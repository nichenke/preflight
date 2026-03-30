---
type: rules
applies_to: rfc
version: 2.0.0
source: PM Documentation Framework (Notion)
---

# RFC / Design Proposal — Content Rules

| Rule ID | Rule | Severity |
|---------|------|----------|
| RFC-R01 | Executive Summary SHALL NOT exceed 3 sentences | Warning |
| RFC-R02 | At least one alternative SHALL be documented in Alternatives Considered | Warning |
| RFC-R03 | Scope SHALL explicitly list Out of Scope items | Warning |
| RFC-R04 | Migration/Rollout SHALL include a rollback plan | Warning |
| RFC-R05 | An accepted RFC SHALL produce at least one ADR, referenced in Meta | Error |
| RFC-R06 | Problem Statement SHALL include specific, measurable evidence | Warning |
| RFC-R07 | An RFC SHALL NOT remain In Review for more than 2 weeks without an explicit extension note | Warning |

## Anti-Patterns to Flag

- **RFC as rubber stamp**: Writing an RFC after implementation is done. If code is shipped, write an ADR instead.
- **Missing alternatives**: An RFC with only one option isn't an RFC — it's a notification. Document constraints that eliminate other options.
- **Kitchen sink RFC**: An RFC covering five decisions should be five RFCs. Each should resolve to a clean set of ADRs.
- **Perpetual Draft**: An RFC in Draft for weeks without moving to In Review. Finish it or withdraw it.
- **Review without resolution**: In Review for a month with unresolved comments. Timebox reviews (RFC-R07). Escalate or decide.
- **Solution looking for a problem**: Proposed Solution 10x the length of Problem Statement. Establish the problem first.
- **No rollback plan**: "We'll figure it out" is not a rollback plan.
- **Open questions without owners**: Every open question should have an owner and target resolution date.
- **Rejected RFC without explanation**: Add a Resolution section when rejecting or withdrawing.
