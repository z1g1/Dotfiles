# /research — Usage Guide

## What This Command Does

`/research` conducts structured internet research with mandatory primary source
verification. It interviews you to scope the research, then autonomously
searches, fetches, and synthesizes findings into a cited report with explicit
gap reporting.

## Position in the Workflow

```
/research ─── (optional) ──→ /1-brainstorm → /2-requirements → ...
 (standalone)                   (pipeline)
```

- **Standalone command** — not part of the 1-6 numbered pipeline
- **Optional feeder** — can produce a handoff for `/1-brainstorm` if requested
- **No upstream dependency** — works from scratch with any topic

## When to Use

- **Technical research** — comparing frameworks, understanding APIs, evaluating
  tools before committing to a stack
- **Market research** — sizing markets, identifying competitors, understanding
  pricing models
- **Business research** — regulatory requirements, industry trends, best
  practices
- **Pre-brainstorm** — gathering evidence before a `/1-brainstorm` session so
  decisions are grounded in data rather than assumptions
- **Due diligence** — verifying claims, checking current state of a technology
  or market

## Example Invocations

**With a topic:**
```
/research Compare Supabase vs Firebase for a B2B SaaS MVP
```

**Open-ended:**
```
/research
```
(The command will interview you to define the topic and questions.)

**Market research:**
```
/research Market size and competitors for AI-powered contract review tools
```

**Technical deep dive:**
```
/research WebSocket vs SSE vs long polling for real-time features in 2024
```

## What to Expect

### Phase 1: Scoping Interview (~2-3 exchanges)

The command asks for:
- **Topic** — refined from `$ARGUMENTS` if provided
- **Key questions** — 3-5 specific questions to investigate
- **Existing context** — what you already know
- **Depth level** — Scan (quick), Standard (thorough), Deep dive (exhaustive)
- **Brainstorm handoff** — whether to create a `/1-brainstorm` handoff file

You confirm the scope, then the command runs autonomously.

### Phase 2-4: Autonomous Research

The command works without interruption:
- Generates search queries for each question
- WebSearches and WebFetches sources
- Logs every source in a registry (success/partial/failed)
- Synthesizes findings and assesses confidence per question

### Phase 5-6: Report & Outputs

- Writes `./docs/research/RESEARCH-{NNN}-{slug}.md`
- Commits to git
- Optionally writes `./claude-temp/handoff-research-{NNN}.json`
- Presents a summary with per-question confidence levels and gap count

## Depth Levels

| Level | Sources/question | Best for |
|-------|-----------------|----------|
| Scan | 3-5 | Quick orientation, "is this worth investigating?" |
| Standard | 5-10 | Most research tasks, informed decision-making |
| Deep dive | 10+ | Critical decisions, competitive analysis, due diligence |

## Design Decisions

### Why standalone (not numbered)?

Research doesn't fit the linear 1→2→3→4→5→6 planning pipeline. It can happen
before brainstorming, between any pipeline stages, or completely independently.
Numbering it would imply a fixed position in the chain.

### Why numbered handoff files?

The pipeline commands use a single `handoff-brainstorm.json` that gets
overwritten each run. Research uses `handoff-research-{NNN}.json` because you
might run multiple research sessions before a brainstorm, and each report
should be independently referenceable.

### Why unrestricted WebFetch?

Research by definition needs to fetch arbitrary URLs. The domain-scoped
WebFetch entries in `settings.json` only cover documentation sites. The
unrestricted `WebFetch` permission allows the command to fetch any source it
finds through WebSearch.

### Why mandatory gaps?

The most dangerous research output is one that looks complete but isn't. The
mandatory gaps section forces honest reporting of what couldn't be found,
what's behind paywalls, and what needs further investigation. This is more
useful than false completeness.

### Why confidence levels?

Not all findings are equal. A finding backed by 5 recent corroborating sources
is fundamentally different from one backed by a single 3-year-old blog post.
Confidence levels (High/Medium/Low) make this explicit so you can calibrate
your decisions accordingly.

## Output Files

### Research Report

`./docs/research/RESEARCH-{NNN}-{slug}.md` — The full research report with:
- Executive summary (cited via inline markdown hyperlinks)
- Findings per question with confidence levels
- Analysis & implications (labeled as interpretation)
- Gaps table with attempted searches
- Source appendix with access status
- All acronyms expanded on first use

### Brainstorm Handoff (optional)

`./claude-temp/handoff-research-{NNN}.json` — Minimal JSON (<600 tokens) with:
- Key findings with confidence levels
- Market data (if applicable)
- Gaps and assumptions to test
- Actionable implications

Feed this to `/1-brainstorm` by referencing the research in your arguments.

## Troubleshooting

### Many WebFetch failures

Some sites block automated fetching. The command logs these as `failed` in the
source appendix. If most sources for a question fail:
- The command will attempt alternative searches
- The gaps section will note the pattern
- Consider manually visiting paywalled sources and sharing key data points

### Research feels too shallow

- Re-run with **Deep dive** depth for critical questions
- Provide more specific questions during scoping — broad questions like
  "tell me about AI" produce shallow results; specific questions like
  "what is the current accuracy of GPT-4 on legal contract review benchmarks?"
  produce focused results
- Share existing context so the command doesn't waste time on basics

### Too many gaps

Gaps are a feature, not a bug. If your research topic is genuinely hard to
research online (proprietary data, emerging fields, niche markets), the gaps
section tells you what you still need to find out through other channels
(interviews, paid reports, direct outreach).

### Source count seems low

The command fetches WebSearch results and then WebFetches the actual pages.
Some search results lead to duplicates, irrelevant content, or failed fetches.
The source count reflects actually-fetched-and-useful sources, not raw search
hit counts.

## Related Files

- [[research]] — Command definition
- [[USAGE]] — Pipeline overview (standalone feeder section)
- [[1-brainstorm]] — Downstream command for research handoff
- [[DEPLOYMENT]] — Deployment guide including symlink instructions
