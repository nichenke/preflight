# Phase 1.2 — JTBD re-evaluation of held design decisions

**Status:** Analysis only. Substrate for ADR-011 (reshape) and ADR-012 (delivery shape) in Phase 2.2.
**Source of truth tested against:** [`specs/jtbd.md`](../../specs/jtbd.md) v0.2 (jobs J1–J5, five personas, five user stories, four anti-jobs).
**Held decisions tested:** the eight from [`docs/analysis/2026-04-26-preflight-strategic-reimagine.md`](2026-04-26-preflight-strategic-reimagine.md), with decision (h) tested in its current form (Option B plugin per [`docs/analysis/2026-04-27-delivery-shape-options.md`](2026-04-27-delivery-shape-options.md)), not the abandoned skill-bundle form.

---

## Why this document exists

The 2026-04-26 strategic reimagine produced eight held decisions before `specs/jtbd.md` v0.1/v0.2 was published. Those decisions encoded a JTBD model implicitly — "what does the user actually want?" — but never tested it against an explicit JTBD doc. ADR-011 and ADR-012 in Phase 2.2 will ratify those decisions formally. Without this re-evaluation, those ADRs would ratify decisions whose JTBD basis hasn't been confirmed against the published model.

This document does not author either ADR. It produces the evidence both will cite.

## Method

For each held decision:
1. **JTBD need served:** which job(s), persona(s), user-story acceptance the decision optimizes for, with line citations.
2. **Counterargument:** the strongest opposing case, argued from jtbd v0.2 evidence (not from outside-doc preference).
3. **Anti-job check:** whether any of the four anti-jobs (jtbd v0.2 lines 67–70) constrain or invalidate the decision.
4. **Verdict:** *Confirm*, *Refine*, *Revise*, or *Flip* — see [Verdict legend](#verdict-legend) below.
5. **Risk severity if verdict is wrong:** Critical / High / Medium / Low — see [Verdict legend](#verdict-legend).

Two parallel analyses were run before synthesis: a JTBD-decomposition pass that mapped each decision to jobs/personas without voting, and an adversarial pass that argued the *opposing* verdict for each decision (counters confirmation bias). Verdicts here reflect the synthesis, not either pass alone.

Anti-job 1 at jtbd:67 ("Not for replacing PAI / agent ISC task decomposition, spec-kit, OpenSpec, or similar SDD frameworks") is read as **user-facing scope**, not implementation substrate — preflight is not a user-facing replacement for spec-kit, but is free to choose any internal substrate.

Anti-job ordinal-to-line mapping: anti-job 1 = jtbd:67, anti-job 2 = jtbd:68, anti-job 3 = jtbd:69, anti-job 4 = jtbd:70.

---

## Verdict legend

Verdict labels:

- **Confirm** — verdict holds as originally argued; no change to scope or framing.
- **Refine** — verdict and intent hold; framing or scope sharpened (e.g., a coarse rule narrowed to its actual failure mode, or a precondition replaced with a more reliable mechanism).
- **Revise** — verdict holds with a new precondition added that the original analysis didn't require.
- **Flip** — verdict reversed against the original 2026-04-26 reasoning.

Verdict cells in the matrix may include a short parenthetical qualifier (e.g., "Refine (empirical pruning)") to name the specific way the verdict was sharpened. These are descriptors of *how* the verdict applies in this case, not new verdict categories.

Hybrid labels (e.g., "Confirm with sunset", "Refine with mitigation") are not legal — collapse to the closest formal label, then use a parenthetical qualifier if the specific shape needs naming.

Severity if verdict is wrong: **Critical** / **High** / **Medium** / **Low**.

---

## Verdict matrix

The matrix has 10 rows over the 8 originally held decisions: decision (g) decomposes into three independent sub-decisions (g.1 process throttle on docs-only multi-pass, g.2 one-ADR-at-a-time, g.3 no forward-declared ADRs) tested separately because each carries its own JTBD evidence. References to "the eight held decisions" mean the original a–h grouping; references to "the ten decision-units" mean the matrix rows used for verdicts.

| # | Decision | Verdict | Primary JTBD evidence | Severity if wrong |
|---|---|---|---|---|
| (a) | Drop spec-kit substrate | **Confirm** | J5 motions; spec-kit utilization audit shows zero cross-agent invocation while ADR cycle is the governance burden | Low |
| (b) | Drop preflight's self-constitution | **Confirm** | J4/S4 names required read-set explicitly without constitution; J3 threshold; CLAUDE.md + architecture.md cover it | Low |
| (c) | Worktrees + direct main edits replace ADR-007 lifecycle | **Confirm** | J3 threshold + S3 routing is content-driven not folder-driven; lifecycle ceremony adds no traceability | Low |
| (d) | Tighten CONST-PROC-02 scope | **Confirm** | Anti-job 3 (jtbd:69, "not for behavior-change governance") *requires* this — the decision and the anti-job are co-defined | Low |
| (e) | Six templates (drop constitution-template) | **Confirm** | J1 enumeration (jtbd:27) names goals/rules/architecture/JTBD/interface contracts — no constitution | Low |
| (f) | New gap-reviewer agent | **Refine** (empirical pruning) | J2 + S1 explicitly name gap categories (jtbd:77); anti-job 1 risk addressed by per-category logging + empirical category pruning, not a theoretical pre-build audit | Medium |
| (g.1) | No multi-pass adversarial review on docs-only | **Refine** (sharpen framing) | Throttle on tautology drift, not docs-only as a category — multi-pass on substantive content remains useful | Low |
| (g.2) | One ADR proposed at a time | **Refine** (with sunset) | Damping mechanism for current cascade-thrash state; revisit once cascade thrash settles | Low |
| (g.3) | No forward-declared ADRs | **Confirm** | J3 + J4 require versioned-text traceability without speculative cross-references | Low |
| (h) | Ship as Option B plugin (project scope) | **Confirm** | J5 motions hold (delivery-shape lines 69–73); J4 does not reach into preflight's kernel (jtbd:55 scopes J4 to the project's durable bits; S4 line 90 declares per-project file set) | Low |

**Three refinements** (`(f)`, `(g.1)`, `(g.2)`); **seven straight confirms**. **No revisions, no flips.**

---

## Per-decision narratives

### (a) Drop spec-kit substrate — *Confirm*

- **JTBD need served:** J5 primarily (jtbd:57–63). The three motions — install / update / extend — don't depend on spec-kit; spec-kit utilization in preflight is one auto-registered command + seven copied templates with no cross-agent invocation. Indirectly serves J1 and J2 by removing the ADR cycle that the strategic-reimagine doc found to be the governance burden.
- **Counterargument:** Spec-kit ships ref-pinning, marketplace tooling, and `CommandRegistrar` multi-agent reach for free; dropping it forces preflight to re-derive its own delivery story.
- **Why the counterargument fails:** the multi-agent-reach claim is theoretical (no evidence it fires across Cursor/Copilot in practice); the ADR-007/008/009/010 cycle is the concrete cost.
- **Anti-job check:** Anti-job 1 (read as user-facing scope) doesn't constrain substrate choice. No collision.
- **Risk severity:** **Low.** Even if downstream demand for spec-kit-substrate-specific features surfaces, re-vendoring is cheap.

### (b) Drop preflight's self-constitution — *Confirm*

- **JTBD need served:** J4 (jtbd:49–55) — fewer files in the contributor read path. S4 acceptance (jtbd:88–90) names `requirements.md` + relevant ADRs + `architecture.md` and *does not* name a constitution. Indirectly serves J3 by removing ADR pressure on a doc that didn't carry architecture-sized decisions.
- **Counterargument:** preflight is exactly the kind of project J4 envisions, so it should eat its own dogfood and keep a constitution-shaped artifact.
- **Why the counterargument is medium-weak:** dogfooding is real but doesn't mandate the constitution shape; preflight's harness can be expressed as CLAUDE.md + requirements.md + ADRs + architecture.md and still satisfy S4.
- **Anti-job check:** Anti-job 4 ("not a constitution-checker for arbitrary projects") supports dropping. No collision.
- **Risk severity:** **Low.** Preserve the dogfood instinct as a sanity check after the Phase 3 reshape lands — confirm the resulting harness still satisfies S4 for preflight itself.

### (c) Worktrees + direct main edits replace ADR-007 lifecycle — *Confirm*

- **JTBD need served:** J3 (jtbd:41–47) and J4. J3's threshold is "would re-deriving this from scratch cost real time?" (jtbd:47); apply/archive ceremony doesn't meet that bar for routine harness edits. J4 benefits because direct edits keep `git log` as truth source.
- **Counterargument:** S3 wants "flag this needs an ADR" classification, and feature-folders provided that surface.
- **Why the counterargument fails:** S3's classification is content-driven (touches `architecture.md` or `interfaces/`), not folder-location-driven. Worktrees + a path-based rule satisfy S3 directly.
- **Anti-job check:** Anti-job 3 ("not for behavior-change governance") supports — feature-folder lifecycle was governance, not architecture traceability. No collision.
- **Risk severity:** **Low.**

### (d) Tighten CONST-PROC-02 scope — *Confirm*

- **JTBD need served:** J3 (jtbd:41–47). The decision aligns CONST-PROC-02's firing condition with J3's threshold: "would re-deriving this cost real time?" Rule-kernel changes and user-facing surface changes are exactly the architecture-sized choices J3 names.
- **Counterargument:** silent reversal is the failure mode strict CONST-PROC-02 was designed to prevent; loosening creates a judgment-call seam.
- **Why the counterargument fails:** **anti-job 3 (jtbd:69) directly negates the strict reading.** This is the most overdetermined decision in the set — jtbd v0.2 has an anti-job whose text was written specifically to retire strict CONST-PROC-02.
- **Anti-job check:** Anti-job 3 *requires* this scope tightening. Co-defined.
- **Risk severity:** **Low.** S3 acceptance (jtbd:86) provides the explicit falsification test.

### (e) Six templates (drop constitution-template) — *Confirm*

- **JTBD need served:** J1 (jtbd:25–32). The doc-type preset is templates' justifying job; J1 line 27 enumerates "goals, rules, architecture, JTBD, interface contracts" without constitution.
- **Counterargument:** adopters from spec-kit's flow may want a constitution-shaped artifact.
- **Why the counterargument is weak:** J1's "rules" maps cleanly to CLAUDE.md + rule files; constitution is a specific framing, not a universal need; no evidence of downstream demand.
- **Anti-job check:** Anti-job 4 supports dropping.
- **Risk severity:** **Low.** Cheap to revisit if a downstream project surfaces real demand.

### (f) Build a new gap-reviewer agent — *Refine* (empirical pruning)

- **JTBD need served:** J2 (jtbd:33–39) and J1 (S1, jtbd:77 — "failure modes, rollback plan, observability story"). The enumerated gap categories map directly onto J2's defect taxonomy plus S1's named questions.
- **Counterargument (with teeth):** Anti-job 1 (jtbd:67) says preflight is *not* for replacing PAI/agent task decomposition. Gap categories like "no rollback plan" / "no observability story" overlap PAI's pre-BUILD premortem and OBSERVE/THINK/PLAN structure. The strategic-reimagine doc compares gap-reviewer to *other frameworks'* explore steps but not to *PAI's own* premortem.
- **Why this requires a refinement, not a flip:** J2 and S1 are explicit and operate at the *spec-document level*, not the agent-task level — gap-reviewer audits "does this RFC have a rollback plan?", not "does this task decomposition have a rollback plan?" That's a defensible scope distinction. The boundary is close enough to anti-job 1 that duplication risk is real, but the right defense is **empirical, not gating**: instrument the agent with per-category finding logs and let measured findings prune scope. A theoretical pre-build audit answers a coverage question via paper analysis; empirical pruning answers it with what gap-reviewer actually finds vs. what PAI already catches.
- **Anti-job check:** Anti-job 1 (user-facing scope) does *not* invalidate; gap-reviewer is preflight's reviewer, not a replacement for PAI. Anti-job 2 ("not a CI gate") requires gap-reviewer to remain on-demand. Anti-job 1 is the live watch-item, addressed by empirical pruning rather than a build gate.
- **Risk severity:** **Medium.** If PAI premortem already catches everything in the enumerated list, gap-reviewer's per-category findings will trend to zero and the categories will prune. The empirical loop is cheap; the wrong defense (no instrumentation) is the expensive failure mode, because duplication then has no detection mechanism.
- **Refinement to ADR-011:** confirm gap-reviewer as a Phase 3 deliverable, **with explicit instrumentation requirement: each finding gap-reviewer emits is tagged with its gap category** (rollback plan, observability, failure modes, etc.). "Spec" in the pruning rule means an individual spec-shaped artifact submitted for review (RFC, ADR, requirements pass, etc.) — not just completed-and-accepted specs; gap-reviewer fires on draft and revision passes equally. After gap-reviewer runs on 5–10 such specs, classify each category by finding rate: **zero findings → prune** as evidence PAI subsumes it at the spec-document level; **low but nonzero findings (e.g., 1 of 5)** → flag as a partial-overlap watch-item, surface for follow-on review rather than auto-pruning; **steady findings → additivity check before retain.** Steady-firing alone doesn't refute anti-job 1 — if PAI's premortem on the same spec independently surfaces the same finding, the category is duplicative-but-frequent (worse than rarely-firing) and should be pruned or migrated to PAI's surface. Sample 3–5 of gap-reviewer's findings per steady category, run PAI premortem on the same spec, compare: only if gap-reviewer findings are additive over PAI is the category genuinely carrying weight and retained. If all categories prune to zero (or fail the additivity check), escalate the duplication concern back to design and surface a follow-on decision for J2 coverage (extend checklist-/bogey-reviewer scope, or add a different reviewer).

### (g.1) No multi-pass adversarial review on docs-only changes — *Refine* (framing)

- **JTBD need served:** J3 implicitly (governance proportionality) and J5 (less maintainer churn lets new versions ship; J5 failure mode is fork drift, jtbd:61).
- **Counterargument:** J2's "looks fine, ships broken" failure mode (jtbd:37) is most acute on docs because spec defects metastasize before code amplifies them.
- **Why the counterargument lands as a framing refinement, not a flip:** multi-pass on *substantive* content is genuinely useful (J2 strong); multi-pass on *already-passed substrate-neutral* docs is the trap. The current rule "no multi-pass on docs-only" is too coarse — it bans valuable second passes on substantive specs and protects only against tautology drift.
- **Anti-job check:** Anti-job 2 ("not a CI gate") supports throttling, but the throttle should target the failure mode, not the document type.
- **Refinement:** sharpen the rule from *"no multi-pass adversarial review on docs-only changes"* to *"throttle multi-pass review when later passes find findings only because earlier passes made the doc more abstract (tautology drift), not because the underlying defect existed all along."* The trigger is "are we finding new findings or chasing the abstraction we just introduced?"
- **Risk severity:** **Low.**

### (g.2) One ADR proposed at a time — *Refine* (with sunset)

- **JTBD need served:** J3 indirectly. Multiple Proposed ADRs cascade; J3 requires ADRs to be readable as the rationale for *the architecture as it is*, which fails when half the chain is conditional.
- **Counterargument:** J1 features can need ADRs on integration / persistence / rollout simultaneously; serial creates a queue.
- **Why the counterargument is weak right now, medium in steady state:** preflight's recent ADRs cascade at ~1.75 levels per ADR (strategic-reimagine evidence); serial is the damping mechanism. After cascade thrash settles, parallel may be fine.
- **Anti-job check:** none.
- **Risk severity:** **Low.** Mark for revisit once cascade thrash settles (signal: a stretch with no ADRs that cascaded into other ADRs in the kernel).

### (g.3) No forward-declared ADRs — *Confirm*

- **JTBD need served:** J3 (jtbd:41–47) and J4 (jtbd:49–55). A forward-declared ADR is unreadable as architecture history — it cites a decision not yet made. J4's "source of truth in versioned text" requirement bans speculative cross-references.
- **Counterargument:** forward-declared ADRs preserve traceability from the deciding ADR to the dependent decision.
- **Why the counterargument fails:** that traceability is satisfiable by lighter mechanisms (open issue, `# TODO(ADR-N)` comment) without polluting `specs/decisions/adrs/` with stubs that read as architecture-as-it-is.
- **Anti-job check:** none.
- **Risk severity:** **Low.**

### (h) Ship as Option B plugin (project scope) — *Confirm*

- **JTBD need served:** J5 (jtbd:57–63). All three motions verified by the delivery-shape doc (lines 69–73): install ✓ trivially easy first time per user; update ✓ deliberate per project; extend ✓ additive discovery prevents collision.
- **Counterargument (J4 readability of the kernel):** plausible read of S4 — kernel rules live inside `${CLAUDE_PLUGIN_ROOT}` outside the project's git tree, so a returning reader using only `git log` and a text editor cannot inspect *preflight's kernel* without invoking the plugin.
- **Why the counterargument fails:** J4's scope (jtbd:55) is *the project's* durable bits — "goals, rules, architecture, JTBD, ADRs" — i.e. **the project's** harness. S4 (jtbd:89–90) names the project's required read set as `specs/requirements.md` + `specs/decisions/adrs/` + (when present) `specs/architecture.md`, and declares acceptance against the **per-project file set** the project itself declares. Preflight's kernel is *the tool's* content; it isn't part of any specific project's declared harness. J4 line 53 also names the relevant J4 commitment for reviewers: *"requiring reviewer rules to cite line-anchored evidence"* — i.e., findings point back into the project's harness so a reader can navigate without invoking the plugin. The kernel content itself doesn't need to be project-tree-resident for J4 to hold.
- **Anti-job check:** none.
- **Risk severity:** **Low.** No JTBD invalidation. Standard delivery-shape risk lives in Option B's implementation failure modes, addressed by ADR-012, not by Phase 1.2.
- **Out of scope here:** Option B's delivery-shape failure modes from the 2026-04-27 spike (kernel hostility, dual-source confusion, blast radius) are implementation concerns, not JTBD evidence. ADR-012 designs the mitigations against them; this Phase 1.2 evaluation tests only against jtbd v0.2.

---

## Cross-cutting

### JTBD coverage

| Decision | J1 | J2 | J3 | J4 | J5 |
|---|---|---|---|---|---|
| (a) Drop spec-kit | indirect | indirect | — | — | **primary** |
| (b) Drop self-constitution | — | — | indirect | **primary** | — |
| (c) Worktrees replace ADR-007 | — | — | **primary** | indirect | — |
| (d) Tighten CONST-PROC-02 | — | — | **primary** | — | indirect |
| (e) Six templates | **primary** | — | — | — | indirect |
| (f) Gap-reviewer | indirect | **primary** | — | — | — |
| (g.1) No multi-pass on docs (refined) | — | indirect | indirect | — | indirect |
| (g.2) One ADR at a time | — | — | indirect | indirect | — |
| (g.3) No forward-declared ADRs | — | — | **primary** | **primary** | — |
| (h) Plugin Option B | — | — | — | — | **primary** |

Every job J1–J5 has at least one primary-server decision. **J4 and J5 dominance:** four of ten decisions primarily serve J4 ((b), (g.3)) or J5 ((a), (h)) — and (g.3) primarily serves both J3 and J4 — reflecting that the reshape is mainly about delivery and durability, not about defect-catching or harness-authoring (those have one each).

### Persona coverage

- **Builder** (J1): primary by (e); incidental by (f), (c), (d).
- **Supervisor** (J2): primary by (f) only — **single-decision dependency.** Decision (f)'s empirical pruning loop is the carrier: any pruning materially weakens Supervisor coverage proportional to the categories pruned, and full pruning (all categories prune to zero, or all fail the additivity check vs. PAI premortem) collapses Supervisor coverage in this decision set to zero. ADR-011 must surface the conditional follow-on (extend checklist-/bogey-reviewer scope, or add a different reviewer). Watch this.
- **Maintainer** (J3): primary or strong by (c), (d), (g.1), (g.2). Best-served persona.
- **Returning-reader** (J4): primary by (b), (g.3). J4 stays project-scoped; preflight's kernel content lives outside the project tree under Option B and that's consistent with J4's scope (jtbd:55, S4 acceptance jtbd:90).
- **Adopter** (J5): primary by (a), (h). Two delivery-substrate decisions.

**No persona is uniformly burdened.** Maintainer absorbs transitional cost from (a) and (h) but is the long-term beneficiary of (c), (d), (g.1), (g.2). The thinnest coverage is Supervisor — see Decision (f) refinement.

### Anti-job collisions

None of the ten decision-units invalidate against any anti-job (jtbd:67–70). Three brush against anti-jobs in supportive ways:

- **(d) and anti-job 3:** anti-job 3 *requires* (d). Co-defined.
- **(e) and anti-job 4:** anti-job 4 makes constitution-as-shipped-template suspect. Supportive.
- **(f) and anti-job 2:** gap-reviewer must remain on-demand, not auto-firing. Supportive constraint on implementation; no current collision.

The closest watch-item is **(f) against anti-job 1** (read carefully — anti-job 1 is *user-facing scope*, but gap categories overlap PAI's premortem at the spec-document level enough to warrant the empirical pruning loop added in the Decision (f) refinement).

---

## Reversals

**No verdict was flipped, no revisions.** The eight original decisions (a–h) all hold. Three received *Refinements* (verdict and intent hold; framing or scope sharpened). *Revise* was defined in the [Verdict legend](#verdict-legend) for label completeness but was not invoked in this evaluation — its absence is by design, not omission.

1. **(f) gap-reviewer — Refine.** Per-category instrumentation + empirical pruning replaces a theoretical pre-build audit. Anti-job 1 boundary is closer than the original analysis acknowledged; the right defense is empirical (measure what gap-reviewer finds vs. what PAI already catches), not a build gate.
2. **(g.1) no multi-pass on docs — Refine.** Sharpens the rule from a document-type filter to a tautology-drift trigger. Same intent; tighter shape.
3. **(g.2) one ADR at a time — Refine.** Adds a sunset clause: revisit once cascade thrash settles. The acceptance condition changes (currently strict, future relaxed), but the verdict remains in place during cascade-thrash state.

---

## Inputs to Phase 2.2

### ADR-011 (reshape) should cite

- Verdict matrix rows (a) through (g.3) — **note that (f) is a Phase 3 open question, not a Phase 2.2 ratification item; see the (f) bullet below for the carve-out.**
- Decision (a)–(c) confirms as the substrate / lifecycle reshape rationale, with JTBD evidence.
- Decision (d) *co-defined with anti-job 3* — strongest of the verdicts.
- Decision (e) and (g.3) — straight Confirms; cite as-is, no special framing required.
- Decision (g.1) **with refined framing** — "throttle on tautology drift," not "no multi-pass on docs-only."
- Decision (g.2) with sunset note — revisit once cascade thrash settles.
- Decision (f) **carve-out (open question, not ratification):** record empirical-pruning instrumentation as a Phase 3 open question, not a Phase 2.2 ratification item. ADR-011 should state: "gap-reviewer is a Phase 3 deliverable; per-category finding logs are required from build; categories that produce zero findings over 5–10 specs are pruned as evidence PAI subsumes them at the spec-document level; steady-firing categories require an additivity check against PAI premortem before retain."
- **Supervisor (J2) coverage dependency:** Supervisor is served by Decision (f) only in this set. If the empirical pruning loop drives all gap categories to zero, or all categories fail the additivity check against PAI premortem (PAI subsumes them at the spec-document level), Supervisor coverage collapses to zero, and ADR-011 must surface a follow-on decision (extend checklist-/bogey-reviewer scope, or add a different reviewer). ADR-011 should record this as an explicit open question with both branches enumerated, not as inline narrative text.

### ADR-012 (delivery shape) should cite

- Verdict matrix row (h) only — straight Confirm.
- Option B confirmation against J5's three motions (delivery-shape doc carries this directly).
- The J4 scope clarification (jtbd:55) and S4 acceptance (jtbd:90): J4 governs the project's declared harness, not preflight's kernel; Option B's `${CLAUDE_PLUGIN_ROOT}` placement of kernel rules is consistent with J4 as written.
- The implementation failure modes flagged by the 2026-04-27 spike (kernel hostility, dual-source confusion, blast radius) need design treatment in ADR-012 — not because JTBD requires it, but because they are real Option-B-specific risks the spike already identified.

### What ADR-011 / ADR-012 should NOT cite

- This document's verdict text as a *governance precedent*. The verdicts apply to this held-decision set only — reuse the *method* (JTBD-decomposition + opposing-verdict synthesis) on future decisions, not the verdicts themselves.
- Time estimates. None given here, none should be added downstream.

---

## What was tested and what wasn't

**Tested:** the eight 2026-04-26 held decisions against jtbd v0.2 jobs / personas / anti-jobs / user-story acceptance bars.

**Not tested:**
- Whether jtbd v0.2 itself is correct. Issue #47 already tracks user-story improvements deferred to post-v0.7.0; this re-evaluation took v0.2 as ground truth.
- Whether Phase 3 implementation choices (skill registry, marketplace mechanics, gap-reviewer prompt structure) satisfy the verdicts. Those are Phase 3 concerns.
- Whether the verdict matrix should be revisited if jtbd v0.3 lands. Recommendation: yes, a one-page diff against this matrix per jtbd minor version.
