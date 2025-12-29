# Claude.md for home directory

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working on any project, it lives in the home directory

## Permissions

Claude Code is automatically allowed to use the following bash commands without requesting permission:

### File Exploration & Search
- `find:*` - File and directory search
- `ls:*` - List directory contents
- `tree:*` - Display directory structure
- `file:*` - Determine file type
- `stat:*` - Display detailed file information
- `du:*` - Disk usage statistics
- `df:*` - Filesystem disk space usage

### File Content Viewing
- `cat:*` - Display file contents
- `less:*` - View file contents with paging
- `more:*` - View file contents with paging
- `head:*` - Display first lines of files
- `tail:*` - Display last lines of files

### Text Search & Processing
- `grep:*` - Search text patterns in files
- `rg:*` - Ripgrep (faster alternative to grep)
- `ag:*` - The Silver Searcher
- `ack:*` - Code-oriented search tool
- `wc:*` - Count lines, words, and characters
- `sort:*` - Sort text lines
- `uniq:*` - Remove duplicate lines
- `cut:*` - Extract columns from text
- `awk:*` - Text processing and data extraction
- `sed:*` - Stream editor for text transformation

### System Information
- `pwd:*` - Print working directory
- `whoami:*` - Current user information
- `uname:*` - System information
- `which:*` - Locate commands
- `whereis:*` - Locate binary, source, and manual files
- `env:*` - Display environment variables
- `printenv:*` - Print environment variables

### Version Control (Read-only)
- `git status:*` - Check repository status
- `git log:*` - View commit history
- `git diff:*` - Show changes
- `git branch:*` - List branches
- `git show:*` - Show commit details
- `git blame:*` - Show line-by-line authorship

### Package Managers (Info only)
- `npm list:*` - List installed packages
- `pip list:*` - List Python packages
- `pip show:*` - Show package information
- `cargo --list:*` - List Rust commands

These permissions allow Claude to efficiently explore and understand codebases without interrupting your workflow. Write operations (like git commit, npm install, etc.) still require explicit approval. 

## Git Workflow

**CRITICAL**: Projects must use a structured branch workflow for staging and production deployments. You MUST follow this workflow and commit changes regularly.

### Branch Structure

The project uses three main branches:

- **`dev`** - Daily development branch
  - All active development happens here
  - Test locally with `npm run dev`
  - NOT deployed automatically
  - Merge to `staging` when ready to test in deployed environment

- **`staging`** - Pre-production testing environment
  - Auto-deploys to: `https://staging--custodyschedule.netlify.app`
  - Merge `dev` here to test changes in deployed environment
  - Test thoroughly before promoting to production
  - Shares same Supabase instance as production

- **`main`** - Production branch
  - Auto-deploys to: `https://custodyschedulepro.com`
  - ONLY merge from `staging` after thorough testing
  - Protected branch (should require PR review)
  - Never push directly to master

When working on tasks regularlly commit and make relevant commit messages to explain any changes that you make 

### Development Workflow

**Daily development:**
```bash
# Work on dev branch
git checkout dev
git pull origin dev

# Make changes, test locally
npm run dev

# Commit frequently (see commit guidelines below)
git add .
git commit -m "Your descriptive message"
git push origin dev
```

**Deploy to staging for testing:**
```bash
# Merge dev to staging
git checkout staging
git pull origin staging
git merge dev
git push origin staging

# Wait 2-3 minutes for Netlify deployment
# Test at: https://staging--custodyschedule.netlify.app
```

**Promote to production:**
```bash
# After thorough testing on staging
git checkout main
git pull origin main
git merge staging
git push origin main

# Automatically deploys to: https://custodyschedulepro.com
```

### Commit Guidelines

**CRITICAL: Commit frequently as you work**
- Commit after completing each logical unit of work (feature, fix, refactor)
- Commit BEFORE moving to a different task
- Commit BEFORE merging between branches
- Commit when requested by the user
- **DO NOT** accumulate many changes before committing

**Commit Message Format:**
- Use present tense, imperative mood (e.g., "Add feature" not "Added feature")
- Be specific about what changed and why
- First line: concise summary (50 chars or less)
- Additional details in body if needed

**Examples:**
```
Add inline credit purchase prompt on preview attempt
Fix icon sizing issue in FeatureBox component on mobile
Update custody assignment logic to handle year boundaries
Refactor credit spending to use transaction pattern
Set up CI/CD pipeline with staging workflow
```

**Standard Footer:**
Always include this footer in commit messages:
```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Commit Process

1. Check what changed: `git status` and `git diff`
2. Stage relevant files: `git add <files>` or `git add .`
3. Create commit with message following format above
4. Push to current branch: `git push origin <branch-name>`
5. If working across branches, merge as needed (dev → staging → main)

### When to Create Pull Requests

- Optional for `dev` → `staging` merges (can merge directly)
- **Recommended** for `staging` → `main` merges (production changes)
- Required if branch protection is enabled on `main`

### Important Reminders

- **Always work on `dev`** - Never develop directly on `staging` or `main`
- **Test locally first** - Use `npm run dev` before pushing
- **Build before pushing** - Run `npm run build` to catch TypeScript errors
- **Commit frequently** - Don't wait until "everything is perfect"
- **Meaningful messages** - Future you (and the user) will thank you
- **Follow the flow** - dev → staging → main (never skip staging)

## Safe and Stable
If software has a sable version you must always perfer these stable supported versions over experimental, beta, end of life or out of date software. If only a beta or experiment is avalible you must surface this to the user to give them the option to use it

## Cybersecurity
**CRITICAL**: You must follow coding best practices. Do not work around a code issue with a temporary fix which might introduce an architecural level security vulnerblity
**IMPORTANT**: When considering to use a piece of software you must not introduce new high level security vulnerabilities into a project. You may consider a medium level CVE with warnings to the user. Low levels can be ignored. 
**CRITICAL**: Role-Based Access Control (RBAC) is a core security requirement and must be built into the development process from day one.**
**CRITICAL**: You must **never** take a shortcut related to security because things are in development or this is just a test. Build security in from day one!

**Required Approach for All Third-Party API Integrations:**

1. **Always use restricted/limited permission keys** - Never use full admin/secret keys even in development
2. **Document required permissions** - Create a speific `$SERVICE_PERMISSIONS.md` file that contains the sepific permssions that need to be abdded in 3rd party services
3. **Test with minimum permissions** - If it works in dev with restricted keys, it will work in production
4. **Apply principle of least privilege** - Only grant the exact permissions needed, nothing more
5. **Verify in test environment** - Security issues found in test save costly fixes in production
6. Ask to retreive documentation on APIs if you need. Do not guess on API permissions always refernce documenation. If you need it ask for it

## Chrome DevTools Testing

When doing web development use Chrome DevTools MCP integration for automated browser testing. The following commands are pre-approved for automated use:

**Read-Only Commands (Always Auto-Accept):**
- `mcp__chrome-devtools__list_pages` - List open browser tabs
- `mcp__chrome-devtools__take_snapshot` - Capture page accessibility tree
- `mcp__chrome-devtools__take_screenshot` - Capture visual screenshot
- `mcp__chrome-devtools__list_console_messages` - List console logs/errors
- `mcp__chrome-devtools__get_console_message` - Get specific console message details
- `mcp__chrome-devtools__list_network_requests` - List HTTP requests
- `mcp__chrome-devtools__get_network_request` - Get specific request/response details

**Interactive Commands (Use with Caution):**
- `mcp__chrome-devtools__navigate_page` - Navigate to URLs (only use for project domains)
- `mcp__chrome-devtools__click` - Click page elements (can trigger actions)
- `mcp__chrome-devtools__handle_dialog` - Dismiss browser dialogs (safe)
- `mcp__chrome-devtools__wait_for` - Wait for content to appear (safe, read-only)

**Performance Testing Commands:**
- `mcp__chrome-devtools__performance_start_trace` - Start performance recording
- `mcp__chrome-devtools__performance_stop_trace` - Stop performance recording
- `mcp__chrome-devtools__performance_analyze_insight` - Analyze performance metrics

These commands are useful for debugging production issues, analyzing performance, and automated testing workflows
