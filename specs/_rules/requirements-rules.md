---
type: rules
applies_to: requirements
version: 2.0.0
source: PM Documentation Framework (Notion)
---

# Requirements Specification — Content Rules

| Rule ID | Rule | Severity |
|---------|------|----------|
| REQ-R01 | Every functional requirement SHALL use EARS notation | Warning |
| REQ-R02 | Every requirement SHALL have a unique, stable ID that is never reused | Error |
| REQ-R03 | Requirements SHALL NOT prescribe implementation ("use Redis", "deploy to K8s") | Error |
| REQ-R04 | Every NFR SHALL have a quantitative acceptance criterion | Warning |
| REQ-R05 | Each user journey SHALL have at least one failure mode documented | Warning |
| REQ-R06 | Success measures SHALL include baseline, target, and measurement method | Warning |
| REQ-R07 | Any change to requirements.md that alters system behavior, scope, or quantitative targets SHALL be accompanied by an ADR that references affected FR/NFR IDs and lists downstream documents needing updates | Error |

## Requirements Change Governance

**No behavioral requirement change without an ADR.** Any modification to requirements.md
that alters system behavior, scope, or quantitative targets must first have an ADR that
documents why the requirement changed, what alternatives were considered, and which
downstream artifacts are affected.

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

**The test:** If the change would cause an agent to generate different code, it needs an
ADR. If it only makes existing intent clearer, it doesn't.

## Anti-Patterns to Flag

- **Solution masquerading as requirement**: "The system shall use PostgreSQL" (that's a constraint or an ADR, not a requirement)
- **Compound requirements**: One ID covering multiple behaviors — split them
- **Passive voice without actor**: "The data shall be encrypted" — by whom? at rest? in transit?
- **Missing trigger**: "The system shall send a notification" — when? to whom?
- **Untestable language**: "The system should generally try to..." — remove hedging
- **Silent scope changes**: Editing requirements without an ADR — if behavior changes, the rationale must be recorded (REQ-R07)
- **Empty Out of Scope**: Every requirements doc should explicitly state what's excluded
