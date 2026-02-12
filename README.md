# promps

Repository of repeatable prompts, slash commands, and agents for various LLMs, organized as an Obsidian vault.

## What's Inside

### Claude Code Planning & Implementation Pipeline (Slash Commands)

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

### Claude Code Agents

Standalone agents for specific workflows:

- **technology-opinions** — Captures and queries technology preferences (one-time setup)
- **copy-reviewer** — Reviews copy/content for clarity and consistency
- **messaging-brief** — Captures project messaging context for copy review

### FourScore Business Prompts

Business-specific prompts for the FourScore platform.

## Repository Structure

```
.claude/                        # Runtime definitions (submodule-ready)
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

## Quick Start

### Planning Pipeline (Slash Commands)

1. **Deploy commands** (choose one):
   ```bash
   cd /path/to/promps

   # Option 1: Symlink (auto-updates when you edit source)
   mkdir -p ~/.claude/commands
   for cmd in .claude/commands/{1,2,3,4,5,6}-*.md; do
     ln -sf "$(pwd)/$cmd" ~/.claude/commands/
   done

   # Option 2: Copy (static)
   mkdir -p ~/.claude/commands
   cp .claude/commands/{1,2,3,4,5,6}-*.md ~/.claude/commands/
   ```

2. **Start planning a project**:
   ```
   /1-brainstorm Build a customer portal for my SaaS product
   # Flows: brainstorm → requirements → epics → features → tasks
   # Then review and run: /6-implement
   ```

See [commands/USAGE.md](./prompts/claude/commands/USAGE.md) for the complete pipeline guide.

### Standalone Agents

1. **Deploy agents**:
   ```bash
   mkdir -p ~/.claude/agents
   ln -sf "$(pwd)/.claude/agents/technology-opinions.md" ~/.claude/agents/
   ln -sf "$(pwd)/.claude/agents/copy-reviewer.md" ~/.claude/agents/
   ln -sf "$(pwd)/.claude/agents/messaging-brief.md" ~/.claude/agents/
   ```

2. **Setup tech opinions** (one-time):
   ```
   technology-opinions: Set up my preferences
   ```

See [DEPLOYMENT.md](./prompts/claude/DEPLOYMENT.md) for detailed deployment instructions.

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
