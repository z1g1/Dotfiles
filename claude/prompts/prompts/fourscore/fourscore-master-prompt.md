# FourScore Master Prompt
**Last Updated**: March 2026

## 1. Company Identity
1. What is Four Score's one-sentence mission?
To deliver powerful tools for civic impact that give constituents the leverage to raise their voices, participate in government at every level, and influence the policies that shape their lives.

2. What problem are you solving, and what's your core insight?
The American political system assumes most citizens will not participate beyond voting and donating. This is not apathy — it is rational disengagement. The time cost of meaningful civic participation (monitoring government activity, understanding what it means, taking action) is prohibitive for anyone with a full-time job. Wealthy interests hire staff to monitor, analyze, and act on their behalf. Average citizens are locked out. FourScore uses AI to compress that time and expertise barrier so every constituent can access the same levers of power. Our focus is local government — city council, school board, planning commission, county legislature — where individual leverage is highest and the space is most underserved.

3. How do you describe the category you're in (civic tech, SaaS, AI-driven advocacy, etc.)?
Civic technology SaaS. B2C subscription product. We are establishing a new market category: individual civic participation as a service. "Personal Democracy Agent" is the investor and strategic framing for what we are building.

4. What stage are you in (idea, MVP, early customers, scaling)?
Post-pivot, pre-launch on the new product. We launched LibertyCalls (AI voice calls to legislators) in beta in 2025, completed customer discovery, and did not achieve sufficient traction to continue as the primary product. We are pivoting in March 2026 to a new core product focused on local government monitoring and civic action scaffolding. MVP is in active development.

5. Who are your direct competitors or adjacent solutions?
- Apathy/doing nothing is the primary competitor. People taking no action is the default 
- The Cvic Tech Graveyard (ex Brigade, Countable, iCitizen, Popvox) are not competitors but must be avoieded. well-funded, all defunct. Built better UIs to the existing system. Stopped at Observe/Orient, never completed the civic action loop through Act.
- ActionButton (NationBuilder): helps users identify who to contact, no AI, designed for advocacy organizations not individuals.
- ResistBot: text-based letter and fax delivery to legislators, no AI, user still has to initiate all contact themselves. Focus on the Federal/State level not identifying local issues 
- None of these complete the full civic engagement loop: Observe → Orient → Decide → Act.
- Granicus, CivicPlus are both vendors in the govemrent CMS/web space. They are not competitors at this moment but might enter our space if we define the personal democracy agent 


## 2. Product and Technology
6. What is the core product functionality today?
FourScore is a local government monitoring and civic action tool. Users enter their address. We map that address to relevant local governing institutions (city council, school board, planning commission, county legislature, etc.). For MVP launch, this mapping is hand-curated by the team. The product monitors those institutions' public websites on a schedule, summarizes publicly posted meeting agendas and minutes using AI, and sends alerts when something relevant is coming up. We then scaffold action options so the user can respond — attending a meeting, submitting a public comment, emailing a representative, or receiving a calendar invite.

The goal is to compress the full civic engagement loop (Observe → Orient → Decide → Act) into something that fits in a busy person's schedule. The Decide step always belongs to the citizen. FourScore never acts without explicit user direction.

LibertyCalls — our original AI voice call to legislator feature — is shelved as a primary product. It may be reintroduced as one action option within the broader platform but is not a customer-facing brand.

7. What are the planned features for the next 6–12 months?
- Programmatic institution discovery to replace hand-curation, mapping any US address to its local governing bodies
- Expansion of local government coverage (city, county, school board are the initial targets)
- LibertyCalls reintegrated as one action mechanism within the civic action loop
- Call2Action: organizers create advocacy campaigns, set credit budgets, get summaries of actions taken by participants
- Issue tracking: help users surface what matters to them and alert when action windows open (public notices, legislative calendars, upcoming votes)
- Meeting agent: send an AI agent to attend a public meeting, return a summary, suggest actions the user might want to take

8. What AI or infrastructure providers are you built on?
- Frontend: React
- Hosting: Netlify
- Payments: Stripe
- Email list: Kit.com (ConvertKit)
- Marketing site: fourscore.ai (needs copy update — currently reflects LibertyCalls positioning)
- Agentic browsing / web scraping: under evaluation. Stagehand/Browserbase and Playwright are candidates. No decision made.
- LLM: API-driven. Provider for product features TBD.
- Development tooling: Claude Code for agentic development to accelerate product delivery
- LibertyCalls stack (on hold, not decommissioned): Twilio for telephony, ElevenLabs for text-to-speech

The product is delivered as a standard web application. "Personal Democracy Agent" is investor and strategic positioning language. The customer-facing product is a web app, not an exposed agentic interface.

9. What is unique or defensible about your technology or approach?
The technology stack is not the moat. The defensibility comes from:
- First-mover brand trust in a policy-neutral civic tool. Trust is hard to replicate once established.
- No algorithmic curation, ever. Permanent philosophical commitment. Users ordered neutrally. No feeds, no ranking, no engagement optimization. Big Tech cannot credibly make this commitment.
- Focus advantage. Local government monitoring is too niche for Big Tech product roadmaps but large enough for a focused startup.
- Switching cost and identity lock-in. Once a user has taken public civic actions through FourScore and other citizens in their community see them in the co-monitoring directory, the switching cost is real.
- Geographic density. Co-monitoring counts only become meaningful social proof with density. Early markets will be hard to replicate.

10. How do you ensure responsible use (safeguards, anti-spam, acceptable use)?
- Address-based institution mapping: users see institutions relevant to their address, not arbitrary targets
- Email verification at signup
- Low-velocity, respectful scraping of public government websites with robots.txt compliance and rate limiting
- No outbound phone calls in MVP — removes the most acute regulatory surface area
- If LibertyCalls is reintroduced: one call per day per office, calls only to the user's own representatives, explicit user consent required before any call is placed
- Retention of records of all actions taken through the platform for law enforcement compliance
- FourScore is not a spam tool. This is a hard line. Any feature or business decision that creates perverse incentives toward spam is rejected regardless of revenue impact.


## 3. Business Model
11. What pricing tiers exist today (free, subscription, credit-based)?
30-day full-feature free trial followed by a hard subscription paywall. Price point is under active customer discovery. $17.76/month is the working hypothesis (patriotic anchoring on 1776). Subscription-only. No ad-supported tier, no credit packs, no freemium. Subscription keeps incentives aligned with the customer.

12. Who pays?
Individual constituents (B2C). B2B is not an active workstream at this time.

13. What is your long-term revenue mix goal?
Subscription revenue from individual constituents. Proving the B2C market exists is the current mandate. There is some background reserach on looking into grant/s non profit status but this changes the focus of the company vs keeping the loyalty focused on the constituent 

14. Do you plan to expand into adjacent services (analytics, compliance, grassroots tooling)?
Not at this time. Focus on MVP validation

15. What KPIs matter most?
- Primary: Double-no survey completion rate. After a user takes a civic action: "Did you know about this before FourScore?" NO. "Would you have taken this action without FourScore?" NO. Both NO = the product delivered its core value.
- Trial-to-paid conversion rate at the 30-day paywall
- Monthly churn post-conversion
- Co-monitoring count density per institution per launch market
- MRR milestones: ~30 users (infrastructure break-even), ~100 users (acquisition break-even), ~500 users (founder salary viability)


## 4. Market and Customers
16. Who are your core ICPs (individual constituents vs orgs)?
B2C primary ICP is "Busy Jordan":
- 35-45 year old, dual-income household, kids in K-12 public school
- Household income $125K-$200K, college-educated, homeowner
- Suburban or mid-size metro (50K-200K population)
- Votes in general elections, reads national political news, donates occasionally
- Does NOT consume local news, does NOT know local elected officials, has never attended a city council or school board meeting
- Has enough income to skip some inconveniences but not enough to opt out of public systems entirely
- Inner monologue: "Democracy is happening to me, not with me"
- Activation trigger: a local government decision affected their family and they had no idea it was coming

Two sub-personas within Busy Jordan:
- The Discoverer (2-7 years in community): doesn't know local power structures exist. Value prop is pure discovery.
- The Re-Engager (8+ years): has opinions, attended a meeting once, gave up. Value prop is proof that participation isn't futile and that others share their concern.

The four original B2C segments (Concerned Parents, Frontline Professionals, Community Organizers, Informed Observers) may still appear in public messaging but Busy Jordan is the primary ICP driving all product and acquisition decisions.

B2B is not in current plans.

17. What industries or causes are your first adopters?
B2C launch in WNY/Buffalo area based on cofounder location and geographic clustering strategy. Existing community connections to the Jewish Community, entrepreneurship networks, and good governance groups in NY state are warm outreach channels for early users.

18. Which geographies do you focus on?
Launch in Western New York / Buffalo area. Geographic clustering is a deliberate strategy — achieve co-monitoring density in one market before expanding. Local government is the exclusive focus. Federal and state level are intentionally out of scope to maintain focus and because individual leverage is highest at the local level.

19. What motivates your users to act, and what stops them?
Motivates: A local government decision affected their family and they had no idea it was coming. The chronic frustration of feeling like democracy happens to them, not with them. The discovery that other citizens in their community share their concern.
Stops them: Time cost. Complexity of finding the right institutions and contacts. Assumption that they would be the only one who cares. Not knowing where to start.

20. Do you segment by ideology, or do you position as strictly nonpartisan?
Strictly nonpartisan. Civic power belongs to everyone, not just one party, cause, or side. A user who advocates for expanding affordable housing and one who advocates against it are both success stories. FourScore measures participation, not outcomes. Hard line at hate, harassment, and abuse.


## 5. Messaging and Brand
21. What's the tone and style of your external brand (clinical, emotional, patriotic, technical)?
Optimistic. Patriotic without being jingoistic. Direct. The system has controls and these tools help people grasp them. Not a cheerleader. Clinical when the situation calls for it.

22. What phrases or metaphors resonate with your audiences?
Liberty, democracy, leverage, voice, participation, local, constituent.

Voice of customer phrases for use in ads, landing pages, and onboarding copy:
- "By the time I found out, it was already decided."
- "I wanted to do something but I didn't know how."
- "I don't even know who makes these decisions."
- "I feel like nobody else in my neighborhood even cares about this."
- "I pay taxes, I vote, and I still have no idea what's happening at city hall."
- "I shouldn't need to quit my job to participate in local government."

23. What words are off-limits?
- Citizen → constituent: legislators represent all residents, not only citizens
- Lobbying → advocacy: lobbying is a regulated profession, advocacy is what constituents do
- Token → credit: no blockchain association
- Civic OODA loop: useful internally and for investor conversations. Not customer-facing language. Translate for consumers: "FourScore tells you what's happening, helps you understand what it means, and makes it easy to do something about it."

24. What role does visual design play (colors, mascots, illustrations)?
Visual identity is unchanged. Royal Purple palette. American historical iconography, not contemporary political imagery. Explicitly avoid red, white, and blue due to partisan association risk.

- Royal Purple: #7851a9
- Dutch White: #dbd5b2
- Periwinkle: #c6c8ee
- Licorice: #110b11
- Fawn: #f8bd7f

Mascots: AI-braham (Abraham Lincoln-based, primary brand mascot). LibertyCalls mascot (Lady Liberty/telephone operator) is on hold with that product.

25. How do you describe FourScore differently to constituents vs org buyers vs investors?
- Constituents: FourScore tells you what is happening in your local government before decisions are made, and makes it easy to act when it matters.
- Investors: We are building the world's first Personal Democracy Agent — AI that gives every citizen the equivalent of a political staff at $17.76/month.
- Advocacy organizations (future): We remove the friction from your members taking civic action. This is the next step beyond email marketing.


## 6. Sales and Growth
26. What's your go-to-market motion (bottom-up grassroots vs top-down org contracts)?
B2C only. Geographic clustering launch in WNY/Buffalo. Dense user acquisition in a single market to generate meaningful co-monitoring counts before expanding.

Primary acquisition channels:
- Short-form video ads (Reels, Shorts, TikTok): snackable, emotionally resonant trigger-event content
- Political media display and podcast ads at lower CPMs during the 2026 midterm cycle
- Nextdoor and local social media targeting: intercept the vent moment

Secondary channels:
- LinkedIn: professional civic framing
- Local news partnerships: sponsored content adjacent to trigger event coverage

Organic mechanics:
- Post-action invite-a-friend prompt
- Co-monitoring count social proof

27. Do you plan channel partnerships (political tech vendors, civic groups, SaaS bundlers)?
Not at this time.

28. How do you acquire early users today (waitlist, pilots, partnerships)?
Kit.com email list. Marketing site at fourscore.ai. Copy on the site needs to be updated — currently reflects LibertyCalls positioning. Social media and podcast advertising planned for launch.

29. What is your fundraising timeline and target (seed, Series A, grants)?
Bootstrapped. March 2026 runway deadline triggered this pivot. Not actively fundraising. Not opposed to it if the right opportunity arises.

30. Who are your most important stakeholders (investors, customers, policymakers, community)?
- Constituents: must earn their trust. The product only works if people believe it is safe, neutral, and genuinely useful.
- Legislators and their staff: must not perceive FourScore as a spam tool. If legislators move to restrict or ban this type of civic tool it is an existential risk.
- Law enforcement: maintain a clear and documented process for responding to legal requests related to platform activity.


## 7. Constraints and Risks
31. What regulatory or compliance issues concern you (campaign finance, lobbying regs, telecom)?
- Web scraping: low-velocity scraping of public government websites is legally lower-risk than phone-based outreach. Still requires robots.txt compliance, rate limiting, and terms-of-service review per target site.
- Data retention and law enforcement compliance: retain records of all actions taken through the platform.
- AI voice calls (if LibertyCalls is reintroduced): TCPA and state-level AI voice regulations apply. Constituent-to-representative calls with explicit user consent is the defensible position. Marketing calls to consumers are prohibited and will not be pursued.

32. What reputational risks do you want to avoid (partisan capture, spam perception)?
Spam perception is the primary reputational risk. FourScore must never be perceived as a tool for coordinated harassment or bulk political contact. Every product and business decision is evaluated against this. Hard line. No exceptions for revenue.

We believe tools should grant leverage, amplifying the power of people, not replacing them. Every action starts with a person. User consent is central to everything we do. We do not hide what we are doing with user data.

Political Survalince is a non starter. we might capture trends and look at data but we will not sell/expose an indivduals political concerns

33. What technical risks exist (AI reliability, phone call quality, scaling telephony)?
- Agentic browsing reliability: government websites are inconsistently structured. Parsing and summarizing unstructured public documents at scale is an unsolved reliability problem.
- Alert quality: if the product fails to surface relevant events during the 30-day trial, users churn before converting. Geographic clustering mitigates this but does not eliminate it.
- Twilio dependency (if LibertyCalls is reintroduced): political pressure on telephony providers is a vendor concentration risk.
- LLM cost at scale: AI summarization costs per user need to remain below unit economics thresholds.

34. What financial runway do you have, and what's your burn?
Bootstrapped. March 2026 runway deadline triggered the current pivot. Burn is lean — two cofounders, infrastructure costs only.

35. What's your fallback plan if AI/telephony integration faces legal or scaling blocks?
The web scraping and summarization core is lower regulatory risk than LibertyCalls was. If agentic browsing faces scaling or legal blocks, the fallback is a lighter-weight product that relies on users submitting documents or links rather than autonomous crawling. A fully autonomous agent is the goal but is not required to deliver the MVP value proposition.


## 8. CEO Priorities
36. What are your top three priorities for the next quarter?
1. Build and launch the new product MVP. The 2026 election cycle is the timing forcing function.
2. Customer discovery on pricing and trial conversion. Validate that Busy Jordan exists at sufficient scale to justify continued investment.
3. Update fourscore.ai marketing copy to reflect new product positioning and rebuild the trust and safety program for the new product scope.

37. What do you want AI assistance with most (strategy, messaging, tech, fundraising, ops)?
Strategy, messaging, and operations. Tactical development work is handled in Claude Code.

38. How hands-on are you with code/product today?
More hands-on than during the LibertyCalls phase. Using Claude Code and agentic development alongside the CTO to accelerate product delivery.

39. How do you prefer deliverables (concise frameworks, detailed docs, draft copy)?
Outlines and numbered lists. Clinical tone. No cheerleading. No emojis. Direct about trade-offs and risks. Do not soften bad news.

40. What's your long-term vision of success for FourScore (5–10 years)?
- Build a profitable company.
- FourScore becomes a key tool used to pass a constitutional amendment to get money out of politics.
- FourScore helps constituents engage with their local and state governments to break down the structural obstacles that prevent participation in civic life.
