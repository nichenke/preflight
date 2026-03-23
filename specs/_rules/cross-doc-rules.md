---
type: rules
applies_to: cross-document
version: 1.1.0
source: PM Documentation Framework (Notion)
---

# Cross-Document Consistency Rules

| Rule ID | Rule | Severity |
|---------|------|----------|
| XDOC-01 | Every ADR referenced in Architecture Doc SHALL exist in decisions/adrs/ | Error |
| XDOC-02 | Every requirement ID referenced in Architecture Doc SHALL exist in requirements.md | Error |
| XDOC-03 | Accepted RFCs SHALL have corresponding ADR(s) | Warning |
| XDOC-04 | Superseded ADRs SHALL have a successor ADR that exists | Error |
| XDOC-05 | Interface contracts SHALL reference components that exist in the Architecture Doc | Warning |
| XDOC-06 | Test strategy requirement mappings SHALL reference valid requirement IDs | Warning |
| XDOC-07 | ADRs that conflict with a constitution principle SHALL include a constitution amendment (CONST-X02) | Error |
| XDOC-08 | Architecture doc Crosscutting Concepts (S8) SHALL be consistent with constitution principles (CONST-X04) | Warning |
| XDOC-09 | Constitution amendments SHALL have a ratified ADR referenced in the Amendment Log (CONST-R07) | Warning |

## Traceability Rules

- Every component in the Architecture Doc SHALL trace to at least one requirement
- Every ADR SHALL reference the requirement(s) or architectural concern it addresses
- Every test in the Test Strategy SHALL map to a requirement ID
- Interface Contracts SHALL reference the Architecture Doc components they connect
- RFCs SHALL reference the requirements they aim to satisfy
