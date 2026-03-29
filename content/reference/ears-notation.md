---
type: reference
topic: ears-notation
version: 1.0.0
source: PM Documentation Framework (Notion)
---

# EARS Notation for Functional Requirements

EARS (Easy Approach to Requirements Syntax) was developed at Rolls-Royce and provides
structured natural language patterns that are both human-readable and machine-parseable.
Kiro (AWS) uses EARS for its spec-driven workflow.

## The Five Patterns

### Ubiquitous (always active, no keyword)

```
The <system> shall <response>.
```

Example: "The API gateway shall validate authentication tokens on every request."

### Event-driven (triggered by something)

```
When <trigger>, the <system> shall <response>.
```

Example: "When a user submits a payment, the billing service shall generate an idempotency key."

### State-driven (active while condition holds)

```
While <precondition>, the <system> shall <response>.
```

Example: "While the circuit breaker is open, the service shall return cached responses."

### Optional feature (applies only when feature present)

```
Where <feature>, the <system> shall <response>.
```

Example: "Where SSO is enabled, the login page shall redirect to the IdP."

### Unwanted behavior (error/fault handling)

```
If <condition>, then the <system> shall <response>.
```

Example: "If the database connection pool is exhausted, then the service shall return HTTP 503."

## Complex (combined patterns)

```
While <precondition>, when <trigger>, the <system> shall <response>.
```

Example: "While the system is in maintenance mode, when a write request arrives,
the API shall return HTTP 503 with a Retry-After header."

## Where EARS Fits in the Doc Hierarchy

EARS is NOT the top-level PM document. It's one layer below.

```
Level 1: Problem Statement + User Journeys + Success Measures
         (Product-focused, narrative, "why" and "what outcome")
         Written in natural language prose. This is what stakeholders review.

         | decomposes into

Level 2: Functional Requirements (EARS notation)
         (Behavior-focused, structured, "what the system shall do")
         Each requirement = one EARS sentence with a unique ID.

         | alongside

Level 2: Non-Functional Requirements (quantified statements)
         (Quality-focused, measurable, "how well it must perform")
         Each NFR has a measurable acceptance criterion.

         | both feed into

Level 3: Acceptance Criteria / Test Scenarios (Given/When/Then)
         (Verification-focused, executable, "how we prove it works")
         Maps 1:many from requirements to test cases.
```

### Example Decomposition

- **User Journey** (Level 1): "As a fleet manager, I need to see which vehicles are
  approaching maintenance thresholds so I can schedule service proactively."

- **EARS Requirements** (Level 2), decomposed from that journey:
  - FR-041: When a vehicle's mileage exceeds 90% of its maintenance interval, the system
    shall display a warning indicator on the fleet dashboard.
  - FR-042: While a maintenance warning is active, when the fleet manager selects the
    vehicle, the system shall display recommended service actions with estimated costs.
  - FR-043: If a vehicle exceeds its maintenance interval without a scheduled service,
    then the system shall escalate the alert to the fleet manager's supervisor.

- **Test Scenarios** (Level 3), decomposed from FR-041:
  - Given a vehicle at 89% of maintenance interval, When dashboard loads, Then no warning
    indicator is shown.
  - Given a vehicle at 91% of maintenance interval, When dashboard loads, Then warning
    indicator is displayed with amber styling.
