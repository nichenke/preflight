---
type: reference
topic: adoption-order
version: 1.0.0
source: PM Documentation Framework (Notion)
---

# Getting Started — Recommended Adoption Order

1. **Start with Requirements + ADRs**. These give you the highest leverage. Requirements
   tell agents what to build; ADRs prevent them from relitigating decisions.

2. **Add Architecture Doc** once you have enough ADRs to reference. The arc42 structure
   gives you a scaffold — fill sections 1, 3, 4, and 5 first, expand from there.

3. **Add Interface Contracts** when you have multi-component systems. These prevent
   integration failures that are the #1 source of agent-generated bugs.

4. **Add RFCs** when your team or scope grows to the point where decisions need
   deliberation before commitment.

5. **Add Test Strategy** to close the verification gap — agents need to know what testing
   looks like.

6. **Maintain the Glossary** from day one. It's low effort and prevents the most insidious
   class of bugs: terms that mean different things to different people (or agents).
