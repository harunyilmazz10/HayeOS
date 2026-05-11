---
description: Start from Haye Obsidian memory with minimal context.
---

# /haye:start

Use `skills/start/SKILL.md`.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS komutları Harun için varsayılan olarak Türkçe konuşur.

Route only to the lightweight `memory-start` flow when memory already exists.

## Start Light Rule
`/haye:start` must stay lightweight. It may only:
- check whether `.hayeos.json` exists
- read `memoryPath` when config exists
- read minimal memory files: `HAYE.md`, `current.md`, `next.md`, optional `04-tasks/active-task.md`, optional `05-sessions/latest-checkpoint.md`
- provide a short recovery summary when a checkpoint exists
- ask which task to continue when no checkpoint exists
- ask for init approval when `.hayeos.json` is missing

`/haye:start` must not:
- use subagents
- enter plan mode
- scan the whole repository
- perform codebase exploration
- search test patterns
- produce an automatic project plan
- create `.hayeos.json` without explicit user approval
- write project files before the user says yes to init

Do not read the full repository or `08-raw/` by default. Inspect `.hayeos.json`, locate `memoryPath`, read only core memory files, then ask the next lightweight Turkish question.

## Init Confirmation Rule
If `.hayeos.json` is missing, do not create files automatically. Ask only in Turkish: "Bu projede Haye hafızası bulunamadı. Şimdi otomatik oluşturayım mı?" If the user says yes, run `/haye:init-memory`; if the CLI fails, use the manual fallback from `skills/init-memory/SKILL.md`. After creation succeeds, run only the lightweight memory-start read.

## Safe Resume Rule
If memory exists, read `05-sessions/latest-checkpoint.md` when present. Give a short `HayeOS Recovery Summary` with current task, phase, last successful step, changed files, blocker, next 3 actions and recommended next mode. Do not automatically start implementation. Ask: "Son checkpoint'e göre kaldığımız yeri buldum. Devam edeyim mi?" If no checkpoint exists, show a short start summary from `next.md` and ask: "Hangi görevle devam edelim?"

## Plugin root vs project vault
- `CLAUDE_PLUGIN_ROOT` veya HayeOS install path sadece plugin code root'tur.
- `.hayeos.json` `memoryPath` current project memory vault yoludur.
- `.hayeos.json` `sourcePath` current project source root yoludur.
- `/haye:start` kısa şekilde `Project root`, `Memory vault`, `Plugin root` gösterir.
- `Memory vault` plugin root ile aynıysa dur ve Türkçe hata ver: "Memory vault points to plugin root. This is unsafe. Fix .hayeos.json."
