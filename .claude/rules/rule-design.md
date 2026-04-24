# Rule and pattern design — research before building

Before proposing or changing a preflight rule, reviewer agent prompt, or
framework pattern, research how comparable frameworks already solve the
problem. The goal is not to copy — it is to avoid re-inventing shapes
that peer frameworks have already solved, and to notice when a design
is fighting a tension that has already been dissolved elsewhere.

## Reference frameworks

Current set: spec-kit, BMAD, GSD, Superpowers, OpenSpec, Gas Town.

Clone each to `cache/repos/<name>/` for code-level analysis — READMEs
are not enough. When research is complete, findings remain in `cache/`;
do not commit cloned repos.

## Research pattern

- Dispatch one agent per framework in parallel. Agents covering 3+
  frameworks produce shallow results.
- Ask a specific research question tied to the actual tension (not
  "how does X work"). Example: "how does X express 'no implementation
  details' without requiring strict enumeration?"
- Require each agent to return 2–3 concrete patterns with file paths +
  line references, plus a 1-paragraph translation to our problem.
- Synthesize the cross-framework convergence before committing to a
  design. Look for the shape that multiple frameworks land on
  independently — that is usually the right axis.

## When to run it

- Any new preflight rule or rule-design change
- Any reviewer or agent-prompt revision that changes reviewer behavior
- Any spec FR that mirrors a known framework concern (quality gates,
  review rubrics, requirement granularity, artifact shapes)
- Any time a reviewer is bouncing between "too loose" and "too strict"
  — that tension is usually solved in peer work

Skip only for pure bug fixes with no design choice involved.
