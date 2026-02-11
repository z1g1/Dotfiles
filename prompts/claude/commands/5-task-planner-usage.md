# /5-task-planner — Usage Guide

## What This Command Does

`/5-task-planner` autonomously decomposes Features into atomic, BTDD-driven
tasks following the Behavior→Red→Green→Refactor cycle. It reads the behavioral
specifications created by `/4-feature-planner` and maps each scenario to a
TDD triplet (test → implement → refactor). Each task contains everything an
implementation agent needs: the behavioral scenario it verifies, test
specifications, implementation steps, file paths, and clear definitions of done.

The behavioral specs are the driving force — every task traces back to a
`BEHAVIOR-XXX` scenario, ensuring complete coverage of user-observable behavior.

This is the **final planning command** in the chain — it does not auto-invoke
implementation. The user reviews tasks and behavioral specs before invoking
`/6-implement`.

## Position in the Chain

```
/1-brainstorm → /2-requirements → /3-epic-planner → /4-feature-planner → **[/5-task-planner]**
```

- **Consumes:** `./claude-temp/handoff-feature.json` (from `/4-feature-planner`)
- **Reads:** `./docs/behaviors/feature-XXX/BEHAVIOR-XXX-[slug].md` (behavioral specs)
- **Produces:** `./docs/tasks/feature-XXX/TASK-XXX-[slug].md`, per-Feature and
  master README indexes, with each task linked to its behavioral scenario
- **Hands off:** `./claude-temp/handoff-task.json` → user reviews, then invokes `/6-implement`

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
   - Read ALL behavioral specs (`BEHAVIOR-XXX`) for this Feature
   - Map each behavioral scenario to a BTDD triplet (Red→Green→Refactor)
   - Create atomic tasks with explicit `[[BEHAVIOR-XXX]]` references
   - Flag setup tasks requiring human action with 🚨
   - Report: "✅ Created N tasks (M behavioral scenarios) for FEATURE-XXX"
5. **After all Features processed:** files committed, handoff written
6. **Terminal report** — summary with behavior counts and review guidance

## Outputs

| Output | Location | Durable? |
|--------|----------|----------|
| Task files | `./docs/tasks/feature-XXX/TASK-XXX-[slug].md` | Yes (git) |
| Per-Feature index | `./docs/tasks/feature-XXX/README.md` | Yes (git) |
| Master index | `./docs/tasks/README.md` | Yes (git) |
| Behavior status updates | `./docs/behaviors/` (committed alongside tasks) | Yes (git) |
| Handoff | `./claude-temp/handoff-task.json` | No (ephemeral) |

## Design Decisions

### Why BTDD is non-negotiable

Every task follows Behavior→Red→Green→Refactor because:
- Behavioral specs (`BEHAVIOR-XXX`) define what users should experience
- Tests translate Given/When/Then into executable assertions
- Implementation agents have unambiguous success criteria rooted in user behavior
- Each task is self-verifying — run the test to check if you're done
- Refactoring step ensures quality doesn't degrade over time
- The behavioral spec is the starting point, not an afterthought

### Why behavioral specs drive task decomposition

Tasks are NOT decomposed from acceptance criteria alone — they're driven by
the behavioral specifications created in `/4-feature-planner`:
- Each `BEHAVIOR-XXX` scenario becomes one BTDD triplet (3 tasks)
- The Given/When/Then maps directly to Arrange/Act/Assert in tests
- This ensures complete coverage: every user-observable behavior has a test
- The `/6-implement` command uses these same specs as its verification gate

### Why fully autonomous (zero user interaction)?

Task decomposition is mechanical — it takes Feature acceptance criteria and
maps them to TDD cycles. There's nothing to interview about:
- Feature files already define what needs to be built
- Tech-opinions files specify tooling preferences
- Codebase analysis reveals patterns to follow
- Unknowns get research tasks, not user questions

### Why triplet numbering (Red→Green→Refactor)?

Tasks are numbered in triplets per behavioral scenario (TASK-001/002/003 for
BEHAVIOR-001, TASK-004/005/006 for BEHAVIOR-002). This makes the BTDD cycle
visible in the file listing — you can immediately see which behavior each
task verifies and which phase (Red/Green/Refactor) it represents.

### Why `./docs/tasks/feature-XXX/` structure?

Tasks are organized by Feature (not by Epic) because:
- Tasks directly implement Features, not Epics
- Each Feature's task set is independent and self-contained
- Keeps dependency graphs manageable (feature-scoped, not project-scoped)
- Mirrors the Feature structure upstream

### Why no auto-invoke to `/6-implement`?

The planning chain pauses here (similar to the `/2` → `/3` boundary) because:
- Implementation writes source code — higher risk than producing documentation
- The user should review `./docs/behaviors/README.md` before coding begins
- Setup tasks (🚨) may require human action before implementation can start
- The handoff JSON is ready for `/6-implement` when the user is ready

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

### Missing behavioral specs

Every task should reference a `BEHAVIOR-XXX` scenario. If tasks lack behavioral
references, the `/4-feature-planner` may not have produced behavioral specs:
1. Check `./docs/behaviors/` for BEHAVIOR files
2. If missing, re-run `/4-feature-planner` to generate them
3. Then re-run `/5-task-planner` to regenerate tasks with behavior links

### Behavior status mismatch

If `handoff-task.json` shows behaviors as "Specified: 12" but you only see 8
behavior files in `./docs/behaviors/`, some specs may have been deleted or
moved. Re-run `/4-feature-planner` for the affected Epics.

### What happens to the handoff-task.json?

The handoff remains in `./claude-temp/` until `/6-implement` consumes it.
The user should review `./docs/behaviors/README.md` and complete any setup
tasks (🚨) before invoking `/6-implement`.

## The BTDD Cycle Explained

For each behavioral scenario, tasks follow the Behavior→Red→Green→Refactor pattern:

```
BEHAVIOR-001 (Specified by /4-feature-planner)
  ↓ Given/When/Then drives test design
TASK-001 (Red):      Write failing test for BEHAVIOR-001
  ↓ Given→Arrange, When→Act, Then→Assert
TASK-002 (Green):    Implement minimum code to pass BEHAVIOR-001
  ↓ Make scenario pass, nothing more
TASK-003 (Refactor): Clean up + edge case behaviors from BEHAVIOR-001
  ↓ BEHAVIOR-001 status → Passing
                        ↓
BEHAVIOR-002 (Specified by /4-feature-planner)
  ↓
TASK-004 (Red):      Write failing test for BEHAVIOR-002
TASK-005 (Green):    Implement minimum code to pass BEHAVIOR-002
TASK-006 (Refactor): Clean up + edge case behaviors from BEHAVIOR-002
  ↓ BEHAVIOR-002 status → Passing
```

Each triplet maps to three commits:
- `test: add failing test for [behavior-slug]`
- `feat: implement [behavior-slug]`
- `refactor: clean up [behavior-slug] and add edge cases`

The key difference from traditional TDD: the behavioral specification EXISTS
before the first test is written. The test doesn't invent behavior — it
translates an already-specified Given/When/Then into executable code.

## Related Files

- [[5-task-planner]] — The command definition
- [[4-feature-planner]] — Previous command in the chain
- [[4-feature-planner-usage]] — Usage guide for Feature planning
- [[6-implement]] — Next command (implementation)
- [[6-implement-usage]] — Usage guide for implementation
- [[3-epic-planner]] — Start of the planning pipeline
- [[3-epic-planner-usage]] — Usage guide for Epic planning
