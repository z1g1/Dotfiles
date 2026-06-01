# /3-epic-planner — Usage Guide

## What This Command Does

`/3-epic-planner` conducts a structured ~15-minute interview with the user,
analyzes the target codebase, and produces comprehensive Epic documentation.
It's the bridge between business requirements (from `/2-requirements`) and
Feature-level planning (from `/4-feature-planner`).

## Position in the Chain

```
/1-brainstorm → /2-requirements → **[/3-epic-planner]** → /4-feature-planner → /5-task-planner
```

- **Consumes:** `./claude-temp/handoff-requirements.json` (from `/2-requirements`)
- **Produces:** `./docs/epics/EPIC-XXX-[slug].md`, `./docs/epics/README.md`
- **Hands off:** `./claude-temp/handoff-epic.json` → auto-invokes `/4-feature-planner`

## When to Use

- After running `/2-requirements` (handoff will be picked up automatically)
- When starting a new project that needs Epic-level planning
- When adding major new capability areas to an existing project
- Standalone with `$ARGUMENTS` if you want to skip brainstorm/requirements

## Example Invocations

**Standard chain (most common):**
Run `/1-brainstorm` and let the chain flow. `/3-epic-planner` will be invoked
by `/2-requirements` automatically... but actually, `/2-requirements` currently
does not auto-invoke `/3-epic-planner`. The user should invoke it manually
after reviewing the requirements document.

```
/3-epic-planner
```

**With arguments (standalone):**
```
/3-epic-planner Build a customer portal for our SaaS product with user management, billing integration, and a support ticket system
```

**Scoped to re-plan:**
```
/3-epic-planner Re-plan the authentication and billing Epics based on updated requirements
```

## What to Expect

1. **Silent setup** — directories created, numbering scanned
2. **Handoff check** — if requirements handoff exists, confirms key elements
3. **Phase 1: Project Context** (3-5 min) — business goals, users, constraints
4. **Phase 2: Codebase Analysis** (5-7 min) — security audit, architecture review
5. **Phase 3: Epic Definition** (5-7 min) — iterative Epic proposal and refinement
6. **Output phase** — files written, committed, handoff created
7. **Auto-invoke** — `/4-feature-planner` starts immediately

## Outputs

| Output | Location | Durable? |
|--------|----------|----------|
| Epic files | `./docs/epics/EPIC-XXX-[slug].md` | Yes (git) |
| Epic index | `./docs/epics/README.md` | Yes (git) |
| Handoff | `./claude-temp/handoff-epic.json` | No (ephemeral) |

## Design Decisions

### Why convert from agent to command?

The original `epic-planner` agent ran as a separate subprocess via the Task
tool. Converting to a slash command means it runs in the main conversation
context, giving the user full visibility into and control over the interview
process. This is especially important for Epic planning since it's
interview-driven — the user needs to see and respond to questions.

### Why `./docs/epics/` instead of `./epics/`?

All durable planning outputs now live under `./docs/` for consistency with
the brainstorm/requirements outputs from commands 1-2. This creates a single,
predictable documentation tree.

### Why JSON handoff instead of Markdown?

The original agent used `.claude-temp/handoff/epic-to-story.md` (a Markdown
file). The command format uses JSON (`handoff-epic.json`) for:
- Predictable parsing by downstream commands
- Token-efficient (no prose, no formatting)
- Consistent with the handoff pattern from commands 1-2

### Why auto-invoke /4-feature-planner?

The planning chain is designed to flow without user intervention at the
handoff points. Epic → Feature decomposition is a natural continuation, and
the Feature planner works autonomously (no interview needed), so there's no
reason to pause.

### Security-first: why EPIC-001 is always security?

If the codebase analysis reveals security vulnerabilities, they automatically
become EPIC-001 with Critical priority. This is non-negotiable because:
- Security issues compound if left unaddressed
- New features built on insecure foundations inherit those vulnerabilities
- It's cheaper to fix security before adding complexity

## Troubleshooting

### "I don't see a requirements handoff"

The command looked for `./claude-temp/handoff-requirements.json` and didn't
find it. This means either:
- `/2-requirements` wasn't run, or
- The handoff was already consumed by a previous `/3-epic-planner` run

**Fix:** Either run `/1-brainstorm` to start the chain, or provide context
via `$ARGUMENTS`.

### Running out of order

You CAN run `/3-epic-planner` without commands 1-2, but you'll need to provide
sufficient context via `$ARGUMENTS`. The command will ask for minimum viable
input (problem statement, users, key requirements) before proceeding.

### Re-running after the chain has continued

If `/4-feature-planner` has already run and you want to re-plan Epics:
1. Run `/3-epic-planner` again
2. It will detect existing Epic files and use the next available number
3. The new handoff will overwrite the old `handoff-epic.json`
4. Re-run `/4-feature-planner` to regenerate Features for the new Epics

### Too many/too few Epics

**Too many small Epics:** The command should combine related work. If you're
seeing 10+ Epics for a small project, push back during the interview and
ask to consolidate.

**Too few large Epics:** Epics that would take more than 2 months should be
split. The command should propose splits during Phase 3.

## Related Files

- [[3-epic-planner]] — The command definition
- [[4-feature-planner]] — Next command in the chain
- [[4-feature-planner-usage]] — Usage guide for Feature planning
