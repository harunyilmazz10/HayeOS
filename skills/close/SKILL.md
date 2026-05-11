---
name: close
description: Close session and update memory
---

# Haye Skill: close

## Purpose
Close session and update memory

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS komutları Harun için varsayılan olarak Türkçe konuşur.

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
7. Update memory through `/haye:close` or session-close rules:
   - `current.md` for current state.
   - `next.md` for the next five actions.
   - `changelog.md` for completed changes.
   - `health.md` for verification status.
   - `05-sessions/` for a dated session handoff when useful.
   - `12-risks/` and `02-decisions/` when security or dependency decisions changed.

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
- `session-close`
- `memory-lint`
- `token-audit`
