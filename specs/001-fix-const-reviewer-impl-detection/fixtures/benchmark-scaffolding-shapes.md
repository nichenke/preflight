# Scaffolding-shapes benchmark fixture — feature 001, SC-003

**Purpose**: exercise CONST-R04's property test against the three scaffolding shapes not covered by the issue #13 benchmark (`benchmark-issue-13.md`). Without this fixture, a reviewer regression that silently narrowed detection to function/file/directory/env/CLI shapes would pass SC-001 and SC-002 while failing the rule's broader 8-shape claim.

**Expected result**: 3 `CONST-R04` findings — one per principle.

## Durability

- [CONST-PERSIST-01] All durable state SHALL be persisted to PostgreSQL.

## Serialization

- [CONST-SER-01] All outbound messages SHALL be serialized with `JSON.stringify` before transport.

## Decisions

- [CONST-DEC-01] All ADRs SHALL use MADR 4.0 templates.
