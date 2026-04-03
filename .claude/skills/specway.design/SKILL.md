---
name: specway.design
description: Create or update the project design system (DESIGN.md) with visual identity, colors, typography, and component guidelines.
handoffs:
  - label: Build Technical Plan
    agent: specway.tech
    prompt: Create a plan for the spec. I am building with...
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Goal: Create or refine the project's design system document (`DESIGN.md` at the project root). This is a **project-level** artifact — it persists across features and provides visual consistency for all UI work.

### Step 1: Resolve feature context

- Get current branch: run `git branch --show-current` (or use `$SPECIFY_FEATURE` env var if set)
- Feature directory is at `specs/<branch-name>/` from repo root
  - If branch has a numeric prefix (e.g., `004-`), search `specs/` for a directory matching that prefix
- Read `product.md` from the feature directory to understand the current feature's context
- If no feature branch is active, the skill can still run to create a general project DESIGN.md

### Step 2: Detect existing DESIGN.md

- Check if `DESIGN.md` exists at the project root
- If **yes** → proceed to **Refinement Mode** (step 4)
- If **no** → proceed to **Creation Mode** (step 3)

### Step 3: Creation Mode

Read `product.md` (if available) to understand the product and feature context.

Start a conversation with the user to understand the project's visual identity. Suggest: *"If you'd like, you can use `/voice` to talk through your design vision — it's often easier to describe visual preferences out loud."*

Present a guiding structure with open-ended topics and examples. Explicitly say: **"You don't need to address all of these — share what feels relevant. Write freely, in any order. You can also provide URLs to products you like visually and I'll use them as reference."**

Suggested topics:

- **Personality and feel**: "How would you describe the visual personality of your product? Professional, playful, minimal, bold, calm, dense?"
  *(Example: "A calm, professional interface — think Linear or Notion, not Figma or Canva")*
- **Visual references**: "Any product, website, or app whose visual style you admire? Share URLs or describe what you like about them."
  *(Example: "I love how Stripe's docs look — clean, lots of whitespace, great typography")*
- **Colors**: "Do you have brand colors defined? Or a palette preference — warm, cool, neutral, dark mode?"
  *(Example: "Our brand color is #2665fd, and we want a dark mode interface")*
- **Typography**: "Any font preferences? Serif, sans-serif, monospace? Should headlines feel different from body text?"
  *(Example: "Inter for everything, clean and uniform")*
- **Key components**: "What are the most important UI elements in your product? Forms, dashboards, cards, navigation, data tables?"
  *(Example: "It's mostly a dashboard with cards and charts, plus a settings panel with forms")*
- **Constraints and priorities**: "Is accessibility a priority? Mobile-first? Any platform-specific requirements?"
  *(Example: "Must meet WCAG AA, mobile-first since most users are on phones")*

Wait for the user's response.

After receiving the user's input, generate `DESIGN.md` at the project root following this structure:

```markdown
# Design System

## Overview
[Holistic description of the design's look and feel — personality, density, visual tone]

## Colors
- **Primary** (#hex): [Role — CTAs, active states, key interactive elements]
- **Secondary** (#hex): [Role — supporting UI, chips, secondary actions]
- **Surface** (#hex): [Role — page backgrounds]
- **On-surface** (#hex): [Role — primary text]
- **Error** (#hex): [Role — validation errors, destructive actions]
[Add more named colors as needed]

## Typography
- **Headlines**: [Font family, weight, size guidance]
- **Body**: [Font family, weight, size range]
- **Labels**: [Font family, weight, size, casing]

## Elevation
[How depth is conveyed — shadows, borders, background variation, or flat design]

## Components
- **Buttons**: [Variants, sizing, corner radius, states]
- **Inputs**: [Border, background, padding, states]
- **Cards**: [Elevation, border, corner radius]
[Add more components relevant to the project]

## Do's and Don'ts
- Do [guideline]
- Don't [anti-pattern]
[Focus on practical rules that prevent visual inconsistency]
```

Proceed to step 5.

### Step 4: Refinement Mode

Read the existing `DESIGN.md` from the project root. Read `product.md` from the current feature directory.

Analyze whether the current feature introduces visual needs not covered by the existing design system:
- New component types (e.g., feature needs data tables but DESIGN.md only covers cards)
- New interaction patterns (e.g., drag-and-drop, animations)
- New contexts (e.g., mobile-specific guidelines, dark mode additions)

If new needs are identified:
- Present them to the user with proposed additions
- Ask if they want to update the DESIGN.md
- Apply approved changes

If no new needs are found:
- Report that the existing DESIGN.md covers the current feature's visual requirements
- Suggest proceeding to `/specway.tech`

### Step 5: Report

- Path to DESIGN.md
- Summary of what was created or updated
- List of design system sections defined
- Suggested next command: `/specway.tech`

## Guidelines

- The DESIGN.md lives at the **project root**, not inside `specs/`. It is a project-wide artifact.
- Focus on design **tokens and guidelines**, not mockups or wireframes.
- Be specific with values (hex codes, px sizes, font names) — vague descriptions ("modern feel") should be translated into concrete tokens.
- If the user provides visual references (URLs), analyze them to extract patterns — don't just list the URLs.
- The format follows the Stitch DESIGN.md convention: human-readable markdown that AI agents can parse and enforce.
- When in refinement mode, preserve existing design decisions unless the user explicitly wants to change them.
