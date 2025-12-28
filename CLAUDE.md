# Claude.md for home directory 

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working on any project, it lives in the home directory 

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
You must follow coding best practices. Do not work around a code issue with a temporary fix which might introduce an architecural level security vulnerblity
When considering to use a piece of software you must not introduce new high level security vulnerabilities into a project. You may consider a medium level CVE with warnings to the user. Low levels can be ignored. 
