---
name: specway.taskstoissues
description: Convert existing tasks into actionable, dependency-ordered GitHub issues for the feature based on available design artifacts.
tools: ['github/github-mcp-server/issue_write']
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Resolve feature context**:
   - Get current branch: run `git branch --show-current` (or use `$SPECIFY_FEATURE` env var if set)
   - Feature directory is at `specs/<branch-name>/` from repo root
     - If branch has a numeric prefix (e.g., `004-`), search `specs/` for a directory matching that prefix
   - Verify `tasks.md` exists in the feature directory (if not: ERROR — run `/specway.tasks` first)
1. From the executed script, extract the path to **tasks**.
1. Get the Git remote by running:

```bash
git config --get remote.origin.url
```

> [!CAUTION]
> ONLY PROCEED TO NEXT STEPS IF THE REMOTE IS A GITHUB URL

1. For each task in the list, use the GitHub MCP server to create a new issue in the repository that is representative of the Git remote.

> [!CAUTION]
> UNDER NO CIRCUMSTANCES EVER CREATE ISSUES IN REPOSITORIES THAT DO NOT MATCH THE REMOTE URL
