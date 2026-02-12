# Messaging Brief — Usage Guide

## Quick Start

### Create a Brief

```
messaging-brief: set up a messaging brief for this project
```

The agent walks you through 7 sections (~15-25 min). If you don't have answers for everything, it marks gaps as "Not yet documented" — partial briefs are still useful.

### Update an Existing Brief

```
messaging-brief: add a new competitor to the brief
messaging-brief: update the brand voice section
messaging-brief: re-do the messaging brief from scratch
```

### What Happens

1. Agent checks if `./docs/messaging-brief.md` exists.
2. If not, conducts the full 7-section interview.
3. If yes, asks what you want to do (quick add, targeted update, re-interview, or view current brief).
4. Writes or updates the file.
5. The copy-reviewer agent automatically detects the brief and switches to Enhanced Mode.

## File Format Reference

The brief is stored at `./docs/messaging-brief.md` with YAML frontmatter:

```yaml
---
version: 1.0.0
created: 2026-02-12
last_updated: 2026-02-12
product: Product Name
stage: beta | launched | growing | established
audience_type: B2B | B2C | Both
---
```

### 7 Sections

| # | Section | What It Captures | Why Copy-Reviewer Needs It |
|---|---------|-----------------|--------------------------|
| 1 | Company & Product | Name, category, stage, one-liner | Calibrates social proof expectations to company stage |
| 2 | Target Customer / ICP | Demographics, pain points, customer voice quotes, awareness stage | Validates copy speaks to the right audience in their language |
| 3 | Competitive Positioning | Competitors, differentiators, positioning statement | Checks value prop is differentiated, not generic |
| 4 | Messaging Hierarchy | #1/#2/#3 value props with evidence | Verifies homepage leads with #1, pages follow ranked priority |
| 5 | Brand Voice | Adjectives, do/don't examples, tone spectrum, vocabulary rules | Validates tone against documented voice, not just B2B/B2C defaults |
| 6 | Conversion Architecture | Per-page goals, funnel structure, pricing rationale | Checks CTAs match documented goals, pages follow funnel |
| 7 | Applicable Frameworks | PAS, StoryBrand, JTBD, AIDA, Cialdini, MECLabs | Enables Persuasion Structure, Emotional Arc, and Conversion Heuristic categories |

## Interview Walkthrough

### Section 1: Company & Product
Straightforward — name, category, stage, one-liner. Takes ~2 minutes. The stage matters because it determines what social proof is realistic to expect.

### Section 2: Target Customer / ICP
The most important section. The agent asks for:
- A description of your ideal customer
- Pain points ranked #1, #2, #3
- Actual customer quotes (from interviews, surveys, support tickets, Reddit — verbatim, not paraphrased)
- Awareness stage of typical visitors

**Tip**: If you don't have customer quotes yet, say so. "Not yet documented" is better than made-up quotes. Come back and add them after user interviews.

### Section 3: Competitive Positioning
Name your competitors (including "doing nothing"). For each, describe one strength and one weakness. Then state your 1-3 differentiators and fill in the positioning statement template:

> For [target user] who [problem], [Product] is a [category] that [key benefit], unlike [alternatives] because [differentiator].

### Section 4: Messaging Hierarchy
Rank your top 3 value props. For each, provide evidence if you have it (stats, customer quotes, case studies). The copy-reviewer uses this to check that your homepage leads with #1 and other pages don't contradict the hierarchy.

### Section 5: Brand Voice
Describe your voice in 3-5 adjectives, then give a DO and DON'T example for each. Rate your tone on four spectrums (Formal↔Casual, Serious↔Playful, Technical↔Simple, Reserved↔Enthusiastic). List any always-use and never-use words.

### Section 6: Conversion Architecture
Walk through your main pages and state the primary conversion goal for each. Describe your funnel (how a visitor goes from landing to paying). Note any pricing rationale the copy needs to support.

### Section 7: Applicable Frameworks
The agent explains each framework and asks which ones resonate. If you're unsure, it recommends based on your stage and audience type. You can always change these later.

## Workflows

### Quick Add

For adding a single piece of information:

```
messaging-brief: add competitor — Mint, good brand recognition but feels outdated
```

The agent reads the existing brief, adds to the right section, checks for conflicts, and updates the last_updated date.

### Targeted Update

For revising a specific section:

```
messaging-brief: update the messaging hierarchy — we changed our #1 value prop
```

The agent shows the current section, asks targeted questions, and updates.

### Full Re-Interview

For a complete refresh (e.g., after a pivot):

```
messaging-brief: re-do the messaging brief from scratch
```

The agent walks through all 7 sections again but shows your current answers so you can keep, update, or replace each one.

## How Copy-Reviewer Consumes the Brief

When you run `copy-reviewer`, it:

1. Checks for `./docs/messaging-brief.md` before reading any page files.
2. If found, loads it and activates **Enhanced Mode**:
   - All 6 standard categories run with brief-enhanced criteria
   - 3 additional categories activate (Persuasion Structure, Emotional Arc, Conversion Heuristic)
   - Brief Alignment report is produced
   - Page-Flow Analysis runs on directory reviews
3. If not found, runs **Standard Mode** (the original 6 categories) with a notice suggesting you create a brief.

### What Enhanced Mode Adds

| Enhancement | What Changes |
|-------------|-------------|
| CTA Clarity | Validates against per-page conversion goals |
| Value Proposition | Checks alignment with messaging hierarchy |
| Social Proof | Calibrates expectations to company stage |
| Tone & Style | Validates against brand voice adjectives and vocabulary rules |
| Persuasion Structure (new) | Evaluates page against selected frameworks |
| Emotional Arc (new) | Rates problem→agitation→solution→trust→action progression |
| Conversion Heuristic (new) | MECLabs C = 4M + 3V + 2(I-F) - 2A scoring |
| Brief Alignment (new) | ICP match, voice compliance, hierarchy coverage report |
| Page-Flow Analysis (new) | Cross-page funnel, messaging, and voice coherence |

## Manual Editing

The brief is a markdown file — edit it directly in your IDE or Obsidian. The messaging-brief agent treats your manual edits as authoritative. A few guidelines:

- Keep the YAML frontmatter valid (don't remove required fields).
- Update `last_updated` when you make manual changes.
- Keep the section structure intact so the copy-reviewer can parse it.
- Adding content within sections is always safe.
- If you remove a section entirely, the copy-reviewer will skip that aspect of Enhanced Mode rather than fail.

## Version Control

The brief lives at `./docs/messaging-brief.md` in your project repo. Treat it like any other project file:

```bash
git add docs/messaging-brief.md
git commit -m "docs: create messaging brief for copy reviews"
```

Update commits:
```bash
git add docs/messaging-brief.md
git commit -m "docs: update ICP and brand voice in messaging brief"
```

The YAML frontmatter tracks `version`, `created`, and `last_updated` for reference.

## Design Decisions

### Why project-only (no global tier)?

Unlike technology opinions (TypeScript preference applies to all projects), messaging context is product-specific. Your ICP, brand voice, competitors, and conversion goals are different for each product. A global messaging brief would be misleading.

### Why `./docs/` and not project root?

The `./docs/` directory is where other durable resources in the agent chain live. Keeps the project root clean while making the brief discoverable.

### Why interview-based (not a template to fill in)?

People give better answers in conversation than in blank forms. The agent asks follow-up questions, offers examples, and captures rationale — things a template can't do. You can always edit the file directly afterward.

### Why "Not yet documented" instead of skipping?

Explicit gaps are more useful than missing sections. When the copy-reviewer sees "Not yet documented" for customer voice quotes, it knows to work around the gap. If the section were just missing, it might misinterpret the brief's structure.

### Why does the copy-reviewer need this?

Without messaging context, the copy-reviewer can only check grammar, readability, and generic SaaS best practices. With the brief, it can evaluate whether copy actually resonates with your specific audience, follows your brand voice, supports your conversion goals, and applies proven persuasion frameworks. The difference is "fix this comma" vs. "this page doesn't establish the problem before presenting the solution."

## Troubleshooting

### "The agent created the file but copy-reviewer still runs Standard Mode"

Check that the file is at exactly `./docs/messaging-brief.md` relative to your project root. The copy-reviewer checks this exact path.

### "I want to change a framework selection"

Run `messaging-brief: update the frameworks section`. The agent will show your current selections and let you add, remove, or replace them.

### "The brief feels incomplete"

That's okay — partial briefs are useful. Run the agent again with a targeted update for the sections you want to fill in. The copy-reviewer works around "Not yet documented" gaps.

### "I have multiple products in one repo"

The brief supports one product per file. If you have multiple products, consider separate `./docs/messaging-brief-{product}.md` files. Note: the copy-reviewer currently only auto-detects `./docs/messaging-brief.md`, so you'd need to specify which brief to use.

### "The agent's framework recommendation doesn't seem right"

The recommendation is based on general patterns (stage + audience type). Override it with whatever frameworks you've actually studied or that your copywriter uses. Your judgment takes priority.
