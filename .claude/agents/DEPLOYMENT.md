# Deploying Claude Code Commands & Agents

This guide explains how to deploy the planning commands and standalone agents
from this repository to your Claude Code environment.

## Overview

This repository contains two types of Claude Code extensions:

1. **Slash Commands** (`prompts/claude/commands/`) — The 5-command planning
   pipeline (`/1-brainstorm` through `/5-task-planner`). Deployed to
   `~/.claude/commands/`.

2. **Agents** (`prompts/claude/agents/`) — Standalone agents
   (`technology-opinions`, `copy-reviewer`). Deployed to `~/.claude/agents/`.

## Deploying Slash Commands (Planning Pipeline)

### Option 1: Symlinks (Recommended)

Changes to the repository automatically propagate to Claude Code.

```bash
cd /path/to/promps
mkdir -p ~/.claude/commands

# Symlink all numbered command files
for cmd in prompts/claude/commands/{1,2,3,4,5}-*.md; do
  ln -sf "$(pwd)/$cmd" ~/.claude/commands/
done

# Verify
ls -la ~/.claude/commands/
```

### Option 2: Copy Files

```bash
cd /path/to/promps
mkdir -p ~/.claude/commands

# Copy all numbered command files
cp prompts/claude/commands/{1,2,3,4,5}-*.md ~/.claude/commands/

# Verify
ls ~/.claude/commands/
```

### Verify Commands Work

In Claude Code, type `/1-` and tab-complete. You should see `/1-brainstorm`.

---

## Deploying Standalone Agents

### Option 1: Symlinks (Recommended)

```bash
cd /path/to/promps
mkdir -p ~/.claude/agents

ln -sf "$(pwd)/prompts/claude/agents/technology-opinions.md" ~/.claude/agents/
ln -sf "$(pwd)/prompts/claude/agents/copy-reviewer.md" ~/.claude/agents/

# Verify
ls -la ~/.claude/agents/
```

### Option 2: Copy Files

```bash
mkdir -p ~/.claude/agents
cp /path/to/promps/prompts/claude/agents/{technology-opinions,copy-reviewer}.md ~/.claude/agents/
```

---

## Deploying Settings

The `prompts/claude/settings.json` file contains permission rules for
development workflows (auto-approve git reads, doc fetching, etc.).

```bash
# Symlink (recommended)
ln -sf "$(pwd)/prompts/claude/settings.json" ~/.claude/settings.json

# Or copy
cp prompts/claude/settings.json ~/.claude/settings.json
```

---

## Full Setup (Everything at Once)

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

# Verify
echo "Commands:" && ls ~/.claude/commands/
echo "Agents:" && ls ~/.claude/agents/
echo "Settings:" && ls -l ~/.claude/settings.json
```

---

## Updating

### If Using Symlinks

Changes are automatic. Edit in the repository and they're live in Claude Code.
Restart your Claude Code session to reload.

### If Using Copies

```bash
cd /path/to/promps && git pull

# Re-copy commands
cp prompts/claude/commands/{1,2,3,4,5}-*.md ~/.claude/commands/

# Re-copy agents
cp prompts/claude/agents/{technology-opinions,copy-reviewer}.md ~/.claude/agents/
```

---

## File Locations Summary

### Repository (Source of Truth)

```
/path/to/promps/
├── prompts/claude/
│   ├── commands/                        # Planning pipeline
│   │   ├── 1-brainstorm.md
│   │   ├── 2-requirements.md
│   │   ├── 3-epic-planner.md
│   │   ├── 4-feature-planner.md
│   │   ├── 5-task-planner.md
│   │   └── USAGE.md                    # Pipeline guide
│   ├── agents/                          # Standalone agents
│   │   ├── technology-opinions.md
│   │   └── copy-reviewer.md
│   └── settings.json                    # Permission rules
```

### Deployed (Claude Code Config)

```
~/.claude/
├── commands/
│   ├── 1-brainstorm.md              # Symlink or copy
│   ├── 2-requirements.md            # Symlink or copy
│   ├── 3-epic-planner.md            # Symlink or copy
│   ├── 4-feature-planner.md         # Symlink or copy
│   └── 5-task-planner.md            # Symlink or copy
├── agents/
│   ├── technology-opinions.md       # Symlink or copy
│   └── copy-reviewer.md            # Symlink or copy
├── settings.json                    # Symlink or copy
└── tech-opinions.md                 # Created by technology-opinions agent
```

### Project Outputs (Created by Commands)

```
your-project/
├── docs/
│   ├── brainstorm/                  # /1 + /2 outputs
│   ├── epics/                       # /3 outputs
│   ├── features/                    # /4 outputs
│   └── tasks/                       # /5 outputs
├── claude-temp/                     # Ephemeral handoffs (gitignored)
└── tech-opinions.md                 # Project-specific overrides (optional)
```

---

## Troubleshooting

### Commands Not Showing Up

1. Verify files exist: `ls ~/.claude/commands/`
2. Check permissions: `chmod 644 ~/.claude/commands/*.md`
3. Restart Claude Code session

### Agents Not Showing Up

1. Verify files exist: `ls ~/.claude/agents/`
2. Check YAML frontmatter is valid
3. Restart Claude Code session

### Symlinks Broken

If the repository was moved:
```bash
# Check current symlinks
ls -la ~/.claude/commands/
ls -la ~/.claude/agents/

# Re-create from new location
cd /new/path/to/promps
# Re-run the symlink commands above
```

### Tech-Opinions Not Found

Agents/commands report "No tech-opinions.md found":
1. Run: `technology-opinions: Set up my preferences`
2. Check: `ls ~/.claude/tech-opinions.md`
3. For project-specific overrides: create `./tech-opinions.md` in project root

---

## Migration from Agent-Based Pipeline

If you previously deployed the agent-based planning pipeline (`epic-planner`,
`story-planner`, `task-planner` agents), you can remove them:

```bash
# Remove old planning agents (now slash commands)
rm -f ~/.claude/agents/epic-planner.md
rm -f ~/.claude/agents/story-planner.md
rm -f ~/.claude/agents/task-planner.md

# Deploy new slash commands
cd /path/to/promps
mkdir -p ~/.claude/commands
for cmd in prompts/claude/commands/{1,2,3,4,5}-*.md; do
  ln -sf "$(pwd)/$cmd" ~/.claude/commands/
done
```

Key differences from the old agent system:
- Agents used `./epics/`, `./stories/`, `./tasks/` — commands use `./docs/epics/`, `./docs/features/`, `./docs/tasks/`
- "Story" is now "Feature" (`FEATURE-XXX` instead of `STORY-XXX`)
- Handoffs use JSON in `./claude-temp/` instead of Markdown in `./.claude-temp/handoff/`
- Commands run in the main conversation instead of as subprocesses

---

## See Also

- [[USAGE]] — Complete pipeline usage guide (in `commands/`)
- [[technology-opinions-usage]] — Tech opinions agent documentation
- [[copy-reviewer-usage]] — Copy reviewer agent documentation
