# Spike plan — preflight ADR-007 validation

A living tracking document for the three spikes that gate ADR-007 from Proposed to Accepted. Update inline as phases complete. Spike reports drop into this directory alongside this file.

## Status header

- **Created**: 2026-04-13
- **Owner**: nic
- **Current phase**: 0 — pre-spike setup
- **Last updated**: 2026-04-13
- **ADR being validated**: [ADR-007 feature folder lifecycle](../../specs/decisions/adrs/adr-007-feature-folder-lifecycle.md)
- **Estimated effort to ADR-007 promotion**: \~6 working days
- **Estimated effort to production**: +3–5 days after promotion

Update the `Current phase` field as phases progress: `0 → 1 → 2 → 3 → 4 → 5 → 6 → done`.

## Purpose

ADR-007 proposes a feature-folder lifecycle for in-flight changes. The composable architecture analysis (2026-04-13) raised the question of whether ADR-007 should be implemented as preflight-native skills (Path A) or as a spec-kit preset that composes with preflight's review engine (Path A-prime). Three spikes test the composable path against real work; results determine the implementation layer and promote ADR-007.

## Source documents

Read these before starting:

- [ADR-007: Adopt feature-folder lifecycle for in-flight changes](../../specs/decisions/adrs/adr-007-feature-folder-lifecycle.md) — the shape decision being validated
- [Composable architecture](../analysis/2026-04-13-composable-architecture.md) — proposes Path A-prime; defines the three spikes
- [spec-kit composition topologies](../analysis/2026-04-13-speckit-composition-topologies.md) — community ecosystem survey (8 presets, 63 extensions) + five-topology decomposition (A–E) that refines Path A-prime into distinct sub-options. Input to Open Question 5.
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

- [x] Install spec-kit locally (`pipx install specify-cli`); verify `specify --version` and `specify init` work in throwaway dir
- [x] Read spec-kit's preset + extension docs end to end:
  - [x] `presets/ARCHITECTURE.md`
  - [x] `presets/README.md`
  - [x] `extensions/RFC-EXTENSION-SYSTEM.md`
  - [x] `extensions/EXTENSION-API-REFERENCE.md`
- [x] Merge `feature/workflow-research` to main as docs-only (PR #23, merged 2026-04-14)
- [x] Pick spike-1 target: `gh issue list --repo nichenke/preflight --state open --limit 10` → choose one that touches a template, rule, or small doc gap
  - Selected issue: **#13**
- [x] Identify the tack-room launcher artifact (current state, partial code, design intent)
  - Location: /Users/Shared/sv-nic/src/tack-room/BOOTSTRAP.md.
- [x] Resolve the five cross-cutting open questions (see §"Open questions" below)
- [x] **Choose a composition topology (Question 5) before any `presets/preflight/` scaffold work.** Review [spec-kit composition topologies](../analysis/2026-04-13-speckit-composition-topologies.md) §2–§5 and pick one of A/B/C/D/E (or a hybrid). The choice reshapes Phase 1 tasks.

**Exit criteria**:

- spec-kit installed and behavior understood
- Research branch merged to main
- spike-1 issue selected and noted above
- launcher state located and noted above
- All five open questions in §"Open questions" have answers
- Composition topology selected and recorded in Question 5

**Estimated effort**: 0.5 day

**Phase status**: **closed 2026-04-14**. All exit criteria met — PR #23 merged, spike-1 issue #13 selected, Q1/Q2/Q3/Q4/Q5 all answered.

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

**Blockers from phase 0**: **none as of 2026-04-14** — all five open questions are answered (Q1: option (a) headless Claude or host-agent LLM; Q2: option (c) templates physically live under preset dir, populated via `git mv content/templates/` → `presets/preflight/templates/` since preflight is converting from plugin to native spec-kit organization; Q3: don't override tasks-template, override `/speckit.tasks` and `/speckit.implement` commands as PAI redirects; Q4: Codex as multi-agent target; Q5: Topology A). Phase 0 closed.

**Estimated effort**: 1.5 days

**Phase status**: **in progress 2026-04-14** — branch `feature/preset-scaffold` has 8 commits covering the plugin → spec-kit conversion in staged slices:

| Slice | Commit | Content |
|---|---|---|
| 1 | `4cdeec9` | `git mv content/templates/*.md` → `presets/preflight/templates/`; author `preset.yml`, `extension.yml`, `speckit.tasks` + `speckit.implement` PAI-redirect commands, `speckit.preflight.review` stub |
| 1.5 | `a487a43` | Minimal `pyproject.toml` + uv `[dependency-groups] dev`, `uv.lock`, `.gitignore` additions |
| 2 | `80d44f6` | `git mv content/rules-source/*.md` → `extensions/preflight/rules/`; update review command for table-format rule loading |
| 3 | `79d93ec` | `git mv content/reference/` → `docs/reference/`; `git mv content/scaffolds/` → `extensions/preflight/scaffolds/`; remove `content/` |
| 4 | `5069464` | `git mv agents/reviewers/*` → `extensions/preflight/agents/reviewers/`; rewrite `speckit.preflight.review.md` as full orchestrator port of `skills/review/SKILL.md` with two-agent ensemble; `git rm -r skills/` |
| 5 | `e62fba6` | Remove Claude Code plugin artifacts: `.claude-plugin/`, `commands/`, `hooks/`, `tests/` |
| 6 | `67d9566` | Rewrite `CLAUDE.md` + `README.md` for spec-kit extension form |
| 7 | `2fcbeb7` | `specs/constitution.md` status banner + CONST-CI-02 path fix (full rewrite deferred to ADR-008 or post-spike) |

Phase 1 exit criteria (install cleanly, templates resolve, review command invocable, hooks fire) still require validation via `specify preset add` and `specify extension add` in a throwaway target project. That validation is the first task of Phase 2 (spike 1).

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
- [ ] **Verify two-agent ensemble dispatch works from spec-kit command context**: `speckit.preflight.review` should dispatch both `checklist-reviewer` and `bogey-reviewer` as subagents (via the host agent's Task/Agent tool), both should complete, and their outputs should merge per the orchestrator's step 7. If the host agent can't dispatch subagents from a spec-kit command prompt, or the `.specify/extensions/preflight/agents/reviewers/*.md` path references don't resolve at runtime, flag as a spike blocker.
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
  - Selected change: **\_**
- [ ] **Don't implement it** — sketch the feature folder only
- [ ] Decide: where does `specs/` live in PAI?
  - Option A: `$PAI_DIR/specs/`
  - Option B: PAI repo root `~/.pai/specs/` (if that's a repo)
  - Option C: project-scoped per use case
  - Decision: **\_**
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
    - Selected target: **\_**
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
- [ ] **Evaluate spec-kit's native optional commands against preflight's review ensemble** (added 2026-04-14 during Phase 1 install test). `specify init` offers three optional commands that overlap with preflight's differentiators:
  - `/speckit.clarify` — structured de-risking questions before planning. Overlaps with preflight's former `/preflight new` guided elicitation. Could host elicitation logic natively.
  - `/speckit.analyze` — cross-artifact consistency report. Directly overlaps with bogey-reviewer's Layer 1 (cross-doc assumption conflicts).
  - `/speckit.checklist` — quality checklist generation. Overlaps with checklist-reviewer's rule-based pass.

  Questions to answer in synthesis: Is preflight's ensemble adding value over native clarify+analyze+checklist combined, or is it re-inventing them? Should preflight compose with them (clarify for elicitation, preflight review as the rule-graded + adversarial layer on top) or replace them? If compose, does that simplify preflight's extension surface area?

  Input for the Topology A vs Topology C discussion at ADR-007 promotion time. If the native commands cover 80% of preflight's value, Topology C (substrate-neutral core with thin adapters) becomes more attractive since preflight's distinctive value shrinks.
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
- [ ] ~~Submit upstream contribution to spec-kit's extension RFC discussion: blocking hooks via exit code propagation~~ (withdrawn 2026-04-22 per Stream B B5 finding — blocking-hook semantics are not on upstream's roadmap; enforcement primitive going forward is the workflow engine's Gate step. If engaging upstream, comment on issue #2104 instead. See `docs/analysis/2026-04-22-speckit-hook-philosophy.md`.)

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
- **Framing correction (2026-04-14)**: the original question implied "preflight needs a deterministic CLI validator to bypass Claude." That framing was wrong. Preflight's review skill (checklist reviewer + bogey reviewer) is **already LLM-based** — not deterministic. Preflight's distinctive value is not "we don't need an LLM" but "we feed the LLM curated rules it wouldn't otherwise see" (see revised options below and Community context).
- **What preflight actually distinguishes on** (vs tikalk, panaversity, others):
  - Rules as first-class edited artifacts (`content/rules-source/*.md` per CONST-CI-02), versioned and testable — not embedded in command prompts
  - Severity grades (Critical/High/Medium/Low) attached to findings
  - Stable rule IDs for traceability (FR-NNN, ADR-NNN, CONST-*)
  - Ensemble review with multiple lenses (checklist + bogey), not a single LLM pass
  - Cross-doc traceability rules (FR referenced in ADR must exist in requirements.md)
  - Review as a dedicated structured step, not inline in each command
- **Options** (revised):
  - (a) **`claude -p` headless** — the spec-kit command script invokes Claude Code in headless mode with the preflight rules pre-loaded as context + the target doc. Lightest lift if Claude Code is already installed in the target environment (true for CC plugin users).
  - (a') **LLM via provider API** — the script calls Anthropic/OpenAI directly, passing preflight rules + doc + structured-output contract. More substrate-independent than (a); more work to implement.
  - (c) **Hybrid** — small deterministic prechecks (ID format, section presence) + LLM review for content quality. The deterministic piece is a tiny subset of the 48 rules; the LLM is still load-bearing.
- **Recommendation**: **(a) for the spike**, with (a') as the production path if we need substrate independence. Deterministic-only (previously option (b)) is withdrawn — it bypasses the actual review work.
- **Community context (research 2026-04-14)**: neither `tikalk/agentic-sdlc-spec-kit` nor `panaversity/spec-kit-plus` has a non-LLM validator. Both use LLM-based validation via spec-kit commands — exactly the pattern preflight should follow:
  - **tikalk architect extension**: `adlc.architect.validate` and `adlc.architect.analyze` are LLM-prompt commands invoked via `before_plan`/`after_plan` hooks. See `~/.cache/agentic-sdlc-spec-kit/extensions/architect/extension.yml`. The pattern is directly reusable: define a spec-kit command, declare hooks in `extension.yml`, let spec-kit's runner invoke the LLM with the command's prompt as context. Rules are embedded in the command prompt text.
  - **panaversity spec-kit-plus**: `sp.checklist` generates quality checklists; `memory/*.md` (constitution, command-rules) is prompt-injected context via spec-kit's normal loading. Rules live as text the LLM considers, not as an enforced schema.
  - **What this means for preflight**: copy the tikalk pattern — define `speckit.preflight.review` as a spec-kit command that loads preflight rules from `content/rules-source/` as prompt context, declares `after_specify`/`after_plan` hooks in `extension.yml`, and invokes via spec-kit's command runner. Panaversity's `memory/*.md` loading pattern is useful for how to present rules as LLM context without overwhelming the prompt budget. Neither fork gives us a CLI-wrapping pattern because neither needs one.
- **Phase 1 task implied**: the preflight preset ships `commands/speckit.preflight.review.md` with rules loaded as prompt context, and declares hooks in `extension.yml`. **No subprocess script required** unless we want substrate independence from Claude Code specifically. The original Phase 1 task "Author `scripts/run-preflight-review.sh`" is withdrawn for the spike; it may return as a production hardening step.
- **Status**: answered 2026-04-14
- **Answer**: **Option (a) — spec-kit command invokes Claude Code (or the host agent's LLM) with preflight rules loaded as prompt context**. Tikalk's `architect.validate` is the reference pattern. No deterministic subprocess wrapper needed for the spike. Verify by reading `skills/review/SKILL.md` during Phase 1 scaffolding to confirm rule loading can be lifted into a preset command context.

### Question 2 — How does spec-kit preset resolution treat templates: copy or reference?

- **Where to look**: `presets/ARCHITECTURE.md` "Resolution" section, `src/specify_cli/presets.py` `PresetResolver` implementation
- **Why it matters**: determines whether `content/templates/*.md` can be pointed at by reference (clean — preserves CONST-CI-02 source-of-truth) or must be duplicated into `presets/preflight/templates/` (fragile — drift risk)
- **Options**:
  - (a) Reference: preset declares paths to existing templates, spec-kit reads them in place
  - (b) Copy at install: spec-kit copies templates into preset directory at install time
  - (c) Hard requirement: templates must live inside the preset directory; we copy or symlink as part of preset build
- **Recommendation**: prefer (a). If only (c) works, build a symlink at preset-build time so the source files stay canonical.
- **Status**: **answered 2026-04-14** via code analysis of `~/.cache/spec-kit` (shallow clone)
- **Answer**: **Option (c) — hard requirement. Templates must physically live under `.specify/presets/<id>/templates/`.** Spec-kit's resolver looks up templates by hardcoded path, not by declaration in `preset.yml`.
  - **Proof (from `~/.cache/spec-kit`)**:
    1. `src/specify_cli/presets.py:1654-1662` — `PresetResolver` docstring declares the fixed priority stack: `.specify/templates/overrides/` → `.specify/presets/<preset-id>/templates/` → `.specify/extensions/<ext-id>/templates/` → `.specify/templates/`. No reference-by-path option.
    2. `src/specify_cli/presets.py:1760-1768` — `resolve()` iterates registered presets and checks `pack_dir / subdir / f"{template_name}{ext}"` where `pack_dir = self.presets_dir / pack_id` and `subdir = "templates"`. The file must physically exist at that path.
    3. `presets/ARCHITECTURE.md:32-35` — "Template Resolution" table confirms the four-tier stack with fixed paths and no indirection.
    4. `presets/ARCHITECTURE.md:39-42` — resolution is implemented three times (Python `PresetResolver`, bash `resolve_template()`, PowerShell `Resolve-Template`) to guarantee consistency — so there is no alternate "reference" path hiding elsewhere.
  - **Implication for preflight**: preflight is **converting organizational form** from Claude Code plugin to native spec-kit extension. The old plugin layout (`content/templates/`, `content/rules-source/`, `skills/`, `.claude-plugin/`) is being replaced, not dual-maintained. Templates move via `git mv content/templates/* presets/preflight/templates/` — preserves file history, no symlinks, no drift problem, no CONST-CI-02 duplication because there's only one location after the move. If we ever want the plugin form back, `git revert` the conversion commit(s).
  - **Decision for this spike**: **`git mv`** — single source of truth by location, not by tooling. Clean cut from plugin to extension.
  - **Phase 1 task implied**: after creating `presets/preflight/templates/` directory, `git mv` each template from `content/templates/` into it. CONST-CI-02 either needs to be rewritten to reference the new location or retired in favor of a spec-kit-native equivalent (tracked as a follow-up during scaffold).

### Question 3 — Does spec-kit allow `tasks-template.md` to be missing?

- **Where to look**: `presets/ARCHITECTURE.md` required-templates list, lifecycle command source
- **Why it matters**: the composable architecture drops `tasks.md` because PAI owns task decomposition. If spec-kit's lifecycle assumes the file's presence, we need a stub; if it tolerates absence, we remove it cleanly.
- **Options**:
  - (a) Stub it with a single-line pointer: "PAI owns task decomposition; see plan.md acceptance"
  - (b) Remove entirely if optional
- **Status**: **answered 2026-04-14** via code analysis of `~/.cache/spec-kit` (shallow clone)
- **Answer**:

  **Short version**: `tasks-template.md` is optional at the preset level, but the wrong artifact to worry about. The hard requirement is on `tasks.md` (the output file) not `tasks-template.md` (the template). The fix is to override two commands, not delete the template.

  **Proof that `tasks-template.md` is optional**:
  1. `src/specify_cli/presets.py:1797` — `PresetResolver.resolve()` walks overrides → preset → extension → core and returns `None` if it falls off the end. No startup validation. No exception.
  2. The official `lean` preset (`presets/lean/preset.yml`) ships zero template overrides — only command overrides. Proves template entries are opt-in.
  3. `presets.py:127` — manifest validation only requires that `provides.templates` is non-empty; command-only presets pass.

  **The real gate is `tasks.md` (the output)**, not `tasks-template.md`:
  - `templates/commands/implement.md:3` runs `check-prerequisites.sh --require-tasks --include-tasks`
  - `scripts/bash/check-prerequisites.sh:128-131` hard-errors if `FEATURE_DIR/tasks.md` is missing:
    ```
    if [ ! -f "$TASKS" ]; then
        echo "ERROR: tasks.md not found in $FEATURE_DIR" >&2
        echo "Run /speckit.tasks first to create the task list." >&2
    ```
  - `/speckit.plan` has a `handoffs` block (`templates/commands/plan.md:3-7`) pointing at `/speckit.tasks` as the suggested next step — handoff suggestion, not automatic invocation.

  **Implication for the preflight preset**:
  - **Do not override `tasks-template.md`.** Leave core's as fallback. Waste of maintenance.
  - **Override `/speckit.tasks`** (following `lean` preset's pattern at `presets/lean/preset.yml:30-33`) with a redirect: "This preset delegates task decomposition to PAI. Do not run `/speckit.tasks`. Instead, run PAI Algorithm against `plan.md`." Optionally generate a one-line stub `tasks.md` so `/speckit.implement`'s prereq check passes if the user runs it by habit.
  - **Override `/speckit.implement`** similarly: redirect to PAI against `plan.md`.
  - Both overrides propagate through `CommandRegistrar` to all 17+ agent dirs, so a second agent in the multi-agent scenario also gets the redirect — not the core command.
  - Net: `tasks.md` can be absent in the flow (PAI never writes it), and the failure mode if someone runs `/speckit.implement` by habit is a legible error pointing at the redirect, not silent breakage.

  **Related Phase 1 task adjustment**: the "Decide tasks-template fate" task in Phase 1 should be replaced with "Author `presets/preflight/commands/speckit.tasks.md` and `presets/preflight/commands/speckit.implement.md` as redirects to PAI."

### Question 4 — What's the second AI target for spike 2's multi-agent test?

- **Why it matters**: spike 2 verifies the multi-agent CommandRegistrar reach. Need a target that installs in <30 minutes and has a command directory spec-kit registers to.
- **Candidates**: Cursor, Gemini CLI, opencode, Tabnine, Windsurf, Qwen
- **Selection criteria**: cheapest install, most reliable, has clearest command directory model
- **Status**: **answered 2026-04-14**
- **Answer**: **Codex**. Already integrated with this environment via the `codex:*` plugin; command directory model is well-understood; zero new install cost.

### Question 5 — Which composition topology is this spike actually testing?

- **Where to look**: [spec-kit composition topologies](../analysis/2026-04-13-speckit-composition-topologies.md) §2 (topologies A–E), §3 (comparison table), §5 (decision input questions)
- **Why it matters**: the current spike design (Phase 1–4) implicitly assumes Topology A (preflight *becomes* a spec-kit extension, potentially abandoning the Claude Code plugin form factor). The research doc surfaces four other viable topologies. Phase 1 scaffold work (`presets/preflight/`) only makes sense after picking one, because the scaffold shape differs per topology:
  - **Topology A** — full preset + extension; abandon CC plugin as primary; Phase 1 as currently written
  - **Topology B** — no spec-kit preset; integrate with `docguard`; Phase 1 becomes a docguard rule-pack build
  - **Topology C** — extract a substrate-neutral core first, then ship two thin adapters (CC plugin + spec-kit extension). Phase 1 adds a core-extraction step; Phase 4 multi-agent test becomes load-bearing
  - **Topology D** — rulepack + 3+ adapters; defer or drop (violates rate-of-change short-horizon principle)
  - **Topology E** — cancel the preset spike entirely; keep Path A (preflight-native skills) and study docguard/archive/ci-guard as prior art only
- **Sub-questions to answer before picking** (from the topologies doc §5):
  1. Is the Claude Code plugin form factor load-bearing, or negotiable?
  2. Is multi-agent reach (17+ AI targets) worth paying maintenance cost for?
  3. How much churn tolerance does preflight have for spec-kit's release train over the next 60 days?
  4. Is the preflight rule engine already substrate-neutral? (cheap unblocker: 1-day audit of `skills/review/`)
  5. What's the cost of ecosystem isolation in 90 days if preflight stays standalone?
  6. Is preflight's value the integrated CC plugin UX, or is it the rulepack?
- **Prerequisite for answering**: review of the topologies doc by nic. **Do not scaffold Phase 1 until Question 5 has an answer** — the scaffold shape depends on the topology.
- **If Topology C is picked**: add a Phase 0.5 "substrate-neutral core extraction audit" task before Phase 1; update Phase 1 to build two adapters instead of one preset; keep Phase 4 multi-agent test as load-bearing validation.
- **If Topology E is picked**: delete Phases 1, 2, and 4 of this plan; keep Phase 3 (PAI brownfield sanity check) and promote ADR-007 under the original Path A plan with no preset work at all.
- **If Topologies B or D are picked**: Phase 1–4 need significant rewriting; flag as a plan-level change.
- **Status**: **answered 2026-04-14** — **Topology A selected**
- **Answer**: **Topology A — preflight becomes a spec-kit extension.** Rationale (from nic via Notion): "want to see what it's like living directly in the ecosystem rather than dipping our toes and missing something. The cleanest future solution if we don't care about BMAD, OpenSpec, etc — and we don't, for now."

  **Scope narrowing for the initial spike** (refined 2026-04-14 from Notion comments):
  - ✅ **Include** `archive` extension (`stn1slv/spec-kit-archive`) — 1 command, isolated, maps directly to ADR-007's ratification step. Compose as a peer, not a dependency. Install + call its command at ship time. Near-zero composition cost.
  - ❌ **Exclude** `docguard` — it's a substrate, not a composition partner. Using it would mean preflight's review logic lives as docguard rule packs (docguard-proprietary format), enforcement shifts to docguard's hook timing, and preflight becomes a docguard client rather than a peer. Too invasive for an initial spike.
  - ❌ **Exclude** `ci-guard` — CI-time gating is not a current concern (no LLM-in-CI subscription), and it's a different enforcement phase than author-time review. Post-spike follow-up at most.
  - The initial Topology A scaffold is: preset + templates + extension manifest + `after_specify`/`after_plan` hooks + preflight review command + `archive` composition for ratification. Minimal + aligned.

  **Implications for Phase 1 tasks** (replace the current blocker list):
  - Phase 1 is unblocked; scaffold as a spec-kit extension, not a generic preset-only approach
  - `presets/preflight/` still contains the preset manifest, but the bulk of the work is an extension (`extensions/preflight/extension.yml` + command hooks)
  - CC plugin form factor is deprioritized as the primary surface for the spike — the spike explicitly tests life in the spec-kit ecosystem. CC plugin may remain as a thin secondary wrapper after the spike validates Topology A, but not during Phase 1.
  - Phase 4's multi-agent verification is load-bearing (A requires multi-agent reach to justify the form-factor trade)
  - Open question #1 (review CLI entry point) is still relevant but the answer matters differently — Topology A needs a substrate-neutral review invocation that spec-kit hooks can fire. Recommendation option (b) — a Python/bash CLI entry that runs rules directly without Claude Code — becomes load-bearing, not optional.
  - Add Phase 1 task: "Register preflight in `extensions/catalog.community.json` as `speckit-preflight`" (needed before the extension can be installed through spec-kit's normal catalog flow)
  - Deferred: composition with `archive`, `docguard`, `ci-guard`. These are post-spike follow-ups if the initial extension lands cleanly.

---

## Findings log

Append findings here as spikes complete. Each entry: phase, date, finding, action implication.

### Phase 1 — 2026-04-14 — spec-kit after-hook execution bug

**Finding**: spec-kit v0.6.2 (and main @ 0.6.3.dev0) has a 100%-consistent asymmetry across all 9 command templates (`analyze`, `checklist`, `clarify`, `constitution`, `implement`, `plan`, `specify`, `tasks`, `taskstoissues`). Every template has 2 "Mandatory hook" blocks (before + after) but only 1 "Wait for the result" instruction — attached to the before-hook block. After-hook mandatory blocks emit an `EXECUTE_COMMAND` directive but without the sequencing instruction, so host agents (Claude Code) print the directive as informational text and stop. Auto-execution works for `before_*` hooks, silently fails for `after_*` hooks.

**How discovered**: ran `/speckit.specify` in the test project after setting `optional: false` on preflight's `after_specify` / `after_plan` hooks. Spec-kit correctly emitted "Automatic Hook: preflight / EXECUTE_COMMAND: speckit.preflight.review" but Claude Code stopped after printing it. Traced to missing "Wait for the result" instruction in `templates/commands/specify.md:257-264`.

**Full analysis (current)**: [`docs/analysis/2026-04-22-speckit-hook-philosophy.md`](../analysis/2026-04-22-speckit-hook-philosophy.md) — Stream B B5 classification reframes this finding as **(β) intentional advisory design**, not a bug. (The earlier "bug" analysis at `docs/analysis/2026-04-14-speckit-after-hook-execution-bug.md` was deleted 2026-04-22; see git log for the original text.)

**Action implication** (updated 2026-04-22 per B5):
1. **Workaround for Phase 2 spike 1**: manually invoke `/speckit.preflight.review` after `/speckit.specify` and `/speckit.plan`. Unchanged — still the right workaround, now understood as the *expected* interaction pattern under advisory hook semantics, not a temporary mitigation for a bug.
2. ~~**Upstream PR** to `github/spec-kit`...~~ **Withdrawn 2026-04-22.** The behavior is intentional upstream design (evidence: `src/specify_cli/extensions.py:2509` explicitly delegates execution to the host AI agent; issue #2104 is an OPEN feature request asking for `auto_run: true`; issue #2279 was closed "not a bug" by maintainer). Filing a patch would be closed as duplicate or rejected on design grounds. If preflight engages upstream, comment on #2104 instead.
3. **Q1 framing update (superseded)**: the original claim that `optional: false` is the "blocking hooks" mechanism the research asked about is wrong. Spec-kit's designated enforcement primitive is the workflow engine's Gate step (PR #2158, v0.7.0+), on a different integration surface than hooks. Preflight's hook-extension composition cannot enforce author-time review — the integration-topology question is reopened in ADR-007's "Integration topology" section.
4. ~~**Exception to "no upstream contributions during spikes"**...~~ **Moot.** No upstream patch is being filed. Issue #25 remains in preflight's tracker as the local record of the investigation; it does not require upstream filing.

### Phase 1 — 2026-04-14 — ensemble dispatch validated on first manual review

**Finding**: manual invocation of `/speckit.preflight.review` on a spec-kit-generated spec (`specs/001-reverse-string/spec.md`) successfully dispatched both subagents (checklist + bogey) via Claude Code's Task tool. Both reviewers completed; merged output came back in the expected Critical/Important/Suggestion format with proper source attribution (rule ID vs `structural`). **Ensemble dispatch mechanism works** — the Topology A concern about "can a spec-kit command prompt actually drive two-agent dispatch" is resolved in preflight's favor.

Three Important findings surfaced on a trivial reverse-string feature spec. Each reveals a distinct signal about the ensemble's value:

1. **[Important] UNIV-01 missing frontmatter** (checklist-reviewer, confidence 97). Spec-kit's `/speckit.specify` template produces prose metadata (`**Feature Branch**:`, `**Created**:`) instead of YAML frontmatter. **Finding interpretation**: this is a **rule scoping bug** in preflight, not a doc defect. UNIV-01 was written for plugin-era doc types (requirements.md, ADRs, constitution) that need durable authorship metadata. Feature specs under spec-kit form are transient per-feature artifacts where prose metadata is the spec-kit convention. Action: rewrite UNIV-01 to exempt `type: spec` (generic feature spec), or scope the rule to "documents with durable authorship". Track as a Phase 5 rule-scoping task.

2. **[Important] SC-002 unspecified benchmark environment** (bogey-reviewer Layer 2 H1, confidence 92; also flagged by checklist UNIV-04 at confidence 82 — bogey retained for higher confidence). Feature spec said "under 10 milliseconds on a standard developer machine." **Finding interpretation**: the spike's quote — "spec ahead of where our harness can help" — captures it exactly. Only bogey-reviewer's adversarial pass catches this. A pure rule check wouldn't flag it because there's no rule for "benchmark environment must be concrete." **Confirms the ensemble's value**: rule-based review alone would miss this class of defect. Evidence for the spike 1 report.

3. **[Important] SC-004 unmeasurable onboarding claim** (bogey-reviewer H1, confidence 90). Feature spec generated: "A developer unfamiliar with the codebase can locate, import, and correctly use the function in under 5 minutes." **No test population, sample size, evaluator, or procedure.** **Finding interpretation — the most important signal from the whole test run**: spec-kit's `/speckit.specify` invented a criterion that no agent, test suite, or planning tool can verify. The template told it to produce "measurable success criteria" and it produced something that *sounds* measurable but isn't. This points at two follow-up experiments:
   - **Would `/speckit.clarify` have caught SC-004 before `/speckit.specify` wrote it?** Test in Phase 2 or Phase 5 by running the same feature through clarify → specify and comparing. If clarify catches it, that's a composition win: clarify + preflight review are complementary.
   - **Is there a pre-specify elicitation skill preflight should ship?** The old `/preflight new` skill did guided questioning before spec creation. Reframed for spec-kit form, this could be `speckit.preflight.elicit` as a pre-hook on `/speckit.specify` that runs a scoping pass to catch "you haven't thought this through yet" before a full spec is generated. Track as a Phase 5 synthesis input: does preflight add value here, or does `/speckit.clarify` already cover it?

**Implication for Topology A vs Topology C decision**: the ensemble dispatch works (validates Topology A mechanically), but findings 1 and 3 suggest preflight's rule set needs **material updates to match spec-kit's actual output**, not just path fixes. If the scope of the rule rewrites is large, Topology C (substrate-neutral core that ships to multiple adapters) becomes more attractive because the rule engine would be shared. If the scope is small, Topology A stays preferred.

### Phase 1 — 2026-04-14 — reviewer coverage non-determinism on multi-instance rules

**Finding**: after rescoping UNIV-01 to exempt `spec`/`plan`/`tasks` and re-running `/speckit.preflight.review` against the same `specs/001-reverse-string/plan.md` twice, the checklist reviewer caught **different UNIV-04 instances on different runs**:

- Run A flagged L16 `"any modern browser that supports Intl.Segmenter"` (vague adjective "modern") at confidence 85.
- Run B missed L16 entirely but flagged L30 `"Simplicity: PASS — no unnecessary abstractions; single function, single file"` (unquantified "simple") at confidence 80.
- Run B additionally flagged a UNIV-03 empty-section finding on L72-L74 that Run A did not report.

Both candidate phrases were present in both runs — the document did not change between runs. The reviewer is making partial, non-overlapping passes over multi-instance rules.

Additionally, in Run B the reviewer's own meta-commentary asserted the plan-exemption was *not* stated in the loaded rule text, when in fact the exemption section was present on disk (verified via `grep`). The reviewer's self-reports about rule content are not reliable evidence of what the rule actually says.

**How discovered**: while testing the UNIV-01 rescope edit in the sibling test project after reinstalling preset + extension via `--dev`. Re-review was meant to confirm the frontmatter finding was gone; the comparison surfaced the coverage gap as a side effect.

**Action implication**:
1. **Not a Phase 1 conversion blocker** — the rules on disk are correct, the mechanism dispatches, and findings produced are legitimate. The reliability wobble is orthogonal to whether Topology A's composition works.
2. **Phase 5 investigation task** (new): reviewer coverage strategy. Options to evaluate: (a) multi-pass consensus dispatch — run the checklist reviewer N times, union findings; (b) rule-by-rule structured prompting — one rule per reviewer call, forcing exhaustive coverage; (c) deterministic pre-pass — regex/grep scan for the enumerated UNIV-04 vague adjectives and feed hits to the reviewer as candidates. Decide during Phase 5 synthesis.
3. **Phase 5 investigation task** (new): reviewer self-reporting reliability. Reviewer prose about "the rule says X" should not be trusted as a source of truth about rule content. Either (a) suppress rule-content commentary from reviewer output, or (b) cite rule text with line numbers so claims are verifiable, or (c) instrument the dispatch command to log the exact rule bytes passed as prompt context for each run.
4. **Do not block PR #24 merge on this** — conversion mechanics are validated; reliability is a Phase 5 concern that applies to any LLM-driven review regardless of topology.

**Implication for Topology A vs Topology C decision**: coverage non-determinism is substrate-neutral — it would afflict any LLM reviewer wrapping the same rule set, whether shipped as a spec-kit extension (A) or a shared core with thin adapters (C). This finding does not shift the topology balance.

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
