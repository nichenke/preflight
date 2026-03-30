# Preflight — project spec rules

## Before writing code

Read these files in order — skip any that don't exist:

1. `specs/constitution.md` — overrides everything
2. `specs/requirements.md` — EARS requirements with FR/NFR IDs
3. `specs/architecture.md` — system structure, patterns, components
4. `specs/interfaces/` — contracts at boundaries you're touching

Check `specs/decisions/adrs/` only when modifying requirements or architecture
— ADR decisions should already be reflected in those docs.

## Requirements change governance

No behavioral requirement change without an ADR. If a change to requirements.md
would cause an agent to generate different code, it needs an ADR first.
Clarifications, typo fixes, and added failure modes do not.

## EARS quick reference

| Pattern | Keyword | Template |
|---------|---------|----------|
| Ubiquitous | (none) | The <system> shall <response>. |
| Event-driven | **When** | When <trigger>, the <system> shall <response>. |
| State-driven | **While** | While <precondition>, the <system> shall <response>. |
| Optional | **Where** | Where <feature>, the <system> shall <response>. |
| Unwanted | **If/then** | If <condition>, then the <system> shall <response>. |
| Complex | Combined | While <pre>, when <trigger>, the <system> shall <response>. |

## Document IDs

Assign unique IDs: FR-NNN, NFR-NNN, ADR-NNN, RFC-NNN, CONST-{CAT}-NN.
IDs are sequential and never reused.
