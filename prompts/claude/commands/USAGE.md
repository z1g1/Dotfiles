# Planning Pipeline — Complete Usage Guide

A 5-command slash command chain that transforms business ideas into
implementation-ready TDD tasks.

## The Chain at a Glance

```
/1-brainstorm  →  /2-requirements  →  /3-epic-planner  →  /4-feature-planner  →  /5-task-planner
 (interactive)     (interactive)        (interactive)        (autonomous)           (autonomous)
```

Each command auto-invokes the next. Start with `/1-brainstorm` and the full
pipeline runs through to task planning.

## Commands

| # | Command | Mode | Duration | What It Does |
|---|---------|------|----------|-------------|
| 1 | `/1-brainstorm` | Interactive | ~20 min | Adversarial business problem exploration with 5 advisory lenses |
| 2 | `/2-requirements` | Interactive | ~15 min | Business requirements elicitation, MoSCoW prioritization |
| 3 | `/3-epic-planner` | Interactive | ~15 min | Codebase security audit + Epic definition interview |
| 4 | `/4-feature-planner` | Autonomous | ~5 min | Decomposes Epics into user-facing Features |
| 5 | `/5-task-planner` | Autonomous | ~5 min | Creates atomic TDD Red-Green-Refactor tasks |

## Quick Start

### Full Pipeline

```
/1-brainstorm Build a customer portal for my SaaS product
```

That's it. The chain flows automatically:
1. Brainstorm validates the business problem
2. Requirements defines what must be built
3. Epic planner analyzes codebase and creates Epics
4. Feature planner decomposes into user-facing Features
5. Task planner creates TDD tasks

### Starting Mid-Chain

You can enter the chain at any point if you provide sufficient context:

```
# Skip brainstorm, start with requirements
/2-requirements We need a user authentication system with SSO support

# Skip to epic planning with existing requirements
/3-epic-planner

# Process specific Epics only
/4-feature-planner only EPIC-002 EPIC-003

# Process specific Features only
/5-task-planner only FEATURE-003 FEATURE-004
```

## Data Flow

### Durable Outputs (committed to git)

```
./docs/
├── brainstorm/                  # From /1-brainstorm + /2-requirements
│   ├── BRAINSTORM-001.md
│   └── REQUIREMENTS-001.md
├── epics/                       # From /3-epic-planner
│   ├── EPIC-001-[slug].md
│   ├── EPIC-002-[slug].md
│   └── README.md
├── features/                    # From /4-feature-planner
│   ├── epic-001/
│   │   ├── FEATURE-001-[slug].md
│   │   ├── FEATURE-002-[slug].md
│   │   └── README.md
│   ├── epic-002/
│   │   └── ...
│   └── README.md
└── tasks/                       # From /5-task-planner
    ├── feature-001/
    │   ├── TASK-001-[slug].md
    │   ├── TASK-002-[slug].md
    │   └── README.md
    ├── feature-002/
    │   └── ...
    └── README.md
```

### Ephemeral Handoffs (gitignored, auto-deleted)

```
./claude-temp/                   # NOT committed to git
├── handoff-brainstorm.json      # /1 → /2 (deleted by /2)
├── handoff-requirements.json    # /2 → /3 (deleted by /3)
├── handoff-epic.json            # /3 → /4 (deleted by /4)
├── handoff-feature.json         # /4 → /5 (deleted by /5)
└── handoff-task.json            # /5 → future implementation agent
```

Each command reads its upstream handoff, uses it, and deletes it after
processing. The only handoff that persists is `handoff-task.json` (terminal).

## Technology Opinions

Commands 3-5 check for technology preference files before making decisions:

1. **Project-specific**: `./tech-opinions.md` (checked first)
2. **Global default**: `~/.claude/tech-opinions.md` (fallback)

Set up global preferences with the `technology-opinions` agent:
```
technology-opinions: Set up my preferences
```

Project-specific overrides go in `./tech-opinions.md` in the project root.

## Command Details

### /1-brainstorm

**Role:** Panel of 5 senior business advisors conducting adversarial examination.

**What happens:**
- Challenges every assumption from strategic, customer, market, and business
  model perspectives
- Forces clarity on problem statement, users, value proposition, scope, and risks
- Captures firm decisions as **DECISION** markers

**Outputs:**
- `./docs/brainstorm/BRAINSTORM-{NNN}.md` — Business-readable brief
- `./claude-temp/handoff-brainstorm.json` — Machine-readable handoff (<500 tokens)

**Auto-invokes:** `/2-requirements`

### /2-requirements

**Role:** Senior business analyst translating validated problems into precise
requirements.

**What happens:**
- Systematically extracts functional, user, business, data, and non-functional
  requirements
- Prioritizes using MoSCoW (Must/Should/Could/Won't)
- Defines acceptance criteria (Given/When/Then)
- Surfaces dependencies and conflicts

**Outputs:**
- `./docs/brainstorm/REQUIREMENTS-{NNN}.md` — Business-readable requirements
- `./claude-temp/handoff-requirements.json` — Machine-readable handoff (<800 tokens)

**Auto-invokes:** Currently pauses. User invokes `/3-epic-planner` manually.

### /3-epic-planner

**Role:** Expert Agile specialist conducting Epic-level planning.

**What happens:**
- Phase 1: Business context interview (3-5 min)
- Phase 2: Codebase security audit + architecture review (5-7 min)
- Phase 3: Iterative Epic definition with user (5-7 min)
- Security issues automatically become EPIC-001 (non-negotiable)

**Outputs:**
- `./docs/epics/EPIC-XXX-[slug].md` — One file per Epic
- `./docs/epics/README.md` — Epic index with sequencing
- `./claude-temp/handoff-epic.json` — Machine-readable handoff (<800 tokens)

**Auto-invokes:** `/4-feature-planner`

### /4-feature-planner

**Role:** Autonomous Feature decomposition engine.

**What happens:**
- Reads all Epics, processes in priority order
- Checks tech-opinions for technology preferences
- Decomposes each Epic into user-facing Features (3-10 per Epic)
- Sizes Features (S/M/L), maps dependencies
- Only asks user when critical ambiguity can't be resolved from context

**Outputs:**
- `./docs/features/epic-XXX/FEATURE-XXX-[slug].md` — One file per Feature
- `./docs/features/epic-XXX/README.md` — Per-Epic Feature index
- `./docs/features/README.md` — Master Feature index
- `./claude-temp/handoff-feature.json` — Machine-readable handoff (<1000 tokens)

**Auto-invokes:** `/5-task-planner`

### /5-task-planner

**Role:** Autonomous TDD task decomposition engine.

**What happens:**
- Reads all "Ready" Features, processes in sequence order
- Maps each acceptance criterion to a TDD Red-Green-Refactor cycle
- Creates atomic tasks (2-4 hours each, one test + one implementation)
- Flags setup tasks requiring human action with 🚨
- Creates research/spike tasks for unknowns

**Outputs:**
- `./docs/tasks/feature-XXX/TASK-XXX-[slug].md` — One file per Task
- `./docs/tasks/feature-XXX/README.md` — Per-Feature Task index with dependency graph
- `./docs/tasks/README.md` — Master Task index with critical path
- `./claude-temp/handoff-task.json` — Machine-readable handoff (<1200 tokens)

**TERMINAL** — no auto-invoke. Implementation is manual or via future agent.

## Deployment

### Install Commands

```bash
cd /path/to/promps

# Symlink (recommended — auto-updates)
mkdir -p ~/.claude/commands
for cmd in prompts/claude/commands/{1,2,3,4,5}-*.md; do
  ln -sf "$(pwd)/$cmd" ~/.claude/commands/
done

# Or copy (static)
mkdir -p ~/.claude/commands
cp prompts/claude/commands/{1,2,3,4,5}-*.md ~/.claude/commands/
```

### Verify

In Claude Code, type `/1-` and tab-complete. You should see `/1-brainstorm`.

### Update (if using copies)

```bash
cd /path/to/promps && git pull
cp prompts/claude/commands/{1,2,3,4,5}-*.md ~/.claude/commands/
```

## Troubleshooting

### Commands not showing up

- Verify files exist in `~/.claude/commands/`
- Check file permissions: `chmod 644 ~/.claude/commands/*.md`
- Restart Claude Code session

### "I don't see a handoff"

The command expected an upstream handoff file that doesn't exist. Either:
- The upstream command wasn't run
- The handoff was already consumed by a previous run
- **Fix:** Run the upstream command first, or provide context via `$ARGUMENTS`

### Running out of order

Commands 3-5 can run standalone without upstream handoffs — they'll scan for
existing files in `./docs/` or ask for minimum context. But the chain works
best when run in order.

### Re-running a command

Commands are idempotent for new content. They detect existing files and
increment numbering. To regenerate:
1. Delete the relevant `./docs/` subdirectory
2. Re-run the command
3. Continue the chain from that point

### Feature files still say "Story"

If you see `STORY-XXX` IDs or `./stories/` paths, those are from the old
agent-based system. The command-based pipeline uses `FEATURE-XXX` and
`./docs/features/`. Old agent outputs can be migrated manually or regenerated.

## Design: Why Commands Instead of Agents?

The planning pipeline was originally built as three Claude Code agents
(`epic-planner`, `story-planner`, `task-planner`). They were converted to
slash commands because:

1. **User visibility** — Commands run in the main conversation. Users see the
   full interview, can steer the conversation, and understand what's happening.
2. **Consistent invocation** — `/1-brainstorm` through `/5-task-planner` is a
   clear, numbered sequence. No need to know agent names or invocation syntax.
3. **Unified chain** — All 5 steps use the same handoff pattern (JSON in
   `./claude-temp/`), same output pattern (`./docs/`), same commit pattern.
4. **Feature rename** — "Story" was renamed to "Feature" throughout, which is
   more intuitive for teams not using Scrum terminology.

The `technology-opinions` and `copy-reviewer` agents remain as agents because
they're standalone tools, not part of a sequential pipeline.

## Related Files

- [[1-brainstorm]] — Command 1
- [[2-retuirements]] — Command 2
- [[3-epic-planner]] / [[3-epic-planner-usage]] — Command 3
- [[4-feature-planner]] / [[4-feature-planner-usage]] — Command 4
- [[5-task-planner]] / [[5-task-planner-usage]] — Command 5
