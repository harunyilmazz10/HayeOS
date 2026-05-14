---
description: Start a HayeOS session - detect or create project memory vault and summarize prior state.
---

# /haye:start

Use `skills/start/SKILL.md`.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.

## What /haye:start does

1. Detects `.hayeos.json` in current working directory.
2. If present: reads `memoryPath` from it; opens minimal memory files (`HAYE.md`, `current.md`, `next.md`, `04-tasks/active-task.md`, latest session checkpoint).
3. If absent: asks user in Turkish:
   > "Bu projede HayeOS hafızası bulunamadı. Şimdi otomatik oluşturayım mı?"

   On "evet", routes to `Skill(haye:init-memory)`. On "hayır", exits without changes.
4. Reports a one-line summary in Turkish and asks "Hangi görevle devam edelim?".

## Start is lightweight

`/haye:start` must stay light. It only reads:
- `.hayeos.json`
- `<resolved memoryPath>/HAYE.md`
- `<resolved memoryPath>/current.md`
- `<resolved memoryPath>/next.md`
- `<resolved memoryPath>/04-tasks/active-task.md` (optional)
- `<resolved memoryPath>/05-sessions/latest-checkpoint.md` (optional)

It does not scan the whole vault. It does not read `08-raw/`. It does not load source code.

For doing actual work, run `/haye:work` after `/haye:start`.

## Version display (optional)

If user asks for plugin version inline, the start skill may call:

```text
Bash: ${CLAUDE_PLUGIN_ROOT}/bin/haye.cmd version   # Windows
Bash: ${CLAUDE_PLUGIN_ROOT}/bin/haye version       # macOS/Linux
```

Then quote the version line from output. Do not fabricate a version number.

## Removed in v3.0.0

In v2.x, `/haye:start` could chain to a separate `memory-start` skill. v3.0.0 removes that — the minimal memory read happens inline within the start skill.
