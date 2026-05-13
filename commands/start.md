---
description: Start from Haye Obsidian memory with minimal context.
---

# /haye:start

Use `skills/start/SKILL.md`.

At the beginning or end of a successful start response, show one concise version line:

```text
HayeOS v<full semantic plugin version> aktif.
```

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

Route only to the lightweight `memory-start` flow when memory already exists.

## Start Light Rule
`/haye:start` must stay lightweight. It may only:
- check whether `.hayeos.json` exists
- read `memoryPath` when config exists
- read minimal memory files: `HAYE.md`, `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, optional `<resolved memoryPath>/04-tasks/active-task.md`, optional `<resolved memoryPath>/05-sessions/latest-checkpoint.md`
- provide a short recovery summary when a checkpoint exists
- ask which task to continue when no checkpoint exists
- ask for init approval when `.hayeos.json` is missing

`/haye:start` must not:
- load `/haye:work`
- start a task classification wizard
- ask "Şimdi hafızayı başlatmamı ister misiniz?" after init
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
If `.hayeos.json` is missing, do not create files automatically. Ask only in Turkish: "Bu projede Haye hafızası bulunamadı. Şimdi otomatik oluşturayım mı?" If the user says yes, run `/haye:init-memory`; if the CLI fails, use the manual fallback from `skills/init-memory/SKILL.md`. After creation succeeds, memory is already considered started; do not ask a second memory-start question. Run only the lightweight memory-start read and ask: "Hangi görevle devam edelim?"

## Canonical Project Vault Rule

HayeOS project memory is local to the current project by default.

Canonical config:

```json
{
  "project": "<project-name>",
  "memoryPath": "./<project-name>_obs",
  "sourcePath": ".",
  "defaultWorkflow": "memory-first",
  "sessionCloseRequired": true
}
```

Canonical vault directory:

```text
<project-root>/<project-name>_obs/
```

The default init flow MUST NOT silently redirect memory to `~/.claude/projects/.../memory`.

The only default authority for creating `.hayeos.json` and the vault layout is `bin/haye init`.

Do NOT manually write `.hayeos.json`.
`/haye:start` must not pre-create `.hayeos.json` with hand-written JSON. The CLI init command is the only source of truth for canonical project config generation.

`/haye:start` must not manually write `.hayeos.json`, manually synthesize `memoryPath`, choose `.claude/projects/.../memory`, or use raw Windows backslash paths.

### Internal Claude project storage is forbidden as HayeOS init target

`~/.claude/projects/<encoded-project-path>/` is Claude Code internal state, not the user's project root.

`/haye:start` must never place `.hayeos.json` or `<project-name>_obs/` there.

The HayeOS project root is the real current working directory where Claude Code was launched. If Claude was launched from `C:\Path\To\Project`, initialization belongs in that folder, not in `~/.claude/projects/...`.

## Safe Resume Rule
If memory exists, read `<resolved memoryPath>/05-sessions/latest-checkpoint.md` when present. Give a short `HayeOS Recovery Summary` with current task, phase, last successful step, changed files, blocker, next 3 actions and recommended next mode. Do not automatically start implementation. Ask: "Son checkpoint'e göre kaldığımız yeri buldum. Devam edeyim mi?" If no checkpoint exists, show a short start summary from `<resolved memoryPath>/next.md` and ask: "Hangi görevle devam edelim?"

## Plugin root vs project vault
- `CLAUDE_PLUGIN_ROOT` veya HayeOS install path sadece plugin code root'tur.
- `.hayeos.json` `memoryPath` current project memory vault yoludur.
- `.hayeos.json` `sourcePath` current project source root yoludur.
- `/haye:start` kısa şekilde `Project root`, `Memory vault`, `Plugin root` gösterir.
- `Memory vault` plugin root ile aynıysa dur ve Türkçe hata ver: "Memory vault points to plugin root. This is unsafe. Fix .hayeos.json."
