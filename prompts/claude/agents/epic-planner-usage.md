# Epic Planner - Usage Guide & Development Process

## Quick Start

### Invoking the Epic Planner

```
Use the epic-planner to help me plan [project description]
```

**Examples:**
```
Use the epic-planner to help me plan a customer portal for my SaaS product

Use the epic-planner to plan adding authentication to my web app

epic-planner: I want to build a mobile app for fitness tracking
```

### What to Expect

1. **Interview Phase (~15 min)**
   - The agent asks structured questions about your business goals
   - Questions cover users, success metrics, constraints, existing systems
   - Work iteratively - you don't need all answers upfront

2. **Codebase Analysis**
   - Agent scans for security vulnerabilities
   - Reviews architecture and code patterns
   - Identifies refactoring needs
   - **Security issues become mandatory first Epic**

3. **Epic Definition**
   - Agent proposes Epics based on discussion
   - You review and refine together
   - Agent captures complete Epic documentation

4. **Documentation Output**
   - Creates `./epics/` directory with Epic markdown files
   - Each Epic: `EPIC-XXX-title.md`
   - Creates `./epics/README.md` index
   - Writes handoff to `.claude-temp/handoff/epic-to-story.md`

5. **Next Steps**
   - Agent recommends which Epic to start with
   - Offers to invoke story-planner subagent (when created)

## Directory Structure Created

```
your-project/
├── epics/                          # Tracked in git
│   ├── README.md                   # Index of all Epics
│   ├── EPIC-001-security-remediation.md
│   ├── EPIC-002-user-authentication.md
│   └── EPIC-003-customer-dashboard.md
│
└── .claude-temp/                   # NOT tracked in git (add to .gitignore)
    └── handoff/
        └── epic-to-story.md        # Context for story-planner
```

**Important**: Add `.claude-temp/` to your `.gitignore`:
```gitignore
# Claude Code temporary files
.claude-temp/
```

## Epic Documentation Format

Each Epic file contains:

- **Overview**: Status, priority, effort estimate
- **Business Value**: Why this matters
- **Success Metrics**: How to measure success
- **Description**: Detailed scope
- **Acceptance Criteria**: Must/Should/Could have requirements
- **User Stories**: High-level story breakdown
- **Dependencies**: Links to other Epics using `[[EPIC-XXX]]`
- **Technical Considerations**: Architecture, security, tech stack
- **Risks & Mitigations**: What could go wrong
- **Out of Scope**: Explicit boundaries
- **Resources**: Docs, team members
- **Notes**: Additional context

## Working with Epic Documentation

### In Obsidian

The Epic files are optimized for Obsidian:
- `[[EPIC-XXX]]` links work for navigation
- Graph view shows Epic dependencies
- Tags and metadata support filtering
- Checkbox lists track progress

### In Your IDE

The markdown is readable in any editor:
- VSCode: Use markdown preview
- Preview checkboxes as you complete criteria
- Search across all Epics with grep/find

### For Team Collaboration

- Commit `./epics/` to git
- Team members can read/review
- Use PR process for Epic refinements
- Link to Epics in your issue tracker

## Tips for Better Results

### During the Interview

1. **Be Specific**: The more context you provide, the better the Epics
2. **Mention Constraints**: Budget, timeline, compliance requirements
3. **Describe Users**: Who will use this? What are their pain points?
4. **Share Concerns**: Security, scalability, performance worries
5. **Ask Questions**: If Agile concepts are unclear, ask for explanation

### For Existing Codebases

1. **Point Out Key Files**: "The auth system is in src/auth/"
2. **Mention Pain Points**: "The database queries are slow"
3. **Share Technical Debt**: "We need to upgrade from React 16"
4. **Identify Patterns**: "We use Redux for state management"

### For New Projects

1. **Describe Similar Systems**: "Like Spotify but for podcasts"
2. **Share Inspiration**: "I want features similar to X"
3. **Clarify Scale**: "Starting with 100 users, plan for 10k"
4. **Technology Preferences**: "We want to use Python/FastAPI"

## Common Patterns

### Starting a New Project

```
epic-planner: I want to build a SaaS platform for freelance designers
to manage client projects and invoices. Target 1000 users in year one.
```

Agent will:
- Ask about designer workflows
- Understand invoicing requirements
- Identify integrations (Stripe, etc.)
- Propose 5-8 foundational Epics
- Create security-first architecture

### Adding Features to Existing System

```
epic-planner: I need to add team collaboration features to my project
management app. Current stack: React, Node.js, PostgreSQL.
```

Agent will:
- Scan existing codebase
- Understand current patterns
- Identify security gaps
- Propose Epics that align with architecture
- Flag refactoring needs first

### Addressing Technical Debt

```
epic-planner: My app has performance issues and security vulnerabilities.
Help me plan a refactoring initiative.
```

Agent will:
- Deep security audit
- Performance analysis
- Prioritize critical fixes
- Create remediation Epics
- Sequence work to minimize disruption

## Iterative Refinement

The epic-planner works iteratively. You can:

### Resume Planning Session

```
Continue epic planning for [project] - let's add an Epic for reporting
```

### Refine Specific Epic

```
I need to revise EPIC-003. The scope was too large.
```

### Add Missing Epics

```
We forgot about email notifications. Can you create an Epic for that?
```

### Adjust Priorities

```
EPIC-002 should be higher priority than EPIC-003 based on customer feedback
```

## Handoff to Story Planning

After Epic planning completes:

```
Use story-planner to break down EPIC-001
```

The story-planner subagent (to be created) will:
- Read the Epic documentation
- Read `.claude-temp/handoff/epic-to-story.md` for context
- Interview you about story-level details
- Create Story documentation in `./stories/`
- Prepare handoff for task-planner

## Development Process (Meta)

### How This Agent Was Created

1. **Requirements Gathering**
   - Interview with user about orchestrator needs
   - Clarified scope: Epic-level only
   - Defined interaction model: iterative
   - Established output format: Obsidian markdown

2. **Design Decisions**
   - **Model**: Sonnet for strong reasoning
   - **Tools**: Read, Grep, Glob, Write, Bash
   - **Permission**: Default (ask before writing)
   - **Scope**: User-level (`~/.claude/agents/`)

3. **Prompt Engineering**
   - Structured interview phases with time targets
   - Security-first mandate
   - Comprehensive Epic template
   - Handoff system for downstream agents
   - Quality checklist and anti-patterns

4. **Testing Plan** (next step)
   - Test on new project (no codebase)
   - Test on existing project (with security issues)
   - Test iterative refinement
   - Verify handoff format works for story-planner

### Iterating on This Agent

To improve the epic-planner:

1. **Edit the agent file**:
   ```
   /agents
   ```
   Select `epic-planner` → Edit

2. **Test changes**:
   ```
   Use epic-planner on a test project
   ```

3. **Common adjustments**:
   - Interview question templates
   - Epic markdown structure
   - Handoff format
   - Tool restrictions
   - Security scanning patterns

4. **Version control** (optional):
   - Copy from `~/.claude/agents/` to project `.claude/agents/`
   - Commit project version to git
   - Share with team

### Creating Related Subagents

**story-planner** (next to create):
```yaml
name: story-planner
description: Breaks Epics into User Stories with acceptance criteria
tools: Read, Write, Grep, Glob
model: sonnet
```

**task-planner** (after story-planner):
```yaml
name: task-planner
description: Breaks Stories into actionable development tasks
tools: Read, Write, Grep, Glob, Bash
model: sonnet
```

**epic-reviewer** (optional):
```yaml
name: epic-reviewer
description: Reviews Epic documentation for completeness and quality
tools: Read, Grep, Glob
model: sonnet
```

### Integration with CI/CD (Future)

When your planning process matures:

1. **Git Hooks**: Validate Epic format on commit
2. **MCP Integration**: Sync to Jira/Linear/GitHub Projects
3. **Automated Metrics**: Track Epic completion rates
4. **Template Validation**: Ensure all required sections present

## Troubleshooting

### Agent Not Appearing

**Problem**: `/agents` doesn't show epic-planner

**Solution**:
- Check file exists: `ls ~/.claude/agents/epic-planner.md`
- Restart Claude Code session
- Verify YAML frontmatter is valid

### Agent Produces Wrong Output

**Problem**: Epics are too small/large or missing sections

**Solution**:
- Review the Epic template in agent prompt
- Add examples of good Epics to agent prompt
- Adjust interview questions to gather needed info

### Handoff File Not Created

**Problem**: `.claude-temp/handoff/epic-to-story.md` missing

**Solution**:
- Check agent has Write permissions
- Verify directory creation in agent prompt
- Ensure agent completes full workflow

### Security Scan Misses Issues

**Problem**: Agent doesn't find known vulnerabilities

**Solution**:
- Add specific search patterns to agent prompt
- Expand security checklist section
- Consider adding MCP tool for security scanning

## Best Practices

1. **One Project at a Time**: Don't switch projects mid-planning
2. **Complete the Interview**: Don't rush the 15-minute process
3. **Review Output**: Check Epic files before moving to Stories
4. **Commit Often**: Save Epic documentation to git regularly
5. **Update as Needed**: Epics evolve - keep documentation current
6. **Team Alignment**: Review Epics with stakeholders before breakdown

## Example Session

```
You: Use epic-planner to plan a Chrome extension for productivity tracking

Agent: Great! I'll help you plan this Chrome extension. Let me start with
some questions to understand your vision (~15 min interview).

First, tell me about the productivity problem you're solving. Who will use
this extension and what pain points do they have?

You: It's for remote workers who struggle to focus. Track time on websites
and apps, get insights on productivity patterns, block distracting sites.

Agent: Excellent context. A few follow-up questions:

1. What defines a "productive" vs "distracting" site? User-defined or
   algorithm-based?
2. Should data stay local or sync across devices?
3. Any privacy concerns? (productivity data is sensitive)
4. Monetization model? Free, freemium, paid?

[Interview continues...]

Agent: Based on our discussion, I recommend 6 Epics:

1. EPIC-001: Security & Privacy Foundation (MUST DO FIRST)
   - Chrome extension permissions model
   - Encrypted local storage
   - Privacy policy & data handling

2. EPIC-002: Time Tracking Core
   - Track active time per site/app
   - Categorize activity (work/distraction/neutral)
   - Local data storage

3. EPIC-003: Productivity Insights Dashboard
   - Daily/weekly summaries
   - Productivity score algorithm
   - Trend visualization

[More Epics...]

Does this breakdown make sense? Any Epics missing or need adjustment?

You: Looks good, but I also need website blocking functionality

Agent: Excellent point. Let me add:

EPIC-004: Focus Mode & Website Blocking
- Block distracting sites during focus sessions
- Pomodoro timer integration
- Whitelist/blacklist management

I'll create the full documentation now...

[Agent creates Epic files]

Agent: ✅ Created 6 Epics in ./epics/

I recommend starting with EPIC-001 (Security & Privacy Foundation) since
Chrome extensions require careful permission management.

Ready to break down EPIC-001 into Stories? I can call the story-planner
subagent.
```

## Next Steps

1. **Test the agent**: Try it on a real project
2. **Iterate on prompts**: Refine based on outputs
3. **Create story-planner**: Next subagent in the chain
4. **Build your workflow**: Epic → Story → Task → Implementation

---

**Remember**: This is a living document. Update it as you learn what works best for your planning process.