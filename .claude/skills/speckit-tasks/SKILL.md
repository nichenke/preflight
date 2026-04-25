---
name: speckit-tasks
description: Break down implementation plans into actionable task lists.
compatibility: Requires spec-kit project structure with .specify/ directory
metadata:
  author: github-spec-kit
  source: preflight-project-local
user-invocable: true
disable-model-invocation: true
---

# Speckit Tasks Skill

# /speckit.tasks — preflight project-local override

When working inside the preflight repo, this skill replaces spec-kit's default `/speckit.tasks` behavior with PAI delegation. It is a project-local Claude Code skill (under `.claude/skills/`), not part of the preset preflight ships to end users — preflight's preset declares only doc-type templates per ADR-009 criterion #3.

In this project, task decomposition is delegated to **PAI Algorithm**. PAI reads `plan.md` directly during its OBSERVE phase, decomposes the plan's acceptance section into atomic ISC (Ideal State Criteria), and tracks progress in its own PRD. `tasks.md` is redundant and would drift from PAI's ground truth.

## What to do instead

1. Confirm the active feature has a `plan.md` under `specs/<NNN-feature>/`
2. Invoke PAI Algorithm (or equivalent host-agent task decomposer) with `plan.md` as input
3. Let PAI produce ISC criteria and execute them

## If you need a placeholder `tasks.md`

`/speckit.implement`'s core command will error if `tasks.md` is missing (hard prerequisite in `.specify/scripts/bash/check-prerequisites.sh`). The companion `speckit-implement` project-local skill also delegates to PAI, so that check is bypassed when `/speckit.implement` is invoked here. But if another tool in your stack expects `tasks.md` to exist, create a one-line pointer:

```
echo "# PAI owns task decomposition — see plan.md acceptance" > specs/<NNN-feature>/tasks.md
```

## Why this override exists

See `docs/analysis/2026-04-13-composable-architecture.md` and ADR-007 in the preflight repo. The composable architecture deliberately separates "what to build" (spec.md + plan.md) from "how to decompose work" (PAI's OBSERVE phase), because PAI's atomic-ISC decomposition is more granular and verifiable than `tasks.md`'s typed task list. This skill applies only when working inside the preflight repo; downstream projects using preflight's preset get spec-kit's default `/speckit.tasks` behavior.
