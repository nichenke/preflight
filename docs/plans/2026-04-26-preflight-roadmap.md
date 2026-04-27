# Preflight roadmap — Q2 2026 reshape

**Date:** 2026-04-26
**Owner:** Nic
**Status:** Active
**Source analysis:** [`docs/analysis/2026-04-26-preflight-strategic-reimagine.md`](../analysis/2026-04-26-preflight-strategic-reimagine.md)
**Tracking:** Update checkboxes inline as work completes. Bump the *Last reviewed* line below each session.

**Last reviewed:** 2026-04-26 (initial author)

---

## North star

Preflight is a Claude Code skill bundle invoked by PAI during BUILD when the task involves harness creation or modification. Its value is **building, modifying, reviewing, and re-reading the durable project harness your agents execute against** — not a template library users pick from. Templates and rules are inputs to the workflow, not the user-facing surface.

User experience phases in. **Initial (Phase A):** user invokes `/preflight:explore` directly in a NATIVE PAI session → workflow asks deep questions → workflow drafts the right preflight docs → reviewers catch gaps → user iterates → human review of explore output is required before BUILD → BUILD proceeds. **Later (Phase B):** PAI two-phase orchestration — PAI runs `/preflight:explore` from a user input, the user reviews/PRs the explore output before BUILD. Same human-review gate; less ceremony to start.

Task sizing in this roadmap uses **S / M / L** rather than time estimates: S = a few hours or less, M = up to roughly a day, L = multi-day. Time-on-clock is a poor metric for whether something is "real time to re-derive" and tends to anchor expectations badly; size signals are honest about relative scope without committing to a clock.

---

## Kill switches

- **2026-05-03:** If Phase 1 (foundation) isn't done, stop the strategic re-evaluation and just ship Phase 2 (cleanup). Cleanup is independently valuable.
- **2026-05-10:** If Phase 3 (reshape) hasn't started, the skill-bundle conversion is being deferred. Reassess: stay on spec-kit with throttled ADR engine instead.
- **2026-05-24:** If Phase 4 (validate) hasn't produced one real feature shipped via the new workflow, the Explore skill design isn't working. Roll back to plain `/preflight:review` skill plus templates; drop the Explore workflow.

---

## Phase 1 — Foundation

**Goal:** Establish the JTBD anchor and harvest existing context before reshaping.

### Tasks

- [ ] **1.1 — Write `specs/jtbd.md`** (M)
  - Three sections: Jobs (what's preflight hired to do), User Stories (≥5 concrete narratives), Anti-Jobs (what preflight is NOT for)
  - Self-contained — no obtuse cross-doc references
  - References to FRs only when concrete
  - Exit: file exists, ≥5 stories, anti-jobs section names PAI/spec-kit/migration boundaries explicitly

- [ ] **1.2 — Re-evaluate decisions against JTBD** (M)
  - Confirm: drop spec-kit, drop self-constitution, drop ADR-007 lifecycle, ADRs survive (architecture-sized choices only — not behavior-change governance)
  - **Open: delivery shape — skill bundle vs plugin.** Plugin distribution may be cleaner for content updates and repo uses. Decision needs a JTBD covering tool delivery / update / cross-repo install patterns first; current jtbd.md only covers harness Jobs, not delivery Jobs. Add J5 (or sibling `specs/delivery-jtbd.md`) before locking the delivery shape.
  - Document any reversals as commits to the analysis doc
  - Exit: roadmap updated if JTBD surfaces anything that contradicts current direction; delivery shape decided (or explicitly deferred to Phase 2 with a delivery-JTBD prerequisite)

- [ ] **1.3 — Archive workstream HANDOFFs** (S)
  - Create `archive/handoffs/` directory
  - Move `.dispatch/HANDOFF.md` (main) → `archive/handoffs/2026-04-13-feature-folder-design.md`
  - Move `.worktrees/workflow-research/.dispatch/HANDOFF.md` → `archive/handoffs/2026-04-24-stream-a-spike1-closed.md`
  - Move `.worktrees/speckit-upstream-tracking/.dispatch/HANDOFF.md` → `archive/handoffs/2026-04-26-adr-010-cycle.md`
  - Each gets a 3-line preamble noting why it's archived
  - Exit: all 3 HANDOFFs in archive, originals removed from active worktrees

- [ ] **1.4 — Merge PR #22 (fix-req-findings)** (S)
  - Already clean: 99/99 tests, 0 Critical, 0 Important. Just stale (since 2026-04-12).
  - Closes #21
  - Exit: PR merged, branch deleted, worktree removed

### Phase 1 exit criteria
- `specs/jtbd.md` exists and is reviewed
- HANDOFFs archived
- PR #22 merged
- Roadmap unchanged or revised based on JTBD

---

## Phase 2 — Cleanup

**Goal:** Close out unfinished work, drop superseded ADRs, prepare clean slate for reshape.

### Tasks

- [ ] **2.1 — Harvest UNIV-01 fix from `test-pai-preset` worktree** (M)
  - The fix itself is real (doc-type-aware required-field table in `universal-rules.md`, ~30 LOC)
  - Strip the spec-kit chain artifacts (15KB spec.md, research.md, data-model.md, quickstart.md, contracts/, tasks.md)
  - Land as a normal PR against main
  - Closes #34
  - Exit: PR merged, fix on main, test-pai-preset worktree closed

- [ ] **2.2 — ADR close-out PR** (M)
  - Author ADR-011: "Drop spec-kit substrate; ship as Claude Code skill bundle" (the ONE meta-ADR for the reshape)
  - In same PR, mark:
    - ADR-007 → **Superseded by ADR-011** (worktrees + direct main edits replace feature-folder lifecycle)
    - ADR-009 → **Superseded by ADR-011** (integration topology no longer applicable)
    - ADR-010 → **Withdrawn** (constitution rewrite replaced by drop-self-constitution)
  - Drop forward-reference to "ADR-011 (planned)" from any remaining doc — replaced by this real ADR-011
  - Exit: PR merged, all four ADR statuses correct on main

- [ ] **2.3 — Archive analysis docs** (S)
  - Create `archive/analysis/` directory
  - Move to archive: 5 workflow-integration research passes, composable-architecture, speckit-composition-topologies, validator-chain-combinatorics, beads-gastown-comparison, framework-customization-depth, speckit-hook-philosophy, speckit-workflow-engine-mechanism, speckit-upstream-tracking
  - Keep on main: today's strategic reimagine analysis, today's roadmap, jtbd.md, reviewer-rule-gap-cluster (still useful precedent)
  - Exit: `docs/analysis/` contains only currently-active references; rest in archive

- [ ] **2.4 — Archive SPIKE_PLAN.md** (S)
  - Move `docs/spikes/SPIKE_PLAN.md` → `archive/2026-04-spike-plan.md`
  - Add closing note: "Spike 1 closed (UNIV-01 fix landed); Spikes 2/3/4/5 cancelled per ADR-011 reshape"
  - Remove `docs/spikes/` directory
  - Exit: spike plan in archive, directory gone

- [ ] **2.5 — Stale worktree + branch cleanup** (S)
  - Remove worktrees: `workflow-research` (already merged via PR #23), `speckit-upstream-tracking` (work merged via PR #33)
  - Audit 11 unmerged remote branches: `gh api repos/nichenke/preflight/branches | jq -r '.[].name'` then for each, check if its tip commit is in main's history
  - Delete obsolete remote branches (likely all 11 are dead code from earlier waves)
  - Exit: only `main` and any active feature branches remain

- [ ] **2.6 — Close pai-source issue #111** (S)
  - Comment with link to today's analysis doc
  - Mark resolved-by-decision: "Spec-kit drop decision documented in preflight repo; original concern (PAI vs `/speckit.plan` over-planning) resolved by removing spec-kit from the chain entirely"
  - Exit: issue closed with reference

### Phase 2 exit criteria
- One real feature on main (UNIV-01 fix)
- ADR statuses correct (007 + 009 superseded; 010 withdrawn; 011 = the reshape ADR)
- `docs/analysis/` contains only active references
- All worktrees except active-work ones removed
- Stale remote branches deleted
- Issue 111 closed

---

## Phase 3 — Reshape

**Goal:** Convert preflight from spec-kit preset+extension to Claude Code skill bundle with deep elicitation and gap-catching reviewers.

### Tasks

- [ ] **3.1 — Drop self-constitution + simplify governance** (M)
  - Delete `.specify/memory/constitution.md`
  - Replace with `PRINCIPLES.md` at repo root: 5–8 short claims (rule IDs are stable; rules ship as markdown; reviewer is on-demand; ADRs only on rule kernel changes; no spec-kit dependency; PAI is the orchestrator)
  - Simplify `specs/requirements.md` to remove plugin-era + spec-kit-era cruft; preserve issue-traceability and the substantive FRs
  - Tighten CONST-PROC-02 (now in PRINCIPLES.md): "ADR required when: (a) a preflight rule is added, removed, or has its severity changed; or (b) preflight's user-facing surface changes substantially. Vocabulary cleanups, typo fixes, added failure modes do not."
  - Exit: PRINCIPLES.md exists; constitution.md deleted; requirements.md simplified

- [ ] **3.2 — Restructure to skill bundle** (M)
  - Create `.claude/skills/preflight/` skill bundle structure (per analysis doc § "What preflight ships")
  - `git mv` operations:
    - `extensions/preflight/rules/*` → `.claude/skills/preflight/rules/`
    - `presets/preflight/templates/*` → `.claude/skills/preflight/templates/` (drop constitution-template.md)
    - `extensions/preflight/agents/reviewers/*` → `.claude/skills/preflight/agents/`
  - Author `.claude/skills/preflight/SKILL.md` (entry point + workflow routing)
  - Author `.claude/skills/preflight/Workflows/Review.md` (port from `extensions/preflight/commands/speckit.preflight.review.md`)
  - Delete `presets/preflight/`, `extensions/preflight/`, `.specify/`
  - Exit: bundle installs cleanly into a target project via `cp -r`; review skill runs end-to-end

- [ ] **3.3 — Author Explore workflow** (L)
  - `.claude/skills/preflight/Workflows/Explore.md`
  - Three phases: deep elicitation, doc-type routing, draft generation
  - Deep elicitation: question bank organized by intent category (new feature, design decision, requirements update, architecture change, etc.); coverage thresholds per category
  - Doc-type routing: rules for which preflight doc types apply to which intent shapes (e.g., "design exploration with multiple viable approaches → RFC; committed decision after design accepted → ADR; new functional behavior → requirements delta; integration with external system → architecture delta + interface-contract")
  - Draft generation: invoke template + fill from elicitation answers
  - Exit: workflow runs end-to-end on a synthetic intent ("add OAuth login"); produces drafts for the right doc types; routes correctly on at least 5 distinct intent shapes

- [ ] **3.4 — Add gap-reviewer agent** (M)
  - `.claude/skills/preflight/agents/gap-reviewer.md`
  - Enumerated gap categories (each category gets a gap-detection prompt):
    - Missing testing strategy
    - Missing rollback plan
    - Missing observability story
    - Missing failure modes
    - Missing rate-of-change consideration
    - Missing security implications (when applicable)
    - Internal conflicts (FR contradicts another FR; spec contradicts architecture)
    - Incompleteness (FR missing acceptance criteria; section mentioned but empty)
  - Returns structured findings (file:line:severity:category)
  - Exit: agent runs against test specs (use the archived speckit-chain artifacts as known-good test cases — they had multiple gap classes)

- [ ] **3.5 — Wire Explore → Review loop in SKILL.md** (M)
  - SKILL.md orchestrates: Explore → Review (with gap-reviewer included) → surface findings → user iterates → re-elicit if needed → re-draft → re-review
  - PAI's BUILD phase invokes preflight SKILL when task involves spec creation/modification
  - SKILL hands off to PAI's EXECUTE when specs are clean
  - Exit: end-to-end smoke test: PAI receives "I want X" → invokes preflight Explore → produces drafts + review findings → user clarifies → drafts updated → review clean → PAI proceeds

### Phase 3 exit criteria
- `.claude/skills/preflight/` skill bundle exists with full structure
- No spec-kit artifacts remain (`presets/`, `extensions/`, `.specify/` all gone)
- Explore + Review workflows functional
- Gap-reviewer agent operational
- PAI can invoke preflight end-to-end on a real (or synthetic) intent

---

## Phase 4 — Validate

**Goal:** Use the new shape on a real feature; iterate based on real friction; ship v0.7.0.

### Tasks

- [ ] **4.1 — Pick a real feature** (S)
  - Candidates: any of preflight's open issues, OR a feature in another active project (tack-room launcher mentioned in original ADR-007 spike plan)
  - Criterion: single-PR-sized scope, exercises ≥3 preflight doc types
  - Exit: feature picked, intent statement written

- [ ] **4.2 — Run end-to-end on the chosen feature** (M)
  - Invoke PAI; state intent
  - Observe Explore workflow's questions — too many? too few? wrong category?
  - Observe routing decisions — right doc types selected?
  - Observe drafts — usable? need editing?
  - Observe reviewer findings — real gaps caught? false positives?
  - Iterate user → workflow → user
  - Exit: feature spec validated through workflow; PAI proceeds to BUILD

- [ ] **4.3 — Capture frictions in spike-style report** (M)
  - `docs/reviews/2026-05-NN-skill-bundle-shakedown.md`
  - Honest record: what worked, what didn't, what to tune
  - Exit: report written

- [ ] **4.4 — Tune based on frictions** (L)
  - Likely areas: question coverage thresholds, routing rules, gap categories, template defaults
  - Each tune is a small commit, no ADR (per tightened CONST-PROC-02 — only rule-kernel changes need ADRs)
  - Exit: identified frictions addressed

- [ ] **4.5 — Ship v0.7.0** (M)
  - Tag `v0.7.0` (final, not `.devN`)
  - Update README + CLAUDE.md to reflect skill-bundle shape
  - Update install instructions: `cp -r preflight/.claude/skills/preflight <target>/.claude/skills/preflight`
  - Exit: tag pushed, README accurate

### Phase 4 exit criteria
- One real feature shipped via the new workflow
- Frictions documented and tuned
- v0.7.0 tagged

---

## Phase backlog (post-v0.7.0)

These are deferred to after the reshape ships. Not blocked on roadmap completion.

- **Multi-agent reach.** If real demand emerges (someone asks to use preflight from Cursor or Codex), revisit. Until then, Claude Code only.
- **Question-bank tuning.** As the Explore workflow runs on more features, mine real elicitation transcripts for question patterns that consistently surface useful info.
- **Cross-project consistency.** If preflight is installed in 3+ projects, audit whether the same rules + workflow produce consistent outcomes.
- **Rule kernel growth.** Add new rules only when real reviewer findings repeatedly miss a class of issues. Each new rule = ADR per tightened CONST-PROC-02.
- **Preflight awareness in PAI's LEARN phase.** Capture session signal — ideally via a subagent looking at the PRD / output of preflight-driven sessions — to feed both *add/change* and *reduce/remove* improvements back into preflight (rules, question banks, gap categories, templates). Cover quality-problem detection (e.g. reviews that consistently miss a class of issue, questions that consistently produce noise). **Open: implementation path** — does this land as a `.claude/rules/` repo-rule that PAI picks up during LEARN, or does it require LEARN/Algorithm changes upstream? Investigate before committing to a shape.
- **`specs/jtbd.md` v0.2 — strengthen user stories.** Tracked in #47. Tighten S1 situation, add Maintainer artifact-retirement story, add Supervisor L4 self-check story. Deferred from v0.1 because the workflow shapes the new stories reference don't exist yet — wait until Phase 4 validation.

---

## Process throttles (in force during the roadmap)

These rules apply during the reshape and continue after:

1. **No multi-pass adversarial review on docs-only changes.** One Codex pass is enough for governance vocabulary cleanups.
2. **One ADR proposed at a time.** Close it before opening another.
3. **No forward-declared ADRs.** ADR-011 was authored in Phase 2; no further forward references.
4. **No reconciliation ADRs with substrates.** Spec-kit gone; future substrate decisions (Claude Code skill API changes, etc.) handled by direct adaptation, not ADRs.
5. **PRINCIPLES.md instead of self-constitution.** 1-page, no version bumps, edit in place.

---

## Risk register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Explore asks too many questions | Medium | User friction | Coverage thresholds tunable; cap at N per category |
| Doc-type routing misroutes | Low | Wrong docs created | Routing rules are auditable; corrections land as commits |
| Gap-reviewer hallucinates | Low | False findings | Enumerated gap categories, no free-form |
| PAI doesn't invoke preflight | Low | Workflow never runs | SKILL.md activation triggers; verify in Phase 4 |
| Skill bundle install fragile | Low | Adoption friction | Plain `cp -r` works; no package manager |
| User reverts to manual template picking | Medium | Value-add lost | Don't ship a `/preflight:new` skill; force users through Explore |
| Reshape stalls in Phase 3 | Medium | Friction continues | Kill switch on 2026-05-10; revert to throttle-the-engine |
| ADR-011 itself becomes a multi-pass review | Low | Irony, friction | Process throttle #1 enforced; one Codex pass max |
