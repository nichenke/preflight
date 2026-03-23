---
type: reference
topic: agent-optimization
version: 1.0.0
source: PM Documentation Framework (Notion)
---

# AI Agent Optimization Notes

## What Makes Docs Agent-Consumable

1. **Structured headings**: Consistent H1/H2/H3 hierarchy that agents can parse predictably
2. **Unique IDs on everything**: FR-001, NFR-001, ADR-001, RFC-001 — agents need stable references
3. **EARS notation for requirements**: The keyword patterns (When/While/Where/If-Then) are parseable and map directly to test conditions
4. **Explicit over implicit**: Never assume shared context. State constraints, assumptions, and scope boundaries explicitly
5. **Machine-readable metadata**: YAML frontmatter for status, dates, owners, relationships
6. **No prose-only decisions**: Every decision point should have structured options, not buried in paragraph text
7. **Separate business from technical**: Keeping product requirements (what) separate from technical specs (how) reduces context window waste and improves agent reasoning

## What Causes Agent Failures

- **Ambiguous requirements** -> agent makes assumptions that diverge from intent
- **Missing constraints** -> agent picks technologies or patterns you can't use
- **Implicit interfaces** -> agent generates code that doesn't match actual contracts
- **Decision rationale buried in prose** -> agent can't distinguish current decisions from rejected alternatives
- **Stale docs** -> agent builds against superseded architecture
- **Compound documents** -> cramming everything into one file wastes context and increases hallucination risk

## Recommended File Organization for SDD Pipelines

```
project/
├── specs/
│   ├── requirements.md          # The what & why
│   ├── architecture.md          # The how (system level)
│   ├── interfaces/
│   │   ├── service-a-b.md       # One file per interface boundary
│   │   └── service-a-c.md
│   ├── test-strategy.md         # How we verify
│   └── glossary.md              # Shared vocabulary
├── decisions/
│   ├── rfcs/
│   │   ├── rfc-001-auth-approach.md
│   │   └── rfc-002-data-model.md
│   └── adrs/
│       ├── adr-001-use-postgresql.md
│       ├── adr-002-event-sourcing.md
│       └── adr-003-grpc-internal.md
└── tasks/                       # Generated from specs (Kiro/Spec-Kit style)
    ├── task-001.md
    └── task-002.md
```

## Six Things an Agent Needs Before Writing Code

1. **What are we building and for whom?** (Requirements / PRD / spec.md)
2. **What are the hard constraints?** (Constitution + project constraints)
3. **What's the technical approach?** (Architecture / plan.md / design.md)
4. **What are the data shapes and API boundaries?** (Data model + contracts)
5. **What does "done" look like for this specific task?** (Acceptance criteria + test expectations)
6. **What's the current state of the codebase?** (Not a doc — runtime agent behavior)

If an agent has answers to all six, it can execute reliably. If any are missing, it
guesses — and guessing is where compound accuracy degradation kills multi-step systems.
