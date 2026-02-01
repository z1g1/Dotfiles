# Story Planner - Usage Guide & Development Process

## Quick Start

### Invoking the Story Planner

```
Use the story-planner to break down my Epics into Stories
```

**Examples:**
```
story-planner: Create stories for all my Epics

Use story-planner to break down EPIC-001

story-planner: I need stories for the authentication Epic
```

### What to Expect

1. **Discovery Phase (~2-3 min)**
   - Agent scans for Epics without stories
   - Reads handoff file from epic-planner (if exists)
   - Reports which Epic it will work on first
   - Asks which Epic to start with (or follows handoff recommendation)

2. **Interview Phase (~5-10 min per Epic)**
   - Agent asks clarifying questions about features
   - Questions tailored to story type (UI, backend, testing)
   - Helps you think through requirements you may not have considered
   - Iterative conversation to ensure clarity

3. **Codebase Analysis (as needed)**
   - Relies primarily on handoff context
   - Only searches codebase when critical context is missing
   - Focused searches for patterns, existing components, testing setup

4. **Story Creation**
   - Creates `./stories/epic-XXX/` directory for each Epic
   - Individual story files: `STORY-XXX-title.md`
   - Each story includes: user story, acceptance criteria, technical notes
   - Stories linked with Obsidian `[[WikiLinks]]` syntax

5. **Handoff Generation**
   - Creates `.claude-temp/handoff/story-to-task.md`
   - Includes technical context for task-planner
   - Recommends story implementation order

6. **Next Epic**
   - Agent moves to next Epic needing stories
   - Reports progress after each Epic
   - Offers to invoke task-planner when done

## Directory Structure Created

```
your-project/
├── epics/                          # Created by epic-planner
│   ├── EPIC-001-security.md
│   └── EPIC-002-authentication.md
│
├── stories/                        # Created by story-planner
│   ├── README.md                   # Index of all story directories
│   ├── epic-001/                   # Stories for EPIC-001
│   │   ├── README.md              # Index of EPIC-001 stories
│   │   ├── STORY-001-fix-sql-injection.md
│   │   ├── STORY-002-add-rate-limiting.md
│   │   └── STORY-003-update-dependencies.md
│   └── epic-002/                   # Stories for EPIC-002
│       ├── README.md
│       ├── STORY-001-jwt-setup.md
│       └── STORY-002-login-ui.md
│
└── .claude-temp/                   # NOT tracked in git
    └── handoff/
        ├── epic-to-story.md        # From epic-planner
        └── story-to-task.md        # From story-planner
```

**Important**: Add `.claude-temp/` to your `.gitignore` if not already present.

## Story Documentation Format

Each story file contains:

- **Epic Link**: Reference to parent Epic using `[[EPIC-XXX]]`
- **Status**: Draft | Ready | In Progress | Done
- **Complexity**: Small | Medium | Large
- **User Story**: As a... I want... So that... format
- **Context**: Why this story matters
- **Acceptance Criteria**:
  - Functional requirements (checkboxes)
  - Non-functional requirements (performance, security, accessibility)
  - Testing requirements (unit, integration, E2E)
- **Technical Implementation Notes**:
  - High-level approach
  - Components/files affected
  - Integration points
  - Technical considerations
  - Existing patterns to follow
- **Dependencies**: Links to other stories using `[[STORY-XXX]]`
- **Out of Scope**: What's NOT included
- **Notes**: Additional context, open questions, decisions

## Working with Story Documentation

### In Obsidian

The story files are optimized for Obsidian:
- Click `[[EPIC-XXX]]` links to jump to parent Epic
- Click `[[STORY-XXX]]` links to navigate between stories
- Graph view shows story dependencies
- Checkboxes track acceptance criteria completion

### In Your IDE

The markdown is readable in any editor:
- VSCode: Use markdown preview
- Check off acceptance criteria as you implement
- Search across all stories with grep/find

### For Development Teams

- Commit `./stories/` to git
- Team members can review stories before implementation
- Use PR process for story refinements
- Link to stories in your issue tracker

## Tips for Better Results

### During the Interview

1. **Be Specific About Features**: "Users need to upload profile photos" not "users need profiles"
2. **Mention UI/UX Requirements**: "Should work on mobile", "needs to be accessible"
3. **Clarify Data Needs**: "We store user preferences in PostgreSQL"
4. **Share Performance Concerns**: "Dashboard should load in under 2 seconds"
5. **Ask for Help**: If you're unsure about technical details, ask the agent for guidance

### For Frontend Stories

1. **Describe User Interactions**: What users click, see, interact with
2. **Mention Responsive Design**: Mobile, tablet, desktop requirements
3. **Accessibility Requirements**: WCAG compliance, keyboard navigation, screen readers
4. **Visual Design**: Reference design files, mockups, or style guides

### For Backend Stories

1. **Data Structures**: What data is stored, retrieved, updated
2. **API Contracts**: REST endpoints, GraphQL queries, request/response formats
3. **Integrations**: External services, third-party APIs
4. **Performance**: Expected response times, rate limits

### For Testing Stories

1. **Test Coverage Expectations**: Let agent recommend test types
2. **Critical User Flows**: Which workflows must be tested end-to-end
3. **Security Testing**: Penetration testing, vulnerability scanning needs

## Common Patterns

### Starting Fresh with Epics

```
User: story-planner: Create stories for all my Epics

Agent: I found 3 Epics needing stories:
- EPIC-001: Security Remediation
- EPIC-002: User Authentication
- EPIC-003: Customer Dashboard

The handoff file recommends starting with EPIC-001 (Security Remediation)
since EPIC-002 and EPIC-003 depend on it. Should I proceed with EPIC-001?

User: Yes

Agent: Great! Let me ask some questions about EPIC-001...

[Interview process begins]
```

### Breaking Down a Specific Epic

```
User: Use story-planner for EPIC-002 only

Agent: Reading EPIC-002: User Authentication...

I see this Epic covers JWT setup, login/logout, password reset, and
session management. Let me ask some clarifying questions:

1. For the login UI, should this be a modal or a dedicated page?
2. Should we support social login (Google, GitHub) or just email/password?
3. What's the password reset flow - email link or security questions?

[Interview continues...]
```

### Adding Stories to Existing Epic

```
User: Add a story for "remember me" functionality to EPIC-002

Agent: Reading existing stories in ./stories/epic-002/...

I see STORY-001 (JWT Setup) and STORY-002 (Login UI) already exist.
The "remember me" feature relates to both.

A few questions:
1. Should "remember me" extend the JWT expiration, or use a separate
   refresh token?
2. How long should the "remember me" session last? 30 days? 90 days?
3. Should this be a checkbox on the login form?

[Creates STORY-003 after clarification]
```

### Refining Draft Stories

```
User: STORY-005 is too large, please split it

Agent: Reading STORY-005: User Dashboard...

You're right, this story covers too much:
- Dashboard layout
- Multiple widgets (analytics, activity feed, notifications)
- Real-time data updates
- User customization

I'll split this into:
- STORY-005a: Dashboard Layout (foundation)
- STORY-005b: Analytics Widget
- STORY-005c: Activity Feed Widget
- STORY-005d: Notifications Widget
- STORY-005e: Real-time Updates
- STORY-005f: Dashboard Customization

Does this breakdown make sense?
```

## Story Status Workflow

Stories progress through these states:

### Draft
- Story is defined but needs review
- Agent creates stories in Draft state initially
- User should review before approving

### Ready
- Story is approved and ready for task breakdown
- Signals task-planner to proceed
- All acceptance criteria are clear

### In Progress
- Tasks are being created or implemented
- Development team is actively working on this

### Done
- Story fully implemented and tested
- All acceptance criteria met

**Workflow**:
```
story-planner creates → Draft
User reviews → Ready
task-planner breaks down → In Progress
Development completes → Done
```

## Autonomous Operation

The story-planner works autonomously through multiple Epics:

```
User: story-planner: Process all my Epics

Agent: I found 4 Epics needing stories. I'll work through them one at a time.

Starting with EPIC-001: Security Remediation...

[Interview for EPIC-001]
[Creates stories for EPIC-001]
✅ Created 5 stories for EPIC-001

Moving to EPIC-002: User Authentication...

[Interview for EPIC-002]
[Creates stories for EPIC-002]
✅ Created 7 stories for EPIC-002

Moving to EPIC-003: Customer Dashboard...

[Interview for EPIC-003]
[Creates stories for EPIC-003]
✅ Created 8 stories for EPIC-003

Moving to EPIC-004: Reporting System...

[Interview for EPIC-004]
[Creates stories for EPIC-004]
✅ Created 6 stories for EPIC-004

All Epics now have stories! Story planning complete.

Would you like me to invoke the task-planner to start breaking down stories?
I recommend starting with EPIC-001 since other Epics depend on it.
```

## Handoff to Task Planning

After story planning completes:

```
Use task-planner to break down STORY-001
```

The task-planner agent (to be created) will:
- Read the Story documentation
- Read `.claude-temp/handoff/story-to-task.md` for context
- Interview you about task-level details
- Create Task documentation in `./tasks/`
- Prepare for implementation

## Story Sizing Guide

### Small Stories (1-2 days)
- Simple UI component
- Single API endpoint
- Basic CRUD operation
- Simple bug fix
- Configuration change

**Example**: "Add logout button to navigation"

### Medium Stories (2-4 days)
- Complex UI component with state management
- Multiple related API endpoints
- Integration with external service
- Moderate refactoring
- Multiple test types needed

**Example**: "Implement user profile page with edit functionality"

### Large Stories (4-7 days)
- Multiple components with complex interactions
- Full feature set (UI + backend + database)
- Complex integration with multiple services
- Significant refactoring
- Comprehensive testing suite

**Example**: "Build real-time collaborative editing feature"

**If larger than 7 days**: Agent will split into multiple stories automatically.

## Development Process (Meta)

### How This Agent Was Created

1. **Requirements Gathering**
   - Interview with user about story-planner needs
   - Clarified scope: Story-level only, no task creation
   - Defined interaction model: autonomous, feature-based
   - Established output format: Obsidian markdown

2. **Design Decisions**
   - **Model**: Sonnet for strong reasoning
   - **Tools**: Read, Grep, Glob, Write, Bash
   - **Permission**: Default (ask before writing)
   - **Scope**: Project-level (`./prompts/claude/agents/`)

3. **Prompt Engineering**
   - Autonomous operation through multiple Epics
   - Focused interviews with domain-specific questions
   - Feature-based story decomposition
   - Handoff system for task-planner
   - Quality checklist and anti-patterns

4. **Integration Points**
   - Reads epic-planner output and handoff
   - Creates handoff for task-planner
   - Maintains Obsidian link compatibility

### Iterating on This Agent

To improve the story-planner:

1. **Edit the agent file**:
   ```
   Read and edit: prompts/claude/agents/story-planner.md
   ```

2. **Test changes**:
   ```
   Use story-planner on a test project with Epics
   ```

3. **Common adjustments**:
   - Interview question templates
   - Story markdown structure
   - Handoff format
   - Story sizing guidelines
   - Codebase search patterns

4. **Version control**:
   - Commit changes to this prompts repository
   - Deploy to `~/.claude/agents/` for use

### Creating the Next Agent: task-planner

**task-planner** (next to create):
```yaml
name: task-planner
description: Breaks Stories into actionable development tasks
tools: Read, Write, Grep, Glob, Bash
model: sonnet
```

**Key features**:
- Reads story-planner output and handoff
- Creates granular, implementable tasks
- Assigns tasks to development phases (setup, implementation, testing)
- Prepares for actual coding work

## Troubleshooting

### Agent Not Finding Epics

**Problem**: "No Epics found needing stories"

**Solution**:
- Check `./epics/` directory exists with `EPIC-*.md` files
- Verify Epics were created by epic-planner
- Check if `./stories/epic-XXX/` already exists (agent skips Epics with stories)

### Stories Too Large/Small

**Problem**: Agent creates stories that are too big or too small

**Solution**:
- During interview, specify sizing expectations
- Ask agent to review story sizes before finalizing
- Use refinement mode to split large stories
- Update agent prompt with better sizing examples

### Missing Technical Context

**Problem**: Stories lack technical implementation details

**Solution**:
- Ensure epic-planner handoff includes codebase patterns
- Ask agent to search codebase for similar features
- Provide more context during interview about tech stack
- Update story with additional technical notes in refinement mode

### Handoff File Not Created

**Problem**: `.claude-temp/handoff/story-to-task.md` missing

**Solution**:
- Check agent has Write permissions
- Verify directory creation in agent prompt
- Ensure agent completes full workflow
- Check `.gitignore` isn't blocking creation

### Dependencies Not Clear

**Problem**: Story dependencies are confusing or missing

**Solution**:
- Ask agent to create dependency graph in handoff
- Review dependency section in each story
- Use Obsidian graph view to visualize dependencies
- Ask agent to clarify dependency rationale

## Best Practices

1. **Complete One Epic at a Time**: Don't interrupt agent mid-Epic
2. **Review Stories Before "Ready"**: Check draft stories, refine if needed
3. **Ask Questions**: If story isn't clear, ask agent to clarify
4. **Commit Often**: Save story documentation to git regularly
5. **Update as Needed**: Stories evolve - keep documentation current
6. **Use Obsidian**: Link navigation is much easier in Obsidian
7. **Signal Task Planning**: Mark stories "Ready" when approved

## Example Session

```
You: Use story-planner to create stories for all Epics

Agent: I found 2 Epics needing stories:
- EPIC-001: Security Remediation (Priority: Critical)
- EPIC-002: User Dashboard (Priority: High)

Reading handoff from epic-planner... EPIC-001 should be completed first
since EPIC-002 depends on security fixes.

Starting with EPIC-001: Security Remediation

I see this Epic covers SQL injection fixes, dependency updates, and
rate limiting. Let me ask some questions:

1. For SQL injection fixes - are you using an ORM (like Prisma, TypeORM)
   or raw SQL queries?

You: We use Prisma ORM mostly, but have some raw SQL in reporting queries

Agent: Got it. Prisma protects against SQL injection by default, so I'll
focus the story on converting those raw SQL queries to parameterized
queries.

2. For dependency updates - I see the Epic mentions "outdated dependencies
   with CVEs". Do you know which dependencies are problematic, or should
   the story include auditing them?

You: Not sure which ones, include auditing

Agent: Perfect. I'll create a story for running npm audit and updating
vulnerable packages.

3. For rate limiting - which endpoints need protection? All API endpoints
   or just auth-related ones?

You: Just auth endpoints for now - login, register, password reset

Agent: Makes sense. That keeps the story focused.

[Interview continues for 5 more minutes]

Agent: Based on our discussion, I'm creating 5 stories for EPIC-001:

1. STORY-001: Audit and Update Vulnerable Dependencies (Small)
2. STORY-002: Convert Raw SQL to Parameterized Queries (Medium)
3. STORY-003: Implement Rate Limiting for Auth Endpoints (Small)
4. STORY-004: Add Security Headers (HSTS, CSP, etc.) (Small)
5. STORY-005: Set Up Security Testing in CI/CD (Medium)

Does this breakdown look good?

You: Yes, create them

Agent: ✅ Created 5 stories for EPIC-001 in ./stories/epic-001/

Moving to EPIC-002: User Dashboard...

[Process repeats for EPIC-002]

Agent: ✅ Created 8 stories for EPIC-002 in ./stories/epic-002/

All Epics now have stories! I've created a handoff file for task-planner
at .claude-temp/handoff/story-to-task.md

I recommend starting task breakdown with STORY-001 from EPIC-001 since
it's foundational security work.

Ready to invoke task-planner?

You: Yes

Agent: Invoking task-planner for STORY-001...
```

## Next Steps

1. **Test the agent**: Try it on real Epics
2. **Iterate on prompts**: Refine based on story quality
3. **Create task-planner**: Next agent in the chain
4. **Build your workflow**: Epic → Story → Task → Implementation

---

**Remember**: This is a living document. Update it as you learn what works best for your story planning process.
