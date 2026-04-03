---
name: specway.product
description: Create or update the feature specification from a natural language feature description.
handoffs: 
  - label: Build Technical Plan
    agent: specway.tech
    prompt: Create a plan for the spec. I am building with...
  - label: Clarify Spec Requirements
    agent: specway.clarify
    prompt: Clarify specification requirements
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before specification)**:
- Check if `.specway/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_specify` key
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally
- Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
- For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
  - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
  - If the hook defines a non-empty `condition`, skip the hook and leave condition evaluation to the HookExecutor implementation
- For each executable hook, output the following based on its `optional` flag:
  - **Optional hook** (`optional: true`):
    ```
    ## Extension Hooks

    **Optional Pre-Hook**: {extension}
    Command: `/{command}`
    Description: {description}

    Prompt: {prompt}
    To execute: `/{command}`
    ```
  - **Mandatory hook** (`optional: false`):
    ```
    ## Extension Hooks

    **Automatic Pre-Hook**: {extension}
    Executing: `/{command}`
    EXECUTE_COMMAND: {command}

    Wait for the result of the hook command before proceeding to the Outline.
    ```
- If no hooks are registered or `.specway/extensions.yml` does not exist, skip silently

## Discovery Conversation

**Discovery is a mandatory, in-depth phase.** Do NOT rush through it. Do NOT skip it. The quality of the entire downstream workflow (spec, plan, tasks, implementation) depends on the depth of understanding built here. A shallow discovery produces a shallow spec, which cascades into poor plans and wasted implementation effort.

The goal is to reach a point where you could explain the feature to a new team member in complete detail — the problem, the users, the workflows, and the boundaries — before writing a single line of spec.

**IMPORTANT**: Discovery is about understanding the WHAT and WHY — user problems, outcomes, and boundaries. Do NOT discuss technical implementation, database schemas, or architecture here. That belongs in `/specway.tech`. Keep language simple and focused on user outcomes.

### Step 1: Assess project context

- Check if `.claude/skills/specway.init/memory/constitution.md` has been filled in (does NOT still contain `[PROJECT_NAME]` placeholder tokens)
- Check if any specs exist under `specs/` directory in the repo root
- Check if a `README.md` exists at the repo root with substantive content (more than boilerplate)
- **Map existing project** (critical when joining a project mid-flight):
  - Check if `CLAUDE.md` (or equivalent agent context file: `AGENTS.md`, `GEMINI.md`, etc.) exists at the repo root — if so, read it to absorb project conventions and context
  - Run a quick repo structure scan (`ls` of top-level directories and key files) to understand the codebase layout
  - Check for package/dependency manifests (`package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `Gemfile`, `pom.xml`, etc.) to identify what exists
  - If the project has existing source code but no specway artifacts yet, treat it as an **established project onboarding** — the spec should respect and reference the existing product rather than assuming greenfield

This context informs the discovery conversation but does NOT replace it — even projects with rich context need deep feature-level discovery.

### Step 2: Open the discovery conversation

**Always start discovery.** There is no skip condition. Even if the user provided a detailed briefing, the discovery conversation is where you probe deeper, uncover assumptions, and build shared understanding.

Acknowledge the user's description and explain the process briefly:

*"Before I generate the spec, I'd like to understand your feature in depth through a few rounds of questions. This conversation is the foundation for everything that follows, so take your time."*

### Step 3: Iterative deep-dive (multi-round)

Conduct the discovery as an **iterative conversation** with multiple rounds. Present **2–3 questions per round**, wait for the user's response, analyze what was said, identify gaps, and ask follow-up questions in the next round.

**Do NOT present all questions at once.** Each round builds on the previous one, going deeper based on what the user revealed.

**What you need to understand by the end** — use these as a mental checklist, not a rigid script. Adapt your questions to the feature and the conversation flow:

- The **problem** being solved and why it matters now
- Who the **users** are and how their needs differ
- The **user journeys** — step by step, what the user actually does
- What is **in scope** and what is explicitly **out of scope**
- What **success** looks like from the user's perspective
- **Edge cases** — what happens when things go wrong or hit limits

**How to conduct the rounds:**

- Start broad (problem, vision, users) and progressively narrow (workflows, boundaries, edge cases)
- Ask open-ended questions that invite explanation, not yes/no answers
- When the user gives a short or vague answer, probe deeper: *"You mentioned [X] — can you tell me more about what that looks like in practice?"*
- Reflect back your understanding periodically: *"So if I understand correctly, [summary] — is that right?"*
- When the user says "I don't know", note it as an open question for the spec
- If the user seems eager to skip ahead: *"A few more questions will save us significant rework later."*
- Keep language simple and focused on user outcomes — avoid technical jargon

**Minimum depth:**

- At least **3 rounds** of questions before proceeding
- Up to **6 rounds** for complex features
- End only when you can fill every spec section with substantive content, not placeholders

### Step 4: Summary & confirmation

Present a brief discovery summary to the user:

```markdown
## Discovery Summary

Here's what I've captured from our conversation:

- **Problem**: [1-2 sentences]
- **Vision**: [1-2 sentences]
- **Primary users**: [who]
- **Key workflows**: [main flows identified]
- **Scope**: [in] / [out]
- **Open questions**: [any remaining unknowns]

Does this capture the essence of what you want to build? Anything to add or correct before I generate the spec?
```

Wait for the user's confirmation or corrections. Only after confirmation, proceed to the Outline (spec generation).

---

## Outline

The text the user typed after `/specway.product` in the triggering message **is** the feature description. Assume you always have it available in this conversation even if `$ARGUMENTS` appears literally below. Do not ask the user to repeat it unless they provided an empty command.

Given that feature description and the discovery conversation input, do this:

1. **Generate a concise short name** (2-4 words) for the branch:
   - Analyze the feature description and extract the most meaningful keywords
   - Create a 2-4 word short name that captures the essence of the feature
   - Use action-noun format when possible (e.g., "add-user-auth", "fix-payment-bug")
   - Preserve technical terms and acronyms (OAuth2, API, JWT, etc.)
   - Keep it concise but descriptive enough to understand the feature at a glance
   - Examples:
     - "I want to add user authentication" → "user-auth"
     - "Implement OAuth2 integration for the API" → "oauth2-api-integration"
     - "Create a dashboard for analytics" → "analytics-dashboard"
     - "Fix payment processing timeout bug" → "fix-payment-timeout"

2. **Create the feature branch** by running the script with `--short-name` (and `--json`). In sequential mode, do NOT pass `--number` — the script auto-detects the next available number. In timestamp mode, the script generates a `YYYYMMDD-HHMMSS` prefix automatically:

   **Branch numbering mode**: Before running the script, check if `${CLAUDE_SKILL_DIR}/init-options.json` exists and read the `branch_numbering` value.
   - If `"timestamp"`, add `--timestamp` (Bash) or `-Timestamp` (PowerShell) to the script invocation
   - If `"sequential"` or absent, do not add any extra flag (default behavior)

   - Bash example: `${CLAUDE_SKILL_DIR}/scripts/create-new-feature.sh "$ARGUMENTS" --json --template "${CLAUDE_SKILL_DIR}/templates/product-template.md" --short-name "user-auth" "Add user authentication"`
   - Bash (timestamp): `${CLAUDE_SKILL_DIR}/scripts/create-new-feature.sh "$ARGUMENTS" --json --timestamp --template "${CLAUDE_SKILL_DIR}/templates/product-template.md" --short-name "user-auth" "Add user authentication"`
   - PowerShell example: `${CLAUDE_SKILL_DIR}/scripts/create-new-feature.sh "$ARGUMENTS" -Json --template "${CLAUDE_SKILL_DIR}/templates/product-template.md" -ShortName "user-auth" "Add user authentication"`
   - PowerShell (timestamp): `${CLAUDE_SKILL_DIR}/scripts/create-new-feature.sh "$ARGUMENTS" -Json -Timestamp --template "${CLAUDE_SKILL_DIR}/templates/product-template.md" -ShortName "user-auth" "Add user authentication"`

   **IMPORTANT**:
   - Do NOT pass `--number` — the script determines the correct next number automatically
   - Always include the JSON flag (`--json` for Bash, `-Json` for PowerShell) so the output can be parsed reliably
   - You must only ever run this script once per feature
   - The JSON is provided in the terminal as output - always refer to it to get the actual content you're looking for
   - The JSON output will contain BRANCH_NAME and PRODUCT_FILE paths
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot")

3. Load `${CLAUDE_SKILL_DIR}/templates/product-template.md` to understand required sections.

4. Follow this execution flow:

    1. Parse user description from Input
       If empty: ERROR "No feature description provided"
    2. Extract key concepts from description AND discovery conversation input
       Identify: actors, actions, data, constraints
       Prioritize information the user explicitly provided over inferred defaults
    3. For unclear aspects:
       - Make informed guesses based on context and industry standards
       - Only mark with [NEEDS CLARIFICATION: specific question] if:
         - The choice significantly impacts feature scope or user experience
         - Multiple reasonable interpretations exist with different implications
         - No reasonable default exists
       - **LIMIT: Maximum 3 [NEEDS CLARIFICATION] markers total**
       - Since the discovery conversation has already provided rich context, the threshold for [NEEDS CLARIFICATION] should be high — fewer ambiguities should remain after deep discovery
       - Prioritize clarifications by impact: scope > security/privacy > user experience > technical details
    4. Fill User Scenarios & Testing section
       If no clear user flow: ERROR "Cannot determine user scenarios"
    5. Generate Functional Requirements
       Each requirement must be testable
       Use reasonable defaults for unspecified details (document assumptions in Assumptions section)
    6. Define Success Criteria
       Create measurable, technology-agnostic outcomes
       Include both quantitative metrics (time, performance, volume) and qualitative measures (user satisfaction, task completion)
       Each criterion must be verifiable without implementation details
    7. Identify Key Entities (if data involved)
    8. Return: SUCCESS (spec ready for planning)

5. Write the specification to PRODUCT_FILE using the template structure, replacing placeholders with concrete details derived from the feature description (arguments) and the discovery conversation while preserving section order and headings. Include a `## Discovery Context` section in the spec (after the header metadata, before User Scenarios) that summarizes the key points from the user's discovery input — their motivation, vision, constraints, and any context they shared. This section serves as a reference for the user's original intent throughout the development process.

6. **Specification Quality Validation**: After writing the initial spec, validate it against quality criteria:

   a. **Create Spec Quality Checklist**: Generate a checklist file at `FEATURE_DIR/checklists/requirements.md` using the checklist template structure with these validation items:

      ```markdown
      # Specification Quality Checklist: [FEATURE NAME]
      
      **Purpose**: Validate specification completeness and quality before proceeding to planning
      **Created**: [DATE]
      **Feature**: [Link to product.md]
      
      ## Content Quality
      
      - [ ] No implementation details (languages, frameworks, APIs)
      - [ ] Focused on user value and business needs
      - [ ] Written for non-technical stakeholders
      - [ ] All mandatory sections completed
      
      ## Requirement Completeness
      
      - [ ] No [NEEDS CLARIFICATION] markers remain
      - [ ] Requirements are testable and unambiguous
      - [ ] Success criteria are measurable
      - [ ] Success criteria are technology-agnostic (no implementation details)
      - [ ] All acceptance scenarios are defined
      - [ ] Edge cases are identified
      - [ ] Scope is clearly bounded
      - [ ] Dependencies and assumptions identified
      
      ## Feature Readiness
      
      - [ ] All functional requirements have clear acceptance criteria
      - [ ] User scenarios cover primary flows
      - [ ] Feature meets measurable outcomes defined in Success Criteria
      - [ ] No implementation details leak into specification
      
      ## Notes
      
      - Items marked incomplete require spec updates before `/specway.clarify` or `/specway.tech`
      ```

   b. **Run Validation Check**: Review the spec against each checklist item:
      - For each item, determine if it passes or fails
      - Document specific issues found (quote relevant spec sections)

   c. **Handle Validation Results**:

      - **If all items pass**: Mark checklist complete and proceed to step 7

      - **If items fail (excluding [NEEDS CLARIFICATION])**:
        1. List the failing items and specific issues
        2. Update the spec to address each issue
        3. Re-run validation until all items pass (max 3 iterations)
        4. If still failing after 3 iterations, document remaining issues in checklist notes and warn user

      - **If [NEEDS CLARIFICATION] markers remain**:
        1. Extract all [NEEDS CLARIFICATION: ...] markers from the spec
        2. **LIMIT CHECK**: If more than 3 markers exist, keep only the 3 most critical (by scope/security/UX impact) and make informed guesses for the rest
        3. For each clarification needed (max 3), present options to user in this format:

           ```markdown
           ## Question [N]: [Topic]
           
           **Context**: [Quote relevant spec section]
           
           **What we need to know**: [Specific question from NEEDS CLARIFICATION marker]
           
           **Suggested Answers**:
           
           | Option | Answer | Implications |
           |--------|--------|--------------|
           | A      | [First suggested answer] | [What this means for the feature] |
           | B      | [Second suggested answer] | [What this means for the feature] |
           | C      | [Third suggested answer] | [What this means for the feature] |
           | Custom | Provide your own answer | [Explain how to provide custom input] |
           
           **Your choice**: _[Wait for user response]_
           ```

        4. **CRITICAL - Table Formatting**: Ensure markdown tables are properly formatted:
           - Use consistent spacing with pipes aligned
           - Each cell should have spaces around content: `| Content |` not `|Content|`
           - Header separator must have at least 3 dashes: `|--------|`
           - Test that the table renders correctly in markdown preview
        5. Number questions sequentially (Q1, Q2, Q3 - max 3 total)
        6. Present all questions together before waiting for responses
        7. Wait for user to respond with their choices for all questions (e.g., "Q1: A, Q2: Custom - [details], Q3: B")
        8. Update the spec by replacing each [NEEDS CLARIFICATION] marker with the user's selected or provided answer
        9. Re-run validation after all clarifications are resolved

   d. **Update Checklist**: After each validation iteration, update the checklist file with current pass/fail status

7. Report completion with branch name, spec file path, checklist results, and readiness for the next phase (`/specway.clarify` or `/specway.tech`).

8. **Check for extension hooks**: After reporting completion, check if `.specway/extensions.yml` exists in the project root.
   - If it exists, read it and look for entries under the `hooks.after_specify` key
   - If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally
   - Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
   - For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
     - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
     - If the hook defines a non-empty `condition`, skip the hook and leave condition evaluation to the HookExecutor implementation
   - For each executable hook, output the following based on its `optional` flag:
     - **Optional hook** (`optional: true`):
       ```
       ## Extension Hooks

       **Optional Hook**: {extension}
       Command: `/{command}`
       Description: {description}

       Prompt: {prompt}
       To execute: `/{command}`
       ```
     - **Mandatory hook** (`optional: false`):
       ```
       ## Extension Hooks

       **Automatic Hook**: {extension}
       Executing: `/{command}`
       EXECUTE_COMMAND: {command}
       ```
   - If no hooks are registered or `.specway/extensions.yml` does not exist, skip silently

**NOTE:** The script creates and checks out the new branch and initializes the spec file before writing.

## Quick Guidelines

- Focus on **WHAT** users need and **WHY**.
- Avoid HOW to implement (no tech stack, APIs, code structure).
- Written for business stakeholders, not developers.
- DO NOT create any checklists that are embedded in the spec. That will be a separate command.

### Section Requirements

- **Mandatory sections**: Must be completed for every feature
- **Optional sections**: Include only when relevant to the feature
- When a section doesn't apply, remove it entirely (don't leave as "N/A")

### For AI Generation

When creating this spec from a user prompt:

1. **Make informed guesses**: Use context, industry standards, and common patterns to fill gaps
2. **Document assumptions**: Record reasonable defaults in the Assumptions section
3. **Limit clarifications**: Maximum 3 [NEEDS CLARIFICATION] markers - use only for critical decisions that:
   - Significantly impact feature scope or user experience
   - Have multiple reasonable interpretations with different implications
   - Lack any reasonable default
4. **Prioritize clarifications**: scope > security/privacy > user experience > technical details
5. **Think like a tester**: Every vague requirement should fail the "testable and unambiguous" checklist item
6. **Common areas needing clarification** (only if no reasonable default exists):
   - Feature scope and boundaries (include/exclude specific use cases)
   - User types and permissions (if multiple conflicting interpretations possible)
   - Security/compliance requirements (when legally/financially significant)

**Examples of reasonable defaults** (don't ask about these):

- Data retention: Industry-standard practices for the domain
- Performance targets: Standard web/mobile app expectations unless specified
- Error handling: User-friendly messages with appropriate fallbacks
- Authentication method: Standard session-based or OAuth2 for web apps
- Integration patterns: Use project-appropriate patterns (REST/GraphQL for web services, function calls for libraries, CLI args for tools, etc.)

### Success Criteria Guidelines

Success criteria must be:

1. **Measurable**: Include specific metrics (time, percentage, count, rate)
2. **Technology-agnostic**: No mention of frameworks, languages, databases, or tools
3. **User-focused**: Describe outcomes from user/business perspective, not system internals
4. **Verifiable**: Can be tested/validated without knowing implementation details

**Good examples**:

- "Users can complete checkout in under 3 minutes"
- "System supports 10,000 concurrent users"
- "95% of searches return results in under 1 second"
- "Task completion rate improves by 40%"

**Bad examples** (implementation-focused):

- "API response time is under 200ms" (too technical, use "Users see results instantly")
- "Database can handle 1000 TPS" (implementation detail, use user-facing metric)
- "React components render efficiently" (framework-specific)
- "Redis cache hit rate above 80%" (technology-specific)
