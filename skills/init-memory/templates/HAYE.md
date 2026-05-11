# HAYE.md

This project uses Haye memory-first workflow.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS komutları Harun için varsayılan olarak Türkçe konuşur.

## Core rules
- Start with `/haye:start`.
- Close with `/haye:close`.
- Do not read the whole vault.
- Do not read `08-raw/` unless explicitly required.
- Do not blindly use `latest` for dependencies.
- Check official advisories when internet is available.
- Record safe dependency decisions in `02-decisions/safe-dependency-versions.md`.

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
