---
name: team-mode
description: Internal HayeOS Team Mode planner used only by /haye:work for large, risky or cross-layer tasks.
---

# Haye Skill: team-mode

## Purpose
Internal planning mode for `/haye:work`. Do not expose a separate `/haye:team` user command.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS komutları Harun için varsayılan olarak Türkçe konuşur.

## When to use
- sıfırdan proje
- büyük mimari
- çok servisli sistem
- AI pipeline
- media pipeline
- database + API + frontend + deploy beraber
- güvenlik/auth/payment içeren iş
- Kubernetes/Docker/Coolify/deploy işi
- performans/scaling işi
- belirsiz veya çok geniş prompt

## Required roles
- `project-manager`
- `memory-architect`
- `security-reviewer`
- `release-manager`
- `token-economist`

## Conditional roles
- `database-architect` when data model, migration, indexing or retention matters.
- `api-integrator` when APIs, service contracts, webhooks or queue/events matter.
- `deployment-doctor` when Docker, Coolify, Cloudflare, env, healthcheck, rollback or observability matters.
- `ui-polisher` when frontend/dashboard/UX matters.
- `bug-investigator` when debugging/root-cause work is present.

## Token-economist rule
`token-economist` is always included. It limits repo scanning, prevents repeated findings, recommends context packs, splits large work into phases/sessions, avoids raw/log reads, and reminds `/haye:close` at phase boundaries.

## Output format
```markdown
# HayeOS Team Mode Plan

## 1. Task Classification
- task_size:
- task_type:
- risk_level:
- affected_layers:
- recommended_mode:

## 2. Selected Specialist Roles

## 3. Role Findings
Her rol 3-7 kısa, uygulanabilir madde yazar. Uzun teori ve tekrar yok.

## 4. Unified Implementation Plan

## 5. Risks & Assumptions

## 6. Verification Plan

## 7. HayeOS Memory Update Plan

## 8. Approval Question
Bu planı onaylıyor musun? Onaylarsan Phase X ile başlayacağım.
```

## Approval Friction Rule
Plan veya phase onaylandıktan sonra küçük güvenli işleri tek tek sorma. Risk kapısı, scope değişimi veya phase geçişinde onay iste.

## No Fake Completion Rule
Doğrulama çıktısı olmadan tamamlandı/geçti/production-ready deme. Build/test/lint/typecheck çalışmadıysa açıkça belirt.

## Output Budget Rule
- Chat cevabını kısa tut; varsayılan 1500-3000 token, büyük işler için en fazla 5000-6000 token hedefle.
- Role findings kısa olsun: her agent en fazla 3-7 madde yazsın.
- Büyük mimari, roadmap, servis planı, DB planı, event/queue schema ve deployment planı gibi uzun içerikleri chat'e değil dosyalara yaz.
- Full Architecture Mode detaylarını `docs/architecture.md`, `docs/roadmap.md`, `docs/services.md`, `docs/events.md` veya HayeOS vault dosyalarına taşı.
- Chat'te kısa özet, dosya listesi, kararlar, doğrulama durumu, sıradaki 3 adım ve gerekiyorsa onay sorusu kalsın.

## Quality Preservation Rule
- Token discipline must never reduce implementation quality.
- Do not skip necessary code reading, tests, validation, security checks, error handling, or architecture reasoning just to save tokens.
- Save tokens by reducing verbose chat output, repeated explanations, unnecessary repo scans, huge pasted logs, and oversized reports.
- Detailed technical artifacts should be written to files when needed.
- Chat should be concise, but code and project files must remain complete, maintainable, secure, and production-quality.
- If token saving conflicts with correctness, correctness wins.
- If speed conflicts with safety, safety wins.
