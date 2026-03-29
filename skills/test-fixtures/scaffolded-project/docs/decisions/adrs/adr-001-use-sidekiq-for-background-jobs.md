---
status: Proposed
date: 2026-03-29
owner: backend-team
version: 0.1.0
type: adr
deciders: backend-team, platform-team
consulted: frontend-team
informed: all-engineers
---

# ADR-001: Use Sidekiq for Background Job Processing

## Context and Problem Statement

Background jobs currently run inline within the request lifecycle. Heavy operations cause request timeouts, degrading user experience and risking data loss when the process is interrupted mid-job. We need to move job execution out of the request cycle into a reliable, observable async processing system.

## Decision Drivers

- Reliability: jobs must not be lost on crash or restart
- Observability: job status must be inspectable at any point
- Team familiarity: the team has deep Redis expertise
- Operational simplicity: minimize new infrastructure complexity

## Considered Options

1. Sidekiq (Redis-backed queue)
2. GoodJob (database-backed queue using PostgreSQL)

## Decision Outcome

Chosen option: "Sidekiq (Redis-backed queue)", because reliability and observability requirements are best met by a proven, battle-tested queue with strong retry semantics and a built-in UI. The operational cost of Redis is acceptable because we already run Redis in production.

### Consequences

- Good, because reliable async job execution with automatic retries reduces job loss risk
- Good, because existing Redis instance is reused — no net-new infrastructure required
- Bad, because Redis uptime becomes a dependency for job processing availability
- Neutral, because the team will need training on Sidekiq-specific patterns and conventions

### Confirmation

Zero dropped jobs in the first 30 days post-migration. Job queue depth monitored via a Grafana alert on queue lag. Review at the 30-day mark; revisit this decision if Redis availability falls below 99.9% or queue depth alerts fire more than twice per week.

## Pros and Cons of the Options

### Sidekiq (Redis-backed queue)

Redis-backed job queue with Sidekiq worker processes. Jobs are serialized to Redis and processed by Sidekiq workers independently of the web process.

- Good, because the team has proven Redis and Sidekiq expertise — reduced onboarding friction
- Good, because battle-tested at scale with extensive retry, scheduling, and dead-job tooling
- Good, because Sidekiq Web UI provides built-in job status visibility
- Bad, because requires Redis as an operational dependency for job processing

### GoodJob (database-backed queue using PostgreSQL)

PostgreSQL-backed job queue using the existing database. No additional infrastructure required.

- Good, because no extra infrastructure — uses existing PostgreSQL instance
- Good, because transactional job enqueueing — jobs and application state committed atomically
- Bad, because increases load on the primary database under high job throughput
- Bad, because less battle-tested than Sidekiq at high job volumes

## More Information

- Decision driven by inline-job timeout incidents in production
- Redis already operates as part of the platform (session cache, rate limiting)
- Sidekiq Pro license to be evaluated if priority queues or batch jobs become a requirement
