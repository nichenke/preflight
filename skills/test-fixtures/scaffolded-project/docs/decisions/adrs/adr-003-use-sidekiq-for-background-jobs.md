---
status: Accepted
date: 2026-03-29
deciders: [backend-team]
consulted: []
informed: []
type: adr
version: 1.0.0
owner: backend-team
---

# ADR-003: Use Sidekiq for Background Jobs

## Context and Problem Statement

Jobs currently run inline within the request cycle. Heavy operations cause request timeouts, degrading reliability and user experience. A background job processing solution is needed to decouple job execution from the request lifecycle.

## Decision Drivers

- Reliability — jobs must complete without request timeout constraints
- Observability — job status, retries, and failures must be visible
- Team familiarity — backend team has existing Redis knowledge
- Operational simplicity — minimize new moving parts and failure modes

## Considered Options

1. Sidekiq (Redis-backed queue)
2. GoodJob (database-backed queue)

## Decision Outcome

Chosen option: **Sidekiq**, because it provides proven reliability, strong observability tooling, and aligns with the team's existing Redis expertise without introducing an unfamiliar operational model.

### Consequences

- Good, because Sidekiq's retry semantics, dead job queues, and Web UI provide strong observability out of the box
- Good, because team familiarity with Redis reduces operational risk and onboarding friction
- Good, because Sidekiq's performance characteristics are well-understood at scale
- Bad, because Redis becomes a required infrastructure dependency
- Neutral, because Redis may already be present for other uses (caching, sessions); verify before treating this as a net-new dependency

### Confirmation

Measure after first month of production use: job timeout rate drops to zero; failed job detection and retry occurs within alerting SLOs.

## Pros and Cons of the Options

### Sidekiq (Redis-backed)

Redis-backed queue with mature retry, scheduling, and visibility tooling.

- Good, because battle-tested reliability with predictable failure modes
- Good, because built-in Web UI for job monitoring and dead-queue inspection
- Good, because team already operates Redis — no new runbook or on-call ramp
- Bad, because Redis is an additional infrastructure dependency if not already present

### GoodJob (database-backed)

PostgreSQL-backed queue with no additional infrastructure.

- Good, because no extra infrastructure — uses the existing database
- Good, because simpler deployment topology
- Bad, because higher database load under job volume; competes with OLTP queries for connections and I/O
- Bad, because observability tooling is less mature than Sidekiq's

## More Information

Redis infrastructure provisioning and Sidekiq configuration are implementation concerns outside the scope of this decision.
