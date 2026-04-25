---
status: Proposed
date: 2026-04-22
deciders: nic
consulted: claude-code (research arc passes 1–5 + re-analysis; framework shape research over BMAD, GSD-2, spec-kit; Stream B B5 hook-philosophy investigation)
informed: (none external)
---

# ADR-007: Adopt feature-folder lifecycle for in-flight changes

## Context and Problem Statement

Preflight has doc types for constitution, requirements, architecture, interfaces, ADRs, RFCs, and test strategy. Each is edited in place in `specs/`. There is no concept of a "unit of work in flight" — no artifact that names the concrete thing being built, its governance context, its acceptance criteria, or its relationship to other in-flight work.

This gap produces three failure modes that motivated the workflow research arc:

1. **Forgotten updates** — changes ship without updating `architecture.md` or `requirements.md` because nothing tracks the obligation. This is the original preflight pain.
2. **Hidden coordination** — multi-PR features exist only in the developer's head. Reviewers see isolated PRs without knowing which feature they belong to.
3. **Unvalidated state compounding on main** — when requirements are edited before implementation validates them (UAT, real usage), errors in requirements compound through subsequent work and are expensive to revert.

A five-pass research arc (see `docs/analysis/2026-04-11-workflow-integration-research.md` through `docs/analysis/2026-04-12-pass5-reanalysis-vs-original-criteria.md`) established:

- **Path A (build on preflight)** beats OpenSpec customization (B1) and fork (B2) by 65+ weighted points on 15 criteria. OpenSpec's soft-rules model violates preflight's hard requirement that the 48 rules remain enforceable.
- **Preflight's defensible value is the 25-category L4 coverage taxonomy**, not the tooling or the reviewer agents. Tooling surfaces are commoditizing fast (3 frontier models, 4 framework breaking releases, 2 benchmarks in 90 days).
- **Rate of change makes plans >60 days speculative.** Rent shapes from the ecosystem; build plumbing only where repo specifics matter.
- **Habit-creating workflow skills are valuable, not "lock-in"** — they are the whole point of the original brief.

A follow-up framework comparison (BMAD, GSD-2, spec-kit) showed that **none of the mature frameworks collapse design rationale and executor hand-off into a single artifact**. BMAD splits responsibilities across `prd.md` / `epics.md` / `story.md`. GSD-2 splits across roadmap / slice-plan / task rows / `DECISIONS.md`. spec-kit splits across `spec.md` / `plan.md` / `tasks.md`. Each has different update cadences and different readers.

This ADR commits preflight to a specific shape for how in-flight changes are represented, reviewed, and merged. Individual downstream artifacts (templates, skills, hooks) are out of scope here — they will be drafted during the spikes this ADR schedules.

## Decision Drivers

- **Original brief** — prevent forgotten updates to `requirements.md` and `architecture.md` when implementing changes.
- **PAI/ISC boundary** — preflight must not duplicate PAI Algorithm's atomic task decomposition. ISC is PAI's domain; preflight provides intent and context.
- **Main cleanliness invariant** — main `requirements.md` must always reflect validated state. Unvalidated requirement changes must not land on main ahead of the implementation that validates them.
- **No feature branches** — long-lived branches produce merge conflicts and stale state. Rejected by deciders explicitly.
- **Multi-PR support** — features at L3+ scale span multiple PRs. The shape must handle this without forcing single-PR features.
- **Reviewer clarity** — reviewers should see full-file diffs, not self-merged deltas.
- **Rate of change tolerance** — the shape must survive ecosystem churn. Borrow stable conventions (markdown, folder layout, FR IDs); avoid brittle external contracts.
- **CONST-PROC-02 discipline** — behavioral requirement changes require an ADR. This ADR covers the shape decision; individual features do not each require an ADR.

## Considered Options

This ADR addresses two related but distinct questions:

1. **Shape options** — how should in-flight changes be represented and how should requirements edits be staged? Options A, B, C, D, and I are shape options; they assume preflight is the substrate.
2. **Substrate alternatives** — could this whole shape live inside OpenSpec or spec-kit rather than inside preflight? Options B3 and B4 are substrate alternatives; they are included here for completeness after a follow-up analysis (`docs/analysis/2026-04-13-framework-customization-depth.md`) re-examined pass 4's dismissal of customization paths in more depth.

### Shape options

1. **Option A — One PR per feature.** Collapse governance + implementation + validation into a single atomic PR.
2. **Option B — Feature branches.** Long-lived branches holding all plans for a feature until merged.
3. **Option C — Feature folder with whole-file copy of affected specs (openspec apply/archive model).** The feature folder holds a proposed `requirements.md` as a full file copy (not a delta). Plans edit the folder's copy. On ship, the folder's file atomically replaces main's file.
4. **Option D — Provisional status on main.** Live-edit `requirements.md` with a `status: provisional | active | withdrawn` field per FR. Implementation builds against provisional; flips to active on UAT.
5. **Option I — Continuous reconcile.** Live-edit main, accept that errors will sometimes land, rely on FR→code traceability tooling to make revision PRs cheap.

### Substrate alternatives

6. **Option B3 — OpenSpec authoring + external preflight review.** Ship `openspec/schemas/preflight/` as a custom schema covering the 7 preflight doc types with preflight's templates. Keep preflight's review engine as a separate tool invoked manually between `openspec new` and `openspec apply`.
7. **Option B4 — spec-kit preset + advisory review hook.** Ship `.specify/presets/preflight/` with preflight templates + command overrides. Register preflight review as an extension command wired to spec-kit's `after_specify` and `after_plan` hooks. Hooks are advisory by upstream design — they cannot block the command from completing (see `docs/analysis/2026-04-22-speckit-hook-philosophy.md`).

## Decision Outcome

**Chosen: Option C — Feature folder with whole-file copy, openspec apply/archive model.**

### Top-level shape

```
specs/<NNN-slug>/
  spec.md              # feature-level: intent, scope, L4 coverage, FR refs, plans index
  plan.md              # per-PR brief (spec-kit's native layout)
  requirements.md      # proposed state of main's requirements.md (full file copy), if requirements change
  architecture.md      # proposed state, only if architecture changes
```

Paths match spec-kit's `.specify/scripts/bash/create-new-feature.sh` output (`SPECS_DIR="$REPO_ROOT/specs"`, `FEATURE_DIR="$SPECS_DIR/$BRANCH_NAME"`). spec-kit allows one `plan.md` per feature folder at the root of the folder, not nested.

Preflight's constitution lives at `.specify/memory/constitution.md` (spec-kit's native constitution path), not at `specs/constitution.md`. spec-kit's `/speckit-constitution` skill and its cross-doc review expectations all target `.specify/memory/constitution.md`; using that path avoids orphaning the native command and avoids two constitutions per project.

### Lifecycle

1. **Creation** — `/preflight:explore` elicits intent and produces a feature folder skeleton with a draft `spec.md`. "Feature" is not a doc type; it is a workflow mode. `/preflight:new` remains doc-type-specific.
2. **Build** — each plan is a per-PR markdown brief. PAI reads a plan, extracts intent and acceptance in prose, decomposes to atomic ISC criteria in its own PRD, builds, and ships. Plans edit `specs/<NNN-slug>/requirements.md` and `specs/<NNN-slug>/architecture.md` — never main's copies directly.
3. **Drift detection** — post-implementation hook uses a two-tier FR lookup: main's `requirements.md` first, then any in-flight `specs/<NNN-slug>/requirements.md`. A reference that resolves in neither is flagged as drift.
4. **Mid-build ADR discovery** — if a plan discovers mid-build that an ADR is required (a requirement changed, a constraint was wrong), the plan pauses. An ADR is drafted and reviewed, the feature's `spec.md` is revised, and the build resumes with the revised spec. Corrupted plans are re-drafted, not patched.
5. **Ship (ratification)** — when all plans merge and UAT passes, a single atomic ratification PR: replaces main's `requirements.md` and `architecture.md` with the feature folder's copies, moves the folder to `specs/archive/<NNN-slug>/`, and bumps plugin version per CONST-PROC-01 if applicable.
6. **Conflict handling** — concurrent features that both touch `requirements.md` resolve at ratification time via normal rebase against main's current state, performed in the feature folder's copy. The second feature to ship carries the merge cost.
7. **RFC** — RFCs remain an independent doc type at `specs/decisions/rfcs/`. A feature that needs design argument references an RFC from its `spec.md`. RFCs are not subsumed into feature folders.
8. **ADR** — ADRs are required only when a feature changes a behavioral requirement (existing CONST-PROC-02). They are not required per feature.
9. **Single-PR escape hatch** — trivial changes (bug fixes, typo corrections, rule tweaks) may bypass the feature folder entirely and use Option A semantics (single PR with inline requirements edits). The dividing line between "small enough for Option A" and "warrants a feature folder" will be established empirically during the spikes this ADR schedules.

### Multi-plan features (reopened)

spec-kit's flat layout allows only one `plan.md` per feature folder. L3+ features that legitimately span multiple PRs need a shape — either *multiple sibling feature folders* coordinated by a parent tracking artifact, or a sub-convention (e.g. `specs/<NNN-slug>/plans/NNN-*.md` sitting alongside spec-kit's top-level `plan.md`). The large spike (tack-room launcher) is expected to settle this; record the outcome in a follow-up ADR or revision when it does.

### Worktree workflow

Spec-kit's `create-new-feature.sh` creates feature branches in place via `git checkout -b`, which is incompatible with preflight's `.claude/rules/git-workflow.md` directive to use `.worktrees/<name>` per feature. Current practice: the user creates a worktree on main, then spec-kit's `before_specify` hook creates the branch inside it via the git extension. No script patching is required.

### Consequences

- **Good**, because main `requirements.md` is always the validated contract. UAT errors are contained in the feature folder and cost only a folder edit to correct.
- **Good**, because the feature folder is the single durable record of a change's governance context. Multi-PR coordination stops being implicit.
- **Good**, because `/preflight:explore` addresses the original pain directly — the elicitation loop forces consideration of requirements and architecture before code ships.
- **Good**, because preflight's review engine runs over the feature folder without needing to merge deltas. Reviewers see normal `git diff` output.
- **Good**, because the shape preserves the PAI/ISC boundary. Plans express intent and acceptance as prose; PAI decomposes to atomic ISC criteria in its own PRD. Preflight does not claim task decomposition as its surface.
- **Good**, because the ratification PR is an atomic, reviewable event — reviewers see the full proposed state of main before it lands.
- **Good**, because archived feature folders preserve the audit trail of how each feature evolved, including mid-build revisions, without cluttering the live `specs/`.
- **Bad**, because drift detection requires a two-tier FR lookup across main and in-flight feature folders. This is roughly 30 lines of new mechanism in the post-implementation hook.
- **Bad**, because concurrent features that touch the same spec file conflict at ratification time. Resolution is a normal rebase but the cost is real.
- **Bad**, because the folder adds ceremony that is too heavy for trivial bug fixes. The Option A escape hatch mitigates this but introduces a judgment call (feature folder or single PR?) that needs a clear heuristic.
- **Bad**, because the shape is not compatible with other frameworks' folder conventions (openspec, spec-kit, BMAD). Cross-tool portability is explicitly not a goal per pass 4 — accepted.
- **Neutral**, because this adopts openspec's apply/archive pattern for one surface (`requirements.md` and `architecture.md` inside feature folders) without adopting openspec as substrate. A small, legible format borrow consistent with pass 4's task.md guidance.

## Integration topology (resolved — see ADR-009)

The *lifecycle shape* decided above is topology-independent. Where preflight lives in the ecosystem — the integration pattern — was opened as a separate question on 2026-04-22 following the Stream B B5 investigation (`docs/analysis/2026-04-22-speckit-hook-philosophy.md`), which established that spec-kit's `after_*` hooks are intentional advisory design and invalidated the assumption that preflight's hooks would enforce review automatically. The lifecycle shape and the path reconciliation (`.specify/memory/constitution.md`; `specs/<NNN-slug>/`) hold under any integration pattern and were not reopened by B5.

**Resolved 2026-04-24 by ADR-009 (Option E):** preflight adopts **preset + extension** as its distribution topology; enforcement orchestration is explicitly deferred to a follow-on ADR pending on-the-loop orchestration pattern research. See ADR-009 for the full decision and candidate-orchestration analysis.

The taxonomy below and the candidate ordering that followed are retained as the pre-resolution framing that led to ADR-009 — *not* a currently-active preference ranking. ADR-009 explicitly decided against picking an enforcement mechanism at this point.

### Topology taxonomy

Use descriptive names from 2026-04-22 onward. The older "Topology A / B / C / D / E" labels (from `docs/analysis/2026-04-13-speckit-composition-topologies.md` and pre-2026-04-22 SPIKE_PLAN entries) remain valid for historical cross-reference; legend below.

| Descriptive name | Old label | One-liner |
|------------------|-----------|-----------|
| **hook-extension composition** | Topology A | Preflight as spec-kit extension; `after_*` hooks dispatch review. **Enforcement broken by design per B5** — `after_*` hooks are advisory-only. Still viable for template + command distribution. |
| **workflow-gate composition** | — (new, B5-surfaced) | Preflight as spec-kit **workflow** (`src/specify_cli/workflows/`, v0.7.0+) with Gate steps wrapping native commands. Enforcement is first-class via `Gate.on_reject = abort/retry` and `RunStatus.PAUSED`. |
| **workflow-extension composite** | — (hybrid, B5-surfaced) | Ships both: a preflight extension AND a preflight-authored workflow. The extension owns template / command overrides and rule artifacts; the workflow owns enforcement. |
| **docguard-integrated composition** | Topology B | No spec-kit preset; integrate review with the `docguard` project's rule-pack mechanism. Deferred. |
| **portable rule-core with adapters** | Topology C | Extract substrate-neutral rule core; ship thin adapters for both Claude Code plugin and spec-kit extension. Enforcement mechanism selected per adapter. |
| **multi-adapter rulepack** | Topology D | Rule-core scaled to 3+ adapters. Dropped — violates rate-of-change principle. |
| **preflight-native (no spec-kit)** | Topology E | Ship preflight as a standalone tool; treat docguard / archive / ci-guard as prior art only. |

### Candidate integrations (pre-resolution framing — superseded by ADR-009)

1. **Workflow-gate composition (preferred).** First-class enforcement via the workflow engine's Gate step (`Gate.on_reject = abort/retry`, `RunStatus.PAUSED`). Preflight ships a bundled workflow wrapping `/speckit.specify` → `Gate: /speckit.preflight.review` → `/speckit.plan` → `Gate: /speckit.preflight.review` → `/speckit.tasks`. Cost: workflow authoring lives on a different surface than `extensions.yml`; the existing extension can coexist (owning templates + commands) or be absorbed.
2. **Pre-hook relocation.** Move review from `after_specify` / `after_plan` to `before_plan` / `before_tasks` / `before_implement`. Pre-hooks carry "Wait for the result" directives and are treated as enforcement by upstream (per B5's survey of [spec-kit#2149](https://github.com/github/spec-kit/issues/2149) and [spec-kit#2178](https://github.com/github/spec-kit/issues/2178), both closed as per-agent bugs-to-fix when pre-hook execution failed). "Review before planning" is arguably more useful than "review after specifying" for the user's mental model. Risk: per-agent compliance is imperfect (Cursor and older Claude Code versions are known-flaky).
3. **Accept advisory semantics.** Keep hook-extension composition; ship `after_*` as `optional: true` with strong prompts and manual invocation. Lowest friction; weakest enforcement. What most existing spec-kit extensions do today.
4. **Upstream proposal.** Comment on [spec-kit#2104](https://github.com/github/spec-kit/issues/2104) advocating for `auto_run: true` or `blocking: true`. Long-horizon only; do not make preflight's near-term ship depend on it.

Hybrids (e.g. workflow-gate for ratification plus pre-hook relocation for in-stage enforcement) were explicitly permitted in the pre-resolution framing and were considered a probable landing spot. **ADR-009 superseded this ranking** by deferring enforcement-mechanism selection entirely; Spike 2 is unblocked and proceeds with manual `/speckit.preflight.review` invocation as the interim review pattern (see ADR-009 § Relationship to Stream A Spike 2).

## Confirmation

Three conditions must be met before this ADR moves from Proposed to Accepted:

1. **Small spike** — one open preflight GitHub issue treated as a feature. Tests whether the folder ceremony is appropriate for trivial changes or whether the Option A escape hatch should be the default for small changes. Target: one working day.
2. **Large spike** — the aborted tack-room launcher feature. Tests the multi-plan shape, the two-tier FR lookup under realistic load, mid-build ADR discovery, and the ratification workflow end-to-end. Target: two working days.
3. **Integration-topology selection.** The topology question above must be answered in writing before Spike 2 commits code. The selection may land as a revision to this ADR, a new superseding ADR, or a Phase 5 synthesis document that references this one — no particular form is mandated, only that it exists.

Order: small spike first. If the feature folder crushes a trivial change, we learn that before committing to the large one.

Acceptance criteria for promoting this ADR to Accepted:

- The small spike either succeeds as a feature folder or produces a clear rule for when Option A applies instead.
- The large spike produces at least two plans, one mid-build revision, and one successful ratification PR.
- No new feature-folder-lifecycle mechanism beyond what this ADR describes is required to make either spike work. If Spike 1 or Spike 2 surfaces a feature-folder-lifecycle blocker, this ADR is revised before acceptance. Review invocation during Spike 2 is handled by manual `/speckit.preflight.review` calls — which is ADR-009's scope (preset + extension distribution topology with enforcement orchestration deferred to a future ADR), not ADR-007's, and does not constitute feature-folder-lifecycle mechanism. Enforcement-shape blockers Spike 2 surfaces route to the orchestration ADR, not to ADR-007 revision.
- Reviewer experience (diff readability, review skill output on feature folders) is subjectively at least as clear as current main-editing flows.
- An integration topology is selected in writing.

### Day-60 tripwire (2026-06-13)

Refresh rate-of-change data, list actual frictions, re-evaluate deferred items. Watches in force:

- **OpenSpec pre-apply validator hooks** — if these ship, substrate-alternative Option B3 becomes more viable.
- **OpenSpec rule-as-code DSL** — same.
- **BMAD / GSD-2 rate-of-change** — watch for a viable composition target emerging from either.
- **Spec-kit workflow engine maturation** — watch for workflow-surface API stability, Gate-step semantics changes, and community workflow-authored extensions as signal for adoption patterns. Relevant because workflow-gate composition remains a candidate enforcement mechanism for the future orchestration ADR (per ADR-009).

The previous "spec-kit `blocking: true` hook semantics" watch is **closed** per the B5 investigation. Upstream's position is established; no hook-blocking field is coming, and the workflow engine + Gate steps is spec-kit's chosen enforcement primitive going forward.

## Pros and Cons of the Options

### Option A — One PR per feature

- Good, because zero new mechanism; reuses existing PR flow
- Good, because requirements edits land atomically with implementation, preserving main cleanliness
- Good, because it is the right shape for trivial changes (retained as the escape hatch in the chosen option)
- Bad, because it does not scale to L3+ features that legitimately span multiple PRs
- Bad, because it does not address the multi-PR coordination problem at all

### Option B — Feature branches

- Good, because all feature state is isolated from main until validated
- Bad, because long-lived branches produce merge conflicts and stale state
- Bad, because every plan PR becomes a branch-to-branch merge, creating a two-level review workflow
- Bad, because they historically burn out maintainers on this project
- Rejected explicitly per decision driver "No feature branches"

### Option C — Feature folder with whole-file copy (chosen)

- Good, because the main cleanliness invariant holds
- Good, because reviewers see full-file diffs without mental merging
- Good, because multi-PR features coordinate through the folder, not through git branches
- Good, because the ratification PR is an atomic, reviewable event
- Good, because the shape matches openspec's proven apply/archive model at one surface without adopting openspec as substrate
- Bad, because it requires two-tier FR lookup in drift hooks (~30 lines)
- Bad, because concurrent features touching the same spec file conflict at ratification
- Bad, because it is ceremony-heavy for trivial changes (mitigated by the Option A escape hatch)

### Option D — Provisional status on main

- Good, because mechanism is minimal (one status field per FR)
- Good, because normal git history with no folder layer
- Bad, because "main is always validated" becomes "main is validated for active FRs only" — a weaker invariant that is easy to misread
- Bad, because every tool that reads `requirements.md` must understand status. Grep, review rules, drift checks all need status awareness, and the coupling cost is spread across the entire rule set.
- Bad, because compound errors remain possible — a provisional FR-041 built on a wrong provisional FR-040 lands in main and must be revised there, exactly the failure the main-cleanliness invariant exists to prevent

### Option I — Continuous reconcile

- Good, because zero new mechanism
- Good, because normal PR flow
- Bad, because main has no cleanliness invariant at all
- Bad, because recovery cost scales with how late UAT catches errors — the blast radius is unbounded
- Bad, because it relies on FR→code traceability tooling that does not yet exist and would itself be a new mechanism

### Option B3 — OpenSpec authoring + external preflight review

- Good, because OpenSpec's custom schema system (v1.0+) does let us ship preflight templates and doc types without forking TypeScript — pass 4's "rigid" framing was overstated
- Good, because OpenSpec's adapter ecosystem covers roughly 10 AI tools maintained by others
- Good, because less template code to own in preflight
- Bad, because OpenSpec has no validator hooks, no pre-apply hook, and no way to gate `openspec apply` on an external review — the user must remember to run `preflight review` manually between `openspec new` and `openspec apply`
- Bad, because ~40 of preflight's 48 rules (all cross-doc, all severity-graded content checks, all procedural governance rules) still live in preflight's review engine outside OpenSpec. No reduction in preflight's maintenance surface.
- Bad, because OpenSpec's manual gate reproduces the original preflight failure mode — "forgot to enforce" — in a slightly different shape
- Estimated weighted score: ~120/175 against pass 4's 15-criterion matrix. Loses to Path A by ~41 points, closer than pass 4's B1 at 85

### Option B4 — spec-kit preset + advisory review hook

- Good, because spec-kit's preset system (4-tier template override stack) is more mature than OpenSpec's schema system
- Good, because spec-kit's `CommandRegistrar` writes commands to 17+ agent directories automatically — Claude, Gemini, Copilot, Cursor, Windsurf, and others — giving preflight multi-agent reach Path A does not have
- Good, because spec-kit hooks (`after_specify`, `after_plan`, `after_tasks`, `after_implement`) let preflight review run prominently, though not automatically in the enforcement sense (see below)
- Good, because spec-kit has a real, shipping extension API with a namespaced command registration (`speckit.preflight.review`) and JSON-schema config validation
- Bad, because spec-kit `after_*` hooks are **advisory by design** — they emit an `EXECUTE_COMMAND:` marker but cannot block the host agent or halt the workflow on a failed review. The gate is honor-system. Confirmed by upstream code (`src/specify_cli/extensions.py:2509` explicitly states "The actual execution is delegated to the AI agent") and by upstream community signals (issue #2104 OPEN feature request for `auto_run: true`; issue #2279 closed "not a bug"). See `docs/analysis/2026-04-22-speckit-hook-philosophy.md`.
- Bad, because spec-kit's extension APIs are pre-1.0 and unstable under semver; breaking changes are likely
- Bad, because spec-kit's preset template resolution is replace-based, not merge-based — a higher-priority preset installing later can silently override preflight's templates
- Bad, because the same 40 content rules still live in preflight (no reduction in rule-engine scope)
- Estimated weighted score: ~130–135/175. The strongest alternative to Path A as a pure preset-plus-hook integration, but still loses to Path A by ~25–30 points because enforcement is advisory, not blocking.
- This bullet originally argued workflow-gate composition as the viable path forward. **Superseded by ADR-009:** the integration-topology question is resolved with **preset + extension** as the distribution topology and enforcement orchestration deferred to a follow-on ADR. Workflow-gate composition was one candidate considered during deferral; it was not ratified. See "Integration topology" above and ADR-009 for the current state.

## More Information

### Research foundation

- `docs/analysis/2026-04-11-workflow-integration-research.md` — pass 1 (6-option comparison)
- `docs/analysis/2026-04-12-workflow-integration-pass2.md` — pass 2 (three walkthroughs, OpenSpec code-level research, initial work-package.yaml draft)
- `docs/analysis/2026-04-12-pass3-category-coverage.md` — pass 3 (25-category L4 taxonomy as defensible value)
- `docs/analysis/2026-04-12-pass4-build-vs-customize.md` — pass 4 (buy-vs-build 161 vs 85, backward-walk, drift-before-builder ordering)
- `docs/analysis/2026-04-13-framework-customization-depth.md` — depth analysis of OpenSpec and spec-kit customization surfaces; source of B3 and B4 option definitions. Partially supersedes pass 4 §2 in scoring detail while preserving pass 4's top-level Path A conclusion.
- `docs/analysis/2026-04-13-speckit-composition-topologies.md` — community ecosystem survey (8 presets, 63 extensions) and the original A–E topology decomposition. See the topology glossary in "Integration topology" above for the 2026-04-22 rename.
- `docs/analysis/2026-04-12-pass5-6mo-sanity-check.md` — pass 5 (rate-of-change, 2-item plan)
- `docs/analysis/2026-04-12-pass5-reanalysis-vs-original-criteria.md` — criteria-first re-scoring, 4-item corrected plan (active recommendation superseded by this ADR for the requirements-handling question)
- `docs/analysis/2026-04-12-meta-evaluation-methodology.md` — 7-angle analytical pattern used across the arc
- `docs/analysis/2026-04-22-speckit-hook-philosophy.md` — Stream B B5 investigation establishing spec-kit `after_*` hooks as intentional advisory design. Source of the integration-topology reopen.
- `docs/analysis/speckit-upstream-tracking.md` — living doc classifying upstream spec-kit releases against preflight outcomes.
- `docs/reference/l4-autonomy-category-framework.md` — 25-category framework referenced throughout

### Related governance

- CONST-PROC-01 (version bump on behavior change) — applies at ratification PR
- CONST-PROC-02 (ADR on behavioral requirement change) — this ADR satisfies the requirement for the shape decision; individual features do not re-trigger it unless they independently change a behavioral requirement
- Project-local git workflow (`.claude/rules/git-workflow.md`) — feature folders live in worktrees like any other change. (Originally FR-028; FR removed 2026-04-25 per ADR-009 acceptance criterion #4 because spec-kit extensions do not register `PreToolUse` hooks. The project-local rule still applies to development in this repo.)
- ADR-005 (maintainer workflow requirements) — feature folder lifecycle is consistent with the single-maintainer assumption
- ADR-006 (review finding locations) — review findings on feature folders will use the file:line-range format from ADR-006

### External references (non-dependencies)

- OpenSpec apply/archive model — github.com/Fission-AI/OpenSpec (pattern borrowed at `requirements.md` surface only; no runtime dependency)
- spec-kit spec/plan/tasks trio — github.com/github/spec-kit (folder-with-multiple-files convention)
- BMAD story-as-context-engine — github.com/bmad-code-org/BMAD-METHOD (context inlining philosophy in feature `spec.md`)

### Operationalization dependencies (out of scope for this ADR, tracked as follow-ups)

Artifacts that will need to exist before the spikes can run, each requiring its own design work:

- Feature-spec template (feature-level declarative doc)
- Plan template (per-PR brief)
- `/preflight:explore` skill — elicitation entry point for feature folders
- `/preflight:propose` skill — orchestrates `new` per doc type, runs review ensemble, emits plans
- `/preflight:review` drift mode — two-tier FR lookup
- Post-implementation hook — two-tier FR lookup implementation
- Preset / extension manifest version bump at ratification PR merge
