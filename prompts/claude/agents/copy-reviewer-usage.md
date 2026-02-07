# Copy Reviewer — Usage Guide

## Quick Start

### Basic Invocation

Point the agent at a single file:
```
copy-reviewer: review src/pages/landing.mdx in B2B mode
```

Point it at a directory (reviews all page files inside):
```
copy-reviewer: review the src/pages/ directory in B2C mode
```

If you forget the mode, the agent will ask before starting.

### What Happens

1. Agent scans the specified file(s) for visible customer-facing text.
2. Skips code, imports, props, and anything not visible to end users.
3. Reviews copy against 6 categories in priority order (see below).
4. Outputs inline annotations with suggested rewrites for every issue found.
5. Closes with a severity-ranked summary table and top priorities.

## Review Categories (in priority order)

| # | Category | What It Catches |
|---|----------|-----------------|
| 1 | CTA Clarity & Placement | Missing, vague, or competing calls-to-action |
| 2 | Value Proposition | Buried or vague "what's in it for me" |
| 3 | Social Proof Signals | Missing trust signals on conversion pages |
| 4 | Readability & Structure | Long sentences, passive voice, dense paragraphs, weak headlines |
| 5 | Grammar & Spelling | Typos, agreement errors, punctuation, inconsistent capitalization |
| 6 | Tone & Style | Voice drift, mode violations, person-switching |

## B2B vs B2C Mode — When to Use Which

### Use B2B mode when:
- The buyer is a business or a decision-maker at a company
- The page needs to feel professional and authoritative
- Trust signals are logos, case studies, security certs, compliance badges
- Reading level should be 8th–10th grade

### Use B2C mode when:
- The buyer is an individual consumer or end user
- The page should feel warm, approachable, and human
- Trust signals are reviews, star ratings, user counts, money-back guarantees
- Reading level should be 6th–8th grade

### Not sure?
Look at who lands on the page. If it's a founder evaluating tools for their team → B2B. If it's a person signing up for their own use → B2C. Some sites have both — run the relevant pages in the appropriate mode.

## Output Format

The agent produces two things:

### Inline Annotations
Every issue is flagged individually:
- The exact original text (quoted)
- A clear explanation of the problem
- A specific suggested rewrite

Issues are grouped by page/section as they appear, so you can work through fixes top-to-bottom.

### Summary Table
At the end, a table breaks down issue counts by category and severity (Critical / Medium / Low), plus:
- **Top priorities** — the 2–3 things to fix first
- **What's working well** — honest callout of copy that's doing its job

## Severity Guide

| Severity | Fix urgency | Examples |
|----------|-------------|----------|
| Critical | Fix before launch | Missing CTA on landing page, typo in headline, value prop buried below the fold |
| Medium | Fix soon | Missing testimonials on pricing page, a passive-voice sentence in features, tone drift |
| Low | Polish when you have time | A synonym that would land better, minor style tweak |

## Example Session

```
You: copy-reviewer: review src/pages/index.mdx in B2C mode

Agent: Reviewing src/pages/index.mdx in B2C mode...

[Reads the file, extracts visible copy]

---
📍 Homepage → Hero section
🔍 Category: Value Proposition
⚠️  Severity: Critical

Original:
> "We build software solutions for the modern enterprise."

Problem:
This leads with what the company does, not what the user gains.
No concrete benefit is communicated. A visitor scanning quickly
will not understand why they should care.

Suggested rewrite:
> "Cut your weekly reporting time in half — starting today."
---

📍 Homepage → Hero section
🔍 Category: CTA Clarity & Placement
⚠️  Severity: Critical

Original:
> [Button: "Go"]

Problem:
"Go" does not tell the visitor what happens next.
CTAs must state the outcome to drive clicks.

Suggested rewrite:
> [Button: "Start for free"]
---

[...more annotations...]

## Review Summary — B2C Mode

| Category                  | Critical | Medium | Low | Total |
|---------------------------|----------|--------|-----|-------|
| CTA Clarity & Placement   |    1     |   0    |  0  |   1   |
| Value Proposition         |    1     |   0    |  0  |   1   |
| Social Proof Signals      |    0     |   1    |  0  |   1   |
| Readability & Structure   |    0     |   2    |  1  |   3   |
| Grammar & Spelling        |    0     |   0    |  2  |   2   |
| Tone & Style              |    0     |   1    |  0  |   1   |
| Totals                    |    2     |   4    |  3  |   9   |

### Top priorities to address:
1. Hero value prop is company-focused, not user-focused — kills first impression
2. CTA button text is non-descriptive — reduces click-through

### What's working well:
- Feature descriptions are concise and use active voice consistently
- Pricing section has a clear 3-tier comparison that's easy to scan
```

## What the Agent Will NOT Do

- Modify any files (read-only tools only)
- Review code quality, architecture, or logic
- Suggest layout, spacing, or design changes
- Flag issues on internal/utility pages (account settings, dashboards)
- Invent problems that aren't there

## Tips for Better Results

1. **Run it per page, not the whole site at once** — reviews are sharper when focused on one page at a time.
2. **Match mode to audience** — a pricing page aimed at enterprise buyers is B2B even if the product also has B2C customers.
3. **Act on Criticals first** — the summary table tells you exactly where to focus.
4. **Re-run after edits** — once you've addressed the flagged issues, run again to catch anything new or confirm the page is clean.
5. **Use suggested rewrites as a starting point** — they're directionally correct but you know your brand voice best.

## Design Decisions

### Why read-only tools only?
The agent reviews language. It should never silently edit a marketing page. All changes should be deliberate and reviewed by the person who owns the copy.

### Why a mode flag instead of two agents?
The review logic (grammar, readability, CTA structure) is identical across B2B and B2C. Only tone expectations and trust-signal priorities change. A mode flag keeps one set of rules to maintain and avoids drift between two copies of the same agent.

### Why inline annotations + summary?
Inline annotations are what you act on — quote, problem, fix, right next to each other. The summary is what you use to *prioritize*. Both formats serve different needs in the same workflow.

### Why not flag missing social proof on every page?
Social proof matters on conversion pages (landing, pricing, signup). Flagging it on a blog post or an account settings page would be noise. The agent only flags where it would meaningfully affect conversion.

## Troubleshooting

### "Agent only extracted a few lines of copy"
The file is probably mostly code with very little visible text. This is expected — the agent skips non-visible content. Point it at a file that has more page-level copy, or check if your copy lives in a CMS or separate content layer.

### "Suggested rewrites don't match our brand voice"
The agent works from SaaS best practices and the B2B/B2C mode rules. Treat suggestions as directional — rewrite in your voice, but keep the structural fix (e.g., if it flagged a missing outcome in a CTA, make sure your rewrite still states the outcome).

### "It flagged something on an internal page"
If the agent flags social proof or CTA issues on an internal page, that's a miss on its part. You can ignore those flags. If it keeps happening, note the file paths that are internal so you can exclude them when invoking.

## Deployment

```bash
# Symlink into Claude Code agents (recommended)
ln -s /Users/zack/projects/promps/prompts/claude/agents/copy-reviewer.md ~/.claude/agents/

# Or copy (requires manual updates)
cp /Users/zack/projects/promps/prompts/claude/agents/copy-reviewer.md ~/.claude/agents/
```

After deploying, restart your Claude Code session. The agent will appear when you type `/agents`.
