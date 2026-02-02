# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a personal prompt repository organized as an Obsidian vault. It contains reusable prompts and agent definitions for various LLMs and use cases.

**CRITICAL**: Files in this repository are prompts that will be deployed elsewhere. DO NOT modify files outside this directory (e.g., `~/.claude`). The user will manually move and symlink files to their deployment locations.

## Repository Structure

```
prompts/                    # Obsidian vault (main working directory)
├── .obsidian/             # Obsidian configuration (do not modify)
├── claude/                # Claude Code agents and prompts
│   └── agents/           # Claude Code agent definitions
└── fourscore/            # FourScore business prompts
```

## File Organization Rules

### Directory Usage

1. **`prompts/claude/`** - All Claude Code related prompts and agents
   - Agent definitions go in `prompts/claude/agents/`
   - Each agent is a markdown file with YAML frontmatter

2. **`prompts/fourscore/`** - Business-specific prompts for FourScore
   - Self-contained prompt documents
   - CEO-specific variations

3. **Topic-specific directories** - Create new subdirectories for other LLMs/topics as needed
   - Use descriptive names (e.g., `chatgpt/`, `gemini/`)
   - Keep related prompts together

### File Naming Convention

When creating prompts or agents:

1. **Main file**: `{name}.md` - The actual prompt or agent definition
2. **Explainer file**: `{name}-explainer.md` or `{name}-usage.md` - Background, rationale, and usage instructions

**Example**:
- `epic-planner.md` - The agent definition
- `epic-planner-usage.md` - How to use it, design decisions, troubleshooting

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

1. **Determine the correct directory**: Claude Code prompts go in `prompts/claude/`, business prompts in relevant subdirectories
2. **Create the prompt file**: `{name}.md` with appropriate content
3. **Create the explainer file**: `{name}-explainer.md` documenting:
   - Purpose and use cases
   - Design decisions
   - Usage instructions
   - Troubleshooting tips
   - Development process (if relevant)

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
# File: prompts/claude/agents/{agent-name}.md

# 2. Create the usage guide
# File: prompts/claude/agents/{agent-name}-usage.md

# 3. Test the agent (after deploying to ~/.claude/agents/)
# This is outside the scope of this repository

# 4. Commit both files
git add prompts/claude/agents/{agent-name}*.md
git commit -m "Add {agent-name} agent for Claude Code"
```

### Updating an Existing Prompt

```bash
# 1. Read the current prompt and explainer
# 2. Make changes to the prompt
# 3. Update the explainer if design changed
# 4. Commit with descriptive message
git add prompts/...
git commit -m "Update {prompt-name} to support {feature}"
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

These prompts and agents are version-controlled here but must be manually deployed to target projects.

### Initial Setup for New Project

1. **Copy base CLAUDE.md to project root:**
   ```bash
   # From your home directory CLAUDE.md or a project template
   cp ~/CLAUDE.md /path/to/project/CLAUDE.md
   ```

2. **Add autonomous agent permissions:**
   - Copy the "Autonomous Agent Permissions" section above
   - Paste into the project's CLAUDE.md
   - Customize based on project needs (e.g., add project-specific npm scripts)

3. **Deploy agents to Claude Code:**
   ```bash
   # Option A: Symlink (recommended - auto-updates when you edit source)
   ln -s /Users/zack/projects/promps/prompts/claude/agents/{agent-name}.md ~/.claude/agents/

   # Option B: Copy (static - requires manual updates)
   cp /Users/zack/projects/promps/prompts/claude/agents/{agent-name}.md ~/.claude/agents/
   ```

4. **Verify agent availability:**
   - Run `claude code` in your project
   - Type `/agents` to see available agents
   - Should see: epic-planner, troubleshooter, code-reviewer, feature-builder

### Updating Deployed Agents

**If using symlinks (Option A):**
- Edit source files in this repository
- Changes automatically reflect in `~/.claude/agents/`
- Restart Claude Code session to reload

**If using copies (Option B):**
```bash
# Re-copy updated agent files
cp /Users/zack/projects/promps/prompts/claude/agents/{agent-name}.md ~/.claude/agents/
```

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

- **No automatic deployment**: Prompts are version-controlled here but deployed manually
- **Symlinks are external**: User manages symlinks from `~/.claude` or other locations
- **Obsidian vault**: The `prompts/` directory is an Obsidian vault - don't break its structure
- **Cross-references**: Use `[[WikiLinks]]` to reference related prompts within the vault
- **Permission security**: Always review auto-approve permissions before deploying to new projects
- **Agent testing**: Test deployed agents in a safe branch before using on main codebase
