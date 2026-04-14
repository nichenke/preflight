---
type: template
doc_type: test-strategy
version: 1.0.0
source: PM Documentation Framework (Notion)
---

# Test Strategy: [Project/Feature Name]

## Testing Pyramid / Trophy
- Unit: coverage target, framework, ownership
- Integration: scope, environment needs
- Contract: consumer-driven contract testing approach
- E2E: critical paths only, environment
- Performance: load targets, tooling
- Chaos/Resilience: failure injection approach

## Acceptance Criteria Mapping
| Requirement ID | Test Type | Automation Status | Owner |
|---------------|-----------|-------------------|-------|

## Environment Strategy
What environments exist, how they differ from prod,
data seeding approach.

## CI/CD Integration
When tests run, what blocks a merge, what blocks a deploy.

## Observability in Test
How do we detect test environment drift from prod?
