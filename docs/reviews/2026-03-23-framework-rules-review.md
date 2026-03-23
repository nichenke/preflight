---
date: 2026-03-23
reviewer: Claude Opus 4.6 (subagent)
scope: All 7 rule files (84 rules total)
outcome: Proposed reduction to 48 rules
---

# PM Doc Framework Rules Review

## 1. Redundancy Analysis

### Pair 1: UNIV-05 / REQ-R05 — Vague adjectives
- UNIV-05 already applies to all doc types. REQ-R05 is a strict subset.
- **Keep**: UNIV-05. **Drop**: REQ-R05.
- Confidence: **High**

### Pair 2: UNIV-03 / REQ-R11 / RFC-R11 — Cross-references use IDs not prose
- All three say "use IDs, not prose." UNIV-03 covers this universally.
- **Keep**: UNIV-03. **Drop**: REQ-R11 and RFC-R11.
- Confidence: **High**

### Pair 3: CONST-X02 / XDOC-07 — ADRs conflicting with constitution need amendment
- XDOC-07 literally cites CONST-X02 as its source. Straight duplicate.
- **Keep**: XDOC-07 (canonical location for cross-doc checks). **Drop**: CONST-X02.
- Confidence: **High**

### Pair 4: CONST-X04 / XDOC-08 — Architecture crosscutting consistent with constitution
- Same situation. Literal duplicate.
- **Keep**: XDOC-08. **Drop**: CONST-X04.
- Confidence: **High**

### Pair 5: CONST-R07 / XDOC-09 — Amendments need ADR in log
- Same check at Error and Warning severity in different files.
- **Keep**: CONST-R07 at Error (governance boundary). **Drop**: XDOC-09.
- Confidence: **High**

### Pair 6: ADR-R06 / RFC-R02 — Alternatives required
- Different doc types, both needed, but language is inconsistent. Not a redundancy to fix, but wording should harmonize.
- Confidence: **Medium** — keep both, align wording.

### Pair 7: UNIV-01 / UNIV-02 / UNIV-06 — Status rules overlap
- Status appears in three rules. UNIV-01 and UNIV-02 both require status in different locations (frontmatter vs Meta section).
- **Recommendation**: Merge UNIV-01 and UNIV-02 into one rule about required metadata. Keep UNIV-06 folded in.
- Confidence: **Medium**

### Pair 8: REQ-R13 / REQ-R14 — Requirements change governance
- REQ-R14 is a sub-criterion of REQ-R13. Merge into one rule.
- Confidence: **High**

### Pair 9: ADR-R03 / XDOC-04 — Superseded ADRs reference successor
- XDOC-04 is ADR-R03 plus an existence check. Strictly stronger.
- **Keep**: XDOC-04. **Drop**: ADR-R03.
- Confidence: **High**

## 2. Severity Calibration

| Rule ID | Current | Proposed | Rationale |
|---------|---------|----------|-----------|
| ADR-R01 | Error | Warning | Bad title doesn't cause wrong decisions. Style issue. |
| ADR-R02 | Error | Error | Status enum is machine-parsed. Keep. |
| ADR-R06 | Error | Warning | Missing second option produces weaker ADR, not wrong code. |
| ADR-R10 | Error | Warning | Compound decisions are messy, not incorrect. |
| ADR-R11 | Error | Warning | Non-sequential numbers are an annoyance, not a correctness issue. |
| ARCH-R01 | Error | Error | Missing protocol/format means agent guesses at integration code. |
| ARCH-R02 | Error | Warning | Missing responsibility is a doc quality issue, not agent failure. |
| ARCH-R09 | Error | Warning | Unrationalized tech choices are sloppy but choice is still stated. |
| REQ-R01 | Error | Warning | Non-EARS requirements are still understandable by agents. |
| REQ-R02 | Error | Error | Missing IDs break all cross-referencing. |
| REQ-R03 | Error | Error | "Use Redis" as requirement constrains architecture incorrectly. |
| REQ-R04 | Error | Warning | Missing quantitative criteria = untestable, not wrong. |
| REQ-R13 | Error | Error | Governance boundary. |
| RFC-R02 | Error | Warning | Missing alternatives weaken RFC, don't cause wrong output. |
| RFC-R05 | Error | Error | No ADR from accepted RFC = decisions invisible to agents. |
| RFC-R13 | Error | Warning | Incomplete documentation, not correctness hazard. |
| CONST-R01 | Error | Error | Principle IDs are referenced by other docs. |
| CONST-R02 | Error | Error | Status enum is machine-parsed. |
| CONST-R03 | Error | Warning | Missing ratifiers is governance gap, not agent correctness. |
| CONST-R07 | Error | Error | Governance boundary violation. |
| CONST-X02/XDOC-07 | Error | Error | Constitution conflict without amendment. |
| UNIV-01 | Error | Error | Missing frontmatter breaks automated processing. |
| UNIV-02 | Error | Warning | Belt-and-suspenders with UNIV-01. Merge. |
| UNIV-06 | Error | Error | Invalid status breaks workflow automation. |
| XDOC-01 | Error | Error | Dangling ADR reference. |
| XDOC-02 | Error | Error | Dangling requirement reference. |
| XDOC-04 | Error | Error | Dangling supersession chain. |

**Summary**: 11 rules downgraded Error -> Warning. Zero upgrades.

## 3. Rules That Should Be Merged

### Merge 1: UNIV-01 + UNIV-02 + UNIV-06 + UNIV-07 -> UNIV-01
> **UNIV-01**: Document SHALL have YAML frontmatter with: status (from defined enum), date (ISO 8601), owner, and version. (Error)

### Merge 2: REQ-R13 + REQ-R14 -> REQ-R07
> **REQ-R07**: Any change to requirements.md that alters system behavior, scope, or quantitative targets SHALL be accompanied by an ADR that references affected FR/NFR IDs and lists downstream documents needing updates. (Error)

### Merge 3: ADR-R04 + ADR-R05 -> ADR-R02
> **ADR-R02**: Context SHALL be value-neutral (no advocacy); Decision SHALL use active voice ("We will..."). (Warning)

### Merge 4: CONST-R04 + CONST-R09 -> CONST-R03
> **CONST-R03**: Each principle SHALL be a single, testable imperative statement ("All services MUST..."), not a paragraph of guidance or aspiration. (Warning)

## 4. Rules That Should Be Dropped

| Rule ID | Why Drop | What's Lost |
|---------|----------|-------------|
| REQ-R05 | Duplicate of UNIV-05 | Nothing |
| REQ-R09 | Info, aspirational | Minor thoroughness |
| REQ-R10 | Info, narrow, subjective | Almost nothing |
| REQ-R11 | Duplicate of UNIV-03 | Nothing |
| REQ-R12 | Arbitrary word count, Info | Nothing |
| ADR-R03 | Subsumed by XDOC-04 | Nothing |
| ADR-R11 | Filesystem hygiene, not content rule | Minimal |
| ADR-R12 | ~2 pages is not checkable | Nothing |
| ADR-R13 | Info, rarely followed | Minor |
| RFC-R06 | Info, git history covers this | Nothing |
| RFC-R08 | Info, over-engineered | Minor |
| RFC-R10 | Info, belongs in review tool | Nothing |
| RFC-R11 | Duplicate of UNIV-03 | Nothing |
| CONST-R03(old) | Premature, ratifiers enforcement | Governance gap |
| CONST-R08 | Style, not checkable | Nothing |
| CONST-R10 | Info, uncheckable | Nothing |
| CONST-X01 | Info, aspirational SHOULD | Very minor |
| CONST-X02 | Duplicate of XDOC-07 | Nothing |
| CONST-X03 | Info, uncheckable | Nothing |
| CONST-X04 | Duplicate of XDOC-08 | Nothing |
| CONST-X05 | Vague, not checkable | Minor |
| XDOC-09 | Duplicate of CONST-R07 | Nothing |
| UNIV-07 | Schema concern, not content rule | Nothing |

**Total drops: 21 rules** (plus 2 merged away)

## 5. Missing Rules

| What It Would Catch | Doc Type | Proposed Severity |
|---------------------|----------|-------------------|
| Orphaned requirements: FR/NFR IDs never referenced by arch, test, or ADR | XDOC | Warning |
| Circular ADR supersession chains | XDOC | Error |
| RFC accepted but status field not updated | RFC | Warning |
| Architecture component with no interface contract | XDOC | Warning |
| Requirement ID reuse after deletion | REQ | Error |

## 6. Proposed Simplified Rule Set

### Universal (UNIV) — 5 rules

| ID | Rule | Severity |
|----|------|----------|
| UNIV-01 | Document SHALL have YAML frontmatter with: status (from defined enum), date (ISO 8601), owner, and version | Error |
| UNIV-02 | All cross-references SHALL use document/requirement IDs, not page numbers or prose | Warning |
| UNIV-03 | No section SHALL be entirely empty without a "TBD" marker and owner | Warning |
| UNIV-04 | Vague adjectives (fast, easy, simple, robust, scalable) SHALL be accompanied by quantification | Warning |
| UNIV-05 | Document SHALL NOT contain TODO/FIXME/HACK without an assigned owner | Warning |

### Requirements (REQ) — 7 rules

| ID | Rule | Severity |
|----|------|----------|
| REQ-R01 | Every functional requirement SHALL use EARS notation | Warning |
| REQ-R02 | Every requirement SHALL have a unique, stable ID that is never reused | Error |
| REQ-R03 | Requirements SHALL NOT prescribe implementation ("use Redis", "deploy to K8s") | Error |
| REQ-R04 | Every NFR SHALL have a quantitative acceptance criterion | Warning |
| REQ-R05 | Each user journey SHALL have at least one failure mode documented | Warning |
| REQ-R06 | Success measures SHALL include baseline, target, and measurement method | Warning |
| REQ-R07 | Any change to requirements.md that alters system behavior, scope, or quantitative targets SHALL be accompanied by an ADR that references affected FR/NFR IDs and lists downstream documents needing updates | Error |

### ADR (ADR) — 7 rules

| ID | Rule | Severity |
|----|------|----------|
| ADR-R01 | Status SHALL be one of: Proposed, Accepted, Deprecated, Superseded | Error |
| ADR-R02 | Context SHALL be value-neutral (no advocacy); Decision SHALL use active voice ("We will...") | Warning |
| ADR-R03 | At least two options SHALL be listed in Considered Options | Warning |
| ADR-R04 | Each option SHALL have at least one Pro and one Con | Warning |
| ADR-R05 | Consequences SHALL include at least one negative/tradeoff item | Warning |
| ADR-R06 | Decision Drivers SHALL be present and each SHALL be concrete (not "flexibility" without qualification) | Warning |
| ADR-R07 | The ADR SHALL be one decision per record — no compound decisions | Warning |

### Architecture (ARCH) — 7 rules

| ID | Rule | Severity |
|----|------|----------|
| ARCH-R01 | Every external interface in Context SHALL specify protocol and data format | Error |
| ARCH-R02 | Every component in Building Block View SHALL have a one-line responsibility statement | Warning |
| ARCH-R03 | Solution Strategy SHALL reference at least one ADR | Warning |
| ARCH-R04 | Runtime View SHALL include at least one failure scenario | Warning |
| ARCH-R05 | Deployment View SHALL specify all environments (not just prod) | Warning |
| ARCH-R06 | Quality Scenarios SHALL be traceable to NFRs in the requirements spec | Warning |
| ARCH-R07 | Crosscutting Concepts SHALL NOT be empty — at minimum cover auth, observability, and error handling | Warning |

### RFC (RFC) — 7 rules

| ID | Rule | Severity |
|----|------|----------|
| RFC-R01 | Executive Summary SHALL NOT exceed 3 sentences | Warning |
| RFC-R02 | At least one alternative SHALL be documented in Alternatives Considered | Warning |
| RFC-R03 | Scope SHALL explicitly list Out of Scope items | Warning |
| RFC-R04 | Migration/Rollout SHALL include a rollback plan | Warning |
| RFC-R05 | An accepted RFC SHALL produce at least one ADR, referenced in Meta | Error |
| RFC-R06 | Problem Statement SHALL include specific, measurable evidence | Warning |
| RFC-R07 | An RFC SHALL NOT remain In Review for more than 2 weeks without an explicit extension note | Warning |

### Constitution (CONST) — 6 rules

| ID | Rule | Severity |
|----|------|----------|
| CONST-R01 | Every principle SHALL have a unique ID in the format CONST-{CATEGORY}-NN | Error |
| CONST-R02 | Status SHALL be one of: Draft, Ratified, Amended | Error |
| CONST-R03 | Each principle SHALL be a single, testable imperative statement, not a paragraph of guidance or aspiration | Warning |
| CONST-R04 | Principles SHALL NOT prescribe specific tools or versions | Warning |
| CONST-R05 | The constitution SHALL NOT exceed 30 principles | Warning |
| CONST-R06 | Every amendment SHALL be recorded in the Amendment Log with ADR reference | Error |

### Cross-Document (XDOC) — 9 rules

| ID | Rule | Severity |
|----|------|----------|
| XDOC-01 | Every ADR referenced in Architecture Doc SHALL exist in decisions/adrs/ | Error |
| XDOC-02 | Every requirement ID referenced in Architecture Doc SHALL exist in requirements.md | Error |
| XDOC-03 | Accepted RFCs SHALL have corresponding ADR(s) | Warning |
| XDOC-04 | Superseded ADRs SHALL have a successor ADR that exists (no circular chains) | Error |
| XDOC-05 | Interface contracts SHALL reference components that exist in the Architecture Doc | Warning |
| XDOC-06 | Test strategy requirement mappings SHALL reference valid requirement IDs | Warning |
| XDOC-07 | ADRs that conflict with a constitution principle SHALL include a constitution amendment | Error |
| XDOC-08 | Architecture doc Crosscutting Concepts SHALL be consistent with constitution principles | Warning |
| XDOC-09 | Every FR/NFR in requirements.md SHALL be referenced by at least one architecture component, test, or ADR | Warning |

### Totals

| Category | Old | New |
|----------|-----|-----|
| UNIV | 8 | 5 |
| REQ | 14 | 7 |
| ADR | 13 | 7 |
| ARCH | 11 | 7 |
| RFC | 14 | 7 |
| CONST | 15 | 6 |
| XDOC | 9 | 9 |
| **Total** | **84** | **48** |

## 7. CLAUDE.md Impact

- **Review Rules Summary**: Rewrite Error and Warning lists with new IDs
- **ID Conventions**: Remove CONST-XNN row (moved to XDOC)
- **Requirements Change Governance**: REQ-R13/R14 reference -> REQ-R07
- **Workflow Cheat Sheets**: REQ-R13 reference -> REQ-R07

## Additional Observations

- **Constitution rules are premature.** Cut ratifier enforcement and category-coverage until battle-tested.
- **Unnumbered traceability bullets** in cross-doc-rules.md should be removed (covered by numbered rules or too vague).
- **Info-severity rules are dead weight.** Every Info rule was dropped or promoted. If not worth Warning, express as prose in anti-patterns.
- **Rules moved to anti-patterns**: ADR title format, diagram notation, tech rationale without ADR, empty out-of-scope, preamble scope, open question owners.
