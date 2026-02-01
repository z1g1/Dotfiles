# Task Planner - Usage Guide & Development Process

## Quick Start

### Invoking the Task Planner

```
Use the task-planner to break down my Stories into Tasks
```

**Examples:**
```
task-planner: Create tasks for all ready stories

Use task-planner to break down STORY-001

task-planner: I need tasks for the authentication story
```

### What to Expect

1. **Discovery Phase (~2-3 min)**
   - Agent scans for stories with `Status: Ready`
   - Reads handoff file from story-planner (if exists)
   - Reports which story it will work on first
   - Skips stories that already have tasks

2. **Technology Check (~1-2 min)**
   - Looks for technology opinions file
   - Checks codebase for established patterns
   - Creates research tasks if critical unknowns exist
   - Only asks user if absolutely necessary

3. **Task Decomposition (~5-10 min per story)**
   - No interview - works autonomously from story documentation
   - Creates TDD-focused tasks (test → implement → refactor)
   - Breaks down each acceptance criterion into atomic tasks
   - Flags setup tasks requiring human action

4. **Task Creation**
   - Creates `./tasks/story-XXX/` directory for each story
   - Individual task files: `TASK-XXX-title.md`
   - Each task includes: test spec, implementation steps, definition of done
   - Tasks linked with Obsidian `[[WikiLinks]]` syntax

5. **Handoff Generation**
   - Creates `.claude-temp/handoff/task-to-implementation.md`
   - Includes dev environment setup, task order, TDD workflow
   - Ready for implementation agents to pick up tasks

6. **Next Story**
   - Agent moves to next "Ready" story needing tasks
   - Reports progress after each story
   - Signals when all ready stories have tasks

## Directory Structure Created

```
your-project/
├── epics/                          # Created by epic-planner
│   ├── EPIC-001-security.md
│   └── EPIC-002-authentication.md
│
├── stories/                        # Created by story-planner
│   ├── epic-001/
│   │   ├── STORY-001-fix-sql.md
│   │   └── STORY-002-rate-limit.md
│   └── epic-002/
│       ├── STORY-001-jwt-setup.md
│       └── STORY-002-login-ui.md
│
├── tasks/                          # Created by task-planner
│   ├── README.md                   # Index of all task directories
│   ├── story-001/                  # Tasks for STORY-001
│   │   ├── README.md              # Task execution order
│   │   ├── TASK-001-write-query-test.md
│   │   ├── TASK-002-implement-parameterized-queries.md
│   │   └── TASK-003-refactor-add-edge-cases.md
│   └── story-002/                  # Tasks for STORY-002
│       ├── README.md
│       ├── TASK-001-setup-rate-limiter.md
│       ├── TASK-002-write-rate-limit-test.md
│       └── TASK-003-implement-rate-limit.md
│
└── .claude-temp/                   # NOT tracked in git
    └── handoff/
        ├── epic-to-story.md
        ├── story-to-task.md
        └── task-to-implementation.md  # From task-planner
```

## Task Documentation Format

Each task file contains:

- **Story & Epic Links**: References using `[[STORY-XXX]]` and `[[EPIC-XXX]]`
- **Status**: Ready | In Progress | Done
- **Type**: Test | Implementation | Refactor | Setup | Research
- **Estimated Time**: 2-4 hours
- **Dependencies**: Sequential, parallel, or none
- **Objective**: What this task accomplishes
- **Test Specification** (TDD Red Phase):
  - Test file path
  - Test code with Arrange-Act-Assert structure
  - Expected failure message
- **Implementation Steps** (TDD Green Phase):
  - Files to create/modify with exact paths
  - Step-by-step instructions
  - Code snippets following codebase patterns
- **Definition of Done**:
  - Test criteria (Red → Green)
  - Implementation criteria (code quality, types, errors)
  - Integration criteria (doesn't break existing code)
- **Technical Notes**: Integration, security, performance, error handling
- **Rollback Plan**: How to revert if issues occur

## Working with Task Documentation

### Test-Driven Development Workflow

For each task, follow the Red-Green-Refactor cycle:

**1. Red Phase (Write Failing Test)**
```bash
# Task tells you exactly what test to write
# Example from TASK-001
cd src/services
# Create test file: auth.service.test.ts
# Write test as specified in task
npm test auth.service.test.ts
# ❌ Test should fail - feature not implemented yet
git commit -m "test: add failing test for user authentication"
```

**2. Green Phase (Make Test Pass)**
```bash
# Task provides implementation steps
# Follow step-by-step instructions
# Implement minimum code to pass test
npm test auth.service.test.ts
# ✅ Test should now pass
git commit -m "feat: implement user authentication"
```

**3. Refactor Phase (Clean Up & Edge Cases)**
```bash
# Improve code quality
# Add edge case tests
# Ensure all tests still pass
npm test
# ✅ All tests pass
git commit -m "refactor: improve auth service and add edge cases"
```

### In Obsidian

The task files are optimized for Obsidian:
- Click `[[STORY-XXX]]` to jump to parent story
- Click `[[EPIC-XXX]]` to jump to parent epic
- Click `[[TASK-XXX]]` to navigate between dependent tasks
- Graph view shows task dependencies
- Checkboxes track definition of done criteria

### In Your IDE

The markdown is readable in any editor:
- VSCode: Use markdown preview
- Check off definition of done as you complete items
- Search across all tasks with grep/find
- Code snippets are syntax-highlighted

### For Development Teams

- Commit `./tasks/` to git
- Team members can pick up tasks autonomously
- Update task status as you work
- Link to tasks in your issue tracker

## Tips for Better Results

### Before Running Task Planner

1. **Ensure Stories are "Ready"**: Task-planner only processes stories with status "Ready"
2. **Review Story Acceptance Criteria**: Clear criteria → better tasks
3. **Update Technology Opinions**: Create `.claude-temp/tech-opinions.md` with your preferences
4. **Check Story Dependencies**: Tasks will follow story dependency order

### Technology Opinions File

Create `.claude-temp/tech-opinions.md` to guide task-planner:

```markdown
# Technology Opinions

## Languages
- **Preferred**: TypeScript over JavaScript
- **Rationale**: Type safety reduces bugs

## Frontend Framework
- **Preferred**: React with hooks
- **Rationale**: Team expertise, ecosystem

## State Management
- **Preferred**: Zustand over Redux
- **Rationale**: Simpler API, less boilerplate

## Testing
- **Unit Tests**: Vitest (faster than Jest)
- **Integration Tests**: Supertest for APIs
- **E2E Tests**: Playwright (cross-browser)

## Backend
- **Framework**: Express.js
- **ORM**: Prisma (type-safe, migration support)
- **Validation**: Zod (TypeScript-first)

## Database
- **Preferred**: PostgreSQL
- **Rationale**: ACID compliance, JSON support

## Authentication
- **Preferred**: Supabase Auth
- **Rationale**: Built-in, secure, easy to use

## Architecture Patterns
- **Preferred**: Repository pattern for data access
- **Preferred**: Service layer for business logic
- **Avoid**: Direct database access from controllers
```

### For TDD Success

1. **Trust the Process**: Write test first, even if it feels slower initially
2. **Small Steps**: Each task is 2-4 hours - don't try to do too much
3. **Run Tests Often**: After every small change
4. **Commit Frequently**: One task = one commit (roughly)
5. **Refactor Confidently**: Tests give you safety net

## Common Patterns

### Starting Fresh with Stories

```
User: task-planner: Create tasks for all ready stories

Agent: I found 3 stories with status "Ready" needing tasks:
- STORY-001: Fix SQL Injection Vulnerabilities (Epic: Security)
- STORY-002: Add Rate Limiting to Auth Endpoints (Epic: Security)
- STORY-003: JWT Authentication Setup (Epic: User Auth)

Reading handoff from story-planner...
Checking technology opinions...

Starting with STORY-001: Fix SQL Injection Vulnerabilities

This story has 3 acceptance criteria:
1. Convert raw SQL queries to parameterized queries
2. Audit all database access points
3. Add SQL injection tests

Creating TDD task breakdown:
- TASK-001: Setup - Install and configure SQLMap for testing
- TASK-002: Write test to detect SQL injection vulnerability
- TASK-003: Convert reporting queries to parameterized
- TASK-004: Add SQL injection protection tests
- TASK-005: Refactor and document secure query patterns

✅ Created 5 tasks for STORY-001

Moving to STORY-002: Add Rate Limiting...
```

### Breaking Down a Specific Story

```
User: Use task-planner for STORY-003 only

Agent: Reading STORY-003: JWT Authentication Setup...

Story acceptance criteria:
- User can log in with email/password
- JWT token issued on successful login
- Token includes user ID and role
- Token expires after 24 hours
- Refresh token mechanism for long sessions

Checking technology opinions... Found preference for Supabase Auth.

Creating TDD task breakdown:
- TASK-001: Setup - Configure Supabase Auth (REQUIRES HUMAN)
- TASK-002: Write test for login endpoint
- TASK-003: Implement login endpoint with JWT
- TASK-004: Write test for token validation
- TASK-005: Implement JWT validation middleware
- TASK-006: Write test for token refresh
- TASK-007: Implement refresh token endpoint
- TASK-008: Add edge case tests (expired tokens, invalid credentials)

✅ Created 8 tasks for STORY-003 in ./tasks/story-003/
```

### Setup Task Example

When human action is required:

```markdown
# TASK-001: Setup Supabase Authentication

🚨 **REQUIRES HUMAN ACTION**

**Story**: [[STORY-003]] - JWT Authentication Setup
**Epic**: [[EPIC-002]] - User Authentication
**Status**: Ready
**Type**: Setup
**Estimated Time**: 1 hour

## Manual Steps Required

1. **Create Supabase Project**:
   - Go to https://supabase.com/dashboard
   - Click "New Project"
   - Name: [Your project name]
   - Database Password: [Choose strong password]
   - Region: [Choose closest to users]

2. **Enable Email Authentication**:
   - In Supabase dashboard → Authentication → Providers
   - Enable "Email" provider
   - Configure email templates (optional)

3. **Copy Credentials to .env**:
   ```bash
   SUPABASE_URL=https://[project-id].supabase.co
   SUPABASE_ANON_KEY=[your-anon-key]
   SUPABASE_SERVICE_ROLE_KEY=[your-service-role-key]
   ```

4. **Install Supabase Client**:
   ```bash
   npm install @supabase/supabase-js
   ```

5. **Run Test Connection**:
   ```bash
   npm run test:supabase-connection
   ```

## Definition of Done

- [ ] Supabase project created and accessible
- [ ] Email authentication enabled in dashboard
- [ ] `.env` file contains valid credentials
- [ ] `@supabase/supabase-js` package installed
- [ ] Test connection script passes

## Next Task

After completing setup, proceed to [[TASK-002]] - Write test for login endpoint
```

### Research Task Example

When unknowns exist:

```markdown
# TASK-001: Research Real-Time WebSocket Library

**Story**: [[STORY-005]] - Real-Time Dashboard Updates
**Epic**: [[EPIC-003]] - Customer Dashboard
**Status**: Ready
**Type**: Research
**Estimated Time**: 3 hours

## Research Goal

Determine the best library for implementing real-time WebSocket connections
in our React application with Node.js backend.

## Evaluation Criteria

Must have:
- [ ] WebSocket support (not just polling)
- [ ] Works with Express.js backend
- [ ] React hooks/components available
- [ ] TypeScript support
- [ ] Active maintenance (updated in last 6 months)
- [ ] Good documentation

Nice to have:
- [ ] Automatic reconnection
- [ ] Room/channel support
- [ ] Binary data support
- [ ] Under 50kb bundle size

## Candidates to Evaluate

1. **Socket.io**
   - Docs: https://socket.io
   - Check: TypeScript support, bundle size, React integration

2. **Pusher**
   - Docs: https://pusher.com
   - Check: Pricing, scalability, ease of setup

3. **Ably**
   - Docs: https://ably.com
   - Check: Pricing, features, reliability

4. **Native WebSocket API**
   - Docs: MDN WebSocket API
   - Check: Browser support, need for additional libraries

## Deliverable

Create `./docs/decisions/real-time-library.md` with:

```markdown
# Real-Time Library Decision

## Evaluation Summary

| Library | TypeScript | Bundle Size | Cost | Recommendation |
|---------|-----------|-------------|------|----------------|
| Socket.io | ✅ | 45kb | Free | ⭐ Recommended |
| Pusher | ✅ | 30kb | $49/mo | Good, but paid |
| Ably | ✅ | 35kb | $29/mo | Good, but paid |
| Native WS | ✅ | 0kb | Free | Too low-level |

## Recommendation: Socket.io

**Rationale**:
- Free and open source
- Excellent TypeScript support
- Strong React ecosystem (socket.io-client)
- Automatic reconnection built-in
- Room support for targeted updates
- Widely used and well-documented

**Implementation Plan**:
- Server: `npm install socket.io`
- Client: `npm install socket.io-client`
- Follow official React hooks guide

**Code Example**:
[Include basic usage example]
```

## Definition of Done

- [ ] All 4 candidates evaluated against criteria
- [ ] Decision document created at `./docs/decisions/real-time-library.md`
- [ ] Recommendation includes rationale and code example
- [ ] Ready to create implementation tasks based on chosen library

## Next Steps

After research complete:
- Update technology opinions with chosen library
- Create implementation tasks for real-time feature
```

## Task Status Workflow

Tasks progress through these states:

### Ready
- Task is defined and ready for implementation
- All dependencies completed (if any)
- Agent can pick this up immediately

### In Progress
- Implementation agent is actively working on this
- Update status when you start a task

### Done
- Tests pass (Red → Green achieved)
- Definition of done criteria met
- Code committed to repository

**Workflow**:
```
task-planner creates → Ready
Developer/agent starts → In Progress
Tests pass + DoD met → Done
```

## Autonomous Operation

The task-planner works autonomously through multiple stories:

```
User: task-planner: Process all ready stories

Agent: I found 4 stories with status "Ready" needing tasks:
- STORY-001: Fix SQL Injection (Epic: Security)
- STORY-002: Add Rate Limiting (Epic: Security)
- STORY-003: JWT Setup (Epic: User Auth)
- STORY-004: Login UI (Epic: User Auth)

Reading handoff from story-planner...
Checking technology opinions... Found preferences for TypeScript, React, Supabase.

Starting with STORY-001: Fix SQL Injection...

[Creates tasks for STORY-001]
✅ Created 5 tasks for STORY-001

Moving to STORY-002: Add Rate Limiting...

[Creates tasks for STORY-002]
✅ Created 6 tasks for STORY-002

Moving to STORY-003: JWT Setup...

[Creates tasks for STORY-003]
✅ Created 8 tasks for STORY-003

Moving to STORY-004: Login UI...

[Creates tasks for STORY-004]
✅ Created 7 tasks for STORY-004

All ready stories now have tasks! Task planning complete.

Implementation can begin. I recommend starting with STORY-001, TASK-001
since other stories depend on security fixes.

Handoff created at .claude-temp/handoff/task-to-implementation.md
```

## Handoff to Implementation

After task planning completes, implementation agents (or developers) can start:

```
# Pick up first task
cd ./tasks/story-001
cat TASK-001-setup-sqlmap.md

# Follow the task instructions
# Update status to "In Progress"

# Complete the task following TDD
# Update status to "Done"

# Move to next task
cat TASK-002-write-injection-test.md
```

**For autonomous agent implementation** (future):
```
Use implementation-agent to work on TASK-001
```

The implementation agent would:
- Read the task documentation
- Read handoff file for environment context
- Execute test → implement → refactor cycle
- Mark task complete when definition of done is met

## Development Process (Meta)

### How This Agent Was Created

1. **Requirements Gathering**
   - Interview with user about task-planner needs
   - Clarified scope: TDD-focused, atomic tasks
   - Defined interaction model: autonomous, no interview
   - Established output format: Prescriptive task documentation

2. **Design Decisions**
   - **Model**: Sonnet for strong reasoning
   - **Tools**: Read, Grep, Glob, Write, Bash
   - **Permission**: Default (ask before writing)
   - **TDD**: Red-Green-Refactor as core principle

3. **Prompt Engineering**
   - Autonomous operation through multiple stories
   - Technology opinions system for preferences
   - Research tasks for unknowns
   - Detailed task templates with test specs
   - Clear definition of done criteria

4. **Integration Points**
   - Reads story-planner output and handoff
   - Creates handoff for implementation agents
   - Maintains Obsidian link compatibility
   - Supports tech-opinions agent (to be created)

### Iterating on This Agent

To improve the task-planner:

1. **Edit the agent file**:
   ```
   Read and edit: prompts/claude/agents/task-planner.md
   ```

2. **Test changes**:
   ```
   Use task-planner on a test project with ready stories
   ```

3. **Common adjustments**:
   - Task template structure
   - TDD workflow instructions
   - Definition of done criteria
   - Research task format
   - Handoff file contents

4. **Version control**:
   - Commit changes to this prompts repository
   - Deploy to `~/.claude/agents/` for use

### Creating Related Agents

**technology-opinions** (recommended to create next):
```yaml
name: technology-opinions
description: Interviews user about technology preferences and documents them for other agents
tools: Read, Write
model: sonnet
```

**implementation-agent** (future):
```yaml
name: implementation-agent
description: Picks up tasks and implements them following TDD workflow
tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
```

## Troubleshooting

### No Stories Found

**Problem**: "No stories with status 'Ready' found"

**Solution**:
- Check stories have `Status: Ready` in their markdown files
- Use story-planner to create stories if they don't exist
- Verify stories aren't already marked "In Progress" or "Done"

### Tasks Too Large/Small

**Problem**: Tasks are too big or too small for TDD cycle

**Solution**:
- Review story acceptance criteria - may be too broad/narrow
- Adjust task breakdown to follow atomic principle
- Each task should be one test-implement-refactor cycle
- Update agent prompt with better sizing examples

### Missing Technology Context

**Problem**: Agent doesn't know which libraries/frameworks to use

**Solution**:
- Create `.claude-temp/tech-opinions.md` with preferences
- Let agent analyze codebase for established patterns
- Create research task to evaluate options
- Document decision in tech-opinions for future tasks

### Setup Tasks Not Flagged

**Problem**: Tasks requiring human action aren't clearly marked

**Solution**:
- Check task type is "Setup"
- Verify 🚨 emoji appears in task title/description
- Review "Manual Steps Required" section exists
- Update agent prompt to better identify setup tasks

### Unclear Definition of Done

**Problem**: Tasks lack specific completion criteria

**Solution**:
- Review task template in agent prompt
- Ensure test criteria specify Red → Green transition
- Verify implementation criteria include code quality checks
- Add more specific examples to agent prompt

## Best Practices

1. **Mark Stories "Ready"**: Only stories with this status get tasks
2. **Create Tech Opinions**: Guide task-planner's technology choices
3. **Follow TDD Strictly**: Red → Green → Refactor, every time
4. **One Task at a Time**: Complete before moving to next
5. **Update Status**: Keep task status current for team visibility
6. **Commit Often**: One task ≈ one commit
7. **Trust the Process**: TDD feels slow at first, but prevents bugs

## Example Session

```
You: Use task-planner to create tasks for all ready stories

Agent: Scanning for stories with status "Ready"...

Found 2 ready stories:
- STORY-001: Fix SQL Injection Vulnerabilities (Epic: Security)
- STORY-003: JWT Authentication Setup (Epic: User Auth)

Checking technology opinions...
Found preferences: TypeScript, Prisma ORM, Vitest for testing

Starting with STORY-001: Fix SQL Injection Vulnerabilities

Analyzing story acceptance criteria:
1. Convert raw SQL queries to parameterized queries
2. Audit all database access points for vulnerabilities
3. Add automated SQL injection testing

I see the story mentions raw SQL in reporting queries. Looking at codebase...
Found: src/reports/analytics.ts uses raw SQL queries.

Creating TDD task breakdown:

TASK-001: Setup SQLMap for SQL injection testing (Setup - 1 hour)
TASK-002: Write test to detect SQL injection in analytics endpoint (Test - 2 hours)
TASK-003: Convert analytics queries to Prisma (Implementation - 3 hours)
TASK-004: Add SQL injection test suite (Test - 2 hours)
TASK-005: Refactor query patterns and document (Refactor - 2 hours)

Dependencies:
- TASK-001 blocks all others (setup required)
- TASK-002 → TASK-003 (test then implement)
- TASK-003 → TASK-004 → TASK-005 (sequential)

✅ Created 5 tasks for STORY-001 in ./tasks/story-001/

Moving to STORY-003: JWT Authentication Setup...

This story requires Supabase setup. Checking if already configured...
No Supabase config found. Creating setup task.

Creating TDD task breakdown:

TASK-001: Setup Supabase project and auth (Setup - 1 hour) 🚨 REQUIRES HUMAN
TASK-002: Write test for user registration (Test - 2 hours)
TASK-003: Implement registration endpoint (Implementation - 3 hours)
TASK-004: Write test for login with JWT (Test - 2 hours)
TASK-005: Implement login endpoint and JWT generation (Implementation - 3 hours)
TASK-006: Write test for token validation (Test - 2 hours)
TASK-007: Implement JWT validation middleware (Implementation - 2 hours)
TASK-008: Add edge case tests and refactor (Refactor - 3 hours)

✅ Created 8 tasks for STORY-003 in ./tasks/story-003/

All ready stories now have tasks!

Summary:
- STORY-001: 5 tasks, ~10 hours estimated
- STORY-003: 8 tasks, ~18 hours estimated

Handoff created at .claude-temp/handoff/task-to-implementation.md

Ready to begin implementation? I recommend starting with STORY-001, TASK-001
(setup SQLMap testing tool).
```

## Next Steps

1. **Test the agent**: Try it on real stories
2. **Create tech-opinions agent**: Capture user preferences
3. **Iterate on prompts**: Refine based on task quality
4. **Create implementation-agent**: For autonomous coding
5. **Build your workflow**: Epic → Story → Task → Implementation

---

**Remember**: This is a living document. Update it as you learn what works best for your task planning and TDD process.
