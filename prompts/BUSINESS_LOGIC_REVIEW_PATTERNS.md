# Business Logic Review Patterns

Reference material for a business logic review agent. Each section is a self-contained
pattern: what to look for, why it produces wrong behaviour, what the bad code actually looks
like in this codebase, and what correct code looks like. Ordered from most-impactful to least.

---

## 1. Parsing Dates From `<input type="date">` With `new Date(string)`

### Why it matters
This is the single most impactful correctness bug in the codebase. It silently corrupts the
core output — custody assignments on the PDF — for every user in a US timezone.

`<input type="date">` produces a value string like `"2010-03-15"`. Passing that to
`new Date("2010-03-15")` is parsed by the JS engine as **UTC midnight** on that date.
When displayed or diffed in any US timezone (all of which are UTC-negative), the date shifts
backward by one day. A child born on March 15 is recorded as March 14.

Two fields are affected:

- **birthdate** — determines the 18th-birthday cutoff. A one-day shift can cause the final
  year of holidays to be included or excluded incorrectly.
- **startDate** — anchors the entire 2-week custody cycle. A one-day shift moves every single
  holiday assignment in the report. Holidays can flip to the wrong parent.

The project's own CLAUDE.md explicitly states: *"Always use `startOfDay()` when comparing
dates"* and *"All date operations use `date-fns`"*. This bug violates both rules.

### What to detect
- Any `new Date(someString)` where `someString` originates from an `<input type="date">` or
  from a date-only ISO string (`YYYY-MM-DD`). These are always UTC midnight.
- Any date field that is displayed or used in arithmetic without first being anchored to local
  midnight via `startOfDay`.
- The safe alternative: `date-fns` `parseISO` followed by `startOfDay`.

### Bad — actual code

`src/components/InputForm/ChildForm.tsx:39` — birthdate:
```typescript
onSave({
  id: child?.id || Date.now().toString(),
  name: name.trim(),
  birthdate: new Date(birthdate),        // ← "2010-03-15" → UTC midnight March 15
                                         //    → local time March 14 in US timezones
  custodySchedule,
});
```

`src/components/InputForm/ChildForm.tsx:155` — startDate:
```typescript
startDate: e.target.value ? new Date(e.target.value) : undefined,
//                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//  Same bug. Shifts the custody cycle anchor by one day.
//  Every holiday assignment in the report may flip to the wrong parent.
```

### Good
```typescript
import { parseISO, startOfDay } from 'date-fns';

// birthdate:
birthdate: startOfDay(parseISO(birthdate)),

// startDate:
startDate: e.target.value ? startOfDay(parseISO(e.target.value)) : undefined,
```

`parseISO` parses without timezone assumption. `startOfDay` anchors to local midnight.
The combination is the project-standard pattern used everywhere else in the codebase.

---

## 2. Credit Spent at Preview Time — Before User Confirms

### Why it matters
The "Preview Schedule" button calls `checkAndGeneratePDF` to determine whether to show
"Re-generate PDF (No Credit)" or "Generate PDF (1 Credit)" on the preview screen. The
problem: `checkAndGeneratePDF` calls the `check_or_record_generation` RPC, which does not
just check — it *records the generation and spends the credit* if this is a new report.

A credit is silently consumed the moment the user clicks "Preview Schedule", before they have
seen anything or clicked any confirmation button. At $500 per credit, this is a financial
transaction without consent.

### What to detect
- Any call to `checkAndGeneratePDF` (or `check_or_record_generation` RPC) outside of the
  confirmed-action path. Preview, status checks, or UI-state queries must never trigger a
  write.
- Any RPC that combines "check if X exists" and "if not, create X and spend Y" in a single
  function, when the check and the spend need to happen at different points in the user flow.

### Bad — actual code

`src/pages/SchedulePage.tsx:219–241` — the preview handler:
```typescript
const handlePreviewSchedule = async () => {
  // ...
  setTriggerSave(true);
  setCurrentStep('preview');

  try {
    // This RPC both checks AND records. It spends a credit here.
    const result = await checkAndGeneratePDF(scheduleData);
    //             ^^^^^^^^^^^^^^^^^^^^^^^^^
    //  Called at PREVIEW time, not at GENERATE time.
    //  If this is a new report, the credit is spent right now.
    setIsPreviouslyGenerated(result.alreadyGenerated);
  } catch (error) { ... }
};
```

`src/hooks/useCredits.ts:128–133` — the hook that calls the RPC:
```typescript
const { data, error } = await supabase.rpc('check_or_record_generation', {
  data_hash_param: dataHash,
  user_id_param: user.id,
  is_test_mode_param: isTestMode,
});
// This RPC spends a credit and inserts a row into generated_reports.
// It was designed to be called once, at generation time — not at preview time.
```

### Good
Split into two RPCs (or two code paths in one RPC):

- **check-only**: queries `generated_reports` for the hash. Returns whether it exists. Reads
  only. No writes. Safe to call at any time.
- **record-and-spend**: the existing logic. Called only inside the confirmation callback in
  `handleGeneratePDF`, after the user has explicitly clicked "confirm".

The preview handler calls check-only. The generate handler calls record-and-spend.

---

## 3. Confirm Dialog Does Not Await Async Callbacks

### Why it matters
`SchedulePage` passes an `async` function to `showConfirm` as the `onConfirm` callback. That
function does PDF generation, blob creation, URL creation, and a programmatic download. But
`handleConfirm` in `useConfirmDialog` calls `onConfirm()` and immediately calls `hideConfirm()`
on the next line — it does not `await` the returned promise. The dialog closes before the PDF
is generated. If the async callback throws, the rejection is unhandled. The `isGenerating`
state (which controls the button's disabled state) is set to `false` in the callback's
`finally` block, which runs after the dialog is already gone — creating a window where the
button re-enables while the download is still in progress.

### What to detect
- Any `onConfirm` / `onSubmit` / action callback typed as `() => void` that is invoked with
  an `async` function at the call site.
- Any pattern where a callback is invoked and a cleanup/close action runs on the next line
  without `await`.
- The type signature is the tell: if `onConfirm` is `() => void` but callers pass
  `async () => { ... }`, the promise is fire-and-forget.

### Bad — actual code

`src/hooks/useConfirmDialog.ts:3,9` — the type says sync:
```typescript
export interface ConfirmDialogState {
  // ...
  onConfirm: () => void;               // ← typed as sync. No Promise return.
}
```

`src/hooks/useConfirmDialog.ts:49–52` — handleConfirm does not await:
```typescript
const handleConfirm = useCallback(() => {
  dialogState.onConfirm();              // ← returns a Promise (caller passed async fn)
  hideConfirm();                        //    but it is not awaited. Dialog closes now.
}, [dialogState, hideConfirm]);
```

`src/pages/SchedulePage.tsx:150` — caller passes an async function:
```typescript
showConfirm(
  'Generate PDF',
  message,
  async () => {                         // ← async. Returns a Promise.
    try {
      const blob = await pdf(<CustodySchedulePDF ... />).toBlob();
      // ... download logic ...
    } catch (error) {
      showToast('An error occurred...', 'error');  // ← never reached if promise is dropped
    } finally {
      setIsGenerating(false);           // ← runs after dialog already closed
    }
  },
  { confirmLabel, variant: 'info' }
);
```

### Good
```typescript
// Type:
export interface ConfirmDialogState {
  onConfirm: () => void | Promise<void>;   // ← allow async
}

// Handler:
const handleConfirm = useCallback(async () => {
  try {
    await dialogState.onConfirm();         // ← await the promise
  } finally {
    hideConfirm();                         // ← close only after work completes
  }
}, [dialogState, hideConfirm]);
```

---

## 4. No Error Boundary — Any Render Crash Is a Blank Screen

### Why it matters
There is no React Error Boundary anywhere in the application. `PDFDocument` runs
`calculateHolidaysUntilAge18` and `assignCustodyToHolidays` during render. `ReportManager`
loads and parses user-supplied JSON. `ChildForm` processes dates. Any one of these can throw
on malformed input. When they do, React unmounts the entire tree and renders nothing. The user
sees a blank white screen with no message, no retry button, and no way to recover without a
hard refresh.

### What to detect
- Search the entire `src/` tree for `componentDidCatch`, `getDerivedStateFromError`, or any
  component named `ErrorBoundary`. If zero results, the app has no error boundary.
- Pay particular attention to subtrees that do non-trivial computation during render: PDF
  generation, date arithmetic, data transformation.

### Bad — actual code

`src/App.tsx:15–56` — the entire component tree, unwrapped:
```typescript
function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <ToastProvider>
          <SkipLink />
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/schedule" element={
              <ProtectedRoute><SchedulePage /></ProtectedRoute>
            } />
            {/* ... */}
          </Routes>
        </ToastProvider>
      </AuthProvider>
    </BrowserRouter>
  );
  // No <ErrorBoundary> wrapping anything.
}
```

### Good
```typescript
import { ErrorBoundary } from './components/ErrorBoundary';

function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <ToastProvider>
          <SkipLink />
          <ErrorBoundary>            {/* ← catches any render error in the tree */}
            <Routes>
              {/* ... */}
            </Routes>
          </ErrorBoundary>
        </ToastProvider>
      </AuthProvider>
    </BrowserRouter>
  );
}
```

The `ErrorBoundary` component must be a class component (React requirement for this lifecycle):
```typescript
class ErrorBoundary extends React.Component<
  { children: React.ReactNode },
  { hasError: boolean; error: Error | null }
> {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    console.error('ErrorBoundary:', error, info);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center">
          <div className="text-center max-w-md p-8">
            <h1>Something went wrong</h1>
            <p>Please refresh the page to try again.</p>
            <button onClick={() => window.location.reload()}>Refresh</button>
          </div>
        </div>
      );
    }
    return this.props.children;
  }
}
```

---

## 5. `resetData` Resets reportDate to Module-Load Time, Not Now

### Why it matters
`initialScheduleData` is a module-level constant. Its `reportDate: new Date()` is evaluated
once, when the module is first imported. `resetData` sets state back to this frozen object.
If the app has been open for hours and the user clicks "Clear All", the report date resets to
whenever the page was first loaded, not to the current time. The generated PDF will have a
stale report date.

### What to detect
- Any initial-state object defined at module scope that contains `new Date()`.
- Any reset function that returns or sets that module-scope object directly.
- The `new Date()` must be inside a function that is called at reset time, not at import time.

### Bad — actual code

`src/hooks/useScheduleData.ts:4–15`:
```typescript
const initialScheduleData: ScheduleData = {   // ← evaluated ONCE at import time
  parents: {
    parentA: { name: '', id: 'parentA' },
    parentB: { name: '', id: 'parentB' },
  },
  children: [],
  reportDate: new Date(),                     // ← frozen at module load. Never updates.
  preparedBy: '',
  caseNumber: '',
  email: '',
  phoneNumber: '',
};

// useState uses this frozen object:
const [scheduleData, setScheduleData] = useState<ScheduleData>(initialScheduleData);

// resetData sets it back to the same frozen object:
const resetData = () => {
  setScheduleData(initialScheduleData);       // ← reportDate is still the old Date
};
```

### Good
```typescript
const createInitialScheduleData = (): ScheduleData => ({
  parents: {
    parentA: { name: '', id: 'parentA' },
    parentB: { name: '', id: 'parentB' },
  },
  children: [],
  reportDate: new Date(),                     // ← fresh Date every time this runs
  preparedBy: '',
  caseNumber: '',
  email: '',
  phoneNumber: '',
});

// useState calls the factory:
const [scheduleData, setScheduleData] = useState<ScheduleData>(createInitialScheduleData);

// resetData calls it again:
const resetData = () => {
  setScheduleData(createInitialScheduleData());
};
```

---

## 6. Auto-Save Races With Manual Save — State Read, Not Storage Read

### Why it matters
`ReportManager` auto-saves every 30 seconds. `useSavedReports.saveReport` builds the updated
report list from the `savedReports` React state array — not from a fresh read of
`localStorage`. React state updates are asynchronous. If a manual save and an auto-save fire
in close succession, the second one may build its update from a snapshot that does not include
the first save's changes. The second write to `localStorage` overwrites the first. The user
sees "Last saved: [time]" and believes their data is safe, but the actual localStorage
contents are from the earlier snapshot.

### What to detect
- Any save function that reads "current state" from a React `useState` variable rather than
  from the actual persistent store (localStorage, a database, a file).
- Auto-save intervals that call a save function which closes over stale state.
- `setInterval` callbacks that do not use a ref or functional update to access the latest
  state.

### Bad — actual code

`src/hooks/useSavedReports.ts:39–66`:
```typescript
const saveReport = (name: string, data: ScheduleData): string => {
  const existingReport = savedReports.find(r => r.name === name);
  //                      ^^^^^^^^^^^^
  //  This is the React state array. It may be stale if another save
  //  just ran and setSavedReports hasn't flushed yet.

  let updatedReports: SavedReport[];
  if (existingReport) {
    updatedReports = savedReports.map(r =>   // ← built from potentially stale state
      r.name === name ? { ...r, data, lastModified: new Date().toISOString() } : r
    );
  } else {
    updatedReports = [...savedReports, newReport];  // ← same problem
  }

  localStorage.setItem(STORAGE_KEY, JSON.stringify(updatedReports));
  //                                                ^^^^^^^^^^^^^
  //  Writes the stale-based array. Previous save's data may be lost.
  setSavedReports(updatedReports);
```

`src/components/ReportManager/ReportManager.tsx:40–48` — the auto-save interval:
```typescript
useEffect(() => {
  const interval = setInterval(() => {
    if (reportName && reportName.trim() !== '') {
      handleSave(true);                 // ← handleSave closes over stale savedReports
    }
  }, 30000);
  return () => clearInterval(interval);
}, [reportName, currentData]);
// handleSave is NOT in the dep array. It is recreated every render
// but the interval closure captures the version from when the effect ran.
```

### Good
Read from `localStorage` at the top of `saveReport`, not from state:
```typescript
const saveReport = (name: string, data: ScheduleData): string => {
  // Always read the latest from the source of truth
  const stored = localStorage.getItem(STORAGE_KEY);
  const currentReports: SavedReport[] = stored ? JSON.parse(stored) : [];

  const existingReport = currentReports.find(r => r.name === name);
  // ... build updatedReports from currentReports, not from state ...

  localStorage.setItem(STORAGE_KEY, JSON.stringify(updatedReports));
  setSavedReports(updatedReports);       // ← sync state to match what was written
  return reportId;
};
```

---

## 7. JSON Import Has No Schema Validation — Crashes on Malformed Files

### Why it matters
`ReportManager` lets users load `.json` files from disk. The import handler parses the JSON,
does manual date reconstruction, and passes the result directly to `onLoadReport` with no
structural validation. If a required field is missing (e.g. `parents.parentA`), or if a field
has the wrong type, the data flows into React state. Downstream code that assumes the shape —
like `scheduleData.parents.parentA.name.trim()` in `SchedulePage` — throws a TypeError. With
no Error Boundary, the app goes blank.

Zod is already a project dependency. The validation infrastructure is available; it just is
not used here.

### What to detect
- Any code path that parses user-supplied data (JSON files, URL params, form submissions) and
  passes it to application state or rendering without a schema check.
- Particularly dangerous when the data is used in property-access chains (`.foo.bar.baz`)
  that will throw on `undefined`.

### Bad — actual code

`src/components/ReportManager/ReportManager.tsx:204–258`:
```typescript
const handleImport = (event: React.ChangeEvent<HTMLInputElement>) => {
  const file = event.target.files?.[0];
  // ...
  reader.onload = (e) => {
    try {
      const content = e.target?.result as string;
      let jsonContent = content;
      const jsonStart = content.indexOf('{');
      if (jsonStart > 0) jsonContent = content.substring(jsonStart);

      const data = JSON.parse(jsonContent);  // ← could be anything

      // Date reconstruction — runs on whatever shape was parsed:
      if (data.reportDate) data.reportDate = new Date(data.reportDate);
      if (data.children) {
        data.children = data.children.map((child: any) => ({
          ...child,                          // ← "any". No shape guarantee.
          birthdate: new Date(child.birthdate),
          custodySchedule: { ... },
        }));
      }

      onLoadReport(data);                    // ← passes unvalidated data to state
      alert('Data loaded successfully from file!');
    } catch (error) {
      alert('Error loading file...');        // ← only catches JSON parse errors
    }
  };
```

### Good
Define a Zod schema that mirrors `ScheduleData` and validate before loading:
```typescript
import { z } from 'zod';

const ScheduleDataSchema = z.object({
  parents: z.object({
    parentA: z.object({ name: z.string(), id: z.literal('parentA') }),
    parentB: z.object({ name: z.string(), id: z.literal('parentB') }),
  }),
  children: z.array(z.object({
    id: z.string(),
    name: z.string(),
    birthdate: z.string().transform(s => startOfDay(parseISO(s))),
    custodySchedule: z.object({
      scheduleType: z.enum(['5225', '4334']),
      primaryParent: z.enum(['parentA', 'parentB']),
      startDate: z.string().optional().transform(s => s ? startOfDay(parseISO(s)) : undefined),
      dropOffTime: z.string().optional(),
    }),
  })),
  reportDate: z.string().transform(s => new Date(s)),
  preparedBy: z.string(),
  caseNumber: z.string().optional(),
  email: z.string().optional(),
  phoneNumber: z.string().optional(),
});

// In handleImport:
const parsed = ScheduleDataSchema.safeParse(data);
if (!parsed.success) {
  alert('Invalid file format. This is not a valid Custody Schedule Pro data file.');
  return;
}
onLoadReport(parsed.data);   // ← validated and date-transformed
```

---

## 8. `isValidHash` Is Exported But Never Called — Should Be an Active Guard

### Why it matters
`dataHash.ts` exports `isValidHash`, which checks that a hash is a well-formed 64-character
hex string. It is never called anywhere. The hash produced by `generateDataHash` is passed
directly to the `check_or_record_generation` RPC. If the Web Crypto API fails silently or
returns a truncated buffer (edge case in some environments), an invalid hash reaches the
database. The database has a CHECK constraint (`data_hash ~ '^[a-f0-9]{64}$'`), so it would
reject the insert — but the error would surface as a generic RPC failure with no indication
of what went wrong.

### What to detect
- Any exported validation function that is never imported or called.
- Any data that is sent to an external system (database, API) without being validated by an
  available validator first.

### Bad — actual code

`src/utils/dataHash.ts:82–85` — the validator exists:
```typescript
export function isValidHash(hash: string): boolean {
  return /^[a-f0-9]{64}$/.test(hash);
}
// Exported. Never imported anywhere in the project.
```

`src/hooks/useCredits.ts:126–127` — the hash is used without validation:
```typescript
const dataHash = await generateDataHash(scheduleData);
// dataHash is passed directly to the RPC. isValidHash is never called.
const { data, error } = await supabase.rpc('check_or_record_generation', {
  data_hash_param: dataHash,
  ...
});
```

### Good
```typescript
const dataHash = await generateDataHash(scheduleData);

if (!isValidHash(dataHash)) {
  throw new Error('Hash generation failed — produced invalid hash');
}

const { data, error } = await supabase.rpc('check_or_record_generation', {
  data_hash_param: dataHash,
  ...
});
```

---

## 9. Dead Code That Looks Like Active Business Logic

### Why it matters
`patternApplier.ts` implements weekend-pattern custody logic (`every-weekend`,
`alternating-weekend`, `first-third-weekend`, `custom`). It is never imported by any other
file. The actual custody assignment runs through `custodyAssigner.ts` with 5-2-2-5 and 4-3-3-4
patterns only. A developer reading `patternApplier.ts` could reasonably conclude that weekend
patterns are supported, and modify it to fix a bug — with no effect on anything. It is also
the only file that uses the `CustodyPattern` type alias and the `HolidayRule` type, which
creates a false impression that those types are load-bearing.

Similarly, `CustodyPatternInput.tsx` is a full form component that is never rendered. It
defines options for the same dead pattern types.

### What to detect
- Files that export functions or components but are never imported anywhere in `src/`.
- Types that are exported but only referenced by dead files.
- Particularly dangerous when the dead code implements business rules that overlap with
  (but differ from) the active business rules. It becomes a maintenance trap and a source of
  confusion during incident response.

### Bad — files that are dead

`src/utils/patternApplier.ts` — exports `applyPatternToHolidays`. Zero import sites outside
this file. Implements weekend patterns that do not exist in `custodyAssigner.ts`.

`src/components/InputForm/CustodyPatternInput.tsx` — exports a form component. Zero import
sites. Renders options for the same dead patterns.

`src/types/index.ts:55` — `CustodyPatternType` is an alias that is never imported.

### Good
Delete `patternApplier.ts` and `CustodyPatternInput.tsx`. Remove `CustodyPatternType` from
`types/index.ts`. If weekend patterns are a future feature, track them in a ticket and
implement them from scratch when needed — do not preserve speculative dead code.

---

## 10. `new Date()` in PDF Footer Is Non-Deterministic Across Renders

### Why it matters
`PDFDocument` renders `new Date().toLocaleString()` inline in the JSX footer. `@react-pdf/renderer`
can re-render the `Document` component during its layout pass. Each re-render calls
`new Date()` again. In theory, different pages of the same PDF could show different
timestamps. In practice, the window is small — but the pattern is wrong regardless. It also
makes the PDF output non-reproducible: two renders of identical input data at slightly
different times produce visually different PDFs, which is confusing when the hash-based
regeneration system is designed around input-determinism.

### What to detect
- Any `new Date()` call inside a render function or JSX expression (not inside a `useEffect`,
  event handler, or `useMemo`).
- Any value that should be "captured once at the start of an operation" but is instead
  "computed fresh on every render".

### Bad
```typescript
// Inside PDFDocument render:
<Text style={styles.footer}>
  Generated: {new Date().toLocaleString()}   {/* ← fresh on every render */}
</Text>
```

### Good
```typescript
// Capture once at the top of the component, outside the JSX:
const generatedAt = useMemo(() => new Date().toLocaleString(), []);
// Or, if the component receives props that change, pass the timestamp as a prop
// from the call site where the generation was initiated.

<Text style={styles.footer}>
  Generated: {generatedAt}                   {/* ← stable across re-renders */}
</Text>
```
