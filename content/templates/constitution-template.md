---
type: template
doc_type: constitution
version: 1.0.0
source: PM Documentation Framework (Notion)
---

<!-- The constitution is the highest-authority document in the framework.
     It defines invariant engineering principles that apply to all features,
     all agents, and all time. If a requirement conflicts with the constitution,
     the constitution wins. If an ADR proposes something that violates a
     constitution principle, the ADR must first amend the constitution.

     Reference: GitHub Spec Kit's /speckit.constitution command implements
     similar governance with semantic versioning and amendment processes. -->

---
status: [Draft | Ratified | Amended (see ADR-xxx)]
version: [semver]
date: YYYY-MM-DD
ratified_by: [list of names/roles who approved]
last_amended: YYYY-MM-DD
amendment_adrs: [ADR-xxx, ADR-yyy]
---

# Engineering Constitution

## Preamble
One paragraph: what this document is, who it applies to, and
what authority it carries. Example:

"This constitution defines non-negotiable engineering principles
for [org/team/project]. All agents, all features, and all code
must comply. Amendments require an ADR with explicit ratification."

## Code Standards
- [CONST-CS-01] [principle]
- [CONST-CS-02] [principle]

## Testing
- [CONST-TEST-01] [principle]
- [CONST-TEST-02] [principle]

## Security
- [CONST-SEC-01] [principle]
- [CONST-SEC-02] [principle]

## Observability
- [CONST-OBS-01] [principle]
- [CONST-OBS-02] [principle]

## API Design
- [CONST-API-01] [principle]
- [CONST-API-02] [principle]

## Data
- [CONST-DATA-01] [principle]
- [CONST-DATA-02] [principle]

## Documentation & Process
- [CONST-DOC-01] All behavioral requirement changes require an ADR (REQ-R07)
- [CONST-DOC-02] ADRs use MADR 4.0 format
- [CONST-DOC-03] All constitution amendments require an ADR with ratification

## Amendment Log
| Version | Date | ADR | Change Summary |
|---------|------|-----|----------------|
| 1.0.0 | YYYY-MM-DD | ADR-001 | Initial ratification |

<!--
Status Lifecycle:

  Draft ----> Ratified ----> Amended (produces new version)
                                |
                                +-- via ADR with explicit ratification

Amendment Process:
1. Write an ADR proposing the change (title: "ADR-NNN: Amend Constitution CONST-{ID}")
2. Ratification: ADR must be approved by designated ratifiers in frontmatter
3. Update the constitution: increment version, add to Amendment Log
4. Cascade check: review downstream docs for conflicts

Requires amendment: adding/removing/changing a principle, changing scope/authority
Does NOT require amendment: typos, examples, reorganizing categories
-->
