---
name: specway.clarify
description: Identify underspecified areas in the current feature spec through up to 5 open-ended, conversational clarification questions and encoding answers back into the spec.
handoffs: 
  - label: Build Technical Plan
    agent: specway.plan
    prompt: Create a plan for the spec. I am building with...
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Goal: Detect and reduce ambiguity or missing decision points in the active feature specification and record the clarifications directly in the spec file.

Note: This clarification workflow is expected to run (and be completed) BEFORE invoking `/specway.plan`. If the user explicitly states they are skipping clarification (e.g., exploratory spike), you may proceed, but must warn that downstream rework risk increases.

Execution steps:

1. **Resolve feature context**:
   - Get current branch: run `git branch --show-current` (or use `$SPECIFY_FEATURE` env var if set)
   - Feature directory is at `specs/<branch-name>/` from repo root
     - If branch has a numeric prefix (e.g., `004-`), search `specs/` for a directory matching that prefix
   - Derive paths: FEATURE_SPEC = `<feature-dir>/spec.md`, IMPL_PLAN = `<feature-dir>/plan.md`, TASKS = `<feature-dir>/tasks.md`
   - If FEATURE_SPEC does not exist, abort and instruct user to run `/specway.specify` first.
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. Load the current spec file. Perform a structured ambiguity & coverage scan using this taxonomy. For each category, mark status: Clear / Partial / Missing. Produce an internal coverage map used for prioritization (do not output raw map unless no questions will be asked).

   Functional Scope & Behavior:
   - Core user goals & success criteria
   - Explicit out-of-scope declarations
   - User roles / personas differentiation

   Domain & Data Model:
   - Entities, attributes, relationships
   - Identity & uniqueness rules
   - Lifecycle/state transitions
   - Data volume / scale assumptions

   Interaction & UX Flow:
   - Critical user journeys / sequences
   - Error/empty/loading states
   - Accessibility or localization notes

   Non-Functional Quality Attributes:
   - Performance (latency, throughput targets)
   - Scalability (horizontal/vertical, limits)
   - Reliability & availability (uptime, recovery expectations)
   - Observability (logging, metrics, tracing signals)
   - Security & privacy (authN/Z, data protection, threat assumptions)
   - Compliance / regulatory constraints (if any)

   Integration & External Dependencies:
   - External services/APIs and failure modes
   - Data import/export formats
   - Protocol/versioning assumptions

   Edge Cases & Failure Handling:
   - Negative scenarios
   - Rate limiting / throttling
   - Conflict resolution (e.g., concurrent edits)

   Constraints & Tradeoffs:
   - Technical constraints (language, storage, hosting)
   - Explicit tradeoffs or rejected alternatives

   Terminology & Consistency:
   - Canonical glossary terms
   - Avoided synonyms / deprecated terms

   Completion Signals:
   - Acceptance criteria testability
   - Measurable Definition of Done style indicators

   Misc / Placeholders:
   - TODO markers / unresolved decisions
   - Ambiguous adjectives ("robust", "intuitive") lacking quantification

   For each category with Partial or Missing status, add a candidate question opportunity unless:
   - Clarification would not materially change implementation or validation strategy
   - Information is better deferred to planning phase (note internally)

3. Generate (internally) a prioritized queue of candidate clarification questions (maximum 5). Do NOT output them all at once. Apply these constraints:
    - Maximum of 5 total questions across the whole session.
    - Each question should be **open-ended**, inviting the user to explain their thinking in their own words.
    - To prevent "blank page" paralysis, each question MUST also provide **2-4 suggested approaches or examples** that orient the user without constraining them.
    - The suggested options serve as conversation starters, not exhaustive choices. The user can pick one, combine them, or describe something entirely different.
    - Questions should feel collaborative ("How do you envision...?", "What matters most to you about...?") rather than interrogative.
    - Only include questions whose answers materially impact architecture, data modeling, task decomposition, test design, UX behavior, operational readiness, or compliance validation.
    - Ensure category coverage balance: attempt to cover the highest impact unresolved categories first; avoid asking two low-impact questions when a single high-impact area (e.g., security posture) is unresolved.
    - Exclude questions already answered, trivial stylistic preferences, or plan-level execution details (unless blocking correctness).
    - Favor clarifications that reduce downstream rework risk or prevent misaligned acceptance tests.
    - If more than 5 categories remain unresolved, select the top 5 by (Impact * Uncertainty) heuristic.

4. Sequential questioning loop (interactive):
    - Present EXACTLY ONE question at a time.
    - For each question, use this format:

       ```markdown
       **Q[N]: [Open-ended question phrased conversationally]**

       [1-2 sentences of context explaining why this matters for the spec]

       Here are some common approaches to consider:
       - **[Approach A]**: [Brief description] — [implication for the feature]
       - **[Approach B]**: [Brief description] — [implication for the feature]
       - **[Approach C]**: [Brief description] — [implication for the feature]

       Based on the spec context, **[Approach X]** seems most aligned because [reason].

       Feel free to pick one of these, combine them, or describe your own approach entirely.
       You can also use `/voice` to talk through your thinking.
       ```

    - After the user answers:
       - Accept any form of response: a letter, a paragraph of explanation, a short phrase, a voice transcription
       - If the user picks a suggested option by letter (e.g., "A"), that's valid
       - If the user writes a paragraph explaining their vision, synthesize the key decision from it
       - If the user says "yes" or "recommended", use the recommended approach
       - If the user's response is rich but covers multiple aspects, confirm your interpretation: "I understood your main point as [X] — is that right?" (does not count as a new question)
       - If the response is too vague to act on, ask a focused follow-up: "Could you say a bit more about [specific aspect]?" (does not count as a new question)
       - Once the key decision is clear, record it in working memory (do not write to disk yet) and move to the next queued question.
    - Stop asking further questions when:
       - All critical ambiguities resolved early (remaining queued items become unnecessary), OR
       - User signals completion ("done", "good", "no more"), OR
       - You reach 5 asked questions.
    - Never reveal future queued questions in advance.
    - If no valid questions exist at start, immediately report no critical ambiguities.

5. Batch integration (after ALL questions are answered or the loop ends):
    - Accumulate all accepted answers in working memory during the questioning loop. Do NOT write to disk between questions — this keeps the conversation flow uninterrupted.
    - Once the questioning loop is complete, apply all clarifications to the spec at once:
       - Ensure a `## Clarifications` section exists (create it just after the highest-level contextual/overview section per the spec template if missing).
       - Under it, create (if not present) a `### Session YYYY-MM-DD` subheading for today.
       - For each accepted answer, append a bullet: `- Q: <question> → A: <synthesized answer from user's response>`. If the user provided a rich, multi-sentence answer, synthesize it into a concise clarification entry (1-2 sentences) that captures the decision. Preserve the user's intent and specific details.
       - Then apply each clarification to the most appropriate section(s):
          - Functional ambiguity → Update or add a bullet in Functional Requirements.
          - User interaction / actor distinction → Update User Stories or Actors subsection (if present) with clarified role, constraint, or scenario.
          - Data shape / entities → Update Data Model (add fields, types, relationships) preserving ordering; note added constraints succinctly.
          - Non-functional constraint → Add/modify measurable criteria in Success Criteria > Measurable Outcomes (convert vague adjective to metric or explicit target).
          - Edge case / negative flow → Add a new bullet under Edge Cases / Error Handling (or create such subsection if template provides placeholder for it).
          - Terminology conflict → Normalize term across spec; retain original only if necessary by adding `(formerly referred to as "X")` once.
       - If a clarification invalidates an earlier ambiguous statement, replace that statement instead of duplicating; leave no obsolete contradictory text.
    - Preserve formatting: do not reorder unrelated sections; keep heading hierarchy intact.
    - Keep each inserted clarification minimal and testable (avoid narrative drift).

6. Validation (performed once after batch integration):
   - Clarifications session contains exactly one bullet per accepted answer (no duplicates).
   - Total asked (accepted) questions ≤ 5.
   - Updated sections contain no lingering vague placeholders the new answers were meant to resolve.
   - No contradictory earlier statement remains (scan for now-invalid alternative choices removed).
   - Markdown structure valid; only allowed new headings: `## Clarifications`, `### Session YYYY-MM-DD`.
   - Terminology consistency: same canonical term used across all updated sections.

7. Write the updated spec back to `FEATURE_SPEC` (single write after all clarifications are applied).

8. Report completion (after questioning loop ends or early termination):
   - Number of questions asked & answered.
   - Path to updated spec.
   - Sections touched (list names).
   - Coverage summary table listing each taxonomy category with Status: Resolved (was Partial/Missing and addressed), Deferred (exceeds question quota or better suited for planning), Clear (already sufficient), Outstanding (still Partial/Missing but low impact).
   - If any Outstanding or Deferred remain, recommend whether to proceed to `/specway.plan` or run `/specway.clarify` again later post-plan.
   - If the spec contains indications of UI/frontend work (user stories mention interface, screens, pages, visual components, dashboards, forms, or similar), include:
     `Suggested next: /specway.design — this feature involves UI. Consider defining or reviewing the project design system before planning.`
   - Suggested next command.

Behavior rules:

- If no meaningful ambiguities found (or all potential questions would be low-impact), respond: "No critical ambiguities detected worth formal clarification." and suggest proceeding.
- If spec file missing, instruct user to run `/specway.specify` first (do not create a new spec here).
- Never exceed 5 total asked questions (clarification retries for a single question do not count as new questions).
- Avoid speculative tech stack questions unless the absence blocks functional clarity.
- Respect user early termination signals ("stop", "done", "proceed").
- If no questions asked due to full coverage, output a compact coverage summary (all categories Clear) then suggest advancing.
- If quota reached with unresolved high-impact categories remaining, explicitly flag them under Deferred with rationale.

Context for prioritization: $ARGUMENTS
