# Reviewer rule-gap issue cluster — 2026-04-22

Six open GitHub issues propose expansions to preflight's reviewer rule set. They share a theme — the ensemble today under-detects certain anti-patterns — but they touch different rules, different severity levels, and have different readiness. This note preserves the cluster so it can drive post-spike planning without re-deriving the grouping from scratch.

Salvaged from `docs/analysis/2026-04-10-repo-health-analysis.md` (pre-conversion-era, most of which is obsolete). That source doc is being retired; only this cluster is worth carrying forward.

## The six issues

| Issue | Scope | Target rule(s) | Readiness |
|-------|-------|----------------|-----------|
| [#13](https://github.com/nichenke/preflight/issues/13) | Reviewer misses implementation details in constitution (function names, file paths, env vars, CLI invocations, inline expressions) | Edit to existing **CONST-R04** | Ready — spike 1 |
| [#14](https://github.com/nichenke/preflight/issues/14) | No rule detects redundant or overlapping constitution principles | New rule — proposed **CONST-R07** (see collision note) | Exploratory — scope-overlap heuristic needs design |
| [#17](https://github.com/nichenke/preflight/issues/17) | Constitution principles cross-referencing FR/NFR IDs (layering violation) | New rule — also proposed **CONST-R07** (see collision note) | Ready — exact file changes specified in issue |
| [#18](https://github.com/nichenke/preflight/issues/18) | Requirements containing implementation status or "known gaps" prose | New rule — proposed **REQ-R08** | Ready — exact file changes specified in issue |
| [#8](https://github.com/nichenke/preflight/issues/8) | Review doesn't flag docs missing mandatory template sections | Likely a new cross-doc or universal rule | Exploratory — needs template-skeleton comparator design |
| [#9](https://github.com/nichenke/preflight/issues/9) | No backlog-health / cross-document observation mode | New review mode or skill, not a rule extension | Aspirational — Phase 5+ scope, not a rule-table fix |

## CONST-R07 ID collision — sequence before implementation

**Both #17 and #14 propose a new rule numbered CONST-R07.** Only one can claim the ID. Sequencing must happen before either lands:

- #17 (cross-reference layering) has complete specs with exact file changes and is ready to implement immediately.
- #14 (redundancy/overlap heuristic) is exploratory and will likely take longer to design.

**Recommendation:** assign CONST-R07 to whichever lands first. Natural ordering gives it to #17; #14 takes the next free ID (CONST-R08 at that point). Note this on both issues when work begins so the second-to-land PR doesn't re-claim R07.

**Spike 1 (#13) is NOT implicated.** Issue #13 is an edit to the existing CONST-R04, not a new rule — it should not touch R07 or any other new ID. If CONST-R04 ends up being split during spike 1 implementation (e.g. pulling implementation-detail enforcement into its own rule), that split would need a new ID — coordinate against #17/#14 before assigning it.

## What was in the source doc but is NOT salvaged

The 2026-04-10 health doc also tracked:

- **Issues #11 and #7** (MoSCoW priority support, program-requirements content bundling). Framework-evolution topics, not reviewer-rule gaps. Out of cluster scope.
- Specs-health table, stale branches table, marketplace.json version drift, test-pass counts — all obsolete to the plugin → spec-kit extension conversion (PR #24, #26, #27).
- Velocity stats and priority recommendations — superseded by the workflow-research SPIKE_PLAN and handoff artifacts.

## Downstream consumers

- Spike 1 picks up #13 directly (CONST-R04 coverage expansion).
- Phase 5 reviewer-reliability investigation will revisit #14 and #8 once we have baseline reliability data.
- #9 is explicit follow-up only; it depends on Topology A vs C promotion first.
