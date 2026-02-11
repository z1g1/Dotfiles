# Copy Review Agent Improvements

Notes on what the copy-review agent needs to deliver deep, strategic B2C SaaS website reviews rather than surface-level grammar cleanup.

## Missing Repo Context (What the Agent Needs as Input)

### 1. Customer & Market Context

- **Ideal Customer Profile (ICP)** — Who is the actual buyer? What motivates them? What are their objections? Without this, the agent can't evaluate whether copy resonates with the target audience.
- **Competitive positioning** — How does the product compare to alternatives (including "doing nothing")? Without this, the agent can't assess whether copy is differentiated.
- **Customer voice data** — Actual quotes from users, support tickets, survey responses. The best copy mirrors the language customers already use to describe their problems.
- **Stage of awareness** — Are visitors arriving cold (don't know the problem exists), problem-aware, or solution-aware? This fundamentally changes what the homepage needs to say first.

### 2. Business & Conversion Goals

- **Primary conversion goal per page** — The agent can't evaluate CTA effectiveness without knowing what "effective" means for each page (waitlist signups, paid subscriptions, email captures, etc.).
- **Funnel structure** — What's the intended visitor journey? Without this, the agent can't evaluate page flow or whether copy guides users forward through the funnel.
- **Pricing strategy rationale** — The agent needs to understand the pricing story to evaluate whether the copy supports it (e.g., $17.76 anchored to 1776, free tier as freemium vs. beta artifact).

### 3. Brand & Messaging Foundation

- **Brand voice guidelines** — Beyond "professional," what's the voice? Empowering? Urgent? Patriotic? Approachable? Without this, the agent can't distinguish intentional tone mixing from inconsistency.
- **Messaging hierarchy** — What's the single most important takeaway for a visitor? What's the #1 value prop, #2, #3? Without this, every heading gets equal weight in review.
- **Positioning statement** — Something like: *"For [target user] who [problem], [Product] is [category] that [key benefit] unlike [alternatives] because [differentiator]."*

### 4. Visual & Rendered Context

- **The agent can't see the actual site** — It reads source code, not the rendered page. It can't evaluate visual hierarchy, whitespace, how text pairs with images, whether CTAs are above the fold, or how the page feels on mobile vs desktop.
- **No screenshot/recording access** — A deep review needs to see the page as a user sees it.

## Agent Capability Gaps

| Gap | What it would enable |
|-----|---------------------|
| No web access | Can't pull competitor sites, benchmark against best-in-class B2C SaaS pages, or check live site rendering |
| No framework application | Doesn't apply proven frameworks (StoryBrand, JTBD, PAS/AIDA, Cialdini's principles) — it pattern-matches grammar, not persuasion structure |
| No page-flow analysis | Reviews each file in isolation; can't evaluate whether the sequence of pages tells a coherent story |
| No emotional arc analysis | Doesn't evaluate whether copy moves the reader through problem → agitation → solution → trust → action |
| B2B vs B2C confusion | Agent defaults to B2B but B2C reviews have fundamentally different criteria (more emotional, story-driven, lower-friction CTAs) |
| No conversion heuristic scoring | Can't score pages on established frameworks like the MECLabs conversion heuristic (Motivation → Value Prop → Friction → Anxiety) |

## Recommended: Messaging Brief as Input

To enable a deep B2C review, the repo should include a messaging brief that the agent can reference. Key fields:

1. **Target user** and their #1 pain point in their own words
2. **Primary conversion action** per page
3. **3 key differentiators** vs. alternatives (including inaction)
4. **Brand voice** in 3-5 adjectives with examples
5. **Stage of company** (beta, launched, scaling) — this changes what social proof is available/expected

With this context plus instructions to review as B2C and apply a persuasion framework like PAS (Problem-Agitation-Solution), the review would shift from "fix this comma" to "this page doesn't establish the problem before presenting the solution, so visitors bounce."

## Frameworks the Agent Should Apply

- **PAS (Problem-Agitation-Solution)** — Does each page establish the problem, agitate it, then present the solution?
- **StoryBrand** — Is the customer the hero? Is the product the guide? Is there a clear plan and call to action?
- **JTBD (Jobs to Be Done)** — Does the copy address the job the customer is hiring the product to do?
- **AIDA (Attention-Interest-Desire-Action)** — Does the page flow follow this progression?
- **Cialdini's Principles** — Does the copy leverage reciprocity, social proof, authority, scarcity, liking, and commitment?
- **MECLabs Conversion Heuristic** — C = 4M + 3V + 2(I-F) - 2A (Motivation + Value Prop + Incentive - Friction - Anxiety)
