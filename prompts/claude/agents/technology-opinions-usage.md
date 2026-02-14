# Technology Opinions - Usage Guide & Development Process

## Quick Start

### Initial Setup

```
Use technology-opinions to set up my preferences
```

**What happens**:
- Agent conducts comprehensive ~20-30 minute interview
- Covers 12 categories of SaaS development technology
- Creates `~/.claude/tech-opinions.md` in your home directory
- File is human-readable (Obsidian-compatible) and machine-parseable

### Adding Opinions Later

```
technology-opinions: Add opinion - prefer Zustand for state management

technology-opinions: Update opinion about testing frameworks

technology-opinions: Re-run full interview
```

### Querying Opinions

**Direct (by other agents)**:
```
# In any agent that needs tech preferences
Read ~/.claude/tech-opinions.md
Search for relevant section
Use documented preference
```

**Via agent invocation**:
```
technology-opinions: Query - what's our authentication preference?
```

## File Location

`~/.claude/tech-opinions.md`

This is a **global file** stored in your home directory:
- Accessible across **all projects**
- One source of truth for your technology preferences
- Can be version controlled separately (recommended)
- Human-editable - your manual changes are authoritative

**Recommended**: Track in git
```bash
cd ~/.claude
git init
git add tech-opinions.md
git commit -m "Initial technology opinions"
```

## File Format

The file uses markdown with YAML frontmatter:

```markdown
---
version: 1.0.0
created: 2026-02-01
last_updated: 2026-02-01
---

# Technology Opinions

[12 sections covering all aspects of SaaS development]

## Languages & Runtime
### Backend Language
**Preference**: Strongly prefer
**Choice**: TypeScript
**Rationale**: Type safety reduces bugs
**Context**: For new projects

[... more sections ...]
```

**Format Benefits**:
- Human-readable in any text editor
- Beautiful in Obsidian
- Machine-parseable by agents
- Easy to search with grep/find
- Version control friendly

## Opinion Strength Levels

Every opinion has a strength level:

### Must use
- **Required** - no exceptions
- Example: "Must use TypeScript - company standard"
- Use for: Company policies, team agreements, compliance requirements

### Strongly prefer
- **Default choice** unless compelling reason otherwise
- Example: "Strongly prefer React - team expertise"
- Use for: Technologies you know well, proven choices

### Prefer
- **Slight preference** - open to alternatives
- Example: "Prefer Vitest over Jest - faster"
- Use for: When you like something but alternatives are acceptable

### No preference
- **Either option is fine**
- Example: "CSS-in-JS vs CSS Modules - no preference"
- Use for: Genuinely don't care, haven't formed opinion yet

### Avoid
- **Don't use unless absolutely necessary**
- Example: "Avoid jQuery in new projects - outdated"
- Use for: Technologies you want to phase out

### Never
- **Prohibited** - security or quality concerns
- Example: "Never use eval() - security risk"
- Use for: Dangerous patterns, deprecated APIs

## Initial Interview

The first time you run technology-opinions, expect a comprehensive interview:

### Interview Flow

**Duration**: ~20-30 minutes
**Categories**: 12 major areas
**Questions**: ~40-60 questions total

**Interview Structure**:
1. **Languages & Runtime** (~3 min)
   - Backend language preferences
   - Frontend language preferences
   - Languages to avoid

2. **Frontend Framework & Tooling** (~4 min)
   - Framework choice (React, Vue, etc.)
   - State management
   - CSS approach
   - Build tools

3. **Backend Framework & API Style** (~3 min)
   - Backend framework
   - API architecture (REST, GraphQL)
   - Monolith vs microservices

4. **Database & Data Layer** (~4 min)
   - Database preference
   - ORM/query builder
   - Caching strategy
   - Migrations

5. **Testing Philosophy & Tools** (~4 min)
   - TDD vs test-after
   - Unit test framework
   - Integration testing
   - E2E testing
   - Testing practices

6. **Authentication & Authorization** (~3 min)
   - Auth solution (Supabase, Auth0, etc.)
   - Session management
   - OAuth providers

7. **Deployment & Infrastructure** (~3 min)
   - Frontend hosting
   - Backend hosting
   - Containers (Docker)
   - CI/CD platform

8. **Code Style & Architecture** (~3 min)
   - Programming paradigm
   - Architecture patterns
   - Code formatting
   - File organization
   - Error handling

9. **Third-Party Services** (~3 min)
   - Payments
   - Email
   - File storage
   - Monitoring
   - Analytics

10. **Git Workflow & Version Control** (~3 min)
    - Branching strategy
    - Commit conventions
    - Code review process
    - Merge strategy

11. **Dependency Management** (~3 min)
    - Package manager
    - When to add dependencies
    - Evaluation criteria
    - Version strategy

12. **Software Stability Preferences** (~3 min)
    - Stable vs bleeding edge
    - Framework updates approach
    - Version pinning strategy

### Sample Interview Questions

**Example 1: Frontend Framework**
```
Agent: "Which frontend framework do you prefer for SaaS applications?"

You: "React"

Agent: "What strength level for this preference?
1. Must use (required)
2. Strongly prefer (default unless compelling reason)
3. Prefer (slight preference)
4. No preference
5. Avoid
6. Never"

You: "Strongly prefer"

Agent: "Any rationale to capture? (Optional, but helps other agents understand)"

You: "Large ecosystem, team expertise, good TypeScript support"

Agent: "Got it. For React specifically, do you prefer functional components
with hooks or class components?"

You: "Functional with hooks"

Agent: "Documented:
### Frontend Framework
**Preference**: Strongly prefer
**Choice**: React (functional components with hooks)
**Rationale**: Large ecosystem, team expertise, TypeScript support
**Context**: Class components discouraged for new code

Moving to state management..."
```

**Example 2: No Preference**
```
Agent: "Do you have a preference for CSS approach? Options include Tailwind,
CSS-in-JS like styled-components, CSS Modules, or Sass?"

You: "No preference - I'm open to whatever works"

Agent: "That's perfectly fine. I'll document 'No preference' and you can
add an opinion later if you form one. You can also let project context
decide on a case-by-case basis."

[Documents: "No preference" - no rationale needed]
```

**Example 3: Avoid with Rationale**
```
Agent: "Are there any testing practices you actively avoid?"

You: "Yes - mocking internal functions"

Agent: "What strength level?
[Shows options]"

You: "Avoid"

Agent: "Why do you avoid this practice?"

You: "Tests become brittle and coupled to implementation details"

Agent: "Documented:
### Testing Practices to Avoid
**Preference**: Avoid
**Choice**: Mocking internal functions
**Rationale**: Tests become brittle, coupled to implementation
**Context**: Mock external APIs and services only

Great. Moving to authentication..."
```

## Adding Opinions After Setup

### Quick Add

**Use when**: You want to add one specific opinion

```
User: technology-opinions: Add opinion - prefer Playwright for E2E testing

Agent: Reading tech-opinions.md...

Current E2E testing opinion: No preference

What strength level for Playwright?
1. Must use
2. Strongly prefer
3. Prefer

User: Strongly prefer

Agent: Rationale? (optional)

User: Cross-browser support and great debugging

Agent: ✅ Updated tech-opinions.md:

### E2E Testing
**Preference**: Strongly prefer
**Choice**: Playwright
**Rationale**: Cross-browser support, great debugging tools
**Context**: Write E2E tests for critical user journeys only

Last updated: 2026-02-01
```

**Conflict Detection**:
```
User: technology-opinions: Add opinion - prefer Jest for unit testing

Agent: Reading tech-opinions.md...

⚠️ Conflict detected:
Current opinion: Prefer Vitest
New opinion: Prefer Jest

Options:
1. Replace Vitest with Jest
2. Keep Vitest, discard Jest
3. Add Jest as alternative
4. Update to "No preference" between both

User: Replace with Jest

Agent: ✅ Updated:

### Unit Testing Framework
**Preference**: Prefer
**Choice**: Jest
**Rationale**: [captures rationale if provided]

Old preference (Vitest) removed.
Last updated: 2026-02-01
```

### Targeted Update

**Use when**: You want to modify an existing opinion

```
User: technology-opinions: Update opinion about state management

Agent: Current state management opinion:

**Preference**: Prefer
**Choice**: Zustand
**Rationale**: Simpler API than Redux, smaller bundle size
**Context**: For simple to moderate state. Use Redux for very complex state.

What would you like to change?

User: Change to Strongly prefer

Agent: ✅ Updated:

**Preference**: Strongly prefer
[Rest stays the same]

Last updated: 2026-02-01
```

### Full Re-Interview

**Use when**: You want to review all opinions, maybe technologies have changed

```
User: technology-opinions: Re-run interview

Agent: I'll go through all categories again, showing your current preferences.
You can keep them or update them.

This will take ~20-30 minutes. Ready?

User: Yes

Agent: [Category 1: Languages & Runtime]

Current backend language preference: Strongly prefer TypeScript
Keep this or change?

User: Keep

Agent: Current frontend language: Must use TypeScript
Keep this or change?

User: Keep

[Continues through all categories...]

Agent: ✅ Interview complete. Updated 5 preferences, kept 29 unchanged.

Last updated: 2026-02-01
```

## How Other Agents Use This

### Direct File Read (Most Common)

Agents can directly read the file for simple queries:

```markdown
# Example: task-planner needs to know testing framework

1. Check if ~/.claude/tech-opinions.md exists
2. If yes, read file
3. Search for "Unit Testing Framework" section
4. Extract:
   - Preference: Prefer
   - Choice: Vitest
   - Rationale: Faster than Jest, native ESM support
5. Use Vitest in task creation
6. If no opinion found, report "no preference documented"
```

**Advantages**:
- Fast (no agent invocation overhead)
- Simple (straightforward file read)
- Token-efficient (only reads relevant section)

### Agent Invocation (Complex Queries)

For interpretation or complex scenarios:

```
task-planner: technology-opinions - Query: authentication preference and why?

technology-opinions agent:
Reads ~/.claude/tech-opinions.md
Finds: Authentication & Authorization section

Returns:
"Authentication preference: Strongly prefer Supabase Auth

Rationale: Built-in, secure, handles complex flows, good DX
Context: For new SaaS applications with standard auth needs
Session management: JWT with refresh tokens

This is a strong preference - use Supabase unless Epic specifies otherwise."
```

### When No Opinion Exists

**Critical**: Agent never hallucinates

```
task-planner: Needs to know WebSocket library preference

Reads tech-opinions.md → No WebSocket opinion found

task-planner reports to user:
"No opinion documented for WebSocket libraries.

Options:
1. Add opinion now (I can invoke technology-opinions agent)
2. I'll create a research task to evaluate options
3. I'll proceed without preference and choose based on codebase patterns

What would you like?"
```

## Conflict Resolution

When Epic/Story decisions conflict with documented opinions:

### Example Scenario

**Situation**:
- Tech opinions say: "Prefer REST"
- Epic-003 says: "Use GraphQL for customer dashboard API"

**How story-planner handles it**:
```
story-planner (reading EPIC-003):
Detects conflict with tech opinions

Flags to user:
"⚠️ Technology Conflict Detected

Epic EPIC-003 specifies: GraphQL API
Tech opinions document: Prefer REST

This appears to be a project-specific requirement that overrides
your general preference.

Options:
1. Proceed with GraphQL (Epic decision overrides general preference)
2. Revise Epic to use REST (follow general preference)
3. Add context to tech opinions about when GraphQL is appropriate

What would you like to do?"
```

**If user chooses option 3**:
```
User: Option 3 - add context

story-planner invokes technology-opinions agent:

technology-opinions: "I'll add context to the REST vs GraphQL opinion.

When should GraphQL be used instead of REST?"

User: "When there are complex data relationships and the frontend needs
to fetch from multiple entities efficiently"

technology-opinions: ✅ Updated tech-opinions.md:

### API Architecture
**Preference**: Prefer
**Choice**: REST
**Rationale**: Simple, well-understood, easy to debug
**Context**: Default for most APIs
**Exception**: Use GraphQL when:
  - Complex data relationships across many entities
  - Frontend needs flexible querying
  - Reducing number of API calls is critical

Last updated: 2026-02-01
```

## Common Use Cases

### Case 1: Starting a New Project

```
task-planner (working on new SaaS project):

1. Reads ~/.claude/tech-opinions.md
2. Extracts key preferences:
   - Language: TypeScript (Must use)
   - Frontend: React (Strongly prefer)
   - Backend: Express (Prefer)
   - Database: PostgreSQL (Strongly prefer)
   - Auth: Supabase (Strongly prefer)
3. Creates tasks using these technologies
4. Includes rationale in task documentation
5. No user intervention needed
```

### Case 2: Evaluating New Dependency

```
task-planner: Creating task that needs date manipulation library

Reads tech-opinions.md → Dependency Management section:
"Evaluation Criteria:
- Actively maintained (updated in last 6 months)
- Good documentation
- Bundle size impact
- No critical CVEs
- Compatible license (prefer MIT, Apache 2.0)
- At least 1.0.0 version"

task-planner creates research task:
"Evaluate date libraries (date-fns, dayjs, luxon) against criteria
from tech-opinions.md"
```

### Case 3: Git Workflow Question

```
epic-planner: Creating Epic, needs to know branching strategy

Reads tech-opinions.md → Git Workflow section:
"Branching Strategy: Strongly prefer GitHub Flow with dev/staging/main"

epic-planner: Documents in Epic technical notes:
"Follow standard branching: dev → staging → main per tech-opinions.md"
```

### Case 4: No Opinion Exists

```
task-planner: Needs to choose between WebSocket libraries

Reads tech-opinions.md → No WebSocket opinion found

task-planner:
"No preference documented for WebSocket libraries.

I found these options in research:
1. Socket.io (most popular)
2. Pusher (managed service)
3. Native WebSocket API

Would you like to:
A) Add a preference now
B) Create a research task to evaluate them
C) I'll use Socket.io (most common) and document the choice

?"

User: B - create research task

task-planner: Creates TASK-001: Research WebSocket library options
"After research, update tech-opinions.md with preference"
```

## Editing the File Manually

You can edit `~/.claude/tech-opinions.md` directly:

**Your edits are authoritative** - agents will respect manual changes.

### Adding a New Opinion Manually

```markdown
## Payment Processing

### Payment Provider
**Preference**: Strongly prefer
**Choice**: Stripe
**Rationale**: Best API, excellent docs, trusted
**Context**: Standard for SaaS billing
**Last Updated**: 2026-02-01
```

### Removing an Opinion

Just delete the section. Agents will treat it as "No preference".

### Updating an Opinion

Change any field:
- Preference strength
- Choice
- Rationale
- Context

**Remember to update**:
```yaml
---
last_updated: 2026-02-01  # Update this
---
```

## Version Control Workflow

**Recommended**: Track tech-opinions.md in git

```bash
# Initial setup
cd ~/.claude
git init
git add tech-opinions.md
git commit -m "Initial technology opinions"

# After updates
git add tech-opinions.md
git commit -m "Update state management preference to Zustand"

# View history
git log --oneline tech-opinions.md

# See what changed
git diff HEAD~1 tech-opinions.md
```

**Benefits**:
- Track evolution of preferences over time
- Understand why preferences changed
- Revert if needed
- Share with team (if appropriate)

## Troubleshooting

### File Not Found

**Problem**: Agents report "tech-opinions.md not found"

**Solution**:
```
technology-opinions: Set up my preferences
```
This creates the file with initial interview.

### Conflicting Opinions

**Problem**: Two opinions contradict each other

**Solution**:
```
technology-opinions: Update opinion about [topic]
```
Agent will show conflict and help resolve.

### Opinion Too Vague

**Problem**: Opinion exists but lacks context for agent to use properly

**Solution**: Edit manually or update via agent:
```
technology-opinions: Update [topic] opinion - add more context
```

### Can't Remember What's Documented

**Solution**: Just read the file
```
cat ~/.claude/tech-opinions.md
# Or in Obsidian, open ~/.claude/tech-opinions.md
```

## Best Practices

1. **Complete Initial Interview**: Don't skip categories - "No preference" is valid
2. **Capture Rationale**: Especially for strong opinions (Must/Avoid/Never)
3. **Update as You Learn**: Preferences evolve - update the file
4. **Version Control**: Track changes in git
5. **Review Periodically**: Every 6-12 months, re-review opinions
6. **Context Matters**: Add when/why opinions apply
7. **Team Alignment**: If working with team, align on shared opinions
8. **Override When Needed**: Opinions are guidelines, not laws

## Development Process (Meta)

### How This Agent Was Created

1. **Requirements Gathering**
   - Interview with user about technology-opinions needs
   - Clarified scope: Global preferences, query interface, never hallucinate
   - Defined interaction model: Comprehensive interview, quick updates
   - Established storage: ~/.claude/tech-opinions.md (durable, version-controlled)

2. **Design Decisions**
   - **Model**: Sonnet for nuanced interview questions
   - **Tools**: Read, Write, Edit (no codebase analysis needed)
   - **Permission**: Default (ask before writing)
   - **Scope**: Global, above project level

3. **Prompt Engineering**
   - Comprehensive 12-category interview structure
   - Opinion strength levels (Must/Strongly prefer/Prefer/No preference/Avoid/Never)
   - Never hallucinate principle - critical for trust
   - Conflict detection and resolution
   - Quick add, targeted update, full re-interview modes

4. **Integration Points**
   - Direct file read by other agents (token-efficient)
   - Agent invocation for complex queries
   - Conflict flagging when Epic/Story overrides opinions

### Iterating on This Agent

To improve the technology-opinions agent:

1. **Edit the agent file**:
   ```
   Read and edit: agents/technology-opinions.md
   ```

2. **Test changes**:
   ```
   Use technology-opinions to set up preferences (fresh start)
   ```

3. **Common adjustments**:
   - Interview questions (add/remove/refine)
   - Opinion categories (new technologies emerge)
   - File format (improve parseability)
   - Conflict resolution logic

4. **Version control**:
   - Commit changes to this prompts repository
   - Deploy to `~/.claude/agents/` for use

## Integration with Other Agents

### epic-planner
```
When creating Epics with technical components:
- Reads tech-opinions.md for architecture preferences
- Uses documented patterns in technical considerations section
- Flags if Epic requires different tech than opinions
```

### story-planner
```
When breaking down stories:
- Reads tech-opinions.md for framework/library choices
- Includes in technical implementation notes
- Flags conflicts between story needs and opinions
```

### task-planner
```
When creating tasks:
- Reads tech-opinions.md for specific implementation choices
- Uses documented testing preferences for test tasks
- Creates research tasks when no opinion exists
- Never guesses - reports "no preference documented"
```

## Example Session

```
You: technology-opinions: Set up my preferences

Agent: I'll conduct a comprehensive interview to capture your technology
preferences for SaaS development. This will take about 20-30 minutes and
create a file at ~/.claude/tech-opinions.md that other agents can consult.

If you don't have a preference on something, I'll document "No preference"
rather than assuming. You can always add opinions later.

Ready to begin?

You: Yes

Agent: [Category 1 - Languages & Runtime]

What programming language do you prefer for backend development?

You: TypeScript

Agent: What strength level?
1. Must use (required)
2. Strongly prefer (default unless compelling reason)
3. Prefer (slight preference)

You: Must use

Agent: Rationale?

You: Company standard for all projects

Agent: Got it. For frontend, TypeScript as well?

You: Yes, also must use

[Interview continues through all 12 categories...]

Agent: [30 minutes later]

✅ Technology opinions captured in ~/.claude/tech-opinions.md

Summary:
- 12 categories covered
- 38 specific preferences documented
- 6 "No preference" items
- File is ready for version control

Other agents can now query this file when making technical decisions.

Recommended next step:
cd ~/.claude && git init && git add tech-opinions.md && git commit -m "Initial technology opinions"
```

## Next Steps

1. **Run initial interview**: Set up your preferences
2. **Version control**: Track the file in git
3. **Test with agents**: See how task-planner uses your opinions
4. **Update as needed**: Add preferences when you form new opinions
5. **Review periodically**: Keep opinions current with your learning

---

**Remember**: This file is your personal tech philosophy documented. It helps agents make decisions autonomously while staying aligned with your preferences.
