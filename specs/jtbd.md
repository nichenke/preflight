# Preflight — jobs to be done

**Version:** v0 (2026-04-26) · expected to evolve. Sections marked *v0 — will evolve* are the cuts I am least sure about; they are the targets for Phase 1.2 review.

## What this doc is for

This document names the jobs preflight is for, the personas it serves, and the jobs it explicitly is not for. Its operational purpose is to **make the Q2 reshape decision falsifiable**: if the jobs below are real and load-bearing, the reshape (drop spec-kit substrate, ship as a Claude Code skill bundle invoked by PAI during BUILD — see `docs/plans/2026-04-26-preflight-roadmap.md`) earns its keep. If any Job comes out worse under the reshape, the reshape bends.

The Job most likely to falsify the reshape is **J4 — durable contributor-readable artifacts** (added during adversarial review specifically because v0 had no reshape-loseable Job). Phase 1.2 should weight J4 heaviest when re-evaluating: does the skill-bundle reshape preserve `specs/*.md` as the contributor-readable surface, or does it move state into agent-mediated forms?

This doc is self-contained. It does not require reading the strategic reimagine analysis, the roadmap, or any ADR to understand. It does cite them where evidence is anchored.

## Why "jobs" and not "features" or "goals"

Preflight already has a lot of features (a 48-rule reviewer ensemble, a doc-type preset, an extension command, an autonomy framework reference). Features tell you *what the tool does*. Jobs tell you *what the user is hiring the tool to do*. The distinction matters because the reshape question — "should preflight stay shaped like a spec-kit extension, or become a skill bundle?" — is decided by which form lets users get their jobs done with less friction. Without a Jobs articulation, the reshape decision is litigated on tool-shape preferences, not user outcomes.

Peer-framework note: spec-kit, BMAD, OpenSpec, Superpowers, and GSD all embed scope in README, not in a standalone JTBD doc. Preflight publishing this as `specs/jtbd.md` is unusual. The justification is that preflight is itself a spec-driven-development tool — eating its own dogfood by carrying its scope as a versioned spec is on-brand. *v0 — will evolve.*

## Personas

Two personas hire preflight; one channel runs the work.

- **Supervisor** *(persona)* — the user reviewing agent-drafted output before it merges. L4 autonomy framing (`docs/reference/l4-autonomy-category-framework.md`). Their default action is *approve / iterate / reject*, not *author from scratch*. Most of preflight's value lands on this persona.
- **Maintainer** *(persona)* — a person extending preflight itself: adding rules, refining reviewer prompts, evolving the doc-type preset. Wants to ship features without governance accretion swallowing every rule change.
- **Drafting agent** *(channel, not persona)* — a coding agent (Claude Code, Codex, etc.) that drafts a spec or implementation from a user's intent. The agent does not *hire* preflight on its own behalf; the supervisor's Jobs run *through* the agent. Stories that look agent-fronted (e.g. self-review before requesting approval) are really supervisor Jobs invoked through the agent surface.

**Autonomy scope note:** preflight is optimized for L4 (human supervises agent execution end-to-end). It degrades usefully at L3 (agent suggests, human reviews) and L2 (agent assists, human authors); some Jobs (J2 elicitation in particular) are less salient when the human is the primary author. Where v0 over-commits to L4, that's a known-gap iteration trigger.

## Forces (the JTBD frame)

- **Push** (what makes the user reach for preflight): An agent-drafted spec just landed. The user knows that approving without reading it carefully will cost more later, but reading every line for every defect class is exhausting. Or: an implementation PR is up, and the user knows the spec-vs-code coherence story is fragile but doesn't want to manually trace which FRs changed.
- **Pull** (what they hope happens): A reviewer agent runs, produces a defect list with severity, and the user spends their attention only on the calls they actually have to make.
- **Anxiety** (what holds them back): Preflight's checks could be wrong, slow, or noisy. False positives erode trust faster than false negatives — a reviewer that flags ten harmless things and misses the real defect is worse than no reviewer at all.
- **Habit** (what they'd do without preflight): Skim the spec, hope, ship, fix later. Or: write more careful prompts manually. Or: carry the defect taxonomy in their head and burn the cycles.

## Jobs

Four Jobs. Three survived first-principles cuts (J1, J2, J3); a fourth (J4 — substrate commitment) was added after RedTeam review identified that v0 had no Job a substrate-changing reshape could fail. Padding to five would still dilute — see *Alternatives considered & rejected* below.

### J1 — Catch spec defects an agent will silently code against

**When** I'm about to hand an agent-drafted spec to an implementation agent, **help me** identify structural and epistemic defects (unverifiable requirements, EARS violations, dangling references, silent contradictions with the constitution, vague adjectives without quantification, implementation prescriptions in requirements), **so that** the implementation agent doesn't generate code against a gap I'll later have to unwind.

**Justifies:** the 48-rule checklist-reviewer pack and the bogey-reviewer (defect-finding agent). **Prevents:** the *"looks fine, ships broken"* failure mode where review felt thorough but missed a structural hole.

Evidence: `extensions/preflight/agents/reviewers/bogey-reviewer.md` (defect classes targeted); `extensions/preflight/rules/universal-rules.md` UNIV-04 (vague adjectives); `extensions/preflight/rules/requirements-rules.md` REQ-R03 / REQ-R08 (implementation leakage and status leakage); `docs/reference/l4-autonomy-category-framework.md` (SWE-bench Verified: 38.3% of real specs underspecified for agents).

### J2 — Surface unstated requirements before they become silent agent assumptions

**When** I'm starting work on a feature whose intent fits in two sentences but whose actual scope is wider, **help me** answer the questions I would have skipped (failure modes, rollback plan, observability story, security implications, persona conflicts), **so that** the resulting spec covers the categories an agent needs to execute autonomously rather than improvise.

**Justifies:** the Explore workflow (deep elicitation + doc-type routing + draft generation) and a future gap-reviewer focused on *missing* categories rather than *malformed* content. **Prevents:** the *"shipped against an under-specified intent"* failure mode where the agent guesses and the guess turns out to be wrong in production.

Evidence: `docs/analysis/2026-04-26-preflight-strategic-reimagine.md` §"Reshape — what preflight becomes" (Explore workflow); `docs/plans/2026-04-26-preflight-roadmap.md` Phase 3.3 (deep elicitation question bank, doc-type routing rules); `docs/reference/l4-autonomy-category-framework.md` (25-category taxonomy, 13-category MVP for L4-ready specs).

### J3 — Prevent silent reversals across time and contributors

**When** I'm changing a requirement, removing a behavior, or reading a spec months after it was written, **help me** trace each requirement to the decision (ADR) that justified it and identify every downstream artifact that depends on it, **so that** changes happen as one coherent diff and prior architectural intent isn't undone by accident.

**Justifies:** REQ-R07 (behavioral changes require ADR + downstream-doc list) and the cross-doc-conflict rule pack. **Prevents:** the *"silent reversal"* failure mode where a later contributor or agent re-improves a prior decision because the rationale was never written down or never traced — and the *"orphan reference"* failure mode where a removed FR ID still has live references in architecture / interfaces / tests.

J3 distinguishes from J1 by *time horizon*: J1 is the supervisor reviewing one artifact in one moment; J3 is the supervisor (or a future contributor / agent) reading a spec months later and needing the rationale and graph of references to act safely. The canonical J3 motion is the *removal of a deprecated FR*, not the *review of a single doc*.

Evidence: `extensions/preflight/rules/requirements-rules.md` REQ-R07 (ADR-required behavioral changes); `specs/decisions/adrs/adr-007-feature-folder-lifecycle.md` (three failure modes: forgotten updates, hidden coordination, unvalidated state compounding on main); `docs/reference/l4-autonomy-category-framework.md` Category 13 (ADRs with rationale prevent agents from silently re-improving prior decisions).

### J4 — Keep specs as durable, contributor-readable artifacts (substrate commitment)

**When** I'm joining a project, returning to a project after months, or reading a spec without invoking an agent, **help me** read the current state of the system from versioned, diffable text files — not from agent-mediated state — **so that** specs remain the source of truth even when no agent is running and a contributor can answer "what does the system do today?" with `git log` and a text editor.

**Justifies:** the `specs/` folder structure as a checked-in artifact; the doc-type preset producing markdown rather than agent-state; the requirement that every reviewer rule cite line-anchored evidence. **Prevents:** the *"truth-in-the-agent"* failure mode where the agent becomes the only thing that knows what the spec means, and contributors who can't or won't invoke it lose access to the system's current shape.

This Job is what a substrate-changing reshape (skill bundle, dropping spec-kit) has to satisfy. If the reshape moves spec state into agent-mediated invocations or tooling-specific formats, J4 is at risk; if the reshape preserves `specs/*.md` as the contributor surface and only changes how the *reviewer* is invoked, J4 is safe. **This is the Job Phase 1.2 should test most carefully.** *v0 — will evolve;* J4 was added after RedTeam pointed out that v0 had no Job opposing the reshape, which made the doc structurally unable to do its stated load-bearing work.

Evidence: `CLAUDE.md` ("Templates, rules, agent prompts, and scaffolds live **inside** `presets/preflight/` and `extensions/preflight/`"); `docs/analysis/2026-04-26-preflight-strategic-reimagine.md` §"Reshape — what preflight becomes" (the reshape preserves `specs/` as markdown but moves invocation surface from extension command to skill); `extensions/preflight/rules/universal-rules.md` UNIV-01 (file-anchored evidence is the rule for reviewer findings, which depends on durable text artifacts).

## User stories

Two stories per Job, anchored to specific personas + situations. Each story has an acceptance hint a future test could check against.

### S1 — Supervisor, J1
*As a supervisor reviewing an agent-drafted RFC, I want a defect list with severity and file-anchored quotes, so that I can spend attention only on Critical/High calls and let Medium/Low ride.*
- Acceptance hint: review output groups findings by severity; each finding cites a quote and a rule ID; findings without rule traceability surface as "judgment call, not rule violation."

### S2 — Supervisor (via drafting agent), J1
*As a supervisor whose drafting agent just wrote a requirements delta, I want the agent to self-review against the rule pack before requesting my approval, so that my first read is on findings I have to judge — not on issues the rules already define as defects.*
- Acceptance hint: the review skill is invokable agent-to-agent (no terminal interaction required); output parseable enough to drive an iteration loop; supervisor sees only findings the rule pack could not auto-resolve.

### S3 — Supervisor, J2
*As a supervisor approving an Explore-workflow output, I want the questions the workflow asked AND the answers it filled in, so that I can spot-check the riskiest answers rather than re-running elicitation myself.*
- Acceptance hint: each provisional answer carries one of {confirmed, inferred, guessed}; overriding a {guessed} answer re-runs only the dependent question subtree; the supervisor never has to re-answer a {confirmed} question.

### S4 — Maintainer, J2
*As a maintainer evolving the elicitation question bank, I want question categories tied to the L4 autonomy taxonomy, so that adding a question is justified by an autonomy gap rather than by personal taste.*
- Acceptance hint: each question category in the bank cites a Category ID from `l4-autonomy-category-framework.md`; questions without a Category cite are flagged for review.

### S5 — Supervisor, J3
*As a supervisor reviewing an implementation PR, I want a coherence check that flags any behavioral change without a corresponding ADR or requirements update, so that I don't merge PRs that quietly invalidate the spec.*
- Acceptance hint: coherence check runs as part of the review skill; flags include the FR/NFR ID(s) affected and the decision-doc(s) missing; supervisor gets a structured "approve / request-ADR / request-spec-update" call.

### S6 — Maintainer, J3
*As a maintainer trying to remove a deprecated requirement, I want the system to identify all downstream artifacts (architecture, interfaces, tests) that reference the FR ID, so that the removal is a single coherent diff rather than a months-long trail of dangling references.*
- Acceptance hint: removal preview lists every doc that references the ID; supervisor reviews the bundle as one diff.

### S7 — Returning contributor, J4
*As a contributor who hasn't touched this project in three months, I want to read the current spec by opening files in my editor, so that I can answer "what does the system do today?" without invoking any agent or tool.*
- Acceptance hint: opening `specs/requirements.md`, `specs/architecture.md`, and the relevant ADR(s) is sufficient to understand current system behavior; no read path requires running preflight, an agent, or any external tool.

## Anti-jobs

Each anti-job passes the sharpness test: someone has asked for it, a prior decision pushed back on it, or the rule pack is structurally tempted toward it. Generic disclaimers ("not for project management") were dropped — they prevent nothing.

- **Not for replacing PAI / agent ISC task decomposition.** Preflight evaluates spec quality; it does not produce a task graph for an implementation agent. Reviewer rules will be tempted to drift toward "decompose this spec into work items" — refuse. *Preflight does:* defect-and-gap review on the spec, then hands off to the implementation agent's own decomposition.

- **Not a CI gate, pre-commit hook, or runtime enforcer.** ADR-009 deferred enforcement orchestration explicitly. Preflight is an *on-demand reviewer*; making it block commits or merges turns review trust into review obligation, and the false-positive cost compounds. *Preflight does:* run when invoked, return findings, leave the merge decision to humans (or to a higher-level gate the user explicitly wires up).

- **Not a constitution-checker for non-spec-kit / non-PAI projects.** Preflight's constitution and rule packs are calibrated for projects that adopt spec-driven development as practiced here. Lifting them into arbitrary projects without the surrounding scaffolding would surface false positives at scale. *Preflight does:* serve projects that have adopted the practice; documents the practice openly so others can adopt it.

- **Not a template marketplace or third-party rule registry.** The doc-type preset is a curated set of seven templates (after dropping constitution-template); the rule pack is a curated set of 48 rules. Opening either to third-party submissions reopens scope on every PR. *Preflight does:* maintain the curated set; accept rule contributions through the same review process every other change uses.

- **Not for retroactive spec archaeology on already-shipped code.** Preflight reviews specs that an agent will code against. Reverse-engineering specs from existing untested code is a different problem with different rule shapes (it cares about what the code does, not what an agent will guess). *Preflight does:* review forward-looking specs; if you need archaeology, run a separate pass with a different reviewer prompt.

## Ranking

Jobs ranked by combined frequency × evidence-strength × cut-clarity (highest first):

1. **J1 — Catch spec defects.** Every spec, strongest evidence (existing reviewer ensemble + 48 rules + SWE-bench data), cleanest cut. The center of gravity.
2. **J4 — Durable contributor-readable artifacts.** Every contributor read, every onboarding, every months-later return. Lowest-friction Job to satisfy *if* the substrate stays markdown; the Job most at risk if the reshape moves spec state into agent-mediated forms. This is the Job Phase 1.2 has to weight most carefully.
3. **J3 — Prevent silent reversals across time and contributors.** Every behavioral change, every deprecation. Strong evidence (ADR-007 failure modes + REQ-R07 rule). Less mature tooling today; this is what Phase 3 of the roadmap targets most directly.
4. **J2 — Surface unstated requirements.** Per feature (less frequent than J1/J3), good evidence (Explore workflow designed but not yet shipped), some on-the-loop friction since elicitation leans author-shaped. *v0 — will evolve;* J2 is the Job most likely to refine in v1.

## Alternatives considered & rejected

- **Forcing five Jobs.** The handoff brief suggested ≥5 Jobs. After first-principles decomposition with evidence trace, three Jobs surfaced (J1, J2, J3); RedTeam review then added a fourth (J4 — substrate commitment) on the basis that no Job in the original cut could be failed by a substrate-changing reshape. Total: four. Padding to five would have promoted sub-defects (vague adjectives, implementation leakage) to top-level Jobs, fragmenting one supervisor decision ("is this spec safe to hand off?") into a checklist. Rejected for honesty.

- **A "route intent to the right doc type" Job.** Considered (was J4 in the candidate set). Cut on the differentiation test — this is a tool-feature description (what the doc-type preset and routing rules *do*), not a recurring user Job. The underlying user moment ("am I writing an ADR or an RFC?") is one-time onboarding friction, addressable by any decent template index. Doesn't earn a top-level slot.

- **An "agent-readiness validation" Job separate from defect-catch.** Considered. Rejected because *agent-readiness* is the *quality bar* J1 evaluates against, not a separate Job. Promoting it would split one operational pass into two with the same outputs.

- **Christensen-pure phrasing without the Justifies/Prevents line.** Considered. Council's tooling-skeptic pushed back: a Job statement that doesn't connect to a ship/cut decision is decorative. The Justifies/Prevents line is the load-bearing addition that makes each Job operational rather than aspirational.

- **Standalone JTBD doc shape itself.** No surveyed peer framework (spec-kit, BMAD, OpenSpec, Superpowers, GSD) publishes a standalone JTBD doc — they all embed scope in README. We're publishing this anyway because preflight is a spec-driven-development tool and a versioned spec for its own scope is on-brand. *v0 — will evolve* if Phase 1.2 review concludes a README section would carry this load with less ceremony.

## How this doc gets used

- **Phase 1.2 — re-evaluate reshape.** Read the four Jobs against the reshape (skill bundle, drop spec-kit, drop self-constitution, replace ADR-007 lifecycle with worktrees). For each Job, ask two questions: (a) does the reshape make this Job *easier or harder* to deliver? (b) does the reshape preserve the substrate this Job depends on (markdown specs in `specs/`, line-anchored evidence, contributor-readable without agent invocation)? J4 is the falsifiability test — if the reshape moves spec state into agent-mediated forms or breaks markdown-on-disk readability, J4 fails and the reshape bends. If all four come out better or unchanged, the reshape is confirmed.
- **Phase 3 — skill design.** Each shipped skill (Explore, Review) must trace to at least one Job. Skills that don't trace to a Job are candidates for removal from scope.
- **Future review of new rules.** A new reviewer rule must trace to a Job (most often J1 or J3). Rules without a Job mapping are candidates for cutting.
- **Iteration triggers.** Update this doc when: (a) a fourth Job emerges from real usage, (b) an Anti-Job is contradicted by an actual feature request that turned out to be in-scope, (c) the persona set changes, (d) the reshape lands and changes the user surface.
