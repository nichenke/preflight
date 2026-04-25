---
name: speckit-implement
description: Execute all tasks from the task breakdown to build the feature.
compatibility: Requires spec-kit project structure with .specify/ directory
metadata:
  author: github-spec-kit
  source: preflight-project-local
user-invocable: true
disable-model-invocation: true
---

# Speckit Implement Skill

# /speckit.implement — preflight project-local override

When working inside the preflight repo, this skill replaces spec-kit's default `/speckit.implement` behavior with PAI delegation. It is a project-local Claude Code skill (under `.claude/skills/`), not part of the preset preflight ships to end users — preflight's preset declares only doc-type templates per ADR-009 criterion #3.

In this project, implementation is delegated to **PAI Algorithm**, which consumes `plan.md` directly without requiring a separate `tasks.md`.

## What to do

1. Confirm the active feature has a `plan.md` under `specs/<NNN-feature>/`
2. Invoke PAI Algorithm against that `plan.md`
3. PAI will:
   - OBSERVE — decompose the plan's acceptance section into atomic ISC criteria
   - THINK — pressure-test assumptions and add failure-mode criteria
   - PLAN — confirm approach
   - BUILD / EXECUTE — perform the work, marking each criterion `[x]` as it passes
   - VERIFY — evidence for each criterion
   - LEARN — reflect and close
4. When PAI's PRD shows all criteria passed, the feature is ready for ratification (`/speckit.archive` or equivalent per ADR-007)

## Why no tasks.md

The companion `speckit-tasks` project-local skill delegates `/speckit.tasks` to PAI as well. PAI's ISC criteria are more atomic and more verifiable than `tasks.md`'s typed task list, and maintaining two task representations creates drift.

## If the core `/speckit.implement` is invoked by habit

The core command's prerequisite check (`check-prerequisites.sh --require-tasks`) will fail if `tasks.md` is missing. Either:
- Run PAI Algorithm directly (recommended)
- Or create a one-line pointer `tasks.md` per the guidance in `/speckit.tasks`, then invoke the core `/speckit.implement` — though that bypasses the intent of these project-local skills

This skill applies only when working inside the preflight repo; downstream projects using preflight's preset get spec-kit's default `/speckit.implement` behavior.
