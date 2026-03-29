---
type: reference
topic: doc-taxonomy
version: 1.0.0
source: PM Documentation Framework (Notion)
---

# Document Taxonomy — The Full Set

| Document | Owner | Purpose | When Created | Mutability |
|----------|-------|---------|--------------|------------|
| **Requirements Spec** | Product/PM | What to build and why — outcomes, user journeys, success measures, constraints | Before any design work | Living — evolves with discovery |
| **Architecture & Design Doc** | Architect/Lead | How to build it — system structure, component design, technology choices | After requirements stabilize | Living — versioned with ADRs |
| **ADR (Architecture Decision Record)** | Anyone proposing a decision | Why a specific choice was made — rationale, alternatives, consequences | At each significant decision point | Immutable once accepted (superseded, never edited) |
| **RFC / Design Proposal** | Engineer proposing a change | Pre-decision exploration — "here's what I think we should do, convince me I'm wrong" | Before an ADR exists | Draft -> Accepted/Rejected -> spawns ADR(s) |
| **Interface Contract** | Owning team | Formal API/event/data boundaries — the "handshake" between components | During architecture phase | Versioned with breaking change policy |
| **Test Strategy** | QE/SRE/Dev | How we verify the system meets requirements — levels, automation approach, coverage targets | Parallel to architecture | Living — updated with scope changes |
| **Glossary / Domain Model** | Product + Engineering | Shared vocabulary and entity relationships — the ubiquitous language | Day one, maintained forever | Living |

## Why These Six (Plus Glossary) and Not Just Three

The **RFC** fills a critical gap: it's the *deliberation* artifact. Requirements say what,
architecture says how, ADRs record why — but none of them capture the *exploration* phase
where options are being weighed. Without RFCs, the reasoning behind the options listed in
ADRs is lost.

**Interface Contracts** are what prevent the "works on my machine" problem at system
boundaries. For AI agents especially, explicit contracts (schemas, error codes, SLAs) are
essential because agents can't infer implicit agreements.

**Test Strategy** exists because requirements define *what* success looks like, but not
*how we verify it*. An AI agent building code needs to know what testing framework to use,
what coverage targets to hit, and what acceptance criteria look like in executable form.

## Updated Document Taxonomy (with gaps filled)

| Document | Owner | Purpose | When |
|----------|-------|---------|------|
| **Constitution / Engineering Principles** | Team/Org Lead | Invariant rules that apply everywhere, always | Day zero, rarely changes |
| **Requirements Spec** | Product/PM | What + why — outcomes, journeys, EARS requirements | Before design |
| **UX Specification** (optional) | Design/Frontend Lead | Interaction design, component specs, design system refs | Parallel to requirements |
| **Architecture & Design Doc** | Architect/Lead | How — system structure, patterns, technology choices | After requirements |
| **ADR** | Decision maker | Why this choice — rationale, alternatives, consequences | At each decision point |
| **RFC / Design Proposal** | Proposer | Pre-decision exploration — weigh options, get feedback | Before ADRs |
| **Interface Contract** | Owning team | API/event/data boundaries between components | During architecture |
| **Test Strategy** | QE/SRE/Dev | How we verify — levels, frameworks, coverage targets | Parallel to architecture |
| **Task / Story Files** | PM/Tech Lead | Decomposed work units with acceptance criteria | Before implementation |
| **Glossary / Domain Model** | Product + Engineering | Shared vocabulary, entity relationships | Day one, maintained always |
