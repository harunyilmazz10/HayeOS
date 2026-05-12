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
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

## Inputs to inspect first
1. `.hayeos.json` if present.
2. Resolve Memory vault from `.hayeos.json` `memoryPath` relative to current project root.
3. Treat `CLAUDE_PLUGIN_ROOT` as plugin code root only.
4. Minimal memory only:
   - `HAYE.md`
   - `index.md`
   - `<resolved memoryPath>/current.md`
   - `<resolved memoryPath>/next.md`
   - `<resolved memoryPath>/04-tasks/active-task.md` when present.
5. Task prompt and any explicit scope/phase limits.

## Project vault write rule
- Project memory, context packs, checkpoints, active task, `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, `<resolved memoryPath>/changelog.md` and session summaries must be written only under resolved `.hayeos.json` `memoryPath`.
- Never write project memory into `CLAUDE_PLUGIN_ROOT` or the HayeOS plugin repository.
- If any target path resolves under `CLAUDE_PLUGIN_ROOT`, stop and warn in Turkish: "Bu dosya plugin klasörüne yazılmaya çalışılıyor. Proje vault'u kullanılmalı."

## Smart Work Router
Classify every meaningful task before acting:

- `task_size`: `small`, `medium`, `large`, `massive`
- `task_type`: `quick fix`, `feature`, `refactor`, `architecture`, `full system`, `security`, `deployment`, `debugging`, `research/planning`
- `risk_level`: `low`, `medium`, `high`
- `affected_layers`: `frontend`, `backend`, `database`, `infra`, `AI pipeline`, `security`, `deployment`, `docs`, `tests`
- `recommended_mode`: `Fast Single Agent`, `Standard Single Agent`, `Plan First`, `Team Mode`, `Full Architecture Mode`

## Work Strategy Selection Rule
`/haye:work` must classify the task first, then decide whether to proceed directly or ask the user to choose a work strategy. It must not silently choose single-agent vs subagent/team behavior for large or ambiguous work.

## Massive Task Classification Rule
If the prompt includes signals like `production-grade`, `complete system`, `autonomous`, `multi-service`, `microservices`, `24/7`, `scale horizontally`, `Kubernetes`, `monitoring`, `analytics`, `AI pipeline`, `full architecture`, `from scratch`, many services, Phase 0/1/2 roadmap, or backend + frontend + infra + AI + monitoring together, classify it as `massive`.

For massive tasks:
- `recommended_mode` = `Full Architecture Mode`
- Team Mode internally enabled
- `token-economist` mandatory
- `security-reviewer` mandatory
- `deployment-doctor` mandatory
- `database-architect` mandatory when DB exists
- no coding before plan approval

## Team Mode Offer Rule
For massive or high-risk work, the first response must:
1. Show classification: `task_size`, `task_type`, `risk_level`, `affected_layers`, `recommended_mode`.
2. Show a short Team Mode plan with `project-manager`, `memory-architect`, `database-architect`, `api-integrator`, `security-reviewer`, `deployment-doctor`, `release-manager`, `token-economist`.
3. Ask in Turkish: "Bu iş massive/high-risk görünüyor. Önerim Full Architecture Mode + Team Mode. Onaylıyor musunuz?"
4. If the prompt already explicitly says "Full Architecture Mode kullan" or similar, skip the strategy question and move to planning.
5. Keep each specialist contribution to 3-7 bullets and write details to files.

### Modes
1. Fast Single Agent
   - Small + low-risk work.
   - Quick implementation.
   - Very little planning.
   - No unnecessary subagent.
2. Standard Single Agent
   - Medium-sized work.
   - Short plan + implementation + verification.
   - Read only necessary files.
3. Plan First
   - Produce only architecture/implementation plan.
   - Do not write code.
   - Wait for user approval before implementation.
4. Team Mode
   - Large, multi-layer or risky work.
   - Use short specialist perspectives: `project-manager`, `memory-architect`, `database-architect`, `api-integrator`, `security-reviewer`, `deployment-doctor`, `release-manager`, `token-economist`.
   - `token-economist` is always included.
   - `security-reviewer` is required for high-risk work.
   - `deployment-doctor` is required when infra/deploy is affected.
   - `database-architect` is required when DB is affected.
   - Write details to `docs/` or HayeOS vault; keep chat concise.
5. Full Architecture Mode
   - Massive, production-grade, multi-service, AI pipeline, infra, monitoring or deployment-heavy work.
   - Produce plan + docs first.
   - Ask approval before coding.
   - After approval, start only Phase 0/1 unless the user expands scope.

### When to ask
Ask a short Turkish strategy question when:
- `task_size` is `large` or `massive`
- `risk_level` is `high`
- backend + frontend + infra are all affected
- dependency/security/deploy is involved
- starting a project from scratch
- the prompt includes signals such as `production-grade`, `complete system`, `microservices`, `AI pipeline`, `Kubernetes`, `24/7`, `scale`
- the prompt is a very long master prompt
- scope is unclear

Question format:

```text
Bu iş [task_size] ve [risk_level] görünüyor. Önerim: [recommended_mode].
Nasıl ilerleyeyim?

1. Önerilen modla devam et
2. Sadece plan çıkar
3. Tek agent ile hızlı ilerle
4. Daha küçük bir MVP'ye indir
```

### When not to ask
Do not ask for small + low-risk work such as tiny bug fixes, single-file edits, small text changes, simple config fixes, docs typos or small UI polish. Use Fast Single Agent, give a short summary, avoid subagents and avoid repeated approvals.

### If the user already selected a mode
If the prompt explicitly says `Full Architecture Mode kullan`, `Team Mode kullan`, `tek agent ile yap`, `sadece plan çıkar`, `hızlıca düzelt` or `Phase 0/1 ile başla`, do not ask strategy again. Briefly confirm in Turkish, for example: "Full Architecture Mode ile ilerliyorum. Önce planı dosyalara yazacağım, kodlamaya başlamadan önce onay isteyeceğim."

## Original Prompt Preservation Rule
Large, massive, architecture and full-system `/haye:work` requests must preserve the original user prompt verbatim before planning, Team Mode synthesis, Full Architecture Mode docs or implementation.

- Resolve `.hayeos.json` `memoryPath` relative to the current project root.
- Write prompt records only under `<resolved memoryPath>/01-prompts/`.
- For the first large master prompt, write `<resolved memoryPath>/01-prompts/initial-master-prompt.md`.
- For later work prompts, write `<resolved memoryPath>/01-prompts/work-request-YYYY-MM-DD-HHMM.md`.
- The prompt record must contain:
  1. Timestamp
  2. Task classification summary
  3. Original prompt verbatim
  4. Optional short normalized brief
- The `Original prompt verbatim` section must preserve the user's prompt exactly, without summarizing, correcting, translating or normalizing it.
- If the user prompt contains sensitive content, preserve only what the user provided; do not invent or enrich secrets.
- Small one-line bugfix tasks do not require prompt preservation.
- Never write prompt records to `CLAUDE_PLUGIN_ROOT`, the plugin repo, or project root.

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

Team Mode kullanıcıya kısa görünmelidir:

```text
Team Mode aktif:
- project-manager: scope/phase
- database-architect: data model
- api-integrator: service/API boundaries
- security-reviewer: risk/dependency
- deployment-doctor: docker/deploy
- token-economist: context/output budget
```

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

## Full Architecture Mode Gate
Massive projects must generate planning artifacts into files before implementation and must not dump the full plan into chat.

Required planning artifacts:
- Project Understanding
- Architecture Overview
- Service Map
- Data Flow
- Event Flow
- Database Plan
- Queue Plan
- Storage Plan
- AI Pipeline Plan
- Monitoring Plan
- Security Plan
- Deployment Plan
- HayeOS Memory Usage Plan
- Phased Implementation Roadmap
- First Implementation Plan

Preferred files: `docs/architecture.md`, `docs/roadmap.md`, `docs/services.md`, `docs/events.md`, `docs/database.md`, `docs/deployment.md`, `docs/security.md`, `docs/monitoring.md`, `docs/operations.md`, `docs/ai-pipeline.md`, `docs/queues.md`, `docs/storage.md`.

After planning, provide a short chat summary, created/changed files, verification status and ask for coding approval. Do not start coding before approval.

## Approval Friction Rule
Kullanıcı strategy approval, plan veya phase'i onayladıysa, HayeOS o phase içindeki küçük ve güvenli işleri kullanıcıya tekrar tekrar sormadan tamamlar.

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

## No Placeholder Production Rule
Full Architecture Mode veya production-grade işte yüzeysel placeholder'ı production foundation gibi sunma:
- Hello world / Merhaba dünya ile production foundation tamamlandı deme.
- `myapp:latest` kullanma.
- `your-*-image` veya `placeholder-image` gibi fake image adı kullanma.
- Docker Compose top-level `version` yazma.
- `python:3.8` kullanma.
- Executable commands içinde `./path/to/...` veya `/path/to/...` gibi fake path kullanma.
- Sadece `assert True` test yazma.
- Massive architecture için 2-line docs yazıp yeterli sayma.
- 5 satırlık yüzeysel docs ile yetinme.

Eğer skeleton yazıyorsan açıkça skeleton olduğunu söyle, production-ready olmadığını belirt ve verification status alanını dürüst yaz.

## Foundation Quality Gate
Production-grade foundation iddiası için gerçek yapı, doğru config, anlamlı test, security/dependency değerlendirmesi, dokümante edilmiş verification status ve rollback/next steps gerekir. Bu gate geçmeden "Aşama tamamlandı", "production-ready", "temel işlevsellik sağlandı", "hazır" veya "başarıyla çalışıyor" deme. Bu kanıtlar yoksa yalnızca "skeleton" veya "plan" de.

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

Separate these in every report:
- files written
- verification run
- verification not run
- runtime verified
- runtime not verified
- known gaps
- next actions

Do not say "temel işlevsellik sağlandı", "production-ready tamamlandı", "başarıyla çalışıyor" or "hazır" unless verification proves it. If only files were written, say: "Dosyalar oluşturuldu; henüz test/build/runtime doğrulaması yapılmadı."

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

## Output Budget Rule
- Chat cevabını kısa tut.
- Varsayılan chat cevabı 1500-3000 token civarında olsun.
- Büyük işler için maksimum 5000-6000 tokenı geçme.
- 64000 output token hatasına yol açabilecek uzun çıktıları chat'e basma.
- Büyük mimari, roadmap, servis planı, DB planı, event schema, queue schema, deployment planı gibi uzun içerikleri chat'e değil dosyalara yaz.
- Detaylı içerikler için `docs/` veya HayeOS vault içinde uygun dosyaları kullan.
- Chat'te sadece şunları ver: kısa özet, değişen/oluşan dosyalar, önemli kararlar, doğrulama durumu, sıradaki 3 adım ve gerekiyorsa onay sorusu.
- If output would become long, prefer writing the detailed content to `docs/` or the HayeOS vault and provide a concise chat summary. Ask for continuation only if the user explicitly requested a long multi-part chat response.
- Team Mode agent çıktıları kısa olmalı; her agent en fazla 3-7 madde yazmalı.
- Full Architecture Mode detayları `docs/architecture.md`, `docs/roadmap.md`, `docs/services.md`, `docs/events.md` gibi dosyalara yazmalı; chat'e tamamını basmamalı.
- `/haye:close` sırasında uzun session log basma; memory'ye yaz, chat'te kısa özet ver.

## Output Budget + Quality Docs Rule
- Chat concise.
- Docs comprehensive.
- Do not make docs shallow to save tokens.
- Long technical detail goes to files.
- Massive `docs/architecture.md` should include goals/non-goals, high-level architecture, service boundaries, data flow, event flow, storage decisions, scaling strategy, reliability strategy, security considerations and MVP vs production roadmap.

## Dependency Security and Risk Gate Rule
- Dependency install/update/remove is a risk gate.
- Ask before `pip install`, `python -m pip install`, `py -m pip install`, `npm install`, `pnpm add`, `yarn add`, `docker pull` or Docker commands that pull unknown images.
- Before `docker compose up`, check compose has no fake images, build contexts exist, referenced Dockerfiles exist, no top-level obsolete `version` field and no `latest` tags unless explicitly justified.
- Do not assume `pip` exists on Windows.
- Never blindly use latest versions.

## Quality Preservation Rule
- Token discipline must never reduce implementation quality.
- Do not skip necessary code reading, tests, validation, security checks, error handling, or architecture reasoning just to save tokens.
- Save tokens by reducing verbose chat output, repeated explanations, unnecessary repo scans, huge pasted logs, and oversized reports.
- Detailed technical artifacts should be written to files when needed.
- Chat should be concise, but code and project files must remain complete, maintainable, secure, and production-quality.
- If there is a conflict between token saving and correctness, correctness wins.
- If there is a conflict between speed and safety, safety wins.

## Auto Checkpoint Rule
HayeOS `/haye:work` sırasında `/haye:close` beklemeden checkpoint yazar.

Checkpoint file locations under resolved `memoryPath`:
- `<resolved memoryPath>/05-sessions/latest-checkpoint.md`
- `<resolved memoryPath>/04-tasks/active-task.md`
- `<resolved memoryPath>/current.md`
- `<resolved memoryPath>/next.md`

Checkpoint şu durumlarda mutlaka yazılır:
1. phase başında
2. phase sonunda
3. 5 veya daha fazla dosya oluşturulduğunda/değiştirildiğinde
4. dependency/security/deploy işlemi öncesinde
5. docker/build/test/lint/typecheck komutundan önce ve sonra
6. hata alındığında
7. büyük kod üretimi bittikten sonra
8. output çok uzayacaksa chat'e basmadan önce
9. riskli işlemden önce
10. kullanıcı uzun/büyük proje promptu verdiyse ilk plan tamamlandığında

Checkpoint içeriği:
- current task
- current phase
- last successful step
- completed steps
- files created or changed
- commands run
- verification status
- current blocker
- risks
- next 3 actions
- notes for next session

Chat'e uzun checkpoint basma. Sadece kısa bilgi ver:
`Checkpoint güncellendi: <resolved memoryPath>/05-sessions/latest-checkpoint.md`

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
