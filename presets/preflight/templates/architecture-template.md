---
type: template
doc_type: architecture
version: 1.0.0
source: PM Documentation Framework (Notion)
---

<!-- arc42-informed, SDD-optimized structure with C4 model diagrams -->

# [System Name] — Architecture & Design

## Meta
- Version: [semver]
- Status: [Draft | In Review | Approved]
- Architect: [name]
- Last Updated: [date]
- Requirements Ref: [link to requirements spec]

## 1. Introduction & Goals

### 1.1 Requirements Overview
Summary of top requirements (link to full spec, don't duplicate).

### 1.2 Quality Goals
Top 3-5 quality attributes with priority ranking (from NFRs).

### 1.3 Stakeholders
| Name/Role | Contact | Expectations/Concerns |
|-----------|---------|----------------------|

## 2. Constraints

### 2.1 Technical Constraints
Mandated technologies, platforms, compatibility requirements.

### 2.2 Organizational Constraints
Team structure, timeline, budget, skill availability.

### 2.3 Conventions
Coding standards, naming conventions, documentation requirements.

## 3. Context & Scope

### 3.1 Business Context (C4 Level 1 — System Context)
Diagram + table showing all external actors and systems.
For each external interface: protocol, data format, SLA, owner.

### 3.2 Technical Context
Network topology, deployment targets, infrastructure boundaries.

## 4. Solution Strategy
High-level approach — the "elevator pitch" for the architecture.
- Key technology decisions (with ADR references)
- Top-level decomposition approach
- Patterns employed (and why)
- Approaches to achieve quality goals

## 5. Building Block View (C4 Level 2 — Containers)

### 5.1 Level 1: System Decomposition
Diagram showing major components/services.
For each component: responsibility, technology, owner.

### 5.2 Level 2: Component Internals (as needed)
Drill into complex components (C4 Level 3 — Components).

## 6. Runtime View
Key scenarios showing how components interact:
- Happy path for primary user journeys
- Error/failure scenarios
- Startup/shutdown sequences
Use sequence diagrams or numbered step lists.

## 7. Deployment View
- Infrastructure diagram (what runs where)
- Environment topology (dev, staging, prod)
- Scaling strategy
- Disaster recovery / failover

## 8. Crosscutting Concepts
Patterns and approaches that span multiple components:
- Authentication/Authorization
- Logging/Observability
- Error handling strategy
- Data consistency approach
- Configuration management
- CI/CD approach

## 9. Architecture Decisions
Summary table linking to individual ADRs.
| ADR | Title | Status | Date |
|-----|-------|--------|------|

## 10. Quality Requirements

### 10.1 Quality Tree
Visual hierarchy of quality attributes.

### 10.2 Quality Scenarios
For each quality attribute, concrete scenarios:
- Stimulus: What happens
- Response: How the system reacts
- Measure: How we verify it

## 11. Risks & Technical Debt
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
Known technical risks, current debt items, planned remediation.

## 12. Glossary
Domain terms with precise definitions. Link to shared glossary
if one exists.

<!--
Technology Choice Format (use within Solution Strategy or ADRs):

### [Technology Choice: e.g., Message Broker Selection]

**Context**: [Why this choice matters]

**Options Evaluated**:

| Criterion | Option A | Option B | Option C |
|-----------|----------|----------|----------|
| [Criterion 1] | [Rating + notes] | ... | ... |
| Team expertise | ... | ... | ... |
| Operational cost | ... | ... | ... |
| Lock-in risk | ... | ... | ... |

**Selected**: [Option B]
**Rationale**: [Why, referencing the matrix above]
**ADR**: [Link to ADR-NNN]
-->
