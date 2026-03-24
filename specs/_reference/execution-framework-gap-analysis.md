---
type: reference
topic: execution-framework-gap-analysis
version: 1.0.0
source: PM Documentation Framework (Notion)
---

# Execution Framework Gap Analysis

The major SDD execution frameworks each define their own artifact chains. Here's what
each one asks for, mapped against our framework.

## Framework Artifact Map

| Artifact Need | Our Framework | BMAD v6 | Spec Kit (GitHub) | OpenSpec (OPSX) | Kiro (AWS) |
|---------------|---------------|---------|-------------------|-----------------|------------|
| Project Brief / Problem Statement | Requirements S1-2 | Analyst -> Project Brief | (input to /specify) | (input to /opsx:propose) | NL prompt |
| PRD / Requirements | Requirements Spec | PM -> PRD (FRs, NFRs, Epics, Stories) | /specify -> spec.md | proposal.md + specs/ | EARS requirements + acceptance criteria |
| UX / Frontend Spec | *Gap* | UX Designer -> UX_Design.md | Within spec.md | Within specs/ | -- |
| Architecture / System Design | Architecture & Design Doc | Architect -> ARCHITECTURE.md | /plan -> plan.md | design.md | Auto-generated arch + design |
| Data Model / Schema | Interface Contracts (partial) | Architect -> db-schema.md | /plan -> data-model.md | Within design.md | Within design phase |
| API / Interface Contracts | Interface Contracts | Architect -> API design | /plan -> contracts/ folder | Within specs/ | Within design phase |
| Research / Alternatives | RFC + ADR options analysis | Analyst research phase | /plan -> research.md | /opsx:explore | -- |
| Decision Records | ADRs (MADR) | Implicit in arch doc | research.md uses Decision/Rationale/Alternatives format | Archived proposals | -- |
| Constitution / Invariant Rules | Constitution (Section 16) | AGENTS.md + checklists | constitution.md | config.yaml context + rules | Steering files |
| Epic/Story Breakdown | *Gap* | SM -> hyper-detailed story files | /tasks -> tasks.md | tasks.md | Sequenced task plan |
| Task Decomposition | *Gap (structure undefined)* | Developer -> per-story branches | Individual task files | tasks.md checkboxes | Discrete dependency-sequenced tasks |
| Test Strategy | Test Strategy | QA Agent + Test Architect | constitution.md (TDD mandate) + quickstart.md | config.yaml rules | -- |
| Validation Scenarios | Test Strategy (partial) | QA Agent UAT | quickstart.md (key validation scenarios) | /opsx:verify | -- |
| Glossary | Glossary | -- | -- | -- | -- |
| Delta / Change Specs | *Gap* | -- | -- | Delta specs (ADDED/MODIFIED/REMOVED sections) | -- |
| Rollback Plan | RFC S-Migration | -- | -- | config.yaml rules (optional) | -- |

## Identified Gaps

### ~~Gap 1: Constitution / Engineering Principles~~ — RESOLVED

Resolved by Section 16: Constitution / Engineering Principles. Template, rules (CONST-R01
through R06), change governance with ADR-gated amendments, and cross-doc traceability
(XDOC-07, XDOC-08) are now part of the framework.

### Gap 2: UX / Frontend Specification
BMAD has an explicit UX Designer agent producing `UX_Design.md`. Our framework captures
user journeys in Requirements S3 but doesn't have a space for component layouts,
interaction patterns, or design system references.

**Recommendation**: Add an optional UX Specification as a companion to the Architecture Doc.

### Gap 3: Task / Story Template
Every execution framework has task decomposition. We mention a `tasks/` folder but don't
define the structure of a task file.

**Recommendation**: Add a Task / Story Template. Each task should contain: unique ID,
parent requirement ID(s), acceptance criteria (Given/When/Then), technical scope, dependencies,
and definition of done.

### Gap 4: Delta / Change Specifications (Brownfield)
OpenSpec has delta specs that express ADDED, MODIFIED, and REMOVED requirements relative
to the existing baseline.

**Recommendation**: Add a Change Specification pattern for brownfield work.
