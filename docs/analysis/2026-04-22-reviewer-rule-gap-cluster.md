# Reviewer rule-gap issue cluster — 2026-04-22

A set of GitHub issues that propose expansions to preflight's reviewer rule set. They share a theme — the ensemble today under-detects certain anti-patterns — but touch different rules, severity levels, and readiness. This note preserves the cluster so it can drive post-spike planning without re-deriving the grouping from scratch.

Salvaged from `docs/analysis/2026-04-10-repo-health-analysis.md` (pre-conversion-era, most of which is obsolete). That source doc is being retired; only this cluster is worth carrying forward.

> **As-of note.** Readiness and shipped-status below reflect issue / rule-file state as of 2026-04-22. Two issues in the original 2026-04-10 snapshot (#17, #18) landed on 2026-04-12 — they are preserved here as historical context but are no longer open work. Verify against live issue state before acting on any row.

## Active cluster — still open

| Issue | Scope | Target rule(s) | Readiness |
|-------|-------|----------------|-----------|
| [#13](https://github.com/nichenke/preflight/issues/13) | Reviewer misses implementation details in constitution (function names, file paths, env vars, CLI invocations, inline expressions). Per the issue body, the *rule itself* (CONST-R04) is correct — the reviewer just applies it too narrowly. | Reviewer-application fix (checklist-reviewer prompt / examples); possibly CONST-R04 wording tighten | Ready — spike 1 |
| [#14](https://github.com/nichenke/preflight/issues/14) | No rule detects redundant or overlapping constitution principles | New rule — next free ID (CONST-R08 or later; see ID-allocation note) | Exploratory — scope-overlap heuristic needs design |
| [#8](https://github.com/nichenke/preflight/issues/8) | Review doesn't flag docs missing mandatory template sections | Likely a new cross-doc or universal rule | Exploratory — needs template-skeleton comparator design |
| [#9](https://github.com/nichenke/preflight/issues/9) | No backlog-health / cross-document observation mode | New review mode or skill, not a rule extension | Aspirational — Phase 5+ scope, not a rule-table fix |

## Already shipped — historical context

| Issue | Rule ID | Shipped at | Notes |
|-------|---------|------------|-------|
| [#17](https://github.com/nichenke/preflight/issues/17) | **CONST-R07** | `extensions/preflight/rules/constitution-rules.md:18` | Principles SHALL NOT cross-reference FR-NNN / NFR-NNN IDs. Issue closed 2026-04-12. |
| [#18](https://github.com/nichenke/preflight/issues/18) | **REQ-R08** | `extensions/preflight/rules/requirements-rules.md:19` | Requirements SHALL NOT contain implementation status or known gaps. Issue closed 2026-04-12. |

Included for cluster completeness — the original 2026-04-10 source doc listed them as ready-to-implement. They landed between the source snapshot and this salvage, which is why a verification/as-of note now accompanies any status claim in this file.

## Rule-ID allocation note

The 2026-04-10 source recorded a *"CONST-R07 collision"* between #17 and #14 — both proposed a new rule under that ID. That collision is **resolved**: #17 took CONST-R07 on 2026-04-12. If #14 is ever pursued, it must take the next free ID (CONST-R08 or later, depending on what lands first). Do not re-propose CONST-R07 for new work.

**Spike 1 (#13) is not affected.** Issue #13 is a reviewer-application fix against the existing CONST-R04 — it does not introduce a new rule and therefore does not claim a new ID. If CONST-R04 ends up being split during implementation (e.g. pulling implementation-detail enforcement into its own rule), the split would need a new ID — coordinate against #14 and any in-flight new-rule issues before assigning.

## What was in the source doc but is NOT salvaged

The 2026-04-10 health doc also tracked:

- **Issues #11 and #7** (MoSCoW priority support, program-requirements content bundling). Framework-evolution topics, not reviewer-rule gaps. Out of cluster scope.
- Specs-health table, stale branches table, marketplace.json version drift, test-pass counts — all obsolete to the plugin → spec-kit extension conversion (PR #24, #26, #27).
- Velocity stats and priority recommendations — superseded by the workflow-research SPIKE_PLAN and handoff artifacts.

## Downstream consumers

- Spike 1 picks up #13 directly (CONST-R04 reviewer-application expansion).
- Phase 5 reviewer-reliability investigation will revisit #14 and #8 once we have baseline reliability data.
- #9 is explicit follow-up only; it depends on Topology A vs C promotion first.
