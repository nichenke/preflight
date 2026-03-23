---
type: rules
applies_to: constitution
version: 1.0.0
source: PM Documentation Framework (Notion)
---

# Constitution / Engineering Principles — Content Rules

| Rule ID | Rule | Severity |
|---------|------|----------|
| CONST-R01 | Every principle SHALL have a unique ID in the format CONST-{CATEGORY}-NN | Error |
| CONST-R02 | Status SHALL be one of: Draft, Ratified, Amended | Error |
| CONST-R03 | A Ratified constitution SHALL list ratifiers in the frontmatter | Error |
| CONST-R04 | Each principle SHALL be a single, testable statement — not a paragraph of guidance | Warning |
| CONST-R05 | Principles SHALL NOT prescribe specific tools or versions ("use Jest" is too specific; "all code must have automated tests" is correct) | Warning |
| CONST-R06 | The constitution SHALL NOT exceed 30 principles — if it's longer, it's not a constitution, it's a standards doc | Warning |
| CONST-R07 | Every amendment SHALL be recorded in the Amendment Log with ADR reference | Error |
| CONST-R08 | The Preamble SHALL explicitly state the authority level and scope | Warning |
| CONST-R09 | Principles SHALL be phrased as imperatives ("All services MUST...") not aspirations ("We should try to...") | Warning |
| CONST-R10 | The constitution SHALL include at least one principle in each category that has active code/infrastructure | Info |

## Cross-Document Traceability

| Rule ID | Rule | Severity |
|---------|------|----------|
| CONST-X01 | ADRs SHOULD reference applicable constitution principles they operate within | Info |
| CONST-X02 | ADRs that propose something conflicting with a constitution principle SHALL include a constitution amendment | Error |
| CONST-X03 | Requirements that expand into areas not covered by the constitution SHOULD trigger a constitution review | Info |
| CONST-X04 | The architecture doc's Crosscutting Concepts (S8) SHALL be consistent with constitution principles | Warning |
| CONST-X05 | The test strategy SHALL demonstrate how constitution testing principles are implemented | Warning |

## Change Governance

**The constitution is the only document that governs its own change process.**

Requirements need ADRs to change (REQ-R13). The constitution — being higher authority —
needs ADRs AND ratification.

### Amendment Process
1. **Write an ADR** proposing the change (title: "ADR-NNN: Amend Constitution CONST-{ID}")
   - Context: why the current principle is insufficient or wrong
   - Decision: the new/modified/removed principle
   - Consequences: what changes downstream
2. **Ratification**: Explicitly approved by ratifiers listed in frontmatter
3. **Update the constitution**: Increment version, add to Amendment Log
4. **Cascade check**: Review downstream documents for conflicts

### What Requires an Amendment
- Adding a new principle
- Removing a principle
- Changing the meaning of an existing principle
- Changing the scope or authority statement in the Preamble

### What Does NOT Require an Amendment
- Fixing typos or grammar
- Adding examples or clarifications that don't change meaning
- Reorganizing categories (moving a principle between sections)

## Anti-Patterns to Flag

- **Constitution as wish list**: Principles nobody follows or enforces. Every principle should be something an agent or reviewer can check.
- **Too many principles**: More than 30 means it's not a constitution — it's a standards manual. Constitutions should be memorizable.
- **Tool-specific principles**: "Use PostgreSQL 16+" is an ADR, not a constitution principle. Constitutions should survive tool changes.
- **Unenforced amendments**: Changing the constitution without an ADR. If it's worth having a constitution, it's worth following the amendment process.
- **No ratifiers named**: A constitution with no `ratified_by` field has no authority — anyone could change it unilaterally.
- **Agent-invisible principles**: Principles that only a human could verify ("code should feel elegant"). Every principle should be checkable by a review agent.
