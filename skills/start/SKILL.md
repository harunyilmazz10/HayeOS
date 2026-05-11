---
name: start
description: Start simple session
---

# Haye Skill: start

## Purpose
Start simple session

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS komutları Harun için varsayılan olarak Türkçe konuşur.

## When to use
- Use when the user's request matches this workflow.
- Use when the current project has `.hayeos.json` or an Obsidian memory vault.
- Use instead of loading a huge old conversation or scanning the entire repository.

## Start Light Rule
`/haye:start` must stay lightweight. It may only:
- check whether `.hayeos.json` exists
- read `memoryPath` when config exists
- read minimal memory files: `HAYE.md`, `current.md`, `next.md`, optional `04-tasks/active-task.md`, optional `05-sessions/latest-checkpoint.md`
- provide a short recovery summary when a checkpoint exists
- ask which task to continue when no checkpoint exists
- ask before creating `.hayeos.json`

`/haye:start` must not:
- must not load `/haye:work`
- must not start a task classification wizard
- must not ask "Şimdi hafızayı başlatmamı ister misiniz?" after init
- must not use subagents
- must not enter plan mode
- must not scan the whole repository
- must not perform codebase exploration
- must not search test patterns
- must not produce an automatic project plan
- must not create `.hayeos.json` without explicit user approval
- must not write project files before the user says yes to init

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
   - If `.hayeos.json` is missing, ask before creating `.hayeos.json`. Ask only in Turkish: "Bu projede Haye hafızası bulunamadı. Şimdi otomatik oluşturayım mı?"
   - Do not create files until the user explicitly says yes.
   - If the user says yes, run `/haye:init-memory`. Do not ask the user to find `bin/haye`, bash or Python paths.
   - If the CLI path fails, use the manual fallback from `skills/init-memory/SKILL.md`.
   - After successful creation, memory is already considered started. Do not ask "Şimdi hafızayı başlatmamı ister misiniz?". Run only the lightweight `memory-start` read and ask: "Hangi görevle devam edelim?"
   - If `.hayeos.json` exists but `memoryPath` is missing or invalid, report the exact missing path in Turkish and offer to repair it through `/haye:init-memory`.
2. Read minimal memory.
3. Apply Safe Resume Rule:
   - Read `05-sessions/latest-checkpoint.md` if present.
   - If it exists, provide a short `HayeOS Recovery Summary`.
   - Do not automatically continue implementation.
   - Ask in Turkish: "Son checkpoint'e göre kaldığımız yeri buldum. Devam edeyim mi?"
   - Continue only after explicit user approval.
4. If no `latest-checkpoint.md` exists, show a short start summary from `next.md` and ask: "Hangi görevle devam edelim?"

## Safe Resume Rule
`/haye:start` reads `.hayeos.json`, locates the vault, then reads:
- `HAYE.md`
- `index.md`
- `current.md`
- `next.md`
- `04-tasks/active-task.md` when present
- `05-sessions/latest-checkpoint.md` when present

Recovery summary format:
```markdown
# HayeOS Recovery Summary

## Current Task
## Current Phase
## Last Successful Step
## Changed Files
## Current Blocker
## Next 3 Actions
## Recommended Next Mode

Kaldığımız yerden devam edeyim mi?
```

Never start coding automatically from `/haye:start` when a checkpoint exists.

## Plugin root vs project vault
- `CLAUDE_PLUGIN_ROOT` or HayeOS install path is the Plugin root.
- `.hayeos.json` `memoryPath` resolves to the Memory vault.
- `.hayeos.json` `sourcePath` resolves to the Project root.
- `/haye:start` must show a short path summary:
  - `Project root: ...`
  - `Memory vault: ...`
  - `Plugin root: ...`
- If `Memory vault` is the same as `Plugin root` or resolves under the plugin repository, stop and warn in Turkish: "Memory vault points to plugin root. This is unsafe. Fix .hayeos.json."

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

## Team/Subagent Rule
Subagent and Team Mode behavior is only allowed inside `/haye:work` for large or risky tasks. `/haye:start` must not use subagents, must not enter plan mode and must not trigger Team Mode.

## No Work Loading Rule
`/haye:start` must not load `/haye:work`, must not start task classification, and must not ask broad work questions like task size, risk level or affected layers. Work classification belongs only to `/haye:work`.

## Smart routing
This simplified command may route internally only to:
- `memory-start`
