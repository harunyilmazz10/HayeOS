---
description: End a HayeOS work block - update changelog, current, next, and session checkpoint in the memory vault.
---

# /haye:close

Use `skills/close/SKILL.md`.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.

## What /haye:close does

End-of-session vault update. The close skill handles all of these inline (no sub-skill dispatch in v3.0.0):

1. **Update changelog/current/next** — appends a session entry to `<resolved memoryPath>/changelog.md`, refreshes `<resolved memoryPath>/current.md` with the new focus, updates `<resolved memoryPath>/next.md` with next concrete actions.

2. **Write latest-checkpoint** — saves full session state snapshot to `<resolved memoryPath>/05-sessions/latest-checkpoint.md` with completed tasks, files touched, verification results, open risks, next actions.

3. **Vault lint** (optional) — flags `current.md` over 150 lines, stale `04-tasks/active-task.md`, orphan files in `08-raw/`. Reports findings without auto-rewriting.

After all three, reports in Turkish: "Hafıza güncellendi, session kapanabilir."

## When to run /haye:close

- End of a meaningful work block (feature complete, phase done, day ending).
- Before `/clear` when context is heavy.
- Before any handoff to another session or developer.
- After verification commands have run and results are known.

## Close boundaries

- Must not start implementation.
- Must not create new tasks (just close the current one).
- Must not run tests/build/lint unless the user explicitly asks.
- Must write only under `<resolved memoryPath>/`.

## No Fake Completion Rule

Close summary must distinguish:
- files written
- verification run vs not run
- runtime verified vs not verified
- known gaps
- next actions

Do not mark work as "hazır", "başarıyla çalışıyor", or "production-ready" unless verification output supports it. If verification did not run, say so explicitly.

## Removed in v3.0.0

In v2.x, `/haye:close` chained to separate `session-close`, `memory-lint`, and `handoff` skills. v3.0.0 removes those — the close skill handles everything inline.
