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

Stream B's B2 adaptation test (spec-kit v0.7.4) and B2-follow-up (v0.8.0) confirmed a critical compatibility fact: **the spec-kit workflow engine (introduced in PR** [#2158](https://github.com/github/spec-kit/pull/2158)**, commit `a00e679`) coexists with hook extensions**. There is no forced migration; workflows and extensions are separate extensibility surfaces that can ship alongside each other. This removes a structural obstacle to a composite topology.

Upstream's designated enforcement primitive is now the workflow engine's Gate step — a first-class state machine with `on_reject ∈ {abort, skip, retry}`, `RunStatus.PAUSED` semantics, `Ctrl+C`-safe resume, and real subprocess dispatch via `integration.dispatch_command()`. This ADR ratifies the topology that aligns preflight with that primitive.

**User signals fed as framing inputs, not pre-decisions:**

- Workflow-gate lean, with issue [#31](https://github.com/nichenke/preflight/issues/31) (auto-commit) potentially closed as part of the same pivot (PR [#37](https://github.com/nichenke/preflight/pull/37) line 137).
- Wrap-strategy opt-in for `speckit.tasks` / `speckit.implement` PAI redirects — preset-vs-extension placement question (PR #37/#38 line 147).

Both signals are carried into the decision. The PAI-redirect placement is resolved in § Scope and follow-ups (out of scope for preflight; filed in `pai-source`).

## Decision Drivers

- **Enforcement strength** — preflight's wedge is _author-time blocking against typed spec grammar_. Advisory-only enforcement does not deliver this. The chosen topology must give preflight access to a real enforcement primitive.
- **Rate-of-change resilience** — spec-kit is pre-1.0. The chosen topology must tolerate moderate upstream churn and name a reassessment trigger for v1.0.
- **Surface-count maintenance cost** — preflight is a solo-maintainer project; every extensibility surface owned is ongoing cost. Composite-surface ownership must be justified, not default.
- **Wedge alignment** — the chosen topology must preserve preflight's single differentiating layer (typed-grammar blocking rules with FR/NFR/ADR ID traceability) without dragging in non-wedge work.
- **Issue-31 resolution compatibility** — the chosen topology should either close #31 structurally or provide a path to; it should not orphan the auto-commit question.
- **Preservation of existing preset + extension investment** — v0.6.0–v0.8.0 preflight has a working preset + extension + 48-rule reviewer ensemble. The chosen topology should preserve that work, not discard it.

## Considered Options

1. **Workflow-gate composition (pure)** — preflight ships a spec-kit workflow with Gate steps; existing preset + extension retired or collapsed into the workflow.
2. **Workflow-extension composite (hybrid)** — preflight ships both: a preset for templates + an extension for commands and rule artifacts (including `/speckit.preflight.review`), **plus** a bundled workflow that orchestrates the specify→plan→tasks→implement cycle with Gate steps invoking the review command.
3. **Pre-hook relocation** — stay on the extension; move review from `after_specify` / `after_plan` to `before_plan` / `before_tasks` / `before_implement`. Pre-hooks carry "Wait for the result" directives and are treated as enforcement by upstream.
4. **Workflow + pre-hook hybrid** — workflow gates at ratification points, pre-hooks for in-stage friction.

**"Accept advisory" is explicitly off the shortlist** per user direction. Rationale: B5 established that hooks are advisory-by-design; adopting "advisory" as the topology would rename the problem, not solve it, and would misrepresent preflight's enforcement claim.

**Ruled out from prior-pass research** (carried forward for completeness; not re-evaluated here):

- docguard-integrated composition (Topology B) — vendor lock-in into a smaller community project
- Portable rule-core with adapters (Topology C) — extraction cost unjustified for a solo-maintainer project
- Multi-adapter rulepack (Topology D) — violates rate-of-change principle
- Preflight-native (Topology E) — forfeits spec-kit ecosystem reach and duplicates commodity layers

### Evaluation matrix

Columns map to the Decision Drivers above. Entries describe _direction_ rather than scores — "strong / weak / neutral" per driver; tradeoffs are explicit in the per-option Pros and Cons section below.

| Option                      | Enforcement                                                              | Rate-of-change resilience                                          | Surface-count cost                 | Wedge alignment                            | #31 compatibility                                                                   | Existing-investment fit                                    |
| --------------------------- | ------------------------------------------------------------------------ | ------------------------------------------------------------------ | ---------------------------------- | ------------------------------------------ | ----------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| 1. Workflow-gate (pure)     | Strong (Gate + abort)                                                    | Weak (pre-1.0 engine; single surface means no fallback)            | Low (one surface)                  | Strong                                     | Supported — PromptStep prompts agent to commit; no registered command needed       | Weak — viable via PromptStep/ShellStep, but inlines complex rule + reviewer artifacts into workflow YAML |
| 2. Composite (chosen)       | Strong (Gate + abort)                                                    | Moderate (pre-1.0 engine risk, but extension survives as fallback) | High (three surfaces)              | Strong                                     | Supported — workflow PromptStep invokes host-agent commit formation                | Preserves preset + extension; extension scope narrows      |
| 3. Pre-hook relocation      | Moderate (host-agent compliance; reliable on Claude Code primary target) | Strong (mature, stable hook surface)                               | Low (one surface)                  | Weak (not upstream's designated primitive) | Weak — same advisory-by-design concerns that B5 raised for `after_*`                | Preserves existing shape; hook relocation is the migration |
| 4. Workflow+pre-hook hybrid | Strong                                                                   | Weak (pre-1.0 engine + per-agent flakiness)                        | Highest (four coordination points) | Strong                                     | Supported (same as composite)                                                       | Preserves, but ongoing coordination cost highest           |

## Decision Outcome

**Chosen option: Workflow-extension composite (Option 2).**

Preflight ships three artifacts in lock-step:

1. **Preset** (`presets/preflight/`) — template overrides for 7 doc types (unchanged from v0.6.0–v0.8.0 shape).
2. **Extension** (`extensions/preflight/`) — registers `/speckit.preflight.review` as a spec-kit command, ships the 48-rule set, and carries the two-agent reviewer ensemble. **The `after_*` hooks are dropped** — they were the advisory-only enforcement path B5 invalidated. The extension also remains useful standalone: a user who does not adopt the workflow can still invoke `/speckit.preflight.review` manually. No `/speckit.preflight.commit` command is registered — auto-commit is handled by workflow PromptStep (see Issue #31 path below).
3. **Workflow** (`workflows/preflight/workflow.yml`) — orchestrates the specify→plan→tasks→implement cycle with review-and-gate pairs. Shape adapted from spec-kit's bundled `workflows/speckit/workflow.yml` (v0.8.0):
   ```
   specify (CommandStep)        → /speckit.specify
   preflight-review-spec        → /speckit.preflight.review
   gate-spec (Gate)             → message + [approve|reject], on_reject: abort
   plan (CommandStep)           → /speckit.plan
   preflight-review-plan        → /speckit.preflight.review
   gate-plan (Gate)             → message + [approve|reject], on_reject: abort
   tasks (CommandStep)          → /speckit.tasks
   implement (CommandStep)      → /speckit.implement
   ```
   Gate steps display a message and prompt the user for approve/reject (`src/specify_cli/workflows/steps/gate/__init__.py:26-69`); they do **not** invoke commands themselves. The review is run by a preceding `CommandStep` that dispatches `/speckit.preflight.review` via `integration.dispatch_command()` (`src/specify_cli/workflows/steps/command/__init__.py:117-145`). The subsequent Gate pauses for human approval of the review output.

**Why composite beats pure workflow-gate:** a pure-workflow topology is *viable* on spec-kit v0.8.0 semantics — `PromptStep` (`src/specify_cli/workflows/steps/prompt/__init__.py`) can send an arbitrary free-form prompt to the integration CLI without any registered command, and `ShellStep` (`src/specify_cli/workflows/steps/shell/__init__.py`) covers subprocess work. What pure-workflow *gives up* is artifact hygiene: preflight's 48 rules, two reviewer agent prompts, and any discoverable on-demand review command would have to live as inline YAML strings inside the workflow file (or implicit dependencies on externally-installed plugin skills dispatched via `CommandStep`). Inline YAML is acceptable for short, simple instructions; it is poorly suited to large rule sets, multi-agent ensembles, and separately-evolving reviewer behavior. The extension exists specifically to carry those artifacts as first-class, versioned, testable units; the workflow exists to sequence them with enforcement gates. Each surface does what it does well — composition over inlining.

End-to-end design and testing interfaces also cleanly separate under the composite: extension artifacts (rules, reviewer prompts, commands) are testable independently of the workflow that invokes them. Pure-workflow conflates artifact content with sequencing logic in one YAML file.

**Why composite beats pre-hook relocation:** Gate-step approve/reject runs as state-machine logic in spec-kit's CLI, not as a prompt-interpretation directive — so the approve/reject semantics are uniform regardless of agent. Command dispatch itself still goes through integration-specific CLIs, so individual agent behavior does matter for command execution — but approve/reject gating is unambiguous in a way that pre-hook compliance (issues [#2149](https://github.com/github/spec-kit/issues/2149) Cursor, [#2178](https://github.com/github/spec-kit/issues/2178) Claude Code) is not. On the primary target (Claude Code), pre-hooks do now execute correctly after PR #2227 — so for a Claude-Code-primary project, pre-hook reliability is no longer the blocker it was when B5 was written. The stronger argument for workflow over pre-hooks is **upstream direction**: spec-kit's maintainers have named the workflow engine as the designated enforcement primitive; pre-hooks are a stable but non-designated surface.

**Why composite beats workflow+pre-hook hybrid:** adding pre-hooks on top of the workflow quadruples the integration surface for marginal enforcement gain. The workflow alone achieves enforcement (via Gate); pre-hooks would be belt-and-suspenders that cost more than the assurance they provide, without closing any failure mode the workflow leaves open.

**Issue #31 (auto-commit) path**: within the composite, the workflow adds a `PromptStep` after the implement step that prompts the host agent to commit the changes (e.g. *"Review the changes produced by /speckit.implement and create a git commit with an appropriate message."*). `PromptStep` sends the instruction to the integration CLI (`PromptStep._try_dispatch`, `workflows/steps/prompt/__init__.py`); the agent then uses its own tool-use capabilities to inspect diffs, craft a commit message, and commit. `ShellStep` with a hard-coded `git commit -m ...` was considered and rejected — it forfeits the LLM's commit-formation quality in exchange for brittleness. Recommend closing #31 as "solved by workflow PromptStep" once the workflow ships.

### Consequences

- **Good**, because author-time enforcement becomes first-class: the workflow pauses at each `Gate` step with `on_reject: abort` until the user approves, and pause/resume is checkpointed (`src/specify_cli/workflows/steps/gate/__init__.py:26-69`; `src/specify_cli/workflows/engine.py:437-441`, `:454-512`). Preflight's differentiating wedge is now reachable through an upstream-endorsed primitive.
- **Good**, because artifact hygiene: 48 rules, two reviewer agent prompts, and a discoverable `/speckit.preflight.review` command live as versioned extension artifacts testable independently of the workflow that invokes them — rather than as inline YAML strings in a single workflow file.
- **Good**, because issue #31 (auto-commit) has a concrete resolution via a workflow `PromptStep` after the implement step — the host agent handles commit-message formation with its own tool-use, not a hard-coded shell invocation.
- **Good**, because workflow step types (`while_loop`, `do_while`, `if_then`, `switch`, `fan_in`, `fan_out`) unlock patterns beyond the linear specify→implement cycle — fix/review loops, conditional recovery paths, parallel reviewers. This topology investment pays across future workflows, not only the current specify→plan→tasks→implement shape.
- **Good**, because the extension remains useful standalone — a user who does not adopt the workflow can still invoke `/speckit.preflight.review` on-demand. Workflow adoption is layered, not all-or-nothing.
- **Neutral**, because "multi-agent reach via `CommandRegistrar` to 17+ agents" is _available_ but not a cited user requirement — preflight's primary target is Claude Code. This ADR claims reach as capability, not demand.
- **Bad**, because the composite ships three surfaces (preset, extension, workflow) with lock-step version coordination. Concrete failure mode: a user installs preset v0.9.0 + extension v0.9.0 + workflow v0.8.x; the workflow dispatches `/speckit.preflight.review` from an older extension where rule IDs referenced by the v0.9.0 preset templates do not exist, so review passes or fails for the wrong reasons. **Mitigation:** ship a `preflight install` wrapper script (or Makefile target) that runs `specify preset add` + `specify extension add` + manual workflow copy as one coordinated action, enforcing version coherence across the triple before writing any files. The wrapper becomes the single supported install path; CONST-PROC-01 governs version-bump discipline; the release-notes version contract documents the triple.
- **Bad**, because the workflow engine is pre-1.0 and its API could receive breaking changes in a v1.0 cut. Reversibility is not symmetric — moving _forward_ to workflow-gate is a refactor; moving _back_ to hooks if v1.0 reshapes the workflow surface requires re-embedding gate-reject UX and rule invocation as hook prompts. Plan for forward cost; plan for rollback cost as a separate budget item.
- **Bad**, because the third-party workflow distribution mechanism is not yet documented by upstream (`workflows/catalog.community.json` is empty as of v0.8.0). Preflight may be among the first community workflow authors. This is a yellow flag with a named re-evaluation threshold (Open Sub-Questions §4; Day-60 tripwire).
- **Bad**, because dropping the `after_*` hooks means existing documentation and mental models need a migration note. Mitigation: user base is small; migration doc is cheap.
- **Bad**, because the empty community catalog (zero peer workflows) means preflight carries pattern-shape decisions without peer review. _Mitigation:_ the bundled spec-kit workflow is the only reference implementation; deviate from its shape only with explicit justification.
- **Neutral**, because PAI-specific `speckit.tasks` / `speckit.implement` redirects are removed from preflight as part of this ADR's implementation — preflight must work without PAI. PAI-side integration is filed as a separate issue in the `pai-source` repo. See Scope and follow-ups.

### Premortem (ways this approach could fail)

- **Spec-kit v1.0 redesigns the workflow engine.** Explore verified minor churn only since PR #2158 (v0.7.0 → v0.8.0: single-line doc change in `expressions.py`), so the short-term API is stable. But a v1.0 redesign — renaming `RunStatus`, changing Gate return shapes, altering `CommandStep` dispatch — would force a rewrite. _Mitigation:_ tighten the day-60 tripwire to "on v0.9.0 release OR 2026-06-13, whichever first." Pre-commit to rollback criteria: if v1.0 reshapes any of {`Gate.on_reject` vocabulary, `RunStatus.PAUSED` resume API, `CommandStep.dispatch_command` contract}, open a follow-up ADR to re-evaluate within 2 weeks of the v1.0 release rather than absorbing the churn silently.
- **The empty community workflow catalog is a leading indicator, not lag.** If nobody else ships a workflow in 60–90 days, the pattern may not catch on, leaving preflight on an orphaned surface. _Blocker threshold:_ if `workflows/catalog.community.json` has zero community entries by day 90 (2026-07-22), trigger re-evaluation of the topology — not automatic rollback, but a rigorous second look at whether to delay adoption.
- **Upstream adds `blocking: true` to hooks after all.** If spec-kit #2104 is accepted and `blocking: true` ships on hooks, the workflow-gate composition is overbuilt — simpler hook-based enforcement becomes available. _Mitigation:_ the composite keeps the extension; the extension could re-adopt `after_*` hooks with `blocking: true` and the workflow would become optional-but-preferred rather than load-bearing. The reverse migration is non-trivial: gate-reject UX would need to be re-expressed as hook-decline semantics, and rule-run artifacts would need a place to live outside the workflow state. Budget the rollback as distinct work; do not assume symmetric reversibility.
- **Per-CommandStep dispatch has hidden failure modes at scale.** `impl.dispatch_command()` relies on `shutil.which(impl.key)` finding the integration CLI on PATH. If an agent integration's CLI is missing or misbehaves, the workflow fails with `RunStatus.FAILED` (`src/specify_cli/workflows/steps/command/__init__.py:134-140`). _Mitigation:_ this is a spec-kit-level problem affecting any workflow, not unique to preflight. Flag in user-facing docs.
- **Three-surface drift produces silent incompatibility.** Addressed explicitly in Consequences (version-mismatched install produces wrong reviewer verdicts). Listed here as a premortem for visibility: if the install-time compatibility check is not shipped alongside the first workflow release, this failure mode is latent and exploitable.

## Confirmation

This ADR moves from Proposed to Accepted when:

1. **Preflight workflow.yml authored** and validated locally against spec-kit v0.8.0+ (shape verified against bundled `workflows/speckit/workflow.yml`, all Gate and CommandStep entries load without parse errors).
2. **End-to-end dry run** — one preflight workflow run succeeds on a sample spec-kit project, exercising at least one gate approve and one gate reject path, with `RunStatus.PAUSED` resume verified. **Distribution escape hatch:** spec-kit v0.8.0 has no `specify workflow add` command (Open Sub-Question §4); the dry run proceeds by manual copy of `workflows/preflight/workflow.yml` into the test project's `.specify/workflows/` directory (or equivalent path spec-kit loads workflows from). This unblocks criterion #2 without waiting on upstream distribution tooling; if a distribution mechanism lands before acceptance, switch to it.
3. **`preflight install` wrapper shipped** — a single script/make-target that runs `specify preset add` + `specify extension add` + manual workflow copy as one coordinated action, enforcing version coherence across the triple before writing any files. This closes the three-surface drift failure mode named in Consequences and Premortem. The wrapper is the single supported install path documented in preflight's README.
4. **Stream A unblock signal** — Spike 2 (tack-room launcher) confirms it can proceed with the composite topology as the enforcement surface.
5. **Issue #31 resolution filed** — a GH issue comment or close-note on #31 identifying the workflow `PromptStep` as the resolution (host agent handles commit-message formation with its own tool-use; close outright or convert to "solved by workflow PromptStep").

### Tripwire — on v0.9.0 release OR 2026-06-13, whichever first

Workflow engine maturation watch in force. Re-evaluate within 2 weeks of trigger if any of the following hold:

- **API shape changes** in `src/specify_cli/workflows/engine.py`, `steps/gate/`, `steps/command/` affect `on_reject` vocabulary, `RunStatus.PAUSED` resume contract, or `CommandStep.dispatch_command()` signature.
- **Community catalog** — if `workflows/catalog.community.json` remains empty at day 90 (2026-07-22), run the catalog re-evaluation named in the premortem.
- **Third-party workflow distribution mechanism** — if spec-kit publishes `specify workflow add` or equivalent, switch from the manual-copy escape hatch in Criterion #2 and close Open Sub-Question §4.
- **Spec-kit v1.0 signals** — any roadmap or commit indicating an imminent v1.0 cut triggers early re-evaluation against the rollback criteria in the premortem.

## Scope and follow-ups

### Resolved during ADR review

- **PAI-specific `speckit.tasks` / `speckit.implement` redirect placement** — out of scope for preflight. Preflight must work without PAI. PAI-side integration is PAI's concern; file a corresponding issue in the `pai-source` repo for PAI-side wiring. The existing PAI redirects in preflight's preset get removed as part of this ADR's implementation.
- **Issue #31 (auto-commit)** — close on workflow ship. Resolution is workflow PromptStep (host agent handles commit-message formation with its own tool-use); no preflight extension command is added.
- **Third-party workflow distribution** — resolved during the PoC dry run (Confirmation criterion #2). Manual copy into `.specify/workflows/` unblocks the spike; productize the install path based on what the PoC learns. If spec-kit ships `specify workflow add` or equivalent before the ADR moves to Accepted, switch to that.
- **B4 pin-widening sequencing** — bumped in lock-step with workflow adoption. Spec-kit's bundled workflow requires `speckit_version: ">=0.7.2"`; preflight's composite requires the workflow engine, so the current pin `>=0.6.2,<0.7.0` is incompatible by definition. Widen the pin as part of the workflow-authoring PR, not as a separate B4 follow-up.

### Deferred

- **Extension retention vs collapse.** This ADR retains the extension as a shrunk-scope artifact distributor (commands + rules, no hooks). If experience shows the extension becomes vestigial once the workflow ships, a follow-up ADR may collapse everything into the workflow. Default: retain.

## Pros and Cons of the Options

### Option 1 — Workflow-gate composition (pure)

- **Good**, because single-surface ownership minimizes version-coordination overhead
- **Good**, because workflow is upstream's designated enforcement primitive — clean alignment
- **Good**, because technically viable: `PromptStep` covers review (free-form prompt to agent), `ShellStep` covers subprocess work, `CommandStep` covers spec-kit commands. No missing primitive.
- **Bad**, because it pushes complex artifacts into inline workflow YAML — 48 rules and two reviewer agent prompts as string content in one file. Workable for short/simple directives; poor fit for large rule sets or multi-agent ensembles that need to evolve independently.
- **Bad**, because end-to-end design and testing interfaces degrade: artifact content becomes entangled with sequencing logic in the same YAML file, harder to test review behavior in isolation
- **Bad**, because it forfeits the standalone on-demand review use case — users who do not adopt the workflow cycle have no way to invoke review
- **Bad**, because it loses the `CommandRegistrar` multi-agent distribution path (17+ AI target registration), even if that reach is aspirational today

### Option 2 — Workflow-extension composite (chosen)

- **Good**, because each surface plays a required role: extension registers commands that `CommandStep` dispatches; workflow sequences commands and interleaves Gate pauses. Not duplication; specialization.
- **Good**, because the extension remains useful standalone for on-demand review — workflow adoption is layered, not all-or-nothing
- **Bad**, because three-surface version lock-step requires install-time compatibility checks (addressed in Consequences and Confirmation criterion #3)
- **Bad**, because ships against a pre-1.0 workflow API; v1.0 could force rewrites with asymmetric rollback cost
- **Bad**, because preflight may be the first community-authored workflow — no peer implementations to calibrate against (zero entries in `workflows/catalog.community.json` at v0.8.0)

### Option 3 — Pre-hook relocation

- **Good**, because stays on a single surface (extension only)
- **Good**, because on the primary target (Claude Code), pre-hooks now execute reliably after PR #2227 (fix for [#2178](https://github.com/github/spec-kit/issues/2178)); for a Claude-Code-primary project, the reliability concern B5 raised is weaker than it was
- **Good**, because pre-hooks _are_ treated as enforcement by upstream (per-agent bug-fix history on #2149, #2178)
- **Bad**, because workflow engine is upstream's _designated_ enforcement primitive going forward per B5 §Q3 — pre-hooks are stable-but-non-designated
- **Bad**, because enforcement depends on host-agent prompt-obedience rather than state-machine logic — approve/reject semantics are less unambiguous than Gate steps
- **Bad**, because cross-agent reach is limited (Cursor and older Claude Code still flaky per closed #2149)
- **Bad**, because review-before-plan is a different UX shape than review-after-specify (reviewer acts on incomplete state more often); non-trivial migration to rules and agent prompts

### Option 4 — Workflow + pre-hook hybrid

- **Good**, because belt-and-suspenders enforcement at both workflow gates and hook points
- **Bad**, because maximum surface count: preset + extension + workflow + pre-hook config \= four places to coordinate
- **Bad**, because hybrid inherits pre-hook per-agent flakiness without adding enforcement beyond what workflow alone delivers
- **Bad**, because muddies the decision story — "we use workflow-gate, except when we don't"
- **Bad**, because quadruples the failure-mode matrix for marginal enforcement gain

## More Information

### Evidence base

- `docs/analysis/2026-04-22-speckit-hook-philosophy.md` — B5 investigation establishing advisory-by-design; source of the topology reopen
- `docs/analysis/speckit-upstream-tracking.md` — B2 / B2-follow-up evidence on v0.7.4 + v0.8.0 coexistence of workflow engine and hook extensions
- `docs/analysis/2026-04-13-speckit-composition-topologies.md` — community ecosystem survey and original A–E topology decomposition
- `specs/decisions/adrs/adr-007-feature-folder-lifecycle.md` — Confirmation gate #3 that this ADR closes

### Spec-kit source citations (v0.8.0 unless noted)

- `src/specify_cli/workflows/engine.py:22-92` — workflow engine state machine definition
- `src/specify_cli/workflows/engine.py:437-441` — `KeyboardInterrupt` → `RunStatus.PAUSED` Ctrl+C safety
- `src/specify_cli/workflows/engine.py:454-512` — `resume(run_id)` persisted-state recovery and step re-execution
- `src/specify_cli/workflows/steps/gate/__init__.py:48` — non-interactive `StepStatus.PAUSED` fallback
- `src/specify_cli/workflows/steps/gate/__init__.py:64` — `on_reject="retry"` triggers re-pause
- `src/specify_cli/workflows/steps/gate/__init__.py:109` — accepted `on_reject` values: `abort`, `skip`, `retry`
- `src/specify_cli/workflows/steps/command/__init__.py:31-148` — `CommandStep` dispatch logic
- `src/specify_cli/workflows/steps/command/__init__.py:134` — integration CLI resolution via `shutil.which(impl.key)`
- `src/specify_cli/workflows/steps/command/__init__.py:140` — `integration.dispatch_command()` subprocess invocation
- `src/specify_cli/extensions.py:2505-2527` — `execute_hook()` docstring confirming "The actual execution is delegated to the AI agent"
- `src/specify_cli/workflows/steps/gate/__init__.py:26-69` — Gate step execute logic: displays message, prompts for choice, returns `StepStatus.PAUSED` non-interactive or `StepStatus.FAILED` on `on_reject: abort` reject. Confirms: Gate steps do not invoke commands.
- `workflows/speckit/workflow.yml:31-35` — bundled `review-spec` Gate step: `type: gate`, `message: "Review the generated spec..."`, `options: [approve, reject]`, `on_reject: abort` — structural template preflight adapts
- `workflows/speckit/workflow.yml:42-46` — bundled `review-plan` Gate step (same shape)
- `workflows/catalog.community.json` — empty (`"workflows": {}`) as of v0.8.0; confirmed no peer community workflows

### Upstream community signals

- [spec-kit#2104](https://github.com/github/spec-kit/issues/2104) — OPEN feature request for `auto_run: true` on hooks (would reopen Option 3 if accepted)
- [spec-kit#2149](https://github.com/github/spec-kit/issues/2149) — Cursor pre-hook non-execution, closed as per-agent bug
- [spec-kit#2178](https://github.com/github/spec-kit/issues/2178) — Claude Code pre-hook non-execution, fixed by PR #2227
- [spec-kit#2279](https://github.com/github/spec-kit/issues/2279) — after-hook non-execution closed as "not a bug" by maintainer
- [spec-kit#2158](https://github.com/github/spec-kit/pull/2158) — workflow engine landing PR (commit `a00e679`)

### Related

- ADR-007 (feature folder lifecycle) — this ADR satisfies its Confirmation gate #3
- Issue [#31](https://github.com/nichenke/preflight/issues/31) — auto-commit, candidate for close on workflow adoption
- PR [#37](https://github.com/nichenke/preflight/pull/37) / PR #38 line 137 and 147 — user signals informing framing

<!--
Y-Statement:
In the context of preflight's integration with spec-kit, facing the B5 finding that after\_\* hooks are advisory-by-design,
we decided for workflow-extension composite and against pure-workflow, pre-hook relocation, and workflow+pre-hook hybrid,
to achieve author-time enforcement via the workflow engine's Gate steps,
accepting the cost of lock-step version coordination across three surfaces and a pre-1.0 engine dependency,
because the composite separates artifacts (rules, reviewer prompts, registered commands) from sequencing logic (workflow), keeping complex content out of inline YAML and preserving a discoverable standalone review path.
\-->
