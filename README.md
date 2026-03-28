# spec-way

A specification-driven development workflow for software projects, implemented as a suite of [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills.

> **Work in progress** — Based on [Speckit](https://github.com/speckit/speckit), this repository is under constant refinement, incorporating additional references and real-world usage learnings over time.

## Overview

spec-way enforces a structured development flow where every feature starts as a natural language description and progresses through specification, planning, task generation, and implementation — with full traceability between artifacts.

```
specway.specify → specway.clarify → specway.plan → specway.tasks → specway.implement
                                                                  ↘ specway.taskstoissues
```

## Skills

### `/specway.constitution` — Project Principles

Defines non-negotiable rules and principles for the project (e.g., mandatory TDD, simplicity, observability). Acts as a constitution that all other skills validate against.

- Output: `.specify/memory/constitution.md`
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

```
.claude/
  skills/              # Claude Code skills (slash commands)
    specway.specify/
    specway.clarify/
    specway.plan/
    specway.tasks/
    specway.implement/
    specway.analyze/
    specway.checklist/
    specway.constitution/
    specway.taskstoissues/

.specify/
  templates/           # Artifact templates (spec, plan, tasks, checklist, constitution)
  scripts/bash/        # Utility scripts (feature creation, prerequisite checks, etc.)
  memory/              # Constitution and persistent project context
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

## Getting Started

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- Git
- Bash

### Usage

1. Clone the repository:

```bash
git clone https://github.com/pedrosoutom/spec-way.git my-project
cd my-project
```

2. (Optional) Configure the project constitution:

```
/specway.constitution Define 3 principles: simplicity, test-first, observability
```

3. Create a feature:

```
/specway.specify I need an authentication system with email and password login
```

4. Follow the flow:

```
/specway.clarify
/specway.plan Using Python with FastAPI and PostgreSQL
/specway.tasks
/specway.implement
```

## License

MIT
