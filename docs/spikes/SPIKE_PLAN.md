# Spike plan — preflight ADR-007 validation

A living tracking document for the three spikes that gate ADR-007 from Proposed to Accepted. Update inline as phases complete. Spike reports drop into this directory alongside this file.

## Status header

- **Created**: 2026-04-13
- **Owner**: nic
- **Current phase**: 0 — pre-spike setup
- **Last updated**: 2026-04-13
- **ADR being validated**: [ADR-007 feature folder lifecycle](../../specs/decisions/adrs/adr-007-feature-folder-lifecycle.md)
- **Estimated effort to ADR-007 promotion**: ~6 working days
- **Estimated effort to production**: +3–5 days after promotion

Update the `Current phase` field as phases progress: `0 → 1 → 2 → 3 → 4 → 5 → 6 → done`.

## Purpose

ADR-007 proposes a feature-folder lifecycle for in-flight changes. The composable architecture analysis (2026-04-13) raised the question of whether ADR-007 should be implemented as preflight-native skills (Path A) or as a spec-kit preset that composes with preflight's review engine (Path A-prime). Three spikes test the composable path against real work; results determine the implementation layer and promote ADR-007.

## Source documents

Read these before starting:

- [ADR-007: Adopt feature-folder lifecycle for in-flight changes](../../specs/decisions/adrs/adr-007-feature-folder-lifecycle.md) — the shape decision being validated
- [Composable architecture](../analysis/2026-04-13-composable-architecture.md) — proposes Path A-prime; defines the three spikes
- [Framework customization depth](../analysis/2026-04-13-framework-customization-depth.md) — OpenSpec/spec-kit surfaces, B3/B4 alternative options
- [Pass 4 build vs customize](../analysis/2026-04-12-pass4-build-vs-customize.md) — original Path A vs B1/B2 analysis (now partially superseded in framing)
- [Pass 5 re-analysis](../analysis/2026-04-12-pass5-reanalysis-vs-original-criteria.md) — 4-item plan (still valid; spikes determine which layer ships it)
- [Meta evaluation methodology](../analysis/2026-04-12-meta-evaluation-methodology.md) — angles 2.8 (criteria-first), 2.9 (load-bearing-criterion isolation), 2.10 (composition-first) apply to spike synthesis

## Branch strategy

- `feature/workflow-research` (current) — research arc commits, ADR-007 draft. Merge to main as docs-only **before** spike work starts. Keeps the audit trail clean.
- `spike/preset-small` — phase 2 spike, branched off main after research merge
- `spike/pai-brownfield` — phase 3 spike
- `spike/launcher` — phase 4 spike
- Each spike branch produces a spike report committed to that branch + a PR to main if the spike's actual work warrants it (spike 1 and 2 produce real PRs against the issue/feature; spike 3 is sketch-only)

---

## Phase 0 — Pre-spike setup

**Goal**: workspace, substrate, and targets locked in before any scaffolding.

**Tasks**:

- [ ] Install spec-kit locally (`pipx install specify-cli`); verify `specify --version` and `specify init` work in throwaway dir
- [ ] Read spec-kit's preset + extension docs end to end:
    - [ ] `presets/ARCHITECTURE.md`
    - [ ] `presets/README.md`
    - [ ] `extensions/RFC-EXTENSION-SYSTEM.md`
    - [ ] `extensions/EXTENSION-API-REFERENCE.md`
- [ ] Merge `feature/workflow-research` to main as docs-only (4 analysis docs + ADR-007)
- [ ] Pick spike-1 target: `gh issue list --repo nichenke/preflight --state open --limit 10` → choose one that touches a template, rule, or small doc gap
    - Selected issue: _____
- [ ] Identify the tack-room launcher artifact (current state, partial code, design intent)
    - Location: _____
- [ ] Resolve the four cross-cutting open questions (see §"Open questions" below)

**Exit criteria**:

- spec-kit installed and behavior understood
- Research branch merged to main
- spike-1 issue selected and noted above
- launcher state located and noted above
- All four open questions in §"Open questions" have answers

**Estimated effort**: 0.5 day

**Phase status**: not started

---

## Phase 1 — Scaffold the preflight preset

**Goal**: build the smallest spec-kit preset that exercises preflight content and review engine.

### Where the scaffold lives

New top-level directory in the preflight repo:

```
preflight/
├── presets/                                    # NEW
│   └── preflight/                              # NEW: the preset itself
│       ├── preset.yml                          # NEW: spec-kit preset manifest
│       ├── extension.yml                       # NEW: extension manifest (hooks + commands)
│       ├── templates/                          # NEW
│       │   ├── spec-template.md                # NEW: composes preflight's L4 + spec format
│       │   ├── plan-template.md                # NEW: brief format, prose intent + acceptance
│       │   └── tasks-template.md               # NEW: stub or removed — PAI owns task decomposition
│       ├── commands/                           # NEW
│       │   └── speckit.preflight.review.md     # NEW: extension command def
│       └── scripts/                            # NEW
│           └── run-preflight-review.sh         # NEW: shells out to review engine
└── content/templates/                           # EXISTING — reused, not duplicated
    ├── adr-template.md                          # referenced from preset (or copied at install)
    ├── architecture-template.md
    ├── constitution-template.md
    ├── interface-contract-template.md
    ├── requirements-template.md
    ├── rfc-template.md
    └── test-strategy-template.md
```

`content/templates/*.md` are the source of truth per CONST-CI-02. The preset references them by path, or the install step copies them — pick which after answering open question #2.

### Tasks

- [ ] Author `presets/preflight/preset.yml` (id, version, description, declared overrides + extension)
- [ ] Author `presets/preflight/extension.yml` (extension command + hook wiring)
- [ ] Author `presets/preflight/templates/spec-template.md` with sections:
    - YAML frontmatter (feature ID, status, refs)
    - Intent (prose paragraph)
    - L4 coverage section (25-category checklist from `docs/reference/l4-autonomy-category-framework.md`)
    - Requirements delta (full file copy of `requirements.md` per ADR-007 Option C)
    - Architecture delta (only if architecture changes)
    - References (FRs touched, ADRs blocked-on, RFCs referenced)
    - Plans index (auto-generated list of `plans/NNN-*.md`)
- [ ] Author `presets/preflight/templates/plan-template.md` (brief format):
    - Header (plan ID, parent feature, status, FR refs)
    - Intent (one paragraph)
    - Acceptance (prose bullets — PAI decomposes to ISC)
    - Context (small, plan-scoped excerpts; reference feature spec's larger context)
    - Out of scope (for this PR only)
- [ ] Decide tasks-template fate: stub it to a single-line "PAI owns task decomposition; see plan.md acceptance" pointer, OR remove it entirely if spec-kit allows
- [ ] Author `presets/preflight/commands/speckit.preflight.review.md` extension command
- [ ] Author `presets/preflight/scripts/run-preflight-review.sh` wrapper that walks the active feature folder and invokes preflight review
- [ ] Test installation: `specify preset add ./presets/preflight` in throwaway project
- [ ] Test invocation: confirm `speckit.preflight.review` registered, hooks fire, templates resolve

**Exit criteria**:

- Preset installs without errors
- Templates resolve via spec-kit's preset chain
- `speckit.preflight.review` registered as an invocable command
- `after_specify` hook fires on `/speckit.specify` (review can be stubbed for now — wiring matters more than depth)
- No conflicts with spec-kit core defaults

**Blockers from phase 0**:
- Open question #1 (review CLI entry point) must be answered before authoring `run-preflight-review.sh`
- Open question #2 (template resolution) must be answered before deciding reference vs copy
- Open question #3 (tasks-template required?) must be answered before stub-vs-remove decision

**Estimated effort**: 1.5 days

**Phase status**: not started

---

## Phase 2 — Spike 1: small preflight issue via preset

**Goal**: validate the preset mechanic on a trivial change. Tests preset friction at minimum scale.

**Branch**: `spike/preset-small`

**Tasks**:

- [ ] Create branch off main
- [ ] Apply preset (from phase 1) to the chosen github issue
- [ ] Run `/speckit.specify <issue title>` — verify spec.md scaffolds in preflight format
- [ ] Run `/speckit.plan` — verify plan.md scaffolds
- [ ] Verify `after_specify` hook fired and review ran
- [ ] Address any review findings
- [ ] Implement the issue's actual fix (real work, not pretend)
- [ ] Run `/speckit.apply` to ratify the feature folder
- [ ] Open PR against main implementing the issue
- [ ] Author spike report at `docs/spikes/2026-04-NN-spike1-preset-small.md`

### Pass criteria

- [ ] Preset installs cleanly without modifying spec-kit source
- [ ] Hook fires reliably and review runs on every spec.md edit
- [ ] Findings flow back to user via LLM prompt
- [ ] Total spike time < 1 day
- [ ] Preset feels native enough that spec-kit branding doesn't impose noticeable overhead

### Fail criteria

- [ ] Preset API requires forking spec-kit
- [ ] Hook integration is silent or unreliable
- [ ] Spec-kit's command vocabulary creates user-visible friction that compounds over multiple invocations
- [ ] Apply step fails or produces unexpected file structure

**Don't proceed to phase 3 if**: phase 1 exit criteria not met. Fix scaffolding before spiking.

**Estimated effort**: 1 day

**Phase status**: not started

**Spike report**: _link when written_

---

## Phase 3 — Spike 3: PAI brownfield micro-spike

**Goal**: validate composition with PAI's existing structure. Tests brownfield fit claim. Run before the large spike to de-risk.

**Branch**: `spike/pai-brownfield` (in PAI repo, not preflight)

**Tasks**:

- [ ] Pick a small PAI change (rule edit, skill tweak, CLAUDE.md adjustment) — real but not urgent
    - Selected change: _____
- [ ] **Don't implement it** — sketch the feature folder only
- [ ] Decide: where does `specs/` live in PAI?
    - Option A: `$PAI_DIR/specs/`
    - Option B: PAI repo root `~/.pai/specs/` (if that's a repo)
    - Option C: project-scoped per use case
    - Decision: _____
- [ ] Author stub `specs/NNN-pai-change/spec.md` using preset templates
- [ ] Author stub `plans/001-<slug>.md` for the change
- [ ] Verify: PAI Algorithm OBSERVE phase reads plan.md and produces ISC criteria without modification
- [ ] Verify: no namespace collision between `/speckit.*` commands and existing PAI `/pai:*` commands
- [ ] Verify: `specs/` location doesn't collide with PAI memory layout (`$PAI_DIR/MEMORY/`, `PAI/`, etc.)
- [ ] Author spike report at `docs/spikes/2026-04-NN-spike3-pai-brownfield.md`

### Pass criteria

- [ ] Feature folder fits cleanly into PAI's existing structure
- [ ] spec.md references CLAUDE.md / rules files rather than duplicating them
- [ ] PAI Algorithm reads plan.md and decomposes without any PAI-side adapter code
- [ ] No tasks.md is produced or required
- [ ] No namespace collision with existing PAI commands

### Fail criteria

- [ ] Authoritative-folder smell — `specs/` wants to own things PAI already owns elsewhere
- [ ] Plan.md format is foreign to PAI's Algorithm and requires PAI-side adapter code
- [ ] Multi-agent CommandRegistrar interferes with PAI's existing command surface

**Estimated effort**: 0.5 day

**Phase status**: not started

**Spike report**: _link when written_

---

## Phase 4 — Spike 2: tack-room launcher with multi-agent verification

**Goal**: validate composable path on a large multi-plan feature with mid-build complexity, and verify multi-agent reach.

**Branch**: `spike/launcher`

**Tasks**:

- [ ] Create branch off main
- [ ] Extend the preset (additive on phase 1's work):
    - [ ] Add `presets/preflight/templates/constitution-template.md` override
    - [ ] Add `presets/preflight/templates/requirements-template.md` override
    - [ ] Add `presets/preflight/templates/architecture-template.md` override
    - [ ] Add `presets/preflight/templates/adr-template.md` override
    - [ ] Add `presets/preflight/templates/rfc-template.md` override
    - [ ] Add `presets/preflight/templates/interface-contract-template.md` override
    - [ ] Add `presets/preflight/templates/test-strategy-template.md` override
- [ ] Multi-agent registration test:
    - [ ] Pick second AI tool target (Cursor, Gemini CLI, opencode — whichever installs in <30 min)
        - Selected target: _____
    - [ ] Install preset on second target via `CommandRegistrar`
    - [ ] Verify `/speckit.preflight.*` commands appear in that agent's command directory
    - [ ] Invoke from second agent, confirm execution
- [ ] Resume tack-room launcher feature using the preset
- [ ] `/speckit.specify` for the launcher feature
- [ ] Generate at least 2 plans (`plans/001-*.md`, `plans/002-*.md`)
- [ ] Have PAI consume one plan and build it
- [ ] Force a mid-build ADR discovery scenario:
    - [ ] Find a constraint the spec didn't capture
    - [ ] Pause the build
    - [ ] Write the ADR
    - [ ] Revise spec.md
    - [ ] Resume build
- [ ] Run `/speckit.apply` to ratify
- [ ] Author spike report at `docs/spikes/2026-04-NN-spike2-launcher-multi-agent.md`

### Pass criteria

- [ ] 2+ plans produced and at least 1 shipped through the full lifecycle
- [ ] Mid-build ADR discovery handled per ADR-007 pause/escalate flow
- [ ] Multi-agent registration verified — same commands work from at least two agent targets
- [ ] Ratification PR atomically replaces main's specs

### Fail criteria

- [ ] Multi-agent registration is harder than expected, or only works on Claude Code in practice
- [ ] Preset cannot express enough of preflight's surface to feel complete
- [ ] Mid-build escalation breaks down because spec-kit's lifecycle assumes linear forward progress
- [ ] Ratification step requires manual fixups beyond what the preset can automate

**Estimated effort**: 2 days

**Phase status**: not started

**Spike report**: _link when written_

---

## Phase 5 — Synthesis and ADR-007 promotion

**Goal**: decide between standalone Path A and Path A-prime. Promote or revise ADR-007.

**Tasks**:

- [ ] Read all three spike reports back-to-back
- [ ] Apply criteria-first re-scoring (methodology angle 2.8) to spike outcomes
- [ ] Apply load-bearing-criterion isolation (angle 2.9) — name the one criterion that drove the decision, if any
- [ ] Decide path:
    - [ ] **If composable path validated**: amend ADR-007 to v2 — change Decision Outcome to specify spec-kit preset as implementation layer; update consequences; update confirmation criteria. Keep shape decisions intact.
    - [ ] **If composable path failed**: keep ADR-007 v1 (preflight-native skills); proceed to original 4-item plan (skills/explore, skills/propose, review --drift, drift hook)
    - [ ] **If results are mixed**: write ADR-008 naming the conditions under which each path applies (e.g., composable for multi-agent projects, standalone for Claude-Code-only)
- [ ] Promote ADR-007 status from Proposed to Accepted
- [ ] Open PR titled "Promote ADR-007: feature folder lifecycle" merging the chosen implementation evidence

**Exit criteria**:

- ADR-007 status is Accepted
- Chosen implementation path is documented
- PR open for merge to main

**Estimated effort**: 0.5 day

**Phase status**: not started

---

## Phase 6 — Production implementation (conditional, post-promotion)

### If Path A-prime (composable) wins

- [ ] Promote `presets/preflight/` from spike scaffold to maintained preset
- [ ] Document installation in README
- [ ] Decide distribution: lives in preflight repo vs separate `preflight-preset` repo
- [ ] Build the preflight CLI wrapper if it didn't exist (review-engine entry point)
- [ ] Version bump plugin.json v0.6.x → v0.7.0
- [ ] Submit upstream contribution to spec-kit's extension RFC discussion: blocking hooks via exit code propagation

### If standalone Path A wins

- [ ] Implement `skills/explore/SKILL.md`
- [ ] Implement `skills/propose/SKILL.md`
- [ ] Implement `skills/review/SKILL.md` `--drift` mode
- [ ] Implement `content/scaffolds/post-implementation-hook.sh`
- [ ] Version bump plugin.json v0.6.x → v0.7.0
- [ ] ADR-007 stays unchanged

**Estimated effort**: 3–5 days for either path

**Phase status**: not started

---

## Open questions

These block phase 1 and must be answered in phase 0.

### Question 1 — Does the existing preflight review skill have a CLI entry point?

- **Where to look**: `skills/review/SKILL.md` and any associated scripts
- **Why it matters**: spec-kit hooks call extension commands via spec-kit's runner; the wrapper script needs a way to invoke preflight review without requiring Claude Code to be present
- **Options if no CLI exists**:
    - (a) Wrapper invokes Claude Code in headless mode (`claude -p` or similar)
    - (b) Write a small Python or bash entry point that runs the rules directly without Claude
- **Recommendation**: option (b) is cleaner because spec-kit hooks should not depend on Claude Code being installed in the target environment
- **Status**: open
- **Answer**: _____

### Question 2 — How does spec-kit preset resolution treat templates: copy or reference?

- **Where to look**: `presets/ARCHITECTURE.md` "Resolution" section, `src/specify_cli/presets.py` `PresetResolver` implementation
- **Why it matters**: determines whether `content/templates/*.md` can be pointed at by reference (clean — preserves CONST-CI-02 source-of-truth) or must be duplicated into `presets/preflight/templates/` (fragile — drift risk)
- **Options**:
    - (a) Reference: preset declares paths to existing templates, spec-kit reads them in place
    - (b) Copy at install: spec-kit copies templates into preset directory at install time
    - (c) Hard requirement: templates must live inside the preset directory; we copy or symlink as part of preset build
- **Recommendation**: prefer (a). If only (c) works, build a symlink at preset-build time so the source files stay canonical.
- **Status**: open
- **Answer**: _____

### Question 3 — Does spec-kit allow `tasks-template.md` to be missing?

- **Where to look**: `presets/ARCHITECTURE.md` required-templates list, lifecycle command source
- **Why it matters**: the composable architecture drops `tasks.md` because PAI owns task decomposition. If spec-kit's lifecycle assumes the file's presence, we need a stub; if it tolerates absence, we remove it cleanly.
- **Options**:
    - (a) Stub it with a single-line pointer: "PAI owns task decomposition; see plan.md acceptance"
    - (b) Remove entirely if optional
- **Status**: open
- **Answer**: _____

### Question 4 — What's the second AI target for spike 2's multi-agent test?

- **Why it matters**: spike 2 verifies the multi-agent CommandRegistrar reach. Need a target that installs in <30 minutes and has a command directory spec-kit registers to.
- **Candidates**: Cursor, Gemini CLI, opencode, Tabnine, Windsurf, Qwen
- **Selection criteria**: cheapest install, most reliable, has clearest command directory model
- **Status**: open
- **Answer**: _____

---

## Findings log

Append findings here as spikes complete. Each entry: phase, date, finding, action implication.

(empty)

---

## What's deliberately not in this plan

- **No upstream contributions during the spikes** — those happen post-decision in phase 6, not as part of validation
- **No content for the deferred items** (data model template, threat model template, JTBD framing) — those stay backlogged per pass 5
- **No CI integration of preflight review** — phase 6+ concern, not spike scope
- **No work on dispatch or pai-source examples beyond what spike walkthroughs require** — risk of scope creep
- **No documentation updates to preflight's README** — happens post-promotion in phase 6

---

## Day-60 tripwire (independent of spike completion)

The pass 5 re-analysis day-60 tripwire (2026-06-13) remains in force regardless of spike progress. At that date, refresh:

- Rate-of-change data on OpenSpec, spec-kit, BMAD, GSD-2
- spec-kit hook semantics — has `blocking: true` shipped?
- OpenSpec validator hooks — has anything shipped?
- Tack Room program scope — Claude Code-only or multi-agent in practice?

If any of those change, re-evaluate the path even if spikes already promoted ADR-007.
