# spec-way

A specification-driven development workflow for software projects, implemented as a suite of [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills.

> Based on [Speckit](https://github.com/github/spec-kit), refined with real-world usage learnings.

## Overview

spec-way enforces a structured development flow where every feature starts as a natural language description and progresses through specification, planning, task generation, and implementation — with full traceability between artifacts.

```
specway.product → specway.clarify → [specway.design] → specway.tech → specway.tasks → specway.implement
                                                                                     ↘ specway.taskstoissues
```

Optional: `/specway.design` (suggested when feature has UI), `/specway.analyze` (consistency check), `/specway.checklist` (requirements quality validation).

## Changes from Speckit

spec-way introduces several improvements over the original [Speckit](https://github.com/github/spec-kit) workflow:

- **Skill-first architecture**: Everything is self-contained within `.claude/skills/` — no external directories or dependencies required
- **Design system support**: `/specway.design` creates and maintains a project-level `DESIGN.md` with visual identity, colors, typography, and component guidelines — suggested automatically when features involve UI
- **Deep discovery conversation**: `/specway.product` conducts a mandatory, multi-round discovery conversation before generating the spec — probing the user's problem, vision, users, workflows, scope, and edge cases across at least 3 iterative rounds
- **Open-ended clarification**: `/specway.clarify` uses conversational questions with suggested approaches instead of rigid multiple-choice, encouraging richer user input while still providing orientation
- **Batch spec updates**: Clarification answers are accumulated in memory and applied to the spec in a single write at the end, keeping the conversation flow uninterrupted

## Installation

### Via npx skills (recommended)

```bash
npx skills add pedrosoutom/spec-way
```

This discovers all `specway.*` skills and installs them into your project's `.claude/skills/` directory.

To install all skills at once without prompts:

```bash
npx skills add pedrosoutom/spec-way --all -y
```

### Manual

Copy the skill directories from `.claude/skills/` into your project:

```bash
git clone https://github.com/pedrosoutom/spec-way.git /tmp/spec-way
cp -r /tmp/spec-way/.claude/skills/specway.* your-project/.claude/skills/
```

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- Git

## Skills

### `/specway.init` — Project Principles

Defines non-negotiable rules and principles for the project (e.g., mandatory TDD, simplicity, observability). Acts as a constitution that all other skills validate against.

- Semantically versioned
- Enforced during planning and analysis

### `/specway.product` — Feature Specification

Transforms a natural language description into a structured specification:

- Mandatory deep discovery conversation (multi-round, at least 3 rounds) before spec generation
- Maps existing project context (CLAUDE.md, repo structure, dependencies)
- Creates a feature branch and directory structure under `specs/`
- Prioritized user stories (P1, P2, P3) with acceptance scenarios
- Testable functional requirements
- Measurable, technology-agnostic success criteria
- Automatic quality validation via checklist

### `/specway.clarify` — Ambiguity Resolution

Analyzes the spec and identifies underspecified areas:

- Up to 5 targeted questions, one at a time
- Each answer is integrated directly into the spec
- Prioritized by impact: scope > security > UX > technical details

### `/specway.design` — Design System (optional)

Creates or updates the project's `DESIGN.md` at the repository root:

- Suggested automatically when a feature involves UI/frontend
- Conversational discovery of visual identity, colors, typography, and components
- If `DESIGN.md` already exists, refines it based on the current feature's needs
- Output follows the Stitch DESIGN.md convention (readable by both humans and AI agents)
- Project-level artifact that persists across features

### `/specway.tech` — Technical Plan

Converts the spec into an implementation plan:

- **Phase 0**: Research and uncertainty resolution (`research.md`)
- **Phase 1**: Design — data model (`data-model.md`), interface contracts (`contracts/`), quickstart guide (`quickstart.md`)
- Validation against the project constitution
- Automatic AI agent context update

### `/specway.tasks` — Task Generation

Generates an executable task list from the design artifacts:

- Organized by user story for independent implementation
- Checklist format with IDs, parallelism markers `[P]`, and story labels `[US1]`
- Dependency graph and MVP suggestion
- Each task is specific enough for an LLM to execute without additional context

### `/specway.implement` — Implementation

Executes the tasks defined in `tasks.md`:

- Phase-by-phase execution respecting dependencies
- Pre-flight checklist verification
- Marks tasks as completed in the file
- Validates results against the original specification

### `/specway.analyze` — Consistency Analysis

Read-only analysis across `product.md`, `tech.md`, and `tasks.md`:

- Detects duplications, ambiguities, and coverage gaps
- Validates alignment with the constitution
- Generates a severity-labeled report (CRITICAL/HIGH/MEDIUM/LOW)
- Suggests remediation without applying changes

### `/specway.checklist` — Custom Checklists

Generates checklists that function as "unit tests for requirements":

- Validates quality, clarity, and completeness of requirements (not implementation)
- Supports domains such as UX, API, security, and performance
- Format: questions about the quality of what is written in the spec

### `/specway.taskstoissues` — Tasks to GitHub Issues

Converts tasks into GitHub issues:

- Respects dependency order
- Uses the repository remote to identify the correct target repo

## Project Structure

Each skill is self-contained with its own templates, scripts, and resources:

```
.claude/skills/
  specway.product/
    SKILL.md                          # Skill instructions
    init-options.json                 # Branch numbering config
    templates/product-template.md      # Product spec structure template
    scripts/
      common.sh                       # Shared utilities (single source of truth)
      create-new-feature.sh           # Branch + directory creation
  specway.tech/
    SKILL.md
    templates/
      tech-template.md
      agent-file-template.md          # AI agent context template
    scripts/
      setup-plan.sh                   # References common.sh from specway.product
      update-agent-context.sh         # Multi-agent context updater
  specway.tasks/
    SKILL.md
    templates/tasks-template.md
  specway.checklist/
    SKILL.md
    templates/checklist-template.md
  specway.init/
    SKILL.md
    memory/constitution.md            # Project principles (persistent)
    templates/constitution-template.md
  specway.design/SKILL.md
  specway.implement/SKILL.md
  specway.clarify/SKILL.md
  specway.analyze/SKILL.md
  specway.taskstoissues/SKILL.md
```

Per-feature artifacts are generated under:

```
specs/<branch-name>/
  product.md           # Feature specification
  tech.md              # Technical plan
  research.md          # Phase 0 research
  data-model.md        # Data model
  contracts/           # Interface contracts
  quickstart.md        # Implementation quickstart
  tasks.md             # Task list
  checklists/          # Quality checklists
```

## Usage

1. (Optional) Configure the project constitution:

```
/specway.init Define 3 principles: simplicity, test-first, observability
```

2. Create a feature:

```
/specway.product I need an authentication system with email and password login
```

3. Follow the flow:

```
/specway.clarify
/specway.design          # optional — suggested if feature has UI
/specway.tech Using Python with FastAPI and PostgreSQL
/specway.tasks
/specway.implement
```

## License

MIT
