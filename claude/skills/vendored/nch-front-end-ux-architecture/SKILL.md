---
name: ux-ui-architecture
description: Design or evaluate UX/UI systems with a frontend-architect lens. Use when creating, critiquing, or refining interface architecture, user flows, information architecture, system state handling, interaction patterns, and structural UX decisions. Focus on intuitive, scalable, highly polished interfaces without discussing backend, code, or frameworks.
argument-hint: [feature, flow, screen, or UI critique target]
# --- vendored-provenance (managed by bin/skill-add) ---
source: https://github.com/ncharris93/ai-docs
source_path: skills/nch-front-end-ux-architecture/SKILL.md
source_commit: dc6cebb14cb5a13ff60d2614c6e9b182ed5619f9
license: UNKNOWN
vendored: 2026-06-03
# --- end vendored-provenance ---
---

# UX/UI Interface Architecture SOP

## Purpose

Design or evaluate interface systems so they are intuitive, state-complete, scalable, and easy to operate without explanation.

This skill is for interface architecture only:
- user goals
- user flows
- information architecture
- system state modeling
- UI structure
- interaction design
- structural critique

Exclude:
- backend design
- technical implementation
- frameworks
- code
- purely aesthetic commentary unless it affects clarity or usability

---

## Operating Stance

Think like a frontend architect, not a decorator.

Prioritize:
- structure over ornament
- usability over novelty
- explicitness over assumption
- user understanding over internal system organization

Be slightly opinionated. Do not give vague design advice. Tie every recommendation to user clarity, task flow, state visibility, or cognitive load.

---

## Core Decision Model

Resolve all interface reasoning through this chain:

### 1. User Intent
What is the user trying to accomplish right now?

Do not anchor on features.  
Anchor on the user's goal.

### 2. System State
What must the interface represent so the user can safely understand and complete that goal?

Always consider:
- default
- loading
- empty
- error
- success
- transitional / in-progress
- partial / blocked / permission / first-use states when relevant

### 3. UI Representation
How is that state clearly and intuitively expressed?

If intent, system state, and UI representation do not map cleanly, the architecture is weak and must be revised.

---

## Non-Negotiable Principles

### Clarity over cleverness
The interface should make sense immediately. Do not reward interpretation.

### Mental model alignment
Group, label, and sequence based on how users think, not how the system is internally organized.

### Consistency and predictability
Similar interactions and patterns should behave the same way across the system.

### Explicit state handling
Never hide or imply meaningful state. Users should not have to infer loading, failure, emptiness, or progress.

### Conceptual composability
Screens, sections, and components should each have one clear responsibility.

### Progressive disclosure
Reveal complexity only when needed. Do not front-load every option.

### Accessibility and usability first
Readable, navigable, and forgiving beats visually sparse but ambiguous.

---

## Active Heuristics

Apply these throughout the analysis or design process:

- **Visibility of system status** — users should always know what is happening
- **Immediate and clear feedback** — actions must produce visible response
- **Error prevention and recovery** — avoid mistakes first, then make recovery obvious
- **Recognition over recall** — show what users need instead of making them remember
- **Consistency and standards** — repeated patterns should mean repeated behavior
- **Minimal cognitive load** — reduce ambiguity, decision fatigue, and scanning cost

---

# Execution Process

Use this structure whether designing from scratch or critiquing an existing UI.

## 1. User Goals

Define what users are actually trying to achieve.

Rules:
- express goals as outcomes, not features
- separate primary from secondary goals
- identify high-frequency goals
- identify failure-sensitive goals

Good:
- Find the right record quickly
- Compare options confidently
- Complete an action without losing context
- Recover from a mistake without confusion

Bad:
- Use filter panel
- Click submit button
- View dashboard widgets

---

## 2. User Flows

Map the step-by-step journey to each goal.

Include:
- entry points
- main path
- alternate paths
- branching logic
- edge cases
- failure points
- recovery paths
- moments of hesitation or context switching

Rules:
- optimize for the dominant path
- do not ignore edge conditions
- separate the user journey from internal business process

---

## 3. Information Architecture

Determine how the interface should be structured and grouped.

Ask:
- what must be understood first?
- what belongs together?
- what is primary versus secondary?
- what is global versus contextual?
- what should remain persistent?
- what should appear only when relevant?

Rules:
- hierarchy should reflect task importance
- grouping should reflect user understanding
- avoid flat layouts where everything competes equally
- avoid organizing the UI around implementation details

---

## 4. System State Model

List every meaningful state before judging or proposing the UI.

Minimum states:
- default
- loading
- empty
- success
- error
- transitional / saving / processing

Additional states when relevant:
- first-use
- no-permission
- read-only
- validation failure
- partial data
- stale data
- blocked / dependency missing

Rules:
- every meaningful state must be visible in the UI
- every state should communicate user meaning, not just technical status
- transitions should be legible, not implicit

Bad:
- blank regions standing in for loading
- missing content standing in for empty
- silent failures
- toast-only handling for major errors

Good:
- explicit state containers with clear explanation and next actions

---

## 5. UI Architecture Breakdown

Break the interface into three layers:

### Screens
Distinct contexts with distinct user intent.

### Sections
Functional groupings within a screen.

### Components
Conceptual building blocks with a single clear responsibility.

Rules:
- each layer must have a clear job
- screens should not mix unrelated intents
- sections should not blend unrelated tasks
- components should not become “god” objects with multiple competing responsibilities
- naming should reflect user meaning, not implementation language

---

## 6. Interaction Patterns

Define how users act and how the system responds.

Include:
- action triggers
- immediate feedback
- validation behavior
- confirmation behavior
- undo or retry patterns
- destructive-action safeguards
- navigation behavior
- consistency across similar tasks

Rules:
- similar actions should yield similar responses
- destructive actions need stronger clarity and protection
- frequent actions should be streamlined
- irreversible outcomes must be explicit beforehand
- disabled states must explain why action is unavailable

---

## 7. Tradeoffs and Alternatives

For major design decisions, state:
- what was chosen
- why it was chosen
- what was rejected
- what tradeoff was accepted

This prevents shallow critique and makes design intent visible.

Examples:
- Chose progressive disclosure over single-screen density to reduce overwhelm
- Chose dedicated empty states over generic placeholders to improve first-use comprehension
- Rejected tab overload because the views represented different modes, not sibling content

---

## 8. Issues and Improvements

When critiquing, classify problems clearly.

### Structural issues
Weak hierarchy, poor grouping, mixed responsibilities, unclear screen purpose

### State issues
Missing, hidden, ambiguous, or under-expressed states

### Interaction issues
Inconsistent actions, weak feedback, poor recovery, unclear consequences

### Cognitive load issues
Too many choices, weak prioritization, scattered context, poor scanability

### Mental model issues
UI shaped around internal system structure rather than user goals

For every issue, state:
- what is wrong
- why it matters
- what should change

Do not say:
- “this feels confusing”

Say:
- “The primary action is buried in a secondary region, which weakens task progression; move it into the main action zone and demote secondary utilities.”

---

# Structuring Standards

## Components
- one clear responsibility
- no hidden cross-purpose behavior
- no mixed meanings in a single pattern

## Grouping
- group by task meaning, not by data origin
- related actions should sit near related information
- avoid arbitrary sections with no behavioral logic

## Naming
- use user-facing language
- labels should describe intent, not internal mechanics
- avoid vague group names unless scope is unmistakable

## Hierarchy
- primary information should read as primary
- primary action should be obvious
- secondary elements should not compete with core task flow
- scan order should match task order

## State Expression
- do not use absence to communicate meaning
- loading, empty, and error must be visually distinct
- success should confirm what happened and what comes next

---

# Review Checklist

Before finalizing, verify:

- Is the interface understandable without explanation?
- Does the structure reflect user goals rather than internal system organization?
- Is hierarchy obvious on first scan?
- Are all meaningful states explicitly handled?
- Are interactions consistent across similar contexts?
- Are edge cases and recovery paths accounted for?
- Is cognitive load minimized at each step?
- Does each screen and section have one clear purpose?
- Does the UI support recognition rather than memory?
- Is the primary path efficient without making edge paths brittle?

---

# Common Anti-Patterns

## Overloaded components
One area trying to handle status, actions, explanation, configuration, and history all at once.

## Flat hierarchy
Everything gets equal weight, so nothing feels important.

## Hidden system state
The system is loading, saving, failing, blocked, or incomplete, but the user cannot tell.

## Inconsistent interaction patterns
The same kind of action behaves differently across screens.

## Over-abstraction
Reusable structure that weakens clarity and hides meaning.

## System-shaped UI
The interface mirrors internal architecture rather than user goals.

## Premature density
Too much exposed too early, with no staged reveal.

## Action ambiguity
Users cannot predict what will happen before acting.

---

# Response Structure

Always produce output in this order.

## 1. User Goals
- Primary goals
- Secondary goals
- Failure-sensitive goals

## 2. User Flows
- Main flow
- Alternate flows
- Edge cases
- Friction points

## 3. Information Architecture
- Global structure
- Hierarchy
- Grouping rationale

## 4. System State Model
- Default
- Loading
- Empty
- Error
- Success
- Transitional
- Special states

## 5. UI Architecture Breakdown
- Screens
- Sections
- Conceptual components
- Responsibility boundaries

## 6. Interaction Patterns
- Key actions
- Feedback loops
- Validation behavior
- Recovery patterns
- Navigation model

## 7. Tradeoffs & Alternatives
- Chosen direction
- Rejected options
- Accepted tradeoffs

## 8. Issues & Improvements
- Structural
- State handling
- Interaction
- Cognitive load
- Mental model alignment

## 9. Final Polished Architecture Summary
- Core screens
- Key components
- State handling model
- Interaction model

---

# Output Template

Use this exact shape in responses.

## User Goals
**Primary**
- [goal]
- [goal]

**Secondary**
- [goal]
- [goal]

**Failure-Sensitive**
- [goal]
- [goal]

## User Flows
**Main Flow**
1. [step]
2. [step]
3. [step]

**Alternate / Edge Flows**
- [branch]
- [branch]

**Friction Points**
- [friction]
- [friction]

## Information Architecture
**Global Structure**
- [area]
- [area]

**Hierarchy**
- Primary: [content/actions]
- Secondary: [content/actions]
- Contextual: [content/actions]

**Grouping Notes**
- [why this grouping matches user mental model]

## System State Model
**Core States**
- Default: [representation]
- Loading: [representation]
- Empty: [representation]
- Error: [representation]
- Success: [representation]
- Transitional: [representation]

**Special States**
- [permission/read-only/first-use/partial-data/etc.]

## UI Architecture Breakdown
**Screens**
- [screen] — [purpose]
- [screen] — [purpose]

**Sections**
- [section] — [responsibility]
- [section] — [responsibility]

**Conceptual Components**
- [component] — [single responsibility]
- [component] — [single responsibility]

## Interaction Patterns
- [action] → [feedback]
- [action] → [feedback]
- [validation/recovery/undo pattern]

## Tradeoffs & Alternatives
- Chose [x] because [reason]
- Rejected [y] because [reason]
- Accepted [tradeoff] in order to [benefit]

## Issues & Improvements
**Structural**
- [issue] → [improvement]

**State Handling**
- [issue] → [improvement]

**Interaction**
- [issue] → [improvement]

**Cognitive Load**
- [issue] → [improvement]

**Mental Model**
- [issue] → [improvement]

## Final Polished Architecture Summary
**Core Screens**
- [screen]
- [screen]

**Key Components**
- [component]
- [component]

**State Handling Model**
- [summary]

**Interaction Model**
- [summary]

---

# Final Polished Architecture Summary

This skill should produce UX/UI architecture output that is:
- organized around user intent rather than feature inventory
- explicit about system state rather than assumption-driven
- structured into clear screens, sections, and conceptual components
- consistent in interaction behavior
- scalable without becoming structurally muddy
- suitable for handoff to a design or product team

The governing model is fixed:

**User Intent defines the goal.**  
**System State defines what must be communicated.**  
**UI Representation defines how that meaning becomes obvious and usable.**

That is the backbone.

Use this skill to design or critique interfaces that are intuitive, state-complete, and structurally rigorous.
