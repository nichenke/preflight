# Quickstart: Verifying feature 001 acceptance

**Feature**: `001-fix-const-reviewer-impl-detection`
**Purpose**: Run the preflight review against the SC-001 and SC-002 fixture corpora and confirm both pass.

Use this after Phase 2 implementation lands (CONST-R04 rewritten, exemplars authored, fixtures written) and before promoting ADR-008 from `Proposed` to `Accepted`.

## Prerequisites

- Worktree is on branch `001-fix-const-reviewer-impl-detection`.
- Implementation changes have been applied to `extensions/preflight/rules/constitution-rules.md`.
- Fixture files exist under `specs/001-fix-const-reviewer-impl-detection/fixtures/`.
- `spec-kit` CLI is installed (`pipx install "git+https://github.com/github/spec-kit.git@v0.6.2"`).

## Step 1: Propagate rule edits into the install copy

```bash
# From repo root
specify extension add --dev extensions/preflight
```

This re-copies `extensions/preflight/rules/constitution-rules.md` into `.specify/extensions/preflight/rules/`. The reviewer agents load from the install copy, so this step is required for the edit to take effect.

**Verify**: `diff extensions/preflight/rules/constitution-rules.md .specify/extensions/preflight/rules/constitution-rules.md` produces no output.

## Step 2: SC-001 — benchmark corpus (issue #13 examples)

Run the preflight review against the SC-001 fixture:

```bash
# In Claude Code
/speckit.preflight.review specs/001-fix-const-reviewer-impl-detection/fixtures/benchmark-issue-13.md
```

**Expected result**: every principle in the fixture is flagged under `CONST-R04`. The fixture contains five principles, each embedding exactly one of the issue #13 examples (`getPaiDir()`, `process.env.PAI_DIR || fallback`, `bootstrap.sh --target <dir>`, `settings.json`, `MEMORY/`).

**Pass condition**: five `CONST-R04` findings in the merged reviewer output, one per principle.

**Fail modes**:
- Fewer than five findings → rule-text broadening did not land in the install copy (re-run Step 1) or the property test is too narrow (revise rule text or add exemplars).
- More than five findings → fixture contains unintended extra leaks (fixture defect, not reviewer defect). Inspect the fixture.

## Step 2b: SC-003 — scaffolding-shapes corpus (coverage gap filler)

```bash
# In Claude Code
/speckit.preflight.review specs/001-fix-const-reviewer-impl-detection/fixtures/benchmark-scaffolding-shapes.md
```

**Expected result**: 3 `CONST-R04` findings — one per principle. The fixture covers the three scaffolding shapes not exercised by the issue #13 benchmark (tool/vendor, inline code token, version-pinned standard).

**Pass condition**: three `CONST-R04` findings in the merged reviewer output.

**Fail modes**:
- Fewer than three findings → reviewer's detection has narrowed below the rule's 8-shape claim, even though SC-001 still passes. Inspect which shape silently passed; treat as a regression.
- More than three findings → fixture contains unintended extra leaks (fixture defect). Inspect the fixture.

## Step 2c: SC-004 — multi-phrase corpus (phrase-level flagging)

```bash
# In Claude Code
/speckit.preflight.review specs/001-fix-const-reviewer-impl-detection/fixtures/benchmark-multi-phrase.md
```

**Expected result**: 7 `CONST-R04` findings — one per distinct implementation-detail phrase across the three principles (2 + 2 + 3). The fixture contains three composite principles (function+file, env var+CLI, CLI+tool/vendor+directory at n=3) to validate the rule's "each offending phrase flagged independently" claim at both n=2 and n=3 shape counts per principle.

**Pass condition**: seven `CONST-R04` findings in the merged reviewer output.

**Fail modes**:
- 6 findings (3-shape principle flags only 2) → reviewer silently caps findings at 2 per principle. This regression is invisible to n=2 fixtures.
- 3 or 4 findings → reviewer truncates at principle-level granularity despite the rule's explicit phrase-level claim.
- Any other count → inspect which phrases produced duplicate or missing flags.

## Step 3: SC-002 — control corpus (implementation-agnostic principles)

```bash
# In Claude Code
/speckit.preflight.review specs/001-fix-const-reviewer-impl-detection/fixtures/control-agnostic.md
```

**Expected result**: zero findings under `CONST-R04`. The fixture contains eight implementation-agnostic outcome statements drawn from EARS-pattern examples.

**Pass condition**: no `CONST-R04` findings in the merged reviewer output.

**Fail modes**:
- One or more findings → false positive. Inspect which principle was flagged; check whether the exemplar pairs in the rule file are miscalibrating the reviewer, or whether the fixture principle is accidentally leaky (fix the fixture). Do not blanket-broaden exemptions.

## Step 4: Record results

Paste the reviewer output summaries for each step into this feature's eventual ratification PR description. All four SCs (SC-001, SC-002, SC-003, SC-004) passing is the signal to:

1. Mark feature 001 ready for ratification.
2. Promote ADR-008 from `Proposed` to `Accepted`.
3. Bump `extensions/preflight/extension.yml` **and** `presets/preflight/preset.yml` versions in lock-step per CONST-PROC-01 + CLAUDE.md (see research.md § 6).

## Rollback

If any of SC-001 through SC-004 fail persistently and the cause is in the rule text itself (not a fixture defect), revert the CONST-R04 subsection edit in `extensions/preflight/rules/constitution-rules.md` to the prior narrow-enumeration text. The rule ID `CONST-R04` remains stable either way (FR-004 / CONST-CI-03) — external references continue to resolve.

Open a follow-up issue documenting which SC failed and why. The ADR-008 Confirmation section explicitly allows ADR revision when SCs do not pass.
