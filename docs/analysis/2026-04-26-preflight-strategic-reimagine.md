# Preflight strategic reimagine — analysis for posterity

**Date:** 2026-04-26
**Last updated:** 2026-04-26 (post-conversation; recommendation evolved through 4 iterations)
**Context:** Friction signal from maintainer (Nic) — too many ADR/requirements review rounds, not enough functional progress. Question: reimagine preflight, drop it, or pivot the roadmap?
**Method:** FirstPrinciples (Deconstruct + Challenge), IterativeDepth (4 lenses), Council (4-perspective debate), RedTeam (decompose + steelman + counter-argument), industry research (60-day window, 6 frameworks), repo-state quantification (background agent), spike-status truth check (background agent), workstream HANDOFF harvest (3 dispatch artifacts).
**Status:** Snapshot. The roadmap (`docs/plans/2026-04-26-preflight-roadmap.md`) carries the trackable execution plan.

---

## TL;DR (final)

Preflight's friction is structural, not process-volume in the abstract. The **48 rules + reviewer ensemble are the moat**; industry data confirms nobody else ships this. Templates are inputs to elicitation, not the user-facing surface. The lifecycle/governance scaffolding (ADR-007 feature folders, CONST-PROC-02 recursion, day-60 tripwire, multi-pass adversarial review on docs-only ADRs, ADR-011 forward-declared before ADR-007 validates) is process accretion that the field has been actively shedding during the same 60-day window preflight got heavier.

**Final recommendation: drop spec-kit, ship as a Claude Code skill bundle invoked during spec creation/modification. Preflight's value is helping users build, modify, review, and re-read the durable project harness their agents execute against — driven by deep elicitation, smart doc-type routing, and gap-catching reviewers. Templates and rules are valuable inputs to that workflow (a secondary but important surface), not the primary user-facing interface.**

---

## Recommendation evolution (transparency)

The recommendation iterated 4 times during the analysis conversation. Recording the evolution because the path is itself useful data:

| Turn | Recommendation | What changed |
|---|---|---|
| 1 | **Option B — throttle the engine, run Spike 2** | Initial synthesis from Council + RedTeam |
| 2 | **Stay on spec-kit with discipline** | After verifying spec-kit conversion was real value (multi-agent reach claim) |
| 3 | **Drop spec-kit, ship as skill bundle (α + small β)** | After auditing actual spec-kit utilization — one command + 7 templates, no hooks, no chain participation. Conversion sunk-cost was anchoring me. |
| 4 (final) | **Drop spec-kit, ship as PAI orchestrator with deep elicitation + gap-catching reviewers** | Maintainer rejected manual "create this document" interface. The value is the *workflow* (elicitation → routing → drafts → gap review), not template-picking |

Each turn was driven by new evidence, not opinion change. Spec-kit utilization audit (`presets/preflight/preset.yml` declares only templates; `extensions/preflight/extension.yml` registers only `speckit.preflight.review`) was decisive.

---

## What the data showed

### Repo state (April 2026)

- **97 commits in April** (2026-04-01 to 2026-04-26)
- **9 ADRs** (002–010); ADR-007 still **Proposed** after **12 revisions over 11 days**
- **ADR-010** merged after 4 commits, **3 of 4 being adversarial-review-finding commits** (Council, Codex×2)
- **Spike 2/3/4/5** of ADR-007's validation plan have not started
- **SPIKE_PLAN.md header is stale** — says "Phase 0" while Phase 1 closed and Spike 1 partially ran on `test-pai-preset` worktree
- **One real feature shipped** in April (CONST-R04 broaden, closes #13); rest is process working on itself

### ADR cycle quantification

| ADR | Lines | Status | Proposed | Latest | Elapsed | Revisions | Review-finding commits |
|-----|-------|--------|----------|--------|---------|-----------|------------------------|
| 007 | 285 | Proposed | 2026-04-13 | 2026-04-24 | 11 days | 12 | 7 |
| 008 | 169 | Accepted | 2026-04-22 | 2026-04-23 | 1 day | 5 | 2 |
| 009 | 229 | Accepted | 2026-04-24 | 2026-04-24 | <1 day | 8 | 3 |
| 010 | 175 | Proposed | 2026-04-25 | 2026-04-26 | 1 day | 4 | 3 |

**Cascade depth:** ADR-007 → constitution + requirements (PR #42) → ADR-010 narrow rewrite → forward-declared ADR-011 (gated on Spike 2). Average cascade: 1.75 levels per ADR.

### Spec-kit actual utilization (decisive finding)

Audit of `presets/preflight/preset.yml`, `extensions/preflight/extension.yml`, and the `commands/` directory:

- **Preset:** ships 7 markdown templates (ADR, RFC, architecture, constitution, interface-contract, requirements, test-strategy). No commands.
- **Extension:** registers ONE command (`speckit.preflight.review`). No after_* hooks (removed per ADR-009). No /clarify, /plan, /tasks, /implement overrides.
- **Multi-agent reach via spec-kit's `CommandRegistrar`:** theoretical — no evidence the maintainer ever invoked preflight review from Cursor or Copilot.

**Cost-benefit verdict:** the entire ADR-007/008/009/010 governance burden, plus pre-1.0 API churn risk, plus `.specify/memory/` path constraint, plus day-60 tripwire calendar tax — all in service of one command's auto-registration and seven templates being copied into a target project. The benefit is near-zero in practice; the cost is the entire recent ADR cycle.

### Workstream HANDOFF harvest

Three `.dispatch/HANDOFF.md` artifacts captured key history:

- **Main HANDOFF (2026-04-13):** ADR-007's original convergence — "Feature folder is the unit of in-flight change," `/preflight:explore` named as elicitation entry point. **The maintainer wanted deep-elicitation tooling from day one.** Today's reframe ("PAI orchestrator with deep elicitation") is consistent with original intent.
- **workflow-research HANDOFF (2026-04-24):** Stream A (spike execution) + Stream B (upstream tracking) framing. B5 verdict captured: spec-kit's `optional: false` hooks were never contracted to block; enforcement was always intentionally delegated to host agent. Spike 1 closed; ADR-008 accepted.
- **speckit-upstream-tracking HANDOFF (2026-04-26):** Concrete record of the ADR-010 v1 → v2 → v3 → v3a multi-pass review chain. Documents *exactly* the friction pattern under analysis. Substrate-Skeptic synthesis won; substrate-neutral wording produced the tautology problem.

These HANDOFFs are themselves valuable archive material — they capture decision rationale that's otherwise distributed across commits and Notion. Action: move to `archive/handoffs/`.

### Issue 111 (pai-source) — corrected

The "test-pai-preset is contaminated by 3 spec-review iterations" framing is **partly wrong**. The 3 passes are *authorship iterations* producing a clean v3 (`56ba71c` spec, `4e3ad8c` plan), not separate stale commits. **However, the underlying signal is correct**: PAI Algorithm v3.7's OBSERVE/THINK/PLAN already does atomic ISC decomposition, premortem, capability selection, and reverse-engineering. Spec-kit's `/speckit.plan` chain pre-decomposes work that PAI does better natively.

### Industry research (60-day window)

| Framework | Direction in last 60d |
|-----------|----------------------|
| **spec-kit** v0.8.1 | **Shipped a "lean preset" 2026-04-24** — official acknowledgment chain is too heavy; issue #543 documents "every `/analyze` finds new CRITICAL issues" loop |
| **BMAD** v6.5 | v6.3 collapsed 4 personas (QA/SM/quick-flow/dev) into 1 (Amelia); removed `spec-wip.md` singleton |
| **OpenSpec** v1.3.1 | Markets "no rigid phase gates"; 3-command primary path |
| **Anthropic Skills** | Anthropic ships **Skills, not specs**; agentskills.io is the standard |
| **Beads** | "Replaces messy markdown plans" with Dolt-backed graph DB |
| **PAI** v4.0.3 | "Lean and Mean" — cut startup context from 38% to 19% |

**Convergence (3+ frameworks):**
1. **Skills as the unit, not specs.** Anthropic, BMAD, spec-kit (v0.8 `SkillsIntegration`) — three converging on Skills standard.
2. **Lighter primary chain, optional rigor on the side.** OpenSpec, spec-kit (lean preset), BMAD — all moved this direction.
3. **Markdown plan stacks under attack.** Beads, BMAD v6.3, OpenSpec — all explicitly position against multi-doc spec piles.

**Negative space — what nobody else does:**
- Nobody ships a 48-rule reviewer rubric
- Nobody runs a two-agent reviewer ensemble by default
- Nobody requires an ADR for every behavioral requirement change

The 48-rule rubric is preflight's unique asset; the other two heavinesses are friction.

**One-sentence answer to "what should a spec for an autonomous agent look like":** A short, decomposed, machine-readable artifact (skill, story, change-folder, or PRD with atomic ISC criteria) that lives inside the agent's tool boundary — *not* a stack of human-authored markdown gates the agent has to traverse before touching code.

---

## Diagnosis: three structural traps

### Trap 1: Recursive ADR engine

CONST-PROC-02 ("ADR on every behavioral requirement change") fires on the rewrites that try to clean up prior ADRs. ADR-010 → forward-declares ADR-011 (doesn't exist) → blocked on Spike 2 (hasn't run) → ADR-007 (Proposed) gates spike acceptance criteria. The engine fuels itself.

### Trap 2: Stale plan masquerading as live governance

`SPIKE_PLAN.md` header still says `Current phase: 0 — pre-spike setup` (dated 2026-04-13). Reality: Phase 0 closed, Phase 1 closed, Spike 1 in progress on test-pai-preset, Spike 2/3 not started. The work *looks* stuck because the artifact wasn't updated — not because work isn't happening.

### Trap 3: Substrate-decoupled abstraction creep

ADR-010 went "substrate-neutral" to avoid Spike 2 contamination. CONST-DIST-01 v1.2.0 was concrete: "auto-load via `.claude/rules/`, no CLAUDE.md edits." Under v2.0.0 it became substrate-neutral and nearly tautological. **Reviewers find ambiguity in tautologies forever.** v3 + v3a + P2 v3a is exactly that pattern.

### Trap 4 (added): the value-add was misframed

The original ADR-007 framing positioned **feature-folder lifecycle** as the value-add. The actual value-add is **deep elicitation + gap-catching reviewers** — exactly what the maintainer wanted from day one (per the 2026-04-13 HANDOFF naming `/preflight:explore` as the elicitation entry point). OpenSpec's explore and Superpowers' brainstorming are "almost there" — they just don't ask enough questions and don't have reviewers that catch gaps like "no testing plan" or "this is conflicted/incomplete." Preflight's moat is *making this workflow work*, not the lifecycle ceremony around it.

---

## The reframed value-add

Preflight is a **PAI-invoked workflow** that drives spec generation through three skills:

### Skill 1: Explore (elicitation + routing)
- User states intent: "I want to add X"
- Workflow asks **deep questions** — more than OpenSpec's explore, more than Superpowers' brainstorming
- Workflow determines which preflight document types apply to the intent (RFC for design exploration? requirements update? architecture delta? new ADR? test-strategy update?)
- Workflow drafts the affected docs

### Skill 2: Review (existing — keep and beef up)
- Checklist reviewer (existing): 48-rule conformance
- Bogey reviewer (existing): cross-doc consistency, assumption conflicts
- **Gap reviewer (new):** explicitly catches gap classes — "no testing plan," "no rollback plan," "no observability story," "no failure modes," "no rate-of-change consideration"
- Returns structured findings (file:line:severity:rule)

### How preflight is invoked (phased)

The invocation surface phases in over time:

**Phase A — direct user invocation (initial shape):** The user invokes `/preflight:explore` directly in a NATIVE PAI session when they're starting a feature, modifying the harness, or evolving a spec. The skill does its workflow, returns drafts + review findings, the user iterates and resolves open questions. **Human review of the explore output is required before BUILD** — this is non-negotiable in the initial shape. Once the explore output is reviewed, fixed, and clean, BUILD proceeds against it.

**Phase B — PAI two-phase orchestration (later):** PAI's Algorithm fleshes out `/preflight:explore` from a human input statement, then the user reviews/PRs the explore output before BUILD. Same review gate, less ceremony to start the workflow. This is where the original "PAI invokes preflight during BUILD" framing eventually lands — but it's later work, not initial state.

In both phases, templates and rules are inputs to the workflow. The user does not pick templates as a starting point — but they see and can adjust the doc-type routing decisions the workflow makes.

### What preflight ships

```
.claude/skills/preflight/
  SKILL.md                      # entry point + workflow routing
  Workflows/
    Explore.md                  # deep elicitation + doc-type routing + draft generation
    Review.md                   # rule check + reviewer ensemble + gap reviewer
  rules/                        # 48 rules (the moat)
    universal-rules.md
    constitution-rules.md
    requirements-rules.md
    architecture-rules.md
    rfc-rules.md
    adr-rules.md
    cross-doc-rules.md
  templates/                    # 6 templates (constitution dropped)
    adr-template.md
    rfc-template.md
    architecture-template.md
    requirements-template.md
    interface-contract-template.md
    test-strategy-template.md
  agents/
    checklist-reviewer.md
    bogey-reviewer.md
    gap-reviewer.md             # NEW
```

No `.specify/`, no `preset.yml`, no `extension.yml`, no spec-kit dependency.

---

## What's dropped

| Item | Reason |
|---|---|
| Spec-kit dependency | Cost-benefit doesn't pencil; one-command utilization vs entire ADR cycle burden |
| `.specify/memory/constitution.md` (preflight's self-constitution) | Preflight is a tooling project; doesn't need self-governance beyond a 1-page README |
| `constitution.md` template (downstream) | CLAUDE.md + architecture.md cover what constitutions try to do; constitution-as-genre is partly spec-kit framing |
| ADR-007 (feature-folder lifecycle) | Worktrees + direct main edits replace apply/archive ceremony; two-tier FR lookup unnecessary when worktrees provide isolation |
| ADR-010 (constitution + requirements rewrite) | Withdrawn — replaced by smaller cleanup (drop self-constitution, simplify requirements) |
| ADR-009 (integration topology) | Superseded by spec-kit drop |
| ADR-011 (forward-declared) | Never authored; reference dropped |
| Day-60 tripwire (2026-06-13) | Calendar theater; spec-kit ecosystem watch no longer relevant |
| Spike 2 / Spike 3 | Cancelled — validating a lifecycle that's being superseded |
| `presets/preflight/`, `extensions/preflight/` | Replaced by `.claude/skills/preflight/` skill bundle |

## What's kept and protected

| Item | Why |
|---|---|
| 48 rules | The moat — nobody else ships this |
| Reviewer ensemble (checklist + bogey) | Unique to preflight; industry's `/analyze` equivalents have the "every iteration finds new criticals" loop |
| 6 templates (no constitution) | Inputs to the Explore workflow; they encode rule expectations |
| Issue-traceability rule | Sound governance; survives substrate change |
| `architecture.md` template (downstream) | High-value — concrete constraints PAI consumes during OBSERVE |
| The CONST-PROC-02 spirit | Tightened: ADR only for rule kernel changes or major downstream architecture |
| Worktree workflow | Already in use; replaces ADR-007's apply/archive ceremony |

---

## What changes about the user experience

**Before (current):**
- User invokes `/speckit.specify`, gets a spec.md
- User fills it out
- User runs `/speckit.preflight.review`
- User decides which other docs to update
- User authors them
- User runs review again
- Repeat

**After (target — Phase A, direct invocation):**
- User invokes `/preflight:explore` in a NATIVE PAI session: "I want to add OAuth login"
- Explore asks deep questions until coverage thresholds met (the thresholds are themselves rules)
- Explore determines: this needs an RFC + requirements delta + architecture delta + test-strategy delta
- Explore drafts all four
- Review skill runs — reports gaps ("no rollback plan in RFC," "test-strategy doesn't cover OAuth state edge cases")
- User clarifies, fixes, iterates against the surfaced findings
- **Human review of the explore output is required before BUILD** — this gate is non-negotiable initially
- Once explore output is clean and human-reviewed, BUILD proceeds

**After (target — Phase B, PAI two-phase, later):**
- User states intent to PAI; PAI invokes Explore on the user's behalf
- Explore output lands as a draft for the user to review/PR before BUILD
- Same human-review gate; less ceremony at the start

The user does not pick a template or manually decide doc types. The workflow drives doc-type routing; the user reviews and adjusts the decisions.

---

## Failure modes to monitor

1. **Explore asks too many questions.** Tunable: coverage thresholds per doc type. Run on real features and dial in.
2. **Doc-type routing misses a category.** Tunable: routing rules can be added. Treat as a rule-kernel change (gets an ADR).
3. **Gap reviewer hallucinates gaps.** Mitigation: gap categories are an enumerated list (no testing, no rollback, no observability, etc.), not free-form. Reviewer checks each category explicitly; can't invent new ones outside the list.
4. **PAI Algorithm doesn't know when to invoke preflight.** Mitigation: SKILL.md uses standard PAI skill activation triggers ("specify", "spec", "RFC", "ADR", "requirements"); PAI's capability selection in OBSERVE picks it up.
5. **The skill bundle install path is fragile.** Mitigation: ship as a top-level `preflight/` directory, copyable via `cp -r preflight/.claude/skills/preflight <target>/.claude/skills/preflight`. No package manager.

---

## Capability invocation record

The Algorithm runs that produced this analysis selected and invoked these capabilities:

- **FirstPrinciples (Deconstruct + Challenge):** Decomposed preflight; classified hard/soft/assumption constraints. Key insight: rules + reviewer ensemble are the entire fundamental value.
- **IterativeDepth (4 lenses):** Failure / Temporal / Constraint Inversion / Meta. Meta lens reframed "reimagine vs drop" as "shrink to kernel."
- **Council (4 perspectives, 3 rounds):** Architect / Engineer / Researcher / Designer. Designer's "what does the user want" question hinted at JTBD gap.
- **RedTeam (5-phase):** Decomposed Council recommendation, steelmanned, counter-argued. Refined "strip to kernel" to "throttle the engine" (then later evidence pushed it back to "drop spec-kit").
- **Industry research agent:** 6 frameworks, 60-day window, sources cited.
- **Repo-state quantification agent:** ADR cycle volume, spike status truth, worktree audit.
- **Workstream HANDOFF harvest:** 3 `.dispatch/HANDOFF.md` artifacts read.
- **Spec-kit utilization audit:** Direct file inspection. Decisive in the recommendation pivot.

**Honest skill-theater note:** Council ran inline (4 personas × 3 rounds authored by primary agent) rather than as 12 parallel LLM calls. RedTeam ran inline (decomposition + steelman + counter-argument) rather than as 32 parallel agents. Both abbreviated forms of the workflow. Substance over ceremony, deliberate trade given context budget.

---

## References

- pai-source issue #111 — `/speckit.plan` vs PAI Algorithm spike proposal
- spec-kit issue #543 — repeated `/analyze` finds new CRITICAL issues every iteration
- spec-kit PR #2340 — official "lean preset" (2026-04-24)
- BMAD-METHOD release notes v6.3.0 — agent consolidation
- Beads README — "replaces messy markdown plans"
- ADR-007: feature folder lifecycle (Proposed) — superseded by worktree-direct-edit
- ADR-009: integration topology (Accepted) — superseded by spec-kit drop
- ADR-010: constitution + requirements rewrite (Proposed) — withdrawn
- `docs/spikes/SPIKE_PLAN.md` — to be archived
- `.dispatch/HANDOFF.md` (main, workflow-research, speckit-upstream-tracking) — to be archived
- `MEMORY/WORK/20260426-110024_preflight-strategic-reimagine-analysis/PRD.md` — full algorithm record (PAI session)
- `docs/plans/2026-04-26-preflight-roadmap.md` — trackable execution plan derived from this analysis
