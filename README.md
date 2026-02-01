# promps

Repository of repeatable prompts and agents for various LLMs, organized as an Obsidian vault.

## What's Inside

### Claude Code Planning Agents

A complete Agile planning system that transforms project ideas into implementation-ready tasks:

- **epic-planner** - Conducts business requirements interviews and creates Epic documentation
- **story-planner** - Breaks Epics into User Stories (autonomous)
- **task-planner** - Creates TDD task breakdown for Stories (autonomous)
- **technology-opinions** - Captures and queries technology preferences

**Auto-chaining**: Run `epic-planner` and the entire chain executes automatically!

📖 **[Deployment Guide](./prompts/claude/agents/DEPLOYMENT.md)** - How to install these agents
📖 **[Usage Guide](./prompts/claude/agents/agent-chain-usage.md)** - Complete workflow documentation

### FourScore Business Prompts

Business-specific prompts for the FourScore platform.

## Repository Structure

```
prompts/                    # Obsidian vault
├── claude/                # Claude Code agents and prompts
│   └── agents/           # Planning agents
│       ├── DEPLOYMENT.md            # How to deploy agents
│       ├── agent-chain-usage.md     # Complete workflow guide
│       ├── epic-planner.md          # Epic planning agent
│       ├── story-planner.md         # Story planning agent
│       ├── task-planner.md          # Task planning agent
│       └── technology-opinions.md   # Tech preferences agent
└── fourscore/            # Business prompts
```

## Quick Start

### For Claude Code Users

1. **Deploy agents** (choose one):
   ```bash
   # Option 1: Symlink (for active development)
   cd /path/to/promps
   mkdir -p ~/.claude/agents
   ln -s "$(pwd)/prompts/claude/agents/epic-planner.md" ~/.claude/agents/
   ln -s "$(pwd)/prompts/claude/agents/story-planner.md" ~/.claude/agents/
   ln -s "$(pwd)/prompts/claude/agents/task-planner.md" ~/.claude/agents/
   ln -s "$(pwd)/prompts/claude/agents/technology-opinions.md" ~/.claude/agents/

   # Option 2: Copy (for stable usage)
   mkdir -p ~/.claude/agents
   cp prompts/claude/agents/{epic,story,task}-planner.md ~/.claude/agents/
   cp prompts/claude/agents/technology-opinions.md ~/.claude/agents/
   ```

2. **Setup tech opinions** (one-time):
   ```bash
   technology-opinions: Set up my preferences
   ```

3. **Start planning a project**:
   ```bash
   epic-planner: Help me plan [your project description]
   # Automatically creates Epics → Stories → Tasks!
   ```

See [DEPLOYMENT.md](./prompts/claude/agents/DEPLOYMENT.md) for complete installation instructions.

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
