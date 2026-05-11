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
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

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
   - `<resolved memoryPath>/current.md`
   - `<resolved memoryPath>/next.md`
   - `<resolved memoryPath>/04-tasks/active-task.md` when present.

## Token discipline
- Do not scan the whole Obsidian vault.
- Do not read `08-raw/` unless explicitly required.
- Do not read the whole repo before a context pack is created.
- Prefer summaries, file paths, root causes, decisions and verification outputs over pasted logs.
- If context is growing, recommend `/clear` plus `/haye:start` after `/haye:close`.

## Workflow
1. Locate project config and memory path.
2. Resolve `memoryPath` and confirm it is not under `CLAUDE_PLUGIN_ROOT`.
3. Read `<resolved memoryPath>/05-sessions/latest-checkpoint.md` when present.
4. Create a concise session summary from the current conversation and checkpoint.
5. Update only memory files under `<resolved memoryPath>`:
   - `<resolved memoryPath>/current.md` for current state.
   - `<resolved memoryPath>/next.md` for the next five actions.
   - `<resolved memoryPath>/changelog.md` for completed changes.
   - `<resolved memoryPath>/health.md` for verification status.
   - `<resolved memoryPath>/05-sessions/` for a dated session handoff when useful.
   - `<resolved memoryPath>/12-risks/` and `<resolved memoryPath>/02-decisions/` when security or dependency decisions changed.
6. Mark `<resolved memoryPath>/05-sessions/latest-checkpoint.md` as `closed` when present.
7. Return only a short close summary.

## Close boundaries
- must not start implementation
- must not create context packs
- must not start a new task
- must not run tests/build/lint unless the user explicitly asked
- must write only under `<resolved memoryPath>`

## Checkpoint finalization
- `<resolved memoryPath>/05-sessions/latest-checkpoint.md` varsa oku.
- Checkpoint içeriğini session summary'ye taşı.
- `<resolved memoryPath>/changelog.md`, `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, `<resolved memoryPath>/health.md` dosyalarını güncelle.
- `<resolved memoryPath>/04-tasks/active-task.md` dosyasını temizle veya sıradaki göreve güncelle.
- `latest-checkpoint.md` dosyasını silme; `Status` alanını `closed` olarak işaretle veya son kapanış durumunu yaz.
- Chat'e uzun log basma; sadece yapılanlar, değişen dosyalar, doğrulama durumu, sıradaki 3 adım ve memory updated files ver.

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

## No Fake Completion Rule
- Session close must distinguish files written, verification run, verification not run, runtime verified, runtime not verified, known gaps and next actions.
- Do not mark work as "hazır", "başarıyla çalışıyor" or "production-ready" unless verification output supports it.
- If verification did not run, say that clearly in the close summary.

## Smart routing
This simplified command may route internally to:
- `session-close`
- `memory-lint`
- `token-audit`
