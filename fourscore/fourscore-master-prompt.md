# FourScore Master Prompt 
## 1. Company Identity
1.	What is Four Score’s one-sentence mission?
To deliver powerful tools for civic impact that give constituents the leverage to raise their voices, participate in government at every level, and influence the policies that shape their lives
2.	What problem are you solving, and what’s your core insight?
There are levers of power in the US government but they are difficult to grasp because of complexity and time required. We are going to use the power of AI to compress these two things to allow citizens to grasp these levers. 
3.	How do you describe the category you’re in (civic tech, SaaS, AI-driven advocacy, etc.)?
We are a B2B SaaS company that is trying to delivery value for our clients. We are establishing a new space so we are starting with a B2C product to help establish the market and demonstrate to potential B2B customers what the tool can don. We are a SaaS product. 
4.	What stage are you in (idea, MVP, early customers, scaling)?
We stated working on the idea in June 2025, and are in the MVP phase now 
5.	Who are your direct competitors or adjacent solutions?
There are companies that offer the ability to put buttons on your website like ActionButton offered by NationBuilder. These products help you figure out who to call, but do not make phone calls for you. They are designed for advocacy not for use of AI.
ResistBot is another product in the space where people can text the bot to request help on delivering letters or faxes. However, they still have to make calls themselves there is no AI usage 

## 2. Product and Technology
6.	What is the Personal Democracy Agent’s core functionality today?
LibertyCalls is the core feature today. Users put in their address. We use an API to lookup who their federal and state representatives are. They can then type out a message to a representative and schedule they want the call made. Then we use ElevenLabs to convert the text to speech and use Twilio to make the phone call. We then provide a message summary to the user. A users gets a certain number of credits as a part of their plan. Calls to federal offices take more credits then to state. Users can only call their own representatives they cannot call arbitrary government members. Right now we make all of our calls after hours so we know we can leave a voicemail 
7.	What are the planned features for the next 6–12 months?
We need to make the AI agent able to interact with the people who answer the phone at a legislators office so we can call during the day 
We want to support calls to local governments. Right now we just support federal and state level 
We want to build a Call2Action feature where organizers can create an issue where they want to advocate around. Then set a budget of credits people can use to make calls as a part of the campaign. The organizer then gets a summary of the calls made
We want to build a feature to help people let FourScore know what issues are important to them. We want to help identify from public notices, calendars, and legislative scheduled when there's an action the person can take. 
We want to build a to be named product where someone can identify a government meeting (town council, school board, etc) and send an agent to attend on their behalf, create a summary of the meeting, suggest actions that might interest the person then take action. 
8.	What AI or infrastructure providers are you built on (e.g., Twilio, LLMs, cloud stack)?
Our marketing site and web app are built in React
We're using ChatGPT and Claude Code for code generation
ElevenLabs is our text to speech provider
Twilio is our telephony provider
Netlify is our hosting provider 
Stripe is our payments provider 
9.	What is unique or defensible about your technology or approach?
Not much. We are combining telephony and another companies text to voice models. If we can establish the brand that would be valuable. 
10.	How do you ensure responsible use (safeguards, anti-spam, acceptable use)?
we only allow users to make one call a day to a single office. They can make calls to different offices in the same day but can call each office only once
We are using Stripe's credit card billing address verification to make sure that people can only call their own government representatives 
We are retaining the text and audio of all calls made to ensure that we can comply with any law enforcement request which are made
We are trying to make contact with the capitol police to develop a process where we can respond to their requests with a legitimate legal order/warrant/etc
We are requiring a payment instrument to use the service to verify their address, this is to help with the bot ID problem 
We are verifying email addresses to help avoid mass sign up 
We would like to integrate with voter records or some other way to detect multiple people registering at the same address

## 3. Business Model
11.	What pricing tiers exist today (free, subscription, credit-based)?
B2C market study is a free tier with an upgrade to a subscription tier (Community Organizer) and option for credits if folks wan to be adhoc
B2B long term plan is a SaaS model where organizations will pay us an onboarding/setup fee then a certain number of calls across the year 
12.	Who pays: constituents, advocacy organizations, or both?
B2C will have an option for subscription or credits
B2B will be Advocacy Organization
13.	What is your long-term revenue mix goal (subscriptions vs credits vs enterprise contracts)?
Once we prove the space is possible we want to focus on B2B and enterprise sales 
14.	Do you plan to expand into adjacent services (analytics, compliance, grassroots tooling)?
We plan to offer a data feed which could give elected representatives a view of calls from their district. 
We also would like to offer the data to news media to help them drive reporting about what people are making calls to congress about 
15.	What KPIs matter most (MRR, MAU, retention, calls made, campaigns run)?
B2C version we need to cover our costs to show that the space exists and is valid
B2B will focus on revenue from Advocacy organizations 

## 4. Market and Customers
16.	Who are your core ICPs (individual constituents vs orgs)?
B2B are Concerned Parents, Frontline Professionals, Community Organizers, and Informed Observers 
B2B we are thinking about religious intuitions, Political action comities, and Unions, but we don't have those as firm as the B2C experiments 
17.	What industries or causes are your first B2B adopters (nonprofits, unions, advocacy groups, etc.)?
We are located in Buffalo NY so there will be a focus on local groups. We also have connections to the Jewish Community, Entrepreneurship world, and Good Governance groups in NY state 
18.	Which geographies do you focus on (local, state, federal)?
We are focused on users in the USA. Our goal would be to help people influence the levels of power at the local and state level where they have more impact. However, we know the focus will be on federal at launch 
19.	What motivates your users to act, and what stops them?
Their lives are impacted by the government and feel like they have no control there. We offer them the ability to help grab those levers of power by simplifying the levers of complexity, and compressing the amount of time it takes to participate
20.	Do you segment by ideology, or do you position as strictly nonpartisan?
We believe civic power belongs to everyone, not just to one party, cause, or side. But we draw the line at hate, harassment, and abuse. Our acceptable use policy reflects this commitment to open advocacy with clear boundaries


## 5. Messaging and Brand
21.	What’s the tone and style of your external brand (clinical, emotional, patriotic, technical)?
We are focused on optimism. The system has controls and these tools help people grasp these levers of control
We are patriotic but not jingoistic.  
22.	What phrases or metaphors resonate with your audiences (leverage, voice, liberty, etc.)?
Liberty
Democracy
Leverage 
23.	What words are off-limits (e.g., lobbying)?
Citizen -> constituent: Legislators do not only represent citizens. If you live in their district you are their constituent
Lobbying -> advocacy: Lobbying is a profession and regulated. Advocacy is performed by constituents to their representatives
Token -> credit: there is no blockchain here. We do not want any association with tokens, coins, NFTs, etc 
24.	What role does visual design play (colors, mascots, illustrations)?
We are adopting a color palette based on Royal Purple. We explicitly avoid using red, white, and blue. These colors can have parisian affiliation so we do not use them 
Royal purple: #7851a9
Dutch white: #dbd5b2
Periwinkle: #c6c8ee"
Licorice: #110b11
Fawn: #f8bd7f
We make use of American iconography from the past. Our Mascot AI-braham is based on a Abraham Lincoln. LibertyCalls mascot features Lady Liberty mixed with a telephone operator 
25.	How do you describe Four Score differently to constituents vs org buyers vs investors?
Investors: we are building the worlds first Personal Democracy Agent 
Constituents: we are building tools to help grasp the levers of power which exist
advocacy organization: we are removing the friction from their members to take action. This is the next step from email marketing. 

## 6. Sales and Growth
26.	What’s your go-to-market motion (bottom-up grassroots vs top-down org contracts)?
B2C: focus is on social and podcast advertising as these spaces allow for an organic exposure
B2B: we will start with personal contacts and try to expand our sales team. We will likely need a high touch sales funnel when we get into B2B space as we are introducing a new tool
27.	Do you plan channel partnerships (political tech vendors, civic groups, SaaS bundlers)?
Not at this time 
28.	How do you acquire early users today (waitlist, pilots, partnerships)?
We have a small email list powered by ConvertKit (kit.com), we then plan on using social media and podcast advertising 
29.	What is your fundraising timeline and target (seed, Series A, grants)?
We are bootstrapping with a runway of 6 months. Mar 2026 is our deadline to see progress
30.	Who are your most important stakeholders (investors, customers, policymakers, community)?
We need to earn the trust of constituents to prove this tool is helpful
We need to make sure that we do not create a spam tool where legislators might take action to ban this type of civic tool 

## 7. Constraints and Risks
31.	What regulatory or compliance issues concern you (campaign finance, lobbying regs, telecom)?
We are concerned about the use of AI voices to make calls. There are prohibitions on using these technologies for marketing calls to consumers. Or using them to make political calls to voters. However, we think making calls to legislator's offices on behalf of their constituents with a focus on consent is ok
32.	What reputational risks do you want to avoid (partisan capture, spam perception)?
We are not a spam tool. this is a critical part of the business. We do not take any action which could lean in this direction. It's a hard line. Example: A normal call to a constituent's federal legislator costs 3 credits. We could probably sell a lot of credits if we offered a 30 credit option to call any legislator. However, this creates a perverse incentive and we will not be doing that. 
We believe tools should grant leverage, amplifying the power of people, not replacing them. Every action starts with a person; our work supports their voice, never speaks for it. User consent is key. We need to explain what we are doing with their data and not hide anything 
We believe civic power belongs to everyone, not just to one party, cause, or side. But we draw the line at hate, harassment, and abuse. Our acceptable use policy reflects this commitment to open advocacy with clear boundaries. 
33.	What technical risks exist (AI reliability, phone call quality, scaling telephony)?
Twilio is a key vendor. If there is political pressure to prevent us from using those tools we would be in trouble 
AI agents and voice are a new thing, we could run into issues with making them lifelike when we got fully interactive 
34.	What financial runway do you have, and what’s your burn?
We have bootstrapping funds until March 2026. 
We are not opposed to fundraising but it's not an active part of of the strategy at this time 
35.	What’s your fallback plan if AI/telephony integration faces legal or scaling blocks?
It's a core feature of the tool. We would try and pivot into other areas where Personal Democracy Agents could be useful, but it would be a large pivot 

## 8. CEO Priorities
36.	What are your top three priorities for the next quarter?
Launch, Launch, Launch. We need to get the tool in front of people and get feedback. 2026 election cycle is coming and our tool needs to be ready 
Trust and Safety program. Build partnership with state police and capitol police to ensure our reporting process is solid. Build out the AUP with our legal team and game day how specific Call2Action campaigns or sales might lead to a PR crisis
Sales. Need to get in front of B2B clients and start showing them what the tool can do and start refining our sales approach 
37.	What do you want AI assistance with most (strategy, messaging, tech, fundraising, ops)?
Strategy, Messaging, and operations 
38.	How hands-on are you with code/product today?
I have built the marketing site, but my CTO is mostly hands on building the application 
39.	How do you prefer deliverables (concise frameworks, detailed docs, draft copy)?
Outlines and numbered lists. 
Be clinical. You are a Robot, I don't need a cheerleader I need a tool 
No Emojis 
40.	What’s your long-term vision of success for Four Score (5–10 years)?
To build a profitable company 
FourScore is a key tool used to get a constitutional amendment to help get money out of politics. 
FourScore is a tool that helps constituents engage with their local and state governments to break down the obstacles that prevent participation in civic life 