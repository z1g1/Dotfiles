# /4-feature-planner — Usage Guide

## What This Command Does

`/4-feature-planner` autonomously decomposes Epics into user-facing Features.
It reads Epic documentation, checks tech-opinions, analyzes the codebase when
needed, and produces Feature files with acceptance criteria, technical notes,
and dependency mappings — all with minimal user interaction.

## Position in the Chain

```
/1-brainstorm → /2-requirements → /3-epic-planner → **[/4-feature-planner]** → /5-task-planner
```

- **Consumes:** `./claude-temp/handoff-epic.json` (from `/3-epic-planner`)
- **Produces:** `./docs/features/epic-XXX/FEATURE-XXX-[slug].md`, per-Epic and
  master README indexes
- **Hands off:** `./claude-temp/handoff-feature.json` → auto-invokes `/5-task-planner`

## When to Use

- Automatically invoked by `/3-epic-planner` (most common)
- Manually after creating or updating Epic files in `./docs/epics/`
- To re-decompose specific Epics: `/4-feature-planner only EPIC-002`

## Example Invocations

**Standard (auto-invoked by /3-epic-planner):**
No action needed — the chain flows automatically.

**Manual invocation:**
```
/4-feature-planner
```

**Scoped to specific Epics:**
```
/4-feature-planner only EPIC-002 EPIC-003
```

**After adding new Epics manually:**
```
/4-feature-planner
```
It will detect which Epics already have Features and only process new ones.

## What to Expect

1. **Silent setup** — directories created, existing state scanned
2. **Handoff check** — if Epic handoff exists, reports processing plan
3. **Per-Epic autonomous processing:**
   - Read Epic file fully
   - Check tech-opinions (project → global)
   - Analyze codebase if needed (3-5 targeted searches max)
   - Create Features with complete acceptance criteria
   - Report: "✅ Created N Features for EPIC-XXX"
4. **After all Epics processed:** files committed, handoff written
5. **Auto-invoke** — `/5-task-planner` starts immediately

## Outputs

| Output | Location | Durable? |
|--------|----------|----------|
| Feature files | `./docs/features/epic-XXX/FEATURE-XXX-[slug].md` | Yes (git) |
| Per-Epic index | `./docs/features/epic-XXX/README.md` | Yes (git) |
| Master index | `./docs/features/README.md` | Yes (git) |
| Handoff | `./claude-temp/handoff-feature.json` | No (ephemeral) |

## Design Decisions

### Why "Feature" instead of "Story"?

The original agent was called `story-planner` and produced `STORY-XXX` files.
We renamed to "Feature" throughout because:
- "Feature" is more intuitive for non-Scrum teams
- Aligns with how most tools and teams think about deliverables
- "Story" has specific Agile ceremony connotations that may not apply
- The underlying concept is the same: a user-facing unit of value

### Why autonomous instead of interview-driven?

Unlike `/3-epic-planner` which conducts an interview, Feature decomposition
works best autonomously because:
- Epic documentation already contains the information needed
- Tech-opinions files provide technology preferences
- Features are a mechanical decomposition of Epic acceptance criteria
- Interrupting for every Feature would make large projects tedious
- The user can refine Features after they're created

### Why per-Epic subdirectories?

Features are organized under `./docs/features/epic-XXX/` because:
- Clear provenance — you always know which Epic a Feature belongs to
- Manageable file counts — Features don't all pile into one directory
- Natural grouping for the README indexes
- Mirrors the task structure downstream (`./docs/tasks/feature-XXX/`)

### Why process ALL Epics?

The command processes every Epic that needs Features in a single run. This
avoids the user needing to invoke it once per Epic. Use `$ARGUMENTS` to scope
to specific Epics if you only want a subset processed.

### Tech-opinions two-tier lookup

The command checks `./tech-opinions.md` (project-specific) before
`~/.claude/tech-opinions.md` (global). This allows project-specific overrides
while maintaining defaults for technology preferences that apply across
projects.

## Troubleshooting

### "I don't see any Epics to decompose"

The command looked for `./claude-temp/handoff-epic.json` and didn't find it,
AND no Epic files exist in `./docs/epics/`. Either:
- `/3-epic-planner` wasn't run
- Epic files are in a different location (e.g., old `./epics/` path)

**Fix:** Run `/3-epic-planner` first, or place Epic files in `./docs/epics/`.

### Features seem too technical

Features should deliver user-facing value. If you see Features like "Migrate
database schema" or "Set up CI pipeline", those should be tasks within a
Feature, not standalone Features. The command should be decomposing based on
what users experience, not technical steps.

### Too many Features per Epic

A typical Epic should have 3-10 Features. If you're seeing 15+, the Features
may be too granular (task-level decomposition happening too early). The command
should combine related items.

### Missing tech-opinions file

If neither `./tech-opinions.md` nor `~/.claude/tech-opinions.md` exists, the
command will infer technology preferences from the codebase or create Features
without specifying technology. This works fine for Feature-level planning; the
specific tooling decisions happen at the task level.

### Re-running for updated Epics

If Epics have been revised after Feature planning:
1. Delete the relevant `./docs/features/epic-XXX/` directory
2. Run `/4-feature-planner only EPIC-XXX`
3. It will regenerate Features for that Epic
4. Re-run `/5-task-planner` to regenerate tasks

### Feature status values

- **Draft**: Feature defined but may need refinement
- **Ready**: Feature is complete and ready for task decomposition
- **In Progress**: Tasks are being created or implemented
- **Done**: Feature fully implemented and tested

The `/5-task-planner` only processes Features with `Status: Ready`.

## Related Files

- [[4-feature-planner]] — The command definition
- [[3-epic-planner]] — Previous command in the chain
- [[3-epic-planner-usage]] — Usage guide for Epic planning
- [[5-task-planner]] — Next command in the chain
- [[5-task-planner-usage]] — Usage guide for Task planning
