---
type: template
doc_type: adr
version: 1.0.0
source: PM Documentation Framework (Notion)
---

<!-- MADR 4.0 format — preferred over Nygard for explicit options analysis -->

---
status: [Proposed | Accepted | Deprecated | Superseded by ADR-xxx]
date: YYYY-MM-DD
deciders: [list of names/roles]
consulted: [list of names/roles asked for input]
informed: [list of names/roles who need to know]
---

# ADR-NNN: [Short Imperative Verb Phrase]

## Context and Problem Statement

[Describe the forces at play. What technical, business, or organizational
situation motivates this decision? What specific problem must be resolved?
Write as if speaking to a future developer who has zero context.]

## Decision Drivers

- [Driver 1: e.g., "Must support 10K concurrent writes per second"]
- [Driver 2: e.g., "Team has deep PostgreSQL expertise, limited Kafka experience"]
- [Driver 3: e.g., "Audit trail is a regulatory requirement"]

## Considered Options

1. [Option A]
2. [Option B]
3. [Option C]

## Decision Outcome

Chosen option: "[Option B]", because [justification referencing
decision drivers].

### Consequences

- Good, because [positive consequence]
- Good, because [positive consequence]
- Bad, because [negative consequence / accepted tradeoff]
- Neutral, because [neither good nor bad, but worth noting]

### Confirmation

[How will we know this decision is working? What metrics, reviews,
or checkpoints will validate it? When will we revisit?]

## Pros and Cons of the Options

### [Option A]

[Brief description or example]

- Good, because [argument]
- Bad, because [argument]

### [Option B]

[Brief description or example]

- Good, because [argument]
- Good, because [argument]
- Bad, because [argument]

### [Option C]

[Brief description or example]

- Good, because [argument]
- Bad, because [argument]

## More Information

[Links to RFCs, requirements, related ADRs, spikes, benchmarks,
external references. Keep this section for evidence, not opinions.]

<!--
Y-Statement Quick Format (for lightweight decisions):

In the context of <use case>, facing <concern>,
we decided for <option> and against <rejected options>,
to achieve <quality goal>, accepting <tradeoff>,
because <rationale>.
-->
