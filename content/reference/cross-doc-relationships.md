---
type: reference
topic: cross-doc-relationships
version: 1.0.0
source: PM Documentation Framework (Notion)
---

# Cross-Document Relationships

Understanding how these documents reference each other is critical for both humans
and AI agents:

```
Problem Space                    Solution Space                Decision Space
-------------                    --------------                --------------

Requirements Spec ----------------> Architecture Doc <-------- ADRs
  (what & why)          informs     (how)          records      (why this way)
       |                               |                           ^
       |                               |                           |
       v                               v                      RFC / Proposal
  Test Strategy            Interface Contracts              (exploration)
  (how we verify)          (boundaries)
       |                               |
       +-------------------------------+
                    both trace back to
                    requirement IDs
```

## Traceability Rules

- Every component in the Architecture Doc SHALL trace to at least one requirement
- Every ADR SHALL reference the requirement(s) or architectural concern it addresses
- Every test in the Test Strategy SHALL map to a requirement ID
- Interface Contracts SHALL reference the Architecture Doc components they connect
- RFCs SHALL reference the requirements they aim to satisfy
