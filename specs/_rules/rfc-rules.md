---
type: rules
applies_to: rfc
version: 1.1.0
source: PM Documentation Framework (Notion)
---

# RFC / Design Proposal — Content Rules

| Rule ID | Rule | Severity |
|---------|------|----------|
| RFC-R01 | Executive Summary SHALL NOT exceed 3 sentences | Warning |
| RFC-R02 | At least one alternative SHALL be documented in Alternatives Considered | Error |
| RFC-R03 | Scope SHALL explicitly list Out of Scope items | Warning |
| RFC-R04 | Migration/Rollout SHALL include a rollback plan | Warning |
| RFC-R05 | An accepted RFC SHALL produce at least one ADR, referenced in Meta | Error |
| RFC-R06 | Status transitions SHALL be timestamped in the Meta section | Info |
| RFC-R07 | Problem Statement SHALL include specific, measurable evidence (not vague complaints) | Warning |
| RFC-R08 | Each alternative SHALL document conditions under which it would be reconsidered | Info |
| RFC-R09 | Open Questions SHALL each have an owner and target resolution date | Warning |
| RFC-R10 | Reviewers list SHALL distinguish required reviewers from informed parties | Info |
| RFC-R11 | Related Requirements SHALL reference specific FR/NFR IDs, not prose descriptions | Warning |
| RFC-R12 | Proposed Solution SHALL include at least one diagram for any multi-component change | Warning |
| RFC-R13 | A rejected or withdrawn RFC SHALL have a Resolution section explaining why | Error |
| RFC-R14 | An RFC SHALL NOT remain In Review for more than 2 weeks without an explicit extension note | Warning |

## Anti-Patterns to Flag

- **RFC as rubber stamp**: Writing an RFC after implementation is done, just for process compliance. If the code is already shipped, write an ADR instead — that's what retroactive decision records are for.
- **Missing alternatives**: An RFC with only one option isn't an RFC — it's a notification. If there truly are no alternatives, explain why this is the only viable path and document the constraints that eliminate other options.
- **Kitchen sink RFC**: An RFC that covers five different decisions should be five RFCs. Each RFC should resolve to a clean set of ADRs, not a sprawling omnibus decision.
- **Perpetual Draft**: An RFC that sits in Draft for weeks without moving to In Review. Either finish it or withdraw it.
- **Review without resolution**: An RFC that has been In Review for a month with unresolved comments. Timebox reviews (RFC-R14). Escalate or decide.
- **Solution looking for a problem**: Proposed Solution section is 10x the length of the Problem Statement. The problem must be clearly established before the solution is worth reviewing.
- **No rollback plan**: "We'll figure it out if it goes wrong" is not a rollback plan. Every RFC for a production change needs an explicit reversal path.
