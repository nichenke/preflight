---
status: Accepted
date: 2026-03-23
deciders: [nic]
consulted: []
informed: []
---

# ADR-001: Use PM Documentation Framework for Spec-Driven Development

## Context and Problem Statement

AI coding agents produce better results when given structured, unambiguous specifications
rather than ad-hoc prompts. Without a consistent documentation framework, each project
re-invents its own spec format, requirements drift without traceability, and agents make
assumptions that diverge from intent. We need a standardized set of planning and design
documents that serve as shared source of truth between humans and AI agents.

## Decision Drivers

- AI agents need structured, behavior-oriented specs to generate correct code
- Requirements changes must be traceable to prevent silent scope drift
- Multiple SDD execution frameworks (Spec Kit, Kiro, OpenSpec, BMAD) each expect
  specific artifact types — a common framework maps to all of them
- Decisions need to be recorded so agents don't relitigate them
- Interface boundaries must be explicit — agents can't infer implicit contracts

## Considered Options

1. Ad-hoc documentation per project
2. Adopt PM Documentation Framework (EARS + MADR + arc42 + structured templates)
3. Adopt a single SDD tool's format (e.g., Spec Kit or Kiro) as the standard

## Decision Outcome

Chosen option: "Adopt PM Documentation Framework", because it provides tool-agnostic
templates that map to any SDD execution framework, uses industry standards (EARS, MADR 4.0,
arc42, C4), includes machine-checkable review rules, and covers the full artifact chain
from requirements through test strategy.

### Consequences

- Good, because agents get structured, parseable specs with unique IDs and EARS notation
- Good, because requirements changes are governed by ADRs (REQ-R13), preventing silent scope drift
- Good, because the framework maps to Spec Kit, Kiro, OpenSpec, and BMAD artifact chains
- Bad, because there is upfront effort to bootstrap templates, write constitution, and capture existing decisions as retroactive ADRs
- Neutral, because the framework identifies gaps (constitution, task template, UX spec, delta specs) that need to be filled incrementally

### Confirmation

Revisit after completing Phase 1 (constitution + initial requirements + retroactive ADRs).
Success criteria: agents produce code that aligns with specs on first pass more often than
without the framework.

## Pros and Cons of the Options

### Ad-hoc documentation per project

Each project defines its own format and level of detail.

- Good, because zero setup cost
- Bad, because no consistency across projects — agents must re-learn each format
- Bad, because no review rules — quality varies wildly
- Bad, because no traceability between requirements, decisions, and tests

### PM Documentation Framework

Structured templates with EARS requirements, MADR ADRs, arc42 architecture, and
machine-checkable review rules.

- Good, because industry-standard formats (EARS, MADR, arc42) with broad community support
- Good, because machine-checkable rules enable automated review
- Good, because explicit cross-document traceability (XDOC rules)
- Bad, because initial bootstrap effort (~4 hours for Phase 0+1)

### Single SDD tool format

Adopt one tool's native format (e.g., Spec Kit's spec.md/plan.md/tasks.md).

- Good, because tight integration with one execution pipeline
- Bad, because vendor lock-in to one tool's workflow
- Bad, because missing artifact types (e.g., Spec Kit has no explicit ADR support)
- Bad, because format may not map cleanly to other tools if we switch

## More Information

- Source: PM Documentation Framework (Notion) — https://www.notion.so/32cfd3b2bd8681498249ef7f5096a390
- EARS: Rolls-Royce, used by Kiro (AWS)
- MADR 4.0: https://github.com/adr/madr
- arc42: https://arc42.org
- C4 Model: https://c4model.com
