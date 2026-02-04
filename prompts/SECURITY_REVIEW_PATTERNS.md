# Security Review Patterns

Reference material for a security review agent. Each section is a self-contained pattern:
what to look for, why it is dangerous, what the bad code actually looks like in this codebase,
and what correct code looks like. Findings are ordered from most-exploitable to least.

---

## 1. SECURITY DEFINER Functions Accept Caller-Supplied User IDs (IDOR)

### Why it matters
PostgreSQL `SECURITY DEFINER` functions run as the function owner (superuser). They bypass
Row Level Security entirely. If one of these functions accepts a `user_id` parameter and does
not verify it equals `auth.uid()`, any authenticated caller can pass any UUID. That means any
user can read or mutate any other user's rows — credits, payment history, report records,
admin status — everything.

This is the highest-priority class of bug in this codebase. It requires no tooling to exploit:
any authenticated Supabase client (including the browser console) can call an RPC directly.

### What to detect
- Any function declared `SECURITY DEFINER` that accepts a `user_id`, `user_uuid`, or
  `user_id_param` argument.
- Check whether the function body ever compares that argument to `auth.uid()`.
- If it does not, it is exploitable. Flag it.
- Also flag functions that are `SECURITY DEFINER` but have no parameter — verify they derive
  the user from `auth.uid()` internally rather than from some other untrusted source.

### Bad — actual code in this codebase

`005_test_mode.sql:267–371` — `spend_credit` accepts `user_uuid` and never checks it:
```sql
CREATE OR REPLACE FUNCTION spend_credit(
  user_uuid UUID,                        -- ← attacker supplies this
  is_test_mode_param BOOLEAN DEFAULT false
)
...
$$ LANGUAGE plpgsql SECURITY DEFINER;    -- ← runs as superuser, RLS is off
-- Body uses user_uuid directly. No "IF user_uuid != auth.uid()" anywhere.
```

`005_test_mode.sql:475–621` — `check_or_record_generation` — same pattern:
```sql
CREATE OR REPLACE FUNCTION check_or_record_generation(
  data_hash_param TEXT,
  user_id_param UUID,                    -- ← attacker supplies this
  is_test_mode_param BOOLEAN DEFAULT false
)
...
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Spends credits and records generations for whatever UUID is passed.
```

`005_test_mode.sql:628–633` — `is_user_admin` is an information-disclosure oracle:
```sql
CREATE OR REPLACE FUNCTION is_user_admin(user_uuid UUID)  -- any UUID
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (SELECT is_admin FROM profiles WHERE id = user_uuid);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Any authenticated user can learn whether any other user is an admin.
```

`005_test_mode.sql:636–651` — `get_credit_balances` leaks any user's balance:
```sql
CREATE OR REPLACE FUNCTION get_credit_balances(user_uuid UUID)  -- any UUID
...
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

`005_test_mode.sql:120–256` — `process_stripe_payment` accepts `user_id_param` and
`credits_amount` with no internal validation of either. This one is legitimately called by
the webhook using the service role key, so the fix is different: restrict it so that only
`service_role` can invoke it, and do not expose it to the `authenticated` role at all.

### Good — the pattern that already works correctly in this codebase

`005_test_mode.sql:381–428` — `modify_credits` does it right:
```sql
CREATE OR REPLACE FUNCTION modify_credits(
  amount INTEGER,                        -- ← no user_id parameter at all
  is_test_mode_param BOOLEAN DEFAULT false
)
...
BEGIN
  SELECT is_admin INTO is_user_admin
  FROM profiles
  WHERE id = auth.uid();                 -- ← derives user from session

  IF NOT is_user_admin THEN              -- ← checks privilege
    RETURN QUERY SELECT FALSE, 0, 'Only admins can modify credits'::TEXT;
    RETURN;
  END IF;
  ...
  WHERE id = auth.uid()                  -- ← operates on session user only
```

`reset_free_report` (`005_test_mode.sql:438–464`) uses the same correct pattern.

### Fix rule
For user-facing functions: remove the `user_id` parameter entirely and derive it from
`auth.uid()` inside the function body. For service-role-only functions like
`process_stripe_payment`: keep the parameter but add a `GRANT` restriction so only
`service_role` can call it, and verify no `authenticated`-role grant exists.

---

## 2. RLS UPDATE Policy Has No Column Restrictions — Privilege Escalation

### Why it matters
The `profiles` table UPDATE policy says "users can update their own row" with no restriction
on which columns. The `profiles` row contains `is_admin`, `live_credits`, `test_credits`, and
`has_free_report`. A user who can write to their own row can set `is_admin = true` and give
themselves unlimited credits — no RPC needed, no exploit, just a direct `.update()` call from
the browser console.

This is compounded by `useProfile.updateProfile`, which accepts `Partial<Profile>` and spreads
it directly into the Supabase update with no allowlist.

### What to detect
- Any RLS UPDATE policy on a table that contains privilege or financial columns, where the
  policy does not restrict which columns can be written.
- Any client-side hook that calls `.update()` with a spread or with unsanitized input shape.
- Particularly dangerous when the type passed to `.update()` includes fields like `is_admin`,
  `credits`, `has_free_report`, or `role`.

### Bad — actual code

`001_initial_setup.sql:77–81` — the policy:
```sql
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);
-- No WITH CHECK clause restricting columns.
-- Any column on the row is writable.
```

`src/hooks/useProfile.ts:44–56` — the hook that exploits it:
```typescript
const updateProfile = async (updates: Partial<Profile>) => {
  // updates could contain { is_admin: true, live_credits: 99999 }
  // TypeScript types are erased at runtime. Nothing stops this.
  const { data, error } = await supabase
    .from('profiles')
    .update({
      ...updates,                        // ← full spread, no allowlist
      updated_at: new Date().toISOString(),
    })
    .eq('id', user.id)
    .select()
    .single();
```

`src/components/TestModeToggle.tsx:19–21` — calls updateProfile with `test_mode_enabled`,
which is an admin-only column, guarded only by a client-side `if (!isAdmin) return null`:
```typescript
await updateProfile({
  test_mode_enabled: !profile.test_mode_enabled,  // admin-only, no server check
});
```

### Good
Two layers are needed:

Layer 1 — the hook: explicitly allowlist what can be written:
```typescript
const updateProfile = async (updates: { name?: string; phone_number?: string | null }) => {
  const { data, error } = await supabase
    .from('profiles')
    .update({
      name: updates.name,
      phone_number: updates.phone_number,
      updated_at: new Date().toISOString(),
    })
    .eq('id', user.id)
    .select()
    .single();
```

Layer 2 — the database: create a dedicated RPC for any write that touches privilege columns,
identical in structure to how `modify_credits` already works. The RPC checks `is_admin`
server-side before writing.

---

## 3. Webhook Selects Verification Key From Unverified Payload

### Why it matters
Stripe webhook signature verification is the only thing preventing forged payment events.
The webhook handler in this codebase determines which secret to use for verification by
reading `livemode` from the raw request body — *before* calling `constructEvent`. The mode
selection happens before any cryptographic check. An attacker who knows or brute-forces one
of the two webhook secrets can sign a forged body with it, set `livemode` to route to that
secret, and have the event accepted. The forged event can then grant credits to any user.

### What to detect
- Any webhook handler that reads fields from the raw body before calling the SDK's event
  verification function.
- Any logic that selects which secret/key to use based on data inside the unverified payload.
- The correct pattern: attempt verification against all configured secrets; whichever succeeds
  is authoritative. Only then read fields from the verified event.

### Bad — actual code

`supabase/functions/stripe-webhook/index.ts:31–48`:
```typescript
// Line 35: parse body BEFORE verification to read livemode
const bodyObj = JSON.parse(body);
isTestMode = bodyObj.livemode === false;        // ← from UNVERIFIED payload

// Line 47: use that unverified value to pick the secret
const webhookSecret = isTestMode ? stripeTestWebhookSecret : stripeLiveWebhookSecret;

// Line 77: verification happens AFTER the key was already chosen
const event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
//                                                              ^^^^^^^^^^
// If the attacker chose the wrong livemode, wrong secret is used, and
// verification fails — but the attacker just sets livemode to match
// whichever secret they know.
```

### Good
```typescript
let event: Stripe.Event | null = null;
const secrets = [
  { secret: stripeLiveWebhookSecret, isTest: false },
  { secret: stripeTestWebhookSecret, isTest: true },
];

for (const { secret, isTest } of secrets) {
  if (!secret) continue;
  try {
    event = Stripe.webhooks.constructEvent(body, signature, secret);
    // Verification succeeded — this secret is authoritative.
    // NOW read livemode, metadata, etc. from the verified event.
    break;
  } catch {
    // Signature did not match this secret. Try the next one.
  }
}

if (!event) {
  return new Response(JSON.stringify({ error: 'Invalid signature' }), { status: 400 });
}
// event is now verified. Trust its contents.
```

---

## 4. Webhook Trusts Metadata Without Verifying Against Actual Charge

### Why it matters
The webhook extracts `credits` from `session.metadata.credits` and passes it directly to the
`process_stripe_payment` RPC, which adds that many credits to the user's account. Stripe
session metadata is mutable — it can be changed after creation via the Stripe Dashboard or
API. If an attacker gains any Stripe account access (compromised credentials, leaked API key),
they can modify the metadata to claim 5 credits while only paying for 1. The amount recorded
in `payment_transactions.amount_cents` is computed from the metadata value, not from what
Stripe actually charged, so the audit trail is also falsified.

### What to detect
- Any webhook handler that reads a quantity or amount from `metadata` and uses it to grant
  something (credits, access, permissions) without cross-referencing against the actual
  transaction amount (`amount_total`, `amount_paid`) on the verified session object.
- Pricing logic that exists only in one place. If the webhook does not know what each credit
  tier costs, it cannot verify.

### Bad — actual code

`supabase/functions/stripe-webhook/index.ts:92–119`:
```typescript
const credits = parseInt(session.metadata?.credits || '0', 10);
// ^ credits value comes entirely from metadata. No verification.

await supabase.rpc('process_stripe_payment', {
  session_id_param: session.id,
  user_id_param: userId,
  credits_amount: credits,               // ← passed straight through
  is_test_mode_param: isTestModeFromMetadata,
});
```

`005_test_mode.sql:169–173` — the SQL function computes `amount_cents` from `credits_amount`
but never receives or checks the actual Stripe `amount_total`:
```sql
IF credits_amount = 5 THEN
  amount_cents_calc := 200000;
ELSE
  amount_cents_calc := credits_amount * 50000;
END IF;
-- This is what gets recorded. It is derived from the metadata, not from Stripe.
```

### Good
After verifying the event, re-fetch the session from Stripe to get the authoritative object,
then validate:
```typescript
const verifiedSession = await stripe.checkout.sessions.retrieve(event.data.object.id);
const expectedCents = credits === 5 ? 200000 : 50000;

if (verifiedSession.amount_total !== expectedCents) {
  console.error('Amount mismatch', { expected: expectedCents, actual: verifiedSession.amount_total });
  return new Response(JSON.stringify({ error: 'Amount mismatch' }), { status: 400 });
}
// Only now call process_stripe_payment.
```

---

## 5. Client-Side Credit Addition Via Direct Table Write

### Why it matters
`useCredits.addCredits` performs a `.update()` on `profiles` to set the credit column. It
reads the current balance from React state (not from the database), adds the amount, and
writes the result back. Two problems: (a) any authenticated user can call this from the
browser console with any amount, and (b) even legitimate calls are a non-atomic
read-modify-write that can lose updates under concurrency.

Credits are the revenue model. This function, as written, lets any user grant themselves
unlimited credits without payment.

### What to detect
- Any client-side code that writes directly to a credit/balance/quota column via `.update()`.
- Any `.update()` that computes a new value by reading from React state and adding to it,
  rather than using a server-side atomic increment (RPC with `column = column + $amount`).
- Credit additions should flow exclusively through server-side RPCs: `process_stripe_payment`
  (webhook-driven) or `modify_credits` (admin-only RPC).

### Bad — actual code

`src/hooks/useCredits.ts:60–101`:
```typescript
const addCredits = async (amount: number, testMode: boolean = false) => {
  const creditColumn = testMode ? 'test_credits' : 'live_credits';
  const currentCredits = testMode ? (profile?.test_credits || 0) : (profile?.live_credits || 0);
  //    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  //    Read from React state, not from a locked DB row.

  const { error } = await supabase
    .from('profiles')
    .update({
      [creditColumn]: currentCredits + amount,  // ← non-atomic. Race-losable.
      updated_at: new Date().toISOString(),
    })
    .eq('id', user.id);                         // ← RLS allows this write.

  // Then inserts a credit_transactions row SEPARATELY — not in a transaction.
  // If the insert fails, credits are added with no audit trail.
  await supabase.from('credit_transactions').insert({ ... });
```

### Good
Remove `addCredits` from `useCredits` entirely. Credit additions must happen only via:
- `process_stripe_payment` RPC (called by the webhook, service-role only).
- `modify_credits` RPC (admin-only, already correctly implemented).

If a non-admin flow ever needs to trigger a credit addition (it should not), it must go
through an Edge Function that verifies the triggering condition server-side.

---

## 6. CORS Wildcard on Payment Endpoint + Open Redirect via Origin Header

### Why it matters
The `create-checkout-session` Edge Function sets `Access-Control-Allow-Origin: *`. It also
constructs `success_url` and `cancel_url` for Stripe from `req.headers.get('origin')` with no
validation. These are two related problems:

The wildcard CORS means any website can make a request to this endpoint if it has a valid
Supabase token. The unvalidated Origin means an attacker can set Origin to
`https://evil.com`, and Stripe will redirect the user to `https://evil.com/profile?payment=success`
after a real payment completes. That attacker-controlled page can then phish for credentials
or present a fake "payment failed, re-enter card" screen.

### What to detect
- `Access-Control-Allow-Origin: *` on any endpoint that performs a privileged action
  (creates sessions, modifies data, initiates payments).
- Any URL construction that uses `req.headers.get('origin')` without checking it against a
  hardcoded allowlist.
- Any Edge Function that returns user-facing redirect URLs derived from request headers.

### Bad — actual code

`supabase/functions/create-checkout-session/index.ts:12–15`:
```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',    // ← any origin on the internet
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};
```

`supabase/functions/create-checkout-session/index.ts:103,124–125`:
```typescript
const origin = req.headers.get('origin') || 'http://localhost:5173';
// ← no validation. Attacker sets this to https://evil.com.

const session = await stripe.checkout.sessions.create({
  success_url: `${origin}/profile?payment=success`,  // ← open redirect
  cancel_url:  `${origin}/checkout?canceled=true`,   // ← open redirect
```

### Good
```typescript
const ALLOWED_ORIGINS = [
  'http://localhost:5173',
  'https://custodyschedulepro.com',
  'https://staging--custodyschedule.netlify.app',
];

const requestOrigin = req.headers.get('origin') || '';
const origin = ALLOWED_ORIGINS.includes(requestOrigin)
  ? requestOrigin
  : 'https://custodyschedulepro.com';   // ← safe fallback

const corsHeaders = {
  'Access-Control-Allow-Origin': origin, // ← specific, not wildcard
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};
```

---

## 7. PII Written to sessionStorage, Then Written to Database With No Validation

### Why it matters
The signup flow stores `{ name, phone }` in `sessionStorage` so it survives the magic-link
redirect. `sessionStorage` is readable by any JavaScript on the same origin — including
injected scripts or browser extensions. More critically, `AuthCallbackPage` reads that data
back and writes it directly to the `profiles` table with no length check, no type check, and
no sanitization. The `name` column is `TEXT NOT NULL` with no length constraint. A tampered
`sessionStorage` entry can inject arbitrarily long or malformed values into the database.

### What to detect
- PII (name, phone, email, address) stored in `sessionStorage` or `localStorage` in plaintext.
- Any code path that reads from `sessionStorage` / `localStorage` and writes the result to a
  database without validating shape, types, and lengths first.
- `JSON.parse` on storage values followed by direct use in a `.update()` or `.insert()`.

### Bad — actual code

`src/pages/SignupPage.tsx:41–44` — writes PII to sessionStorage:
```typescript
sessionStorage.setItem('pendingSignup', JSON.stringify({
  name: formData.name,   // ← PII, no encryption, no expiry
  phone: formData.phone,
}));
```

`src/pages/AuthCallbackPage.tsx:22–43` — reads it back and writes to DB:
```typescript
const pendingSignup = sessionStorage.getItem('pendingSignup');
if (pendingSignup) {
  const signupData = JSON.parse(pendingSignup);   // ← no try/catch on this line
  // signupData could be anything if sessionStorage was tampered with.

  await supabase
    .from('profiles')
    .update({
      name: signupData.name,                      // ← no length/type check
      phone_number: signupData.phone || null,     // ← no format validation
      updated_at: new Date().toISOString(),
    })
    .eq('id', session.user.id);
```

### Good
Validate before writing:
```typescript
const signupData = JSON.parse(pendingSignup);

const name = typeof signupData.name === 'string'
  ? signupData.name.trim().slice(0, 100)
  : null;

const phone = typeof signupData.phone === 'string'
  ? signupData.phone.replace(/\D/g, '').slice(0, 15)   // digits only, max 15
  : null;

if (!name) {
  // Name is required. Do not write. Redirect to signup.
  navigate('/signup');
  return;
}

await supabase.from('profiles').update({ name, phone_number: phone, ... });
```

---

## 8. Payment-Success Banner Trusts Query Parameter, Not Actual Payment State

### Why it matters
`/profile?payment=success` displays a large "Payment Successful!" banner and tells the user
credits have been added. The banner is triggered solely by the presence of the query
parameter. Anyone can navigate to this URL at any time. In a legal/custody context where
users may be under stress, a link like `/profile?payment=success` is a social-engineering
vector — it can make someone believe they have credits when they do not.

### What to detect
- Any UI that displays a "success" or "completed" state based on a URL query parameter
  without verifying the underlying operation actually succeeded.
- Particularly dangerous when the success state involves money or access changes.

### Bad — actual code

`src/pages/ProfilePage.tsx:37–39`:
```typescript
useEffect(() => {
  if (searchParams.get('payment') === 'success') {
    setPaymentSuccess(true);              // ← banner shown. No DB check.
    refreshProfile();                     // ← refresh happens, but banner is
                                          //    already visible before it resolves
```

### Good
```typescript
useEffect(() => {
  if (searchParams.get('payment') === 'success') {
    // Do not show banner yet. Refresh profile first, then check.
    refreshProfile().then(() => {
      // Verify a recent completed payment actually exists
      supabase
        .from('payment_transactions')
        .select('id')
        .eq('user_id', user.id)
        .eq('status', 'completed')
        .gte('completed_at', new Date(Date.now() - 60_000).toISOString()) // last 60s
        .single()
        .then(({ data }) => {
          if (data) setPaymentSuccess(true);
          // If no recent payment, do not show the banner.
        });
    });
  }
}, [searchParams]);
```

---

## 9. Missing Content-Security-Policy Header

### Why it matters
CSP is the browser's primary defence against XSS. Without it, any injected script runs with
full access to the page's DOM, cookies, localStorage, and — critically — the Supabase auth
token stored in memory. An attacker who achieves XSS can read the token and make authenticated
API calls: calling RPCs, writing to tables, initiating Stripe sessions. CSP does not prevent
XSS, but it limits what injected code can do.

### What to detect
- Check `netlify.toml` (or equivalent deployment config) for a `Content-Security-Policy`
  header in the `[[headers]]` block.
- If absent, flag it.
- If present, verify it does not contain `unsafe-inline` or `unsafe-eval` without a nonce.

### Bad — actual code

`netlify.toml:35–41` — security headers block has no CSP:
```toml
[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"
    # Content-Security-Policy is missing entirely.
```

### Good
Add a CSP appropriate for React + Supabase + Stripe. Starting point:
```toml
Content-Security-Policy = "default-src 'self'; script-src 'self' https://js.stripe.com; connect-src 'self' https://*.supabase.co https://api.stripe.com; frame-src https://checkout.stripe.com; img-src 'self' data:;"
```
Tune based on all external resources the app actually loads. Test in report-only mode first.

---

## 10. Race Condition in Credit Deduction — Missing FOR UPDATE Lock

### Why it matters
Two concurrent requests (e.g. a double-click on "Generate PDF") can both read the credit
balance, both see it is >= 1, and both deduct. The result: two credits spent from a balance
of one. The `spend_credit` function correctly uses `FOR UPDATE` to prevent this. The
`check_or_record_generation` function does not. The inconsistency means one code path is safe
and the other is not.

### What to detect
- Any `SECURITY DEFINER` function that reads a balance, checks it, and then updates it in
  separate statements.
- If the read does not include `FOR UPDATE`, the function is vulnerable to concurrent
  double-spend.
- Compare all such functions against each other. If one uses `FOR UPDATE` and another does
  not, the one without it is the bug.

### Bad — actual code

`005_test_mode.sql:522–530` — reads balance without locking:
```sql
-- Inside check_or_record_generation:
IF is_test_mode_param THEN
  SELECT test_credits, has_free_report INTO current_credits, has_free
  FROM profiles
  WHERE id = user_id_param;              -- ← no FOR UPDATE
ELSE
  SELECT live_credits, has_free_report INTO current_credits, has_free
  FROM profiles
  WHERE id = user_id_param;              -- ← no FOR UPDATE
END IF;
-- Then later, at line 580–587, it deducts unconditionally.
-- Two concurrent calls both pass the balance check.
```

### Good — the pattern that already works in this file

`005_test_mode.sql:282–289` — `spend_credit` does it right:
```sql
SELECT
  has_free_report,
  live_credits,
  test_credits
INTO user_record
FROM profiles
WHERE id = user_uuid
FOR UPDATE;                              -- ← locks the row. Second caller blocks.
```

---

## 11. Edge Functions Return Raw Internal Error Messages

### Why it matters
Both Edge Functions catch errors and return `err.message` in the JSON response body. Stripe
SDK errors and Supabase errors can contain internal URLs, database schema details, API key
prefixes, or stack traces. These are useful to an attacker mapping the system.

### What to detect
- Any `catch` block in an Edge Function (or any server-side handler) that returns
  `err.message` or `error.message` directly in the response body.
- The response should contain a generic message. The full error should be logged server-side
  only.

### Bad — actual code

`supabase/functions/create-checkout-session/index.ts:147–151`:
```typescript
if (err instanceof Error) {
  return new Response(
    JSON.stringify({ error: err.message }),  // ← internal details to caller
    { status: 500, headers: { ... } }
  );
}
```

### Good
```typescript
console.error('Checkout session error:', err);   // ← full error server-side only
return new Response(
  JSON.stringify({ error: 'An internal error occurred. Please try again.' }),
  { status: 500, headers: { ... } }
);
```

---

## 12. Migration Idempotency Guards Are No-Ops

### Why it matters
Each migration file begins with a `DO $$ … IF EXISTS … RETURN; END IF; END $$;` block
intended to skip execution if the migration was already applied. In PostgreSQL, `RETURN`
inside an anonymous `DO` block exits only that block. The remaining top-level SQL statements
— including `DROP POLICY IF EXISTS` and `DROP FUNCTION IF EXISTS` — execute regardless. This
means every time a migration file is run, RLS policies are briefly dropped and re-created.
During that window, RLS is not enforced.

### What to detect
- Any migration file that uses `DO $$ … RETURN … END $$;` as an idempotency guard, followed
  by top-level DDL statements outside that block.
- The guard only works if the entire migration body is inside the `DO` block, or if the
  migration runner tracks applied migrations externally (which `run.sh` does not do — it
  relies on these in-file guards).

### Bad — actual code

`001_initial_setup.sql:17–24`:
```sql
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM schema_migrations WHERE version = '001') THEN
    RAISE NOTICE 'Migration 001 already applied, skipping...';
    RETURN;                              -- ← exits the DO block only
  END IF;
END $$;

-- Everything below this line STILL EXECUTES even if RETURN ran above.
CREATE TABLE IF NOT EXISTS profiles ( ... );
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;  -- ← RLS gap
CREATE POLICY "Users can read own profile" ...
```

All five migration files have this same structure.
