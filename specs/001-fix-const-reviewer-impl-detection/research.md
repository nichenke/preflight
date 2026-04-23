# Phase 0 Research: CONST-R04 property-test implementation unknowns

**Feature**: `001-fix-const-reviewer-impl-detection`
**Date**: 2026-04-22

Spec `spec.md` Assumption 2 defers several mechanics to `/speckit.plan`. This document resolves them so Phase 1 can produce concrete fixtures.

---

## 1. Rule-file structure — inline row or subsection?

**Decision**: Expand CONST-R04 into a subsection directly under the rule table, not a single-row edit.

**Rationale**: The current rule table is a flat `| ID | Rule | Severity |` grid. The new shape (property test + scaffolding list + exemption clause + exemplar pairs) will not fit in a single cell without becoming unreadable. Other rule families in the preflight rules directory (e.g., `adr-rules.md`, `requirements-rules.md`) already use a subsection pattern for rules that need elaboration — follow that precedent.

The rule table keeps a one-line entry for CONST-R04 that cites the subsection:

```markdown
| CONST-R04 | Principles SHALL pass the implementation-detail property test (see below) | Warning |
```

And below the table:

```markdown
### CONST-R04: Implementation-detail property test

**Property test** — … (normative clause from FR-001)
**Scaffolding** — … (non-normative shape list per FR-002)
**Exemption** — … (standards clause per FR-003)
**Examples** — … (paired good/bad exemplars)
```

**Alternatives considered**:
- *Single table row with bullets inside the cell*: rejected — unreadable in rendered markdown, fragile under table-cell parsers.
- *Separate rules file* (`constitution-rules-r04.md`): rejected — fragmenting rule files violates the existing one-file-per-doc-type convention and complicates reviewer rule loading.

---

## 2. Exemplar count per shape

**Decision**: One (bad, good) pair per shape for the eight shapes listed in FR-002. Total: 8 pairs = 16 example sentences.

**Rationale**: Peer-framework research (cached under `cache/repos/`) showed spec-kit uses 4 good/bad pairs per property in its specify template, BMAD uses category-based example lists of 3-5 items, and Superpowers uses Red Flags lists of 4-8 items. Preflight's eight scaffolding shapes already segment the calibration surface, so a single before/after pair per shape produces ~16 calibration sentences total — comparable to peer frameworks without bloating the rule file. Each pair demonstrates the shape concretely: one principle that embeds the shape (bad) and a minimal rewrite that expresses the same intent without the shape (good). SC-001 and SC-002 validated empirically that this count was sufficient on first implementation run (5/5 expected flags on SC-001, 0/0 expected flags on SC-002).

Exemplar size: ≤ 1 sentence per side. The rule file stays under ~100 lines.

**Alternatives considered**:
- *Two pairs per shape (16 pairs / 32 sentences)*: initially preferred for "edge of shape" vs. "center of shape" calibration coverage, revised after SC-001/SC-002 both passed on first-run implementation with one pair per shape. Keep as the escalation path if future rule-design research surfaces a real edge-case calibration gap.
- *Three or more pairs per shape (24+ pairs total)*: diminishing returns; rule file bloats past readability threshold.
- *Exemplars in a separate scaffold file*: rejected — reviewer loading is simpler when the rule and its calibration live in the same file.

---

## 3. Test corpora location and shape

**Decision**: Fixture markdown files under `specs/001-fix-const-reviewer-impl-detection/fixtures/`.

- `fixtures/benchmark-issue-13.md` — SC-001 corpus. Five principles, each embedding exactly one of the issue #13 examples. Each principle is a realistic constitution principle (not a contrived synthetic), so the reviewer exercise is faithful to production.
- `fixtures/benchmark-scaffolding-shapes.md` — SC-003 corpus. Three principles covering the scaffolding shapes not exercised by issue #13: tool/vendor name, inline code token (non-call expression), and version-pinned standard (the FR-003 exemption boundary's must-flag side). Added during PR-#35 review after reviewers noted a regression-detection gap: a reviewer narrowed to the 5 issue-#13 shapes would pass SC-001/SC-002 while silently failing the rule's 8-shape claim.
- `fixtures/benchmark-multi-phrase.md` — SC-004 corpus. Two principles, each embedding two distinct implementation-detail shapes, expected to produce 4 CONST-R04 findings total (one per offending phrase). Added during PR-#35 review to validate the rule's phrase-level flagging claim, which was otherwise untested — a reviewer that truncated to one finding per principle would pass SC-001..SC-003 while silently violating this claim.
- `fixtures/control-agnostic.md` — SC-002 corpus. Eight implementation-agnostic principles drawn from EARS-style outcome statements.

**Rationale**: Feature-local fixtures ship with the spec and archive when the feature ratifies — they are the artifact that pins the acceptance signal. Global `docs/fixtures/` would outlive any single feature and accumulate cruft. ADR-007's feature-folder pattern explicitly supports fixtures as feature-owned content.

Format: each fixture is a markdown file with `## Principle N` headings and one principle per heading, mimicking the real constitution's structure. The reviewer runs normally against this file (it looks like any other constitution).

**Alternatives considered**:
- *Inline in the spec*: rejected — pollutes the spec with test data; fixtures should be reviewable as input documents in their own right.
- *Global `docs/fixtures/`*: rejected — outlives the feature; accumulates; no clear owner.
- *`.specify/memory/test-corpus.md`*: rejected — `.specify/memory/` is for durable project state (constitution, etc.), not feature-scoped fixtures.

---

## 4. Install-copy propagation

**Decision**: Manual re-run of `specify extension add --dev extensions/preflight` documented in the quickstart. No automation in this feature.

**Rationale**: Source of truth is `extensions/preflight/`. The `.specify/extensions/preflight/` copy is a dev install populated by `specify extension add --dev`. This worktree already has a `.specify/` install; the rule edit needs to propagate there before any reviewer run sees it. A one-line re-install step in the quickstart is the minimum change that makes the fix work end-to-end.

Automating this (e.g., a post-edit hook that re-runs `specify extension add --dev`) is out of scope for this feature — it is a separate concern about preflight's dev-loop ergonomics, and automating based on file-watch would complicate the worktree-clean invariants the project already has (FR-028). If the re-install friction becomes real, a follow-up issue can address it.

**Alternatives considered**:
- *Automated propagation via hook*: rejected for this feature — adds complexity outside the scope of a rule-text edit; better handled as a separate dev-tooling concern.
- *Symlink the `.specify/` copy to the source*: rejected — breaks the "install copy is a snapshot" contract and makes the source-vs-install distinction meaningless.
- *Skip propagation entirely, edit both files*: rejected — two files with drift risk; violates the source-of-truth rule in CLAUDE.md.

---

## 5. Reviewer prompt changes

**Decision**: No reviewer prompt changes in this feature. The existing checklist-reviewer prompt already loads the rule file and applies the rules as written — broadening CONST-R04's text is sufficient.

**Rationale**: Spec Assumption 2 scopes reviewer prompt changes as out-of-bounds for this feature. Reviewing the current `extensions/preflight/agents/reviewers/checklist-reviewer.md` confirms the prompt is rule-text-driven — it does not encode per-rule heuristics. If SC-001 / SC-002 fail empirically after Phase 2 implementation lands, prompt revision becomes a separate follow-up.

**Risk**: the property test is more abstract than pattern-matching and may require reviewer-prompt calibration to elicit reliably. This risk is acknowledged in ADR-008 (L68) and is the primary reason the ADR's Confirmation section gates promotion to `Accepted` on SC-001 + SC-002 passing empirically.

**Alternatives considered**:
- *Proactive prompt revision in this feature*: rejected — scope creep; the spec deliberately separated rule-text edits from prompt engineering to keep the feature tight.
- *Add a property-test invocation wrapper to the reviewer prompt*: rejected — premature optimization; measure first via SC-001/SC-002.

---

## 6. Version bump target

**Decision**: Bump **both** `extensions/preflight/extension.yml` and `presets/preflight/preset.yml` from `0.7.0.dev0` to `0.7.0.dev1` (PEP 440 dev-counter increment).

**Rationale**: Spec-kit validates version strings with `packaging.version.Version` — that's **PEP 440**, not SemVer. Hyphen-delimited pre-releases like `0.7.0-dev1` are rejected at install time (confirmed by commit `a923e0e` that fixed `0.7.0-spike` → `0.7.0.dev0`). Correct form for the dev-counter tick is `0.7.0.dev0 → 0.7.0.dev1` (dot-separated, numeric).

CONST-PROC-01 requires a version bump on behavioral change. Project `CLAUDE.md` further requires that preset and extension versions stay in lock-step (both currently track `0.7.0.dev0`). This feature changes reviewer behavior via rule-text in the extension; although the preset content is untouched, the lock-step convention exists so downstream consumers can pin a single `0.7.0.devN` tag and get a known pair. Bumping both preserves that invariant.

Staying within the 0.7.0 dev cycle (not jumping to `0.7.1.dev0`) is correct because `0.7.0` final has not shipped yet — the ADR-007 validation spike (per `docs/spikes/SPIKE_PLAN.md`) still gates the final release. PEP 440 orders `0.7.0.dev0 < 0.7.0.dev1 < ... < 0.7.0 final < 0.7.1.dev0`, so ticking the dev counter is the semantically correct move during an ongoing dev cycle.

**Alternatives considered**:
- *Bump extension only*: initially preferred (the preset has no behavioral change), but rejected because it diverges from `CLAUDE.md`'s lock-step convention. If that convention turns out to be dead weight, a follow-up can relax it in `CLAUDE.md` and a future feature can bump them independently.
- *Jump to `0.7.1.dev0`*: rejected — implies the 0.7.0 dev cycle is closed, which it isn't (no `0.7.0` final has shipped). Correct signal for an ongoing dev cycle is ticking the dev counter, not bumping the patch number.
- *Move to `0.7.0` stable*: rejected — spike not complete; releasing as stable now would be premature.
- *Hyphenated form `0.7.0-dev1`*: rejected — invalid PEP 440 (spec-kit validator rejects hyphens in the pre-release segment).
- *No version bump*: rejected — violates CONST-PROC-01.

---

## Summary of resolved unknowns

| Unknown | Resolution |
|---|---|
| Rule-file structure | Subsection under the rule table; one-line table entry cites the subsection |
| Exemplar count | 1 (bad, good) pair per shape × 8 shapes = 8 pairs = 16 example sentences |
| Test corpora location | `specs/001-…/fixtures/benchmark-issue-13.md` + `control-agnostic.md` |
| Install-copy propagation | Manual `specify extension add --dev` documented in quickstart |
| Reviewer prompt | No change in this feature; risk tracked |
| Version bump | Both extension.yml and preset.yml, `0.7.0.dev0` → `0.7.0.dev1` (PEP 440 dev-counter tick, lock-step per CLAUDE.md) |

No `NEEDS CLARIFICATION` markers remain. Phase 1 proceeds.
