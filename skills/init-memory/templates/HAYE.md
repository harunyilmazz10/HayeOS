# HAYE.md

This project uses Haye memory-first workflow.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

## Core rules
- Start with `/haye:start`.
- Close with `/haye:close`.
- Do not read the whole vault.
- Do not read `08-raw/` unless explicitly required.
- Do not blindly use `latest` for dependencies.
- Check official advisories when internet is available.
- Record safe dependency decisions in `<resolved memoryPath>/02-decisions/safe-dependency-versions.md`.

## Plugin root vs project vault
- `CLAUDE_PLUGIN_ROOT` or the HayeOS install path is plugin code root only.
- `.hayeos.json` `memoryPath` is this project's memory vault and is the single source of truth for memory writes.
- `.hayeos.json` `sourcePath` is this project's source root.
- Context packs, checkpoints, active task, `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md` and `<resolved memoryPath>/changelog.md` must stay inside the resolved project vault.
- Never write project memory into the plugin repository.
- If a target path is under `CLAUDE_PLUGIN_ROOT`, stop and warn: "Bu dosya plugin klasörüne yazılmaya çalışılıyor. Proje vault’u kullanılmalı."

## Smart Work Router
- `/haye:work` classifies `task_size`, `task_type`, `risk_level`, `affected_layers` and `recommended_mode`.
- Small low-risk work uses Fast Mode.
- Medium work uses Standard Mode.
- Large or high-risk work may use Team Mode.
- Massive or production-grade architecture work uses Full Architecture Mode and requires approval before coding.

## Approval Friction Rule
- If a plan or phase is approved, continue small safe steps without asking after every edit.
- Ask at phase boundaries and risk gates only.

## No Fake Completion Rule
- Do not claim "tamamlandı", "geçti", "çalışıyor" or "production-ready" without verification output.
- If build/test/lint/typecheck did not run, say so clearly.

## Output Budget Rule
- Chat cevabını kısa tut; varsayılan 1500-3000 token civarında olsun.
- Büyük işler için 5000-6000 tokenı geçme.
- Büyük mimari, roadmap, servis planı, DB planı, event/queue schema ve deployment planı gibi uzun içerikleri chat'e değil `docs/` veya HayeOS vault dosyalarına yaz.
- Chat'te kısa özet, dosyalar, önemli kararlar, doğrulama durumu, sıradaki 3 adım ve gerekiyorsa onay sorusu ver.
- `/haye:close` sırasında uzun session log basma; memory'ye yaz, chat'te kısa özet ver.

## Quality Preservation Rule
- Token discipline must never reduce implementation quality.
- Do not skip necessary code reading, tests, validation, security checks, error handling, or architecture reasoning just to save tokens.
- Save tokens by reducing verbose chat output, repeated explanations, unnecessary repo scans, huge pasted logs, and oversized reports.
- Detailed technical artifacts should be written to files when needed.
- Chat should be concise, but code and project files must remain complete, maintainable, secure, and production-quality.
- If there is a conflict between token saving and correctness, correctness wins.
- If there is a conflict between speed and safety, safety wins.

## Auto Checkpoint Rule
- HayeOS uzun veya riskli işlerde `/haye:close` beklemeden checkpoint yazar.
- Checkpoint dosyası: `<resolved memoryPath>/05-sessions/latest-checkpoint.md`
- Active task dosyası: `<resolved memoryPath>/04-tasks/active-task.md`
- Checkpoint detayları chat'e basılmaz; dosyaya yazılır.

## Safe Resume Rule
- `/haye:start` latest checkpoint'i okur.
- Kısa recovery özeti verir.
- Kullanıcıdan onay almadan implementation'a devam etmez.

## Scope Control Rule
- Stay inside the approved phase and scope.
- If extra scope is needed, ask: "Bu işlem mevcut scope dışında. Ekleyeyim mi?"

## Token discipline
- Use HayeOS memory first.
- Avoid unnecessary repo scans and raw/log reads.
- Use context packs for big work.
- Keep Team Mode role findings short.
- Split large work into phases/sessions and close with `/haye:close`.

## Framework Security Rule
For React/Next.js projects, Haye must check both dependency advisories and edge/WAF mitigation status. Cloudflare WAF may reduce exposure but vulnerable dependencies must still be patched. Do not mark safe unless dependency patch status and WAF status are documented.
