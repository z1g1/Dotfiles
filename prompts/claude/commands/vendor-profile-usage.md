# /vendor-profile -- Usage Guide

## What This Command Does

`/vendor-profile` conducts structured security profiling of a SaaS vendor using
8 pre-defined questions (terminology/RBAC, documentation sources, security
defaults, pricing/tiers, external research, hardening guides, API docs,
logging/audit trails). It reads a vendor stub file, runs a brief scoping
interview (scope and depth), researches autonomously with primary source
verification, produces a cited research report, and updates the vendor file
with structured answers.

## Position in the Workflow

```
/vendor-profile ─── standalone ──→ ./docs/research/RESEARCH-NNN-slug.md
 (reads vendor stub)                ./saas/Vendor.md (updated)

/breach-analyze ─── standalone ──→ (breach analysis)
/research ─── standalone ──→ (general-purpose research)
```

- **Standalone command** -- not part of the 1-6 numbered pipeline
- **Domain-specific** -- embeds the `/research` anti-hallucination protocol
  but with pre-configured vendor security questions
- **Produces two artifacts** -- research report + updated vendor profile

## When to Use

- **New vendor assessment** -- Evaluating a SaaS vendor's security posture
  before adoption or as part of a vendor risk program
- **Building a vendor catalog** -- Systematic profiling of all SaaS vendors
  in your stack for security program development
- **Vendor comparison** -- Profile multiple vendors to compare security models,
  defaults, and tier-locked features
- **Security program planning** -- Understanding a vendor's security model
  before building controls, policies, or monitoring
- **Re-assessment** -- Updating an existing vendor profile with current
  information (pricing changes, new features, etc.)

## Example Invocations

**Profile an existing vendor stub:**
```
/vendor-profile saas/Salesforce.com.md
```

**Profile a new vendor (no existing file):**
```
/vendor-profile saas/Okta.md
```
(The command will ask for a vendor name and create a stub with 8 questions.)

**Re-profile with updated information:**
```
/vendor-profile saas/Salesforce.com.md
```
(If already profiled, the command will ask whether to re-research.)

## What to Expect

### Phase 1: File Detection (~1 exchange)

The command reads the target file and determines its state:
- **Needs research** -- shows the existing questions, confirms the vendor
- **Already researched** -- asks whether to re-research or skip
- **Doesn't exist** -- asks for vendor name, creates a stub with 8 questions

### Phase 2: Scoping Interview (~1-2 exchanges)

The command asks for:
- **Scope** -- Core platform only, Core + add-ons, or Full ecosystem
- **Depth** -- Scan, Standard (default), or Deep dive
- **Additional context** -- Any specific concerns or known issues (optional)

| Level | Sources/question | Best for |
|-------|-----------------|----------|
| Scan | 3-5 | Quick vendor triage, initial assessment |
| Standard | 5-10 | Most vendor profiling, security program planning |
| Deep dive | 10+ | Critical vendor assessment, pre-procurement due diligence |

| Scope | Covers |
|-------|--------|
| Core platform only | Primary product and built-in security |
| Core + major add-ons | Include paid security add-ons and extensions |
| Full ecosystem | Marketplace, integrations, partner products |

### Phase 3-5: Autonomous Research

The command works without interruption:
- Generates search queries for all 8 questions
- WebSearches and WebFetches sources
- Logs every source in a registry (success/partial/failed)
- For deep dives, launches parallel sub-agents splitting questions into groups
- Synthesizes findings and assesses confidence per question

### Phase 6: Outputs

- Writes `./docs/research/RESEARCH-{NNN}-{slug}.md` with full cited report
- Updates the vendor file with structured answers to all 8 questions
- Commits both files to git
- Presents summary with per-question confidence, gaps, and areas for future research

## The 8 Vendor Questions

These are pre-configured and not asked of the user:

1. **Security Terminology and RBAC Model** -- Key terms, access control model,
   organizational hierarchy
2. **Canonical Documentation Sources** -- Where to find docs, public vs.
   paywalled, release cadence
3. **Security Defaults** -- Open vs. closed by default, key assumptions
4. **Pricing and Tier-Locked Security Features** -- Tiers, security features
   per tier, cost implications
5. **Top External Security Research Sources** -- Top 3-5 researchers, vendors,
   and communities
6. **Official Hardening Guides and Security Documentation** -- Guides, CIS
   benchmarks, compliance certs, IR docs
7. **Canonical API Documentation** -- API docs, available APIs, auth methods
8. **Logging and Audit Trails** -- Control plane and data plane logging,
   defaults, retention, costs

## Design Decisions

### Why a scoping interview (unlike /breach-analyze)?

Vendor profiling has meaningful scope variation. Salesforce core platform is
very different from "Salesforce + Marketing Cloud + Commerce Cloud." The scope
question prevents wasted research on products the user doesn't care about.
Breach analysis doesn't have this ambiguity -- a breach is a specific event.

### Why 8 questions (not 7)?

Q8 (Logging and Audit Trails) was added after the initial Salesforce research
revealed that logging is often the most operationally important and least
documented aspect of a SaaS vendor's security model. It deserves dedicated
investigation rather than being buried in other questions.

### Why separate from /research?

`/research` is general-purpose with a full scoping interview. `/vendor-profile`
has pre-defined questions and a domain-specific output format (vendor file with
structured answers + research report). The vendor file template produces a
useful standalone security reference, not just research findings.

### Why detailed vendor files (unlike concise breach files)?

Breach files are event briefs -- you read them to understand what happened.
Vendor files are operational references -- you consult them when building
controls, writing policies, or troubleshooting. They benefit from detailed
tables, terminology definitions, and structured data.

### Why deep dive parallelization splits Q2+Q6+Q7?

Documentation-related questions (Q2, Q6, Q7) often share sources -- the same
vendor docs portal serves all three. Grouping them lets a single sub-agent
efficiently navigate the vendor's documentation hierarchy without redundant
fetches.

## Output Files

### Research Report

`./docs/research/RESEARCH-{NNN}-{slug}.md` -- Full cited research report:
- Executive summary (cited)
- Findings for all 8 questions with confidence levels
- Analysis & implications (labeled as interpretation)
- Gaps table with attempted searches
- Source appendix with access status

### Updated Vendor File

`./saas/Vendor.md` -- Structured vendor security profile:
- Original `## Open Questions` preserved
- `## Research Agent Information` with wiki link to report
- 8 answer sections with structured data (tables, lists, sub-headers)
- `### Areas Requiring Additional Research` for future work

## Troubleshooting

### Documentation is behind a paywall/login

Many vendors gate detailed security documentation behind customer logins.
The command logs these as `failed` in the source appendix and notes the pattern
in the Gaps section. For critical vendors, consider:
- Manually accessing paywalled docs and sharing key findings
- Checking for cached/archived versions
- Looking for community summaries of paywalled content

### Pricing information feels outdated

Vendor pricing changes frequently. The command flags pricing data with dates.
For current pricing, verify directly on the vendor's pricing page. The
research report's Source Appendix includes the fetch date for all sources.

### Too broad for "Full ecosystem" scope

Large vendors (Salesforce, Microsoft, Google) have enormous ecosystems. "Full
ecosystem" can produce shallow coverage across too many products. Consider:
- Start with "Core platform only" for the initial profile
- Run `/vendor-profile` again for specific add-ons as separate profiles
- Use "Core + major add-ons" as a middle ground

### Security defaults question is thin

Some vendors don't document their defaults clearly. This is itself a finding.
The command will note in the Gaps section what couldn't be determined and
suggest testing approaches (e.g., "create a trial account and audit default
settings").

### File path issues

The command expects a path relative to the project root (e.g.,
`saas/Okta.md`). If the file doesn't exist, it will offer to create a stub
with all 8 standard questions.

## Related Files

- [[vendor-profile]] -- Command definition
- [[research]] -- General-purpose research command (shares anti-hallucination protocol)
- [[breach-analyze]] -- Breach analysis command (sibling command)
- [[USAGE]] -- Pipeline overview
