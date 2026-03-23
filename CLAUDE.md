# PM Documentation Framework — Agent Instructions

## File Layout

```
specs/
  _templates/          # Copy a template to start a new doc
  _rules/              # Machine-checkable review rules per doc type
  _reference/          # EARS notation, doc taxonomy, cross-doc relationships, etc.
  constitution.md      # Non-negotiable engineering principles (always read)
  glossary.md          # Shared vocabulary
  requirements.md      # (created per project) What + why
  architecture.md      # (created per project) How
  test-strategy.md     # (created per project) How we verify
  interfaces/          # One file per component boundary
decisions/
  rfcs/                # Pre-decision exploration
  adrs/                # Immutable decision records (MADR 4.0)
```

## Core Rules — Read Before Coding

Before writing any implementation code, read these files in order:

1. `specs/constitution.md` — non-negotiable rules that override everything
2. `specs/requirements.md` — what to build (EARS requirements with FR/NFR IDs)
3. `decisions/adrs/` — scan for relevant accepted ADRs before making tech choices
4. `specs/architecture.md` — system structure, patterns, component responsibilities
5. `specs/interfaces/` — check for contracts at any boundary you're touching

If a file doesn't exist yet, note the gap but don't block on it.

## Requirements Change Governance (REQ-R13 / REQ-R14)

**No behavioral requirement change without an ADR.**

Any modification to requirements.md that alters system behavior, scope, or quantitative
targets SHALL be accompanied by an ADR documenting the change rationale.

**Requires an ADR:**
- Adding, removing, or changing a FR or NFR
- Changing an NFR's quantitative target
- Moving a requirement between in-scope and out-of-scope

**Does NOT require an ADR:**
- Clarifying wording without changing behavior
- Fixing EARS notation
- Adding a failure mode, assumption, or open question
- Typos and readability improvements

**The test:** If the change would cause an agent to generate different code, it needs an
ADR. If it only makes existing intent clearer, it doesn't.

## EARS Quick Reference

| Pattern | Keyword | Template |
|---------|---------|----------|
| Ubiquitous | (none) | The \<system\> shall \<response\>. |
| Event-driven | **When** | When \<trigger\>, the \<system\> shall \<response\>. |
| State-driven | **While** | While \<precondition\>, the \<system\> shall \<response\>. |
| Optional | **Where** | Where \<feature\>, the \<system\> shall \<response\>. |
| Unwanted | **If/then** | If \<condition\>, then the \<system\> shall \<response\>. |
| Complex | Combined | While \<pre\>, when \<trigger\>, the \<system\> shall \<response\>. |

## Review Rules Summary

Review rules are in `specs/_rules/`. Key severities:

**Error (must fix):**
- UNIV-01: YAML frontmatter with status, date, owner
- UNIV-02: Meta section with version and status
- REQ-R01: Functional requirements use EARS notation
- REQ-R02: Every requirement has a unique ID
- REQ-R03: Requirements don't prescribe implementation
- REQ-R13: Behavioral changes accompanied by ADR
- ADR-R06: At least two options in Considered Options
- ADR-R10: One decision per ADR
- ARCH-R01: External interfaces specify protocol and data format
- XDOC-01: Referenced ADRs exist in decisions/adrs/
- XDOC-02: Referenced requirement IDs exist in requirements.md

**Warning (should fix):**
- UNIV-05: Vague adjectives quantified
- REQ-R06: User journeys have failure modes
- ADR-R08: Consequences include tradeoffs
- ARCH-R04: Runtime view includes failure scenarios

## ID Conventions

| Doc Type | ID Pattern | Example |
|----------|-----------|---------|
| Functional Requirement | FR-NNN | FR-001 |
| Non-Functional Requirement | NFR-NNN | NFR-001 |
| ADR | ADR-NNN | ADR-001 |
| RFC | RFC-NNN | RFC-001 |
| Universal Rule | UNIV-NN | UNIV-01 |
| Cross-Doc Rule | XDOC-NN | XDOC-01 |
| Requirements Rule | REQ-RNN | REQ-R01 |
| ADR Rule | ADR-RNN | ADR-R01 |
| Architecture Rule | ARCH-RNN | ARCH-R01 |
| RFC Rule | RFC-RNN | RFC-R01 |

IDs are sequential and never reused. Superseded documents keep their IDs.

## Workflow Cheat Sheets

### Greenfield (new project/feature)

1. Write Requirements Spec (problem statement + user journeys + EARS requirements)
2. Write RFCs for foundational technical decisions (data layer, API style, auth, deploy, observability)
3. Resolve each RFC -> produce corresponding ADR(s)
4. Write Architecture Doc (synthesize ADRs into coherent design)
5. Write Interface Contracts (one per component boundary)
6. Decompose into tasks -> execute

### Brownfield (adding features to existing system)

1. Write change specification (delta against existing requirements)
2. Maybe 0-1 RFCs if new technical territory
3. ADRs for any new decisions
4. Update Architecture Doc
5. Decompose into tasks -> execute

### Bug Fix

1. Identify which FR-xxx is violated
2. Read constitution, architecture, and relevant interface contracts
3. Fix the code to match the spec
4. If the spec was wrong, write an ADR first (REQ-R13), then update the requirement
