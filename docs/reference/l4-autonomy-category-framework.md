---
status: reference
date: 2026-04-12
owner: nic
type: reference
version: 1.0.0
---

# Information categories for L4 autonomous agent success

A standalone reference defining the 25 information categories required for an autonomous AI agent to succeed at spec-driven software engineering at L3 (human-in-the-loop) and L4 (human-on-the-loop) autonomy. Synthesized from requirements engineering standards (IEEE 29148, ISO/IEC 25010:2023, Volere, SWEBOK v4), empirical agent research (SWE-bench, SWE-bench Verified, METR, FeatureBench, SlopCodeBench), industry guidance (Anthropic, Cognition AI), and a comparative inventory of seven modern spec-driven development frameworks.

---

## 1. Purpose and scope

This document answers one question: **what information categories must exist in a specification for an autonomous software engineering agent to succeed without a human in the execution loop?**

It is not a workflow proposal, not a framework comparison, and not a recommendation for any particular tool. It is a coverage taxonomy derived from the research literature and cross-validated against production benchmarks.

**Why this matters.** The difference between L3 and L4 autonomy is exactly the difference between "some categories missing is fine because a human fills them in" and "every applicable category must be populated and machine-verifiable." Empirically, specs that are "adequate" for a human reviewer are materially incomplete for an autonomous agent. This document enumerates what adequate actually means at L4.

**Autonomy levels** (adapted from SAE J3016 for autonomous systems):

| Level | Name | Human role | Implication for spec |
|-------|------|-----------|----------------------|
| L0 | Manual | Human writes everything | Spec is documentation |
| L1 | Assisted | Agent suggests, human writes | Spec is guidance |
| L2 | Partial | Agent writes, human reviews every change | Spec is context |
| L3 | Conditional | Agent executes tasks, human reviews before merge | Spec must describe what to build |
| **L4** | **High (on-the-loop)** | **Agent executes, human supervises overall loop** | **Spec must describe what to build AND when to stop** |
| L5 | Full | Agent operates without supervision | Spec must describe everything including self-correction |

L4 is the target state for systems like Tack Room, Cognition's Devin, and autonomous PR pipelines. The category requirements grow materially at L4 because the human is no longer the last line of defense for underspecification.

---

## 2. The empirical foundation

Three benchmark studies and one frontier research program establish the difference between human-adequate and agent-adequate specifications.

### 2.1 SWE-bench Verified — the underspecification rate

OpenAI's SWE-bench Verified study ([Chowdhury et al., August 2024](https://openai.com/index/introducing-swe-bench-verified/)) is the strongest empirical evidence that human-adequate specs fail for agents. The study took 1,699 randomly sampled SWE-bench instances and had 93 professional Python developers annotate each one for specification quality. Results:

- **38.3% flagged as underspecified problem statements** — the issue description alone was insufficient for an agent to determine what to build, even with the full repository, base commit, and hints text provided.
- **61.1% flagged as unfair unit tests** — the FAIL_TO_PASS tests did not match the specification intent, meaning agents could not self-verify completeness.
- **68.3% of the original sample filtered out** after combining all disqualification criteria.

The study methodology is publicly documented. OpenAI explicitly acknowledges the filter is "likely overzealous" but defends it as yielding high-confidence feasibility assessments. The 1,699 → 500 sample reduction is the Verified benchmark.

**Implication**: even with a full repository snapshot, exact base commit, hidden test suite, and hints text, more than a third of real GitHub issues are not specified well enough for an autonomous agent. The gap between "human-adequate" and "agent-adequate" is a 38-percentage-point gap, not a rounding error.

### 2.2 METR — task horizon as the dominant failure mode

METR's [*Measuring AI Ability to Complete Long Tasks*](https://metr.org/blog/2025-03-19-measuring-ai-ability-to-complete-long-tasks/) (March 2025) established that the primary driver of autonomous agent failure is not skill but task horizon length. The study timed human experts on a battery of software engineering and reasoning tasks, ran frontier models on the same tasks, and fitted logistic curves mapping model success probability to human task duration.

Headline finding: **the length of tasks AI can complete has been doubling approximately every 7 months for the last 6 years.**

Published 50%-success horizons (per the blog's updated table):
- Claude 3.7 Sonnet: ~1 hour of human task duration
- Claude Opus 4.5: ~293 minutes (≈4.9 hours) of human task duration

**Implication**: agents fail at long-horizon tasks not because they lack skill but because they lose coherence over extended action sequences. This means task decomposition belongs *inside the spec* — breaking long tasks into shorter ones directly improves success probability without requiring better models. It also means specs must include stopping conditions to detect when an agent has exceeded its reliable horizon.

### 2.3 FeatureBench — size vs success rate

[*FeatureBench: Benchmarking Agentic Coding for Complex Feature Development*](https://arxiv.org/abs/2602.10975) (ICLR 2026, LiberCoders) contrasts agent performance on minor patches vs full feature implementations. The dataset-level comparison is stark:

| Benchmark | Avg gold-patch size | Files modified | Problem statement length | Claude Opus 4.5 resolve rate |
|-----------|--------------------:|---------------:|-------------------------:|-----------------------------:|
| SWE-bench | 32.8 lines | 1.7 | 195 words | **74.4%** |
| FeatureBench | 790.2 lines | 15.7 | 4,818 words | **11.0%** |

A 24× increase in code size and a 25× increase in problem statement length correspond to a **6.7× drop in success rate** from the same model. FeatureBench reports a negative correlation between pass rate and code length (Figure 5) without publishing explicit size-bin buckets.

**Implication**: autonomous agent performance collapses as the unit of work grows. This is additional empirical evidence for category 21 (task decomposition) and for explicit scope limits (category 3).

### 2.4 SlopCodeBench — monotonic quality degradation

[*SlopCodeBench: Benchmarking How Coding Agents Degrade Over Long-Horizon Iterative Tasks*](https://arxiv.org/abs/2603.24755) (March 2026) measured 11 coding agents across 20 problems at 93 checkpoints each, tracking code quality as iteration count grows.

Key findings:
- Verbosity increases in **89.8%** of agent trajectories, structural erosion in **80%** — both independent of correctness
- Agent code is **2.2× more verbose** than comparable human open-source code
- Core functionality pass rates hold up; **error-handling and regression pass rates collapse** as trajectories progress
- No agent solves any problem end-to-end across the 11 tested models; the highest checkpoint solve rate is 17.2%
- "Agent metrics climb monotonically; human metrics plateau"

**Implication**: agent quality degrades monotonically with context accumulation. The only reset is a fresh context window. This validates context fill limits (the 60-70% rule in Tack Room architecture) and argues that stopping conditions must fire before degradation dominates.

### 2.5 Task decomposition as a success predictor

[*Advancing Agentic Systems: Dynamic Task Decomposition, Tool Integration and Evaluation*](https://arxiv.org/abs/2410.22457) (NeurIPS 2024 workshop, Gabriel et al.) reports that **Structural Similarity Index (SSI) is the most significant predictor of sequential task performance** across the benchmarks tested. The paper introduces SSI as a metric for how closely an agent's task breakdown matches a reference decomposition, and finds it dominates other predictors in regression analysis.

**Implication**: how a task is decomposed predicts success more than which model runs it. Decomposition quality should be specified upfront, not emergent.

### 2.6 Anthropic — building effective agents

Anthropic's [*Building Effective Agents*](https://www.anthropic.com/engineering/building-effective-agents) (December 2024) is the canonical industry reference for agent design. Two load-bearing quotes:

> "A good tool definition often includes example usage, edge cases, input format requirements, and clear boundaries from other tools."

> "One rule of thumb is to think about how much effort goes into human-computer interfaces (HCI), and plan to invest just as much effort in creating good agent-computer interfaces (ACI)."

The post distinguishes *workflows* (LLMs in predetermined code paths) from *agents* (LLMs dynamically directing their own tool use) and names tool boundary specification as a foundational requirement.

Anthropic's follow-up [*Effective Harnesses for Long-Running Agents*](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) (November 2025) adds a two-agent architecture: an **initializer agent** sets up `init.sh`, `claude-progress.txt`, and an initial git commit; a **coding agent** makes incremental progress in every subsequent session. Design rule: work on one feature at a time.

**Implication**: tool boundaries, agent-computer interfaces, and progress checkpointing are first-class spec concerns at L4, not implementation details.

---

## 3. The 25 categories

The categories are grouped into three bands: build-correctness (what to build), operations-envelope (when to hand off), and meta (traceability and known unknowns). Each category is numbered; the numbering is used throughout the comparative coverage tables in §4.

### Band A — Build-correctness categories

#### Cat 1 — Purpose / Jobs-to-be-done

**Definition**: The underlying goal the change serves, framed as the outcome the user is trying to achieve, not the feature being built.

**Why it matters at L4**: Without an explicit purpose statement, an agent optimizes for the literal wording of the request rather than the underlying outcome. When requirements conflict or edge cases arise, the agent has no basis for judgment. JTBD framing specifically separates *stable desired outcomes* from *solution prescriptions*, so the spec remains valid even as implementation approaches change.

**Failure mode if missing**: Agent ships what was literally requested but not what was needed. Silent misalignment between output and intent.

**Sources**:
- Tony Ulwick — Outcome-Driven Innovation framework, [Strategyn](https://strategyn.com/jobs-to-be-done/) and [Anthony Ulwick](https://anthonyulwick.com/outcome-driven-innovation/)
- Ulwick — [*Inventing the Perfect Customer Need Statement*](https://jobs-to-be-done.com/inventing-the-perfect-customer-need-statement-4fb7de6ba999) — canonical format definition
- Volere Requirements Template §1 (Purpose), [Robertson & Robertson](https://www.volere.org/templates/volere-requirements-specification-template/)
- IEEE/ISO/IEC 29148:2018 — Business/Mission Analysis section, [ISO standard page](https://www.iso.org/standard/72089.html)

**Format**: Desired Outcome Statements follow Ulwick's canonical structure — *"Direction of improvement (verb) + metric (unit of measure) + object of control + contextual clarifier."* Example: *"Minimize the time it takes to get the songs in the desired order for listening."* Must be stable, measurable, and solution-agnostic.

**Example**: *"When a reviewer lands on a PR page, they want to see findings grouped by severity so they can triage in under 30 seconds."* Stable (the triage need persists regardless of implementation), measurable (30 seconds), solution-agnostic (doesn't specify how to group or display).

---

#### Cat 2 — Stakeholders and personas

**Definition**: The people and roles whose needs are being served, with sufficient context for the agent to calibrate defaults and resolve trade-offs.

**Why it matters at L4**: When requirements conflict (e.g., performance vs accessibility), the agent needs to know whose needs take precedence. Without persona context, the agent cannot calibrate UX defaults or resolve "who decides."

**Failure mode if missing**: Agent makes generic choices that don't match the actual user population. Silent misalignment on every judgment call.

**Sources**:
- IEEE/ISO/IEC 29148:2018 — Stakeholder Requirements Specification (StRS) section
- Volere Requirements Template §2 (Stakeholders)
- [BMAD Method PRD personas](https://docs.bmad-method.org/)

**Example**: "Primary: senior IC engineers who run 5+ concurrent PRs per day. Secondary: eng managers reviewing PRs for quality gating. Tertiary: new hires using PR feedback as learning signal. Precedence: primary > secondary > tertiary when conflicts arise."

---

#### Cat 3 — Scope (in / out / deferred)

**Definition**: Explicit boundaries listing what is in scope, what is out of scope with reason, and what is deferred to future work.

**Why it matters at L4**: SWE-bench Verified annotators specifically flagged scope ambiguity as a top failure mode. Agents either gold-plate (adding out-of-scope features) or delete adjacent features thinking they're unrelated to the change. Explicit scope prevents both.

**Failure mode if missing**: Uncontrolled scope drift. Agent either over-delivers (wastes time, ships broken extras) or under-delivers (misses adjacent requirements).

**Sources**:
- Volere §5 (Scope of Work) and §27 (Waiting Room for deferred items)
- [BMAD MVP scope guidance](https://docs.bmad-method.org/)
- IEEE/ISO/IEC 29148:2018 scope definition

**Example**:
- In scope: add severity badges to findings, update the PR comment template, add tests
- Out of scope: changing the severity rubric itself, adding new severity levels (requires ADR)
- Deferred: SARIF export format (Q3 2026), GitHub Check annotations

---

#### Cat 4 — Glossary / domain terms

**Definition**: Shared vocabulary with definitions, maintained across all specification documents so the agent uses consistent terminology.

**Why it matters at L4**: Without a glossary, agents invent synonyms when writing code, tests, and docs. The result is semantic drift between layers — the code says "reviewer," the test says "auditor," the docs say "evaluator." Humans can reconcile these; autonomous agents compound the drift.

**Failure mode if missing**: Terminology divergence across code/tests/docs, leading to broken tests and misleading documentation.

**Sources**:
- Volere §5 (Naming Conventions and Definitions)
- IEEE/ISO/IEC 29148:2018 SRS §1.3 (Definitions, acronyms, abbreviations)

**Example**: "Finding: a single issue detected by a reviewer agent. Severity: one of Critical/High/Medium/Low per constitution clause CONST-REV-03. Reviewer: any agent implementing the ReviewerAgent interface (see `specs/interfaces/reviewer.md`)."

---

#### Cat 5 — Functional requirements (EARS or equivalent)

**Definition**: Atomic, testable, uniquely-IDed behaviors using a structured notation like EARS (Easy Approach to Requirements Syntax) or WHEN/THEN scenarios.

**Why it matters at L4**: Without crisp FRs, there's no way to verify done. EARS decomposition forces requirements into patterns that map directly to test cases: ubiquitous ("The system shall..."), event-driven ("When X, the system shall..."), state-driven ("While X, the system shall..."), optional ("Where feature X, the system shall..."), unwanted ("If X, then the system shall..."), and complex combinations.

**Failure mode if missing**: Agent cannot self-verify completeness. Human must babysit every iteration.

**Sources**:
- IEEE/ISO/IEC 29148:2018 SRS §3.2 (Functional requirements)
- Alistair Mavin et al., EARS notation paper (RE'09)
- [BMAD PRD functional requirements](https://docs.bmad-method.org/)
- [GitHub Spec Kit `specify.md`](https://github.com/github/spec-kit)
- [OpenSpec WHEN/THEN scenarios](https://github.com/Fission-AI/OpenSpec)

**Example**: "FR-042: When a reviewer finding has severity Critical, the system shall block PR merge until the finding is resolved or explicitly dismissed by a user with the `override-critical` permission."

---

#### Cat 6 — Non-functional / quality attributes

**Definition**: Quality characteristics the system must satisfy, specified quantitatively. The authoritative taxonomy is ISO/IEC 25010:2023's nine characteristics.

**Why it matters at L4**: An agent can ship functionally correct code that's unusable in production. NFR quantification with baseline/target/measurement method gives the agent a machine-checkable standard.

**Failure mode if missing**: Functionally correct but unusably slow, insecure, or unreliable code. Discovered only in production.

**Sources**:
- [ISO/IEC 25010:2023 — Product quality model](https://www.iso.org/standard/78176.html)
- [ISO/IEC 25010:2023 update guide (arc42 Quality)](https://quality.arc42.org/articles/iso-25010-update-2023)
- Volere §10–17 (covering Look & Feel, Usability, Performance, Operational, Maintainability, Security, Cultural, Compliance)
- IEEE/ISO/IEC 29148:2018 quality attributes

**The nine ISO/IEC 25010:2023 quality characteristics** (updated from the 8 in the 2011 revision):

1. **Functional Suitability** — does the system do what's needed?
2. **Performance Efficiency** — does it do it fast enough?
3. **Compatibility** — does it coexist with other systems?
4. **Interaction Capability** — can users use it effectively? (renamed from "Usability" in 2011)
5. **Reliability** — does it keep working?
6. **Security** — is it protected?
7. **Maintainability** — can it be modified?
8. **Flexibility** — can it run in varied environments? (renamed from "Portability" in 2011)
9. **Safety** — does it avoid harming people, data, or the environment? (**new in 2023**)

The 2023 revision also added subcharacteristics: Inclusivity and Self-descriptiveness (under Interaction Capability), Resistance (under Security), and Scalability (under Flexibility). Replaced "User Interface Aesthetics" → "User Engagement" and "Maturity" → "Faultlessness."

**Example**: "NFR-012: p99 API latency shall be under 250ms measured at the ingress layer over rolling 5-minute windows, baseline 450ms current median, target achieved via caching layer (see ADR-007)."

---

#### Cat 7 — Constraints

**Definition**: Non-negotiable technical, organizational, regulatory, or budget limits that bound the solution space before any design choices.

**Why it matters at L4**: Without explicit constraints, the agent chooses banned languages, prohibited dependencies, or disallowed architectures. Constraints are the fastest way to prevent huge classes of failure without enumerating forbidden options.

**Failure mode if missing**: Agent picks a forbidden stack element, wastes the iteration, and discovers the constraint only via human review.

**Sources**:
- Volere §3 (Mandated Constraints)
- IEEE/ISO/IEC 29148:2018 §5.2.6 (Design constraints)
- SWEBOK v4 Chapter 1 — Software Requirements, [IEEE Computer Society SWEBOK](https://www.computer.org/education/bodies-of-knowledge/software-engineering)

**Example**: "Must run on Bun (not Node). Must not add new npm dependencies requiring native compilation. Must not call external services other than GitHub API and Anthropic API. Compliance: data must stay in us-east-1 per GDPR."

---

#### Cat 8 — Assumptions and facts

**Definition**: Explicit statement of what is taken as true without verification, paired with a validation plan for how each assumption will be tested.

**Why it matters at L4**: METR's findings show that long-horizon tasks fail from compounding wrong assumptions. An agent that makes silent assumptions has no way to detect when they're wrong — the first failure appears hours in, and the root cause is invisible.

**Failure mode if missing**: Cascade failures from assumptions that were never validated, with no clear trace back to the wrong assumption.

**Sources**:
- Volere §4 (Relevant Facts and Assumptions)
- METR 2025 findings on long-horizon task failure

**Example**: "Assumption: the existing `ReviewerAgent` interface is stable and will not change during this work. Validation: run `grep ReviewerAgent` across the codebase before starting; if the interface changes during the work, restart the change with an updated baseline."

---

#### Cat 9 — Preconditions / environment state

**Definition**: The starting state required for the work to begin: repository commit, environment variables, secrets, services running, data fixtures.

**Why it matters at L4**: SWE-bench encodes preconditions explicitly as `repo + base_commit + environment_setup_commit` because without them, agents cannot reproduce the starting state and flail in setup. Anthropic's *Building Effective Agents* names "ground truth from the environment" as foundational for autonomous execution.

**Failure mode if missing**: Agent can't reproduce the starting state, wastes iterations on setup, or fails because the environment drifted between runs.

**Sources**:
- SWE-bench dataset schema ([HuggingFace `princeton-nlp/SWE-bench`](https://huggingface.co/datasets/princeton-nlp/SWE-bench))
- [SWE-bench paper (Jimenez et al. 2023, ICLR 2024)](https://arxiv.org/abs/2310.06770)
- Anthropic, [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)

**Example**: "Base commit: `abc123`. Environment: Node 20.x, Bun 1.1+. Services: local Postgres at port 5432 with schema `test_reviewer`. Required env vars: `ANTHROPIC_API_KEY`, `GITHUB_TOKEN`. Starting fixtures: `tests/fixtures/review-baseline.json`."

---

#### Cat 10 — Interface contracts

**Definition**: Typed schemas for API, CLI, event, and data boundaries the change crosses, including error taxonomies and versioning policy.

**Why it matters at L4**: Integration breakage is invisible until runtime without explicit contracts. The agent cannot know whether it's allowed to change a signature, add a field, or deprecate an endpoint. Interface contracts make boundary stability reviewable independently of implementation.

**Failure mode if missing**: Silent integration breakage. Downstream consumers fail in production.

**Sources**:
- IEEE/ISO/IEC 29148:2018 §5.2.4 (External interfaces)
- OpenAPI Specification — REST API schemas
- AsyncAPI — event-driven schemas
- Protocol Buffers — typed RPC

**Example**: "POST `/api/reviews/{pr}` — request schema: `{findings: Finding[], severity: Severity}`. Response schema: `{accepted: boolean, merge_blocked: boolean, errors?: Error[]}`. SLA: p99 < 500ms, 99.9% availability. Error codes: 200/400/401/403/429/500. Rate limit: 60 req/min per token. Versioning: breaking changes require `/api/v2/`."

---

#### Cat 11 — Data model / entities

**Definition**: Schemas for domain entities, their invariants, relationships, and evolution rules.

**Why it matters at L4**: An agent touching a database without a data model will invent columns, break foreign key constraints, and write migrations that corrupt data. The data model is the single source of truth for entity structure that code, tests, and docs must align with.

**Failure mode if missing**: Invented DB columns, broken FK constraints, migrations that corrupt data.

**Sources**:
- Volere §5 (Business Data Model)
- [BMAD Architect document](https://docs.bmad-method.org/)
- Domain-Driven Design (Evans) — aggregates and entities

**Example**: "`Finding` aggregate root: `id: uuid`, `pr_id: int`, `severity: enum(critical|high|medium|low)`, `message: string`, `created_at: timestamptz`. Invariants: a finding cannot change severity after creation (CONST-REV-03). Relationships: one-to-many with `PR`, many-to-many with `Reviewer` via `review_attribution`."

---

#### Cat 12 — Architecture

**Definition**: System structure — components, their responsibilities, layering rules, allowed call directions, and technology choices with rationale.

**Why it matters at L4**: Without architectural context, the agent drops code in random files and violates intended layering. Architecture specifies where the change lives, what it can call, and what it cannot.

**Failure mode if missing**: Code scattered across the wrong files. Layering violations that degrade the system over time.

**Sources**:
- [arc42 architecture template](https://arc42.org/)
- C4 model (Simon Brown) — Context, Containers, Components, Code
- [BMAD Architect doc](https://docs.bmad-method.org/)
- [GitHub Spec Kit `plan.md`](https://github.com/github/spec-kit)

**Example**: "Review pipeline has three layers: ingress (parses PR events), reviewer (runs individual reviewer agents), aggregator (combines findings). Layering rule: ingress → reviewer → aggregator, no reverse calls. New reviewer agents must implement `ReviewerAgent` interface (§5 of `specs/interfaces/reviewer.md`) and register via `src/reviewers/registry.ts`."

---

#### Cat 13 — Architectural decision records with rationale

**Definition**: Persistent records of architectural decisions with context, drivers, considered options, decision, and consequences. MADR 4.0 adds an optional Confirmation field for compliance.

**Why it matters at L4**: Without ADRs, an agent "improves" things by silently reversing prior decisions whose justification it never saw. This is the single strongest argument for ADRs in autonomous workflows — **they're rationale cache**. An agent encountering a counterintuitive design choice should be able to find the ADR that explains why.

**Failure mode if missing**: Agent re-litigates settled decisions. Valuable trade-offs silently reversed. Over time, architectural intent is lost.

**Sources**:
- [MADR 4.0 — Markdown Architectural Decision Records](https://adr.github.io/madr/) (released 2024-09-17)
- Michael Nygard's original ADR format
- ADR community: https://adr.github.io/

**MADR 4.0 structure**: Context and Problem Statement, Decision Drivers (optional), Considered Options, Decision Outcome, Consequences (optional), **Confirmation** (optional — how compliance will be verified), Pros and Cons of the Options (optional), More Information (optional).

**Example**: ADR-007 "Use reviewer agent ensemble for severity classification" — Context: single-reviewer approaches miss class of errors. Drivers: accuracy, explainability, latency budget. Options: single reviewer, ensemble, hybrid. Decision: ensemble with checklist + bogey agents. Consequences: 2× API cost, 1.4× latency. Confirmation: nightly benchmark against labeled finding dataset, regression fails CI.

---

#### Cat 14 — Constitution / inviolable principles

**Definition**: Meta-rules that override everything else — non-negotiable constraints on behavior that apply across all changes regardless of context.

**Why it matters at L4**: Under local pressure from a specific task, an agent will violate baseline norms (security, compliance, quality) if they're not stated as constitutional. "Never write to main," "all code TDD," "no secrets in logs" — these need to be unambiguously above any local trade-off.

**Failure mode if missing**: Agent violates baseline norms to ship faster or meet a specific requirement. Security or compliance breakage in production.

**Sources**:
- [GitHub Spec Kit constitution](https://github.com/github/spec-kit)
- BMAD principles layer
- IEEE 29148 organizational constraints

**Example**: "CONST-SEC-01: No secrets in log output under any circumstances. CONST-PROC-02: All behavioral changes require an ADR. CONST-REV-03: Severity classifications are immutable after creation."

---

#### Cat 15 — Acceptance criteria / fit criteria

**Definition**: Measurable, testable "done" criteria for each functional requirement, ideally executable as automated tests.

**Why it matters at L4**: SWE-bench Verified found 61.1% of original tasks had **unfair tests** — acceptance criteria that don't match the spec intent. This is the failure mode Verified was created to fix. At L4 the agent must self-verify, which requires acceptance criteria that exactly encode the spec's intent.

**Failure mode if missing**: Agent cannot determine when it's done. Humans become the acceptance oracle and the L4 loop breaks.

**Sources**:
- Volere Fit Criterion methodology
- [SWE-bench Verified](https://openai.com/index/introducing-swe-bench-verified/) — encodes criteria as FAIL_TO_PASS + PASS_TO_PASS tests
- [BMAD Gherkin acceptance](https://docs.bmad-method.org/)
- Given/When/Then (Gherkin) notation

**Example**: "FR-042 acceptance: given a PR with one Critical finding, when a user without `override-critical` attempts to merge, then the merge is blocked with HTTP 403 and error message `CRITICAL_FINDINGS_UNRESOLVED`. Encoded as `tests/integration/pr-merge-block.test.ts::critical-blocks-merge`."

---

#### Cat 16 — Test strategy

**Definition**: Layered test approach covering unit, integration, contract, end-to-end, performance, and chaos levels. Specifies which layer covers which risk, coverage targets, test data, and environments.

**Why it matters at L4**: Without a strategy, agents write tests that pass but don't cover the risk surface. Test strategy turns "tests pass" into "tests validate the right invariants at the right layer."

**Failure mode if missing**: Tests that pass locally but don't catch real failure modes. False confidence.

**Sources**:
- IEEE/ISO/IEC 29148:2018 §6 (Verification)
- Test pyramid (Mike Cohn)
- Test trophy (Kent C. Dodds)

**Example**: "Unit: every reviewer agent's classify() method, ≥90% branch coverage. Integration: full review pipeline against fixture PRs, ≥20 test cases. Contract: reviewer agent interface, schema-checked. E2E: smoke test against staging with real GitHub API. Performance: p99 latency budget 500ms verified via k6 nightly."

---

#### Cat 17 — Success metrics

**Definition**: How the change will be measured in production — baseline, target, measurement method, and timeline for validation.

**Why it matters at L4**: Without success metrics, the agent can't tell "working" from "working and valuable." For rollback decisions, the agent (or its supervisor) needs quantified signals. Ulwick's ODI framework makes the case that desired outcomes must be *stable, measurable, and controllable*.

**Failure mode if missing**: No basis for rollback decisions. No way to distinguish "technically working" from "actually valuable."

**Sources**:
- [Ulwick Desired Outcome Statements](https://jobs-to-be-done.com/inventing-the-perfect-customer-need-statement-4fb7de6ba999)
- Volere §16 (Performance Requirements)
- BMAD success metrics section

**Example**: "Baseline: median triage time 3.5 minutes per PR. Target: under 30 seconds median, measured via instrumented reviewer dashboard. Method: Datadog custom metric `pr.triage.duration_s`, p50 rolling 7-day window. Validation: 2-week post-deploy window, rollback if baseline not improved by 50%."

---

#### Cat 18 — Failure modes / unhappy paths

**Definition**: Explicit enumeration of error states, recoverability expectations, and unwanted behaviors. EARS "unwanted behavior" (If/then) pattern is purpose-built for this.

**Why it matters at L4**: Agents write happy-path code by default. Without explicit failure modes, edge-case bugs cascade in production. FMEA tradition (Failure Modes and Effects Analysis) treats unhappy paths as first-class spec concerns.

**Failure mode if missing**: Happy-path-only code. Edge cases surface in production as user-facing bugs.

**Sources**:
- EARS unwanted-behavior pattern (Mavin et al.)
- FMEA tradition (origin: US military reliability engineering)
- IEEE/ISO/IEC 29148:2018

**Example**: "FR-042 unwanted behaviors: If the severity classifier times out (>5s), then the system shall default to 'needs-review' and alert the team channel. If a reviewer agent crashes, then its findings shall be dropped and the ensemble shall proceed with remaining reviewers. If all reviewers fail, then the system shall block merge with error `REVIEW_UNAVAILABLE`."

---

#### Cat 19 — Security / threat model

**Definition**: Trust boundaries, authentication and authorization requirements, data sensitivity classification, compliance constraints (GDPR/HIPAA/SOC2/etc), and systematic threat enumeration (STRIDE, LINDDUN, attack trees).

**Why it matters at L4**: An autonomous agent introducing an auth bypass or PII leak is a catastrophic failure. Threat models make the attack surface visible and force the agent to consider malicious inputs, not just correct ones.

**Failure mode if missing**: Auth bypass introduced silently. PII logged without redaction. Compliance violations discovered in audit.

**Sources**:
- ISO/IEC 25010:2023 Security subcharacteristics — confidentiality, integrity, authenticity, accountability, non-repudiation
- Volere §15 (Security Requirements)
- Microsoft STRIDE threat modeling
- LINDDUN privacy threat modeling

**Example**: "Trust boundary: reviewer agent runs in the same process as the aggregator but must not access raw PR content beyond the diff. Data sensitivity: finding messages may contain file paths (low-risk) but must not contain code content (PII risk if PR modifies secrets). STRIDE: Spoofing (low — agents authenticated via signed manifest), Tampering (medium — mitigated by fresh context), Repudiation (low), Information Disclosure (high — logs must redact file contents), Denial of Service (medium — rate limited), Elevation of Privilege (low)."

---

### Band B — Operations-envelope categories

These four categories determine when the agent must yield control. They are the defining difference between L3-ready and L4-ready specifications.

#### Cat 20 — Tool inventory / capability bounds

**Definition**: Explicit enumeration of tools the agent can call, what each does, allowed vs forbidden operations, destructive-operation policy, and authentication scopes.

**Why it matters at L4**: The agent needs to know the boundary of its own capability. Without it, the agent either refuses safe actions (under-confident) or runs destructive ones (over-confident). Anthropic's *Building Effective Agents* names this as foundational — "example usage, edge cases, input format requirements, and clear boundaries from other tools."

**Failure mode if missing**: Destructive operations executed without authorization. Or: safe operations refused because the agent couldn't tell they were allowed.

**Sources**:
- [Anthropic — Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents) (December 2024)
- [Anthropic — Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) (November 2025)
- [Cognition AI — Devin](https://cognition.ai/blog/introducing-devin) harness scaffold
- Supervisory control theory (Ramadge & Wonham)

**Example**: "Allowed tools: `git` (all read ops, commit, push to branches matching `feature/*`, never to `main`), `bun test`, `gh pr create`, `gh pr comment`. Forbidden: `git push --force`, `gh pr merge`, `rm -rf`, any call touching `.env*` files. Escalation required for: schema migrations, dependency upgrades, any file matching `specs/constitution.md`."

---

#### Cat 21 — Task decomposition / plan

**Definition**: Ordered steps, dependencies, parallelizable units, and acceptance criteria per task. METR's finding that horizon length drives failure makes this category critical — decomposition *inside the spec* directly improves success probability.

**Why it matters at L4**: METR 2025 demonstrates that agents fail at long-horizon tasks because they "struggle with stringing together longer sequences of actions more than they lack skills." The research on task decomposition ([Gabriel et al., NeurIPS 2024 workshop](https://arxiv.org/abs/2410.22457)) reports that Structural Similarity Index — how closely an agent's decomposition matches a reference — is the most significant predictor of sequential task performance. Decomposition quality predicts success more than model quality.

**Failure mode if missing**: Agent flails on sequencing. Long tasks collapse. Task horizon becomes the bottleneck.

**Sources**:
- [METR 2025 — Measuring AI Ability to Complete Long Tasks](https://metr.org/blog/2025-03-19-measuring-ai-ability-to-complete-long-tasks/)
- [Gabriel et al. 2024 — Advancing Agentic Systems: Dynamic Task Decomposition](https://arxiv.org/abs/2410.22457)
- [OpenSpec `tasks.md`](https://github.com/Fission-AI/OpenSpec)
- [GitHub Spec Kit `tasks.md`](https://github.com/github/spec-kit)
- BMAD user stories format
- Devin's plan structure

**Example**:
```
Task 1: Add severity enum to Finding entity
  Depends on: none
  Acceptance: `Finding.severity` field exists with enum constraint, migration runs cleanly
Task 2: Wire severity into reviewer ensemble
  Depends on: Task 1
  Parallelizable: yes, with Task 3
  Acceptance: each reviewer emits severity, aggregator merges by max
Task 3: Add severity badge UI
  Depends on: Task 1
  Parallelizable: yes, with Task 2
  Acceptance: badge renders with correct color, matches constitution palette
Task 4: Wire merge block
  Depends on: Task 2
  Acceptance: critical finding blocks merge per FR-042 test
```

---

#### Cat 22 — Stopping conditions / escalation triggers

**Definition**: Explicit conditions under which the agent must stop executing and hand off to a human or supervisor. Iteration limits, confidence thresholds, protected path touches, ambiguity detection, environmental anomalies.

**Why it matters at L4**: **This is the category that defines when the human is pulled back into the loop.** Without it, the agent either loops forever or commits to decisions it shouldn't make. Supervisory control literature treats explicit handoff conditions as the foundational requirement for human-on-the-loop systems.

**Failure mode if missing**: Agent loops. Or commits bad decisions. Or fails silently without alerting.

**Sources**:
- [Anthropic — Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents) (max iterations, checkpoints)
- On-the-loop supervisory control literature (Ramadge & Wonham 1987, and descendants)
- [Cognition AI Devin](https://cognition.ai/blog/introducing-devin) scaffold

**Example**:
- Stop and escalate if: iteration count > 10, confidence < 0.6 on any decision, any file in `specs/constitution.md` is touched, any migration would drop a column, any test in `tests/contract/` fails, any dependency added or removed, total token spend > $5.
- Alert channel: `#reviewer-escalations` on Slack
- Timeout: escalate if no progress (no commit) for 15 minutes

---

#### Cat 23 — Rollout / rollback plan

**Definition**: Deployment steps, feature flags, migration ordering, and rollback procedure with explicit criteria for when to invoke rollback.

**Why it matters at L4**: Autonomous agents will merge things that need to be reverted. Without explicit rollback criteria and procedure, every L4 change is a one-way door. IEEE 29148 Operational Concept and Volere §23 (Migration) treat this as first-class.

**Failure mode if missing**: Agent merges breaking changes. Rollback becomes a manual scramble.

**Sources**:
- IEEE/ISO/IEC 29148:2018 Operational Concept section
- Volere §23 (Migration)
- Continuous delivery literature (Humble & Farley)

**Example**: "Rollout: deploy behind `reviewer_severity_v2` feature flag at 0%. Gradually ramp to 5/25/50/100% over 7 days with 2-hour soak at each stage. Rollback criteria: error rate > 0.5% or p99 latency > 750ms at any stage → immediate flag disable, investigation before next attempt. Rollback procedure: `flagctl disable reviewer_severity_v2 --env=prod`, confirm via `flagctl status`, post-mortem within 24 hours."

---

### Band C — Meta categories

#### Cat 24 — Traceability

**Definition**: Bidirectional links connecting requirement ↔ code ↔ test ↔ ADR ↔ interface. Every change must be able to answer "which requirement does this serve?" and "which code satisfies this requirement?"

**Why it matters at L4**: When deciding whether to refactor, the agent needs to know what a given piece of code is for. Without traceability, the agent can't distinguish "incidental implementation detail" from "load-bearing requirement satisfier." IEEE 29148 explicitly mandates traceability as a first-class concern.

**Failure mode if missing**: Agent refactors away load-bearing code thinking it's incidental. Requirements go uncovered silently.

**Sources**:
- IEEE/ISO/IEC 29148:2018 (mandates traceability)
- [SWEBOK v4 Chapter 1](https://www.computer.org/education/bodies-of-knowledge/software-engineering)
- ISO/IEC 25010:2023 (Maintainability — Analysability sub-characteristic)

**Example**: "FR-042 is satisfied by `src/reviewer/severity.ts:blockCriticalMerge()` and tested by `tests/integration/pr-merge-block.test.ts`. ADR-007 justifies the ensemble approach used in this code path. Interface `ReviewerAgent` in `specs/interfaces/reviewer.md` is implemented here."

---

#### Cat 25 — Open questions / known unknowns

**Definition**: Explicit register of ambiguities, unresolved decisions, and known unknowns — each with an owner and target resolution date.

**Why it matters at L4**: Without an explicit ambiguity register, the agent silently picks an answer and commits. The human supervisor has no way to distinguish "this was decided" from "this was guessed." Making uncertainty visible is a prerequisite for supervised autonomy.

**Failure mode if missing**: Agent silently resolves ambiguity without flagging. Wrong choices baked in without review.

**Sources**:
- BMAD "Open Questions" section
- Volere §18 (Open Issues)
- arc42 "Risks and Technical Debt"

**Example**: "OQ-1: Should severity downgrades (Critical → High) require an override permission? Owner: @reviewer-team-lead. Target: before rollout to production. OQ-2: What's the retention policy for findings after a PR is closed? Owner: @compliance. Target: 2026-04-30."

---

## 4. Comparative coverage across modern frameworks

Legend: **Y** = structurally captured, **P** = partial / implicit, **N** = missing.

| # | Category | OpenSpec | Spec Kit | Superpowers | GSD-2 | BMAD | Archon v3 | Devin |
|---|----------|:--------:|:--------:|:-----------:|:-----:|:----:|:---------:|:-----:|
| 1 | Purpose / JTBD | P | P | N | Y | Y | Y | N |
| 2 | Stakeholders / personas | N | P | N | P | Y | Y | N |
| 3 | Scope in/out | P | Y | P | Y | Y | Y | N |
| 4 | Glossary | N | N | N | N | P | N | N |
| 5 | Functional reqs (EARS) | Y | Y | P | P | Y | Y | N |
| 6 | NFRs / ISO 25010 | N | P | N | N | Y | Y | N |
| 7 | Constraints | N | P | N | Y | Y | Y | N |
| 8 | Assumptions / facts | N | N | N | Y | P | P | N |
| 9 | Preconditions / env | N | P | N | Y | P | N | P |
| 10 | Interface contracts | N | N | N | N | P | P | N |
| 11 | Data model | N | P | N | N | Y | Y | N |
| 12 | Architecture | P | Y | Y | N | Y | Y | N |
| 13 | ADRs w/ rationale | N | N | N | Y | P | N | N |
| 14 | Constitution | N | Y | N | N | P | N | N |
| 15 | Acceptance criteria | P | P | P | N | Y | Y | N |
| 16 | Test strategy | N | N | N | N | P | P | N |
| 17 | Success metrics | N | N | N | N | Y | Y | N |
| 18 | Failure modes | N | N | N | N | P | P | N |
| 19 | Security / threat | N | N | N | N | P | P | N |
| 20 | Tool inventory | N | N | N | N | N | N | Y |
| 21 | Task decomposition | **Y** | **Y** | N | N | Y | Y | Y |
| 22 | Stopping conditions | N | N | N | N | N | N | P |
| 23 | Rollout / rollback | N | N | N | N | P | P | N |
| 24 | Traceability | P | P | N | P | Y | P | N |
| 25 | Open questions | N | N | N | P | Y | Y | N |
| **Y+P total** | | 6 | 10 | 3 | 8 | 17 | 14 | 5 |

### Observations

1. **Task decomposition (Cat 21) is the category most consistently captured by execution-focused frameworks** (OpenSpec, Spec Kit, BMAD, Archon, Devin) but absent from the spec-authoring frameworks (Superpowers, GSD-2). This reflects a division of labor: some tools treat decomposition as spec concern, others as runtime concern.

2. **Tool inventory (Cat 20) is essentially absent everywhere except Devin.** Even then, Devin captures it implicitly in its harness scaffold, not as a first-class spec artifact. This is the largest gap in the entire landscape for L4 readiness.

3. **Stopping conditions (Cat 22) are absent from every framework** except as implicit Devin runtime behavior. This is the definitive gap between current spec frameworks and L4-ready systems.

4. **Rollout / rollback (Cat 23) is nearly universal as a gap.** Requirements frameworks assume a human operator will figure out rollout at release time. This breaks for L4 autonomy.

5. **Failure modes (Cat 18) are captured structurally only by EARS-based frameworks and BMAD's Gherkin acceptance.** Every other framework leaves unhappy paths implicit.

6. **ADRs with rationale (Cat 13) are surprisingly rare as first-class artifacts** in modern agent frameworks — only GSD-2's DECISIONS.md treats them as required context. Most assume they exist somewhere but don't integrate them into the work package.

7. **The modern agent frameworks cluster into two shapes**: execution-focused (OpenSpec, Spec Kit, Devin — strong on tasks and architecture, weak on NFR/constitution/failure modes) and authoring-focused (BMAD, Archon — strong on persona/PRD/success metrics, weaker on tool bounds and stopping conditions). Neither shape alone covers the L4 surface.

---

## 5. The minimum viable spec for L4 autonomy

Converging across all sources, **12 categories** constitute a true floor for L4 autonomous execution. A spec missing any of these is materially incomplete:

1. **Cat 1** — Purpose / JTBD
2. **Cat 3** — Scope (in/out/deferred)
3. **Cat 5** — Functional requirements with IDs
4. **Cat 6** — Non-functional / quality attributes
5. **Cat 7** — Constraints
6. **Cat 9** — Preconditions / environment
7. **Cat 10** — Interface contracts (at any boundary touched)
8. **Cat 12** — Architecture with layering rules
9. **Cat 13** — ADRs with rationale
10. **Cat 15** — Acceptance criteria as executable tests
11. **Cat 20** — Tool inventory / capability bounds
12. **Cat 21** — Task decomposition
13. **Cat 22** — Stopping conditions (12 + 1: escalation is non-negotiable for on-the-loop)

Everything else is valuable but can be inferred, deferred, or added as the system matures. These 13 are the categories that, if missing, cause silent failures that humans cannot detect until production.

---

## 6. Meta-findings

### Consistently cited as make-or-break

Four categories appear in every serious source (IEEE 29148, ISO 25010, Volere, Anthropic, METR, SWE-bench Verified):

1. **Preconditions / environment state** (Cat 9) — SWE-bench had to encode exact base_commit because agents cannot reproduce without it.
2. **Acceptance criteria as executable tests** (Cat 15) — 61.1% of original SWE-bench tasks failed at this level.
3. **Task decomposition** (Cat 21) — METR's headline finding is that horizon length, not skill, drives failure.
4. **Tool boundaries and stopping conditions** (Cat 20 + 22) — Anthropic's *Building Effective Agents* names these as foundational.

### Underserved by most frameworks

The most striking gap across OpenSpec, Spec Kit, Superpowers, BMAD, Archon, and Devin is **Cat 20 (tool inventory / bounds)** and **Cat 22 (stopping conditions / escalation triggers)**. These are exactly the categories an on-the-loop system needs most — they define when the agent must yield control. Only Devin's harness captures them, and only implicitly in runtime scaffolding, not as spec artifacts.

**Cat 23 (rollout / rollback)** is also nearly universal as a gap; requirements frameworks assume a human operator will figure it out at release time, which breaks for L4 autonomy.

**Cat 18 (failure modes)** is captured structurally only by EARS-based frameworks and BMAD's Gherkin acceptance — everyone else leaves unhappy paths implicit.

### Surprises

- **SWE-bench Verified's 38.3% underspecification rate** is the strongest empirical argument that "human-adequate" and "agent-adequate" specs differ in kind, not degree. Humans project context that agents cannot.
- **ISO 25010's 2023 revision added Safety as a first-class quality characteristic**, directly in response to autonomous-systems concerns. The standards body is explicitly acknowledging L4 as a design target.
- **Every academic framework assumes ADRs exist** but none of the modern agent frameworks except GSD-2 treats them as required context for execution. MADR 4.0's addition of a "Confirmation" field (how compliance will be verified) is a direct move toward agent-executable decisions.
- **JTBD/ODI's Desired Outcome Statements** map almost 1:1 onto what autonomous agents need for goal representation — yet no agent framework cites JTBD explicitly.
- **FeatureBench's 6.7× drop in success rate** from SWE-bench (32.8 lines, 1.7 files, 195-word statement, 74.4% resolve) to FeatureBench (790.2 lines, 15.7 files, 4,818-word statement, 11.0% resolve) is the quantitative proof that scope matters more than model.

### What's emerging

The convergence of these sources suggests that **L4 autonomy requires a category taxonomy that's larger than any single current framework provides** and specifically must add the operations-envelope categories (20–23). The next generation of spec tools will likely define themselves by L4 readiness rather than doc templates or elicitation flow — the underlying question is not "what does a spec look like" but "what does an autonomous agent need to know to succeed without me watching every step."

---

## 7. Bibliography

### Standards

- **ISO/IEC/IEEE 29148:2018** — *Systems and software engineering — Life cycle processes — Requirements engineering*. [ISO page](https://www.iso.org/standard/72089.html). Published 2018, replaced IEEE 830-1998 / 1233-1998 / 1362-1998. Defines BRS, StRS, SyRS, and SRS specification types. [SEBoK overview](https://sebokwiki.org/wiki/Software_Requirements). Template mirror at [ReqView](https://www.reqview.com/doc/iso-iec-ieee-29148-templates/).

- **ISO/IEC 25010:2023** — *Systems and software engineering — Systems and software Quality Requirements and Evaluation (SQuaRE) — Product quality model*. [ISO page](https://www.iso.org/standard/78176.html). Published 2023. Revised from 8 to 9 quality characteristics, adding Safety as a new top-level characteristic. [arc42 guide to the 2023 update](https://quality.arc42.org/articles/iso-25010-update-2023).

- **SWEBOK v4** — *Guide to the Software Engineering Body of Knowledge, Version 4.0*. Edited by Hironori Washizaki, published October 15, 2024 by IEEE Computer Society. Chapter 1 covers Software Requirements. [IEEE Computer Society page](https://www.computer.org/education/bodies-of-knowledge/software-engineering). Direct PDF at [ieeecs-media](https://ieeecs-media.computer.org/media/education/swebok/swebok-v4.pdf).

### Empirical research

- **Jimenez, C. E., Yang, J., Wettig, A., Yao, S., Pei, K., Press, O., & Narasimhan, K.** (2023). *SWE-bench: Can Language Models Resolve Real-World GitHub Issues?* [arXiv:2310.06770](https://arxiv.org/abs/2310.06770). Published at ICLR 2024. Dataset schema on HuggingFace: [`princeton-nlp/SWE-bench`](https://huggingface.co/datasets/princeton-nlp/SWE-bench).

- **OpenAI** (2024). *Introducing SWE-bench Verified*. Published August 13, 2024. [OpenAI index page](https://openai.com/index/introducing-swe-bench-verified/). 93 professional Python developers screened 1,699 random samples. Headline findings: **38.3% flagged as underspecified problem statements**, **61.1% flagged as unfair FAIL_TO_PASS tests**, **68.3% of samples filtered out** in total.

- **METR** (2025). *Measuring AI Ability to Complete Long Tasks*. Published March 19, 2025. [METR blog](https://metr.org/blog/2025-03-19-measuring-ai-ability-to-complete-long-tasks/). Headline finding: the length of tasks AI can complete has been doubling approximately every 7 months for the last 6 years. Published 50%-success horizons: ~1 hour for Claude 3.7 Sonnet, ~293 minutes (≈4.9 hours) for Claude Opus 4.5.

- **LiberCoders** (2026). *FeatureBench: Benchmarking Agentic Coding for Complex Feature Development*. [arXiv:2602.10975](https://arxiv.org/abs/2602.10975). Published at ICLR 2026. Cross-benchmark comparison: Claude Opus 4.5 resolves 74.4% of SWE-bench tasks (avg 32.8 lines, 1.7 files, 195-word problem statements) but only 11.0% of FeatureBench tasks (avg 790.2 lines, 15.7 files, 4,818-word statements) — a 6.7× drop in success rate with a 24× increase in code size. GitHub: [LiberCoders/FeatureBench](https://github.com/LiberCoders/FeatureBench).

- **SlopCodeBench authors** (2026). *SlopCodeBench: Benchmarking How Coding Agents Degrade Over Long-Horizon Iterative Tasks*. [arXiv:2603.24755](https://arxiv.org/abs/2603.24755). Published March 25, 2026. 20 problems × 93 checkpoints × 11 models. Findings: verbosity increases in 89.8% of agent trajectories, structural erosion in 80%, agent code is 2.2× more verbose than comparable human code, error-handling and regression pass rates collapse monotonically as trajectories progress, no agent solves any problem end-to-end across the 11 tested models.

- **Gabriel, A. G., Ahmad, A. A., & Jeyakumar, S. K.** (2024). *Advancing Agentic Systems: Dynamic Task Decomposition, Tool Integration and Evaluation using Novel Metrics and Dataset*. [arXiv:2410.22457](https://arxiv.org/abs/2410.22457). NeurIPS 2024 workshop. Introduces Structural Similarity Index (SSI) as the most significant predictor of sequential task performance.

### Industry guidance

- **Anthropic** (December 2024). *Building Effective Agents*. [anthropic.com/engineering](https://www.anthropic.com/engineering/building-effective-agents). Establishes the distinction between workflows (LLMs in predetermined paths) and agents (LLMs dynamically directing their own tools). Key quotes: *"A good tool definition often includes example usage, edge cases, input format requirements, and clear boundaries from other tools"* and *"Think about how much effort goes into human-computer interfaces, and plan to invest just as much effort in creating good agent-computer interfaces (ACI)."*

- **Anthropic** (November 2025). *Effective Harnesses for Long-Running Agents*. [anthropic.com/engineering](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents). Two-agent architecture: initializer sets up `init.sh`, `claude-progress.txt`, and an initial commit; coding agent makes incremental progress in every subsequent session. Related: [Harness Design for Long-Running Application Development](https://www.anthropic.com/engineering/harness-design-long-running-apps).

- **Cognition AI** (March 2024). *Introducing Devin*. [cognition.ai/blog](https://cognition.ai/blog/introducing-devin). First major autonomous software engineering agent; 13.86% SWE-bench resolve rate (vs 1.96% prior SOTA). Updated at [Devin 2.0](https://cognition.ai/blog/devin-2).

- **MADR 4.0** — *Markdown Architectural Decision Records, version 4.0*. Released September 17, 2024. [adr.github.io/madr](https://adr.github.io/madr/). Template fields: Context and Problem Statement, Decision Drivers (optional), Considered Options, Decision Outcome, Consequences (optional), Confirmation (optional), Pros and Cons of the Options (optional), More Information (optional).

### Jobs-to-be-done / outcome-driven innovation

- **Ulwick, A.** — [Strategyn: Jobs-to-be-Done](https://strategyn.com/jobs-to-be-done/). Corporate page for ODI methodology.
- **Ulwick, A.** — [Outcome-Driven Innovation](https://anthonyulwick.com/outcome-driven-innovation/). Ulwick's personal site.
- **Ulwick, A.** — [*Inventing the Perfect Customer Need Statement*](https://jobs-to-be-done.com/inventing-the-perfect-customer-need-statement-4fb7de6ba999). Canonical format for Desired Outcome Statements: *Direction of improvement (verb) + metric + object of control + contextual clarifier.*

### Requirements templates

- **Volere Requirements Specification Template** by James and Suzanne Robertson, Atlantic Systems Guild. [volere.org](https://www.volere.org/templates/volere-requirements-specification-template/). 27 sections across Project Drivers (1–3), Project Constraints (3–5), Functional Requirements (6–9), Non-functional Requirements (10–17), and Project Issues (18–27).

### Modern agent frameworks

- **OpenSpec** (Fission AI) — [github.com/Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec). Spec-driven development for AI coding assistants. Flow: `/opsx:explore` → `/opsx:propose` → `/opsx:apply` → `/opsx:archive`.
- **Spec Kit** (GitHub) — [github.com/github/spec-kit](https://github.com/github/spec-kit). GitHub's open-source toolkit for Spec-Driven Development.
- **Superpowers** (obra) — [github.com/obra/superpowers](https://github.com/obra/superpowers). Composable skills framework enforcing brainstorm → plan → execute → review with two-stage subagent verification.
- **GSD-2** (gsd-build) — [github.com/gsd-build/gsd-2](https://github.com/gsd-build/gsd-2). Meta-prompting and context-engineering framework with state machine execution, fresh context windows per task.
- **BMAD Method** (bmad-code-org) — [github.com/bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD). 12+ specialized agent personas (PM, Architect, Dev, QA) with agile-structured workflows. Docs at [docs.bmad-method.org](https://docs.bmad-method.org/).
- **Archon v3** (coleam00) — [github.com/coleam00/Archon](https://github.com/coleam00/Archon). Harness builder framing with workflow orchestration for AI coding tasks.

---

## 8. Changelog

- **1.0.0** (2026-04-12) — Initial publication. 25-category framework derived from IEEE 29148 / ISO 25010:2023 / Volere / SWEBOK v4 standards, SWE-bench Verified / METR / FeatureBench / SlopCodeBench empirical research, and Anthropic / Cognition AI industry guidance. Comparative coverage across 7 modern agent frameworks. Minimum viable spec for L4 defined as 13 categories.
