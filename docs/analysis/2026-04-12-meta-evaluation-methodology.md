---
status: complete
date: 2026-04-12
owner: nic
type: analysis
---

# Meta-report — how we want to evaluate this space

This arc ran five analytical passes plus a re-analysis to decide how preflight should evolve in response to the fast-moving spec-driven development landscape. The passes used seven different analytical angles, each catching failure modes the others missed. This meta-report captures *why* we leaned on each angle, *what* each one caught that others didn't, and *how* this methodology should be applied to future decisions in this space.

It's also an implicit argument: **multi-angle analysis is the right evaluation method for fast-moving spaces, not a luxury.** No single angle would have produced the final recommendation. The disagreements *between* angles are where the real insight lives.

---

## 1. Why write a meta-report at all

Two reasons:

1. **The pattern is reusable.** The next decision in this space (whether to integrate with Claude Code's new `advisor-tool`, whether to adopt spec-kit's native-skills format when it matures, whether to ship a Tack Room prototype) will face the same structural challenges: fast rate of change, contested terminology, unclear target state, multiple viable paths. The angles stack the same way every time.

2. **Pass 5 drifted.** The arc's most instructive moment was pass 5 optimizing for a criterion (obsolescence risk) it introduced, at the cost of the criteria from message 1. That drift was only caught by the re-analysis step that re-scored against the original brief. That re-scoring move *should be a standard step*, not an emergency correction. Writing it down here makes it harder to skip next time.

---

## 2. The seven angles used

Each angle is listed with:
- **What it does**
- **What it catches that others miss**
- **When to use it**
- **The failure mode it prevents**
- **The pass(es) where it was load-bearing**

### 2.1 FirstPrinciples decomposition

**What it does**: breaks a problem down into irreducible truths, then builds reasoning from the ground up. Challenges assumptions about what "needs" to exist.

**What it catches**: commoditization. When you strip away surface features (reviewer agents, elicitation flows, EARS format, scaffold commands) and ask "what's actually unique," the answer is often very different from what the surface suggests.

**When to use**: when the problem framing is contested, or when a prior pass defended the wrong value proposition.

**Failure mode prevented**: over-investing in features that every competitor already has. In our arc, FirstPrinciples caught that reviewer agents and elicitation flows were commoditized across the landscape — preflight's defensible value had to live elsewhere.

**Load-bearing in**: Pass 3 (identified coverage taxonomy as the unique contribution, not the tooling). Pass 4 Lens 1 (distinguished commodity criteria from strategic differentiation).

**Cost**: slow. Pure reasoning, no empirical grounding. Can drift into architecture astronautics if used alone.

### 2.2 IterativeDepth scored comparison

**What it does**: multiple passes over the same set of options with increasing depth. Each pass scores options against explicit criteria.

**What it catches**: relative ranking among ≥3 viable options. Forces explicit tradeoffs rather than implicit preferences.

**When to use**: when there are multiple genuinely viable paths and the choice isn't obvious.

**Failure mode prevented**: analysis paralysis. Without scoring, a set of options with different tradeoffs can't be compared, and the default becomes "build everything" or "build nothing."

**Load-bearing in**: Pass 1 (6-option comparison), Pass 4 Lens 1 (Path A/B1/B2 scoring with 15 weighted criteria).

**Cost**: the scoring is only as good as the weights. Weights encode assumptions that must themselves be challenged — which is where Council and criteria re-scoring come in.

### 2.3 Multi-perspective Council debate

**What it does**: spawns 3+ distinct perspectives with conflicting priorities (Pragmatist, Architect, User Advocate, etc.), lets them argue, extracts consensus and dissents.

**What it catches**: tensions between legitimate but conflicting priorities. A single reviewer tends to collapse these into one preference; Council keeps them live.

**When to use**: when a decision has inherent tensions (pragmatism vs purity, short-term vs long-term, user experience vs architectural hygiene).

**Failure mode prevented**: false consensus. An analyst reviewing their own work tends to converge on the one answer that satisfies all constraints — which often doesn't exist, and pretending it does hides the real tradeoff.

**Load-bearing in**: Pass 2 (three-perspective debate on E-lite, with published transcript). The dissents from the Architect and User Advocate were cited in later passes.

**Cost**: can produce consensus prematurely if the perspectives are too similar. Perspectives must be genuinely different, not just rephrasings of the same view.

### 2.4 RedTeam adversarial stress-test

**What it does**: explicitly attacks the leading recommendation from 5+ angles (timing, scope, alternatives, completeness, evidence). Assigns severity to each attack.

**What it catches**: weaknesses in the "winning" plan before it ships. Specifically catches vaporware dependencies, hidden scope creep, and inadequate testing.

**When to use**: after every pass that produces a recommendation, before publishing it.

**Failure mode prevented**: shipping a plan that nobody challenged. Analytic momentum tends to validate the leading option; RedTeam forces explicit challenges.

**Load-bearing in**: Pass 2's 5-attack review of the Tack Room harness recommendation. Caught the timing attack (Tack Room was vaporware) and the completeness attack (template ≠ process), both of which shifted the recommendation.

**Cost**: can be dismissed if framed as optional. Works only when the attacks are genuinely scored and acted on.

### 2.5 Empirical rate-of-change research

**What it does**: gathers hard data on how fast the space is actually moving — version numbers, ship dates, breaking changes, benchmark shifts, model releases — over a specific time window.

**What it catches**: obsolescence risk. The gap between "this looks stable" (narrative) and "this shipped 4 breaking releases in 90 days" (empirical) is enormous.

**When to use**: any time a plan extends beyond ~60 days in a fast-moving space.

**Failure mode prevented**: architecture astronautics. Building for a decade in a space where half the landscape changes every quarter.

**Load-bearing in**: Pass 5 rate-of-change research found 3 frontier models, 4 framework breaking releases, and 2 new benchmarks in 90 days. Produced the 55-70% 6-month obsolescence estimate that killed pass 4's "decade" framing.

**Cost**: takes real web research time. Cannot be done from static context. Needs to be refreshed periodically because the data itself has a half-life.

### 2.6 Buy-vs-build weighted criteria

**What it does**: classical decision framework adapted — 10 standard criteria (differentiation, TCO, control, vendor risk, etc.) plus project-specific criteria, each weighted explicitly, each scored per option.

**What it catches**: quantitative comparison with legible assumptions. Forces "why is this weighted 3×?" to be answerable.

**When to use**: when the decision is genuinely build-vs-adopt-vs-customize.

**Failure mode prevented**: narrative bias. Without explicit weights, the analyst's preferences dominate; with explicit weights, the preferences are at least visible.

**Load-bearing in**: Pass 4 Lens 1 scored Path A: 161/175, Path B2: 96/175, Path B1: 85/175. The gap was driven by three criteria weighted 3× (rules preservation, Tack Room harness fit, control/customization) — which only became visible because the weights were explicit.

**Cost**: the weights themselves encode the answer. A 3× weight on "strategic differentiation" and 1× on "network effects" biases toward build. Weights must be stated up front and challenged separately.

### 2.7 Backward-walking from target state

**What it does**: starts from a fully-implemented target (Tack Room running autonomously) and walks backwards through architectural layers, asking at each step "what must be true at the layer below for this to work?"

**What it catches**: hidden dependencies and ordering requirements that forward planning misses. Particularly good at revealing which things must exist *before* which other things.

**When to use**: when the target state is clear but the path is not, especially when the path has dependencies that forward planning would miss.

**Failure mode prevented**: ordering bugs. Forward-planning produces the wrong sequence when dependency structure is deep.

**Load-bearing in**: Pass 4 Lens 3 walked backwards from Tack Room through 7 layers and produced the critical finding: **drift detection must ship before the autonomous builder**, not after. Forward planning would have shipped them in the wrong order. The "lookback letter from 2027" framing made the finding concrete.

**Cost**: requires a clear target state. Useless for genuinely open-ended exploration.

### 2.8 Criteria-first re-scoring

**What it does**: takes any pass's recommendation and scores it against the criteria from the *original* brief, not against the criteria the current pass introduced.

**What it catches**: drift. Specifically, the failure mode where each late pass refines on the previous pass's framing and loses sight of the original brief.

**When to use**: **always, whenever a pass changes the recommendation.** This is non-negotiable.

**Failure mode prevented**: optimizing for newly-introduced criteria at the cost of original ones. This is the most dangerous failure mode in a multi-pass analysis because each pass feels locally correct.

**Load-bearing in**: Pass 5 re-analysis. Pass 5 dropped workflow skills on obsolescence grounds; criteria-first re-scoring revealed the corrected plan scored 11/12 on original criteria while pass 5 scored 4/12. Without this angle, pass 5 would have shipped.

**Cost**: requires the original criteria to be written down. If the original brief is loose, criteria-first re-scoring has nothing to anchor to. **Write the criteria down on day 1.**

### 2.9 Load-bearing-criterion isolation

**What it does**: when a multi-criterion scoring matrix produces a clear winner, identifies which single criterion is doing most of the work and re-states the conclusion in terms of that one criterion. If 14 criteria are close and 1 is binary, the honest framing is "X loses on the binary criterion" — not "X loses on the average."

**What it catches**: framing errors where a single load-bearing criterion gets hidden inside an aggregate score. Aggregate scores spread the decision across many dimensions, which obscures whether the result is robust (multiple criteria agree) or fragile (one criterion drives everything). The same fragility looks like robustness in the matrix output.

**When to use**: after every weighted-criteria scoring exercise that produces a clear winner. Specifically when the gap between options exceeds 30% of the maximum score on a small number of criteria.

**Failure mode prevented**: presenting a fragile single-criterion decision as a robust multi-criterion consensus. Pass 4 scored Path A vs B1 across 15 criteria and reported A=161, B1=85 — a 76-point gap that read as "A is dominant on everything." The honest framing was "A wins because B1 scores 1/5 on preflight rules preservation; the other 14 criteria are within noise." That framing is more actionable because it tells you exactly what would flip the decision.

**Load-bearing in**: the framework customization depth doc (2026-04-13) re-scored OpenSpec/spec-kit and found B4 at ~130/175 — much closer than pass 4's B1 at 85/175. The gap had been hidden by spreading the decisive enforcement-gate criterion across the matrix average. Re-stating the conclusion as "Path A wins on enforcement gate, ties or loses on most other criteria" produced sharper tripwire conditions and revealed the composable-architecture path.

**Cost**: requires honesty about what is actually load-bearing, which sometimes contradicts the analyst's preferred framing. Easy to skip when the matrix already shows the desired winner.

### 2.10 Composition-first before substitution

**What it does**: before scoring options as substitutes for each other, asks whether they cover the same layer of the problem. If they cover different layers, the question is composition topology, not selection. The pattern is: **identify layers → identify which framework owns which layer → score only across options that cover the same layer → if composition is possible, score the composed stack as its own option.**

**What it catches**: framing errors where a multi-layer architecture gets analyzed as a single-layer choice. Substitution framing forces fights between things that don't need to fight; composition framing reveals the seams where they can coexist.

**When to use**: when both conditions hold:
- The candidate "substrates" are extensible by design (preset systems, plugin APIs, schemas)
- The "build" option duplicates surface the substrate already owns

When either condition is false, fall back to substitution scoring — the angle isn't useful for genuinely competing tools.

**Failure mode prevented**: scoring frameworks against each other on criteria that are only meaningful within one layer, and dismissing valuable cross-layer features because they don't fit the substitution narrative. The arc dismissed spec-kit's multi-agent CommandRegistrar as "near-zero value" across passes 1–5 and the customization depth doc, because the substitution framing scored multi-agent reach as "what would we lose if we adopted spec-kit?" — a question that has no answer when the loss is hypothetical. Under composition framing, multi-agent reach is "what would we *gain* by composing spec-kit's authoring layer onto preflight's rules layer?" — a question with a concrete and large answer (Tack Room glue).

**Load-bearing in**: the composable architecture doc (2026-04-13). Across 31 passes the framing was "preflight vs substrate X." Composition-first reframing produced Path A-prime as a new option (spec-kit owns lifecycle + multi-agent reach, preflight owns rules + governance, PAI owns decomposition + execution) that scored within noise of standalone Path A but with a meaningfully different risk profile and direct Tack Room fit. This was the largest framing miss of the arc.

**Cost**: requires identifying the layers up front, which is sometimes hard. If layer boundaries are ambiguous (because two frameworks legitimately fight over the same surface), composition framing collapses back to substitution. Use only when the layers are clean. Can be expensive to apply post-hoc — once an analysis is committed to substitution scoring, retrofitting composition framing means re-running the option enumeration.

**Pre-step, not alternative**: this angle runs *before* IterativeDepth and Buy-vs-build, not in parallel with them. It changes what gets scored, not how. The natural order is: composition check → if substitution still applies, run weighted scoring → if a clear winner emerges, run load-bearing-criterion isolation (2.9) → criteria-first re-scoring (2.8) before publishing.

---

## 3. The pattern — stacking angles

No single angle in the list above would have produced the final recommendation. More importantly, the *disagreements between angles* are where the real insight lives:

- **FirstPrinciples said**: preflight's value is the coverage taxonomy. Corollary: don't build more workflow.
- **Criteria-first re-scoring said**: workflow skills satisfy the original criteria. Corollary: build the workflow.
- **Rate-of-change said**: workflow is commoditizing fast. Corollary: don't build workflow.
- **Re-scoring said more**: preflight-native workflow is UX, not a competing framework. Corollary: low obsolescence risk.

The final recommendation (4 items, ship workflow skills + drift + coverage, drop handoff format) emerged from resolving these disagreements against the original brief. It would not have emerged from any single angle.

**The general pattern**:

0. **Composition check first** — before enumerating options as substitutes, ask if the candidate frameworks cover the same layer. If they don't, the question is composition topology, not selection (2.10).
1. **Start broad** — enumerate options and criteria (IterativeDepth, Buy-vs-build).
2. **Go deep** — decompose from first principles to find commoditized surfaces (FirstPrinciples).
3. **Widen again** — multi-perspective debate on leading options (Council).
4. **Stress-test the winner** — RedTeam the leading recommendation.
5. **Ground in reality** — empirical rate-of-change research to challenge long horizons.
6. **Walk backwards** — from target state to today's decision, revealing ordering.
7. **Isolate the load-bearing criterion** — when scoring produces a clear winner, identify whether it's robust (multiple criteria agree) or fragile (one criterion drives everything). Re-state the conclusion in terms of the load-bearing criterion (2.9).
8. **Always re-score** — criteria-first check against the original brief, before publishing (2.8).

Skipping any step is possible. Skipping #0 produces 31 passes asking the wrong question (composition disguised as substitution). Skipping #8 produces drift like pass 5. Skipping #7 produces fragile decisions presented as robust ones.

---

## 4. What we learned about this space specifically

### 4.1 The space is moving fast — faster than "we'll see in 12 months" suggests

Empirical rate-of-change data: **3 frontier models, 4 framework breaking releases, 2 new benchmarks in 90 days**. OpenSpec shipped v1.0 breaking changes, BMAD did full v5→v6→v6.3 with 4 breaking changes, spec-kit migrated its scaffold to Claude Code native skills. This is not a slow-moving enterprise space.

**Implication**: plans with horizons >60 days are speculative. The "own it for a decade" framing is actively harmful — it biases toward building substrate, and substrate at 6-month obsolescence probability 55-70% is a bad bet.

### 4.2 Categories are durable; plumbing is not

Content (what you write in a template) survives framework churn. Markdown is the convergent substrate — every major framework is converging *on* it, not away from it. GitHub published an explicit "markdown as a programming language" post. Plumbing (workflow runners, handoff formats, API integrations) is highly volatile.

**Implication**: build plumbing only where repo specifics matter (git hooks, preflight-native UX, drift detection). Rent formats from the ecosystem (STRIDE for threat modeling, C4/DDD for data models, Google SRE book for ops envelopes, OpenSpec's task.md format if we need task decomposition).

### 4.3 Taxonomy matters more than features

Preflight's defensible core is the coverage taxonomy (23/25 categories vs OpenSpec's 6/25), not the workflow or the reviewer agents. But the taxonomy alone is a checklist — what makes it a contract is the *precedence rules* (constitution > requirements > ADR > code) and *ID-stable traceability* (FR-NNN never reused).

**Implication**: invest in the taxonomy and its invariants. Don't invest in workflow surface area unless it connects directly to the taxonomy (which explore/propose do — they route through the category set).

### 4.4 Habit-lock is the feature, not the bug

Workflow skills create habits. Habits prevent forgetting. That's the original brief. Pass 5 treated habit-lock as a reversibility cost; the re-analysis caught this as a category error.

**Implication**: when scoring reversibility, distinguish "easy to replace the code" (true for workflow skills) from "easy to replace the habit" (not the goal — we *want* the habit).

### 4.5 Short horizons beat long plans

At 55-70% obsolescence probability over 6 months, any plan that doesn't fit in 4-6 weeks is speculative. The right governance model is **ship small, iterate fast, re-score at 60-day intervals.** Pass 4's 365-day tripwire was wrong; pass 5's 60-day tripwire is right.

**Implication**: every plan should have an explicit "stop and re-evaluate" checkpoint within 60 days. No long-running roadmaps. The next decision is made with data that doesn't exist yet.

---

## 5. How to evaluate this space going forward

### 5.1 Decision framework for "should I build this feature?"

Five questions, in order:

1. **Does it address an original criterion?** (If the answer is "not really," stop. The feature is speculative.)
2. **Is it a commodity in the ecosystem?** (If yes, don't build — rent or do nothing.)
3. **Will it obsolete within 6 months?** (If yes and it's not a daily-pain fix, don't build.)
4. **Does it create daily habits?** (If yes, habit-lock is the *benefit*. Score accordingly.)
5. **Can it ship in <1 week?** (If no, break it into smaller pieces or defer.)

**Build if**: Q1=yes, Q2=no (or preflight-specific), Q3=no, Q4=yes or neutral, Q5=yes.

**Skip if**: Q1=no, OR Q2=yes, OR Q3=yes without daily payoff, OR Q5=no without strong decomposition.

### 5.2 Principles for fast-moving spaces

1. **Criteria-first.** Always re-score against the original brief before publishing. Every pass. No exceptions.
2. **Empirical over narrative.** Rate of change is measurable. Measure it. Don't guess.
3. **Rent over build where the ecosystem converges.** Formats, standards, patterns are where community value compounds. Plumbing is where repo specifics matter.
4. **Short horizons.** 60-day tripwires, not annual plans. The best decision in week 20 is made with week-20 data, not week-1 data.
5. **Habit creation is valuable.** Don't confuse it with lock-in. Workflow skills that become daily rituals are solving the original problem, not creating one.
6. **Multi-angle analysis.** Stack perspectives. Let them disagree. Reconcile disagreements with the original brief.
7. **Value the disagreements.** When two angles reach opposing conclusions, that's where the real insight is — not in the angle that happened to "win."

### 5.3 The pattern for future decisions

Any non-trivial decision in this space should follow this template:

1. Write down the criteria from the brief (day 0).
2. Run FirstPrinciples + IterativeDepth to produce the option set (pass 1).
3. Run Council + RedTeam to stress-test the leader (pass 2).
4. Run empirical rate-of-change research to challenge the horizon (pass 3).
5. Run backward-walk from target state if the target is clear (pass 4).
6. **Run criteria-first re-scoring before publishing every pass** (every pass, every time).
7. Ship the minimum viable plan with a 60-day tripwire.
8. Re-run steps 4-7 at day 60 with new data.

Skip steps only with deliberate justification.

---

## 6. Concrete lessons from this specific arc

### What worked

- **Parallel research agents.** Five passes × multiple research streams = dozens of background agents. This made 6 days of work fit in 2 days of clock time.
- **Writing each pass to disk before starting the next.** Forced crisp summaries and prevented context bloat.
- **Publishing to Notion after each pass.** Made the research reviewable at each stage and produced a clear audit trail for future reference.
- **Explicit confidence levels.** Every recommendation ended with "confidence: high/medium/low" and "what would flip it." Prevented false certainty.
- **The lookback letter framing** (pass 4). Writing "as if from 2027" exposed ordering assumptions forward planning would have missed.

### What didn't work

- **Pass 5's missing criteria-first re-check.** The most important failure mode in the arc. Would have caught the workflow-skills drop before publication if run as a standard step.
- **Pass 4's "decade" framing.** Anchored on a horizon the rate-of-change data couldn't support. Should have been challenged by pass 5's own rate-of-change research more aggressively.
- **Pass 1's score-based option table.** Was useful as a starting point but rapidly became obsolete as later passes sharpened the framing. Shouldn't have been treated as load-bearing.
- **Background agent coordination.** A few agents got confused about scope (the first rate-of-change attempt looked for local files when it should have done web research). Sharper prompting on retry fixed it.

### What the arc didn't do

- **No spike.** RedTeam in pass 2 specifically flagged "no spike, no prototype, no user testing" as a medium-severity attack. It was not addressed across 5 passes. A 1-day spike implementing `/preflight explore` on a real change would have produced more signal than any of the passes.
- **No external user input.** Everything was internal analysis. The landscape moves fast enough that external signal (even from one other preflight user) would have changed the calculus on multiple decisions.
- **No composition check.** Across 31 passes the framing was "preflight vs substrate X" — substitution. The composition-first angle (2.10) was added retroactively after the framework customization depth doc revealed that pass 4's matrix had been scoring different layers against each other. Composition-first should have run at pass 1 and would have produced Path A-prime as a first-class option from the start instead of as a 32nd-pass discovery.
- **No load-bearing-criterion isolation.** Pass 4's 76-point gap between Path A and B1 read as dominance, but it was actually a single criterion (preflight rules preservation) doing all the work. The customization depth doc had to retro-fit this analysis. Angle 2.9 should have run immediately after pass 4's matrix and would have produced sharper tripwire conditions earlier.

---

## 7. How this feeds back into preflight itself

This arc was about preflight, but the methodology is general. **Preflight should capture this methodology as its own reference material** — not as rules (which would calcify it) but as reference docs that future preflight users can read when facing similar decisions.

Specific proposed changes to preflight's content are enumerated in the companion doc `docs/plans/2026-04-12-preflight-content-updates-from-research.md`.

The short version:
- Add `content/reference/evaluation-methodology.md` describing the 7 angles and when to use them
- Add `content/reference/rate-of-change-awareness.md` describing how to assess obsolescence risk
- Possibly add an analysis doc type template for multi-pass decision work
- Do *not* commit the 25-category L4 framework as a rule artifact — keep as reference

---

## 8. The one-paragraph summary

Multi-angle analysis is the right way to evaluate decisions in fast-moving spaces. Ten angles — composition-first, FirstPrinciples, IterativeDepth, Council, RedTeam, rate-of-change, buy-vs-build, backward-walking, load-bearing-criterion isolation, and criteria-first re-scoring — each catch failure modes the others miss. **Composition-first runs before scoring; criteria-first re-scoring runs before publishing.** The two most dangerous failure modes are **substitution framing for problems that are actually composition** (caught only by 2.10) and **drift from the original brief** (caught only by 2.8). For preflight specifically: the space moves fast enough that plans >60 days are speculative, the defensible value is the coverage taxonomy (not the tooling), habit-creating workflow skills are high-value despite looking like "lock-in," and the right governance model is ship-small + 60-day tripwire. This methodology should become part of preflight's reference material so future decisions in this space reuse the pattern instead of rediscovering it.
