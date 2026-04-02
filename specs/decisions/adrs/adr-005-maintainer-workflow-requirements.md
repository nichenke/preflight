---
status: Accepted
date: 2026-04-01
owner: nic
version: 0.1.0
deciders: [nic]
consulted: []
informed: []
---

# ADR-005: Add Maintainer Workflow Requirements with Persona Attribution

## Context and Problem Statement

The requirements spec defines four personas (bootstrapper, spec author, spec reviewer,
plugin author) and five user journeys. Journey 5 (Evolve framework content) covers the
plugin author editing content, running tests, and shipping — but stops there.

Actual plugin maintenance involves workflows not covered by any journey or FR:
- Triaging GitHub issues against specs and constitution
- Enforcing development workflow invariants (worktrees, feature branches, PRs)
- Assessing backlog health and spec hygiene

We built local tooling for these workflows (issue-triage skill, git-workflow rule,
traceability rule) and discovered there are no requirements to trace them to. The
existing FRs also don't attribute to personas — you can infer which persona each FR
serves, but it's implicit.

This matters because local development tooling and shipped plugin behavior serve
different personas with different quality gates. Without persona attribution, it's
unclear whether a given FR is a user-facing plugin contract or a maintainer workflow
aid.

## Decision Drivers

- CONST-PROC-02 requires an ADR for behavioral requirement changes
- The issue-triage skill (PR #10) has no FR to trace to
- Git workflow enforcement hooks have no FR to trace to
- Existing FRs lack persona attribution, making traceability ambiguous
- Section 9 (Out of Scope) lists "mechanical rule enforcement via hooks" for v1 plugin
  behavior — but local repo hooks serving the maintainer persona are a different concern

## Considered Options

1. Add a "Maintainer workflow" journey and FRs to requirements.md with persona tags
2. Keep maintainer tooling undocumented as local-only convention
3. Create a separate maintainer-requirements.md for local tooling

## Decision Outcome

Chosen option: "Add a Maintainer workflow journey and FRs to requirements.md with
persona tags", because all personas and their workflows belong in a single requirements
doc, and persona attribution makes the scope of each FR explicit.

### Consequences

- Good, because maintainer tooling (skills, hooks, rules) now has FRs to trace to
- Good, because persona tags clarify which FRs are user-facing plugin contracts vs
  maintainer workflow aids
- Good, because future local tooling has a requirements section to extend
- Bad, because adding persona tags to existing FRs is a documentation chore — mitigated
  by doing it incrementally (new FRs get tags now, existing FRs get tags in a cleanup pass)
- Neutral, because this does not move "mechanical rule enforcement via hooks" into scope
  for the plugin — that remains out of scope per Section 9. The hooks here are local repo
  tooling, not shipped plugin content.

### Confirmation

- Journey 6 exists in requirements.md with maintainer persona attribution
- FR-026+ exist for issue triage, workflow enforcement, and traceability
- New FRs have persona tags; existing FRs have section headers that imply persona
- Local hook enforcing git workflow traces to a specific FR

## Pros and Cons of the Options

### Add journey and FRs to requirements.md with persona tags

Single requirements doc, all personas represented, persona attribution on new FRs.

- Good, because maintains single source of truth for all requirements
- Good, because persona tags make traceability explicit
- Good, because journey format matches existing template pattern
- Bad, because requirements.md grows longer

### Keep maintainer tooling undocumented

Local tooling exists without spec coverage.

- Good, because no spec changes needed
- Bad, because maintainer tooling has no FRs to trace to — violates the traceability
  invariant we just added to our own rules
- Bad, because future maintainers have no spec to understand why local tooling exists

### Separate maintainer-requirements.md

Split local tooling requirements into a separate doc.

- Good, because separates plugin behavior from maintainer workflow
- Bad, because splits persona coverage across two docs — cross-doc references needed
- Bad, because the template and rules assume one requirements doc per project

## More Information

- PR #10: issue-triage skill and traceability rule
- Issue #9: backlog health observations (future plugin feature)
- Section 9 of requirements.md: "Mechanical rule enforcement via hooks" remains out of
  scope for plugin v1 — this ADR covers local repo hooks only
