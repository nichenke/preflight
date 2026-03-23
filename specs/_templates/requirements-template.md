---
type: template
doc_type: requirements
version: 1.0.0
source: PM Documentation Framework (Notion)
---

# [Project/Feature Name] — Requirements Specification

## Meta
- Version: [semver]
- Status: [Draft | In Review | Approved | Superseded by REQ-xxx]
- Owner: [name]
- Stakeholders: [list]
- Last Updated: [date]

## 1. Problem Statement
Why this work exists. What pain point, opportunity, or strategic need
drives it. Written from the user/business perspective, not engineering.

## 2. Users & Personas
Who is affected. For each persona: role, goals, pain points,
technical sophistication level.

## 3. User Journeys / Jobs to Be Done
For each key workflow:
- Trigger: What initiates the journey
- Steps: Numbered sequence of user actions and system responses
- Success Outcome: What "done" looks like from the user's perspective
- Failure Modes: What can go wrong and expected system behavior

## 4. Functional Requirements
Individual behavioral requirements using EARS notation (see below).
Each requirement gets a unique ID (FR-001, FR-002...).

## 5. Non-Functional Requirements
Performance, scalability, security, availability, observability,
accessibility, compliance. Each gets a unique ID (NFR-001...)
and a measurable acceptance criterion.

## 6. Constraints
Hard boundaries that cannot be negotiated:
- Technical: must run on X, must integrate with Y
- Organizational: budget, timeline, team capacity
- Regulatory: compliance requirements, data residency
- Existing commitments: backward compatibility, migration paths

## 7. Assumptions
Things believed to be true that, if wrong, would change the
requirements. Each assumption should have a validation plan.

## 8. Success Measures
Quantitative metrics that determine if the project achieved its goals.
For each metric: baseline, target, measurement method, timeline.

## 9. Out of Scope
Explicitly called out to prevent scope creep. "We are NOT doing X
because Y."

## 10. Open Questions
Unresolved items that need answers before implementation can proceed.
Each has an owner and a target resolution date.

## 11. Appendices
Wireframes, data models, research findings, competitive analysis.
