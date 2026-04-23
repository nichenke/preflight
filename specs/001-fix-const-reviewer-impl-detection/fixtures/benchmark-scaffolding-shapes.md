# Scaffolding-shapes benchmark fixture — feature 001, SC-003

**Purpose**: exercise CONST-R04's property test against the three scaffolding shapes not covered by the issue #13 benchmark (`benchmark-issue-13.md`). Without this fixture, a reviewer regression that silently narrowed detection to function/file/directory/env/CLI shapes would pass SC-001 and SC-002 while failing the rule's broader 8-shape claim.

To test property-test *generalization* rather than exemplar recognition, the principles below do not reuse the rule file's exemplar sentences verbatim.

**Expected result**: 3 `CONST-R04` findings — one per principle.

## Durability

- [CONST-PERSIST-01] All durable state SHALL be persisted to PostgreSQL.

## Transport headers

- [CONST-SER-01] All outbound request bodies SHALL include `Content-Type: application/json` in the header line.

## Versioning

- [CONST-VER-01] All public APIs SHALL follow SemVer 2.0.0.
