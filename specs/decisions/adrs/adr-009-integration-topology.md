---
status: Proposed
date: 2026-04-23
deciders: Nic
consulted: Stream B research (B2, B5); spec-kit upstream via source analysis
informed: Stream A (Spike 2 blocker)
---

# ADR-009: Adopt workflow-extension composite as preflight's integration topology

## Context and Problem Statement

ADR-007 ("Feature folder lifecycle") left the _integration topology_ question open. The lifecycle shape it decided is topology-independent — _where preflight lives in the spec-kit ecosystem_ is the separate question this ADR resolves.

The question was reopened on 2026-04-22 by the Stream B B5 investigation (`docs/analysis/2026-04-22-speckit-hook-philosophy.md`), which established that spec-kit's `after_*` hooks are **intentional advisory design**: `optional: false` governs rendering (automatic `EXECUTE_COMMAND:` marker vs prompt-for-confirmation), not enforcement. Upstream has explicitly confirmed this stance — closed community issue [#2279](https://github.com/github/spec-kit/issues/2279) ("not a bug"), open feature request [#2104](https://github.com/github/spec-kit/issues/2104), and the in-code docstring at `src/specify_cli/extensions.py:2509` stating _"The actual execution is delegated to the AI agent."_ The hook-extension composition's enforcement claim does not survive.

Stream B's B2 adaptation test (spec-kit v0.7.4) and B2-follow-up (v0.8.0) confirmed a compatibility fact: **the spec-kit workflow engine (introduced in PR [#2158](https://github.com/github/spec-kit/pull/2158), commit `a00e679`) coexists with hook extensions** — no forced migration; workflows and extensions are separate extensibility surfaces that can ship alongside each other. Upstream's designated enforcement primitive is the workflow engine's Gate step.

This ADR ratifies the topology. Mechanism-level details (which workflow step types preflight uses, command-naming conventions, permission contracts, output-capture patterns) are deliberately **not** decided here — see `docs/analysis/2026-04-24-speckit-workflow-engine-mechanism.md` for the mechanism research and the validation spike named in Confirmation below.

**User signals fed as framing inputs, not pre-decisions:**

- Workflow-gate lean, with issue [#31](https://github.com/nichenke/preflight/issues/31) (auto-commit) potentially closed as part of the same pivot (PR [#37](https://github.com/nichenke/preflight/pull/37) line 137).
- Wrap-strategy opt-in for `speckit.tasks` / `speckit.implement` PAI redirects — preset-vs-extension placement question (PR #37/#38 line 147). Resolved out of scope for preflight: filed in `pai-source` for PAI-side wiring.

## Decision Drivers

- **Enforcement strength** — preflight's wedge is _author-time blocking against typed spec grammar_. Advisory-only enforcement does not deliver this. The chosen topology must give preflight access to a real enforcement primitive.
- **Rate-of-change resilience** — spec-kit is pre-1.0. The chosen topology must tolerate moderate upstream churn and name a reassessment trigger for v1.0. (See Governance notes below on how this ADR relates to preflight's own rate-of-change principle.)
- **Surface-count maintenance cost** — preflight is a solo-maintainer project; every extensibility surface owned is ongoing cost. Composite-surface ownership must be justified, not default.
- **Wedge alignment** — the chosen topology must preserve preflight's single differentiating layer (typed-grammar blocking rules with FR/NFR/ADR ID traceability) without dragging in non-wedge work.
- **Issue-31 resolution compatibility** — the chosen topology should either close #31 structurally or provide a path to; it should not orphan the auto-commit question.
- **Artifact hygiene** — large rule sets, multi-agent reviewer prompts, and reusable commands are better expressed as versioned artifacts in a distribution surface (preset / extension) than as inline strings in a workflow YAML. End-to-end design and testing interfaces degrade when artifact content is entangled with sequencing logic.

## Considered Options

1. **Workflow-gate composition (pure)** — preflight ships a spec-kit workflow; existing preset + extension retired or collapsed.
2. **Workflow-extension composite (hybrid)** — preflight ships both: a preset for templates, an extension for commands and rule artifacts (including `/speckit.preflight.review`), **plus** a bundled workflow that orchestrates the specify→plan→tasks→implement cycle with Gate steps for human approval of review output.
3. **Pre-hook relocation** — stay on the extension; move review from `after_specify` / `after_plan` to `before_plan` / `before_tasks` / `before_implement`. Pre-hooks carry "Wait for the result" directives and are treated as enforcement by upstream.
4. **Workflow + pre-hook hybrid** — workflow gates at ratification points, pre-hooks for in-stage friction.

**"Accept advisory" is explicitly off the shortlist** per user direction. Rationale: B5 established that hooks are advisory-by-design; adopting "advisory" as the topology would rename the problem, not solve it, and would misrepresent preflight's enforcement claim.

**Ruled out from prior-pass research** (carried forward for completeness; not re-evaluated here):

- docguard-integrated composition (Topology B) — vendor lock-in into a smaller community project
- Portable rule-core with adapters (Topology C) — extraction cost unjustified for a solo-maintainer project
- Multi-adapter rulepack (Topology D) — violates rate-of-change principle
- Preflight-native (Topology E) — forfeits spec-kit ecosystem reach and duplicates commodity layers

### Evaluation matrix

Columns map to the Decision Drivers above. Entries describe *direction* — strong / moderate / weak per driver; tradeoffs are explicit in Pros and Cons below.

| Option | Enforcement | Rate-of-change resilience | Surface-count cost | Wedge alignment | #31 path | Artifact hygiene |
|---|---|---|---|---|---|---|
| 1. Workflow-gate (pure) | Strong (Gate abort) | Weak (pre-1.0 engine; no fallback) | Low (one surface) | Strong | Viable per workflow research; mechanism TBD by spike | Weak — inlines large rule sets and reviewer prompts into workflow YAML |
| 2. Composite (chosen) | Strong (Gate abort) | Moderate (pre-1.0 engine; extension survives as standalone fallback) | High (three surfaces) | Strong | Viable per workflow research; mechanism TBD by spike | Strong — artifacts versioned and testable independently of sequencing logic |
| 3. Pre-hook relocation | Moderate (host-agent compliance; reliable on Claude Code primary target) | Strong (mature, stable hook surface) | Low (one surface) | Weak (not upstream's designated primitive) | Weak — same advisory concerns B5 raised | Moderate — existing extension artifact surface preserved |
| 4. Workflow+pre-hook hybrid | Strong | Weak (pre-1.0 + per-agent flakiness) | Highest (four coordination points) | Strong | As composite | As composite |

## Decision Outcome

**Chosen option: Workflow-extension composite (Option 2).**

High-level shape:

- **Preset** (`presets/preflight/`) — template overrides for 7 doc types (unchanged from v0.6.0–v0.8.0).
- **Extension** (`extensions/preflight/`) — registers the preflight review command, ships the 48-rule set, carries the two-agent reviewer ensemble. `after_*` hooks dropped (B5 invalidated the enforcement claim). Extension remains useful standalone for on-demand review.
- **Workflow** (`workflows/preflight/workflow.yml`) — orchestrates the specify→plan→tasks→implement cycle with review-and-gate pairs; Gate steps provide human approve/reject checkpoints.

**Why composite beats pure workflow-gate:** artifact hygiene. Preflight's 48 rules, two reviewer agent prompts, and a discoverable standalone review command are poorly expressed as inline workflow YAML strings. The extension exists to carry those artifacts as first-class versioned units; the workflow exists to sequence them with enforcement gates. End-to-end design and testing interfaces also cleanly separate under the composite — artifact content is testable independently of the workflow that invokes it. Pure-workflow is technically viable (workflow step types can cover the work in principle — see mechanism research) but forfeits this separation of concerns.

**Why composite beats pre-hook relocation:** the workflow engine's Gate step provides enforcement as state-machine logic in spec-kit's CLI, uniform across integrations at the approval layer. Pre-hooks depend on host-agent compliance (issues [#2149](https://github.com/github/spec-kit/issues/2149) Cursor and [#2178](https://github.com/github/spec-kit/issues/2178) older Claude Code were closed as per-agent bugs-to-fix). On the primary target (Claude Code), pre-hooks execute correctly after PR #2227 — so for a Claude-Code-primary project the reliability concern is weaker than B5 initially raised, but **upstream direction** is the decisive factor: the workflow engine is spec-kit's *designated* enforcement primitive going forward; pre-hooks are a stable-but-non-designated surface.

**Why composite beats workflow+pre-hook hybrid:** adding pre-hooks on top of the workflow quadruples the integration surface for marginal enforcement gain. The workflow alone achieves enforcement via Gate; pre-hooks would be belt-and-suspenders that cost more than the assurance they provide.

**Mechanism-level choices are deferred to the validation spike** (see Confirmation) — specifically: command-naming for CommandStep dispatch, review output handoff to Gate, #31 auto-commit permission contract, and third-party workflow install path. These questions have sufficient unknowns that writing the workflow YAML before the spike risks shipping broken mechanism claims (as happened in an earlier draft of this ADR; see review-and-revision trail in the mechanism research doc).

### Consequences

- **Good**, because author-time enforcement becomes first-class via the workflow engine's Gate step — preflight's differentiating wedge is reachable through an upstream-endorsed primitive.
- **Good**, because artifact hygiene: 48 rules, two reviewer agent prompts, and a discoverable review command live as versioned extension artifacts, testable independently of the workflow that invokes them.
- **Good**, because workflow step types (`while_loop`, `do_while`, `if_then`, `switch`, `fan_in`, `fan_out`) unlock patterns beyond the linear specify→implement cycle — fix/review loops, conditional recovery paths, parallel reviewers. Topology investment pays across future workflows.
- **Good**, because the extension remains useful standalone — users who do not adopt the workflow can still invoke the review command on-demand. Workflow adoption is layered, not all-or-nothing.
- **Neutral**, because "multi-agent reach via `CommandRegistrar` to 17+ agents" is *available* but not a cited user requirement — preflight's primary target is Claude Code. This ADR claims reach as capability, not demand.
- **Neutral**, because PAI-specific `speckit.tasks` / `speckit.implement` redirects are removed from preflight as part of this ADR's implementation — preflight must work without PAI. PAI-side integration is filed as a separate issue in `pai-source`. See Scope and follow-ups.
- **Bad**, because the composite ships three surfaces (preset, extension, workflow) with lock-step version coordination. Concrete failure mode: a user installs preset v0.9.0 + extension v0.9.0 + workflow v0.8.x, and the workflow references rule IDs or commands the older extension does not provide, so review behaves incorrectly. **Mitigation:** ship a `preflight install` wrapper script that coordinates all three installs as one versioned action (detailed mechanism in the research doc; wrapper exists even though spec-kit has no native cross-surface manifest fields).
- **Bad**, because the workflow engine is pre-1.0 and its API could receive breaking changes in a v1.0 cut. Reversibility is not symmetric — forward adoption is a refactor; rollback to hooks if v1.0 reshapes the workflow surface requires re-embedding gate-reject UX and rule-run artifacts in hook prompts. Plan for forward and rollback costs separately.
- **Bad**, because preflight may be among the first community workflow authors — `workflows/catalog.community.json` is empty as of v0.8.0. No peer implementations to calibrate against; pattern-shape decisions carry without peer review. Named threshold in Tripwire.
- **Bad**, because dropping `after_*` hooks means existing documentation and mental models need a migration note. Mitigation: user base is small; migration doc is cheap.
- **Bad**, because adopting a pre-1.0 workflow engine as load-bearing **overrides preflight's own rate-of-change preference** — `docs/analysis/2026-04-12-pass5-6mo-sanity-check.md` §2 classifies framework-plumbing dependencies as higher-risk than content-only surfaces. The override is accepted because the alternatives (advisory-only hooks, pre-hook relocation, preflight-native) fail harder against the enforcement-strength driver. Governance note, not a silent drift.

### Premortem

- **Spec-kit v1.0 redesigns the workflow engine.** Short-term API is stable (minor churn v0.7.0 → v0.8.0); v1.0 redesign is a real rewrite risk. *Mitigation:* tighten the day-60 tripwire to "on v0.9.0 release OR 2026-06-13, whichever first." Pre-commit to rollback criteria: if v1.0 reshapes any of {`Gate.on_reject` vocabulary, `RunStatus.PAUSED` resume API, `CommandStep.dispatch_command` contract}, open a follow-up ADR to re-evaluate within 2 weeks of the v1.0 release.
- **Empty community workflow catalog is a leading indicator, not lag.** *Blocker threshold:* if `workflows/catalog.community.json` has zero community entries by day 90 (2026-07-22), trigger re-evaluation — not automatic rollback, but a rigorous second look at whether to delay adoption.
- **Upstream adds `blocking: true` to hooks.** If spec-kit #2104 is accepted and `blocking: true` ships, the workflow-gate composition is overbuilt. *Mitigation:* the composite keeps the extension; the extension could re-adopt `after_*` hooks with `blocking: true` and the workflow would become optional-but-preferred. The reverse migration is non-trivial — gate-reject UX re-expressed as hook-decline semantics — so budget rollback as distinct work.
- **Mechanism spike returns incompatible findings.** The spike (Confirmation #2) may reveal that the workflow engine's current primitives are not actually sufficient for preflight's review-shaped workload — e.g. output-handoff limitations in PromptStep make "review output visible to Gate" hard. *Mitigation:* the spike's charter explicitly includes "if mechanism issues are insurmountable, retire this ADR and open ADR-010 on a different topology" as a possible outcome. The topology decision is Proposed, not Accepted, for exactly this reason.
- **Three-surface drift produces silent incompatibility.** Addressed in Consequences (version-mismatched installs); listed here for visibility. If the `preflight install` wrapper is not shipped alongside the first workflow release, this failure mode is latent.

## Confirmation

This ADR moves from Proposed to Accepted when:

1. **Mechanism validation spike complete** — a scoped (1–2 day) spike produces concrete answers to the four open mechanism questions in `docs/analysis/2026-04-24-speckit-workflow-engine-mechanism.md` §10: (a) command dispatch for namespaced extension commands; (b) review output handoff to Gate; (c) auto-commit via PromptStep permission model; (d) third-party workflow install path. Findings are written up; either the composite topology is empirically supported or the ADR reopens.
2. **Preflight workflow.yml authored** based on spike findings and validated against spec-kit v0.8.0+ — all step entries parse; Gate and command-dispatch entries exercise approve/reject paths; `RunStatus.PAUSED` resume verified.
3. **`preflight install` wrapper shipped** — a single script / make-target that coordinates preset + extension + workflow installation as one versioned action. This closes the three-surface drift failure mode named in Consequences and Premortem.
4. **ADR-009 revised with mechanism-level detail** — the workflow YAML shape, command-dispatch convention, #31 resolution path, and install mechanism are added to this ADR (or referenced from an updated research doc) based on spike findings, so the Accepted version of ADR-009 reflects validated mechanism.

**Relationship to ADR-007:** ADR-007's Confirmation criterion #3 ("an integration topology is selected in writing") is closed by this ADR moving to **Proposed** state — the topology has been selected and written. ADR-007 does not require the topology decision to be empirically validated before unblocking its own gate; validation is ADR-009's own Accepted criterion. This resolves the circular dependency an earlier draft of this ADR created by tying its own acceptance to Stream A Spike 2.

**Relationship to Stream A Spike 2:** Spike 2 (tack-room launcher) is unblocked by ADR-009 Proposed — design work can proceed on the composite shape. Spike 2 is not a gate on ADR-009 acceptance; its coverage of workflow mechanism is a separate topic.

### Tripwire — on v0.9.0 release OR 2026-06-13, whichever first

Workflow engine maturation watch in force. Re-evaluate within 2 weeks of trigger if any of the following hold:

- **API shape changes** in `src/specify_cli/workflows/engine.py`, `steps/gate/`, `steps/command/` affect `on_reject` vocabulary, `RunStatus.PAUSED` resume contract, or `CommandStep.dispatch_command()` signature.
- **Community catalog** — if `workflows/catalog.community.json` remains empty at day 90 (2026-07-22), run the catalog re-evaluation named in the premortem.
- **Third-party workflow distribution mechanism** — if spec-kit publishes `specify workflow add` or equivalent, revise the `preflight install` wrapper to use it.
- **Spec-kit v1.0 signals** — any roadmap or commit indicating an imminent v1.0 cut triggers early re-evaluation against the rollback criteria in the premortem.

## Scope and follow-ups

### Resolved during ADR review

- **PAI-specific `speckit.tasks` / `speckit.implement` redirect placement** — out of scope for preflight. Preflight must work without PAI. PAI-side integration is PAI's concern; file a corresponding issue in the `pai-source` repo. Existing PAI redirects in preflight's preset get removed as part of this ADR's implementation.
- **Issue #31 (auto-commit)** — close on workflow ship; no preflight extension command is added. Concrete resolution path (PromptStep, with permission model yet to be validated) is owned by the mechanism validation spike, not this ADR.
- **Third-party workflow distribution** — deferred to the mechanism spike (Confirmation #1 sub-question (d)). Manual copy into `.specify/workflows/` is the current working assumption; spike verifies the actual path and registry mechanics.
- **B4 pin-widening sequencing** — pin is widened in lock-step with workflow adoption. Spec-kit's bundled workflow declares `speckit_version: ">=0.7.2"`, and the workflow engine landed in v0.7.0 (PR #2158), so the current pin `>=0.6.2,<0.7.0` is incompatible as a project-policy decision (not an upstream-enforced runtime constraint — spec-kit's `requires` metadata is stored but not yet runtime-enforced per `engine.py:50-52`). Widen the pin as part of the workflow-authoring PR.

### Deferred

- **Extension retention vs collapse.** This ADR retains the extension as a shrunk-scope artifact distributor (commands + rules, no hooks). If experience shows the extension becomes vestigial once the workflow ships, a follow-up ADR may collapse everything into the workflow. Default: retain.

## Governance notes

- **CONST-DIST-01** (plugin auto-load via `.claude/rules/`) is orphaned by this ADR — the workflow surface is not a Claude Code plugin. Follow-up: update the constitution rewrite in progress to reflect that preflight's distribution surfaces are spec-kit preset, extension, and workflow — not Claude Code plugin.
- **CONST-PROC-01** (version bump on behavior change) extends to the workflow surface. Release discipline: preset, extension, and workflow version strings bump in lock-step (the same cadence already applied to preset.yml and extension.yml per project CLAUDE.md).
- **ADR-003's plugin quality gates** (CONST-QA-03/-04/-05) are framed in plugin-era terms. Follow-up: either re-express them as "applicable to any preflight distribution artifact including workflows," or explicitly carve out workflows with a named alternative gate mechanism. Not blocking for ADR-009 acceptance but should be addressed before the first workflow ships.
- **Pass 5 rate-of-change preference** (`docs/analysis/2026-04-12-pass5-6mo-sanity-check.md` §2) preferred content over framework plumbing. This ADR consciously overrides that preference on the ground that the enforcement-strength driver is not reachable via content-only surfaces — advisory-only hooks fail B5, pre-hook relocation forfeits upstream direction, preflight-native forfeits ecosystem reach. Recorded in Consequences; the override is intentional, not silent drift.

## Pros and Cons of the Options

### Option 1 — Workflow-gate composition (pure)

- **Good**, because single-surface ownership minimizes version-coordination overhead
- **Good**, because workflow is upstream's designated enforcement primitive — clean alignment
- **Good**, because technically viable: workflow step types can cover review, commit, and enforcement in principle (see mechanism research)
- **Bad**, because it pushes complex artifacts into inline workflow YAML — 48 rules and two reviewer agent prompts as string content in one file. Workable for short/simple directives; poor fit for large rule sets or multi-agent ensembles that need to evolve independently.
- **Bad**, because end-to-end design and testing interfaces degrade: artifact content becomes entangled with sequencing logic in the same YAML file, harder to test review behavior in isolation
- **Bad**, because it forfeits the standalone on-demand review use case — users who do not adopt the workflow cycle have no way to invoke review

### Option 2 — Workflow-extension composite (chosen)

- **Good**, because each surface plays a specialized role: extension carries versioned artifacts (commands, rules, reviewer prompts); workflow sequences them with enforcement gates. Specialization, not duplication.
- **Good**, because the extension remains useful standalone for on-demand review — workflow adoption is layered, not all-or-nothing
- **Bad**, because three-surface version lock-step requires a `preflight install` wrapper to prevent silent drift (addressed in Consequences and Confirmation #3)
- **Bad**, because ships against a pre-1.0 workflow API; v1.0 could force rewrites with asymmetric rollback cost
- **Bad**, because preflight may be the first community-authored workflow — no peer implementations to calibrate against
- **Bad**, because the mechanism details are unvalidated at the time of this ADR's Proposed state; the validation spike may reveal blockers

### Option 3 — Pre-hook relocation

- **Good**, because stays on a single surface (extension only)
- **Good**, because on the primary target (Claude Code), pre-hooks now execute reliably after PR #2227
- **Good**, because pre-hooks *are* treated as enforcement by upstream (per-agent bug-fix history on #2149, #2178)
- **Bad**, because workflow engine is upstream's *designated* enforcement primitive going forward — pre-hooks are stable-but-non-designated
- **Bad**, because enforcement depends on host-agent prompt-obedience rather than state-machine logic — approve/reject semantics are less unambiguous than Gate steps
- **Bad**, because cross-agent reach is limited (Cursor and older Claude Code still flaky per closed #2149)
- **Bad**, because review-before-plan is a different UX shape than review-after-specify (reviewer acts on incomplete state more often); non-trivial migration to rules and agent prompts

### Option 4 — Workflow + pre-hook hybrid

- **Good**, because belt-and-suspenders enforcement at both workflow gates and hook points
- **Bad**, because maximum surface count: preset + extension + workflow + pre-hook config = four places to coordinate
- **Bad**, because hybrid inherits pre-hook per-agent flakiness without adding enforcement beyond what workflow alone delivers
- **Bad**, because muddies the decision story — "we use workflow-gate, except when we don't"
- **Bad**, because quadruples the failure-mode matrix for marginal enforcement gain

## More Information

### Evidence base

- `docs/analysis/2026-04-22-speckit-hook-philosophy.md` — B5 investigation establishing advisory-by-design; source of the topology reopen
- `docs/analysis/speckit-upstream-tracking.md` — B2 / B2-follow-up evidence on v0.7.4 + v0.8.0 coexistence of workflow engine and hook extensions
- `docs/analysis/2026-04-13-speckit-composition-topologies.md` — community ecosystem survey and original A–E topology decomposition
- `docs/analysis/2026-04-24-speckit-workflow-engine-mechanism.md` — mechanism-level research separating validated behavior from unvalidated assumptions; inputs for the validation spike named in Confirmation
- `docs/analysis/2026-04-12-pass5-6mo-sanity-check.md` — rate-of-change principle this ADR consciously overrides
- `specs/decisions/adrs/adr-007-feature-folder-lifecycle.md` — Confirmation gate #3 that this ADR closes by being written

### Upstream community signals

- [spec-kit#2104](https://github.com/github/spec-kit/issues/2104) — OPEN feature request for `auto_run: true` on hooks (would reopen Option 3 if accepted)
- [spec-kit#2149](https://github.com/github/spec-kit/issues/2149) — Cursor pre-hook non-execution, closed as per-agent bug
- [spec-kit#2178](https://github.com/github/spec-kit/issues/2178) — Claude Code pre-hook non-execution, fixed by PR #2227
- [spec-kit#2279](https://github.com/github/spec-kit/issues/2279) — after-hook non-execution closed as "not a bug" by maintainer
- [spec-kit#2158](https://github.com/github/spec-kit/pull/2158) — workflow engine landing PR (commit `a00e679`)

### Related

- ADR-007 (feature folder lifecycle) — this ADR satisfies its Confirmation gate #3 by written selection
- Issue [#31](https://github.com/nichenke/preflight/issues/31) — auto-commit, candidate for close on workflow ship
- PR [#37](https://github.com/nichenke/preflight/pull/37) / PR #38 line 137 and 147 — user signals informing framing

<!--
Y-Statement:
In the context of preflight's integration with spec-kit, facing the B5 finding that after_* hooks are advisory-by-design,
we decided for workflow-extension composite and against pure-workflow, pre-hook relocation, and workflow+pre-hook hybrid,
to achieve author-time enforcement via the workflow engine's Gate steps while preserving artifact hygiene (versioned rules and reviewer prompts testable independently of sequencing logic),
accepting the cost of lock-step version coordination across three surfaces, a pre-1.0 engine dependency, and an explicit override of preflight's own rate-of-change preference,
because the composite separates artifacts from sequencing logic and preserves a discoverable standalone review path.
-->
