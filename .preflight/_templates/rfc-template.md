---
type: template
doc_type: rfc
version: 1.1.0
source: PM Documentation Framework (Notion)
---

# RFC-NNN: [Descriptive Title]

## Meta
- Author: [name]
- Status: [Draft | In Review | Accepted | Rejected | Withdrawn]
- Created: [date]
- Last Updated: [date]
- Reviewers: [list with roles — who MUST review vs who is informed]
- Related Requirements: [FR-xxx, FR-yyy, NFR-zzz]
- Resulting ADRs: [ADR-xxx, ADR-yyy — filled in after acceptance]

## Executive Summary
2-3 sentences: what you're proposing and why. A busy reviewer
should be able to read ONLY this and know whether they need to
read the full RFC.

## Problem Statement
What's broken, missing, or suboptimal today? Include data if
available. Be specific — "performance is bad" is not a problem
statement; "p99 latency on /api/orders exceeds 2s under >500 RPS
load" is.

## Scope

### In Scope
- [Explicit list of what this RFC covers]

### Out of Scope
- [Explicit list with brief rationale for each exclusion]
  (prevents scope creep during review)

## Proposed Solution
Detailed description of the approach. Include as many of these
as relevant:
- Architecture diagrams (C4 or clearly labeled)
- Data model changes (schema diffs, new entities)
- API surface changes (new endpoints, modified contracts)
- Sequence diagrams for complex flows
- Pseudocode for non-obvious logic
- Configuration / feature flag approach

## Alternatives Considered
For each alternative (minimum one):
- **[Alternative Name]**
  - Description: what this approach would look like
  - Pros: what it gets right
  - Cons: why it was not preferred
  - When to reconsider: under what circumstances this might
    become the better choice

## Migration / Rollout Plan
How do we get from here to there?
- Phases (if applicable)
- Feature flags / gradual rollout strategy
- Backward compatibility approach
- Rollback plan (what if this goes wrong?)
- Data migration steps (if applicable)

## Risks & Open Questions

### Known Risks
For each risk:
- Risk: [description]
- Likelihood: [Low/Medium/High]
- Impact: [Low/Medium/High]
- Mitigation: [approach]

### Open Questions
For each question:
- Question: [what needs answering]
- Why it matters: [impact on the proposal]
- Owner: [who will resolve this]
- Target date: [when we need the answer]

## Dependencies
- Other teams affected: [list]
- Services that need changes: [list]
- External systems or third parties: [list]
- Timeline dependencies: [must happen before/after X]

## Success Criteria
How will we know this worked?
- Metrics: [specific, measurable targets]
- Timeline: [when we measure]
- Acceptance criteria: [what "done" looks like]

<!--
Status Lifecycle:

  Draft ----> In Review ----> Accepted ----> (produces ADR(s))
                 |
                 +-----------> Rejected  (with documented reason)
                 |
                 +-----------> Withdrawn (author pulls it back)

- Draft: Author is still writing. Not ready for formal review.
- In Review: Ready for formal review. Reviewers actively providing feedback.
- Accepted: Reviewers agree. Produces ADR(s). Resulting ADRs field populated.
- Rejected: Not proceeding. Add ## Resolution: Rejected section. Keep in repo.
- Withdrawn: Author pulls back. Add ## Resolution: Withdrawn section.

When to Write an RFC vs an ADR:

- Multiple viable approaches, non-obvious tradeoffs -> RFC then ADR(s)
- Decision affects multiple teams or broad blast radius -> RFC then ADR(s)
- Foundational choice constraining everything downstream -> RFC then ADR(s)
- Decision is constrained, only one real option -> ADR directly
- Team discussed verbally, just needs recording -> ADR directly
- Low-risk, easily reversible -> ADR directly
- Clarifying existing behavior, no decision needed -> Neither, update spec
- Bug fix with obvious cause -> Neither, just fix it
-->
