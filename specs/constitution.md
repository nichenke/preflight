---
status: Ratified
version: 1.1.0
date: 2026-03-25
ratified_by: [nic]
last_amended: 2026-03-28
amendment_adrs: [ADR-003]
---

# Engineering Constitution

## Preamble

This constitution defines non-negotiable engineering principles for the PM Documentation
Framework project. All agents, all features, and all code must comply. Amendments require
an ADR with explicit ratification.

## Content Integrity
- [CONST-CI-01] All framework content must be usable without Notion access — the git repo is the standalone distribution
- [CONST-CI-02] Templates are the single source of truth for document structure — do not duplicate template content in other files
- [CONST-CI-03] Rule IDs are stable — renumbering or removing IDs requires an ADR

## Distribution
- [CONST-DIST-01] Rules auto-load via `.claude/rules/`, never require CLAUDE.md edits in target projects
- [CONST-DIST-02] Plugin installation must not overwrite project-specific files (constitution, glossary, requirements, ADRs, RFCs)

## Quality
- [CONST-QA-01] Skills must be measurably better than manual workflow before shipping — use /skill-creator evals to validate
- [CONST-QA-02] Evals must cover rule following, activation ordering, and skill triggering accuracy
- [CONST-QA-03] Plugin releases must pass automated content integrity tests, plugin structure validation, and functional end-to-end testing — no manual-only quality gates

## Process
- [CONST-PROC-01] Any plugin change that alters behavior bumps the version (semver)
- [CONST-PROC-02] All behavioral requirement changes require an ADR (REQ-R07)
- [CONST-PROC-03] ADRs use MADR 4.0 format

## Amendment Log
| Version | Date | ADR | Change Summary |
|---------|------|-----|----------------|
| 1.0.0 | 2026-03-25 | ADR-001 | Initial ratification |
| 1.1.0 | 2026-03-28 | ADR-003 | Add CONST-QA-03 — automated quality gates for plugin releases |
