---
type: reference
topic: greenfield-rfc-vs-adr
version: 1.0.0
source: PM Documentation Framework (Notion)
---

# Greenfield: ADRs vs RFCs — When to Use Which

**For greenfield, RFCs come first. ADRs are the output.**

## Decision Flow

```
New project / feature idea
         |
         v
  Write Requirements Spec
  (Product-focused: what + why)
         |
         v
  For each significant technical decision:
         |
    +----+--------------------------------+
    |                                     |
    v                                     v
  Answer is obvious?                Multiple viable options?
  (constrained by reqs,             Hard to reverse?
   org policy, or team              Affects other teams?
   capability)                      Foundational choice?
    |                                     |
    v                                     v
  Write ADR directly                Write RFC first
  (record the decision)             (explore, get feedback)
                                          |
                                          v
                                    RFC resolved ->
                                    Write ADR(s) from outcome
         |
         v
  Architecture Doc synthesizes
  all ADRs into coherent design
```

## Write an ADR directly when:

- The decision is constrained — there's no real choice to explore
- The team is small enough that deliberation happened verbally and just needs recording
- The decision is low-risk and easily reversible
- You're documenting a decision already made (retroactive capture)

## Write an RFC first when:

- Multiple viable approaches exist and tradeoffs aren't obvious
- The decision affects multiple teams or has broad blast radius
- The decision is expensive to reverse once implemented
- You need async input from people not currently involved
- It's a foundational greenfield choice (data store, messaging pattern, auth model,
  deployment topology, observability stack) that will constrain everything downstream

## Typical greenfield sequence:

1. Requirements Spec -> define what and why
2. 3-5 RFCs for foundational technical decisions (data layer, API style, auth model,
   deployment approach, observability strategy)
3. Resolve each RFC -> produce corresponding ADR(s)
4. Architecture Doc -> synthesize ADRs into coherent system design
5. Interface Contracts -> define boundaries between components
6. Task decomposition -> execute

## Typical brownfield (adding features) sequence:

1. Change Specification (delta against existing reqs)
2. Maybe 0-1 RFCs if new technical territory is involved
3. ADRs for any new decisions
4. Update Architecture Doc
5. Task decomposition -> execute

The RFC is the *conversation*. The ADR is the *verdict*. For greenfield you have many
conversations because nothing is decided yet, so RFCs dominate the early phase. For
brownfield, most foundational decisions already exist as ADRs, so you write new ADRs
directly or use delta specs against the existing baseline.
