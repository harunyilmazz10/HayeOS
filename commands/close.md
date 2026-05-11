---
description: Update Haye memory and close the session cleanly.
---

# /haye:close

Use `skills/close/SKILL.md`.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS komutları Harun için varsayılan olarak Türkçe konuşur.

Route to advanced workflows when needed:
- `session-close` to write the handoff.
- `memory-lint` to keep core memory useful.
- `token-audit` when context cleanup is needed.

Summarize work done, files changed, verification output, open risks and next actions into the Obsidian memory vault from `.hayeos.json`.

Update the relevant memory files explicitly:
- `current.md` for the new project state.
- `next.md` for the next five actions.
- `changelog.md` for completed changes.
- `health.md` for verification status.
- `05-sessions/` for the session handoff when useful.

## Checkpoint finalization
If `05-sessions/latest-checkpoint.md` exists, read it, fold it into the session summary, update `changelog.md`, `current.md`, `next.md`, and `active-task.md`, then mark the checkpoint as `closed`. Do not delete it. Chat output stays short: yapılanlar, değişen dosyalar, doğrulama durumu, sıradaki 3 adım, memory updated files.
