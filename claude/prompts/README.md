# z1g1/prompts

Shared Claude Code agents, commands, and settings for use across projects via git submodule.

## What's Inside

### Planning & Implementation Pipeline (Slash Commands)

A 6-command chain that transforms project ideas into implementation-ready tasks and then autonomously implements them using BTDD:

```
                /research (standalone)
                    │
                    ▼ (optional handoff)
/1-brainstorm → /2-requirements → /3-epic-planner → /4-feature-planner → /5-task-planner
                                                                               ↓
                                                                    [user review gate]
                                                                               ↓
                                                                      /6-implement
```

| Command | Mode | What It Does |
|---------|------|-------------|
| `/research` | Interactive + Autonomous | Internet research with primary source citations and gap reporting |
| `/1-brainstorm` | Interactive | Adversarial business problem exploration |
| `/2-requirements` | Interactive | Business requirements elicitation and prioritization |
| `/3-epic-planner` | Interactive | Codebase analysis + Epic definition interview |
| `/4-feature-planner` | Autonomous | Decomposes Epics into Features + behavioral specs |
| `/5-task-planner` | Autonomous | Creates BTDD tasks driven by behavioral scenarios |
| `/6-implement` | Autonomous | PRIV + BTDD implementation of all tasks |

**Auto-chaining**: Run `/1-brainstorm` and the chain flows automatically through task planning. After reviewing the task plan and behavioral specs, manually invoke `/6-implement` to begin implementation.

**Research first**: Run `/research` before brainstorming to ground decisions in verified data. It produces a cited report in `./docs/research/` and an optional handoff for `/1-brainstorm`.

All durable outputs land in `./docs/` (research, epics, features, behaviors, tasks, implementation journal). Ephemeral handoffs pass through `./claude-temp/`.

### Standalone Agents

- **technology-opinions** — Captures and queries technology preferences (one-time setup)
- **copy-reviewer** — Reviews copy/content for clarity and consistency
- **messaging-brief** — Captures project messaging context for copy review

### Push Notifications (ntfy)

Push notifications to your phone when Claude Code needs attention or finishes a task. Uses a self-hosted [ntfy](https://ntfy.sh) server behind Tailscale for private, zero-trust delivery.

- **hooks/notify.sh** — Hook script that sends notifications via ntfy on `Notification` and `Stop` events
- **hooks/setup-ntfy-claude-notifications.sh** — Automated setup script (installs ntfy, provisions TLS, creates users/tokens, deploys hook)
- **hooks/ntfy-runbook.md** — Operational runbook (architecture, procedures, troubleshooting)

Notifications include hostname, tmux session:window, and project name so you know exactly where to look:

```
devbox [main:claude] my-project
  Needs your attention
```

**Quick start:**

```bash
chmod +x hooks/setup-ntfy-claude-notifications.sh
./hooks/setup-ntfy-claude-notifications.sh
```

See the [runbook](hooks/ntfy-runbook.md) for phone app setup, token rotation, cert renewal, and troubleshooting.

**Requirements:** Ubuntu 24.04, Tailscale, jq, ntfy iOS/Android app

### Configuration

- **settings.json** — Permission rules for auto-approved commands (git, npm, WebFetch, etc.)

## Adding to a Project

### Option A: Submodule as `.claude/` (Recommended)

From your project root:

```bash
git submodule add https://github.com/z1g1/prompts .claude
git commit -m "feat: add shared Claude Code agents and commands via submodule"
```

Since `agents/`, `commands/`, and `settings.json` are at the repo root, they
land at `.claude/agents/`, `.claude/commands/`, and `.claude/settings.json` —
exactly where Claude Code auto-discovers them.

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
cp -r prompts/agents/* .claude/agents/ 2>/dev/null || true
cp -r prompts/commands/* .claude/commands/ 2>/dev/null || true
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
# Research a topic (standalone)
/research Compare authentication providers for a B2B SaaS MVP

# Full pipeline
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

# Re-copy if using the prompts/ approach (web sessions):
mkdir -p .claude/agents .claude/commands
cp -r prompts/agents/* .claude/agents/ 2>/dev/null || true
cp -r prompts/commands/* .claude/commands/ 2>/dev/null || true
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
agents/                         # Agent definitions (submodule root -> .claude/agents/)
├── technology-opinions.md
├── copy-reviewer.md
└── messaging-brief.md
commands/                       # Command definitions (submodule root -> .claude/commands/)
├── research.md
├── 1-brainstorm.md
├── 2-requirements.md
├── 3-epic-planner.md
├── 4-feature-planner.md
├── 5-task-planner.md
└── 6-implement.md
hooks/                          # Hook scripts and setup tooling
├── notify.sh                  # ntfy push notification hook
├── setup-ntfy-claude-notifications.sh  # Automated ntfy setup
└── ntfy-runbook.md            # Operational runbook
settings.json                   # Permission config (submodule root -> .claude/settings.json)

prompts/                        # Obsidian vault (documentation only)
├── claude/
│   ├── commands/              # Command usage docs
│   │   ├── USAGE.md
│   │   ├── research-usage.md
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

## Developing This Repo

Runtime files live at the repo root for submodule distribution, but Claude Code
expects them under `.claude/`. To work on this repo itself, create local
symlinks (already gitignored):

```bash
mkdir -p .claude
ln -s ../agents .claude/agents
ln -s ../commands .claude/commands
ln -s ../settings.json .claude/settings.json
```

This gives Claude Code the `.claude/agents/`, `.claude/commands/`, and
`.claude/settings.json` paths it needs while keeping the real files at root.

## Contributing

1. Work on the `dev` branch
2. Create/edit prompts in appropriate subdirectory
3. Always create two files:
   - `agents/{name}.md` or `commands/{name}.md` — The agent/command definition
   - `prompts/claude/agents/{name}-usage.md` or `prompts/claude/commands/{name}-usage.md` — Documentation
4. Commit frequently with descriptive messages
5. See [CLAUDE.md](./CLAUDE.md) for detailed guidelines

## License

Personal use. Not licensed for distribution.
