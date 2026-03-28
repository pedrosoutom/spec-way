# spec-way

A specification-driven development workflow for software projects, implemented as a suite of [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills.

> Based on [Speckit](https://github.com/speckit/speckit), refined with real-world usage learnings.

## Overview

spec-way enforces a structured development flow where every feature starts as a natural language description and progresses through specification, planning, task generation, and implementation — with full traceability between artifacts.

```
specway.specify → specway.clarify → specway.plan → specway.tasks → specway.implement
                                                                  ↘ specway.taskstoissues
```

Optional at any point: `/specway.analyze` (consistency check) and `/specway.checklist` (requirements quality validation).

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

### `/specway.constitution` — Project Principles

Defines non-negotiable rules and principles for the project (e.g., mandatory TDD, simplicity, observability). Acts as a constitution that all other skills validate against.

- Semantically versioned
- Enforced during planning and analysis

### `/specway.specify` — Feature Specification

Transforms a natural language description into a structured specification:

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

### `/specway.plan` — Technical Plan

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

Read-only analysis across `spec.md`, `plan.md`, and `tasks.md`:

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
  specway.specify/
    SKILL.md                          # Skill instructions
    init-options.json                 # Branch numbering config
    templates/spec-template.md        # Spec structure template
    scripts/
      common.sh                       # Shared utilities (single source of truth)
      create-new-feature.sh           # Branch + directory creation
  specway.plan/
    SKILL.md
    templates/
      plan-template.md
      agent-file-template.md          # AI agent context template
    scripts/
      setup-plan.sh                   # References common.sh from specway.specify
      update-agent-context.sh         # Multi-agent context updater
  specway.tasks/
    SKILL.md
    templates/tasks-template.md
  specway.checklist/
    SKILL.md
    templates/checklist-template.md
  specway.constitution/
    SKILL.md
    memory/constitution.md            # Project principles (persistent)
    templates/constitution-template.md
  specway.implement/SKILL.md
  specway.clarify/SKILL.md
  specway.analyze/SKILL.md
  specway.taskstoissues/SKILL.md
```

Per-feature artifacts are generated under:

```
specs/<branch-name>/
  spec.md              # Feature specification
  plan.md              # Technical plan
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
/specway.constitution Define 3 principles: simplicity, test-first, observability
```

2. Create a feature:

```
/specway.specify I need an authentication system with email and password login
```

3. Follow the flow:

```
/specway.clarify
/specway.plan Using Python with FastAPI and PostgreSQL
/specway.tasks
/specway.implement
```

## License

MIT
