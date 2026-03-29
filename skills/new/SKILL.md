---
name: new
description: Create a new spec document with guided elicitation — walks through structured questions for requirements (EARS), ADRs (MADR 4.0), RFCs, architecture, interface contracts, test strategy, or constitution, then writes the doc and runs automated review
---

# New document skill

Create a spec document by walking the user through structured elicitation, one question (or small group of related questions) at a time. Write the completed document and run an automated review.

## 0. Resolve plugin root

Run the following Bash command to verify `${CLAUDE_PLUGIN_ROOT}` is set:

```bash
echo "$CLAUDE_PLUGIN_ROOT"
```

If the output is empty or the variable is unset, stop and tell the user: "CLAUDE_PLUGIN_ROOT is not set. This skill requires the preflight plugin to be installed in Claude Code."

## 1. Resolve docs directory

Read `.preflight/config.yml` and extract `docs_dir`. Default to `docs/` if the file is missing or `docs_dir` is absent.

## 2. Select document type

If the user provided a doc type as an argument (e.g., `/preflight new adr`), use it directly.

If no type was provided, present these choices and ask the user to pick one:

1. **requirements** — EARS functional and non-functional requirements
2. **adr** — Architecture Decision Record (MADR 4.0)
3. **rfc** — Request for Comments / pre-decision exploration
4. **architecture** — System architecture and design (arc42/C4)
5. **interface-contract** — Contract at a component boundary
6. **test-strategy** — Test pyramid, acceptance criteria mapping, environments
7. **constitution** — Non-negotiable engineering principles

Wait for the user's selection before proceeding.

## 3. Determine target filename

### Singletons

These doc types have a fixed path — one file per project:

| Type | Path |
|------|------|
| requirements | `{docs_dir}/requirements.md` |
| architecture | `{docs_dir}/architecture.md` |
| constitution | `{docs_dir}/constitution.md` |
| test-strategy | `{docs_dir}/test-strategy.md` |

### Sequential (ADR, RFC)

1. Use Glob to scan `{docs_dir}/decisions/adrs/adr-*.md` (or `rfcs/rfc-*.md`). The directory may not exist yet — if Glob returns no results, treat that as "no files exist" and start at ID 1. Section 7.3 creates the directory with `mkdir -p` before writing.
2. Parse filenames to find the highest existing ID number. If no files exist, start at 1.
3. Increment by 1 to get the next ID.
4. Ask the user for a short slug (lowercase-hyphenated, e.g., "use-postgres").
5. Produce filename: `{docs_dir}/decisions/adrs/adr-{NNN}-{slug}.md` or `{docs_dir}/decisions/rfcs/rfc-{NNN}-{slug}.md` where NNN is zero-padded to 3 digits.

### Named (interface-contract)

1. Ask the user for the boundary name (e.g., "api-gateway-auth-service").
2. Produce filename: `{docs_dir}/interfaces/{name}.md`

### Collision check

If the target file already exists, tell the user and ask how to proceed:
- **Overwrite** the existing file
- **Pick a new name** (re-prompt for slug or boundary name)
- **Cancel**

Wait for the user's decision before proceeding.

## 4. Load the template

Read the template from `${CLAUDE_PLUGIN_ROOT}/content/templates/{type}-template.md`. Use it to understand the target document structure — do NOT paste the template verbatim. The elicitation flow below builds the document section by section from the user's answers.

## 5. Elicitation flows

For every doc type: ask **one question or small group of related questions at a time**. Wait for the user's answer before moving to the next section. Build the document incrementally. Adapt follow-up questions based on earlier answers.

---

### 5.1 Requirements elicitation

**Step 1 — Problem statement:**
Ask: "What problem does this project/feature solve? Describe it from the user's perspective — what pain point, opportunity, or strategic need drives it?"

**Step 2 — Personas:**
Ask: "Who are the users or affected parties? For each, give a brief description: role, goals, pain points, and technical sophistication."

**Step 3 — User journeys:**
For each persona (or key workflow), ask:
- "Walk me through the primary workflow. What triggers it? What steps does the user take? What does success look like?"
- After the happy path, ask: "What can go wrong? What failure modes should the system handle, and how?"
Capture each journey with: Trigger, Steps, Success Outcome, Failure Modes.

**Step 4 — Functional requirements:**
Review the journeys and extract behavioral requirements. For each, guide the user to express it using an EARS pattern:
- **Event-driven:** "When [trigger], the system shall [response]."
- **State-driven:** "While [precondition], the system shall [response]."
- **Optional:** "Where [feature is included], the system shall [response]."
- **Unwanted:** "If [condition], then the system shall [response]."
- **Ubiquitous:** "The system shall [response]." (no keyword — always true)
- **Complex:** combine While + When for preconditioned events.

Assign sequential IDs starting from FR-001. If `{docs_dir}/requirements.md` already exists, read it first and find the highest existing FR-NNN — new IDs must continue that sequence (e.g., if FR-023 is the highest, start new IDs at FR-024). Present each requirement back to the user for confirmation before moving on.

After the initial set, ask: "Are there additional functional requirements we haven't covered?"

**Step 5 — Non-functional requirements:**
Ask: "What are the quality attributes this system must meet? Think about: performance (latency, throughput), availability, security, scalability, observability, accessibility, compliance."

For each NFR, guide the user to provide a **quantitative, measurable criterion** — not vague goals. Assign NFR-NNN IDs sequentially.

**Step 6 — Constraints:**
Ask: "What hard boundaries exist that can't be negotiated? Consider: technology mandates, integration requirements, budget/timeline/team constraints, regulatory/compliance requirements, backward compatibility commitments."

**Step 7 — Assumptions:**
Ask: "What are you assuming to be true that, if wrong, would change these requirements? For each assumption, how would you validate it?"

**Step 8 — Success measures:**
Ask: "How will you know this project succeeded? For each metric, provide: baseline (current state), target, measurement method, and when you'll measure."

**Step 9 — Out of scope:**
Ask: "What are you explicitly NOT doing, and why? Calling these out prevents scope creep."

---

### 5.2 ADR elicitation

**Step 1 — Context and problem statement:**
Ask: "What situation or problem is forcing this decision? Write as if explaining to a future developer who has zero context about the project."

**Step 2 — Decision drivers:**
Ask: "What factors matter most in making this decision? List the key drivers — technical constraints, team expertise, performance requirements, regulatory needs, etc."

**Step 3 — Options:**
Ask: "What options are you considering? Describe at least 2." For each option:
- "Give a brief description of this approach."
- "What are the pros?"
- "What are the cons?"

If the user provides only one option, prompt: "A good ADR needs at least 2 options to show alternatives were considered. What else was on the table, even if it was quickly dismissed?"

**Step 4 — Decision outcome:**
Ask: "Which option did you choose, and why? Reference the decision drivers from earlier."
Then: "What are the consequences — good, bad, and neutral?"

**Step 5 — Confirmation criteria:**
Ask: "How will you know this decision is working? What metrics, reviews, or checkpoints will you use to validate it? When will you revisit?"

---

### 5.3 RFC elicitation

**Step 1 — Executive summary:**
Ask: "In 2-3 sentences, what are you proposing and why? A busy reviewer should be able to read only this and know whether they need to read the full RFC."

**Step 2 — Problem statement:**
Ask: "What's broken, missing, or suboptimal today? Include measurable evidence if available — specific metrics, error rates, user complaints, not vague statements."

**Step 3 — Scope:**
Ask: "What's in scope for this RFC? And equally important — what's explicitly out of scope? For each exclusion, briefly explain why."

**Step 4 — Proposed solution:**
Ask: "Describe your proposed approach in detail. Include architecture changes, data model changes, API surface changes, or sequence flows as appropriate."

**Step 5 — Alternatives:**
Ask: "What alternatives did you consider? For each, describe the approach, its pros and cons, and under what circumstances you'd reconsider it."

Require at least 1 alternative. If none provided, prompt: "What other approaches were discussed or considered, even briefly?"

**Step 6 — Migration and rollout:**
Ask: "How do you get from the current state to the proposed state? Consider: phases, feature flags, backward compatibility, data migration. What's the rollback plan if it goes wrong?"

**Step 7 — Risks:**
Ask: "What are the known risks? For each: describe it, rate likelihood (Low/Medium/High) and impact (Low/Medium/High), and state the mitigation approach."

**Step 8 — Success criteria:**
Ask: "How will you know this worked? Define specific, measurable targets and when you'll measure them."

---

### 5.4 Architecture elicitation

**Step 1 — Requirements overview:**
Ask: "Summarize the key requirements this architecture must satisfy. Reference the requirements doc if one exists — don't duplicate, just link and summarize the top items."

**Step 2 — System context (C4 Level 1):**
Ask: "What external systems, users, and services interact with this system? For each, describe: who/what it is, the protocol/format used, and the direction of data flow."

**Step 3 — Solution strategy:**
Ask: "What is the high-level architectural approach? What key technology choices drive the design? What patterns are you employing and why? Reference any ADRs."

**Step 4 — Building blocks (C4 Level 2):**
Ask: "What are the major components or services? For each, describe: its responsibility, the technology it uses, and who owns it."

For each component, follow up: "How does this component interact with the others? What are the key interfaces between them?"

**Step 5 — Quality and constraints:**
Ask: "What are the top quality goals (from NFRs) and how does this architecture achieve them? What technical and organizational constraints shaped the design?"

---

### 5.5 Interface contract elicitation

**Step 1 — Protocol and transport:**
Ask: "What protocol does this interface use? (HTTP/REST, gRPC, async messaging, etc.) What data format? (JSON, Protobuf, Avro, etc.) What authentication mechanism?"

**Step 2 — Endpoints or operations:**
Ask: "List each endpoint, event, or message. For each, describe: name/path, method/direction, request schema (types, required/optional fields, validation), response schema (types, error codes), and provide an example request/response."

Walk through endpoints one at a time if there are multiple.

**Step 3 — SLA:**
Ask: "What are the quality-of-service targets? Consider: availability, latency targets (p50, p95, p99), rate limits, retry policy, timeout recommendations."

**Step 4 — Error handling contract:**
Ask: "What is the error code taxonomy? Which operations are retry-safe? What circuit breaker behavior do you recommend for consumers?"

---

### 5.6 Test strategy elicitation

**Step 1 — Test pyramid levels:**
Ask: "Walk me through each level of your test pyramid. For each level (unit, integration, contract, E2E, performance, chaos/resilience): what's the coverage target, what framework/tooling, and who owns it?"

**Step 2 — Acceptance criteria mapping:**
Ask: "Which requirements (FR-NNN, NFR-NNN) map to which test types? What's the automation status of each?"

If a requirements doc exists at `{docs_dir}/requirements.md`, read it and help the user map requirements to test types.

**Step 3 — Test environments:**
Ask: "What test environments exist? How do they differ from production? What's the data seeding approach? How do you detect environment drift?"

---

### 5.7 Constitution elicitation

**Step 1 — Preamble:**
Ask: "What is this constitution for? Who does it apply to? What authority does it carry? (Typically: all agents, all features, all code must comply. Amendments require an ADR.)"

**Step 2 — Categories:**
Ask: "What categories of principles do you want to define? Common categories include: Code Standards, Testing, Security, Observability, API Design, Data, Documentation. But define whatever fits your project."

**Step 3 — Principles:**
For each category the user defines, ask: "What are the non-negotiable principles for {category}?"

Guide each principle to be:
- **Imperative** — a clear command, not a suggestion
- **Testable** — you can verify whether code/process complies
- Assigned a `CONST-{CAT}-NN` ID where `{CAT}` is a short category abbreviation

After all categories, ask: "Any principles that don't fit neatly into a category, or cross-cutting concerns?"

---

## 6. ADR impact propagation

After writing an ADR (and only for ADRs), run an impact propagation step per FR-023.

### 6.1 Identify downstream docs

Check for the existence of each of these files:
- `{docs_dir}/requirements.md`
- `{docs_dir}/architecture.md`
- `{docs_dir}/constitution.md`
- All files in `{docs_dir}/interfaces/` (use Glob: `{docs_dir}/interfaces/*.md`)

Read each file that exists.

### 6.2 Analyze impact

For each existing downstream doc, analyze the ADR's decision and consequences against that doc's content. Identify:
- New functional requirements (FR-NNN) implied by the decision
- New non-functional requirements (NFR-NNN) implied by the decision
- Architecture changes needed (new components, changed interactions, updated patterns)
- Interface contract changes needed (new endpoints, modified schemas, SLA changes)
- Constitution implications (does the decision align with existing principles? does it suggest a new one?)
- Constraint additions or modifications

### 6.3 Present propagation plan

Present the proposed changes to the user as a structured list, grouped by target document:

```
## Impact propagation from ADR-NNN

### requirements.md
- Add FR-025: When [trigger from ADR], the system shall [response].
- Modify NFR-003: Update latency target from 200ms to 500ms (consequence of choosing Option B).

### architecture.md
- Add new component: [name] in Building Block View section 5.1.
- Update Solution Strategy to reference ADR-NNN.

### interfaces/api-gateway.md
- No changes needed.

### constitution.md
- No changes needed.

### Untraced consequences
- [Consequence from ADR that doesn't map to any existing doc — flag for user awareness]
```

Ask: "Which of these changes should I apply?"

### 6.4 Apply approved changes

For each change the user approves:
1. Read the target document.
2. Apply the change in the appropriate section, maintaining existing formatting and ID sequences.
3. Write the updated document.

For new FR/NFR IDs, continue the sequence from the highest existing ID in that document.

### 6.5 Flag untraced consequences

Any ADR consequence that cannot be mapped to an existing downstream document should be reported to the user with a note: "This consequence is not reflected in any downstream doc. Consider whether it needs a new document or an update to an existing one."

## 7. Write the document

### 7.1 Populate frontmatter

Set YAML frontmatter fields:
- `status: Draft`
- `date:` today's date (YYYY-MM-DD)
- `owner:` ask the user, or infer from conversation context
- `version: 0.1.0`
- `type:` the doc type

For ADRs, also set:
- `deciders:` ask the user
- `consulted:` ask or leave empty
- `informed:` ask or leave empty

For RFCs, also set:
- `author:` same as owner

### 7.2 Assemble the document

Build the document from the elicitation answers, following the template's section structure. Use the exact heading hierarchy from the template. Fill in content from the user's answers. Mark any sections the user skipped or deferred as `TBD — [owner]`.

### 7.3 Write the file

Create parent directories with `mkdir -p` if they don't exist. Write the assembled document to the target path determined in step 3.

Report the file path to the user.

## 8. Post-creation review

After writing the document, run an automated review using rules from the **plugin source** (not the project copy, which may be stale).

### 8.1 Load rules

Read from `${CLAUDE_PLUGIN_ROOT}/content/rules-source/`:

**Always load:**
- `universal-rules.md`

**Load type-specific rules if the file exists:**

| Doc type | Rules file |
|----------|-----------|
| requirements | `requirements-rules.md` |
| adr | `adr-rules.md` |
| rfc | `rfc-rules.md` |
| architecture | `architecture-rules.md` |
| constitution | `constitution-rules.md` |
| interface-contract | (none — universal rules only) |
| test-strategy | (none — universal rules only) |

**Conditionally load cross-doc rules:**
- Use Grep to search the newly written document for ID reference patterns: `FR-\d`, `NFR-\d`, `ADR-\d`, `CONST-[A-Z]`
- If any matches are found, also read `cross-doc-rules.md`

### 8.2 Evaluate and fix

Evaluate the newly written document against all loaded rules.

- **Error-severity findings:** auto-fix them in the document immediately. Write the corrected file. Report what was fixed.
- **Warning-severity findings:** report them to the user with the rule ID and a specific fix suggestion. Do not auto-fix warnings — let the user decide.

### 8.3 Report

```
## Post-creation review: {filename}

### Auto-fixed (Errors)
- {Rule ID}: {what was fixed}

### Warnings (user action needed)
- {Rule ID}: {what's wrong} — {fix suggestion}

### Result: N auto-fixed, M warnings
```

If no findings at all, report: "Post-creation review: PASS — no findings."
