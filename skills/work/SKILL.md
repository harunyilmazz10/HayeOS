---
name: work
description: Smart Work Router for development, Team Mode planning, low-friction execution and verification discipline.
---

# Haye Skill: work

## Purpose
`/haye:work "görev"` tek giriş noktasıdır. HayeOS görevi analiz eder, büyüklük/risk/mod seçimini yapar, gerekirse Team Mode veya Full Architecture Mode önerir, onay sürtünmesini düşük tutar ve doğrulama disipliniyle ilerler.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS komutları Harun için varsayılan olarak Türkçe konuşur.

## Inputs to inspect first
1. `.hayeos.json` if present.
2. Memory root from `memoryPath`.
3. Minimal memory only:
   - `HAYE.md`
   - `index.md`
   - `current.md`
   - `next.md`
   - `04-tasks/active-task.md` when present.
4. Task prompt and any explicit scope/phase limits.

## Smart Work Router
Classify every meaningful task before acting:

- `task_size`: `small`, `medium`, `large`, `massive`
- `task_type`: `feature`, `bugfix`, `refactor`, `architecture`, `security`, `deploy`, `research`, `bootstrap`, `documentation`, `media-pipeline`, `AI-system`
- `risk_level`: `low`, `medium`, `high`
- `affected_layers`: `frontend`, `backend`, `database`, `infra`, `AI`, `security`, `deployment`, `media pipeline`, `queue/event system`, `storage`, `analytics`
- `recommended_mode`: `fast`, `standard`, `team`, `full-architecture`

## Mode selection
- Fast Mode: `small` + `low risk`. Kısa planla direkt uygula. Kullanıcıya gereksiz onay sorma.
- Standard Mode: `medium`. Kısa plan + implementation + verification yap. Sadece belirsiz veya riskli yerde sor.
- Team Mode: `large` veya `high risk`. Türkçe sor: "Bu görev büyük/riskli görünüyor. Uzman rollere bölerek Team Mode ile önce plan çıkarayım mı?"
- Full Architecture Mode: `massive`, sıfırdan büyük sistem veya geniş production-grade mimari. Kodlamadan önce detaylı mimari çıkar ve kullanıcı onayı olmadan kodlamaya başlama.

## Internal workflow routing
Kullanıcı her şeyi `/haye:work` ile verebilir. Kullanıcıyı sürekli başka komuta yönlendirme.

- Bug/debug işi ise `/haye:fix` mantığını içeride uygula ve "Bu görev için fix workflow uyguluyorum" de.
- Security/dependency/auth işi ise `/haye:secure` mantığını içeride uygula.
- Deploy/release işi ise `/haye:ship` veya deploy mantığını içeride uygula.
- Büyük mimari ise Team Mode veya Full Architecture Mode öner.
- Non-trivial işler için `context-pack` oluşturmayı öner veya uygula; gereksiz repo taraması yapma.

## Team Mode
Team Mode sadece `/haye:work` içinde internal moddur. Ayrı user-facing `/haye:team` komutu yoktur. Gerekirse `skills/team-mode/SKILL.md` içindeki yapıyı kullan.

Team Mode kullanılacağı durumlar:
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

Team Mode rolleri:
- `project-manager`: işi phase'lere böler, roadmap çıkarır, scope kontrolü yapar.
- `memory-architect`: HayeOS/Obsidian memory update planı çıkarır.
- `database-architect`: schema, migration, data model, indexing, retention planı çıkarır.
- `api-integrator`: API boundary, service contract, queue/event ve integration noktalarını çıkarır.
- `security-reviewer`: auth, dependency, secrets, exposed ports, abuse, permissions, webhook, payment risklerini kontrol eder.
- `deployment-doctor`: Docker, Coolify, Cloudflare, env, healthcheck, rollback, observability planı çıkarır.
- `ui-polisher`: frontend/dashboard/UX gerekiyorsa UI/UX kalite planı çıkarır.
- `bug-investigator`: iş hata/debug içeriyorsa root-cause workflow önerir.
- `release-manager`: test, release, ship, rollback, verification checklist çıkarır.
- `token-economist`: her Team Mode'da zorunludur; context şişmesini engeller.

Team Mode role findings kısa olmalı: her rol en fazla 3-7 uygulanabilir madde yazar, uzun teori ve tekrar yok.

## Team Mode output format
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

## 4. Unified Implementation Plan

## 5. Risks & Assumptions

## 6. Verification Plan

## 7. HayeOS Memory Update Plan

## 8. Approval Question
Bu planı onaylıyor musun? Onaylarsan Phase X ile başlayacağım.
```

## Full Architecture Mode
Full Architecture Mode şu durumlarda önerilir:
- kullanıcı "sıfırdan proje" derse
- kullanıcı "complete production-grade system" derse
- kullanıcı "multi-service", "AI operating system", "distributed architecture", "microservices", "Kubernetes", "24/7" derse
- büyük media/AI/infra sistemi istiyorsa

Full Architecture Mode output:
1. Project Understanding
2. Architecture Overview
3. Service Map
4. Data Flow
5. Event Flow
6. Database Plan
7. Queue Plan
8. Storage Plan
9. AI Pipeline Plan
10. Monitoring Plan
11. Security Plan
12. Deployment Plan
13. Scaling Plan
14. HayeOS Memory Usage Plan
15. Phased Implementation Roadmap
16. First Implementation Plan
17. Approval Question

Kodlamaya başlamadan önce onay iste.

## Approval Friction Rule
Kullanıcı bir planı veya phase'i onayladıysa, HayeOS o phase içindeki küçük ve güvenli işleri kullanıcıya tekrar tekrar sormadan tamamlar.

Küçük güvenli işler için sorma:
- klasör oluşturma
- yeni stub dosya ekleme
- docs güncelleme
- basit config ekleme
- README güncelleme
- service placeholder oluşturma
- route stub oluşturma
- test placeholder oluşturma
- internal refactor
- HayeOS memory'ye kısa not yazma

Phase içinde küçük adımlar arasında "Devam ediyorum: sıradaki adım ..." diye ilerle.

Phase sonunda sor:
"Phase X tamamlandı. Yapılanlar: ... Sıradaki phase'e geçeyim mi?"

## When HayeOS asks for approval
Onay sadece şu risk kapılarında istenir:
1. destructive işlem: dosya silme, büyük overwrite, reset, clean, wipe
2. database migration: migration oluşturma, schema breaking change, data loss riski
3. dependency değişimi: install, update, remove
4. security/auth/payment/permission değişikliği
5. deploy veya production config değişikliği
6. secret/env işlemleri
7. büyük mimari yön değişikliği
8. scope dışına çıkma
9. maliyet doğurabilecek API/GPU/cloud işlemi
10. kullanıcı açıkça "önce sor" dediyse

## Scope Control Rule
- Kullanıcı "Phase 0 ve Phase 1" dediyse Phase 2'ye geçmeden sor.
- Kullanıcı belirli kapsam verdiyse scope dışına çıkma.
- Scope dışına çıkmak gerekiyorsa Türkçe sor: "Bu işlem mevcut scope dışında. Ekleyeyim mi?"

## Cost / Risk Gate
Şu işlemlerden önce onay şart:
- paid API kullanımı
- GPU gerektiren işlem
- cloud resource oluşturma
- external service hesabı/config oluşturma
- webhook canlı bağlantısı
- gerçek deploy
- production secret kullanımı
- gerçek upload/publish işlemi
- YouTube/TikTok/Instagram API canlı çağrısı

## No Fake Completion Rule
HayeOS doğrulama çıktısı olmadan "çalışıyor", "tamamlandı", "geçti", "production-ready", "başarılı" demesin.

Eğer build/test/lint/typecheck çalışmadıysa açıkça yaz:
- "Build çalıştırılmadı."
- "Test çalıştırılmadı."
- "Lint çalıştırılmadı."
- "Bu sadece yapılandırma/iskelet seviyesinde doğrulandı."
- "Gerçek runtime doğrulaması henüz yapılmadı."

Her meaningful işte Verification Plan olsun.

Phase sonunda rapor:
```markdown
## Verification Status
- commands run:
- passed:
- failed:
- not run:
- reason if not run:
```

## Token discipline
Büyük işlerde:
- önce HayeOS memory kullan
- gereksiz repo tarama yapma
- raw/log klasörlerini okuma
- context-pack oluştur
- agent raporlarını kısa tut
- aynı bilgiyi tekrar etme
- büyük işi phase/session parçalara böl
- phase sonunda `/haye:close` öner
- eski konuşmayı uzatmak yerine memory update öner

Team Mode'da `token-economist` her zaman dahil edilir.

## Output format for non-Team work
- Task Classification
- Selected Mode
- Plan
- Implementation Summary
- Verification Plan
- Verification Status
- Risks / Scope Notes
- HayeOS Memory Update Needed

## Safety rules
- Destructive commands require explicit approval.
- Dependency install/update/remove requires approval.
- Do not claim completion without verification output or an explicit limitation note.
