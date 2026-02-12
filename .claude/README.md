# Claude Code Configuration

This directory contains reusable Claude Code agents, commands, and configuration that can be shared across projects via git submodules.

## What's Inside

### Agents (`agents/`)

Standalone Claude Code agents:

- **technology-opinions.md** - Captures and queries technology preferences (one-time setup)
- **copy-reviewer.md** - Reviews customer-facing website copy
- **messaging-brief.md** - Captures project messaging context for copy review

### Commands (`commands/`)

The 6-command Agile planning and implementation pipeline:

```
/1-brainstorm → /2-requirements → /3-epic-planner → /4-feature-planner → /5-task-planner → /6-implement
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

**Note:** Slash commands (`/1-brainstorm` through `/6-implement`) require separate deployment from `.claude/commands/` to `~/.claude/commands/`. See `prompts/claude/commands/USAGE.md`.

### Update

```bash
cd .claude && git pull origin main && cd ..
git add .claude
git commit -m "Update Claude Code configuration"
```

## Source of Truth

`.claude/` is the source of truth for all runtime definitions. `prompts/claude/` contains documentation only.

```
.claude/                             # Runtime definitions (submodule-ready)
├── agents/                          # Agent definitions
│   ├── technology-opinions.md
│   ├── copy-reviewer.md
│   └── messaging-brief.md
├── commands/                        # Command definitions
│   ├── 1-brainstorm.md
│   ├── 2-requirements.md
│   ├── 3-epic-planner.md
│   ├── 4-feature-planner.md
│   ├── 5-task-planner.md
│   └── 6-implement.md
├── settings.json
├── settings.local.json
└── README.md

prompts/claude/                      # Documentation only (Obsidian vault)
├── agents/                          # Agent usage docs
│   ├── technology-opinions-usage.md
│   ├── copy-reviewer-usage.md
│   └── messaging-brief-usage.md
├── commands/                        # Command usage docs
│   ├── 3-epic-planner-usage.md
│   ├── 4-feature-planner-usage.md
│   ├── 5-task-planner-usage.md
│   ├── 6-implement-usage.md
│   └── USAGE.md
└── DEPLOYMENT.md                    # Deployment guide
```

## Alternative: System-Wide Installation

Instead of per-project submodules, install globally via symlink:

```bash
cd /path/to/promps

# Commands
mkdir -p ~/.claude/commands
for cmd in .claude/commands/{1,2,3,4,5,6}-*.md; do
  ln -sf "$(pwd)/$cmd" ~/.claude/commands/
done

# Agents
mkdir -p ~/.claude/agents
ln -sf "$(pwd)/.claude/agents/technology-opinions.md" ~/.claude/agents/
ln -sf "$(pwd)/.claude/agents/copy-reviewer.md" ~/.claude/agents/
ln -sf "$(pwd)/.claude/agents/messaging-brief.md" ~/.claude/agents/

# Settings
ln -sf "$(pwd)/.claude/settings.json" ~/.claude/settings.json
```

See `prompts/claude/DEPLOYMENT.md` for detailed deployment options.
