---
status: complete
date: 2026-04-12
owner: nic
type: analysis
supersedes_conclusions_of: 2026-04-11-workflow-integration-research.md
---

# Preflight workflow integration — second pass

## What changed from pass 1

Pass 1 ranked options against criteria but failed to answer the central question: **how does preflight actually run a workflow for a new feature, a bug fix, and a bug that turns out to be an architectural gap?** Pass 1 also dismissed OpenSpec customization without code-level research and treated community network effects as pure risk. All three gaps are addressed here.

Three findings materially shift the pass 1 conclusions:

1. **OpenSpec is the only framework in the landscape with first-class spec-drift detection** (`/opsx:verify` + `/opsx:sync`). Pass 1 missed this — everything else either ignores drift or relies on implicit role revisits. This is the single biggest differentiator in the field and the thing preflight most wants to replicate.
2. **OpenSpec is customizable for content but not for behavior.** Replacing templates and schemas is trivial and fully upstream-compatible. Replacing the 48 preflight rules, the workflow commands, or the validator requires forking ~4000 lines of TypeScript workflow prose, which upstream churn (new tool adapters landing monthly) will constantly rebase. The content-only integration is viable; the behavior-level fork is not.
3. **Network-effect rankings are different from what pass 1 assumed.** Real GitHub numbers (90-day window) put **BMAD** at #1 for adoption health (131 contributors, 377 PRs merged, explicit beta/GA discipline), **OpenSpec** at #2 (stable post-1.0 but single-maintainer risk), **GSD-2** as a dark horse (30 days old, extreme velocity, reassess in 90 days), **Archon** middling, and **Superpowers** surprisingly low (patch-only cadence, 34 PRs merged in 90 days despite 148k stars). Pass 1's dismissal of "framework dependency" as pure risk understated BMAD's real maintenance upside and overstated Superpowers'.

The bottom line recommendation does not change (evolve preflight in place), but the *shape* of that evolution is now concrete and the rejected options have better-grounded rejections.

---

## 1. How frameworks actually handle new work proposal

Research covered Devin, Archon v3, Superpowers, OpenSpec, GSD-2, and BMAD on the specific question: how does an idea become an execution-ready work package, and what happens when the build reveals a spec gap?

### Explore vs propose modes

Only two frameworks have a first-class split between "I have a vague idea" and "I know what I want":

- **OpenSpec** — `/opsx:explore` vs `/opsx:propose` are distinct commands with different artifact profiles. `explore` produces zero persistent artifacts (divergent thinking). `propose` produces a change directory with `proposal.md`, `specs/`, `design.md`, `tasks.md` in one step.
- **GSD-2** — `discuss` is a mandatory phase the state machine refuses to skip. Configurable `phases.require_slice_discussion` lets the user re-enter discuss mid-flight.

Three frameworks have a soft or implicit distinction:

- **Devin** — Interactive Planning splits one session into Initial Assessment (exploratory) and Detailed Plan (proposal). 30-second auto-proceed means planning is forced, approval is not.
- **Superpowers** — The `brainstorming` skill activates when the model judges the input vague. If the user says "implement X clearly," they skip straight to `writing-plans`. Convention-based, no enforcement.
- **BMAD** — Analyst phase (brainstorm/research/brief/PRFAQ) is optional. PM phase (PRD) is required. Dependency-enforced: epics/stories require both PRD and architecture as inputs.

One framework ignores the split entirely:

- **Archon v3** — workflow selection is the mode switch (`archon-assist` for exploration, `archon-idea-to-pr` for execution). Refinement happens *after* execution via five parallel reviewers, not before.

### Drift detection

**Only OpenSpec has first-class drift detection.** `/opsx:verify` checks three dimensions (completeness, correctness, coherence), searches the codebase for evidence, and reports critical/warning/suggestion findings. `/opsx:sync` propagates delta specs back into main specs — the drift-closing operation.

Every other framework:
- **Devin**: none. Operates on live repo, no spec layer.
- **Archon v3**: none. Execution-focused, doesn't maintain the PRDs it consumes.
- **Superpowers**: none. No persistent spec layer.
- **GSD-2**: indirect — "reassess roadmap" phase re-evaluates state after each slice.
- **BMAD**: implicit — role revisits (PM/Architect go back to their docs when dev surfaces issues).

This is where preflight and OpenSpec share the most DNA. OpenSpec's `/opsx:verify` is almost exactly what a "post-build preflight review" would do — the question is whether to consume OpenSpec for it or build the equivalent.

### Forcing function intensity

Ranked from hardest to softest:

| Rank | Framework | Mechanism |
|------|-----------|-----------|
| 1 | GSD-2 | State machine + fail-closed gates. You cannot skip discuss. |
| 2 | BMAD | Dependency enforcement: epics/stories require PRD + architecture as inputs. |
| 3 | OpenSpec | Soft: no phase gates, but `/opsx:apply` presumes a change exists. "Actions, not phases" philosophy. |
| 4 | Devin | Plan generation forced, plan approval optional (30s auto-proceed). |
| 5 | Superpowers | Convention: brainstorming skill fires based on model judgment. |
| 6 | Archon v3 | Optional. Users pick a workflow directly. |

### Work package portability

Four of six frameworks produce markdown artifacts that any executor could consume: **OpenSpec** (change directory), **Superpowers** (`design.md` + plan), **GSD-2** (`M001-CONTEXT.md` + `DECISIONS.md` + `PROJECT.md`), **BMAD** (epics/stories). **Devin** and **Archon v3** tie the plan to their own runtimes.

This matters for the pass 2 requirement that the handoff format be loosely coupled enough to switch execution engines later. Preflight's target handoff format should be at least as portable as these four.

---

## 2. OpenSpec customization — the honest assessment

Code-level research on the OpenSpec repo (TypeScript, ~4000 lines of workflow templates, Zod-based validation, npm CLI) produced a sharper picture than pass 1 assumed.

### What OpenSpec lets you customize without forking

Via `openspec/config.yaml` + project-local schemas under `openspec/schemas/<name>/`:

- **Artifact set** — full replacement. A custom schema YAML defines `artifacts[]` with arbitrary IDs, templates, and a dependency DAG. Preflight's 7 doc types (requirements, ADR, RFC, architecture, interface contract, test strategy, constitution) map cleanly to this.
- **Templates** — drop-in markdown replacements for the spec-driven defaults.
- **Per-artifact free-text guidance** — `rules:` field in config.yaml appended to AI prompts. Soft, not enforceable.
- **Global `context:` string** — ≤50KB of project-wide context injected into every artifact instruction.

Schema resolution precedence is `project > user-global > package` (documented in `src/core/artifact-graph/resolver.ts:63-91`), so projects can override without touching the installed package.

### What requires forking

- **The `/opsx:*` workflow commands.** Names, count, and prose of `explore`/`propose`/`apply`/`archive` are hard-coded in `src/core/templates/workflows/*.ts` (12 files, ~3700 lines of TypeScript-embedded markdown). You cannot rename them to `/preflight:explore`. You cannot add `/preflight:scaffold`. The profile system lets you *subset* the 11 built-in workflows but not add new ones.
- **The structural validator.** `src/core/validation/validator.ts` (459 lines) hard-codes rules like "every Requirement contains SHALL or MUST" and "scenarios use `####`". No DSL, no plugin, no config hook. Preflight's 48 rules have no home here.
- **Tool adapters.** 26 adapters registered in a static block (`src/core/command-generation/registry.ts:39-105`). No runtime registration.

### The incompatibility that kills "OpenSpec as foundation"

OpenSpec's validator hard-codes EARS-style enforcement. If a preflight doc type that isn't a spec (e.g., an ADR) gets run through `openspec validate`, it fails because it lacks SHALL/MUST keywords. The only way around this is to never run `openspec validate` on non-spec artifacts — a footgun, and it loses preflight's strongest differentiator: the 48-rule ensemble review.

### Effort estimates

- **Config-only integration** (custom schema + templates + rules as AI guidance): weekend's work. Fully upstream-compatible. Near-zero maintenance. **Loses rule-based review.**
- **Fork-and-rebrand integration** (own commands, own validator, own init): substantial. Inherits ~4000 lines of workflow templates to keep synced. Upstream churn is concentrated in exactly the files you'd be modifying (v1.2→v1.3 was 90% adapter additions). Every release risks merge conflicts.

### What this means for the options list

Pass 1's Option C ("OpenSpec methodology + preflight review") was vague. It now splits into two distinct concrete options:

- **Option C1 — OpenSpec content adoption.** Ship a `openspec/schemas/preflight/` directory containing preflight's 7 doc templates plus a config.yaml with rules flattened into the free-text `rules:` field. OpenSpec becomes the authoring tool for the flow preflight previously owned via `scaffold` + `new`. Preflight's `/preflight review` remains a standalone validator outside OpenSpec because the 48 rules cannot live inside it. The user gets `/opsx:explore` and `/opsx:propose` for authoring and `/preflight review` for validation. **Two tools, two mental models, upstream-compatible.**
- **Option C2 — OpenSpec hard fork.** Take the methodology *and* rebrand it to `/preflight:*`. Requires forking ~4000 lines of TypeScript. Upstream churn lives in those files. **High maintenance tax, small community gain.**

C1 is viable if the preflight review tool stays separate. C2 is not viable at the effort/benefit tradeoff shown by the code-level research.

---

## 3. Community network effects — the honest numbers

90-day window (2026-01-11 to 2026-04-11), real GitHub API numbers:

| Framework | Stars | Contributors | Commits (90d) | PRs merged (90d) | Issues (opened/closed) | Releases (90d) | Bus factor top-1 | Direction |
|-----------|-------|-------------|---------------|-----------------|----------------------|----------------|------------------|-----------|
| OpenSpec | 39k | 53 | 128 | 128 | 208 / 118 | 12 | TabishB 66% | Stable post-1.0 |
| Superpowers | 148k | 31 | 190 | 34 | 401 / 311 | 4 (patch only) | obra 66% | Flattening |
| GSD-2 | 5.5k | 77 | 3,249 | 1,625 | 1,694 / 1,480 | ~40 | glittercowboy 40% | Explosive (30 days old) |
| BMAD | 44k | 131 | 652 | 377 | 374 / 351 | 17 | alexeyv 52% | Major v6 overhaul |
| Archon | 17k | 13 | 974 | 32 | 88 / 140 | 8 | Wirasm 62% | Pre-1.0 scope drift |

### Key observations

1. **Superpowers is frozen, not thriving.** 148k stars but only 34 PRs merged in 90 days and patch-only releases. The v5.0.6 change deleted the subagent review loop in favor of inline self-review — an honest engineering regression but a sign the core is not expanding. Pass 1 overvalued Superpowers by assuming star count tracks development health. It doesn't here.
2. **BMAD is the healthiest spec-driven framework to adopt.** 131 total contributors (largest pool), 377 PRs merged (3rd highest throughput), explicit beta/GA release discipline with v6.0.0-Beta.2 through Beta.8 before GA. Breaking changes are aggressive (v6 removed features every release) but the process is legible. alexeyv is 52% of commits but bmadcode (original author) is now #2 — a healthy succession signal.
3. **OpenSpec is stable but single-maintainer.** Cleanest release hygiene of the five, stable post-1.0 API, growing adapter ecosystem. TabishB is 66% of commits; if they disengage, the project stalls. This is the material bus-factor risk pass 1 hand-waved.
4. **GSD-2 is a dark horse to watch.** Extreme velocity (3,249 commits in 90 days, more than the other four combined), architecturally ambitious (ADR-driven capability-aware model routing, MCP elicitation), healthiest contributor distribution (top author only 40%). But the repo is 30 days old. Reassess in July 2026.
5. **Only Archon has positive issue hygiene** (140 closed vs 88 opened). Every other framework is accumulating open issues faster than closing them.

### What this changes

Pass 1 scored "framework dependency" as pure risk (1–5 where 5 = no dependency). That framing hid the upside. Revised framing:

| Framework | Adoption health | Material risk | Honest verdict |
|-----------|----------------|--------------|----------------|
| BMAD | Strong | Breaking changes every minor release | Worth depending on if you can track upstream weekly |
| OpenSpec | Medium | Single maintainer (TabishB) | Worth depending on with eyes open; validator/verbs are a hard lock-in |
| GSD-2 | Extreme-but-young | 30 days old, daily breaking releases | Reassess in 90 days, not now |
| Archon | Medium (April burst only) | Pre-1.0 scope drift (spec → harness builder) | Not ready |
| Superpowers | Weak (patch-only 90d) | obra bottleneck, deliberately simplifying | Use as reference, not dependency |

**This does not change the recommendation**, but it explains *why*: there is no community framework healthy enough to carry preflight's value. BMAD is healthiest but its value prop (12+ agent personas, aggressive agile theater) conflicts directly with PAI Algorithm's execution model. OpenSpec has the closest alignment on spec-driven workflow but bus-factor risk plus the 48-rule incompatibility rules it out as foundation. The rest are either too young, too scope-drifty, or too frozen.

---

## 4. The concrete E-lite design

Pass 1's "E-lite" was under-specified. Here is the target architecture, grounded in the three walkthroughs below.

### Minimal additions to existing preflight

The existing `scaffold`/`new`/`review` skills already cover document creation and ensemble validation. The gaps are the **entry point** (how an idea becomes a governed doc set) and the **exit artifact** (what gets handed to execution). Adding exactly two new skills and one new output artifact fills both:

- **`skills/explore/SKILL.md`** — elicitation loop. Input: fuzzy idea. Output: named plan ("these doc types need to be created/updated"). Hands off to `propose`. No artifacts created until user approves the plan. Escalates any requirement-touching change to governance mode (forces the ADR question).
- **`skills/propose/SKILL.md`** — orchestrates the existing `new` skill once per doc type in the plan, runs the existing `review` skill across the changed docs, and emits a `work-package.yaml` **only if review is clean at High severity or below**. This is the forcing function.
- **`content/templates/work-package-template.yaml`** — the handoff schema (below).
- **`content/scaffolds/post-implementation-hook.sh`** — ~30-line bash script. Diffs FR IDs in the PR's commit trailers against FR IDs listed in the work package. Surfaces any mismatch as a PR review comment. Non-blocking — the human decides whether drift represents a gap or a clean implementation.
- **Two rule additions** to `content/rules-source/`: "propose refuses to emit with Critical findings" and "explore escalates to governance path on any requirement ID touch."

That is the entire delta. No new framework, no fork, no external dependency.

### The forcing function — `propose` refuses to emit

The pass 1 Council debate correctly identified that "ship E-lite now, skip the bridge" is the right direction but did not specify *how* the flow gets forced. Pass 2's answer: the work package is the gate. `propose` will not emit a `work-package.yaml` if `review` reports any Critical finding or if the traceability check (every listed FR has a backing design section) fails. The executor will not run without a work package. This is mechanical, hook-free, and the pressure is exactly where it needs to be — at the handoff, not upstream during elicitation where it would create friction on simple defects.

This is a preflight-native equivalent of OpenSpec's soft-gate-via-command-structure, but stronger: OpenSpec will let `/opsx:apply` run on a half-specified change; `propose` will refuse to write a work package.

### Granularity rules for the work package

The handoff contract (schema below) stays fixed regardless of change size. The three walkthroughs test this:

- A 266-line feature design doc produces a work package with 5 FRs, 1 ADR, 1 RFC, 1 constitution amendment, and an interface contract reference. Same schema.
- A one-line defect fix produces a work package with 1 FR, 1 test file, no ADR, no architectural references. Same schema.
- An 8-file architectural amendment produces a work package with 3 new FRs, a `blocks` field listing the ADR/RFC that must land in the same PR, and a constitution version bump. Same schema.

Granularity is determined by what the user and the elicitation loop produced, not by a fixed work-unit size. This is the deliberate opposite of GSD-2's slice model (fixed-size tasks) and Superpowers' 2–5 minute steps (tiny tasks). Preflight's unit is "one atomic user intent with all governance implications resolved."

### The handoff contract — `work-package.yaml`

```yaml
schema_version: 1
work_package_id: WP-2026-04-11-001
created_at: 2026-04-11T18:22:00Z
created_by: preflight/propose@0.7.0
status: ready  # ready | in_progress | implemented | drift_detected | closed

intent:
  summary: "Add IssueResolver: four-phase automated issue-to-PR workflow in dispatch"
  kind: feature  # feature | defect | refactor | governance
  originating_input: "/preflight explore 'Add an IssueResolver...'"

spec_refs:
  constitution:
    version: "1.5.0"
    clauses: [CONST-WRITE-01, CONST-WRITE-02, CONST-GATE-01]
  requirements:
    functional: [FR-040, FR-041, FR-042, FR-043, FR-044]
    non_functional: [NFR-012]
  architecture:
    sections: ["§4 Resolver phases", "§5 State file"]
  decisions:
    adrs: [ADR-006]
    rfcs: [RFC-004]
  interfaces:
    - path: specs/interfaces/resolver-state.md
      kind: json-schema

scope:
  expected_surface:
    - dispatch/skills/issue-triage/
    - dispatch/lib/state.sh
  out_of_scope:
    - "Writing to the default branch directly (forbidden by CONST-WRITE-01)"

acceptance:
  - "Every FR listed in spec_refs.requirements.functional has at least one test"
  - "State file conforms to specs/interfaces/resolver-state.md schema"
  - "Post-implementation hook reports no FR drift"

blocks:
  - kind: adr
    id: ADR-006
    path: specs/decisions/adrs/adr-006-dispatch-scope-expansion.md
  - kind: constitution_bump
    from: "1.4.0"
    to: "1.5.0"

review:
  last_run: 2026-04-11T18:20:00Z
  tool: preflight/review@0.6.0
  result: clean
  max_severity: low

executor_hints:
  test_dirs: ["tests/integration"]
  language_primary: bash
```

**Explicitly excluded:** code prescriptions (no function names, no module layouts, no prompt text), time estimates, step-by-step plans, review prose. The executor figures out *how*; the package only says *what must be true*.

**Loose coupling.** Any executor — PAI Algorithm, Codex, a human, a future tool — needs four capabilities to consume this:

1. Read YAML. Parse `spec_refs` and follow the paths.
2. Honor `blocks`. Whatever ships must include the listed ADRs and version bumps in the same atomic change.
3. Run acceptance checks. Human reads them; machine turns them into a test plan.
4. Emit an FR trailer on commits. The post-implementation hook reads `FR-NNN` tokens from commit messages. This is the only coupling between executor and preflight — one convention, trivially portable.

`executor_hints` is deliberately advisory. The three walkthroughs below use the same schema for a 266-line design doc, a one-line alias fix, and an 8-file architectural amendment — which is the portability test.

---

## 5. Three workflow walkthroughs with real examples

### Walkthrough 1 — Feature add (dispatch PR #10 IssueResolver)

**Real artifact**: https://github.com/nichenke/dispatch/pull/10 — "docs: IssueResolver design document" (+266/-0, one file). The PR body describes a four-phase automated issue-to-PR workflow expanding dispatch's scope, and flags that CONST-WRITE-01/02, CONST-GATE-01, and ADR-006 will be needed.

**Today**, that PR is a freeform design doc in `docs/`. **Target state**: same idea enters through preflight and exits as governed specs plus a work package.

**1. Entry.** `/preflight explore "Add an IssueResolver to dispatch — automated issue-to-PR agentic workflow"`. The idea is not spec-ready (no FR IDs, touches multiple layers, scope unclear), so `explore` is correct.

**2. Elicitation.** The skill reads `specs/constitution.md`, `specs/requirements.md`, and dispatch's meta and asks six questions:
- Is this an extension of dispatch's current scope or a new bounded context?
- What triggers a resolver run — manual invocation, label on issue, schedule?
- Does the resolver write to the repo directly, or propose via PR only?
- What's the phase handoff — a state file, a message bus, sequential skills?
- Does phase 2 (Harness Fix) modify user environment, and under what consent model?
- What failure modes must be observable to the user?

After the answers, `explore` names the doc set needed: scope amendment in `constitution.md`, five new FRs in `requirements.md`, one ADR, one RFC, one interface contract. It asks: "Proceed to `/preflight propose`?"

**3. Document outputs.** `propose` invokes `new` once per doc type:
- `specs/decisions/adrs/adr-006-dispatch-scope-expansion.md` — context, decision, consequences including obligation to add CONST-WRITE-01/02.
- `specs/decisions/rfcs/rfc-004-issue-resolver-phases.md` — four-phase design. This is where PR #10's 266 lines live, restructured into the RFC template.
- `specs/constitution.md` amendment — CONST-WRITE-01 (resolver proposes via PR only), CONST-WRITE-02 (resolver writes only inside `.dispatch/resolver/`), CONST-GATE-01 (Harness Fix requires approval token). Version bumped per CONST-PROC-01.
- `specs/requirements.md` adds FR-040..FR-044 and NFR-012.
- `specs/interfaces/resolver-state.md` — JSON schema for `.dispatch/resolver/state.json`.

**4. Review gates.** `propose` runs ensemble review:
- Checklist reviewer catches: FR-042 uses "should" instead of "shall" — flagged High.
- Bogey reviewer catches: "RFC-004 phase 2 writes to Claude settings but CONST-GATE-01 only names an approval token — no schema for what the token authorizes. A malicious resolver run with a valid token could write anywhere." Flagged Critical.

User fixes both, re-runs, comes back clean.

**5. Work package.** `propose` emits `.preflight/work-packages/2026-04-11-issue-resolver.yaml` and prints the path. Executor consumes it.

**6. Post-build.** When the implementation PR opens, the post-implementation hook diffs FR IDs in the PR's commits against FR IDs in the work package. Any touched FR not listed → drift flagged as PR comment. Any listed FR untouched → incomplete execution flagged.

### Walkthrough 2 — Simple bug fix (pai-source `355825d`)

**Real commit**: `355825d` — one-line fix in `bootstrap.sh`: unquoted `$TARGET` in the generated `pai` alias breaks when `--target` contains spaces. Pure defect against existing behavior.

**1. Entry.** `/preflight propose "Fix unquoted target path in generated pai alias — breaks on paths with spaces. Traces to FR-009."`. Caller has done traceability, so `propose` is correct — `explore` would be overkill.

**2. Elicitation.** Minimal. Three questions: add failure-mode clarification? regression test location? other FRs touched?

**3. Document outputs.** Only `requirements.md` — adds a failure-mode bullet under FR-009 ("...including target paths containing whitespace"). Per `.claude/rules/preflight.md`, clarifications do not require an ADR.

**4. Review gates.** Fast path, under one minute. Checklist confirms the clarification is additive and scoped. Bogey passes.

**5. Work package.** Minimal — one FR ID, one test file to add, one source file as expected surface area. No architecture references.

**6. Post-build.** Hook confirms PR touches `bootstrap.sh` and adds the test. FR-009 in both work package and PR commit trailer. Clean.

**The point**: the forcing function does not create friction on pure defect fixes. `propose` short-circuits elicitation when the caller provides FR traceability upfront. The review ensemble runs a reduced rule set on clarification-only diffs.

### Walkthrough 3 — Architectural bug fix (pai-source `e7bfe86`)

**Real commit**: `e7bfe86` — started as a Codex finding ("jq autodiscovery aborts under `set -e` on malformed settings.json") but investigation revealed CONST-SRC-02 (single-source-of-truth-for-paths) didn't account for the CC_DIR/PAI_DIR split-deploy mode. Ships with two code patches, RFC-003, ADR-010, constitution v1.4.0, and three new FRs. Eight files, 247 additions. **This is the escalation path that pays the forcing function's cost.**

**1. Entry.** `/preflight explore "jq autodiscovery aborts under set -e in validate-install.sh — Codex finding"`. User *thinks* it's a simple defect but picks `explore` — good instinct.

**2. Elicitation escalation.** The skill reads `specs/constitution.md`, finds CONST-SRC-02 (getPaiDir-only path resolution), reads `specs/requirements.md`, finds FR-003 (bootstrap resolves paths via getPaiDir). It greps the failing file and sees the jq call is *discovering* a path, which is not what FR-003 describes.

First question: **"validate-install.sh is discovering a path from settings.json, but FR-003 says paths resolve via getPaiDir. Is this a code bug (violation of FR-003) or a requirements gap (FR-003 doesn't cover split deploy)?"**

User answers: "Split deploy needs to read CC_DIR from settings because there's no other source — it's a gap."

This single answer escalates the work from "bug fix" to governance territory. `.claude/rules/preflight.md` says: no behavioral requirement change without an ADR. Elicitation now forces the questions:
- What invariant does CONST-SRC-02 actually protect, and does split deploy preserve it or break it?
- In split mode, what's the authoritative source for CC_DIR — settings.json, env var, or computed?
- What failure modes does the new path have that the old one didn't?
- Should CONST-SRC-02 be replaced, amended with exception, or kept with split mode out-of-scope?

**3. Document outputs.**
- `specs/decisions/rfcs/rfc-003-cc-dir-split.md` — path resolution design.
- `specs/decisions/adrs/adr-010-split-deploy-cc-dir-exception.md` — decides: amend CONST-SRC-02 with a scoped exception.
- `specs/constitution.md` v1.4.0 — amended CONST-SRC-02.
- `specs/requirements.md` — amends FR-003, adds FR-020 (split-mode CC_DIR resolution), FR-021 (malformation handling), FR-022 (env var precedence).

The code-level findings (the `|| true` guard, the REAL_HOME probe, the `--fast` rename) are now *traceable* to FR-021, FR-020, and UX clarification respectively.

**4. Review gates.** This is where the ensemble earns its keep:
- Checklist: constitution version bumped ✓, EARS form ✓, ADR status ✓, RFC cites ADR ✓.
- Bogey (High): "ADR-010 says 'exception for split mode' but does not define the boundary. If a third mode is added later, does the exception extend automatically?" — user tightens ADR-010.
- Traceability (Medium): "FR-020 describes resolution order but does not cite which phase of bootstrap.sh applies it." — user adds a pointer to `architecture.md §3.2`.

**Without `explore`'s escalation**, the first four code patches would have shipped as a "bug fix" commit, leaving constitution and requirements silently inconsistent with reality. This is the failure mode the forcing function exists to prevent.

**5. Work package.** Executor receives a package with multiple FRs, multiple files, and a `blocks` field listing the ADR/RFC that must land in the same PR. A different executor (Codex tomorrow) would consume the same package and know the same facts.

**6. Post-build.** Hook diffs FR IDs in the PR against the work package. If the executor touched FR-003 in `validate-install.sh` but the PR trailer only mentions FR-020, the hook surfaces: "FR-003 was amended in this work package but the implementing commit does not reference it — confirm the amendment shipped." Drift closed before merge.

---

## 6. Revised options list

Pass 1 had six options. Pass 2's code-level research on OpenSpec customization splits Option C into two, and the walkthroughs make Option E specific enough to separate from Option A.

| Option | Pass 1 | Pass 2 revision |
|--------|--------|-----------------|
| **A: Preflight standalone extension** | Score 27 — workflow bolted on doc tool | **Now equivalent to E-lite.** The pass 2 walkthroughs show `/preflight explore` + `/preflight propose` are not "workflow in a doc tool" — they are elicitation + governance orchestration, which is preflight's natural domain. |
| **B: Superpowers integration** | Score 21 — dependency risk | **Downgraded.** Network effects show Superpowers is patch-only (34 PRs in 90d), frozen in direction, one-maintainer bottleneck. |
| **C1: OpenSpec content adoption** | (was combined with C2) | **New split option.** Config-based. OpenSpec owns authoring via `/opsx:*`, preflight's `/preflight review` stays standalone. Upstream-compatible. Weekend of work. Loses preflight branding. |
| **C2: OpenSpec hard fork** | (was combined with C1) | **New split option.** Rebrand commands to `/preflight:*`. Substantial fork of ~4000 lines of TS templates. Upstream churn constant. Not viable at the tradeoff. |
| **D: GSD-2 integration** | Score 21 — competing execution model | **Flagged for future reassessment.** Network effects show GSD-2 is the most architecturally ambitious framework but is 30 days old and releasing 40 versions per quarter. Revisit July 2026. |
| **E: Tack Room harness content** | Score 34 — right architecture, timing gap | **Refined as E-lite (concrete design above).** The pass 2 walkthroughs and handoff contract provide the design pass 1 was missing. This is not vaporware-dependent — it ships standalone and becomes Tack Room harness content automatically when Tack Room exists. |
| **F: BMAD integration** | Score 16 — too heavy, Algorithm conflict | **Unchanged.** Network effects show BMAD is the healthiest community framework to adopt, but its value prop (12+ agent personas, aggressive agile theater) conflicts directly with PAI Algorithm. |

### Recommendation

**Ship E-lite, as concretely specified in §4 above.** This is not a framework adoption, a fork, or a bridge — it is ~5 files of additions to preflight and one ~30-line bash hook.

If the community picture changes in 6 months (GSD-2 stabilizes, BMAD resolves its agile-theater conflict with a simpler workflow, OpenSpec adds plugin-registered commands), re-evaluate. But nothing in today's landscape is healthy enough or aligned enough to carry preflight's value.

### Why Option C1 is not the recommendation despite being viable

C1 (OpenSpec content adoption, preflight review standalone) is genuinely upstream-compatible and a weekend's work. It would give preflight users `/opsx:explore` and `/opsx:propose` immediately, with preflight review running as a separate validator. The reasons it is not the recommendation:

1. **The 48 rules are preflight's main differentiator** and cannot live inside OpenSpec. Users would run two tools. The ensemble review architecture that caught the Critical finding in walkthrough 1 would still be preflight-side, so the authoring UX split across tools adds confusion without reducing work.
2. **OpenSpec's EARS validator is a footgun** for non-spec doc types. Running `openspec validate` on an ADR fails because ADRs don't contain SHALL/MUST. Users will try it anyway.
3. **OpenSpec's bus factor is real.** TabishB is 66% of commits. A weekend's integration work that depends on a single-maintainer project for authoring UX is a gamble that is not justified when the alternative (E-lite) is ~5 files that never depend on an external release.
4. **The forcing function is weaker.** OpenSpec's `/opsx:apply` will run on a half-specified change. E-lite's `propose` refuses to emit a work package if review is not clean at High severity or below. The mechanical gate is stronger on the preflight-native path.
5. **Brand/verbs mismatch.** Users already know `/preflight *`. Switching half the flow to `/opsx:*` creates two mental models for no reason.

C1 is the fallback if E-lite's timeline slips past a quarter and the explore/propose flow is still a daily pain. Otherwise it is strictly worse than shipping the 5 files for E-lite.

---

## 7. Council debate — full transcript

Pass 1 summarized the Council verdict without publishing the debate. Here is the three-perspective debate verbatim.

### Opening positions

**The Pragmatist:**
> Tack Room is vaporware until it ships. The user has three concrete gaps right now — task-plan docs, spec-drift detection, and spec-aware context loading — and two of those are squarely within preflight's existing capability. We should add the task-plan doc type to preflight this week, wire a lightweight "did you update architecture.md?" reminder into the review skill, and move on. Option C (OpenSpec methodology) is a checklist we can embed in the `new` skill's elicitation flow without importing a framework. No bridge needed if the destination doesn't exist yet.

**The Architect:**
> The reason E scored highest is that it respects transform boundaries. Preflight owns T1 (clarification) and the doc-verification half of T4. Tack Room will own T3, T5, and runtime T4. If we let preflight creep into runtime verification or task orchestration, we create a subsystem that Tack Room has to either absorb or compete with. The task-plan doc type is fine — it's a template, it lives in `content/templates/`, it's pure T1. But "did you update architecture.md?" is T5 integration logic. Put it in the wrong place now and you'll be extracting it later.

**The User Advocate:**
> Nic's actual failure mode isn't "no task-plan template." It's that after building something, the specs and architecture doc drift from reality and nobody notices until the next session. A template doesn't fix that. A post-build review prompt does. I don't care whether it lives in preflight or Tack Room — I care that it fires at the right moment. Right now, the only tool that fires at "I'm done building" is the Algorithm's REFLECT step. Can we hook into that without building Tack Room?

### Cross-responses

**Pragmatist → Architect:** You're protecting boundaries for a system that doesn't exist. Constitution rule CONST-PROC-01 requires a version bump for behavioral changes, not an architectural purity test. We add the template, add a review rule for spec-drift, ship it. If Tack Room needs to move it later, that's a 20-minute migration.

**Pragmatist → User Advocate:** Hooking into Algorithm REFLECT is out of scope for preflight — that's PAI infrastructure. But we can add a `post-build` review profile to the review skill that checks "do your specs still match what you built?" That's a doc review, not runtime orchestration.

**Architect → Pragmatist:** The 20-minute migration argument is how every permanent bridge gets built. But I concede: a template and a review rule are both firmly in preflight's domain. My concern is scope creep beyond those two primitives. If we keep it to content and rules, I'm aligned.

**Architect → User Advocate:** The right hook point is the review skill invoked manually or by convention after building. Preflight already has `/preflight review`. Adding a "post-build" rule set that checks architecture.md freshness, requirement coverage, and decision traceability is architecturally clean. It's T4 doc-verification, which preflight owns.

**User Advocate → Pragmatist:** A post-build review profile works if Nic actually runs it. The real fix is making it frictionless — the Algorithm's REFLECT step should suggest `/preflight review --profile post-build`. That's a one-line addition to the Algorithm, not a preflight change.

**User Advocate → Architect:** Agreed on the boundary. But I want to name the actual deliverable: a set of review rules that catch spec drift. Not a methodology document. Not a process diagram. Rules that the review skill already knows how to enforce.

### Council verdict

**Ship E-lite now. Skip the bridge.**

- Add task-plan template to preflight (pure T1, no architectural risk)
- Add post-build review rules for spec-drift detection (pure T4 doc-verification)
- Do NOT import OpenSpec as methodology layer — absorb useful ideas directly into skill behavior
- Tack Room remains north star; preflight stays a full plugin until Tack Room exists

**Dissents:**
- Architect: keep post-build rules focused on document content only (no runtime artifacts)
- User Advocate: without an Algorithm REFLECT hint, user still won't remember to run review

---

## 8. Summary — answering the pass 2 questions

| Pass 2 question | Answer |
|-----------------|--------|
| How do we workflow building something new? | Walkthrough 1 (dispatch PR #10). `/preflight explore` → elicitation → `/preflight propose` → review ensemble → `work-package.yaml` → executor. |
| How do we workflow a simple bug fix? | Walkthrough 2 (pai-source 355825d). `/preflight propose` with FR traceability upfront → minimal elicitation → fast-path review → work package → executor. |
| How do we workflow a bug that's a spec gap? | Walkthrough 3 (pai-source e7bfe86). `/preflight explore` → elicitation detects requirement-ID touch → escalates to governance path → ADR/RFC/constitution amendment → review ensemble → work package with `blocks` field → executor. |
| How do we hand off to PAI/other execution engine? | `work-package.yaml` schema in §4. Spec references, acceptance criteria, blocks field, executor hints. No code prescriptions. Executor-agnostic. |
| How loosely coupled can we make it? | Four capabilities required: read YAML, honor blocks, run acceptance checks, emit FR trailer on commits. PAI today, Codex tomorrow, any future tool. |
| Is OpenSpec attractive because it forces an initial flow? | Partly. OpenSpec's forcing function is soft (command structure implies order but doesn't gate). Preflight can do stronger: `propose` refuses to emit the work package if review is not clean. Mechanical, not aspirational. |
| Can we customize OpenSpec? | Content: yes, trivially. Behavior: no — ~4000 lines of TS fork required and upstream churn is concentrated in those files. C1 viable as authoring-only integration with preflight review standalone. C2 not viable. |
| Community network effects — how real? | BMAD is healthiest (131 contributors, 377 PRs merged 90d), OpenSpec stable but single-maintainer, GSD-2 explosive but 30 days old, Superpowers frozen (34 PRs 90d despite 148k stars), Archon pre-1.0 scope drift. None are healthy+aligned enough to carry preflight's value. |

## Appendix — what to build first

Concrete first sprint after this analysis lands:

1. Write `skills/explore/SKILL.md` and `skills/propose/SKILL.md` using the walkthrough flows as the authoring guide.
2. Write `content/templates/work-package-template.yaml` matching the schema in §4.
3. Write `content/scaffolds/post-implementation-hook.sh` — the ~30-line FR-drift detector.
4. Add two rules to `content/rules-source/`: "propose refuses to emit with Critical findings" and "explore escalates on requirement ID touch."
5. Validate on a real change: implement walkthrough 1 or 2 end-to-end as a spike (addresses pass 1's RedTeam attack #5 — "no spike, no prototype, no user testing").

No version bump on preflight's governing constitution. No behavioral-rule changes to existing skills. This is pure addition, fully reversible, fully compatible with any future Tack Room design.
