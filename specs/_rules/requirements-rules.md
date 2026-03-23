---
type: rules
applies_to: requirements
version: 1.0.0
source: PM Documentation Framework (Notion)
---

# Requirements Specification — Content Rules

| Rule ID | Rule | Severity |
|---------|------|----------|
| REQ-R01 | Every functional requirement SHALL use EARS notation | Error |
| REQ-R02 | Every requirement SHALL have a unique, stable ID | Error |
| REQ-R03 | Requirements SHALL NOT prescribe implementation ("use Redis", "deploy to K8s") | Error |
| REQ-R04 | Every NFR SHALL have a quantitative acceptance criterion | Error |
| REQ-R05 | No requirement SHALL use vague terms: "fast", "easy", "intuitive", "seamless", "robust" without quantification | Warning |
| REQ-R06 | Each user journey SHALL have at least one failure mode documented | Warning |
| REQ-R07 | Success measures SHALL include baseline, target, and measurement method | Warning |
| REQ-R08 | Out of Scope section SHALL NOT be empty | Warning |
| REQ-R09 | Every assumption SHALL have a validation plan | Info |
| REQ-R10 | Requirements SHALL NOT contain implementation-specific UI copy (use intent, not exact strings) unless the copy is itself a requirement | Info |
| REQ-R11 | Cross-references to other requirements SHALL use the requirement ID, not prose descriptions | Warning |
| REQ-R12 | The Problem Statement SHALL NOT exceed 500 words | Info |
| REQ-R13 | Any change to requirements.md that alters system behavior, scope, or quantitative targets SHALL be accompanied by an ADR documenting the change rationale | Error |
| REQ-R14 | The ADR for a requirements change SHALL reference affected FR/NFR IDs and list downstream documents needing updates (architecture, interfaces, test strategy) | Warning |

## Requirements Change Governance

**No behavioral requirement change without an ADR.** Any modification to requirements.md that alters system behavior, scope, or quantitative targets must first have an ADR that documents why the requirement changed, what alternatives were considered, and which downstream artifacts are affected.

**Changes that REQUIRE an ADR:**
- Adding a new FR or NFR (expanding scope)
- Removing a FR or NFR (cutting scope)
- Changing a requirement's behavior (affects architecture, interfaces, or tests)
- Changing an NFR's quantitative target (e.g., p99 latency 200ms -> 100ms)
- Moving a requirement between in-scope and out-of-scope

**Changes that DON'T require an ADR:**
- Clarifying wording without changing behavior
- Fixing EARS notation (e.g., adding a missing trigger keyword)
- Adding a failure mode to an existing journey
- Correcting typos or improving readability
- Adding an assumption or open question

**The test:** If the change would cause an agent to generate different code, it needs an ADR. If it only makes existing intent clearer, it doesn't.

## Anti-Patterns to Flag

- **Solution masquerading as requirement**: "The system shall use PostgreSQL" (that's a constraint or an ADR, not a requirement)
- **Compound requirements**: One ID covering multiple behaviors — split them
- **Passive voice without actor**: "The data shall be encrypted" — by whom? at rest? in transit?
- **Missing trigger**: "The system shall send a notification" — when? to whom?
- **Untestable language**: "The system should generally try to..." — remove hedging
- **Silent scope changes**: Editing requirements without an ADR — if behavior changes, the rationale must be recorded (REQ-R13)
