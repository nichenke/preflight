---
type: reference
topic: frameworks-and-tools
version: 1.0.0
source: PM Documentation Framework (Notion)
---

# Frameworks & Tools Reference

## Requirements

- **EARS**: The go-to notation for structured NL requirements. Used by Kiro (AWS).
- **Volere**: More comprehensive requirements shell (40+ sections), good for regulated environments.
- **Jobs to Be Done (JTBD)**: Complementary framework for understanding user motivation.
- **Kiro**: AWS's SDD IDE — auto-generates EARS requirements from natural language prompts.

## ADRs

- **MADR 4.0**: Current best practice. GitHub: adr/madr. Markdown-native with pros/cons analysis.
- **Nygard Original**: Minimal 4-section format. Good for lightweight decisions.
- **Y-Statements**: One-sentence format for very simple decisions.
- **adr-tools** (Nat Pryce): CLI for managing ADR files.
- **Log4Brains**: Web-based ADR viewer.

## Architecture

- **arc42**: 12-section template. The most widely adopted structure. Tool-agnostic, available in Markdown/AsciiDoc/Confluence.
- **C4 Model** (Simon Brown): 4-level diagramming approach (Context -> Container -> Component -> Code). Notation-independent.
- **Structurizr**: DSL for defining C4 models as code, exportable to PlantUML/Mermaid.
- **ISO/IEC/IEEE 42010:2011**: The formal international standard for architecture descriptions. arc42 is a practical implementation of its principles.

## SDD Tooling (for execution pipeline)

- **GitHub Spec Kit**: SDD scaffolding — spec -> plan -> tasks -> implement. Works with Claude Code, Copilot, Gemini CLI.
- **Kiro (AWS)**: Full IDE with built-in EARS requirements -> design -> tasks pipeline.
- **OpenSpec (OPSX)**: Spec format and tooling for agent-driven development.
- **BMAD Method**: Requirements -> architecture -> implementation flow with review gates.

## Meta

- **Pragmatic Engineer RFC Collection**: Gergely Orosz's survey of RFC/design doc practices at 50+ companies.
- **Martin Fowler / Birgitta Bockeler's SDD Analysis**: Critical evaluation of SDD tools (Spec Kit, Kiro, Tessl) with practical findings on agent compliance issues.
