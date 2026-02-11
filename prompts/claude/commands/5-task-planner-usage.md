# /5-task-planner — Usage Guide

## What This Command Does

`/5-task-planner` autonomously decomposes Features into atomic, TDD-driven
tasks following the Red-Green-Refactor cycle. Each task it creates contains
everything an implementation agent (or developer) needs to work independently:
test specifications, implementation steps, file paths, and clear definitions
of done.

This is the **terminal command** in the planning chain — it does not auto-invoke
any further commands. A future implementation-agent will pick up from here.

## Position in the Chain

```
/1-brainstorm → /2-requirements → /3-epic-planner → /4-feature-planner → **[/5-task-planner]**
```

- **Consumes:** `./claude-temp/handoff-feature.json` (from `/4-feature-planner`)
- **Produces:** `./docs/tasks/feature-XXX/TASK-XXX-[slug].md`, per-Feature and
  master README indexes
- **Hands off:** `./claude-temp/handoff-task.json` (for future implementation-agent)
- **TERMINAL** — no auto-invoke after this command

## When to Use

- Automatically invoked by `/4-feature-planner` (most common)
- Manually after creating or updating Feature files with `Status: Ready`
- To re-decompose specific Features: `/5-task-planner only FEATURE-003 FEATURE-004`

## Example Invocations

**Standard (auto-invoked by /4-feature-planner):**
No action needed — the chain flows automatically.

**Manual invocation:**
```
/5-task-planner
```

**Scoped to specific Features:**
```
/5-task-planner only FEATURE-003 FEATURE-004
```

**After updating a Feature:**
```
/5-task-planner only FEATURE-002
```

## What to Expect

1. **Silent setup** — directories created, existing state scanned
2. **Handoff check** — if Feature handoff exists, reports processing plan
3. **Tech-opinions check** — reads project and global preferences
4. **Per-Feature autonomous processing:**
   - Read Feature file and parent Epic
   - Map acceptance criteria to TDD cycles
   - Create atomic tasks (test → implement → refactor)
   - Flag setup tasks requiring human action with 🚨
   - Report: "✅ Created N tasks for FEATURE-XXX"
5. **After all Features processed:** files committed, handoff written
6. **Terminal report** — summary with recommended starting point

## Outputs

| Output | Location | Durable? |
|--------|----------|----------|
| Task files | `./docs/tasks/feature-XXX/TASK-XXX-[slug].md` | Yes (git) |
| Per-Feature index | `./docs/tasks/feature-XXX/README.md` | Yes (git) |
| Master index | `./docs/tasks/README.md` | Yes (git) |
| Handoff | `./claude-temp/handoff-task.json` | No (ephemeral) |

## Design Decisions

### Why TDD is non-negotiable

Every task follows Red-Green-Refactor because:
- Tests document expected behavior before implementation
- Implementation agents have unambiguous success criteria
- Each task is self-verifying — run the test to check if you're done
- Refactoring step ensures quality doesn't degrade over time
- One test + one implementation ≈ one clean commit

### Why fully autonomous (zero user interaction)?

Task decomposition is mechanical — it takes Feature acceptance criteria and
maps them to TDD cycles. There's nothing to interview about:
- Feature files already define what needs to be built
- Tech-opinions files specify tooling preferences
- Codebase analysis reveals patterns to follow
- Unknowns get research tasks, not user questions

### Why odd = test, even = implementation?

The numbering convention (TASK-001 = test, TASK-002 = implementation) makes
the TDD cycle visible in the file listing. You can immediately see which
tasks are tests and which are implementations by the number.

### Why `./docs/tasks/feature-XXX/` structure?

Tasks are organized by Feature (not by Epic) because:
- Tasks directly implement Features, not Epics
- Each Feature's task set is independent and self-contained
- Keeps dependency graphs manageable (feature-scoped, not project-scoped)
- Mirrors the Feature structure upstream

### Why terminal (no auto-invoke)?

The planning chain ends here because:
- Implementation requires a different mode of operation (writing code vs. planning)
- The user should review the task plan before implementation begins
- Implementation-agent is future work — not yet built
- The handoff JSON is ready for when that agent exists

### Setup tasks flagged with 🚨

Tasks that require human action (creating external service accounts, setting
up credentials, configuring dashboards) cannot be done by an automated agent.
These are flagged prominently so they're completed before implementation
begins.

## Troubleshooting

### "I don't see any Ready Features"

The command only processes Features with `Status: Ready`. Either:
- `/4-feature-planner` wasn't run
- Features are still in `Draft` status
- Feature files are in a different location

**Fix:** Run `/4-feature-planner` first, or update Feature status to `Ready`.

### Tasks seem too large

Tasks should be 2-4 hours each. If a task feels larger:
- It probably needs to be split into multiple TDD cycles
- Check if multiple acceptance criteria got combined into one task
- Each acceptance criterion should be its own Red-Green-Refactor cycle

### Tasks seem too small

If tasks are trivially small (30 minutes each), adjacent tasks could
potentially be combined. But err on the side of atomic — it's easier to
combine small tasks during implementation than to split large ones.

### Missing test specifications

Every task should have a concrete test specification — file path, test code,
expected failure message. If these are vague, the tech-opinions file may be
missing testing tool preferences. Create `./tech-opinions.md` with your
preferred test framework and re-run.

### Re-running for updated Features

If Features have been revised:
1. Delete the relevant `./docs/tasks/feature-XXX/` directory
2. Run `/5-task-planner only FEATURE-XXX`
3. Tasks will be regenerated from the updated Feature

### What happens to the handoff-task.json?

The handoff remains in `./claude-temp/` until a future implementation-agent
consumes it. Since no agent auto-invokes after this command, the file will
persist until manually deleted or consumed by a future tool.

## The TDD Cycle Explained

For each acceptance criterion in a Feature, tasks follow this pattern:

```
TASK-001 (Red):    Write failing test for criterion
TASK-002 (Green):  Implement minimum code to pass test
TASK-003 (Refactor): Clean up + add edge case tests
                        ↓
TASK-004 (Red):    Write failing test for next criterion
TASK-005 (Green):  Implement minimum code to pass test
TASK-006 (Refactor): Clean up + add edge case tests
```

Each triplet maps to roughly:
- 1 test commit: `test: add failing test for [feature]`
- 1 implementation commit: `feat: implement [feature]`
- 1 refactor commit: `refactor: improve [feature] and add edge cases`

## Related Files

- [[5-task-planner]] — The command definition
- [[4-feature-planner]] — Previous command in the chain
- [[4-feature-planner-usage]] — Usage guide for Feature planning
- [[3-epic-planner]] — Start of the planning pipeline
- [[3-epic-planner-usage]] — Usage guide for Epic planning
