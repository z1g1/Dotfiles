# Agent Chain Usage - Complete Development Workflow

This document explains how the planning agents work together to transform ideas into implementation-ready tasks. using the epic-planner, story-planner, and task-planner agents 

**✨ Key Feature: Automatic Chaining** - Just run `epic-planner` and the entire planning chain executes automatically. No need to manually invoke each agent!

## Agent Overview

The planning system consists of four specialized agents that work sequentially with **automatic chaining**:

```
technology-opinions (one-time setup)
    ↓
epic-planner (15 min interview)
    ↓ [AUTO-INVOKES]
story-planner (autonomous)
    ↓ [AUTO-INVOKES]
task-planner (autonomous)
    ↓ [FUTURE: AUTO-INVOKES]
implementation-agent (future - autonomous coding)
```

**Automatic Invocation**: Each agent automatically invokes the next in the chain. User only needs to start with `epic-planner`.

## Prerequisites

### One-Time Setup: Technology Opinions

Before using the planning agents, capture your technology preferences:

```bash
technology-opinions: Set up my preferences
```

**What happens**:
- Comprehensive ~20-30 minute interview
- Covers 12 categories: languages, frameworks, testing, deployment, git workflow, etc.
- Creates `~/.claude/tech-opinions.md`
- Global file used across all projects

**This only needs to be done once**. The file is reusable across all your projects.

### Technology Opinions: Two-Tier System

Technology opinions use a **Global Default + Project Override** system:

**Global Opinions** (`~/.claude/tech-opinions.md`):
- Your default technology preferences
- Used across all projects unless overridden
- Set once, reuse everywhere
- Version control separately (recommended)

**Project Opinions** (`./tech-opinions.md`):
- Optional project-specific overrides
- Committed with project code
- Only include opinions that differ from global
- Example: Global prefers React, but this project uses Vue (client requirement)

**Query Priority**:
1. Agents check `./tech-opinions.md` first (project-specific)
2. Fall back to `~/.claude/tech-opinions.md` (global)
3. If neither has opinion, report "No preference"

**When to Create Project Opinions**:
- Client mandates specific technologies
- Team has different expertise
- Legacy project uses different stack
- Want to experiment without changing global preferences

**Creating Project Opinions**:
```bash
technology-opinions: Create project-specific tech opinions

Agent: Asks which opinions should differ from global
Creates ./tech-opinions.md with only overrides
Reminds you to commit to git
```

**Example categories covered**:
- Languages (TypeScript vs JavaScript)
- Frontend (React vs Vue, state management)
- Backend (Express vs Fastify, REST vs GraphQL)
- Database (PostgreSQL vs MySQL, Prisma vs TypeORM)
- Testing (Jest vs Vitest, Playwright vs Cypress)
- Git workflow (branching strategy, commit conventions)
- Dependency management (when to add libraries)
- Software stability preferences (stable vs bleeding edge)

**Output**: `~/.claude/tech-opinions.md` (global defaults, version control recommended)

**Optional**: `./tech-opinions.md` (project-specific overrides, committed with project)

---

## Starting a New Project

**TL;DR**: Just run `epic-planner` - it will automatically invoke story-planner and task-planner.

### Phase 1: Epic Planning (User-Interactive)

**Command**:
```bash
epic-planner: Help me plan [project description]
```

**Example**:
```bash
epic-planner: Help me plan a SaaS platform for managing customer subscriptions
```

**What happens**:
1. **Interview (~15 minutes)**:
   - Agent asks structured questions about business goals
   - Covers: users, success metrics, constraints, existing systems
   - Helps you think through requirements you may not have considered

2. **Codebase Analysis**:
   - Scans for security vulnerabilities (if existing project)
   - Reviews architecture and patterns
   - Identifies technical debt

3. **Epic Creation**:
   - Creates `./epics/` directory
   - Generates Epic files: `EPIC-001-title.md`, `EPIC-002-title.md`, etc.
   - Each Epic includes:
     - Business value and success metrics
     - Acceptance criteria
     - Technical considerations
     - Dependencies between Epics
     - Risk assessment

4. **Handoff**:
   - Creates `.claude-temp/handoff/epic-to-story.md`
   - Includes recommended Epic sequencing
   - Documents codebase patterns and security requirements

5. **Auto-Invoke story-planner**:
   - Reports: "Epic planning complete. Now invoking story-planner..."
   - Uses Task tool to invoke story-planner agent
   - Continues automatically to Phase 2

**Output**:
- `./epics/EPIC-001-*.md`, `EPIC-002-*.md`, etc.
- `.claude-temp/handoff/epic-to-story.md`

**Time**: ~15 minutes for interview + ~5-10 minutes per Epic

**User can interrupt**: Say "stop" or "wait" before auto-invocation if you want to review Epics first.

---

### Phase 2: Story Planning (Autonomous - Auto-Invoked)

**Automatically invoked by epic-planner** (or can be run manually):
```bash
story-planner: Create stories for all my Epics
```

**What happens**:
1. **Discovery**:
   - Finds all Epics without stories
   - Reads handoff from epic-planner
   - Uses recommended Epic sequencing

2. **Autonomous Processing** (no interview):
   - Reads Epic documentation completely
   - Extracts acceptance criteria and technical notes
   - Checks `~/.claude/tech-opinions.md` for technology preferences
   - Analyzes codebase (only if handoff lacks context)
   - Infers story requirements from all available context

3. **Story Creation**:
   - Creates `./stories/epic-XXX/` for each Epic
   - Generates story files: `STORY-001-title.md`, `STORY-002-title.md`, etc.
   - Each story includes:
     - User story format (As a... I want... So that...)
     - Acceptance criteria (functional, non-functional, testing)
     - Technical implementation notes
     - Dependencies on other stories
     - Complexity assessment (Small/Medium/Large)

4. **Handoff**:
   - Creates `.claude-temp/handoff/story-to-task.md`
   - Includes technical context from codebase
   - Documents recommended story implementation order

5. **Auto-Invoke task-planner**:
   - Reports: "Story planning complete. Now invoking task-planner..."
   - Uses Task tool to invoke task-planner agent
   - Continues automatically to Phase 3

**Output**:
- `./stories/epic-001/STORY-001-*.md`, `STORY-002-*.md`, etc.
- `./stories/epic-002/STORY-001-*.md`, etc.
- `.claude-temp/handoff/story-to-task.md`

**Time**: ~5-10 minutes per Epic (fully autonomous)

**User Questions**: Only if critical ambiguity exists (rare)

---

### Phase 3: Task Planning (Autonomous - Auto-Invoked)

**Command**:
```bash
task-planner: Create tasks for all ready stories
```

**What happens**:
1. **Discovery**:
   - Finds all stories with `Status: Ready`
   - Reads handoff from story-planner
   - Checks technology opinions for preferences

2. **Autonomous Processing** (no interview):
   - Reads story documentation completely
   - Checks `~/.claude/tech-opinions.md` for framework/library choices
   - Analyzes codebase (only if needed for patterns)
   - Creates TDD-focused tasks (test-first approach)

3. **Task Creation**:
   - Creates `./tasks/story-XXX/` for each story
   - Generates task files: `TASK-001-title.md`, `TASK-002-title.md`, etc.
   - Each task includes:
     - Test specification (TDD Red phase - what test to write)
     - Implementation steps (TDD Green phase - make test pass)
     - Refactor guidance (TDD Refactor phase)
     - Definition of done (tests pass + acceptance criteria met)
     - File paths to create/modify
     - Dependencies (sequential vs parallel)

4. **Special Task Types**:
   - **Setup tasks**: Flagged with 🚨 when human action required (e.g., "Setup Supabase project")
   - **Research tasks**: Created when unknowns exist (e.g., "Evaluate WebSocket libraries")

5. **Handoff**:
   - Creates `.claude-temp/handoff/task-to-implementation.md`
   - Includes dev environment setup
   - Documents TDD workflow
   - Specifies task execution order

**Output**:
- `./tasks/story-001/TASK-001-*.md`, `TASK-002-*.md`, etc.
- `./tasks/story-002/TASK-001-*.md`, etc.
- `.claude-temp/handoff/task-to-implementation.md`

**Time**: ~5-10 minutes per story (fully autonomous)

**User Questions**: Only if critical decision can't be inferred (rare)

---

## Complete Workflow Example

### Scenario: Building a SaaS Subscription Platform

#### Step 1: Technology Opinions (One-Time)

```bash
You: technology-opinions: Set up my preferences

Agent: [Conducts 20-30 minute interview covering all categories]

Agent: ✅ Technology opinions captured in ~/.claude/tech-opinions.md

Summary:
- Languages: Must use TypeScript
- Frontend: Strongly prefer React with hooks
- Backend: Prefer Express.js
- Database: Strongly prefer PostgreSQL with Prisma
- Auth: Strongly prefer Supabase Auth
- Testing: Prefer Vitest, Playwright for E2E
- Git: GitHub Flow (dev → staging → main)
```

#### Step 2: Epic Planning (Triggers Full Chain)

```bash
You: epic-planner: Help me plan a SaaS subscription management platform

Agent: [15 minute interview about business goals, users, success metrics]

Agent: Based on our discussion, I recommend 6 Epics:

1. EPIC-001: Security Foundation (MUST DO FIRST)
   - Security audit and remediation
   - RBAC setup
   - Data encryption

2. EPIC-002: User Authentication
   - Supabase Auth integration
   - Email/password and OAuth
   - Session management

3. EPIC-003: Subscription Management
   - Stripe integration
   - Plan creation and selection
   - Billing workflows

4. EPIC-004: Customer Dashboard
   - Subscription overview
   - Usage metrics
   - Payment history

5. EPIC-005: Admin Portal
   - Customer management
   - Analytics and reporting
   - Subscription administration

6. EPIC-006: Webhook & Notifications
   - Stripe webhook handling
   - Email notifications
   - In-app notifications

✅ Created 6 Epics in ./epics/
✅ Handoff created at .claude-temp/handoff/epic-to-story.md

Recommendation: Start with EPIC-001 (Security Foundation) as other Epics depend on it.

Epic planning complete. Now invoking story-planner to create stories...
[Automatically invokes story-planner agent]
```

#### Step 3: Story Planning (Automatically Invoked)

```bash
Agent: I found 6 Epics needing stories. Reading handoff...
Recommended sequence: EPIC-001 → EPIC-002 → EPIC-003 → EPIC-004 → EPIC-005 → EPIC-006

Starting with EPIC-001: Security Foundation

Reading Epic documentation...
Checking tech-opinions... Prefer Prisma, must use TypeScript
Analyzing codebase for security patterns...

Creating stories autonomously:
- STORY-001: Security audit and vulnerability scan (Small)
- STORY-002: Implement RBAC system (Medium)
- STORY-003: Database encryption setup (Small)
- STORY-004: Secure session management (Medium)
- STORY-005: Security testing in CI/CD (Small)

✅ Created 5 stories for EPIC-001 in ./stories/epic-001/

Moving to EPIC-002: User Authentication...

[Continues through all 6 Epics autonomously]

✅ Story planning complete!
- Total: 32 stories across 6 Epics
- All stories marked as "Draft" - please review

Handoff created at .claude-temp/handoff/story-to-task.md

Story planning complete. Now invoking task-planner to create tasks...
[Automatically invokes task-planner agent]
```

**No user questions asked** - agent inferred everything from Epic documentation and tech-opinions.

#### Step 4: Task Planning (Automatically Invoked)

```bash
Agent: Scanning for stories with status "Ready"...

Found 32 ready stories across 6 Epics.
Reading handoff from story-planner...
Checking tech-opinions for framework preferences...

Starting with STORY-001: Security audit and vulnerability scan

Creating TDD task breakdown:
- TASK-001: Setup security scanning tools (Setup - 1 hour) 🚨 REQUIRES HUMAN
- TASK-002: Write test for SQL injection detection (Test - 2 hours)
- TASK-003: Implement SQL injection protection (Implementation - 3 hours)
- TASK-004: Write test for XSS vulnerabilities (Test - 2 hours)
- TASK-005: Implement XSS protection (Implementation - 2 hours)
- TASK-006: Add security test suite to CI (Implementation - 2 hours)

✅ Created 6 tasks for STORY-001 in ./tasks/story-001/

[Continues through all 32 stories autonomously]

✅ Task planning complete!
- Total: 156 tasks across 32 stories
- All tasks follow TDD pattern (test → implement → refactor)
- 8 setup tasks flagged as requiring human action

Handoff created at .claude-temp/handoff/task-to-implementation.md

Ready to begin implementation!
Recommended: Start with STORY-001, TASK-001 (setup security tools)
```

**No user questions asked** - agent used tech-opinions and story documentation.

**Full chain complete** - From epic-planner invocation to implementation-ready tasks, all automated!

#### Step 5: Review Planning Output (Optional)

```bash
You: [Review ./epics/, ./stories/, ./tasks/ directories]

# All planning complete! Review the output:
# - 6 Epics with full documentation
# - 32 Stories with acceptance criteria
# - 156 Tasks with TDD workflow

# Refine if needed:
You: story-planner: Refine STORY-003 - need more detail on encryption approach

Agent: [Reads STORY-003 and parent Epic, adds detail autonomously]
✅ Updated STORY-003 with encryption implementation details
```

---

## Implementation Phase (Future: Autonomous Coding)

### Current State: Manual Implementation

With tasks created, you can now:

1. **Start with setup tasks**:
   ```bash
   # Find setup tasks
   grep -r "🚨 REQUIRES HUMAN" ./tasks/

   # Complete setup tasks manually (e.g., create Supabase project, setup Stripe)
   ```

2. **Follow TDD workflow** for each task:
   ```bash
   # TASK-001: Write failing test
   npm test path/to/feature.test.ts  # ❌ Should fail
   git commit -m "test: add failing test for feature"

   # TASK-002: Implement to make test pass
   # [Write minimal code]
   npm test path/to/feature.test.ts  # ✅ Should pass
   git commit -m "feat: implement feature"

   # TASK-003: Refactor and add edge cases
   # [Improve code quality, add edge case tests]
   npm test  # ✅ All tests pass
   git commit -m "refactor: improve feature and add edge cases"
   ```

3. **Mark tasks complete**:
   - Update task status: `Status: Ready` → `Status: Done`
   - Move to next task

### Future: Implementation-Agent (Autonomous Coding)

**Vision** (to be created):
```bash
implementation-agent: Work on TASK-001

Agent:
1. Reads task documentation
2. Reads handoff file for environment context
3. Executes TDD cycle:
   - Red: Writes failing test
   - Green: Implements minimal code to pass test
   - Refactor: Improves code quality, adds edge cases
4. Runs all tests to ensure nothing breaks
5. Creates git commit
6. Marks task as "Done"
7. Moves to next task autonomously

✅ TASK-001 complete. Moving to TASK-002...
```

**Full autonomous development**:
```bash
implementation-agent: Complete all tasks for STORY-001

Agent: [Works through all tasks autonomously, commits as it goes]

✅ STORY-001 complete!
- 6 tasks completed
- 12 tests written (all passing)
- 6 git commits created
- Ready for code review
```

---

## Directory Structure Created

After running all planning agents:

```
your-project/
├── epics/                              # Created by epic-planner
│   ├── README.md                       # Index of all Epics
│   ├── EPIC-001-security-foundation.md
│   ├── EPIC-002-user-authentication.md
│   ├── EPIC-003-subscription-management.md
│   └── ...
│
├── stories/                            # Created by story-planner
│   ├── README.md                       # Index of all story directories
│   ├── epic-001/
│   │   ├── README.md                   # EPIC-001 story index
│   │   ├── STORY-001-security-audit.md
│   │   ├── STORY-002-rbac-system.md
│   │   └── ...
│   ├── epic-002/
│   │   ├── README.md
│   │   ├── STORY-001-supabase-auth-setup.md
│   │   └── ...
│   └── ...
│
├── tasks/                              # Created by task-planner
│   ├── README.md                       # Index of all task directories
│   ├── story-001/
│   │   ├── README.md                   # STORY-001 task index
│   │   ├── TASK-001-setup-security-tools.md
│   │   ├── TASK-002-write-sql-injection-test.md
│   │   ├── TASK-003-implement-sql-protection.md
│   │   └── ...
│   ├── story-002/
│   │   └── ...
│   └── ...
│
├── .claude-temp/                       # Temporary handoff files (NOT in git)
│   └── handoff/
│       ├── epic-to-story.md            # From epic-planner
│       ├── story-to-task.md            # From story-planner
│       └── task-to-implementation.md   # From task-planner
│
└── .gitignore                          # Add .claude-temp/
```

**Git tracking**:
- ✅ Track: `epics/`, `stories/`, `tasks/`
- ❌ Don't track: `.claude-temp/`

```gitignore
# .gitignore
.claude-temp/
```

---

## Agent Chain Summary

| Agent | User Time | Agent Time | Output | Interview? |
|-------|-----------|------------|--------|------------|
| **technology-opinions** | 20-30 min | - | `~/.claude/tech-opinions.md` | Yes (one-time) |
| **epic-planner** | 15 min | 5-10 min/Epic | `./epics/EPIC-*.md` | Yes |
| **story-planner** | 0 min | 5-10 min/Epic | `./stories/epic-*/STORY-*.md` | No (autonomous) |
| **task-planner** | 0 min | 5-10 min/story | `./tasks/story-*/TASK-*.md` | No (autonomous) |
| **implementation-agent** | 0 min | Varies | Code commits | No (future) |

**Total user time**: ~35-45 minutes for complete project planning

**Benefits**:
- **Comprehensive**: Epic → Story → Task breakdown
- **Autonomous**: Most agents work without user input
- **Reusable**: Tech opinions used across all projects
- **TDD-focused**: All tasks follow test-driven development
- **Implementation-ready**: Tasks have everything needed to start coding

---

## Incremental Usage

### Default: Full Auto-Chain
```bash
epic-planner: Plan my project
# Automatically runs full chain:
# ✅ Creates Epics
# ✅ Auto-invokes story-planner → Creates Stories
# ✅ Auto-invokes task-planner → Creates Tasks
# Result: Complete planning in one command!
```

### Interrupt Auto-Chain (Review at Each Stage)
```bash
# Start epic-planner
epic-planner: Plan my project

# When you see "Now invoking story-planner..."
You: stop
# ↳ Review Epics, then manually continue when ready

# Later, continue manually:
story-planner: Create stories for all Epics
You: stop  # Review stories before tasks
# ↳ Review Stories

task-planner: Create tasks for all ready stories
# ✅ Complete
```

### Targeted Planning (Single Epic or Story)
```bash
# Plan just one Epic at a time
story-planner: Create stories for EPIC-001 only
task-planner: Create tasks for STORY-001 only
# Incremental: Epic by Epic or Story by Story
```

---

## Best Practices

### 1. Technology Opinions First
- Run `technology-opinions` before any planning
- Keep `~/.claude/tech-opinions.md` updated as you learn
- Version control it in git for history

### 2. Detailed Epics = Better Stories
- Spend time on epic-planner interview
- Provide clear acceptance criteria
- Include technical considerations
- Better Epic quality → better autonomous story creation

### 3. Review Before Marking "Ready"
- Stories created as "Draft" by default
- Review and edit if needed
- Mark as "Ready" when satisfied
- Only "Ready" stories get task breakdown

### 4. Complete Setup Tasks First
- Find tasks with 🚨 REQUIRES HUMAN
- Complete these before implementation tasks
- Example: Create Supabase project, setup Stripe account

### 5. Follow TDD Workflow
- Each task specifies: test → implement → refactor
- Write test first (Red)
- Make test pass (Green)
- Refactor and add edge cases
- One task ≈ one commit

### 6. Commit Frequently
- Task-planner creates atomic tasks
- Each task should result in a commit
- Follow commit message conventions from tech-opinions

### 7. Trust the Agents
- story-planner and task-planner work autonomously
- They infer from Epic docs and tech-opinions
- Let them run - you can refine later if needed

---

## Troubleshooting

### Agent can't find tech-opinions
**Problem**: "No tech-opinions.md found"

**Solution**:
```bash
technology-opinions: Set up my preferences
```

### Stories are too vague
**Problem**: story-planner created stories but they lack detail

**Solution**:
- Check if Epic acceptance criteria were detailed enough
- Refine stories manually or use:
```bash
story-planner: Refine STORY-003 - need more detail
```

### Tasks missing technology choices
**Problem**: task-planner didn't know which framework to use

**Solution**:
- Check if tech-opinions covers the technology category
- Add opinion:
```bash
technology-opinions: Add opinion - prefer Next.js for React apps
```

### Too many Epics/Stories/Tasks
**Problem**: Planning agents created too much

**Solution**:
- Work incrementally:
```bash
epic-planner: Plan just the MVP features
story-planner: Create stories for EPIC-001 only
task-planner: Create tasks for STORY-001 only
```

---

## Future Enhancements

### Implementation-Agent
- Autonomous coding based on task specifications
- Follows TDD workflow automatically
- Creates git commits
- Runs tests and ensures they pass
- Marks tasks complete

### Code-Review-Agent
- Reviews implementation-agent's code
- Checks for security issues
- Ensures coding standards
- Suggests improvements

### MCP Integrations
- Sync with Jira/Linear/GitHub Projects
- Update task status automatically
- Link commits to tasks
- Track velocity and completion

---

## Quick Reference

### Complete Workflow Commands
```bash
# One-time setup
technology-opinions: Set up my preferences

# Per-project planning (AUTO-CHAINS TO COMPLETION)
epic-planner: Help me plan [project description]
# ↳ Automatically invokes story-planner
#   ↳ Automatically invokes task-planner
#     ✅ Complete planning in one command!

# Manual planning (if you interrupted the auto-chain)
story-planner: Create stories for all my Epics
task-planner: Create tasks for all ready stories

# Incremental planning (specific Epic/Story)
story-planner: Create stories for EPIC-001
task-planner: Create tasks for STORY-001

# Refinement
story-planner: Refine STORY-003
task-planner: Add tasks to STORY-001 for [new requirement]

# Updates
technology-opinions: Add opinion - prefer [technology]
```

### File Locations
- Global tech opinions: `~/.claude/tech-opinions.md` (version control separately)
- Project tech opinions: `./tech-opinions.md` (optional, overrides global)
- Project Epics: `./epics/EPIC-*.md`
- Project Stories: `./stories/epic-*/STORY-*.md`
- Project Tasks: `./tasks/story-*/TASK-*.md`
- Handoffs: `.claude-temp/handoff/*.md` (don't commit)

### Agent Roles
- **technology-opinions**: Capture user preferences (one-time)
- **epic-planner**: Business-level planning (user interview)
- **story-planner**: Feature-level breakdown (autonomous)
- **task-planner**: Implementation planning (autonomous)
- **implementation-agent**: Coding (future, autonomous)

---

**The goal**: Transform a project idea into implementation-ready tasks with minimal user time, maximum autonomy, and complete TDD coverage.
