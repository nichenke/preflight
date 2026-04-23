# Implementation Plan: Constitution reviewer catches implementation-detail leaks consistently

**Branch**: `001-fix-const-reviewer-impl-detection` | **Date**: 2026-04-22 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/001-fix-const-reviewer-impl-detection/spec.md`

## Summary

Rewrite CONST-R04 in `extensions/preflight/rules/constitution-rules.md` from its current narrow enumeration ("principles shall not prescribe specific tools or versions") into the **property-test + illustrative scaffolding** shape established by ADR-008. The rule's normative clause becomes a single substitution-test invariant; the existing shape list moves into a non-normative exemplar section with paired good/bad examples. Authors a small benchmark corpus (issue #13 examples) and a control corpus (implementation-agnostic principles) to satisfy SC-001 and SC-002.

## Technical Context

**Language/Version**: Markdown edits only — no code changes in this feature
**Primary Dependencies**: preflight checklist reviewer agent (reads `extensions/preflight/rules/constitution-rules.md`)
**Storage**: Git-tracked markdown files under `extensions/preflight/rules/` and `specs/001-fix-const-reviewer-impl-detection/fixtures/`
**Testing**: Manual review runs using `/speckit.preflight.review` on benchmark + control corpora; SC verification by inspection of reviewer output
**Target Platform**: spec-kit extension layer (preflight v0.7.0-dev)
**Project Type**: Rule authoring / review-pipeline content
**Performance Goals**: N/A — offline reviewer invocation
**Constraints**: Rule ID `CONST-R04` must remain stable (FR-004, CONST-CI-03); rule-file source of truth stays at `extensions/preflight/rules/`; install-copy propagation is a planning concern decided in Phase 0 research
**Scale/Scope**: One rule-text rewrite, one exemplar section (16 examples = 2 pairs × 8 shapes), benchmark fixture (~5 principles) + control fixture (~8 principles)

## Constitution Check

*Gate: must pass before Phase 0 research. Re-check after Phase 1 design.*

Checked against `.specify/memory/constitution.md` v1.1.0. Stale principles flagged by the constitution's own "Under Review" banner are noted but not enforced.

| Principle | Status | Notes |
|---|---|---|
| CONST-CI-01 (git = canonical source) | ✓ | Edit lands in repo; nothing lives outside git |
| CONST-CI-02 (template path) | N/A | Not editing a template |
| CONST-CI-03 (rule IDs stable) | ✓ | FR-004 explicitly preserves `CONST-R04` |
| CONST-DIST-01 (auto-load rules) | N/A | Flagged stale in constitution banner (plugin-specific) |
| CONST-DIST-02 (no overwrite) | ✓ | Editing preflight-owned rule file, not a project-authored doc |
| CONST-QA-01 through CONST-QA-05 | SKIP | Flagged stale in constitution banner |
| CONST-PROC-01 (version bump) | REQUIRED | Bump both `extensions/preflight/extension.yml` and `presets/preflight/preset.yml` in lock-step (CLAUDE.md convention; both currently `0.7.0-dev`) |
| CONST-PROC-02 (ADR for behavioral change) | ✓ | ADR-008 covers the shape decision and this first application |
| CONST-PROC-03 (MADR for ADRs) | ✓ | ADR-008 uses MADR 4.0 |

**Gate result**: PASS. One explicit obligation from CONST-PROC-01 tracked in Phase 1 deliverables (version bump).

## Project Structure

### Documentation (this feature)

```text
specs/001-fix-const-reviewer-impl-detection/
├── spec.md              # feature spec (committed)
├── plan.md              # this file
├── research.md          # Phase 0 output — resolves unknowns
├── quickstart.md        # Phase 1 output — reviewer-run verification steps
├── checklists/
│   └── requirements.md  # spec quality checklist (from /speckit.specify)
└── fixtures/            # Phase 1 output — test corpora
    ├── benchmark-issue-13.md   # SC-001 corpus (issue #13 examples)
    └── control-agnostic.md     # SC-002 corpus (clean principles)
```

No `data-model.md` — this feature has no data model beyond the existing rule-row + finding shape already documented in ADR-008 and the checklist reviewer prompt.

No `contracts/` — this is an internal rule-text edit; no external interfaces are introduced or changed.

### Source code (repository root)

Implementation touches these paths:

```text
extensions/preflight/
├── rules/
│   └── constitution-rules.md       # EDIT — CONST-R04 row + new Examples section
└── extension.yml                   # EDIT — version bump per CONST-PROC-01

presets/preflight/
└── preset.yml                      # EDIT — version bump to keep preset/extension in sync per CLAUDE.md

specs/001-fix-const-reviewer-impl-detection/
└── fixtures/
    ├── benchmark-issue-13.md       # NEW — SC-001 corpus
    └── control-agnostic.md         # NEW — SC-002 corpus
```

Install-copy propagation into `.specify/extensions/preflight/rules/constitution-rules.md` is a re-install step (`specify extension add --dev`), covered in the quickstart.

**Structure Decision**: No new directories. Edits stay inside the existing `extensions/preflight/rules/` structure; the fixture directory is feature-local under `specs/001-…/fixtures/` so it ships with the spec and archives with it when the feature ratifies.

## Complexity Tracking

No constitution-check violations. No complexity-justification table required.
