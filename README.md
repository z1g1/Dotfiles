# promps

Repository of repeatable prompts, slash commands, and agents for various LLMs, organized as an Obsidian vault.

## What's Inside

### Claude Code Planning Pipeline (Slash Commands)

A complete 5-command Agile planning chain that transforms project ideas into implementation-ready TDD tasks:

<<<<<<< Updated upstream
- **epic-planner** - Conducts business requirements interviews and creates Epic documentation
- **story-planner** - Breaks Epics into User Stories (autonomous)
- **task-planner** - Creates TDD task breakdown for Stories (autonomous)
- **technology-opinions** - Captures and queries technology preferences
- **copy-reviewer** - Reviews customer-facing website copy
=======
```
/1-brainstorm → /2-requirements → /3-epic-planner → /4-feature-planner → /5-task-planner
```
>>>>>>> Stashed changes

| Command | Mode | What It Does |
|---------|------|-------------|
| `/1-brainstorm` | Interactive | Adversarial business problem exploration |
| `/2-requirements` | Interactive | Business requirements elicitation and prioritization |
| `/3-epic-planner` | Interactive | Codebase analysis + Epic definition interview |
| `/4-feature-planner` | Autonomous | Decomposes Epics into user-facing Features |
| `/5-task-planner` | Autonomous | Creates TDD Red-Green-Refactor tasks |

<<<<<<< Updated upstream
📖 **[Deployment Guide](./.claude/agents/DEPLOYMENT.md)** - How to install these agents
📖 **[Usage Guide](./prompts/claude/agents/agent-chain-usage-epic-story-task.md)** - Complete workflow documentation
=======
**Auto-chaining**: Run `/1-brainstorm` and the entire chain flows automatically through all 5 commands.

All durable outputs land in `./docs/` (epics, features, tasks). Ephemeral handoffs pass through `./claude-temp/`.

### Claude Code Agents

Standalone agents for specific workflows:

- **technology-opinions** — Captures and queries technology preferences (one-time setup)
- **copy-reviewer** — Reviews copy/content for clarity and consistency
>>>>>>> Stashed changes

### FourScore Business Prompts

Business-specific prompts for the FourScore platform.

## Repository Structure

```
<<<<<<< Updated upstream
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
=======
prompts/                        # Obsidian vault
├── claude/                    # Claude Code prompts
│   ├── commands/              # Slash command definitions
│   │   ├── USAGE.md                    # Complete pipeline guide
│   │   ├── 1-brainstorm.md             # /1-brainstorm command
│   │   ├── 2-retuirements.md           # /2-requirements command
│   │   ├── 3-epic-planner.md           # /3-epic-planner command
│   │   ├── 3-epic-planner-usage.md     # Usage guide
│   │   ├── 4-feature-planner.md        # /4-feature-planner command
│   │   ├── 4-feature-planner-usage.md  # Usage guide
│   │   ├── 5-task-planner.md           # /5-task-planner command
│   │   └── 5-task-planner-usage.md     # Usage guide
│   ├── agents/                # Standalone agents
│   │   ├── DEPLOYMENT.md               # How to deploy agents
│   │   ├── copy-reviewer.md            # Copy review agent
│   │   ├── copy-reviewer-usage.md      # Usage guide
│   │   ├── technology-opinions.md      # Tech preferences agent
│   │   └── technology-opinions-usage.md # Usage guide
│   └── settings.json          # Permission configuration
└── fourscore/                 # Business prompts
>>>>>>> Stashed changes
```

## Quick Start

<<<<<<< Updated upstream
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
=======
### Planning Pipeline (Slash Commands)

1. **Deploy commands** (choose one):
   ```bash
   cd /path/to/promps

   # Option 1: Symlink (auto-updates when you edit source)
   mkdir -p ~/.claude/commands
   for cmd in prompts/claude/commands/{1,2,3,4,5}-*.md; do
     ln -sf "$(pwd)/$cmd" ~/.claude/commands/
   done

   # Option 2: Copy (static)
   mkdir -p ~/.claude/commands
   cp prompts/claude/commands/{1,2,3,4,5}-*.md ~/.claude/commands/
   ```

2. **Start planning a project**:
   ```
   /1-brainstorm Build a customer portal for my SaaS product
   # Flows: brainstorm → requirements → epics → features → tasks
   ```

See [commands/USAGE.md](./prompts/claude/commands/USAGE.md) for the complete pipeline guide.

### Standalone Agents

1. **Deploy agents**:
   ```bash
   mkdir -p ~/.claude/agents
   ln -sf "$(pwd)/prompts/claude/agents/technology-opinions.md" ~/.claude/agents/
   ln -sf "$(pwd)/prompts/claude/agents/copy-reviewer.md" ~/.claude/agents/
   ```

2. **Setup tech opinions** (one-time):
   ```
   technology-opinions: Set up my preferences
   ```

See [agents/DEPLOYMENT.md](./prompts/claude/agents/DEPLOYMENT.md) for detailed deployment instructions.
>>>>>>> Stashed changes

## Contributing

This is a personal prompt repository. The prompts are version-controlled here but deployed manually to `~/.claude` or project directories.

### Adding/Editing Prompts

1. Work on the `dev` branch
2. Create/edit prompts in appropriate subdirectory
3. Always create two files:
   - `{name}.md` - The prompt/agent/command definition
   - `{name}-usage.md` or `{name}-explainer.md` - Documentation
4. Commit frequently with descriptive messages
5. See [CLAUDE.md](./CLAUDE.md) for detailed guidelines

## License

Personal use. Not licensed for distribution.
