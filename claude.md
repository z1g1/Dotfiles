# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a personal prompt repository organized as an Obsidian vault. It contains reusable prompts and agent definitions for various LLMs and use cases.

**CRITICAL**: Files in this repository are prompts that will be deployed elsewhere. DO NOT modify files outside this directory (e.g., `~/.claude`). The user will manually move and symlink files to their deployment locations.

## Repository Structure

```
agents/                     # Agent definitions with YAML frontmatter
│   ├── technology-opinions.md
│   ├── copy-reviewer.md
│   └── messaging-brief.md
commands/                   # Command definitions (slash commands)
│   ├── 1-brainstorm.md
│   ├── 2-requirements.md
│   ├── 3-epic-planner.md
│   ├── 4-feature-planner.md
│   ├── 5-task-planner.md
│   └── 6-implement.md
settings.json               # Permission configuration

prompts/                    # Obsidian vault (documentation only)
├── .obsidian/             # Obsidian configuration (do not modify)
├── claude/                # Claude Code documentation
│   ├── agents/           # Agent usage guides (*-usage.md)
│   ├── commands/         # Command usage guides (*-usage.md)
│   ├── DEPLOYMENT.md     # Deployment guide
│   ├── technology-preferences.md
│   └── development-preferences.md
└── fourscore/            # FourScore business prompts
```

When a consuming project adds this repo as a git submodule at `.claude/`, the root-level
`agents/`, `commands/`, and `settings.json` land at `.claude/agents/`, `.claude/commands/`,
and `.claude/settings.json` — exactly where Claude Code expects them.

## File Organization Rules

### Directory Usage

1. **`agents/`, `commands/`, `settings.json`** (repo root) - Claude Code runtime files
   - **Purpose**: Designed for git submodule distribution — when added as `.claude/`, these land at the correct paths automatically
   - **Contents**: Agent definitions, command definitions (*.md with YAML frontmatter), and settings.json
   - **Usage**: Projects add this repo as `.claude/` submodule for immediate agent availability

2. **`prompts/claude/`** - Claude Code documentation (reference files)
   - **Purpose**: Usage guides, design documentation, and examples
   - **Contents**: Agent usage files (*-usage.md), workflow guides, preferences
   - **Part of**: Obsidian vault for note-taking and cross-referencing

3. **`prompts/fourscore/`** - Business-specific prompts for FourScore
   - Self-contained prompt documents
   - CEO-specific variations

4. **Topic-specific directories** - Create new subdirectories for other LLMs/topics as needed
   - Use descriptive names (e.g., `chatgpt/`, `gemini/`)
   - Keep related prompts together

### File Naming Convention

When creating Claude Code agents:

1. **Agent definition**: `agents/{name}.md` - The actual agent with YAML frontmatter
2. **Usage documentation**: `prompts/claude/agents/{name}-usage.md` - How to use it, design decisions, troubleshooting

When creating Claude Code commands:

1. **Command definition**: `commands/{name}.md` - The slash command definition
2. **Usage documentation**: `prompts/claude/commands/{name}-usage.md` - How to use it, design decisions, troubleshooting

**Examples**:
- `agents/copy-reviewer.md` - Agent definition (deployed via submodule)
- `prompts/claude/agents/copy-reviewer-usage.md` - Documentation (in Obsidian vault)
- `commands/3-epic-planner.md` - Command definition (deployed via submodule)
- `prompts/claude/commands/3-epic-planner-usage.md` - Documentation (in Obsidian vault)

**Rationale**: Runtime definitions are at repo root so that submodule consumers get them at the correct `.claude/` paths automatically. Documentation stays in `prompts/` for the Obsidian vault and reference.

## Agent Definition Format

Claude Code agents use YAML frontmatter:

```markdown
---
name: agent-name
description: Brief description shown in agent list
tools: Read, Grep, Glob, Write, Bash
model: sonnet
permissionMode: default
---

# Agent Prompt Title

[Detailed agent instructions here]
```

**Key Fields**:
- `name`: Unique identifier (lowercase-with-hyphens)
- `description`: Concise summary of agent purpose (1-2 sentences)
- `tools`: Space or comma-separated list of allowed tools
- `model`: `sonnet`, `haiku`, or `opus`
- `permissionMode`: `default` (ask before actions) or other modes

## Working in This Repository

### Creating New Prompts

#### For Claude Code Agents:

1. **Create the agent definition**: `agents/{name}.md`
   - Include YAML frontmatter (name, description, tools, model, permissionMode)
   - Write the agent prompt following established patterns

2. **Create the usage documentation**: `prompts/claude/agents/{name}-usage.md`
   - Purpose and use cases
   - Design decisions
   - Usage instructions
   - Troubleshooting tips
   - Development process

#### For Claude Code Commands:

1. **Create the command definition**: `commands/{name}.md`
   - Write the command prompt following established patterns
   - Use numbered prefix for pipeline commands (e.g., `6-implement.md`)

2. **Create the usage documentation**: `prompts/claude/commands/{name}-usage.md`
   - Purpose and use cases
   - Design decisions
   - Usage instructions
   - Troubleshooting tips

#### For Other Prompts:

1. **Determine the correct directory**: Business prompts go in `prompts/fourscore/`, etc.
2. **Create the prompt file**: `{name}.md` with appropriate content
3. **Create documentation as needed**: `{name}-explainer.md` if complex

### Editing Existing Prompts

1. **Read both files**: The prompt and its explainer
2. **Understand the context**: Check the explainer for design rationale
3. **Make consistent changes**: Update both prompt and explainer if needed
4. **Preserve structure**: Maintain YAML frontmatter format for agents

### Obsidian Compatibility

Files should be Obsidian-compatible:
- Use `[[WikiLinks]]` for cross-references between prompts
- Support markdown checkboxes: `- [ ]` and `- [x]`
- Standard markdown formatting (headers, lists, code blocks)
- No proprietary formats

## Development Workflow

This repository follows the standard git workflow defined in the parent CLAUDE.md:
- Work on `dev` branch for development
- Test locally before committing
- Merge to `staging` for review
- Merge to `main` for production

**Commit frequently** when creating or updating prompts. Each logical change should be committed.

## Common Tasks

### Adding a New Claude Code Agent

```bash
# 1. Create the agent definition
# File: agents/{agent-name}.md

# 2. Create the usage guide
# File: prompts/claude/agents/{agent-name}-usage.md

# 3. Test the agent locally
# Option A: If using this repo as submodule in a test project, it's already available
# Option B: Symlink for testing: ln -s "$(pwd)/agents/{agent-name}.md" ~/test-project/.claude/agents/

# 4. Commit both files
git add agents/{agent-name}.md prompts/claude/agents/{agent-name}-usage.md
git commit -m "Add {agent-name} agent for Claude Code"
```

### Adding a New Claude Code Command

```bash
# 1. Create the command definition
# File: commands/{command-name}.md

# 2. Create the usage guide
# File: prompts/claude/commands/{command-name}-usage.md

# 3. Test the command locally
# Symlink for testing: ln -s "$(pwd)/commands/{command-name}.md" ~/.claude/commands/

# 4. Commit both files
git add commands/{command-name}.md prompts/claude/commands/{command-name}-usage.md
git commit -m "Add {command-name} command for Claude Code"
```

### Updating an Existing Agent

```bash
# 1. Read the agent definition and usage documentation
# Edit: agents/{agent-name}.md
# Review: prompts/claude/agents/{agent-name}-usage.md

# 2. Make changes to the agent
# 3. Update the usage documentation if behavior changed
# 4. Test in a project using this as a submodule

# 5. Commit with descriptive message
git add agents/{agent-name}.md prompts/claude/agents/{agent-name}-usage.md
git commit -m "Update {agent-name} to support {feature}"

# Projects using this as a submodule can update with:
# cd .claude && git pull && cd ..
```

## Autonomous Agent Permissions

When deploying autonomous agents (epic-planner, troubleshooter, code-reviewer, feature-builder), the following permissions should be configured in the target project's CLAUDE.md to enable efficient autonomous operation:

### Tool Permissions (Always Auto-Approve)

Add these to allow agents to work without constant prompting:

- `Read` - Read any project file
- `Grep` - Search code patterns
- `Glob` - Find files by pattern
- `Edit` - Modify existing files
- `Write` - Create new files
- `TodoWrite` - Manage task lists (already autonomous by default)
- `Task` - Launch specialized sub-agents
- `WebFetch` - Fetch documentation and API references
- `WebSearch` - Search for solutions and documentation

### Auto-Approve Bash Commands

**Development & Testing Commands:**
```
npm run dev:*
npm run test:*
npm run build:*
npm run lint:*
npm run typecheck:*
npm test:*
pnpm dev:*
pnpm test:*
pnpm build:*
pytest:*
cargo test:*
cargo build
```

**Git Read Operations** (already standard in base CLAUDE.md):
```
git status:*
git diff:*
git log:*
git show:*
git branch:*
git blame:*
```

**Package Information** (already standard in base CLAUDE.md):
```
npm list:*
pip list:*
pip show:*
```

### Prompt Once Per Session

These operations should ask for approval once per session, then be auto-approved for the remainder:

**Git Write Operations:**
```
git add:*
git commit:*
git push origin:*
git checkout:*
git merge:*
```

**Package Installation:**
```
npm install:*
npm ci:*
pnpm install:*
pip install:*
yarn install:*
```

Note: Must still follow "Safe and Stable" guidelines - only stable versions, warn about beta/experimental.

### Always Require Approval

Never auto-approve these destructive operations:

```
git reset --hard:*
git push --force:*
git push -f:*
git rebase:*
rm -rf:*
npm uninstall:*
pnpm remove:*
pip uninstall:*
```

## Deployment Instructions

These agents and configurations can be deployed to projects in multiple ways, depending on your needs.

### Option 1: Git Submodule (Recommended for Projects)

Add this repository as a submodule at `.claude/`. Since `agents/`, `commands/`, and `settings.json` are at the repo root, they land at `.claude/agents/`, `.claude/commands/`, and `.claude/settings.json` — exactly where Claude Code expects them.

```bash
# In your project root:
git submodule add https://github.com/z1g1/prompts .claude
git commit -m "Add Claude Code agents via submodule"

# Agents are now available in Claude Code!
```

**Benefits:**
- Agents immediately available (no copying/symlinking)
- Updates via `git submodule update`
- Works in Claude Code web sessions (files in repo)
- Version-controlled agent versions

**Update agents:**
```bash
cd .claude && git pull origin main && cd ..
git add .claude
git commit -m "Update Claude Code agents"
```

### Option 2: Global Installation (For All Projects)

Install agents system-wide:

```bash
# Symlink (auto-updates when you pull this repo)
ln -s /path/to/prompts/agents/*.md ~/.claude/agents/
ln -s /path/to/prompts/settings.json ~/.claude/settings.json

# OR: Copy (static - requires manual updates)
cp /path/to/prompts/agents/*.md ~/.claude/agents/
cp /path/to/prompts/settings.json ~/.claude/settings.json
```

**Verify availability:**
- Run `claude code` in any project
- Agents are available globally

### Option 3: Per-Project Customization

For project-specific agent variations:

```bash
# In your project:
mkdir -p .claude/agents

# Copy specific agents
cp /path/to/prompts/agents/copy-reviewer.md .claude/agents/

# Customize for this project
# Edit .claude/agents/copy-reviewer.md with project-specific instructions

# Commit project-specific agents
git add .claude/
git commit -m "Add customized Claude Code agents"
```

### Updating Deployed Agents and Configuration

**If using git submodule (Option 1):**
```bash
cd .claude
git pull origin main
cd ..
git add .claude
git commit -m "Update Claude Code agents"
```

**If using symlinks (Option 2):**
- Edit source files in this repository
- Changes automatically reflect in `~/.claude/`
- Restart Claude Code session to reload

**If using copies (Option 2 or 3):**
```bash
# Re-copy updated agent files
cp /path/to/prompts/agents/{agent-name}.md ~/.claude/agents/

# Re-copy updated settings.json
cp /path/to/prompts/settings.json ~/.claude/settings.json
```

### About settings.json

The `settings.json` file (at repo root, lands at `.claude/settings.json` when used as submodule) contains comprehensive permission rules for development workflows:

**Documentation Fetching:**
- WebFetch auto-approval for: code.claude.com, Python docs, Mozilla docs, StackOverflow, GitHub, Node.js, React, TypeScript, Rust, Go, Supabase, Stripe

**Git Operations:**
- Read: `git log`, `git diff`, `git show`, `git branch`, `git status`, `git blame`
- Write: `git add`, `git commit`, `git checkout`, `git push`, `git merge`, `git pull`

**File Operations:**
- View: `cat`, `head`, `tail`
- Search: `find`, `tree`, `grep`, `rg`
- Info: `ls`, `file`, `stat`, `du`, `wc`

**Build & Development:**
- `npm install`, `npm run build`, `npm run dev`

**System Information:**
- `pwd`, `env`, `printenv`, `which`, `uname`, `compgen`

**Web Access:**
- `WebSearch` for general queries

**Chrome DevTools:**
- Auto-approve: Read-only inspection, snapshots, console/network access, performance tracing
- Ask for approval: Navigation, clicks, form filling, file uploads
- Always deny: Script evaluation

When symlinked or copied to `~/.claude/settings.json`, these permissions enable faster, autonomous development workflows without interrupting with permission prompts.

### Project-Specific Customization

Each project may need different permission levels:

**High-trust environment (personal projects):**
- Enable all auto-approve permissions above
- Agents can work fully autonomously

**Team/production environment:**
- Keep "Always Require Approval" restrictions
- Consider requiring approval for git push operations
- May want to restrict `Write` tool to specific directories

**Per-project CLAUDE.md additions:**
```markdown
## Project-Specific Agent Permissions

# Auto-approve project-specific commands
npm run deploy:staging:*
npm run db:migrate:*
docker-compose up:*

# Restrict Write operations to specific directories
# (Note: This requires manual checking in agent prompts)
# - Allow: src/, tests/, docs/
# - Deny: .github/, config/, scripts/
```

## Important Notes

- **Submodule-first design**: Runtime files (`agents/`, `commands/`, `settings.json`) live at repo root so they land at the correct `.claude/` paths when added as a submodule
- **Documentation separate**: Agent definitions (repo root) and documentation (`prompts/`) are intentionally separated
- **Local dev setup**: Since `.claude/` is gitignored, create local symlinks for working in this repo itself (see README)
- **Obsidian vault**: The `prompts/` directory is an Obsidian vault for documentation and reference
- **Cross-references**: Use `[[WikiLinks]]` in documentation to reference related content
- **Permission security**: Always review auto-approve permissions before deploying to new projects
- **Agent testing**: Test agent changes in a test project before committing to this repository
- **Dual-purpose repo**: Serves both as submodule source (repo root) and documentation vault (`prompts/`)
