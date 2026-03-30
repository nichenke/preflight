---
description: "Spec-driven development — scaffold project structure, create new spec docs, or review existing docs"
arguments:
  - name: action
    description: "Action to perform: scaffold, new, or review"
    required: true
---

Dispatch to the appropriate preflight skill based on `$action`.

- `scaffold` → invoke the `preflight:scaffold` skill
- `new` → invoke the `preflight:new` skill
- `review` → invoke the `preflight:review` skill

If `$action` is not one of the above, respond:

```
Unknown action: $action
Usage: /preflight scaffold | new | review
```
