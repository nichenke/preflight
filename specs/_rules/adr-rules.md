---
type: rules
applies_to: adr
version: 1.0.0
source: PM Documentation Framework (Notion)
---

# Architecture Decision Records — Content Rules

| Rule ID | Rule | Severity |
|---------|------|----------|
| ADR-R01 | Title SHALL be a short imperative verb phrase, not a question | Error |
| ADR-R02 | Status SHALL be one of: Proposed, Accepted, Deprecated, Superseded | Error |
| ADR-R03 | If Superseded, the superseding ADR number SHALL be referenced | Error |
| ADR-R04 | Context SHALL be written in value-neutral language (no advocacy) | Warning |
| ADR-R05 | Decision SHALL use active voice ("We will...", not "It was decided...") | Warning |
| ADR-R06 | At least two options SHALL be listed in Considered Options | Error |
| ADR-R07 | Each option SHALL have at least one Pro and one Con | Warning |
| ADR-R08 | Consequences SHALL include at least one negative/tradeoff item | Warning |
| ADR-R09 | Decision Drivers SHALL be present and each SHALL be concrete (not "flexibility" or "simplicity" without qualification) | Warning |
| ADR-R10 | The ADR SHALL be one decision per record — no compound decisions | Error |
| ADR-R11 | ADR numbers SHALL be sequential and never reused | Error |
| ADR-R12 | The full document SHALL NOT exceed ~2 pages | Info |
| ADR-R13 | The Confirmation section SHALL specify a revisit date or trigger | Info |

## Anti-Patterns to Flag

- **Decision without alternatives**: If you didn't consider alternatives, it's not really a decision — it's an assumption
- **Retroactive justification**: Writing an ADR after the code is shipped to paper over a gut call
- **Consequence-free decisions**: Every decision has tradeoffs; if none are listed, they weren't thought through
- **Scope creep**: An ADR that covers three decisions should be split into three ADRs
- **Opinion in Context**: The Context section describes forces, not preferences
