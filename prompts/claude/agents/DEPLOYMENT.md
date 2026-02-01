# Deploying Claude Code Agents

This guide explains how to deploy the planning agents from this repository to your Claude Code environment.

## Overview

The agents in this repository (`epic-planner`, `story-planner`, `task-planner`, `technology-opinions`) are stored here for version control but need to be deployed to your Claude Code configuration directory to be usable.

## Deployment Options

### Option 1: Symlinks (Recommended for Active Development)

**Best for**: When you're actively developing/improving these agents and want changes to propagate immediately.

**Setup**:
```bash
# From this repository directory
cd /path/to/promps

# Create Claude agents directory if it doesn't exist
mkdir -p ~/.claude/agents

# Symlink all planning agents
ln -s "$(pwd)/prompts/claude/agents/epic-planner.md" ~/.claude/agents/epic-planner.md
ln -s "$(pwd)/prompts/claude/agents/story-planner.md" ~/.claude/agents/story-planner.md
ln -s "$(pwd)/prompts/claude/agents/task-planner.md" ~/.claude/agents/task-planner.md
ln -s "$(pwd)/prompts/claude/agents/technology-opinions.md" ~/.claude/agents/technology-opinions.md

# Verify symlinks
ls -la ~/.claude/agents/
```

**Pros**:
- Changes to agents in the repository immediately available in Claude Code
- Easy to iterate and test improvements
- Git tracks all changes in one place
- Can commit improvements directly from the repo

**Cons**:
- If you delete/move the repository, symlinks break
- Need to manage symlinks manually

---

### Option 2: Copy Files (Recommended for Stable Usage)

**Best for**: When agents are stable and you just want to use them without modifications.

**Setup**:
```bash
# From this repository directory
cd /path/to/promps

# Create Claude agents directory if it doesn't exist
mkdir -p ~/.claude/agents

# Copy all planning agents
cp prompts/claude/agents/epic-planner.md ~/.claude/agents/
cp prompts/claude/agents/story-planner.md ~/.claude/agents/
cp prompts/claude/agents/task-planner.md ~/.claude/agents/
cp prompts/claude/agents/technology-opinions.md ~/.claude/agents/

# Verify
ls ~/.claude/agents/
```

**Pros**:
- Simple, no dependencies
- Works even if repository is moved/deleted
- Clear separation between "source" and "deployed"

**Cons**:
- Need to manually update when agents are improved
- Changes made in `~/.claude/agents/` won't be tracked in git
- Can forget to sync updates

---

### Option 3: Project-Specific Agents (For Custom Variants)

**Best for**: When you need a project-specific variant of an agent.

**Setup**:
```bash
# In your project directory
mkdir -p .claude/agents

# Copy and customize agent for this project only
cp /path/to/promps/prompts/claude/agents/epic-planner.md .claude/agents/epic-planner.md

# Edit the local version for project-specific needs
# This overrides the global agent for this project only
```

**Pros**:
- Project-specific customizations without affecting global agents
- Version controlled with the project
- Team members get the same agent configuration

**Cons**:
- Need to maintain multiple versions
- Global agent improvements don't auto-propagate

---

## Recommended Workflow

### For Most Users (Stable Usage)

1. **Initial setup**: Copy agents to `~/.claude/agents/`
   ```bash
   cp prompts/claude/agents/{epic,story,task}-planner.md ~/.claude/agents/
   cp prompts/claude/agents/technology-opinions.md ~/.claude/agents/
   ```

2. **Update when needed**: When new versions are released
   ```bash
   cd /path/to/promps
   git pull
   cp prompts/claude/agents/{epic,story,task}-planner.md ~/.claude/agents/
   ```

3. **Track your tech opinions**: Keep `~/.claude/tech-opinions.md` in a separate git repo
   ```bash
   cd ~
   git init claude-config
   cd claude-config
   mv ~/.claude/tech-opinions.md .
   ln -s "$(pwd)/tech-opinions.md" ~/.claude/tech-opinions.md
   git add tech-opinions.md
   git commit -m "Initial tech opinions"
   ```

### For Agent Developers (Active Development)

1. **Use symlinks**: Link repository agents to Claude
   ```bash
   ln -s /path/to/promps/prompts/claude/agents/*.md ~/.claude/agents/
   ```

2. **Test changes**: Edit agents in repository, test in Claude Code

3. **Commit improvements**:
   ```bash
   cd /path/to/promps
   git add prompts/claude/agents/
   git commit -m "Improve epic-planner's codebase analysis"
   git push
   ```

---

## Deployment Checklist

After deploying agents, verify they work:

- [ ] **Check agent visibility**:
  ```bash
  # In Claude Code, list available agents (if command exists)
  # Or just try invoking one:
  epic-planner: test
  ```

- [ ] **Setup tech-opinions** (one-time):
  ```bash
  technology-opinions: Set up my preferences
  ```

- [ ] **Test the chain**:
  ```bash
  epic-planner: Help me plan a simple todo app
  # Should auto-invoke story-planner → task-planner
  ```

- [ ] **Verify file locations**:
  - Global agents: `~/.claude/agents/epic-planner.md` exists
  - Global tech-opinions: `~/.claude/tech-opinions.md` (created after setup)
  - Project overrides: `./tech-opinions.md` (optional)

---

## File Locations Summary

### Repository (Version Control)
```
/path/to/promps/
├── prompts/claude/agents/
│   ├── epic-planner.md              # Source of truth
│   ├── epic-planner-usage.md        # Documentation
│   ├── story-planner.md             # Source of truth
│   ├── story-planner-usage.md       # Documentation
│   ├── task-planner.md              # Source of truth
│   ├── task-planner-usage.md        # Documentation
│   ├── technology-opinions.md       # Source of truth
│   ├── technology-opinions-usage.md # Documentation
│   └── agent-chain-usage.md         # Complete workflow guide
```

### Global Claude Config (Deployed)
```
~/.claude/
├── agents/
│   ├── epic-planner.md          # Deployed (copy or symlink)
│   ├── story-planner.md         # Deployed (copy or symlink)
│   ├── task-planner.md          # Deployed (copy or symlink)
│   └── technology-opinions.md   # Deployed (copy or symlink)
└── tech-opinions.md             # Created by technology-opinions agent
```

### Project-Specific (Optional)
```
your-project/
├── .claude/
│   └── agents/
│       └── epic-planner.md      # Project-specific override (optional)
├── tech-opinions.md             # Project-specific opinions (optional)
├── epics/                       # Created by epic-planner
├── stories/                     # Created by story-planner
├── tasks/                       # Created by task-planner
└── .claude-temp/                # Temporary handoff files (don't commit)
```

---

## Updating Agents

### If Using Symlinks
Changes are automatic - just edit in repository and they're live in Claude Code.

### If Using Copies
```bash
# Pull latest changes
cd /path/to/promps
git pull

# Re-copy agents
cp prompts/claude/agents/{epic,story,task}-planner.md ~/.claude/agents/
cp prompts/claude/agents/technology-opinions.md ~/.claude/agents/

# Verify versions match
diff prompts/claude/agents/epic-planner.md ~/.claude/agents/epic-planner.md
```

---

## Troubleshooting

### Agents Not Showing Up

**Problem**: Can't invoke agents in Claude Code

**Solutions**:
1. Verify files exist in `~/.claude/agents/`
2. Check file permissions: `chmod 644 ~/.claude/agents/*.md`
3. Restart Claude Code (if applicable)
4. Check YAML frontmatter is valid

### Symlinks Broken

**Problem**: Symlinked agents stop working

**Solutions**:
1. Check repository still exists: `ls /path/to/promps`
2. Check symlinks: `ls -la ~/.claude/agents/`
3. Re-create symlinks if repository moved

### Tech-Opinions Not Found

**Problem**: Agents report "No tech-opinions.md found"

**Solutions**:
1. Run the setup: `technology-opinions: Set up my preferences`
2. Check file exists: `ls ~/.claude/tech-opinions.md`
3. For project-specific: create `./tech-opinions.md` in project root

---

## Version Control Recommendations

### This Repository (Prompts)
```bash
# Commit agent improvements
git add prompts/claude/agents/
git commit -m "Improve story-planner's autonomous operation"
git push
```

### Tech-Opinions (Separate Repo)
```bash
# Track your technology preferences separately
mkdir ~/claude-config
cd ~/claude-config
git init
mv ~/.claude/tech-opinions.md .
ln -s "$(pwd)/tech-opinions.md" ~/.claude/tech-opinions.md
git add tech-opinions.md
git commit -m "Initial tech opinions"

# Push to private repo
git remote add origin git@github.com:yourusername/claude-config.git
git push -u origin main
```

### Project Planning Output
```bash
# In your project, add to .gitignore:
echo ".claude-temp/" >> .gitignore

# But DO track planning output:
git add epics/ stories/ tasks/
git commit -m "Add project planning documentation"
```

---

## Quick Start Commands

### Setup with Symlinks
```bash
mkdir -p ~/.claude/agents
cd /path/to/promps
for agent in epic-planner story-planner task-planner technology-opinions; do
  ln -sf "$(pwd)/prompts/claude/agents/${agent}.md" ~/.claude/agents/
done
```

### Setup with Copies
```bash
mkdir -p ~/.claude/agents
cp /path/to/promps/prompts/claude/agents/{epic,story,task}-planner.md ~/.claude/agents/
cp /path/to/promps/prompts/claude/agents/technology-opinions.md ~/.claude/agents/
```

### Update Copies
```bash
cd /path/to/promps && git pull
cp prompts/claude/agents/{epic,story,task}-planner.md ~/.claude/agents/
```

---

## See Also

- [[agent-chain-usage]] - Complete workflow guide for using the planning agents
- [[epic-planner-usage]] - Epic planning agent documentation
- [[story-planner-usage]] - Story planning agent documentation
- [[task-planner-usage]] - Task planning agent documentation
- [[technology-opinions-usage]] - Tech opinions agent documentation
