---
name: dependency-audit
description: Run dependency audit workflow and produce a dependency security report.
---

# Haye Skill: dependency-audit

## Purpose
Run dependency audit workflow and produce a dependency security report.

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


## Embedded React / Next.js security baseline
When a project uses React Server Components, Next.js App Router, middleware/proxy routes, server actions, image optimization or cache components:

- Avoid `react-server-dom-webpack`, `react-server-dom-parcel`, `react-server-dom-turbopack` versions:
  - `19.0.0` through `19.0.5`
  - `19.1.0` through `19.1.6`
  - `19.2.0` through `19.2.5`
- Prefer compatible patched versions:
  - `19.0.6+`
  - `19.1.7+`
  - `19.2.6+`
- For Next.js:
  - 15.x should be `15.5.16+`
  - 16.x should be `16.2.5+`
- Cloudflare WAF is defense-in-depth. It does not replace dependency patching.

## Live advisory rule
If internet is available, check official sources before recommending versions:
- npm registry
- npm audit / pnpm audit / yarn audit
- GitHub Security Advisories
- React advisories
- Next.js/Vercel release notes
- Cloudflare changelog

If live checking is unavailable, state that the result is based on local files and embedded Haye rules only.
