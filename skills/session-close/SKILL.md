---
name: session-close
description: Close a session by updating Obsidian memory, changelog, next actions, decisions, bugs and verification notes.
---

# Haye Skill: session-close

## Purpose
Close a session by updating Obsidian memory, changelog, next actions, decisions, bugs and verification notes.

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
2. Resolve Memory vault from `.hayeos.json` `memoryPath` relative to current project root.
3. Only minimal memory files:
   - `HAYE.md`
   - `index.md`
   - `<resolved memoryPath>/current.md`
   - `<resolved memoryPath>/next.md`
   - `<resolved memoryPath>/04-tasks/active-task.md` when present.

## Project vault write rule
- Session summaries, checkpoint finalization, `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, `<resolved memoryPath>/changelog.md`, `<resolved memoryPath>/health.md` and `<resolved memoryPath>/04-tasks/active-task.md` are written only under resolved `.hayeos.json` `memoryPath`.
- Never write session memory into `CLAUDE_PLUGIN_ROOT`.
- If a target path resolves under the plugin installation directory, stop and warn: "Bu dosya plugin klasörüne yazılmaya çalışılıyor. Proje vault’u kullanılmalı."

## Token discipline
- Do not scan the whole Obsidian vault.
- Do not read `08-raw/` unless explicitly required.
- Do not read the whole repo before a context pack is created.
- Prefer summaries, file paths, root causes, decisions and verification outputs over pasted logs.
- If context is growing, recommend `/clear` plus `/haye:start` after `/haye:close`.

## Output Budget Rule
- `/haye:close` sırasında uzun session log basma.
- Uzun ayrıntıları HayeOS memory dosyalarına yaz: `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, `<resolved memoryPath>/changelog.md`, `<resolved memoryPath>/health.md`, `<resolved memoryPath>/05-sessions/`, `<resolved memoryPath>/02-decisions/`, `<resolved memoryPath>/12-risks/`.
- Chat'te kısa özet, değişen dosyalar, önemli kararlar, doğrulama durumu, sıradaki 3 adım ve gerekiyorsa onay sorusu ver.
- Büyük kapanış raporu 5000-6000 tokenı geçecekse dosyaya yaz ve chat'te dosya yolunu göster.

## Workflow
1. Locate project config and memory path.
2. Read minimal memory.
3. Identify task type, risks and affected files.
4. Create or reuse a context pack when work is non-trivial.
5. Execute the smallest safe step.
6. Verify with real commands when possible.
7. Update memory through `/haye:close` or session-close rules.

## Checkpoint finalization
- `<resolved memoryPath>/05-sessions/latest-checkpoint.md` varsa oku.
- Session summary dosyasına checkpoint'in current task, phase, completed steps, changed files, verification status, blockers, risks ve next 3 actions alanlarını taşı.
- `latest-checkpoint.md` dosyasını silme; `Status` alanını `closed` yap.
- `<resolved memoryPath>/04-tasks/active-task.md` dosyasını kapatılan göreve göre temizle veya sıradaki görevle güncelle.
- Chat'te uzun session log basma; detayları memory dosyalarına yaz.

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
