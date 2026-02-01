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

## Important Notes

- **No automatic deployment**: Prompts are version-controlled here but deployed manually
- **Symlinks are external**: User manages symlinks from `~/.claude` or other locations
- **Obsidian vault**: The `prompts/` directory is an Obsidian vault - don't break its structure
- **Cross-references**: Use `[[WikiLinks]]` to reference related prompts within the vault
