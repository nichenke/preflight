---
type: requirements
---

# Project Requirements

## 1. Functional Requirements

- FR-001: The system shall accept user input through a web form.
- FR-002: The system shall validate email addresses before submission.
- The system should send a confirmation email after signup.
- Users can reset their password via the settings page.
- FR-005: When a user submits invalid data, the system shall display an error message within 2 seconds.

## 2. Non-Functional Requirements

- NFR-001: The system shall be fast.
- NFR-002: The system shall be secure.
- NFR-003: The system shall have good uptime.
- NFR-004: The system shall support at least 1000 concurrent users with p95 response time under 200ms.

## 3. Constraints

- The system must run on AWS infrastructure.
- Budget is limited so we should keep costs low.
