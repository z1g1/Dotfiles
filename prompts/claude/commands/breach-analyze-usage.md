# /breach-analyze -- Usage Guide

## What This Command Does

`/breach-analyze` conducts structured research on a specific SaaS security
breach using 6 pre-defined questions (root cause, threat actor attribution,
mitigations, impact, industry takeaways, security program factors). It reads
a breach stub file, researches autonomously with primary source verification,
produces a cited research report, and updates the breach file with findings.

## Position in the Workflow

```
/breach-analyze ─── standalone ──→ ./docs/research/RESEARCH-NNN-slug.md
 (reads breach stub)               ./breaches/YYYY-MM Vendor.md (updated)

/research ─── standalone ──→ (general-purpose research)
/vendor-profile ─── standalone ──→ (vendor security profiling)
```

- **Standalone command** -- not part of the 1-6 numbered pipeline
- **Domain-specific** -- embeds the `/research` anti-hallucination protocol
  but with pre-configured breach questions (no scoping interview for questions)
- **Produces two artifacts** -- research report + updated breach brief

## When to Use

- **New breach analysis** -- You have a breach stub file with `#to_research`
  tag and an abstract, ready for investigation
- **Creating a breach from scratch** -- Point it at a non-existent file path
  and it will create a stub then research it
- **Re-researching a breach** -- Point it at an already-researched breach to
  update findings with newer sources or deeper analysis
- **Building a breach catalog** -- Systematic analysis of multiple breaches
  for pattern recognition across incidents

## Example Invocations

**Analyze an existing breach stub:**
```
/breach-analyze breaches/2022-12 Circle CI.md
```

**Analyze a breach that hasn't been stubbed yet:**
```
/breach-analyze breaches/2024-06 Snowflake Campaign.md
```
(The command will ask for an abstract and create the stub.)

**Re-research with deeper analysis:**
```
/breach-analyze breaches/2023-06 Microsoft-Storm-0558 Breach.md
```
(If already researched, the command will ask whether to re-research.)

## What to Expect

### Phase 1: File Detection (~1 exchange)

The command reads the target file and determines its state:
- **Needs research** -- shows the abstract, confirms the breach
- **Already researched** -- asks whether to re-research or skip
- **Doesn't exist** -- asks for abstract, date, and vendor to create a stub

### Phase 2: Depth Selection (~1 exchange)

Choose research depth:

| Level | Sources/question | Best for |
|-------|-----------------|----------|
| Scan | 3-5 | Quick orientation, filling in a known breach |
| Standard | 5-10 | Most breach analyses, building the catalog |
| Deep dive | 10+ | Critical incidents, conflicting narratives, attribution disputes |

### Phase 3-5: Autonomous Research

The command works without interruption:
- Generates search queries for all 6 questions
- WebSearches and WebFetches sources
- Logs every source in a registry (success/partial/failed)
- For deep dives, launches parallel sub-agents splitting questions into groups
- Synthesizes findings and assesses confidence per question

### Phase 6: Outputs

- Writes `./docs/research/RESEARCH-{NNN}-{slug}.md` with full cited report
- Updates the breach file: removes `#to_research`, adds wiki-linked findings
- Commits both files to git
- Presents summary with per-question confidence and gap count

## The 6 Breach Questions

These are pre-configured and not asked of the user:

1. **Root Cause** -- Initial access vector, attack chain, failed controls
2. **Threat Actor Attribution** -- Who, TTPs, affiliations, prior campaigns
   (may be "unattributed" or "disputed")
3. **Mitigations** -- Immediate and long-term response with timelines
4. **Impact** -- Blast radius, downstream effects, financial impact
5. **SaaS Industry Takeaways** -- Patterns, systemic issues, industry lessons
6. **SaaS Security Program Factors** -- Actionable controls and practices

## Design Decisions

### Why pre-configured questions (no scoping interview)?

Breach analysis has a well-defined structure. The same 6 questions apply to
every breach. Asking the user to define questions each time adds friction
without value. The only user input needed is file selection and depth.

### Why separate from /research?

`/research` is general-purpose with a full scoping interview (topic, questions,
context, depth, handoff). `/breach-analyze` has pre-defined questions and a
domain-specific output format (breach file + research report with wiki links).
Embedding the protocol directly avoids inter-command coordination complexity.

### Why add Threat Actor Attribution as a separate question?

Attribution was previously embedded in Root Cause. Making it explicit ensures:
- Every breach has a clear attribution statement (even if "unattributed")
- The research actively investigates TTPs and group affiliations
- Disputed attributions are surfaced rather than buried in technical details

### Why two output files?

The breach file (`breaches/`) is a concise brief for quick reference. The
research report (`docs/research/`) is the full cited analysis. Wiki links
connect them. This mirrors how the existing breach catalog already works --
the command just automates what was previously done manually.

### Why deep dive parallelization?

Deep dives generate 10+ sources per question across 6 questions -- that's
60+ fetches. Splitting into parallel sub-agents (Q1+Q2 / Q3+Q4 / Q5+Q6)
reduces wall-clock time significantly while maintaining the anti-hallucination
protocol in each sub-agent.

## Output Files

### Research Report

`./docs/research/RESEARCH-{NNN}-{slug}.md` -- Full cited research report:
- Executive summary (cited)
- Findings for all 6 questions with confidence levels
- Analysis & implications (labeled as interpretation)
- Gaps table with attempted searches
- Source appendix with access status

### Updated Breach File

`./breaches/YYYY-MM Vendor.md` -- Concise breach brief:
- Original abstract preserved
- `## Research Agent Information` with wiki link to report
- 6 findings sections (Root Cause, Threat Actor Attribution, Mitigations,
  Impact, SaaS Industry Takeaways, SaaS Security Program Factors)
- Each section is a concise summary; full details in the research report

## Troubleshooting

### Attribution is "unattributed" for most breaches

This is expected. Many breaches are never publicly attributed. The command
is designed to handle this -- "Unattributed" with partial information (tools
used, suspected origin) is a valid finding. Check the Gaps section for what
attribution-related searches were attempted.

### Breach file has different section structure than expected

Existing breach files may not have a Threat Actor Attribution section (it was
added as a new question). The command will add it. If re-researching, it
replaces everything from `## Research Agent Information` onward.

### Many WebFetch failures

Some incident response reports are behind vendor login walls. The command logs
these as `failed` in the source appendix. If most sources for a question fail:
- The gaps section will note the pattern
- Consider manually visiting paywalled sources and sharing key data points
- Vendor incident reports are often the most detailed but least accessible

### Research feels too shallow

- Re-run with **Deep dive** depth
- Provide additional context in the abstract to help focus searches
- Some older breaches have limited public documentation

### File path issues

The command expects a path relative to the project root (e.g.,
`breaches/2022-12 Circle CI.md`). If the file doesn't exist, it will offer
to create a stub.

## Related Files

- [[breach-analyze]] -- Command definition
- [[research]] -- General-purpose research command (shares anti-hallucination protocol)
- [[vendor-profile]] -- Vendor security profiling command (sibling command)
- [[USAGE]] -- Pipeline overview
