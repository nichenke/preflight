---
type: rules
applies_to: architecture
version: 2.0.0
source: PM Documentation Framework (Notion)
---

# Architecture & Design Document — Content Rules

| Rule ID | Rule | Severity |
|---------|------|----------|
| ARCH-R01 | Every external interface in Context SHALL specify protocol and data format | Error |
| ARCH-R02 | Every component in Building Block View SHALL have a one-line responsibility statement | Warning |
| ARCH-R03 | Solution Strategy SHALL reference at least one ADR | Warning |
| ARCH-R04 | Runtime View SHALL include at least one failure scenario | Warning |
| ARCH-R05 | Deployment View SHALL specify all environments (not just prod) | Warning |
| ARCH-R06 | Quality Scenarios SHALL be traceable to NFRs in the requirements spec | Warning |
| ARCH-R07 | Crosscutting Concepts SHALL NOT be empty — at minimum cover auth, observability, and error handling | Warning |

## Anti-Patterns to Flag

- **Ambiguous box-and-arrow diagrams**: Use C4 or a clearly labeled notation with a legend
- **Technology choices without rationale**: Every tech choice should reference an ADR — "we're using Kafka" without why is insufficient
- **Duplicated requirement text**: Reference requirements by ID, don't copy full text into the architecture doc
