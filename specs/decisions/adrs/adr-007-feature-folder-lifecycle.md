---
status: Proposed
date: 2026-04-13
deciders: nic
consulted: claude-code (research arc passes 1–5 + re-analysis; this session's framework shape research over BMAD, GSD-2, spec-kit)
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
7. **Option B4 — spec-kit preset + advisory review hook.** Ship `.specify/presets/preflight/` with preflight templates + command overrides. Register preflight review as an extension command wired to spec-kit's `after_specify` and `after_plan` hooks. Hooks are advisory (cannot block), but run automatically.

## Decision Outcome

**Chosen: Option C — Feature folder with whole-file copy, openspec apply/archive model.**

> **Note:** The top-level shape below was drafted pre-Topology-A. Amendment 1 (appended after the Confirmation section) reconciles these paths with spec-kit's actual layout: `specs/<NNN-slug>/` replaces `specs/features/<NNN-slug>/`, and the constitution moves to `.specify/memory/constitution.md`. The lifecycle semantics are unchanged.

### Top-level shape

```
specs/features/NNN-slug/
  spec.md              # feature-level: intent, scope, L4 coverage, FR refs, plans index
  requirements.md      # proposed state of main's requirements.md (full file copy)
  architecture.md      # proposed state, only if architecture changes
  plans/
    001-<slug>.md      # one PR, one PAI handoff
    002-<slug>.md
```

### Lifecycle

1. **Creation** — `/preflight:explore` elicits intent and produces a feature folder skeleton with a draft `spec.md`. "Feature" is not a doc type; it is a workflow mode. `/preflight:new` remains doc-type-specific.
2. **Build** — each plan is a per-PR markdown brief. PAI reads a plan, extracts intent and acceptance in prose, decomposes to atomic ISC criteria in its own PRD, builds, and ships. Plans edit `specs/features/NNN/requirements.md` and `specs/features/NNN/architecture.md` — never main's copies directly.
3. **Drift detection** — post-implementation hook uses a two-tier FR lookup: main's `requirements.md` first, then any in-flight `specs/features/*/requirements.md`. A reference that resolves in neither is flagged as drift.
4. **Mid-build ADR discovery** — if a plan discovers mid-build that an ADR is required (a requirement changed, a constraint was wrong), the plan pauses. An ADR is drafted and reviewed, the feature's `spec.md` is revised, and the build resumes with the revised spec. Corrupted plans are re-drafted, not patched.
5. **Ship (ratification)** — when all plans merge and UAT passes, a single atomic ratification PR: replaces main's `requirements.md` and `architecture.md` with the feature folder's copies, moves the folder to `specs/features/archive/NNN-slug/`, and bumps plugin version per CONST-PROC-01 if applicable.
6. **Conflict handling** — concurrent features that both touch `requirements.md` resolve at ratification time via normal rebase against main's current state, performed in the feature folder's copy. The second feature to ship carries the merge cost.
7. **RFC** — RFCs remain an independent doc type at `specs/decisions/rfcs/`. A feature that needs design argument references an RFC from its `spec.md`. RFCs are not subsumed into feature folders.
8. **ADR** — ADRs are required only when a feature changes a behavioral requirement (existing CONST-PROC-02). They are not required per feature.
9. **Single-PR escape hatch** — trivial changes (bug fixes, typo corrections, rule tweaks) may bypass the feature folder entirely and use Option A semantics (single PR with inline requirements edits). The dividing line between "small enough for Option A" and "warrants a feature folder" will be established empirically during the spikes this ADR schedules.

### Consequences

- **Good**, because main `requirements.md` is always the validated contract. UAT errors are contained in the feature folder and cost only a folder edit to correct.
- **Good**, because the feature folder is the single durable record of a change's governance context. Multi-PR coordination stops being implicit.
- **Good**, because `/preflight:explore` addresses the original pain directly — the elicitation loop forces consideration of requirements and architecture before code ships.
- **Good**, because preflight's review engine runs over the feature folder without needing to merge deltas. Reviewers see normal `git diff` output.
- **Good**, because the shape preserves the PAI/ISC boundary. Plans express intent and acceptance as prose; PAI decomposes to atomic ISC criteria in its own PRD. Preflight does not claim task decomposition as its surface.
- **Good**, because the ratification PR is an atomic, reviewable event — reviewers see the full proposed state of main before it lands.
- **Good**, because archived feature folders preserve the audit trail of how each feature evolved, including mid-build revisions, without cluttering the live `specs/features/`.
- **Bad**, because drift detection requires a two-tier FR lookup across main and in-flight feature folders. This is roughly 30 lines of new mechanism in the post-implementation hook.
- **Bad**, because concurrent features that touch the same spec file conflict at ratification time. Resolution is a normal rebase but the cost is real.
- **Bad**, because the folder adds ceremony that is too heavy for trivial bug fixes. The Option A escape hatch mitigates this but introduces a judgment call (feature folder or single PR?) that needs a clear heuristic.
- **Bad**, because the shape is not compatible with other frameworks' folder conventions (openspec, spec-kit, BMAD). Cross-tool portability is explicitly not a goal per pass 4 — accepted.
- **Neutral**, because this adopts openspec's apply/archive pattern for one surface (`requirements.md` and `architecture.md` inside feature folders) without adopting openspec as substrate. A small, legible format borrow consistent with pass 4's task.md guidance.

### Confirmation

Two spikes are required before this ADR moves from Proposed to Accepted:

1. **Small spike** — one open preflight GitHub issue treated as a feature. Tests whether the folder ceremony is appropriate for trivial changes or whether the Option A escape hatch should be the default for small changes. Target: one working day.
2. **Large spike** — the aborted tack-room launcher feature (see dispatch handoff context). Tests the multi-plan shape, the fallthrough FR lookup under realistic load, mid-build ADR discovery, and the ratification workflow end-to-end. Target: two working days.

Order: small spike first. If the feature folder crushes a trivial change, we learn that before committing to the large one.

Acceptance criteria for promoting this ADR to Accepted:

- The small spike either succeeds as a feature folder or produces a clear rule for when Option A applies instead.
- The large spike produces at least two plans, one mid-build revision, and one successful ratification PR.
- No mechanism outside what this ADR describes is required to make either spike work. If new mechanism is needed, this ADR is revised before acceptance.
- Reviewer experience (diff readability, review skill output on feature folders) is subjectively at least as clear as current main-editing flows.

Day-60 tripwire from the re-analysis plan remains in force (2026-06-13): refresh rate-of-change data, list actual frictions, re-evaluate deferred items. The tripwire is now sharpened by the framework customization depth analysis — specifically watch spec-kit's hook semantics for a `blocking: true` field or exit-code propagation, which would make Option B4 viable and threaten Path A's lead. Secondary watches: OpenSpec pre-apply validator hooks, OpenSpec rule-as-code DSL.

## Amendment 1: Path reconciliation with spec-kit (2026-04-15, pre-acceptance)

Topology A (ratified in Phase 0 of the SPIKE_PLAN) puts preflight's workflow inside spec-kit. During Phase 2 spike preparation, two path decisions in this ADR's original draft were found to conflict with spec-kit's actual file layout. Both are reconciled here before acceptance, per the confirmation criteria that explicitly permit revision: *"If new mechanism is needed, this ADR is revised before acceptance."*

### Constitution location

**Original draft:** implicit — preflight's constitution lived at `specs/constitution.md` where the plugin-era governance docs lived alongside `requirements.md`, `architecture.md`, and the `decisions/` tree.

**Reconciled:** `.specify/memory/constitution.md`, spec-kit's native constitution path.

**Rationale:** spec-kit's `/speckit-constitution` skill, its constitution-template scaffolding, and its cross-doc review expectations all target `.specify/memory/constitution.md`. Keeping preflight's constitution at `specs/constitution.md` creates two constitutions per project (spec-kit's empty placeholder template plus preflight's real one) and orphans the native command. Composing with spec-kit per Topology A means yielding the path.

**Executed as:** one commit on `fix/harness-deconflict` that moves the file content verbatim, adds a location banner, and updates live references in `CLAUDE.md`, `.claude/rules/preflight.md`, `extensions/preflight/commands/speckit.preflight.review.md`, `extensions/preflight/scaffolds/agents-md-skeleton.md`, and `docs/reference/l4-autonomy-category-framework.md`. Historical references (ADR-002, `docs/analysis/*`, `docs/plans/*`, this ADR's slice table) preserve the old path as a historical fact, mirroring how prior renames (`content/` → `presets/preflight/`) were handled.

### Feature folder layout

**Original draft:** `specs/features/<NNN-slug>/` with `spec.md`, `requirements.md`, `architecture.md`, and a `plans/` subdirectory holding per-PR `NNN-<slug>.md` plans.

**Reconciled:** `specs/<NNN-slug>/` — spec-kit's actual `create-new-feature.sh` layout. A single `plan.md` lives at the feature root (`specs/<NNN-slug>/plan.md`), not nested under a `plans/` subdirectory.

**Rationale:** spec-kit hardcodes `SPECS_DIR="$REPO_ROOT/specs"` and `FEATURE_DIR="$SPECS_DIR/$BRANCH_NAME"` in its scaffolding script with no configuration surface to insert an intermediate `features/` directory. Matching spec-kit's convention eliminates a class of path patches we would otherwise owe spec-kit's scripts forever, and aligns with Topology A's "compose with spec-kit" bet.

### What doesn't change

- The lifecycle shape (Option C: feature folder with whole-file copy, openspec apply/archive model)
- The main-cleanliness invariant (main `requirements.md` always reflects validated state)
- The single-PR escape hatch for trivial changes
- The drift detection two-tier FR lookup (main first, then in-flight feature folders)
- The mid-build ADR discovery protocol
- RFCs remain at `specs/decisions/rfcs/` as an independent doc type
- ADRs remain at `specs/decisions/adrs/` and continue to require CONST-PROC-02 discipline for behavioral requirement changes

### Reopened questions

- **Multi-plan feature shape.** The original draft proposed `plans/NNN-*.md` under each feature folder to support L3+ features spanning multiple PRs. Spec-kit's flat layout allows only one `plan.md` per feature folder. Re-evaluate during the large spike (tack-room launcher) whether multi-plan features should be represented as *multiple sibling feature folders* coordinated by a parent tracking artifact, or whether we need a sub-convention (e.g. `specs/<NNN-slug>/plans/NNN-*.md` sitting alongside spec-kit's top-level `plan.md`). This is load-bearing for Phase 4 of the SPIKE_PLAN; record the outcome in a follow-up amendment.
- **Drift detection pathing.** Two-tier lookup now scans `specs/<NNN-slug>/` folders instead of `specs/features/<NNN-slug>/`. The mechanism is unchanged; only the glob needs to match the new convention. Implementation follows whenever post-implementation hooks land.

### Worktree workflow compatibility

Spec-kit's `.specify/scripts/bash/create-new-feature.sh` creates feature branches in place via `git checkout -b`, which is incompatible with preflight's `.claude/rules/git-workflow.md` directive to use `.worktrees/<name>` per feature. The incompatibility is resolved in a separate PR that patches `create-new-feature.sh` to create a worktree instead. That patch is a harness prerequisite for Spike 1 and is tracked as a follow-up to this amendment — the decision to use spec-kit's `specs/<NNN-slug>/` feature folder layout (above) stands regardless of how the branch/worktree is created.

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
- Good, because spec-kit hooks (`after_specify`, `after_plan`, `after_tasks`, `after_implement`) let preflight review run automatically without user action
- Good, because spec-kit has a real, shipping extension API with a namespaced command registration (`speckit.preflight.review`) and JSON-schema config validation
- Bad, because spec-kit hooks are **advisory**, not blocking — they fire an LLM prompt and cannot halt the workflow on a failed review. The gate is honor-system.
- Bad, because spec-kit's extension APIs are pre-1.0 and unstable under semver; breaking changes are likely
- Bad, because spec-kit's preset template resolution is replace-based, not merge-based — a higher-priority preset installing later can silently override preflight's templates
- Bad, because the same 40 content rules still live in preflight (no reduction in rule-engine scope)
- Estimated weighted score: ~130–135/175. The strongest alternative to Path A. Still loses to Path A by ~25–30 points because the enforcement gate is advisory, not blocking.
- **Flip condition**: if spec-kit ships blocking hook semantics (a `blocking: true` field + exit-code propagation), B4 becomes viable. This is a small API change and the most plausible near-term upstream change that would invalidate Path A's lead. Day-60 tripwire should explicitly watch for it.

## More Information

### Research foundation

- `docs/analysis/2026-04-11-workflow-integration-research.md` — pass 1 (6-option comparison)
- `docs/analysis/2026-04-12-workflow-integration-pass2.md` — pass 2 (three walkthroughs, OpenSpec code-level research, initial work-package.yaml draft)
- `docs/analysis/2026-04-12-pass3-category-coverage.md` — pass 3 (25-category L4 taxonomy as defensible value)
- `docs/analysis/2026-04-12-pass4-build-vs-customize.md` — pass 4 (buy-vs-build 161 vs 85, backward-walk, drift-before-builder ordering)
- `docs/analysis/2026-04-13-framework-customization-depth.md` — depth analysis of OpenSpec and spec-kit customization surfaces; source of B3 and B4 option definitions and the revised day-60 tripwire conditions. Partially supersedes pass 4 §2 in scoring detail while preserving pass 4's top-level Path A conclusion.
- `docs/analysis/2026-04-12-pass5-6mo-sanity-check.md` — pass 5 (rate-of-change, 2-item plan)
- `docs/analysis/2026-04-12-pass5-reanalysis-vs-original-criteria.md` — criteria-first re-scoring, 4-item corrected plan (active recommendation superseded by this ADR for the requirements-handling question)
- `docs/analysis/2026-04-12-meta-evaluation-methodology.md` — 7-angle analytical pattern used across the arc
- `docs/reference/l4-autonomy-category-framework.md` — 25-category framework referenced throughout

### Related governance

- CONST-PROC-01 (version bump on behavior change) — applies at ratification PR
- CONST-PROC-02 (ADR on behavioral requirement change) — this ADR satisfies the requirement for the shape decision; individual features do not re-trigger it unless they independently change a behavioral requirement
- FR-028 (worktree enforcement) — feature folders live in worktrees like any other change
- ADR-005 (maintainer workflow requirements) — feature folder lifecycle is consistent with the single-maintainer assumption
- ADR-006 (review finding locations) — review findings on feature folders will use the file:line-range format from ADR-006

### External references (non-dependencies)

- OpenSpec apply/archive model — github.com/Fission-AI/OpenSpec (pattern borrowed at `requirements.md` surface only; no runtime dependency)
- spec-kit spec/plan/tasks trio — github.com/github/spec-kit (folder-with-multiple-files convention)
- BMAD story-as-context-engine — github.com/bmad-code-org/BMAD-METHOD (context inlining philosophy in feature `spec.md`)

### Operationalization dependencies (out of scope for this ADR, tracked as follow-ups)

Artifacts that will need to exist before the spikes can run, each requiring its own design work:

- `content/templates/feature-spec-template.md` — feature-level declarative doc
- `content/templates/plan-template.md` — per-PR brief
- `skills/explore/SKILL.md` — elicitation entry point for feature folders
- `skills/propose/SKILL.md` — orchestrates `new` per doc type, runs review ensemble, emits plans
- `skills/review/SKILL.md` — add `--drift` mode with two-tier FR lookup
- `content/scaffolds/post-implementation-hook.sh` — two-tier FR lookup implementation
- Version bump plugin.json v0.6.x → v0.7.0 at time of ratification PR merge
