# /6-implement — Usage Guide

## What This Command Does

`/6-implement` autonomously implements the tasks created by `/5-task-planner`,
following the **Plan→Research→Implement→Verify (PRIV)** methodology with
**Behavioral Test-Driven Development (BTDD)**. It reads task specifications,
behavioral scenarios, and codebase patterns to produce working, tested source
code — writing tests first, implementing minimum code to pass, then refactoring.

The behavioral specs (`BEHAVIOR-XXX`) created by `/4-feature-planner` are the
verification contract. Implementation is not done until every scenario reaches
**Passing** status. The `./docs/behaviors/README.md` dashboard is the user's
primary review artifact after autonomous work completes.

## Position in the Chain

```
/1-brainstorm → /2-requirements → /3-epic-planner → /4-feature-planner → /5-task-planner
                                                                               ↓
                                                                    [user review gate]
                                                                               ↓
                                                                    **[/6-implement]**
```

- **Consumes:** `./claude-temp/handoff-task.json` (from `/5-task-planner`)
- **Reads:** `./docs/tasks/`, `./docs/behaviors/`, `./docs/features/`, `./docs/epics/`
- **Produces:** Source code (tests + implementation), updated behavioral spec
  statuses, implementation journal, git commits
- **TERMINAL** — no auto-invoke after this command

## When to Use

- After reviewing `./docs/behaviors/README.md` and `./docs/tasks/README.md`
- After completing any setup tasks flagged with 🚨
- NOT auto-invoked — the `/5` → `/6` boundary is a deliberate review gate

## Example Invocations

**Standard (after /5-task-planner completes):**
```
/6-implement
```

**Scoped to a specific Feature:**
```
/6-implement only FEATURE-001
```

**Scoped to specific Tasks:**
```
/6-implement only TASK-003 TASK-004 TASK-005
```

**After fixing a blocked task:**
```
/6-implement only TASK-007 TASK-008 TASK-009
```

## What to Expect

1. **Silent setup** — directories verified, test runner validated, tech-opinions read
2. **Implementation plan** — reports which Features, task counts, behavior counts
3. **Setup gate** (if applicable) — presents 🚨 tasks, waits for confirmation
4. **Per-Feature autonomous implementation:**
   - Load Feature context (Feature, Epic, all behaviors, all tasks)
   - For each BTDD triplet:
     - **PLAN:** Read task + behavior specs, identify files and patterns
     - **RESEARCH:** Analyze codebase patterns, check docs if needed
     - **IMPLEMENT:** Red (write failing test) → Green (make it pass) → Refactor (clean up)
     - **VERIFY:** Run all Feature tests, check for regressions
   - Report: "✅ FEATURE-XXX: N/M behaviors passing"
5. **After all Features:** full test suite, behavior dashboard update, journal entry
6. **Completion report** — summary with pass/fail counts and blocked task details

## Outputs

| Output | Location | Durable? |
|--------|----------|----------|
| Test files | Project codebase (paths from task specs) | Yes (git) |
| Implementation files | Project codebase (paths from task specs) | Yes (git) |
| Updated behavior specs | `./docs/behaviors/feature-XXX/BEHAVIOR-XXX-[slug].md` | Yes (git) |
| Per-Feature behavior index | `./docs/behaviors/feature-XXX/README.md` | Yes (git) |
| Master behavior dashboard | `./docs/behaviors/README.md` | Yes (git) |
| Implementation journal | `./docs/implementation/IMPL-LOG.md` | Yes (git) |

## Design Decisions

### Why PRIV (Plan→Research→Implement→Verify)?

The four-phase cycle ensures disciplined implementation:
- **Plan** prevents jumping into code without understanding the task
- **Research** ensures codebase patterns are followed, not reinvented
- **Implement** uses BTDD (not ad-hoc coding) to produce testable code
- **Verify** catches regressions before they compound

Without PRIV, autonomous agents tend to write code immediately, skip pattern
matching, and miss regressions until they're deep into the codebase.

### Why BTDD (not just TDD)?

Traditional TDD starts with "write a test." BTDD starts with "read the
behavioral specification." This matters because:
- The behavioral spec was reviewed by the user (it's the acceptance contract)
- The test must exercise the Given/When/Then exactly, not invent new behavior
- Status tracking (Specified→Failing→Passing) gives the user a progress dashboard
- Multiple tasks can verify the same Feature without inventing overlapping tests

### Why a review gate (not auto-invoked by /5)?

Implementation writes source code — a fundamentally higher-risk operation than
producing planning documentation. The pause between `/5` and `/6` exists so:
- The user can review behavioral specs before any code is written
- Setup tasks (🚨) requiring human action can be completed
- The user retains control over when autonomous coding begins
- This mirrors the `/2` → `/3` boundary (review requirements before planning)

### Why one Feature at a time?

Processing all BTDD triplets for one Feature before moving to the next:
- Keeps the Verify phase scoped — you're checking N behaviors, not N×M
- Makes regression detection precise (you know which Feature caused it)
- Produces clean git history (all commits for a Feature are adjacent)
- Allows the user to see incremental progress per Feature

### Why max 3 attempts for Green phase?

If a test won't pass after 3 implementation iterations, the issue is likely
architectural — not a simple code fix. Continuing to iterate would:
- Produce increasingly messy code
- Waste context window on a single task
- Delay progress on other behaviors

Instead, the task is marked Blocked with the failure reason logged. The user
(or a future invocation) can address the root cause.

### Why an implementation journal?

The journal (`./docs/implementation/IMPL-LOG.md`) serves as:
- **Audit trail** — what was done, in what order, with what results
- **Decision log** — patterns chosen, conventions followed
- **Blocked task registry** — why tasks failed, what needs manual attention
- **Regression history** — which behaviors broke and when

This is especially valuable for autonomous work where the user isn't watching
every step.

### Why not produce a downstream handoff?

`/6-implement` is terminal — there's no `/7-*` command. The implementation
journal and behavior dashboard ARE the terminal artifacts. If a future
deployment command is added, it would consume the behavior dashboard
(all-passing = deployable), not a JSON handoff.

### Why atomic commits per BTDD phase?

One commit per Red/Green/Refactor phase means:
- Each commit is independently reviewable
- `git bisect` can pinpoint exactly when a behavior broke
- Commit messages reference the behavioral scenario for traceability
- Reverting a single phase is clean (revert the Green without losing the Red)

## The PRIV + BTDD Lifecycle

For each behavioral scenario, the full lifecycle is:

```
/4-feature-planner creates BEHAVIOR-XXX (Status: Specified)
                              ↓
/5-task-planner creates TASK triplet referencing BEHAVIOR-XXX
                              ↓
/6-implement executes:
                              ↓
PLAN:     Read TASK-XXX + BEHAVIOR-XXX
          Identify files, patterns, integration points
                              ↓
RESEARCH: Read codebase at integration points
          Match test patterns, import conventions
                              ↓
IMPLEMENT (Red):
          Write test from Given/When/Then
          Run test → fails ✓
          BEHAVIOR-XXX → Failing
          Commit: test: add failing test for [slug]
                              ↓
IMPLEMENT (Green):
          Write minimum code to pass
          Run test → passes ✓
          Commit: feat: implement [slug]
                              ↓
IMPLEMENT (Refactor):
          Clean up code, add edge case tests
          Run all tests → still passing ✓
          BEHAVIOR-XXX → Passing
          Commit: refactor: clean up [slug]
                              ↓
VERIFY:   Run ALL Feature tests
          Check no regressions
          Update behavior dashboard
```

## Troubleshooting

### "I don't see any Ready Tasks"

The command looked for `./claude-temp/handoff-task.json` and didn't find it,
AND no Task files exist with `Status: Ready`. Either:
- `/5-task-planner` wasn't run
- Task files are in a different location

**Fix:** Run `/5-task-planner` first, or update Task status to `Ready`.

### Test runner not found / not working

The command validates the test runner during setup. If it fails:
1. Check `./tech-opinions.md` or `~/.claude/tech-opinions.md` for test tool config
2. Ensure the test framework is installed (e.g., `npm install`, `pip install pytest`)
3. Re-run `/6-implement` after fixing

### Task blocked after 3 Green attempts

The implementation couldn't make the test pass. Common causes:
- Test expectations don't match the behavioral spec (spec ambiguity)
- Integration point has changed since task planning
- Missing dependency or infrastructure

**Fix:** Review the blocked task in `./docs/implementation/IMPL-LOG.md`, fix
the root cause manually, then re-run with `/6-implement only TASK-XXX`.

### Regression detected during Verify

A previously-passing behavior broke after implementing a new one. The command
stops the Feature and reports which behavior regressed.

**Fix:** Check the git log for the commit that caused the regression. Fix the
issue, then re-run `/6-implement only FEATURE-XXX` to continue.

### Test passes unexpectedly during Red phase

The behavior is already implemented (perhaps from a previous partial run or
existing code). The command investigates and skips the Green/Refactor phases
for that behavior, marking it as Passing.

### Re-running after partial completion

If `/6-implement` was interrupted or partially completed:
1. Check `./docs/behaviors/README.md` for current status counts
2. Run `/6-implement` — it will detect which behaviors are already Passing
   and only process remaining ones (scan task Status fields)
3. Or scope to specific tasks: `/6-implement only TASK-007 TASK-008 TASK-009`

### Implementation doesn't match behavioral spec

If the code works but doesn't match what the behavioral spec describes:
1. The behavioral spec is authoritative — the code should match it
2. If the spec is wrong, update the `BEHAVIOR-XXX` file first
3. Then adjust the test and implementation to match

## Related Files

- [[6-implement]] — The command definition
- [[5-task-planner]] — Previous command in the chain
- [[5-task-planner-usage]] — Usage guide for Task planning
- [[4-feature-planner]] — Creates behavioral specifications
- [[4-feature-planner-usage]] — Usage guide for Feature + behavior planning
- [[3-epic-planner]] — Start of the planning pipeline
- [[3-epic-planner-usage]] — Usage guide for Epic planning
