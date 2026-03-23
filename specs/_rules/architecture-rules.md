---
type: rules
applies_to: architecture
version: 1.0.0
source: PM Documentation Framework (Notion)
---

# Architecture & Design Document — Content Rules

| Rule ID | Rule | Severity |
|---------|------|----------|
| ARCH-R01 | Every external interface in Context SHALL specify protocol and data format | Error |
| ARCH-R02 | Every component in Building Block View SHALL have a one-line responsibility statement | Error |
| ARCH-R03 | Solution Strategy SHALL reference at least one ADR | Warning |
| ARCH-R04 | Runtime View SHALL include at least one failure scenario | Warning |
| ARCH-R05 | Deployment View SHALL specify all environments (not just prod) | Warning |
| ARCH-R06 | Quality Scenarios SHALL be traceable to NFRs in the requirements spec | Warning |
| ARCH-R07 | Risks SHALL each have a mitigation plan or explicit acceptance | Warning |
| ARCH-R08 | Diagrams SHALL use C4 or a clearly labeled notation — no ambiguous box-and-arrow | Warning |
| ARCH-R09 | Technology choices SHALL NOT appear without rationale (no "we're using Kafka" without why) | Error |
| ARCH-R10 | The document SHALL NOT duplicate full requirement text — reference by ID | Info |
| ARCH-R11 | Crosscutting Concepts SHALL NOT be empty — at minimum cover auth, observability, and error handling | Warning |
