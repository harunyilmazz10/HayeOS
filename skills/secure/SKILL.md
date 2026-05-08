---
name: secure
description: Smart router for security and safe versions
---

# Haye Skill: secure

## Purpose
Smart router for security and safe versions

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

## Smart routing
This simplified command may route internally to:
- `security`
- `dependency-security`
- `version-policy`
- `react-nextjs-security`
- `secrets-audit`
- `auth-audit`
- `exposed-port-audit`
- `dependency-audit`

## Dependency security checks
- Read `.hayeos.json` first and use its `sourcePath` for `package.json`, lockfile and audit checks.
- Inspect `package.json` plus one of `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock` or `bun.lockb` when present.
- If no lockfile exists, report that dependency resolution is not pinned.
- Treat any dependency set to `latest` as unsafe policy. Choose explicit patched compatible versions instead.
- For React/Next.js projects, run or mirror `bin/haye react-nextjs-audit`.
- Use official live advisories when internet is available. If unavailable, state that the result uses only local files and embedded Haye rules.

## Embedded React / Next.js baseline
- Avoid RSC packages `19.0.0-19.0.5`, `19.1.0-19.1.6`, `19.2.0-19.2.5`.
- Prefer compatible patched RSC packages `19.0.6`, `19.1.7`, `19.2.6` or later compatible patch.
- Next.js 15.x baseline is `15.5.16+`.
- Next.js 16.x baseline is `16.2.5+`.
- Cloudflare WAF is defense-in-depth only and does not replace dependency patching.
