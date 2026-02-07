# promps

Repository of repeatable prompts and agents for various LLMs, organized as an Obsidian vault.

## What's Inside

### Claude Code Planning Agents

A complete Agile planning system that transforms project ideas into implementation-ready tasks:

- **epic-planner** - Conducts business requirements interviews and creates Epic documentation
- **story-planner** - Breaks Epics into User Stories (autonomous)
- **task-planner** - Creates TDD task breakdown for Stories (autonomous)
- **technology-opinions** - Captures and queries technology preferences
- **copy-reviewer** - Reviews customer-facing website copy

**Auto-chaining**: Run `epic-planner` and the entire chain executes automatically!

📖 **[Deployment Guide](./.claude/agents/DEPLOYMENT.md)** - How to install these agents
📖 **[Usage Guide](./prompts/claude/agents/agent-chain-usage-epic-story-task.md)** - Complete workflow documentation

### FourScore Business Prompts

Business-specific prompts for the FourScore platform.

## Repository Structure

```
.claude/                    # Claude Code agents (submodule-ready)
├── agents/                # Agent definitions
│   ├── epic-planner.md           # Epic planning agent
│   ├── story-planner.md          # Story planning agent
│   ├── task-planner.md           # Task planning agent
│   ├── technology-opinions.md    # Tech preferences agent
│   ├── copy-reviewer.md          # Copy review agent
│   └── DEPLOYMENT.md             # Deployment guide
├── settings.json          # Permission configuration
└── README.md              # Submodule usage guide

prompts/                   # Obsidian vault (documentation)
├── claude/
│   └── agents/           # Agent usage documentation
│       ├── epic-planner-usage.md
│       ├── story-planner-usage.md
│       ├── task-planner-usage.md
│       ├── technology-opinions-usage.md
│       ├── copy-reviewer-usage.md
│       └── agent-chain-usage-epic-story-task.md
└── fourscore/            # Business prompts
```

## Quick Start

### Option 1: Git Submodule (Recommended)

Add this repository as a submodule to your project. Agents will be immediately available in Claude Code web sessions:

```bash
# In your project root:
git submodule add https://github.com/yourusername/promps.git .claude
git submodule update --init --recursive

# Commit the submodule
git add .claude .gitmodules
git commit -m "Add Claude Code agents via submodule"

# Agents are now available in Claude Code!
# Start planning:
epic-planner: Help me plan [your project description]
# Automatically creates Epics → Stories → Tasks!
```

**Update agents:**
```bash
cd .claude && git pull origin main && cd ..
git add .claude
git commit -m "Update Claude Code agents"
```

### Option 2: Global Installation

Install agents system-wide for all projects:

```bash
# Symlink (auto-updates when you pull this repo)
ln -s /path/to/promps/.claude/agents/*.md ~/.claude/agents/
ln -s /path/to/promps/.claude/settings.json ~/.claude/settings.json

# OR: Copy (static, requires manual updates)
cp /path/to/promps/.claude/agents/*.md ~/.claude/agents/
cp /path/to/promps/.claude/settings.json ~/.claude/settings.json
```

**Setup tech opinions** (one-time):
```bash
technology-opinions: Set up my preferences
```

See [.claude/README.md](./.claude/README.md) and [DEPLOYMENT.md](./.claude/agents/DEPLOYMENT.md) for complete installation options.

## Contributing

This is a personal prompt repository. The prompts are version-controlled here but deployed manually to `~/.claude` or project directories.

### Adding/Editing Prompts

1. Work on the `dev` branch
2. Create/edit prompts in appropriate subdirectory
3. Always create two files:
   - `{name}.md` - The prompt/agent definition
   - `{name}-usage.md` or `{name}-explainer.md` - Documentation
4. Commit frequently with descriptive messages
5. See [CLAUDE.md](./CLAUDE.md) for detailed guidelines

## License

Personal use. Not licensed for distribution.
