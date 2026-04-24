---
status: Proposed
date: 2026-04-24
deciders: Nic
consulted: Stream B research (B2, B5); spec-kit upstream via source analysis; adversarial review (Codex + red-team x2)
informed: Stream A (Spike 2 blocker); future enforcement-orchestration ADR
---

# ADR-009: Adopt preset + extension as preflight's distribution topology; defer enforcement orchestration

## Context and Problem Statement

ADR-007 ("Feature folder lifecycle") left the _integration topology_ question open and named its resolution as Confirmation gate #3.

Stream B's B5 investigation (`docs/analysis/2026-04-22-speckit-hook-philosophy.md`) established that spec-kit's `after_*` hooks are intentional **advisory-by-design** — `optional: false` governs rendering, not enforcement. Upstream has confirmed this stance ([spec-kit#2279](https://github.com/github/spec-kit/issues/2279) closed "not a bug"; [#2104](https://github.com/github/spec-kit/issues/2104) open feature request; `src/specify_cli/extensions.py:2509` docstring: *"The actual execution is delegated to the AI agent."*). The hook-extension composition's enforcement claim does not survive.

Two earlier drafts of this ADR (committed as c02b5c1, 83f6e6d on this branch) tried to ratify a **workflow-extension composite** that replaced hook enforcement with workflow-engine Gate steps. Three adversarial review passes (Codex x2; red-team x2) surfaced load-bearing unknowns:

- **Mechanism-level claims overstated v0.8.0 guarantees.** Namespaced-command dispatch for extension-registered commands, PromptStep permission surface, `StepStatus` vs `RunStatus`, runtime requires-enforcement — all claimed more than the code actually supports.
- **Runtime-architecture questions unresolved.** Whether enforcement should run in a subprocess or as a sub-agent is a larger on-the-loop orchestration research question that preflight has not done industry pattern analysis on (per project rule `rule-design.md`).
- **Topology and enforcement were conflated.** "Which extensibility surfaces carry what" is a different decision from "how reviews get invoked and how their verdicts propagate." The review findings kept landing on enforcement-mechanism claims, not topology.

This ADR separates those decisions. It ratifies the **topology** (which surfaces carry which artifacts) and **explicitly defers enforcement orchestration** to a future ADR informed by on-the-loop orchestration pattern research. Author-time blocking as a preflight-owned capability is relaxed as a near-term goal.

## Decision Drivers

- **Artifact hygiene** — large rule sets, multi-agent reviewer prompts, and reusable commands are expressed as first-class versioned artifacts in a distribution surface, not inline strings in workflow YAML.
- **Rate-of-change resilience** — preflight values low churn (pass 5 of the meta-evaluation; `docs/analysis/2026-04-12-pass5-6mo-sanity-check.md`). The chosen topology avoids adding a pre-1.0 framework-glue dependency.
- **Wedge alignment** — preflight's differentiator is typed-grammar rules with FR/NFR/ADR ID traceability. An artifact-carrying surface is sufficient for this wedge; enforcement orchestration is a separable concern.
- **Scope discipline** — defer what we haven't researched. Subprocess-vs-subagent, on-the-loop agent patterns, and orchestration-runtime selection are not answered by existing preflight research.
- **Unblocking Stream A** — Spike 2 (tack-room launcher) needs to know *which surface to build on*. The enforcement-orchestration question is independent of that.

## Considered Options

1. **Preset + extension, enforcement deferred (chosen).** Preflight ships as today's shape (preset + extension) with `after_*` hooks removed. Review is on-demand via `/speckit.preflight.review`. Enforcement orchestration is a separate future ADR.
2. **Workflow-extension composite.** Preflight ships preset + extension + bundled workflow; workflow owns enforcement via Gate steps. Ratifies a specific orchestration mechanism now.
3. **Pre-hook relocation.** Move review to `before_plan` / `before_tasks` / `before_implement` hooks on the extension.
4. **Preflight-native standalone.** Drop the spec-kit ecosystem; ship as a Claude Code plugin or standalone CLI.

**"Accept advisory" was off the shortlist** per earlier direction — B5 established hooks are advisory-by-design; adopting "advisory" as the topology renames the problem without resolving it.

**Ruled out from prior-pass research** (not re-evaluated): docguard-integrated composition (vendor lock-in), portable rule-core with adapters (extraction cost unjustified), multi-adapter rulepack (violates rate-of-change).

## Decision Outcome

**Chosen option: Preset + extension, enforcement deferred.**

Preflight ships two artifacts:

- **Preset** (`presets/preflight/`) — template overrides for 7 doc types.
- **Extension** (`extensions/preflight/`) — registers `/speckit.preflight.review`, ships the 48-rule set, carries the two-agent reviewer ensemble. **`after_*` hooks are dropped** (B5 invalidated the enforcement claim); they are **not replaced** — preflight makes no author-time enforcement claim in this ADR.

Review is invoked **on demand**: user or any orchestrator calls `/speckit.preflight.review`. The extension remains useful standalone.

### Why not workflow-extension composite

The composite requires committing now to a specific enforcement mechanism — workflow-engine Gate steps — which depends on pre-1.0 runtime architecture and on subprocess-vs-subagent questions preflight has not researched. Three review passes found that every concrete claim about the mechanism overstated what v0.8.0 actually guarantees. Deferring the mechanism decision avoids shipping claims we cannot defend.

### Why not pre-hook relocation

Pre-hooks are upstream's *existing* enforcement surface but not its *designated* one going forward (B5 §Q5). Adopting them now builds on a surface that upstream is moving away from and inherits per-agent compliance variability (issues [#2149](https://github.com/github/spec-kit/issues/2149), [#2178](https://github.com/github/spec-kit/issues/2178)). If the future enforcement ADR concludes pre-hooks are the right answer, nothing in this ADR precludes adopting them then.

### Why not preflight-native

Forfeits spec-kit ecosystem reach (17+ agents via `CommandRegistrar`), duplicates commodity layers (authoring UX, catalog, lifecycle primitives), and walks away from the research investment that drove ADR-007. Not cost-justified.

### Enforcement orchestration — candidates, not ratified

Documented for the future ADR; none selected here:

- Workflow-engine Gate steps (spec-kit's designated primitive; mechanism-level questions captured in `docs/analysis/2026-04-24-speckit-workflow-engine-mechanism.md`)
- Pre-hook relocation (existing, non-designated)
- Upstream `blocking: true` on hooks if [#2104](https://github.com/github/spec-kit/issues/2104) lands
- CI-driven review (run `/speckit.preflight.review` in a GitHub Action or equivalent)
- Agent-driven loop (host agent invokes review as part of its own workflow)
- Future on-the-loop orchestration runtimes (Claude Code subagent patterns, other)

### Consequences

- **Good**, because artifact hygiene is preserved — rules, reviewer prompts, and review command live as first-class versioned artifacts.
- **Good**, because no pre-1.0 framework-glue dependency is added. Pass 5 rate-of-change preference honored.
- **Good**, because Stream A is unblocked on the actual topology question. Spike 2 can proceed knowing the surface.
- **Good**, because the extension remains useful standalone for on-demand review.
- **Neutral**, because PAI-specific `speckit.tasks` / `speckit.implement` redirects are removed from preflight's preset as part of this ADR's implementation — preflight must work without PAI. PAI-side wiring is filed separately in `pai-source`.
- **Neutral**, because "multi-agent reach via `CommandRegistrar`" is available through the extension but not a cited user requirement.
- **Bad**, because preflight explicitly relaxes author-time enforcement as a near-term claim. Review happens if and only if the user or orchestrator invokes it. "Every doc gets reviewed" is no longer an automatic outcome.
- **Bad**, because the enforcement-orchestration question requires a follow-on ADR plus research. Spike 2 may run into enforcement-shape questions before that ADR exists; those conversations feed into the orchestration research rather than blocking on it.
- **Bad**, because the mechanism research doc still needs correction (see research-doc update notes below); review findings identified one factual error (`specify workflow add` already exists in v0.8.0) that affects any future orchestration ADR that picks workflow.

### Premortem

- **Deferred enforcement never lands.** The future orchestration ADR could sit open indefinitely, leaving preflight as a review-on-demand tool with no enforcement path. *Mitigation:* named as a required follow-up; the "Industry on-the-loop pattern analysis" research is tracked as a concrete prerequisite not a wishlist item.
- **Ecosystem moves under us.** Spec-kit ships `specify workflow add` already (v0.8.0 — found in adversarial review); upstream could continue to mature workflow-gate into a de-facto standard before preflight picks. *Mitigation:* that's a positive scenario — more peer implementations to calibrate against when the orchestration ADR opens.
- **Users want enforcement now.** Relaxing the enforcement claim may disappoint users who expected author-time blocking. *Mitigation:* document the on-demand invocation path clearly; name workflow-gate as a candidate orchestration users can experiment with ahead of the official orchestration decision.

## Confirmation

ADR-009 moves from Proposed to Accepted when:

1. **`after_*` hooks are removed from `extensions/preflight/extension.yml`.** The enforcement claim they encoded is retired in writing.
2. **Existing preset + extension artifacts remain installable and usable.** `/speckit.preflight.review` continues to work on-demand; 48 rules continue to load; two-agent reviewer ensemble continues to run.
3. **PAI-specific redirects removed from the preset.** Separate issue filed in `pai-source` for PAI-side wiring.
4. **Research doc §6 corrected** for `specify workflow add` existence (flagged by adversarial review; material to any future orchestration ADR).

**Relationship to ADR-007 gate #3:** closes on this ADR moving to Proposed — "an integration topology is selected in writing" is satisfied by written selection regardless of whether enforcement orchestration has been picked. The separation of topology from enforcement is the substance of ADR-009's contribution.

**Relationship to Stream A Spike 2:** unblocked by Proposed state. Spike 2 builds on preset + extension as the topology; enforcement-shape questions Spike 2 surfaces become inputs to the future orchestration ADR.

### Tripwire — on v0.9.0 release OR 2026-06-13, whichever first

- **Workflow engine API shape changes** — tracked for the future orchestration ADR, not for this one
- **Community workflow catalog growth** — signal for orchestration pattern maturity
- **`auto_run` / `blocking: true` on hooks** — if [#2104](https://github.com/github/spec-kit/issues/2104) lands, reopens pre-hook as an enforcement candidate
- **Industry on-the-loop orchestration patterns** — literature and framework review (per `rule-design.md`); prerequisite for the orchestration ADR

## Scope and follow-ups

### Resolved during ADR review

- **PAI-specific `speckit.tasks` / `speckit.implement` redirect placement** — out of scope for preflight. Filed in `pai-source` repo for PAI-side wiring. Existing redirects removed from preflight's preset as part of this ADR's implementation.
- **Workflow distribution mechanism** — `specify workflow add` already exists in spec-kit v0.8.0 (`src/specify_cli/__init__.py:4854-4900`). Not an open question. Relevant only to the future orchestration ADR.
- **B4 pin-widening** — no workflow adoption under this ADR, so the current pin `>=0.6.2,<0.7.0` on preset + extension can stay. If other reasons to widen arise, decide independently.
- **Issue #31 (auto-commit)** — deferred to the future orchestration ADR. Not resolved by ADR-009.

### Follow-on work this ADR commits to

1. **ADR-010 (or later): Enforcement orchestration.** Opens after industry on-the-loop orchestration pattern analysis is complete. Candidate set already documented above.
2. **Constitution amendment.** The constitution rewrite currently in progress should add a principle: *"preflight provides review artifacts and on-demand invocation; enforcement orchestration is the user's or orchestrator's choice."* See Governance notes.
3. **Requirements refresh.** The requirements.md rewrite (already flagged as needed) should reflect on-demand review as the primary invocation mode.
4. **Mechanism research doc §6 correction.** Update to reflect `specify workflow add` existence.

## Governance notes

- **CONST-DIST-01** (plugin auto-load via `.claude/rules/`) remains orphaned (already flagged stale in constitution banner). This ADR does not un-orphan it; the constitution rewrite addresses it.
- **CONST-DIST-02** spirit preserved: "don't overwrite project-authored docs" still applies to extension install.
- **CONST-PROC-01** applies to preset and extension version bumps in lock-step (already project practice per CLAUDE.md).
- **CONST-QA-01 through CONST-QA-05** remain stale (plugin-era refs; already flagged). Option E does not require new quality gates; the existing preset/extension structure validation continues to apply.
- **CONST-CI-01** (git = canonical source) and **CONST-CI-03** (rule IDs stable) remain valid and respected.
- **CONST-PROC-02** (behavioral changes require ADR): this ADR is itself the governance artifact for the enforcement-stance change.
- **ADR-003's plugin quality gates** (CONST-QA-03/-04/-05) were framed in plugin-era terms. Follow-up: either re-express for extension form in the future orchestration ADR, or accept as permanently stale once the constitution rewrite lands.
- **Pass 5 rate-of-change preference** — *honored* by this ADR. The prior composite-direction drafts overrode it; Option E does not.

## Pros and Cons of the Options

### Option 1 — Preset + extension, enforcement deferred (chosen)

- **Good**, because separates the topology decision (made) from the enforcement decision (deferred pending research) — each gets the rigor it deserves
- **Good**, because no subprocess-vs-subagent commitment; no pre-1.0 framework-glue dependency
- **Good**, because unblocks Stream A immediately; ADR-007 gate #3 closes cleanly
- **Good**, because artifact hygiene preserved; existing preset + extension investment carries forward unchanged
- **Bad**, because author-time enforcement is relaxed as a near-term claim — reviews become on-demand, not automatic
- **Bad**, because requires a follow-on ADR that hasn't been scheduled

### Option 2 — Workflow-extension composite

- **Good**, because upstream workflow engine is spec-kit's designated enforcement primitive going forward
- **Good**, because `specify workflow add` already exists for distribution
- **Bad**, because ratifies a pre-1.0 framework-glue dependency preflight hasn't researched enough to defend
- **Bad**, because multiple review passes found load-bearing mechanism claims overstate what v0.8.0 guarantees
- **Bad**, because conflates topology (what surfaces carry) with enforcement (how reviews fire) — two separable decisions

### Option 3 — Pre-hook relocation

- **Good**, because upstream does treat pre-hook non-execution as bugs-to-fix
- **Good**, because single-surface ownership
- **Bad**, because per-agent compliance flakiness ([#2149](https://github.com/github/spec-kit/issues/2149), [#2178](https://github.com/github/spec-kit/issues/2178))
- **Bad**, because pre-hooks are stable-but-non-designated going forward; workflow engine is upstream's direction
- **Bad**, because same class of unresolved runtime-architecture questions as workflow composite

### Option 4 — Preflight-native standalone

- **Good**, because fewest external dependencies; full runtime control
- **Bad**, because forfeits spec-kit ecosystem reach and authoring UX
- **Bad**, because duplicates commodity layers (catalog, lifecycle, multi-agent distribution)
- **Bad**, because walks away from the research investment behind ADR-007

## More Information

### Evidence base

- `docs/analysis/2026-04-22-speckit-hook-philosophy.md` — B5 investigation; source of the enforcement-claim invalidation
- `docs/analysis/speckit-upstream-tracking.md` — B2 / B2-follow-up evidence on v0.7.4 + v0.8.0 coexistence of workflow engine and hook extensions
- `docs/analysis/2026-04-13-speckit-composition-topologies.md` — community ecosystem survey and original A–E topology decomposition
- `docs/analysis/2026-04-24-speckit-workflow-engine-mechanism.md` — mechanism research; retained as reference material for the future orchestration ADR
- `docs/analysis/2026-04-12-pass5-6mo-sanity-check.md` — rate-of-change principle this ADR honors
- `specs/decisions/adrs/adr-007-feature-folder-lifecycle.md` — Confirmation gate #3 closed by this ADR

### Upstream community signals

- [spec-kit#2104](https://github.com/github/spec-kit/issues/2104) — OPEN feature request for `auto_run: true` on hooks (would reopen pre-hook relocation for the future orchestration ADR)
- [spec-kit#2149](https://github.com/github/spec-kit/issues/2149), [#2178](https://github.com/github/spec-kit/issues/2178) — pre-hook non-execution issues (mixed outcomes)
- [spec-kit#2279](https://github.com/github/spec-kit/issues/2279) — after-hook closed as "not a bug"
- [spec-kit#2158](https://github.com/github/spec-kit/pull/2158) — workflow engine landing PR

### Related

- ADR-007 (feature folder lifecycle) — this ADR satisfies its Confirmation gate #3 by written selection
- Issue [#31](https://github.com/nichenke/preflight/issues/31) — auto-commit, deferred to the future orchestration ADR
- PR [#37](https://github.com/nichenke/preflight/pull/37), PR #38 — user signals informing framing

<!--
Y-Statement:
In the context of preflight's integration with spec-kit, facing the B5 finding that after_* hooks do not enforce and the follow-on discovery that workflow-gate enforcement carries unresolved subprocess-vs-subagent runtime questions,
we decided for preset + extension as the distribution topology and explicitly deferred enforcement orchestration to a future ADR,
to make the topology decision defensibly while avoiding commitment to a pre-1.0 framework-glue runtime that preflight has not researched,
accepting that review becomes on-demand rather than author-time-blocking as a near-term claim,
because topology (which surfaces carry artifacts) and enforcement (how reviews fire) are separable decisions and deferring the latter honors preflight's rate-of-change preference while unblocking Stream A on the former.
-->
