# PM Doc Framework Review — Subagent Prompt

## Usage

Give this prompt to Claude Code. It will run as a deep-think review of the
framework's rule set, looking for redundancy, over-specification, severity
misalignment, and opportunities to simplify without losing coverage.

```
Run this as a thorough review. Think deeply before proposing changes.
Read every rules file and the full framework doc before starting analysis.
```

---

## The Prompt

```
You are a senior staff engineer reviewing a PM documentation framework
before it ships as a team standard. The framework has 84 machine-checkable
rules across 7 document types. Your job is to review these rules the way
you'd review a PR: find what's redundant, over-engineered, missing, or
at the wrong severity level.

Read ALL of the following files:
- specs/_rules/requirements-rules.md
- specs/_rules/adr-rules.md
- specs/_rules/architecture-rules.md
- specs/_rules/rfc-rules.md
- specs/_rules/constitution-rules.md
- specs/_rules/universal-rules.md
- specs/_rules/cross-doc-rules.md

If those files don't exist yet, read the full framework source at
specs/_reference/ or the monolithic pm-doc-framework.md.

Then produce a review with these sections:

## 1. Redundancy Analysis

Find rules that say the same thing in different words, or rules where
one is a strict superset of another.

For each redundant pair/group:
- Which rules overlap
- Which one to keep (the more precise one)
- Which to drop or merge
- Confidence: [High/Medium/Low]

## 2. Severity Calibration

Review every Error-severity rule. Errors should be reserved for things
that would cause an agent to produce WRONG output or violate a
governance boundary. Ask for each Error rule:

- If this rule is violated, does the agent produce incorrect code?
- Or does it just produce less-than-ideal documentation?

If the answer is "less-than-ideal docs," downgrade to Warning.

Similarly, review Warning rules. If a Warning violation would actually
cause agent execution failures, upgrade to Error.

Produce a table:
| Rule ID | Current | Proposed | Rationale |

## 3. Rules That Should Be Merged

Some rules are better expressed as a single rule with sub-criteria
than as separate rules. For example, if there are 3 rules about
"requirements shall have IDs" that each say slightly different things
about ID format, merge them.

For each merge candidate:
- Rules to merge
- Proposed merged rule text
- New ID

## 4. Rules That Should Be Dropped

Be aggressive here. For each drop candidate:
- Rule ID
- Why it should go
- What (if anything) is lost

Categories to look for:
- Rules that are common sense for any competent agent/author
- Rules that duplicate what YAML frontmatter validation already catches
- Rules that are too prescriptive about style rather than substance
- "Info" severity rules that nobody will ever check
- Rules that constrain the framework more than they help users

## 5. Missing Rules

After cutting, are there gaps? Things the framework SHOULD check
but doesn't? Be specific:
- What the rule would catch
- Which doc type it applies to
- Proposed severity

## 6. Proposed Simplified Rule Set

After all the above analysis, produce the COMPLETE proposed rule set
organized by doc type. Include:
- Final rule ID
- Rule text (rewritten for clarity if needed)
- Severity

Target: reduce from 84 rules to 40-50 without losing meaningful
coverage. If you can't get below 60, explain which rules you
considered cutting but couldn't justify dropping.

## 7. CLAUDE.md Impact

If rules are renumbered or dropped, what changes in CLAUDE.md?
List the specific sections that need updating.

---

Ground rules for this review:

- Don't be polite about cutting rules. The framework is better with
  fewer, sharper rules than with comprehensive but ignored ones.

- Prefer rules that an agent can mechanically check (grep for pattern,
  count occurrences, validate cross-references) over rules that require
  judgment ("shall be concrete" is hard to check; "shall reference at
  least one FR/NFR ID" is easy to check).

- Every Error-severity rule should be something that, if violated,
  would cause a downstream agent to produce wrong code or make a
  wrong decision. If the violation only affects documentation quality,
  it's a Warning at most.

- Universal rules (UNIV-XX) should be truly universal — if a rule
  only matters for some doc types, move it to that doc type's rules.

- Cross-doc rules (XDOC-XX) are the highest-value rules because they
  catch consistency failures between documents. Be reluctant to cut
  these. Add more if gaps exist.

- The constitution rules (CONST-XX) and cross-doc traceability
  (CONST-X0X) are new and may be over-engineered since the
  constitution hasn't been battle-tested yet. Flag any that feel
  premature.

- Consider whether some rules are better expressed as anti-patterns
  (in prose, for humans) rather than as formal numbered rules (for
  automated checking). Not everything needs an ID.
```

---

## After the Review

Take the subagent's output and:

1. Read the proposed simplified rule set
2. For each proposed cut/merge, decide if you agree
3. Update the rules files and Notion pages
4. Update CLAUDE.md if rule IDs changed
5. Update the framework doc's rule tables
6. Commit with: "refactor: simplify framework rules from 84 to N"

The goal isn't a specific number — it's removing rules that don't
earn their keep while keeping rules that prevent real agent failures.
