---
description: Start from Haye Obsidian memory with minimal context.
---

# /haye:start

Use `skills/start/SKILL.md`.

At the beginning or end of a successful start response, show one concise version line:

```text
HayeOS aktif. (Sürüm için: `/haye:version`)
```

### Version display

If the user wants the active version inline, you may call:

```text
Bash: ${CLAUDE_PLUGIN_ROOT}/bin/haye.cmd version
# (Windows)
```

or

```text
Bash: ${CLAUDE_PLUGIN_ROOT}/bin/haye version
# (Mac/Linux)
```

Then quote the version line from that output. Do NOT fabricate a version number. Do NOT use a placeholder like `v<...>`.

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
If `.hayeos.json` is missing, do not create files automatically. Ask only in Turkish: "Bu projede Haye hafızası bulunamadı. Şimdi otomatik oluşturayım mı?"

When the user says yes (any of: "evet", "yes", "ok", "tamam", "olur"):

1. IMMEDIATELY call `Skill(haye:init-memory)`. Do not use the Write tool to create `.hayeos.json` or any vault file directly.
2. Do not enumerate vault folders inline; the init-memory skill handles that.
3. Do not say "Memory başarıyla oluşturuldu" before init-memory has actually run and reported success.
4. If init-memory fails or returns an error, report the exact failure and ask the user how to proceed.

**Direct file writes for vault setup are forbidden in this skill.** The init-memory skill is the only authorized path. This includes:
- DO NOT `Write(.hayeos.json)` with hand-written JSON
- DO NOT `Write(<vault>/HAYE.md)` with manual content
- DO NOT `Write(<resolved memoryPath>/current.md)`, `<resolved memoryPath>/next.md`, etc.
- ALL of these go through `Skill(haye:init-memory)`.

Legacy `/haye:init-memory` wording is only a user-facing command name; the required continuation is the Skill tool call above.

After init-memory reports success, memory is already considered started. Do not ask a second memory-start question. Run only the lightweight memory-start read and ask: "Hangi görevle devam edelim?"

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
