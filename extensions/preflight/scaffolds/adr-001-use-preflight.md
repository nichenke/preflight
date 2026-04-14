---
status: Accepted
date: YYYY-MM-DD
deciders: []
consulted: []
informed: []
---

# ADR-001: Use Preflight for Spec-Driven Development

## Context and Problem Statement

AI coding agents produce better results when given structured, unambiguous specifications
rather than ad-hoc prompts. Without a consistent documentation framework, each project
re-invents its own spec format, requirements drift without traceability, and agents make
assumptions that diverge from intent.

## Decision Drivers

- Agents need structured, behavior-oriented specs to generate correct code
- Requirements changes must be traceable to prevent silent scope drift
- Decisions need to be recorded so agents don't relitigate them
- Interface boundaries must be explicit — agents can't infer implicit contracts

## Considered Options

1. Ad-hoc documentation per project
2. Adopt preflight framework (EARS + MADR + arc42 + structured templates)

## Decision Outcome

Chosen option: "Adopt preflight framework", because it provides structured templates
with machine-checkable review rules, uses industry standards (EARS, MADR 4.0, arc42),
and integrates natively with Claude Code via plugin.

### Consequences

- Good, because agents get structured, parseable specs with unique IDs and EARS notation
- Good, because requirements changes are governed by ADRs, preventing silent scope drift
- Good, because machine-checkable review rules catch issues before code is written
- Bad, because there is upfront effort to write constitution and initial requirements

### Confirmation

Revisit after completing initial requirements and first ADR cycle. Success: agents
produce code that aligns with specs on first pass more often than without the framework.
