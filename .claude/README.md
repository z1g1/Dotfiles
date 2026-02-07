# Claude Code Configuration

This directory contains reusable Claude Code agents and configuration that can be shared across projects via git submodules.

## What's Inside

### Agents (`agents/`)

Production-ready Claude Code agents for Agile software development:

- **epic-planner.md** - Epic-level requirements gathering and planning
- **story-planner.md** - Breaks Epics into User Stories (autonomous)
- **task-planner.md** - Creates TDD task breakdown (autonomous)
- **technology-opinions.md** - Captures and queries technology preferences
- **copy-reviewer.md** - Reviews customer-facing website copy

**Agent Chain**: Running `epic-planner` automatically chains through `story-planner` → `task-planner`, creating complete project plans autonomously.

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

Once added as a submodule, all agents are immediately available in Claude Code web sessions:

```bash
# In your project with the submodule:
claude code

# Agents are auto-detected from .claude/agents/
# Start planning:
epic-planner: Help me plan [your feature]
```

### Update Agents

```bash
# Pull latest agent improvements:
cd .claude
git pull origin main
cd ..
git add .claude
git commit -m "Update Claude Code agents to latest version"
```

## Documentation

Agent usage guides and documentation are maintained separately in the `prompts/` directory of this repository:

- **Agent Usage Guides**: `prompts/claude/agents/*-usage.md`
- **Workflow Guide**: `prompts/claude/agents/agent-chain-usage-epic-story-task.md`
- **Deployment Options**: `agents/DEPLOYMENT.md` (in this directory)

## Technology Preferences

Some agents (like `epic-planner`) can leverage technology preferences. Create a `tech-opinions.md` file in your project root or home directory to guide agent decisions:

```bash
# Project-specific preferences (highest priority):
./tech-opinions.md

# Global preferences:
~/.claude/tech-opinions.md
```

Use the `technology-opinions` agent to set up your preferences interactively.

## Submodule Benefits

✅ **No manual copying** - Agents are in the right location automatically
✅ **Automatic updates** - Pull latest improvements via git
✅ **Version control** - Pin to specific commits or track latest
✅ **Works in web sessions** - Files are in the repository for Claude Code web
✅ **Shared across projects** - Same agents, consistent behavior

## Local Development Mode

If you're developing/improving these agents:

```bash
# Clone the repository normally (not as submodule):
git clone https://github.com/yourusername/promps.git
cd promps

# Work on agents in .claude/agents/
# Documentation lives in prompts/claude/agents/*-usage.md

# Test changes:
ln -s "$(pwd)/.claude/agents/epic-planner.md" ~/test-project/.claude/agents/
```

## Alternative: System-Wide Installation

Instead of per-project submodules, you can install agents globally:

```bash
# Option 1: Symlink (auto-updates when you pull this repo)
ln -s /path/to/promps/.claude/agents/*.md ~/.claude/agents/
ln -s /path/to/promps/.claude/settings.json ~/.claude/settings.json

# Option 2: Copy (static, requires manual updates)
cp /path/to/promps/.claude/agents/*.md ~/.claude/agents/
cp /path/to/promps/.claude/settings.json ~/.claude/settings.json
```

See `agents/DEPLOYMENT.md` for detailed deployment options.

## Repository Structure

```
.claude/                    # This directory (submodule-ready)
├── agents/                # Agent definitions
│   ├── *.md              # Agent files with YAML frontmatter
│   └── DEPLOYMENT.md     # Deployment guide
├── settings.json         # Permission configuration
└── README.md             # This file

prompts/                   # Documentation (not included in submodule usage)
├── claude/agents/        # Agent usage guides (*-usage.md)
└── ...                   # Other documentation
```

## Support

- **Agent Documentation**: See `prompts/claude/agents/` in the source repository
- **Issues**: Report at https://github.com/yourusername/promps/issues
- **Claude Code Docs**: https://docs.claude.com/claude-code

---

**Note**: This is a specialized directory designed for git submodule distribution. For comprehensive documentation, Obsidian vault structure, and non-Claude Code prompts, see the full repository.
