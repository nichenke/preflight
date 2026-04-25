---
status: Under Review — plugin-to-extension conversion in progress
version: 1.2.0
date: 2026-03-25
owner: nic
ratified_by: [nic]
last_amended: 2026-04-25
amendment_adrs: [ADR-003, ADR-009]
---

# Engineering Constitution

> **⚠️ STATUS (2026-04-25): Under partial rewrite.** Preflight is converting from a Claude Code plugin to a native spec-kit extension (see ADR-007 and `docs/spikes/SPIKE_PLAN.md`). Several constitutional principles below reference plugin-form concepts that no longer apply:
>
> - **CONST-CI-02** path reference fixed below (was `content/templates/`, now `presets/preflight/templates/`)
> - **CONST-DIST-01** — `.claude/rules/` auto-load pattern is plugin-specific; spec-kit extensions distribute via `specify extension add`. Principle is stale pending rewrite.
> - **CONST-DIST-02** — "Plugin installation" language is stale; the spirit (don't overwrite project-authored docs) still applies to spec-kit extension install.
> - **CONST-QA-01 through CONST-QA-05** — reference "skills" and "plugin releases" that no longer exist. Eval suite concept may survive in spec-kit-native form; needs rewrite.
> - **CONST-PROC-01** — "plugin change bumps version" becomes "preset or extension change bumps version in preset.yml / extension.yml". Semver intent unchanged.
>
> **CONST-CI-01**, **CONST-CI-03**, **CONST-PROC-02**, **CONST-PROC-03**, **CONST-REV-01**, and **CONST-REV-02** (the last two added 2026-04-25 per ADR-009) remain valid as-is.
>
> A full rewrite is tracked as a follow-up — via a future constitution-amendment ADR (ADR-008 is now taken by the property-test rule shape decision) if ADR-007 is accepted, or deferred until the spike outcome is known. Do not cite stale principles in new work.

> **📍 LOCATION (2026-04-15):** This constitution moved from `specs/constitution.md` to `.specify/memory/constitution.md` per ADR-007 (path reconciliation with spec-kit). The spec-kit native `/speckit-constitution` skill edits this file. Historical references in ADR-002, docs/analysis/*, docs/plans/*, and docs/specs/* preserve the old path as a historical fact.

## Preamble

This constitution defines non-negotiable engineering principles for preflight. All agents, all features, and all code must comply. Amendments require an ADR with explicit ratification.

## Content Integrity
- [CONST-CI-01] The git repository is the canonical source for all framework content
- [CONST-CI-02] Templates live inside `presets/preflight/templates/` and are the single source of truth for document structure — do not duplicate template content in other files (updated 2026-04-14 from `content/templates/` during the plugin-to-extension conversion; principle intent unchanged)
- [CONST-CI-03] Rule IDs are stable — renumbering or removing IDs requires an ADR

## Distribution
- [CONST-DIST-01] Rules auto-load via `.claude/rules/`, never require CLAUDE.md edits in target projects
- [CONST-DIST-02] Plugin installation must not overwrite project-authored documents

## Quality
- [CONST-QA-01] Skills must pass a defined eval suite before shipping
- [CONST-QA-02] Evals must cover rule following, activation ordering, and skill triggering accuracy
- [CONST-QA-03] Plugin releases must pass automated content integrity tests
- [CONST-QA-04] Plugin releases must pass plugin structure validation
- [CONST-QA-05] Plugin releases must pass functional end-to-end testing

## Process
- [CONST-PROC-01] Any plugin change that alters behavior bumps the version (semver)
- [CONST-PROC-02] All behavioral requirement changes require an ADR (REQ-R07)
- [CONST-PROC-03] ADRs use MADR 4.0 format

## Review and Enforcement
- [CONST-REV-01] Preflight review (`/speckit.preflight.review`) is invoked on demand by the user or orchestrator; preflight does not auto-fire review at workflow gates
- [CONST-REV-02] Preflight asserts no author-time enforcement of review; whether and how to automate review firing is the user's or orchestrator's choice and is delegated to a follow-on orchestration ADR

## Amendment Log
| Version | Date | ADR | Change Summary |
|---------|------|-----|----------------|
| 1.0.0 | 2026-03-25 | (bootstrap) | Initial ratification — pre-plugin era, no ADR exists |
| 1.1.0 | 2026-03-28 | ADR-003 | Add CONST-QA-03 through CONST-QA-05 — automated quality gates for plugin releases |
| 1.2.0 | 2026-04-25 | ADR-009 | Add CONST-REV-01 and CONST-REV-02 — on-demand review invocation; preflight asserts no author-time enforcement |
