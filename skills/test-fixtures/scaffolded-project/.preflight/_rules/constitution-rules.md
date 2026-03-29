---
type: rules
applies_to: constitution
version: 2.0.0
source: PM Documentation Framework (Notion)
---

# Constitution / Engineering Principles — Content Rules

| Rule ID | Rule | Severity |
|---------|------|----------|
| CONST-R01 | Every principle SHALL have a unique ID in the format CONST-{CATEGORY}-NN | Error |
| CONST-R02 | Status SHALL be one of: Draft, Ratified, Amended | Error |
| CONST-R03 | Each principle SHALL be a single, testable imperative statement ("All services MUST..."), not a paragraph of guidance or aspiration | Warning |
| CONST-R04 | Principles SHALL NOT prescribe specific tools or versions ("use Jest" is too specific; "all code must have automated tests" is correct) | Warning |
| CONST-R05 | The constitution SHALL NOT exceed 30 principles — if it's longer, it's not a constitution, it's a standards doc | Warning |
| CONST-R06 | Every amendment SHALL be recorded in the Amendment Log with ADR reference | Error |

## Change Governance

**The constitution is the only document that governs its own change process.**
Requirements need ADRs to change (REQ-R07). The constitution — being higher authority —
needs ADRs AND ratification.

### Amendment Process
1. **Write an ADR** proposing the change (title: "ADR-NNN: Amend Constitution CONST-{ID}")
2. **Ratification**: Explicitly approved by designated ratifiers
3. **Update the constitution**: Increment version, add to Amendment Log
4. **Cascade check**: Review downstream documents for conflicts

### What Requires an Amendment
- Adding, removing, or changing a principle
- Changing the scope or authority statement in the Preamble

### What Does NOT Require an Amendment
- Fixing typos or grammar
- Adding examples or clarifications that don't change meaning
- Reorganizing categories

## Anti-Patterns to Flag

- **Constitution as wish list**: Principles nobody follows or enforces. Every principle should be checkable by an agent or reviewer.
- **Too many principles**: More than 30 means it's a standards manual, not a constitution. Constitutions should be memorizable.
- **Tool-specific principles**: "Use PostgreSQL 16+" is an ADR, not a constitution principle. Constitutions should survive tool changes.
- **Unenforced amendments**: Changing the constitution without an ADR.
- **No ratifiers named**: A constitution without designated ratifiers has no authority.
- **Agent-invisible principles**: Principles only a human could verify ("code should feel elegant"). Every principle should be mechanically checkable.
