# z1g1/prompts

Shared Claude Code agents, commands, and settings for use across projects via git submodule.

## What's Inside

### Planning & Implementation Pipeline (Slash Commands)

A 6-command chain that transforms project ideas into implementation-ready tasks and then autonomously implements them using BTDD:

```
/1-brainstorm → /2-requirements → /3-epic-planner → /4-feature-planner → /5-task-planner
                                                                               ↓
                                                                    [user review gate]
                                                                               ↓
                                                                      /6-implement
```

| Command | Mode | What It Does |
|---------|------|-------------|
| `/1-brainstorm` | Interactive | Adversarial business problem exploration |
| `/2-requirements` | Interactive | Business requirements elicitation and prioritization |
| `/3-epic-planner` | Interactive | Codebase analysis + Epic definition interview |
| `/4-feature-planner` | Autonomous | Decomposes Epics into Features + behavioral specs |
| `/5-task-planner` | Autonomous | Creates BTDD tasks driven by behavioral scenarios |
| `/6-implement` | Autonomous | PRIV + BTDD implementation of all tasks |

**Auto-chaining**: Run `/1-brainstorm` and the chain flows automatically through task planning. After reviewing the task plan and behavioral specs, manually invoke `/6-implement` to begin implementation.

All durable outputs land in `./docs/` (epics, features, behaviors, tasks, implementation journal). Ephemeral handoffs pass through `./claude-temp/`.

### Standalone Agents

- **technology-opinions** — Captures and queries technology preferences (one-time setup)
- **copy-reviewer** — Reviews copy/content for clarity and consistency
- **messaging-brief** — Captures project messaging context for copy review

### Configuration

- **settings.json** — Permission rules for auto-approved commands (git, npm, WebFetch, etc.)

## Adding to a Project

### Option A: Submodule as `.claude/` (Recommended)

From your project root:

```bash
git submodule add https://github.com/z1g1/prompts .claude
git commit -m "feat: add shared Claude Code agents and commands via submodule"
```

Agents and commands are immediately available — Claude Code auto-discovers
everything in `.claude/agents/` and `.claude/commands/`.

### Option B: Submodule as `prompts/` (Web-First)

Use this when your project needs its own `.claude/` directory for project-specific
config, or when targeting Claude Code web sessions that need a copy-based bootstrap.

```bash
git submodule add https://github.com/z1g1/prompts prompts
git commit -m "feat: add prompts submodule for shared Claude agents and commands"
```

Then add bootstrap instructions to your project's `CLAUDE.md` so Claude Code
web sessions can self-configure:

```markdown
## Shared Agents and Commands Setup

This project uses shared Claude Code agents and commands from the
`z1g1/prompts` submodule located in the `prompts/` directory.

Before starting work, initialize the submodule and copy agents and commands
into the project's `.claude/` directory:

\```bash
# Initialize the prompts submodule if not already present
git submodule update --init --recursive

# Copy shared agents and commands to project-level .claude directory
mkdir -p .claude/agents .claude/commands
cp -r prompts/.claude/agents/* .claude/agents/ 2>/dev/null || true
cp -r prompts/.claude/commands/* .claude/commands/ 2>/dev/null || true
\```

Run this setup at the start of each new Claude Code web session. Local terminal
sessions using symlinks do not need this step.
```

### Cloning a project that already has the submodule

```bash
git clone --recurse-submodules https://github.com/z1g1/<your-project>.git
```

Or if already cloned without `--recurse-submodules`:

```bash
git submodule update --init --recursive
```

### Start using it

```
/1-brainstorm Build a customer portal for my SaaS product
# Flows: brainstorm → requirements → epics → features → tasks
# Then review and run: /6-implement
```

See [commands/USAGE.md](./prompts/claude/commands/USAGE.md) for the complete pipeline guide.

## Updating Agents and Commands

```bash
# If submodule is at .claude/:
cd .claude && git pull origin main && cd ..
git add .claude
git commit -m "chore: update shared Claude agents to latest"

# If submodule is at prompts/:
cd prompts && git pull origin main && cd ..
git add prompts
git commit -m "chore: update prompts submodule to latest"
```

## Security Considerations

- Review all agent and command changes before updating the submodule reference.
  The pinned commit hash in the parent repo acts as an audit trail.
- Agents have tool access declarations in their YAML frontmatter — verify these
  match your project's security requirements before enabling.
- Submodule pinning ensures consuming projects don't automatically pick up
  untested changes. You control when to update.

See [DEPLOYMENT.md](./prompts/claude/DEPLOYMENT.md) for all deployment options
including global symlinks, per-project copies, and troubleshooting.

## Repository Structure

```
.claude/                        # Runtime definitions (submodule target)
├── agents/                    # Agent definitions
│   ├── technology-opinions.md
│   ├── copy-reviewer.md
│   └── messaging-brief.md
├── commands/                  # Command definitions
│   ├── 1-brainstorm.md
│   ├── 2-requirements.md
│   ├── 3-epic-planner.md
│   ├── 4-feature-planner.md
│   ├── 5-task-planner.md
│   └── 6-implement.md
├── settings.json
└── README.md

prompts/                        # Obsidian vault (documentation only)
├── claude/
│   ├── commands/              # Command usage docs
│   │   ├── USAGE.md
│   │   ├── 3-epic-planner-usage.md
│   │   ├── 4-feature-planner-usage.md
│   │   ├── 5-task-planner-usage.md
│   │   └── 6-implement-usage.md
│   ├── agents/                # Agent usage docs
│   │   ├── technology-opinions-usage.md
│   │   ├── copy-reviewer-usage.md
│   │   └── messaging-brief-usage.md
│   └── DEPLOYMENT.md          # Deployment guide
└── fourscore/                 # Business prompts
```

## Contributing

1. Work on the `dev` branch
2. Create/edit prompts in appropriate subdirectory
3. Always create two files:
   - `{name}.md` — The prompt/agent/command definition
   - `{name}-usage.md` or `{name}-explainer.md` — Documentation
4. Commit frequently with descriptive messages
5. See [CLAUDE.md](./CLAUDE.md) for detailed guidelines

## License

Personal use. Not licensed for distribution.
