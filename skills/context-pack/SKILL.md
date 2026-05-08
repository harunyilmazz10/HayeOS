---
name: context-pack
description: Generate a minimal task-specific context pack before coding, debugging, deploying, or reviewing.
---

# Haye Skill: context-pack

## Purpose
Generate a minimal task-specific context pack before coding, debugging, deploying, or reviewing.

## When to use
- Use when the user's request matches this workflow.
- Use when the current project has `.hayeos.json` or an Obsidian memory vault.
- Use instead of loading a huge old conversation or scanning the entire repository.

## Inputs to inspect first
1. `.hayeos.json` if present.
2. Memory root from `memoryPath`.
3. Only minimal memory files:
   - `HAYE.md`
   - `index.md`
   - `current.md`
   - `next.md`
   - `04-tasks/active-task.md` when present.

## Token discipline
- Do not scan the whole Obsidian vault.
- Do not read `08-raw/` unless explicitly required.
- Do not read the whole repo before a context pack is created.
- Prefer summaries, file paths, root causes, decisions and verification outputs over pasted logs.
- If context is growing, recommend `/clear` plus `/haye:start` after `/haye:close`.

## Workflow
1. Locate project config and memory path.
2. Read minimal memory.
3. Identify task type, risks and affected files.
4. Create or reuse a context pack when work is non-trivial.
5. Execute the smallest safe step.
6. Verify with real commands when possible.
7. Update memory through `/haye:close` or session-close rules.

## Output format
- What I found
- What I will do / did
- Risks
- Files touched or to inspect
- Verification command/result
- Memory updates required

## Safety rules
- Do not run destructive commands without explicit approval.
- Do not auto-upgrade dependencies without approval.
- Do not claim safe/fixed/done without verification output or a clear limitation note.
