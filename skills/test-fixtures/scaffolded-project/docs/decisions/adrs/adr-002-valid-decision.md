---
status: Accepted
date: 2026-03-15
deciders: [backend-team, platform-team]
consulted: [frontend-team]
informed: [all-engineers]
type: adr
version: 1.0.0
owner: backend-team
---

# ADR-002: Use PostgreSQL for Primary Data Store

## Context and Problem Statement

The analytics pipeline currently uses MongoDB for all storage. As query complexity grows — especially for cross-document aggregations and reporting — performance degrades and the team is writing increasingly complex aggregation pipelines. We need to choose a primary relational data store that supports our analytics and operational workloads.

## Decision Drivers

- Analytics queries require complex joins and window functions
- ACID compliance required for financial transaction records (regulatory)
- Team has strong SQL expertise; MongoDB aggregation pipeline experience is limited
- Must support horizontal read scaling via replicas

## Considered Options

1. PostgreSQL
2. MySQL
3. Continue with MongoDB

## Decision Outcome

Chosen option: **PostgreSQL**, because it satisfies all decision drivers — strongest analytics query support, full ACID compliance, and best fit for team expertise.

### Consequences

- Good, because complex analytics queries become straightforward SQL
- Good, because ACID guarantees satisfy regulatory requirements without application-level workarounds
- Bad, because requires data migration from MongoDB (estimated 2-sprint effort)
- Neutral, because team training on PostgreSQL-specific features (JSONB, window functions) needed

### Confirmation

- Migration complete with zero data loss (verified via row counts and spot-checks)
- Analytics query p95 latency < 200ms (baseline: 850ms on MongoDB)
- No regulatory findings related to transaction integrity at next audit

## Pros and Cons of the Options

### PostgreSQL

Full-featured relational database with excellent analytics support.

- Good, because window functions and CTEs handle complex reporting natively
- Good, because ACID-compliant transactions, no application-level compensation needed
- Good, because team expertise is strong
- Bad, because requires schema migration from document model

### MySQL

Popular relational alternative.

- Good, because well-understood operationally
- Bad, because weaker window function support than PostgreSQL
- Bad, because less flexible JSON support for semi-structured data

### Continue with MongoDB

Keep existing document store.

- Good, because no migration cost
- Bad, because aggregation pipeline complexity grows unboundedly with reporting needs
- Bad, because limited ACID guarantees require complex application-level workarounds

## More Information

- See NFR-002 in `docs/requirements.md` for latency targets
- Migration plan tracked in RFC-001
