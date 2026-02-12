# Deploying Claude Code Commands & Agents

This guide explains how to deploy the shared agents, commands, and settings
from `z1g1/prompts` to your projects.

## Deployment Options at a Glance

| Method | Best For | Auto-discovers? | Web session support? |
|--------|----------|-----------------|---------------------|
| Submodule as `.claude/` | Most projects | Yes | Yes (with CLAUDE.md bootstrap) |
| Submodule as `prompts/` | Projects with their own `.claude/` config | No (needs copy) | Yes (with CLAUDE.md bootstrap) |
| Global symlinks | All local projects at once | Yes | No |
| Per-project copy | Customized agents | Yes | Yes (files committed) |

---

## Option 1: Submodule as `.claude/` (Recommended)

Add this repository as the `.claude/` directory. Claude Code auto-discovers
agents, commands, and settings with zero extra configuration.

### Setup

```bash
# From your project root:
git submodule add https://github.com/z1g1/prompts .claude
git commit -m "feat: add shared Claude Code agents and commands via submodule"
```

### Cloning a project that already has the submodule

```bash
git clone --recurse-submodules https://github.com/z1g1/<your-project>.git
```

Or if already cloned without `--recurse-submodules`:

```bash
git submodule update --init --recursive
```

### Web session bootstrap

Claude Code web sessions may not auto-initialize submodules. Add this to your
project's `CLAUDE.md` so Claude can self-configure:

```markdown
## Shared Agents and Commands Setup

This project uses shared Claude Code agents and commands from the
`z1g1/prompts` submodule at `.claude/`.

Before starting work, initialize the submodule if the `.claude/agents/`
directory is empty:

\```bash
git submodule update --init --recursive
\```
```

### Updating

```bash
cd .claude
git pull origin main
cd ..
git add .claude
git commit -m "chore: update shared Claude agents to latest"
```

### Limitations

- The submodule owns `.claude/` — project-specific settings should go in your
  project root's `CLAUDE.md`, not inside `.claude/`.
- Extra files (`prompts/`, `README.md`, etc.) are included but harmless —
  Claude Code ignores anything outside `agents/`, `commands/`, and `settings.json`.

---

## Option 2: Submodule as `prompts/` (Web-First)

Use this approach when your project needs its own `.claude/` directory for
project-specific agents, settings, or configuration that shouldn't live in
the submodule.

The submodule lives at `prompts/` and a bootstrap step copies agents and
commands to the project's `.claude/` directory at the start of each session.

### Setup

```bash
# From your project root:
git submodule add https://github.com/z1g1/prompts prompts
git commit -m "feat: add prompts submodule for shared Claude agents and commands"
```

### Add bootstrap instructions to your project's CLAUDE.md

Copy the following into your project's `CLAUDE.md`. This ensures Claude Code
web sessions (and fresh terminal sessions) can self-configure:

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

### (Optional) Local symlinks for terminal use

For local Claude Code terminal sessions, symlinks provide seamless access
without a copy step:

```bash
# From your project root (run once after cloning)
mkdir -p .claude
ln -sf ../prompts/.claude/agents .claude/agents
ln -sf ../prompts/.claude/commands .claude/commands
```

> **Note:** Symlinks do not resolve reliably in Claude Code web environments.
> The CLAUDE.md bootstrap approach covers that case.

### Cloning a project that already has the submodule

```bash
git clone --recurse-submodules https://github.com/z1g1/<your-project>.git
```

Or if already cloned without `--recurse-submodules`:

```bash
git submodule update --init --recursive
```

### Updating

```bash
cd prompts
git pull origin main
cd ..
git add prompts
git commit -m "chore: update prompts submodule to latest"
```

---

## Option 3: Global Symlinks

For system-wide availability across all local projects without submodules.
Does not work in Claude Code web sessions.

```bash
cd /path/to/prompts

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

# Verify
echo "Commands:" && ls ~/.claude/commands/
echo "Agents:" && ls ~/.claude/agents/
echo "Settings:" && ls -l ~/.claude/settings.json
```

### Updating

Changes are automatic — edit in the repository and they're live in Claude Code.
Restart your Claude Code session to reload.

---

## Option 4: Per-Project Copy

For project-specific customization of individual agents. Files are committed
to the project repo, so they work in web sessions without submodules.

```bash
mkdir -p .claude/agents
cp /path/to/prompts/.claude/agents/copy-reviewer.md .claude/agents/
# Edit .claude/agents/copy-reviewer.md with project-specific instructions
git add .claude/
git commit -m "Add customized copy-reviewer agent"
```

### Updating

Manual — re-copy and re-customize when the source changes.

---

## Security Considerations

- **Review before updating**: Check agent and command changes before updating
  the submodule reference. The pinned commit hash acts as an audit trail.
- **Tool access**: Agents declare tool access in their YAML frontmatter —
  verify these match your project's security requirements before enabling.
- **Submodule pinning**: Consuming projects don't automatically pick up
  untested changes. You control when to update.

---

## Project Outputs (Created by Commands)

When using the planning pipeline, commands create outputs in the consuming
project:

```
your-project/
├── docs/
│   ├── brainstorm/                  # /1 + /2 outputs
│   ├── epics/                       # /3 outputs
│   ├── features/                    # /4 outputs
│   ├── behaviors/                   # /4 outputs (updated by /6)
│   ├── tasks/                       # /5 outputs
│   └── implementation/              # /6 outputs
├── claude-temp/                     # Ephemeral handoffs (gitignored)
└── tech-opinions.md                 # Project-specific overrides (optional)
```

---

## Troubleshooting

### Agents or Commands Not Showing Up

1. Verify files exist in the expected location:
   - Submodule as `.claude/`: `ls .claude/agents/` and `ls .claude/commands/`
   - Submodule as `prompts/`: `ls .claude/agents/` and `ls .claude/commands/`
   - Global symlinks: `ls ~/.claude/agents/` and `ls ~/.claude/commands/`
2. Check permissions: `chmod 644 .claude/commands/*.md`
3. Restart Claude Code session

### Submodule Empty After Clone

```bash
git submodule update --init --recursive
```

### Symlinks Broken

If the repository was moved:

```bash
ls -la ~/.claude/commands/
ls -la ~/.claude/agents/
# Re-create from new location — re-run the symlink commands above
```

### Tech-Opinions Not Found

Agents/commands report "No tech-opinions.md found":

1. Run: `technology-opinions: Set up my preferences`
2. Check: `ls ~/.claude/tech-opinions.md`
3. For project-specific overrides: create `./tech-opinions.md` in project root

---

## See Also

- [[USAGE]] — Complete pipeline usage guide (in `commands/`)
- [[technology-opinions-usage]] — Tech opinions agent documentation
- [[copy-reviewer-usage]] — Copy reviewer agent documentation
- [[messaging-brief-usage]] — Messaging brief agent documentation
