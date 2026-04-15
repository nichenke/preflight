---
description: Delegate task decomposition to PAI Algorithm (no tasks.md generated under this preset)
---

# /speckit.tasks — preflight preset override

This preset intentionally does not generate `tasks.md`.

Under the preflight preset, task decomposition is delegated to **PAI Algorithm**. PAI reads `plan.md` directly during its OBSERVE phase, decomposes the plan's acceptance section into atomic ISC (Ideal State Criteria), and tracks progress in its own PRD. `tasks.md` is redundant and would drift from PAI's ground truth.

## What to do instead

1. Confirm the active feature has a `plan.md` under `.specify/features/<feature>/`
2. Invoke PAI Algorithm (or equivalent host-agent task decomposer) with `plan.md` as input
3. Let PAI produce ISC criteria and execute them

## If you need a placeholder `tasks.md`

`/speckit.implement`'s core command will error if `tasks.md` is missing (hard prerequisite in `scripts/bash/check-prerequisites.sh`). Since this preset also overrides `/speckit.implement` to delegate to PAI, that check is bypassed. But if another tool in your stack expects `tasks.md` to exist, create a one-line pointer:

```
echo "# PAI owns task decomposition — see plan.md acceptance" > .specify/features/<feature>/tasks.md
```

## Why this override exists

See `docs/analysis/2026-04-13-composable-architecture.md` and ADR-007 in the preflight repo. The composable architecture deliberately separates "what to build" (spec.md + plan.md) from "how to decompose work" (PAI's OBSERVE phase), because PAI's atomic-ISC decomposition is more granular and verifiable than `tasks.md`'s typed task list.
