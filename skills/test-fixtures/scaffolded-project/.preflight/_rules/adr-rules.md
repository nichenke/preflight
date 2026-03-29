---
type: rules
applies_to: adr
version: 2.0.0
source: PM Documentation Framework (Notion)
---

# Architecture Decision Records — Content Rules

| Rule ID | Rule | Severity |
|---------|------|----------|
| ADR-R01 | Status SHALL be one of: Proposed, Accepted, Deprecated, Superseded | Error |
| ADR-R02 | Context SHALL be value-neutral (no advocacy); Decision SHALL use active voice ("We will...") | Warning |
| ADR-R03 | At least two options SHALL be listed in Considered Options | Warning |
| ADR-R04 | Each option SHALL have at least one Pro and one Con | Warning |
| ADR-R05 | Consequences SHALL include at least one negative/tradeoff item | Warning |
| ADR-R06 | Decision Drivers SHALL be present and each SHALL be concrete (not "flexibility" without qualification) | Warning |
| ADR-R07 | The ADR SHALL be one decision per record — no compound decisions | Warning |

## Anti-Patterns to Flag

- **Decision without alternatives**: If you didn't consider alternatives, it's not really a decision — it's an assumption
- **Retroactive justification**: Writing an ADR after the code is shipped to paper over a gut call
- **Consequence-free decisions**: Every decision has tradeoffs; if none are listed, they weren't thought through
- **Scope creep**: An ADR that covers three decisions should be split into three ADRs
- **Opinion in Context**: The Context section describes forces, not preferences
- **Title as question**: Titles should be short imperative verb phrases ("Use Event Sourcing for Order State"), not questions
- **Technology choice without ADR**: Any tech choice in the architecture doc should have a corresponding ADR with rationale
