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

1. Agent checks for `./docs/messaging-brief.md` to determine Standard or Enhanced Mode.
2. Scans the specified file(s) for visible customer-facing text.
3. Skips code, imports, props, and anything not visible to end users.
4. Reviews copy against 6 categories (Standard) or 9 categories (Enhanced) in priority order.
5. Outputs inline annotations with suggested rewrites for every issue found.
6. (Enhanced) Produces Conversion Heuristic scorecard, Brief Alignment report, and Page-Flow Analysis.
7. Closes with a severity-ranked summary table and top priorities.

## Standard vs Enhanced Mode

The copy-reviewer has two modes that activate automatically based on whether a messaging brief exists.

### Standard Mode (no brief)

Activates when `./docs/messaging-brief.md` does not exist. Reviews against 6 categories using generic SaaS best practices and B2B/B2C mode rules. This is the original copy-reviewer behavior.

The agent will display a notice suggesting you create a messaging brief for deeper reviews.

### Enhanced Mode (brief present)

Activates when `./docs/messaging-brief.md` exists. Everything from Standard Mode still runs, plus:

- **Existing categories are enhanced**: CTAs are validated against per-page conversion goals, value props are checked against the messaging hierarchy, social proof expectations are calibrated to company stage, and tone is validated against documented brand voice.
- **3 new categories**: Persuasion Structure, Emotional Arc, Conversion Heuristic.
- **Brief Alignment report**: ICP match, voice compliance, hierarchy coverage, framework adherence.
- **Page-Flow Analysis**: Cross-page funnel alignment, messaging consistency, voice coherence (directory reviews only).

To create a messaging brief, run the `messaging-brief` agent (~15 min interview). See [[messaging-brief-usage]] for details.

## Review Categories (in priority order)

### Standard Mode (6 categories)

| # | Category | What It Catches |
|---|----------|-----------------|
| 1 | CTA Clarity & Placement | Missing, vague, or competing calls-to-action |
| 2 | Value Proposition | Buried or vague "what's in it for me" |
| 3 | Social Proof Signals | Missing trust signals on conversion pages |
| 4 | Readability & Structure | Long sentences, passive voice, dense paragraphs, weak headlines |
| 5 | Grammar & Spelling | Typos, agreement errors, punctuation, inconsistent capitalization |
| 6 | Tone & Style | Voice drift, mode violations, person-switching |

### Enhanced Mode (9 categories)

All 6 Standard categories above (with brief-enhanced criteria), plus:

| # | Category | What It Catches | Requires From Brief |
|---|----------|-----------------|-------------------|
| 7 | Persuasion Structure | Page doesn't follow selected framework (PAS, StoryBrand, JTBD, AIDA, Cialdini); solution before problem; flat feature list instead of persuasion arc | Section 7 (Frameworks) |
| 8 | Emotional Arc | No progression from problem → agitation → solution → trust → action; emotionally flat page; agitation without resolution | Section 2 (ICP), Section 7 (Frameworks) |
| 9 | Conversion Heuristic | MECLabs C = 4M + 3V + 2(I-F) - 2A scoring — identifies whether motivation, value, incentive, friction, or anxiety is the biggest conversion bottleneck | Sections 2, 4, 6 (ICP, Hierarchy, Conversion Goals) |

### Persuasion Frameworks Reference

These frameworks are evaluated in Enhanced Mode category 7 when selected in the brief:

| Framework | Core Question | Best For |
|-----------|--------------|----------|
| **PAS** (Problem-Agitation-Solution) | Does the page establish the problem, twist the knife, then present the fix? | Landing pages, homepage heroes |
| **StoryBrand** | Is the customer the hero and the product the guide? | Brand-driven sites, about pages |
| **JTBD** (Jobs to Be Done) | Does copy address the job the customer is hiring the product for? | Feature pages, comparison pages |
| **AIDA** (Attention-Interest-Desire-Action) | Does the page flow follow this progression? | Any conversion page |
| **Cialdini's Principles** | Which principles are leveraged? (Reciprocity, social proof, authority, scarcity, liking, commitment) | Layered across all pages |
| **MECLabs Heuristic** | C = 4M + 3V + 2(I-F) - 2A — what's the conversion score? | Scoring and prioritizing fixes |

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

### Standard Mode Output

1. **Mode announcement** — Standard Mode notice with brief creation suggestion
2. **Inline annotations** — each issue with original quote, problem, suggested rewrite
3. **Summary table** — 6 rows, severity counts, top priorities, what's working well

### Enhanced Mode Output

1. **Mode announcement** — Enhanced Mode confirmation
2. **Inline annotations** — same format, now covering 9 categories
3. **Conversion Heuristic scorecard** — one per page, MECLabs scoring with weighted factors
4. **Page-Flow Analysis** — cross-page coherence (directory reviews only)
5. **Brief Alignment report** — ICP match, voice compliance, hierarchy coverage, framework adherence
6. **Summary table** — 9 rows, severity counts, top priorities, what's working well

## Page-Flow Analysis

When reviewing a **directory** in Enhanced Mode, the agent produces a cross-page analysis evaluating:

- **Funnel alignment** — do pages follow the documented visitor journey?
- **Cross-page messaging** — is the messaging hierarchy consistent across pages?
- **Voice consistency** — does brand voice hold or drift page-to-page?
- **CTA progression** — do CTAs escalate appropriately through the funnel?
- **Narrative coherence** — does the site tell a coherent story if read in order?

This analysis only appears when reviewing multiple pages with a brief present. It's the agent's answer to the "reviews each file in isolation" gap.

## Severity Guide

| Severity | Fix urgency | Examples |
|----------|-------------|----------|
| Critical | Fix before launch | Missing CTA on landing page, typo in headline, value prop buried below the fold, page presents solution before problem (Enhanced) |
| Medium | Fix soon | Missing testimonials on pricing page, a passive-voice sentence in features, tone drift, flat emotional arc (Enhanced) |
| Low | Polish when you have time | A synonym that would land better, minor style tweak, missed Cialdini opportunity (Enhanced) |

## Example Session — Standard Mode

```
You: copy-reviewer: review src/pages/index.mdx in B2C mode

Agent:
ℹ️  No messaging brief found (./docs/messaging-brief.md).
Running in Standard Mode (6 categories). For strategic, framework-based
reviews (9 categories + persuasion analysis), create a messaging brief:

  Run the messaging-brief agent to set one up (~15 min).

Reviewing src/pages/index.mdx in B2C mode...

[...inline annotations for 6 categories...]

## Review Summary — B2C Standard Mode

| Category                  | Critical | Medium | Low | Total |
|---------------------------|----------|--------|-----|-------|
| CTA Clarity & Placement   |    1     |   0    |  0  |   1   |
| Value Proposition         |    1     |   0    |  0  |   1   |
| Social Proof Signals      |    0     |   1    |  0  |   1   |
| Readability & Structure   |    0     |   2    |  1  |   3   |
| Grammar & Spelling        |    0     |   0    |  2  |   2   |
| Tone & Style              |    0     |   1    |  0  |   1   |
| Totals                    |    2     |   4    |  3  |   9   |
```

## Example Session — Enhanced Mode

```
You: copy-reviewer: review src/pages/index.mdx in B2C mode

Agent:
✅ Messaging brief loaded (./docs/messaging-brief.md).
Running in Enhanced Mode — 9 categories + brief alignment analysis.

Reviewing src/pages/index.mdx in B2C mode...

[...inline annotations for 9 categories...]

### Conversion Heuristic — Homepage

| Factor | Score (1-5) | Weight | Weighted | Notes |
|--------|-------------|--------|----------|-------|
| Motivation (M) | 3 | ×4 | 12 | Addresses ICP pain point but doesn't agitate |
| Value Prop (V) | 2 | ×3 | 6 | Generic — doesn't lead with Value Prop #1 from brief |
| Incentive (I) | 4 | ×2 | 8 | Free trial clearly offered |
| Friction (F) | 2 | ×2 (neg) | -4 | Two competing CTAs create decision friction |
| Anxiety (A) | 3 | ×2 (neg) | -6 | No money-back guarantee or privacy assurance |

Maximum possible: 45 | Score: 16/45

Priority fix: Value Prop (V) — ×3 weight, currently at 2/5. Leading with
the brief's #1 value prop would add 9 points.

## Brief Alignment

### ICP Match
Copy mentions "busy professionals" but the brief's ICP is "Gen Z first-time
investors." The language doesn't match the documented audience.

### Voice Compliance
Brief says Bold + Approachable. Hero copy reads Corporate + Formal —
violates both adjectives.

### Hierarchy Coverage
Value Prop #1 ("Save without thinking about it") is absent from the homepage.
VP #2 appears in the features section. VP #3 is missing entirely.

### Framework Adherence
PAS: Page jumps to solution without establishing the problem. No agitation.
StoryBrand: Product is positioned as the hero, not the customer.

### Gaps in Brief Coverage
Pricing rationale (1776 anchoring) is not supported anywhere in the copy.

## Review Summary — B2C Enhanced Mode

| Category                  | Critical | Medium | Low | Total |
|---------------------------|----------|--------|-----|-------|
| CTA Clarity & Placement   |    1     |   0    |  0  |   1   |
| Value Proposition         |    1     |   1    |  0  |   2   |
| Social Proof Signals      |    0     |   1    |  0  |   1   |
| Readability & Structure   |    0     |   2    |  1  |   3   |
| Grammar & Spelling        |    0     |   0    |  2  |   2   |
| Tone & Style              |    1     |   0    |  0  |   1   |
| Persuasion Structure      |    1     |   0    |  0  |   1   |
| Emotional Arc             |    0     |   1    |  0  |   1   |
| Conversion Heuristic      |    0     |   1    |  0  |   1   |
| Totals                    |    4     |   6    |  3  |  13   |

### Top priorities to address:
1. Page presents solution before problem — violates PAS framework, visitors
   who don't feel understood bounce
2. Value prop doesn't match brief's #1 — homepage should lead with
   "Save without thinking about it"
3. Brand voice violation — copy reads Corporate when brief says Bold + Approachable
```

## What the Agent Will NOT Do

- Modify any files (read-only tools only)
- Review code quality, architecture, or logic
- Suggest layout, spacing, or design changes
- Flag issues on internal/utility pages (account settings, dashboards)
- Invent problems that aren't there
- Apply persuasion frameworks without a messaging brief (categories 7-9 require documented context)
- Hallucinate brand voice guidelines not in the brief

## Tips for Better Results

1. **Create a messaging brief first** — Enhanced Mode reviews are dramatically more useful than Standard Mode. Run the `messaging-brief` agent before your first copy review (~15 min).
2. **Run it per page, not the whole site at once** — reviews are sharper when focused on one page at a time. Use directory mode when you specifically want page-flow analysis.
3. **Match mode to audience** — a pricing page aimed at enterprise buyers is B2B even if the product also has B2C customers.
4. **Act on Criticals first** — the summary table tells you exactly where to focus.
5. **Re-run after edits** — once you've addressed the flagged issues, run again to catch anything new or confirm the page is clean.
6. **Use suggested rewrites as a starting point** — in Enhanced Mode they'll align with your brief's brand voice, but you still know your voice best.
7. **Update the brief as you learn** — after user interviews, competitor research, or a positioning pivot, update the messaging brief so future reviews reflect reality.

## Design Decisions

### Why read-only tools only?
The agent reviews language. It should never silently edit a marketing page. All changes should be deliberate and reviewed by the person who owns the copy.

### Why a mode flag instead of two agents?
The review logic (grammar, readability, CTA structure) is identical across B2B and B2C. Only tone expectations and trust-signal priorities change. A mode flag keeps one set of rules to maintain and avoids drift between two copies of the same agent.

### Why inline annotations + summary?
Inline annotations are what you act on — quote, problem, fix, right next to each other. The summary is what you use to *prioritize*. Both formats serve different needs in the same workflow.

### Why not flag missing social proof on every page?
Social proof matters on conversion pages (landing, pricing, signup). Flagging it on a blog post or an account settings page would be noise. The agent only flags where it would meaningfully affect conversion.

### Why Standard vs Enhanced instead of always Enhanced?
Categories 7-9 (Persuasion Structure, Emotional Arc, Conversion Heuristic) require knowing the ICP, brand voice, and selected frameworks. Without a brief, applying these would mean guessing — which produces noise, not insight. Standard Mode is honest about its limitations rather than hallucinating context.

### Why does the brief live at `./docs/messaging-brief.md`?
Project-level, alongside other durable resources. Unlike technology opinions (global applies across all projects), messaging context is product-specific — your ICP and brand voice don't transfer between products.

## Troubleshooting

### "Agent only extracted a few lines of copy"
The file is probably mostly code with very little visible text. This is expected — the agent skips non-visible content. Point it at a file that has more page-level copy, or check if your copy lives in a CMS or separate content layer.

### "Suggested rewrites don't match our brand voice"
In Standard Mode, the agent works from generic SaaS best practices. Create a messaging brief with your brand voice adjectives and do/don't examples — Enhanced Mode rewrites will align much better.

### "It flagged something on an internal page"
If the agent flags social proof or CTA issues on an internal page, that's a miss on its part. You can ignore those flags. If it keeps happening, note the file paths that are internal so you can exclude them when invoking.

### "Enhanced Mode review feels overwhelming"
The 9-category review produces more output. Use the summary table to prioritize — address Criticals first, then Mediums. The Conversion Heuristic scorecard tells you which single factor would improve the page most.

### "Brief Alignment says my copy doesn't match the brief"
Either the copy needs updating or the brief is outdated. If your messaging has evolved since the brief was written, update the brief first (`messaging-brief: update [section]`), then re-run the review.

## Deployment

```bash
# Symlink into Claude Code agents (recommended)
ln -s /path/to/prompts/agents/copy-reviewer.md ~/.claude/agents/

# Or copy (requires manual updates)
cp /path/to/prompts/agents/copy-reviewer.md ~/.claude/agents/
```

After deploying, restart your Claude Code session. The agent will appear when you type `/agents`.
