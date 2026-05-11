---
name: memory-start
description: Start a Claude Code session from Haye Obsidian memory with minimal context. Use after /clear or at the beginning of work.
---

# Haye Skill: memory-start

## Purpose
Start a Claude Code session from Haye Obsidian memory with minimal context. Use after /clear or at the beginning of work.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

## When to use
- Use when the user's request matches this workflow.
- Use when the current project has `.hayeos.json` or an Obsidian memory vault.
- Use instead of loading a huge old conversation or scanning the entire repository.

## Inputs to inspect first
1. `.hayeos.json` if present.
2. Resolve Memory vault from `.hayeos.json` `memoryPath` relative to current project root.
3. Keep Plugin root and Memory vault separate: `CLAUDE_PLUGIN_ROOT` is plugin code, not project memory.
4. Only minimal memory files:
   - `HAYE.md`
   - `index.md`
   - `<resolved memoryPath>/current.md`
   - `<resolved memoryPath>/next.md`
   - `<resolved memoryPath>/04-tasks/active-task.md` when present.

If the Memory vault resolves to the Plugin root or under the plugin repository, stop and warn: "Memory vault points to plugin root. This is unsafe. Fix .hayeos.json."

## Token discipline
- Do not scan the whole Obsidian vault.
- Do not read `08-raw/` unless explicitly required.
- Do not read the whole repo before a context pack is created.
- Prefer summaries, file paths, root causes, decisions and verification outputs over pasted logs.
- If context is growing, recommend `/clear` plus `/haye:start` after `/haye:close`.

## Workflow
1. Read `.hayeos.json` from the current project root.
2. Resolve `memoryPath` relative to the current project root.
3. Confirm Plugin root and Memory vault are separate. If the Memory vault points to the plugin root, stop.
4. Read only minimal memory:
   - `HAYE.md`
   - `index.md`
   - `<resolved memoryPath>/current.md`
   - `<resolved memoryPath>/next.md`
   - `<resolved memoryPath>/04-tasks/active-task.md` when present
   - `<resolved memoryPath>/05-sessions/latest-checkpoint.md` when present
5. If `<resolved memoryPath>/05-sessions/latest-checkpoint.md` exists, provide a short recovery summary.
6. If a checkpoint exists, ask: "Kaldığımız yerden devam edeyim mi?"
7. If no checkpoint exists, ask: "Hangi görevle devam edelim?"

## Memory-start boundaries
- must not execute implementation
- must not create context packs
- must not run tests/build/lint
- must not load `/haye:work`
- must not start a task classification wizard
- must not scan the repository
- must not write `<resolved memoryPath>/04-tasks/active-task.md`
- must not write `<resolved memoryPath>/05-sessions/latest-checkpoint.md`

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
