# spec-kit upstream tracking

**Status:** living doc — updated per upstream release, not batched.
**Baseline:** preflight was validated against spec-kit **v0.6.2** (pin: `">=0.6.2,<0.7.0"`).
**Current upstream HEAD:** v0.7.4 as of 2026-04-22.
**Scope:** classify each release since v0.6.2 against preflight's 6 outcomes.

Preflight classifies each upstream release against preflight outcomes rather than deciding "bump vs pin" — the question per release is *how do we absorb each change, and is any of it a hard blocker?* The current install pin (`>=0.6.2,<0.7.0` in `presets/preflight/preset.yml` and `extensions/preflight/extension.yml`) is behind the v0.7.x classifications below; the pin widens in B4 as adaptation PRs land.

---

## Preflight outcomes to protect

These are what adaptation must preserve. A change is only a **(iii) hard blocker** if it breaks one of these in a way preflight cannot adapt to through implementation changes alone.

| ID | Outcome | One-liner |
|----|---------|-----------|
| (a) | Author-time review enforcement | Review runs when spec/plan is written, not in CI/post-hoc |
| (b) | Ensemble dispatch from spec-kit commands | `checklist` + `bogey` reviewers fire via spec-kit hook surface |
| (c) | Rules as first-class versioned artifacts with stable IDs | `CONST-*`, `UNIV-*`, etc. survive refactors; rule files are the source of truth |
| (d) | Severity-graded findings (Critical / High / Medium / Low) | Orchestrator output preserves severity tiers |
| (e) | Cross-doc traceability | An FR referenced in an ADR must exist in `requirements.md`; reviewer enforces |
| (f) | Composition with other spec-kit extensions | `archive`, community extensions, custom user extensions all coexist |

---

## Classification legend

| Tag | Meaning | Preflight response |
|-----|---------|--------------------|
| **(i) no-impact** | Cosmetic, internal CLI concern, or unrelated subsystem | Record; no action |
| **(ii) implementation-adjust** | Preflight code/config needs a change, but outcomes (a)–(f) preserved | B4 adaptation PR; B3 requirements/arch review if observable behavior shifts |
| **(iii) hard-blocker** | An outcome is broken and not recoverable through adaptation | Escalate to design-decision doc; may force ADR-007 revisit |

Every material change since v0.6.2 gets a row. Rows marked `needs-B2-confirmation` have provisional classifications pending an install against the newer upstream.

### Affected-outcome notation

Each (ii) / (iii) row names the impacted outcome IDs in parentheses, e.g. `(ii: b, f)` = implementation-adjust affecting ensemble dispatch and composition.

---

## Stream B workstreams

This doc is part of preflight's Stream B work — spec-kit upstream tracking, adaptation, and hook-philosophy investigation. Stream A (core spike execution on issue #13, tack-room launcher, PAI brownfield) runs in parallel from the `workflow-research` worktree. Labels referenced throughout this doc:

| Label | Workstream |
|-------|-----------|
| **B1** | Living upstream tracking doc — this file |
| **B2** | Test adaptation: install preflight against current upstream; validate classifications |
| **B3** | Requirements / architecture review when a (ii) or (iii) alters preflight's observable behavior (per CONST-PROC-02) |
| **B4** | Adaptation PRs per (ii); escalation design docs per (iii); pin widening in `preset.yml` / `extension.yml` |
| **B5** | Hook philosophy investigation (subagent) — output at `./2026-04-22-speckit-hook-philosophy.md`, verdict β |

**Gate 2.5** (load-bearing): Spike 2 in the sibling worktree cannot proceed until B5's classification (done) plus integration-topology selection lands in writing. See ADR-007 "Integration topology" for the current state.

---

## Maintenance convention

- **Living doc.** No date prefix on the filename. Update in-place as releases land.
- **One release per section** ordered most-recent first after the first pass below (ordered oldest-first for the initial population's narrative flow).
- **Do not batch.** When a release ships, add its section and classifications before other Stream B work continues.
- **Reclassify as evidence arrives.** B2 adaptation testing will validate or overturn (ii)/(iii) calls. Mark reclassifications with a `reclassified: YYYY-MM-DD` note inline.
- **Anchor per outcome.** The outcomes table above is stable; downstream references should link to `#preflight-outcomes-to-protect`.

---

## Baseline constraints (independent of release)

Some preflight-relevant properties of spec-kit are baseline — not introduced or changed by any specific release since v0.6.2 — and therefore do not belong in per-release classifications. Document them here so release rows only capture actual deltas.

- **`after_*` hooks are advisory by design.** `optional: false` renders an `EXECUTE_COMMAND:` marker but does not block host-agent completion. Established by spec-kit PR #1702 (2026-03-04, pre-v0.6.0); confirmed by upstream as intentional in issues [spec-kit#2104](https://github.com/github/spec-kit/issues/2104) (OPEN feature request for `auto_run: true`) and [spec-kit#2279](https://github.com/github/spec-kit/issues/2279) (closed "not a bug"). Full analysis: `./2026-04-22-speckit-hook-philosophy.md`. This is the structural reason the current hook-extension composition cannot enforce author-time review; it is *not* a v0.7.x regression.

---

## Initial pass — v0.6.2 → v0.7.4

Evidence sources below are all independently verifiable: upstream PR numbers (full URLs where relevant), spec-kit commit SHAs in `~/.cache/spec-kit`, and tag-to-tag `git log` (`git -C ~/.cache/spec-kit log v0.6.2..v0.7.4`). B2 confirmation pending for all (ii)/(iii) classifications unless noted.

### v0.6.3 (released 2026-04-08..2026-04-09, approximate)

**Headline:** maintenance release between v0.6.2 and v0.7.0 series. No material items captured in the survey.

| Change | Classification | Notes |
|--------|---------------|-------|
| — (no material items in survey) | (i) no-impact | `needs-B2-confirmation` — verify changelog via `git -C ~/.cache/spec-kit log v0.6.2..v0.6.3` during B2 |

### v0.6.4 (released 2026-04-09..2026-04-10, approximate)

**Headline:** maintenance release; survey did not flag specific items.

| Change | Classification | Notes |
|--------|---------------|-------|
| — (no material items in survey) | (i) no-impact | `needs-B2-confirmation` — verify changelog during B2 |

### v0.7.0 (released ~2026-04-11)

**Headline:** workflow engine + catalog introduction; `--ai` → `--integration` rename. This is the largest semantic jump in the window.

| Change | Classification | Notes |
|--------|---------------|-------|
| Workflow engine + catalog (#2158) | **(ii) implementation-adjust** (a, b); revised: 2026-04-22 | v0.7.0 introduces `src/specify_cli/workflows/` with Gate/CommandStep/`RunStatus.PAUSED` primitives — a new enforcement surface spec-kit did not have before. Given the advisory-hook baseline constraint (see "Baseline constraints" above), this is the likely migration target for preflight: workflow-gate composition. Evaluation is the integration-topology question tracked in ADR-007; see `./2026-04-22-speckit-hook-philosophy.md` §Q3. |
| `--ai` → `--integration` CLI rename (#2218) | **(ii) implementation-adjust** (—) | `needs-B2-confirmation`. User-facing CLI flag. If preflight's install commands or documentation reference `--ai`, they need updating. No outcome broken — pure naming flex. |

### v0.7.1 (released between v0.7.0 and v0.7.2)

**Headline:** survey did not call out specific items. Likely maintenance / bugfix.

| Change | Classification | Notes |
|--------|---------------|-------|
| — (no material items in survey) | (i) no-impact | `needs-B2-confirmation` — verify via `git -C ~/.cache/spec-kit log v0.7.0..v0.7.1` |

### v0.7.2 (released ~2026-04-16)

**Headline:** `pack_id` → `preset_id` manifest rename (#2243).

| Change | Classification | Notes |
|--------|---------------|-------|
| `pack_id` → `preset_id` rename (#2243) | **(ii) implementation-adjust** (c, f) — provisional | **Special note:** preflight's `presets/preflight/preset.yml` uses `preset.id` (not `pack_id` or `preset_id` at top-level). Evidence from handoff suggests this rename is internal to spec-kit's preset-loader path, not the manifest-facing field we use. If true, this may be **(i) no-impact** for preflight. `needs-B2-confirmation` — install against v0.7.4 and observe preset discovery. |

### v0.7.3 (released ~2026-04-19)

**Headline:** marker-based context upsert (#2259) replacing shell-based mechanism.

| Change | Classification | Notes |
|--------|---------------|-------|
| Marker-based context upsert (#2259) | **(i) no-impact**; reclassified: 2026-04-22 (post-B5) | B5 clarified: #2259 is not a hook-enforcement alternative. It solves a different problem (idempotent agent-context file mutation during `specify` CLI install/switch/uninstall). Not event-driven; no `after_*` equivalent. Preflight's review dispatch surface is unrelated to this mechanism. See `./2026-04-22-speckit-hook-philosophy.md` §Q4. |

### v0.7.4 (released ~2026-04-22)

**Headline:** Antigravity migration; `--skills` deprecation; directory-traversal block.

| Change | Classification | Notes |
|--------|---------------|-------|
| Antigravity migration + layout changes | **(ii) implementation-adjust** (f) | `needs-B2-confirmation`. New IDE integration surface. Preflight's extension composition should survive as long as `extensions/preflight/` contract is unchanged. |
| `--skills` deprecation | **(ii) implementation-adjust** (—) | `needs-B2-confirmation`. Preflight's `--dev` install sequence does not use `--skills`; the deprecation likely does not touch our install path. Document the deprecation and remove any references if found. |
| Directory-traversal block in command write paths (#2296) | **(i) no-impact** (security hardening) | Preflight reviewer doesn't write outside preflight-owned paths; the block protects spec-kit users from malicious extensions, not a capability preflight relies on. Verify no preflight test fixture trips the block. `needs-B2-confirmation`. |

---

## Coupling table (what's linked to what)

| Entry | Coupled to | Why |
|-------|-----------|-----|
| v0.7.0 workflow engine (#2158) | ADR-007 integration-topology evaluation | v0.7.0 introduces the workflow engine as a candidate migration target for preflight (workflow-gate composition). Decision tracked in ADR-007 "Integration topology". Baseline advisory-hook constraint (separate, see above) is what motivates considering migration at all. |
| v0.7.3 marker-based upsert (#2259) | B5 (RESOLVED β) | B5 resolved: #2259 is not an enforcement alternative. Entry reclassified (i). |
| v0.7.2 `pack_id → preset_id` (#2243) | B2 adaptation test | Classification is provisional — install confirms whether our `preset.yml` format is affected |
| All other v0.7.x entries | B2 adaptation test | Every provisional classification needs install-level validation |

---

## Outstanding questions for B2 (adaptation test)

1. Does `specify preset add --dev ./presets/preflight` succeed on v0.7.4 without errors?
2. Does `specify extension add --dev ./extensions/preflight` succeed, and do both hooks (`after_specify`, `after_plan`) register?
3. Does `/speckit.preflight.review` still dispatch both reviewers from a v0.7.4 spec-kit command context?
4. Does `preset.id` in our preset manifest still bind correctly after the v0.7.2 `pack_id → preset_id` rename?
5. Does any v0.7.x release change the structure of `requires.speckit_version` expression evaluation?
6. Are any preflight reviewer rule files tripping the v0.7.4 directory-traversal block?

These are the questions B2 execution answers. Each answer either confirms a classification in the tables above or forces a reclassification (noted inline with `reclassified: YYYY-MM-DD`).

---

## Cross-references

- Hook philosophy classification (B5, verdict β): `./2026-04-22-speckit-hook-philosophy.md`
- ADR-007 — integration-topology reopened per B5: `../../specs/decisions/adrs/adr-007-feature-folder-lifecycle.md`
- Preset pin source: `../../presets/preflight/preset.yml` (`requires.speckit_version`)

---

## Change log (this doc only)

- 2026-04-22 — initial population from workflow-research handoff survey. All v0.7.x rows marked `needs-B2-confirmation`. Coupling to B5 noted on v0.7.0 and v0.7.3 entries.
- 2026-04-22 — post-B5 reclassification: v0.7.0 workflow engine upgraded to (iii) hard-blocker; v0.7.3 marker-based upsert downgraded to (i) no-impact (not a hook-enforcement alternative). Coupling table updated.
- 2026-04-22 — structural revision (Codex PR review): added "Baseline constraints" section separating release-independent properties (advisory `after_*` hooks) from per-release deltas. v0.7.0 workflow engine revised (iii) → (ii) — v0.7.0 introduces a new enforcement surface (opportunity), while the advisory-hook limitation that motivates migration is a baseline constraint (pre-v0.6.0). Source citation replaced sibling-worktree HANDOFF pointer with durable in-repo references (upstream PR numbers, spec-kit SHAs, tag-to-tag `git log`).
- 2026-04-23 — removed dead HANDOFF cross-references (`.dispatch/` is untracked, session-scoped). Added "Stream B workstreams" section defining B1–B5 labels and Stream A/B context in-file, so the doc stands on its own without relying on external dispatch artifacts.
