# Claude Code Configuration

This directory contains reusable Claude Code agents and configuration that can be shared across projects via git submodules.

## What's Inside

### Agents (`agents/`)

Standalone Claude Code agents:

- **technology-opinions.md** - Captures and queries technology preferences (one-time setup)
- **copy-reviewer.md** - Reviews customer-facing website copy

### Planning Pipeline (Slash Commands)

The 5-command Agile planning chain lives in `prompts/claude/commands/` and is deployed via symlink to `~/.claude/commands/`:

```
/1-brainstorm → /2-requirements → /3-epic-planner → /4-feature-planner → /5-task-planner
```

See `prompts/claude/commands/USAGE.md` for the complete pipeline guide.

### Configuration

- **settings.json** - Permission rules for auto-approved commands (git, npm, WebFetch, etc.)

## Using This as a Git Submodule

### Add to Your Project

```bash
# In your project root:
git submodule add https://github.com/yourusername/promps.git .claude
git submodule update --init --recursive

# Commit the submodule
git add .claude .gitmodules
git commit -m "Add Claude Code agents via submodule"
```

### Agents Available Immediately

Once added as a submodule, standalone agents are immediately available in Claude Code:

```bash
# Agents are auto-detected from .claude/agents/
technology-opinions: Set up my preferences
```

**Note:** Slash commands (`/1-brainstorm` through `/5-task-planner`) require separate deployment from `prompts/claude/commands/` to `~/.claude/commands/`. See `prompts/claude/commands/USAGE.md`.

### Update

```bash
cd .claude && git pull origin main && cd ..
git add .claude
git commit -m "Update Claude Code configuration"
```

## Source of Truth

Agent and command source files live in `prompts/claude/`:

```
prompts/claude/
├── commands/                    # Planning pipeline (slash commands)
│   ├── 1-brainstorm.md
│   ├── 2-requirements.md
│   ├── 3-epic-planner.md
│   ├── 4-feature-planner.md
│   ├── 5-task-planner.md
│   └── USAGE.md
├── agents/                      # Standalone agents + usage docs
│   ├── copy-reviewer.md
│   ├── copy-reviewer-usage.md
│   ├── technology-opinions.md
│   ├── technology-opinions-usage.md
│   └── DEPLOYMENT.md
└── settings.json
```

This `.claude/` directory contains copies for submodule distribution.

## Alternative: System-Wide Installation

Instead of per-project submodules, install globally via symlink:

```bash
cd /path/to/promps

# Commands
mkdir -p ~/.claude/commands
for cmd in prompts/claude/commands/{1,2,3,4,5}-*.md; do
  ln -sf "$(pwd)/$cmd" ~/.claude/commands/
done

# Agents
mkdir -p ~/.claude/agents
ln -sf "$(pwd)/prompts/claude/agents/technology-opinions.md" ~/.claude/agents/
ln -sf "$(pwd)/prompts/claude/agents/copy-reviewer.md" ~/.claude/agents/

# Settings
ln -sf "$(pwd)/prompts/claude/settings.json" ~/.claude/settings.json
```

See `prompts/claude/agents/DEPLOYMENT.md` for detailed options.
