---
type: rules
applies_to: cross-document
version: 2.0.0
source: PM Documentation Framework (Notion)
---

# Cross-Document Consistency Rules

| Rule ID | Rule | Severity |
|---------|------|----------|
| XDOC-01 | Every ADR referenced in Architecture Doc SHALL exist in decisions/adrs/ | Error |
| XDOC-02 | Every requirement ID referenced in Architecture Doc SHALL exist in requirements.md | Error |
| XDOC-03 | Accepted RFCs SHALL have corresponding ADR(s) | Warning |
| XDOC-04 | Superseded ADRs SHALL have a successor ADR that exists (no circular chains) | Error |
| XDOC-05 | Interface contracts SHALL reference components that exist in the Architecture Doc | Warning |
| XDOC-06 | Test strategy requirement mappings SHALL reference valid requirement IDs | Warning |
| XDOC-07 | ADRs that conflict with a constitution principle SHALL include a constitution amendment | Error |
| XDOC-08 | Architecture doc Crosscutting Concepts SHALL be consistent with constitution principles | Warning |
| XDOC-09 | Every FR/NFR in requirements.md SHALL be referenced by at least one architecture component, test, or ADR | Warning |
