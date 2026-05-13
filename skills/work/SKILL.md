---
name: work
description: Use when user requests a feature, refactor, migration, deploy, or any non-trivial implementation work - smart router that selects mode (Full Architecture, Team Mode, MVP) and invokes brainstorming for unscoped requests
---

# Haye Skill: work

## The Iron Law

```text
NO IMPLEMENTATION CODE BEFORE PLAN APPROVAL
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
NO PROJECT SOURCE INSIDE THE MEMORY VAULT
NO STUB PLAN ARTIFACTS - UNDER 20 LINES OR WITH PLACEHOLDERS
```

Violating the letter of any rule is violating the spirit. Don't rephrase your way out.

## Red Flags - STOP, you're rationalizing

| Thought | Reality |
|---------|---------|
| "This is too simple to need a plan" | Every project gets a plan. Short is fine. Stub is not. |
| "I'll add detail to the plan later" | Stub plan in vault = lying about completion. |
| "Tests/build look fine, no need to run" | If you didn't run it in this turn, you can't claim it. |
| "User said 'devam', so 5 more files" | "Devam" = one meaningful step then stop. |
| "Let me set up the vault later" | Auto Checkpoint Rule applies from file #1. |
| "Team Mode is overkill here" | Trigger conditions are written in this skill. Read them, don't guess. |
| "I'll skip the planning section, the prompt is clear" | The plan IS the prompt's contract. Skip = scope drift. |
| "Just one quick fix without verification" | Quick = unverified = a lie. |
| "Stack drift is fine, FastAPI vs Flask is similar" | Drift requires explicit user approval. |
| "Placeholder is OK, user will fix it" | User explicitly said 'no placeholders'. You wrote them anyway. |

## The Gate Function

Before claiming "complete", "done", "works", "passes", "ready":

1. IDENTIFY: What command/check proves this claim?
2. RUN: Execute the FULL command (fresh, in this turn)
3. READ: Full output, exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence, don't claim
   - If YES: Claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying.

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

## Mandatory routing after mode selection

When the user chooses one of the offered modes (Full Architecture Mode, Team Mode, Plan First, Standard Single Agent, Fast Single Agent), HayeOS routes IMMEDIATELY to the corresponding next action. No prose preamble. No "Şimdi planı yazıyorum" placeholder.

| User picks | REQUIRED next call / behavior | Why |
|---|---|---|
| Full Architecture Mode | `Skill(haye:team-mode)` | Coordinates specialist agents and produces the full architecture plan |
| Team Mode | `Skill(haye:team-mode)` | Same orchestrator; produces a smaller specialist plan |
| Plan First | `Skill(haye:context-pack)` followed by read-only plan construction | Investigation before plan |
| Standard Single Agent | inline plan in chat, then `Skill(haye:checkpoint)` after plan approval | One Sonnet, no subagents |
| Fast Single Agent | direct implementation with checkpoint after 5 files | One Sonnet, no plan ceremony |

DO NOT call `Skill(haye:feature)` for any of these mode-selection continuations. `feature` is for single-slice work, NOT for routing out of work-skill mode selection.

DO NOT improvise a plan inline when Full Architecture Mode was selected. The team-mode skill is responsible for producing the plan.

DO NOT continue answering with prose after the mode is chosen. Make the required skill call or perform the explicitly required continuation behavior.

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

## Prompt Fidelity Guard

Before presenting any plan, restate the user's core objective in one sentence and verify that the proposed plan directly serves that objective.

Do not silently transform the project into a different problem domain.

Examples:
- "premium doctor landing page" must not become "doctor CRUD backend"
- "marketing site" must not become "multi-tenant SaaS"
- "UI revamp" must not become "database redesign"

If the plan introduces major new scope not explicitly requested by the user, stop and do one of:
1. remove the unrelated scope, or
2. ask for explicit approval before adding it.

A plan that materially changes the user's objective is invalid, even if it sounds technically sophisticated.

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

## Path Separation Rule (project source vs memory vault)

Proje dosyaları ve memory dosyaları FARKLI dizinlerde yaşar. Birbirine karıştırılmaz.

### sourcePath (proje kökü) - buraya yazılır
Kullanıcının projesinin gerçekten çalıştığı her şey:
- Kod: `.py`, `.ts`, `.tsx`, `.js`, `.jsx`, `.go`, `.rs`, `.java`, `.html`, `.css`
- Infra: `Dockerfile`, `docker-compose*.yml`, `Procfile`, `.dockerignore`, helm/kustomize
- Config: `.env.example`, `next.config.*`, `tsconfig.json`, `package.json`, `requirements.txt`, `pyproject.toml`, `Makefile`
- Docs: `README.md`, `CHANGELOG.md`, `docs/`, `ADR/`, API specs
- Klasörler: `services/`, `apps/`, `packages/`, `infra/`, `scripts/`, `tests/`, `public/`, `assets/`

### memoryPath (vault) - SADECE memory için
Yapısal proje hafızası:
- `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, `<resolved memoryPath>/changelog.md`, `<resolved memoryPath>/health.md`
- `<resolved memoryPath>/01-prompts/`, `<resolved memoryPath>/02-decisions/`, `<resolved memoryPath>/03-bugs/`, `<resolved memoryPath>/04-tasks/`, `<resolved memoryPath>/05-sessions/`, `<resolved memoryPath>/06-prompts/`, `<resolved memoryPath>/07-checklists/`, `<resolved memoryPath>/08-raw/`, `<resolved memoryPath>/09-context-packs/`, `<resolved memoryPath>/10-reviews/`, `<resolved memoryPath>/11-metrics/`, `<resolved memoryPath>/12-risks/`, `<resolved memoryPath>/99-archive/`

### Hard rule
Bir hedef path `<resolved memoryPath>` altındaysa VE şu isimlerden/uzantılardan biriyse -> DUR ve Türkçe uyar:
- `.py`, `.ts`, `.tsx`, `.js`, `.jsx`, `.go`, `.rs`, `.java`, `.html`, `.css`, `.sh`, `.yaml`, `.yml`, `.toml`, `Dockerfile`, `docker-compose*`, `package.json`, `requirements.txt`, `pyproject.toml`, `next.config.*`
- Memory subfolder olmayan klasörler: `services/`, `apps/`, `packages/`, `infra/`, `scripts/`, `tests/`, `public/`, `assets/`

Uyarı mesajı:
"Bu dosya memory vault'una yazılmaya çalışılıyor ama bu proje kodu/dökümanı. Proje kök dizinine (sourcePath) yazılmalı."

Proje için `docs/` gerekiyorsa `<sourcePath>/docs/`'a yazılır, `<memoryPath>/docs/`'a değil.
Proje `README.md`'si `<sourcePath>/README.md`'ye yazılır, `<memoryPath>/README.md`'ye değil.

## Plan Depth Rule (Full Architecture Mode and Plan First)

Kullanıcı massive/full-architecture sistem istediğinde ya da N planning artifact listelediğinde, HayeOS koda başlamadan önce HEPSİNİ uygun derinlikte üretir.

### Required artifacts
Prompt 15 artifact saydıysa, 15 artifact üretirsin. Daha az değil.

### Minimum derinlik per artifact
- Architecture Overview: >=80 satır, içerik: seçilen vs reddedilen stack (gerekçeyle), en büyük 5 mimari risk, scale varsayımları, failure mode'lar
- Service Map: her servis için sorumluluk, input, output, bağımlılıklar, scaling profili, ürettiği/tükettiği queue topic'leri
- Data Flow / Event Flow: en az bir mermaid veya ascii diagram, her event'in payload şeması
- Database Plan: tablolar + sütunlar + index'ler, ownership kuralları, migration stratejisi, backup/restore planı
- Queue Plan: broker, queue isimleri, retry/DLQ/visibility, ordering guarantee'leri
- Security Plan: auth, RBAC, secret yönetimi, exposed port, abuse surface, dependency policy
- Deployment Plan: ortam başına rollout, rollback path, healthcheck, observability
- Monitoring Plan: metric, alert, dashboard, on-call sinyali
- Roadmap: faz başına somut file/folder delta

### Stub-plan refusal
Bir plan artifact'i 20 satırın altındaysa VEYA "X yapılandırılacaktır", "ileride detaylandırılacak", "...için gerekli ayarlamalar yapılacak" gibi placeholder ifadelerle doluysa - plan task'ını `[x]` ile işaretleme.
`[ ] (yetersiz, derinleştir)` olarak bırak ve neyin eksik olduğunu açıkla.

### Service count adherence
Prompt N servis adlandırdıysa, service map'te N servis listelersin. Daha az üretmek scope cut'tır ve şu cümleyi gerektirir:
"Scope cut: requested N servisin N1'ini implement edeceğim. Sebep: ..."
Bu cümle olmadan az servis üretmek No Fake Completion Rule ihlalidir.

## No Fake Completion Rule - strengthened evidence requirements

Mevcut "No Fake Completion Rule"un üstüne ek kanıt şartları:

### "build/test/lint passed" iddiası için
- Gerçek komutu ve final exit code'unu (veya success line'ını) göster
- "komut çalıştı, çıktı OK'di" kanıt değil; ilgili 1-3 satırı yapıştır
- 100 testten 1'ini çalıştırdıysan "1/N test çalıştı" de

### "servis başladı" / "endpoint çalışıyor" iddiası için
- Container için: `docker compose ps` çıktısı `running (healthy)` göstermeli VE endpoint'e `curl`
- Curl'ün 200 dönmesi endpoint'in var olduğunu gösterir; business logic'in çalıştığını DEĞİL. Bunu açıkça söyle.
- `{"message": "...successfully!"}` döndüren echo endpoint'leri **servis verification'ı sayılmaz**.

### "tüm N servis test edildi" iddiası için
- Her servis ayrı ayrı test edilmiş, state ve response gösterilmiş olmalı
- "Hepsi geçti" sadece her servis başlatılmış VE her endpoint beklenen yanıtı verdiyse doğrudur
- Servisler başlatılmadıysa (`docker compose up` çalışmadıysa) -> "servisler başlatılmadı; sadece dosya içerikleri doğrulandı" de. Anti-regression marker: servisler baslatilmadi.

### Kanıt olmadan yasak ifadeler
- "başarıyla tamamlandı" / "successfully completed"
- "test başarılı" / "tests passed"
- "production-ready" / "production hazır"
- "doğru çalışıyor" / "working correctly"
- "entegrasyon doğru çalışıyor"

Bu ifadeler ancak yukarıdaki kanıtlarla birlikte kullanılır.

## Team Mode mandatory rule

`/haye:work` Full Architecture Mode'a girdiğinde VEYA kullanıcı explicit specialist agent listesi verdiğinde:

### Team Mode dispatch rule

When specialist perspectives are required, `/haye:work` must route to `haye:team-mode`.
`haye:team-mode` then dispatches specialist roles from `agents/` through the Claude Code agent/subagent mechanism.

Do NOT attempt to call agent names using `Skill(haye:<agent-name>)`.

### token-economist HER ZAMAN zorunlu
Her Full Architecture Mode oturumu, scope ne olursa olsun, token-economist'i en az bir kez çağırır. Çıktısı implementation başlamadan önce chat'e ya da memory note'a girer.

### Adı geçen specialist'ler GERÇEKTEN çağrılır
Prompt project-manager, memory-architect, database-architect, api-integrator, security-reviewer, deployment-doctor, release-manager, token-economist gibi agent'lar listelediyse - adı geçen her agent çıktı üretir.
Çıktıları `<resolved memoryPath>/10-reviews/team-mode/<agent>-<date>.md`'ye gider; chat'te <=7 bullet'lık özet kalır.

### Agent atlamak explicit onay gerektirir
Bir agent'ı çağırmamaya karar verirsen, yapmadan önce söyle:
"{agent-name}'i atlıyorum çünkü: {sebep}. Onayınızı bekliyorum."

### Full Architecture Mode'da single-agent execution ihlaldir
Kendini Full Architecture Mode'da ama tek agent olarak çalışıyorken bulursan, dur ve ya:
- Team Mode'a düzgün gir, ya da
- Kullanıcıdan mode'u düşürmesini iste

## Loop and confirmation spam prevention

### Aynı output tekrarı
Mevcut turn çıktın bir önceki turn'le büyük oranda aynı olacaksa (aynı dosya listesi, aynı "Sonraki Adımlar" bloğu, aynı özet), tekrar etme.
Ya kullanıcıya clarification sor ya da "bu turn'de yeni iş yok, neyi bekliyoruz?" de.

### Aynı dosyaya tekrar yazma
Bu oturumda zaten yazdığın bir dosyaya tekrar yazmak üzereysen VE içerik büyük oranda aynıysa - DUR.
Ya önceki yazma başarısız olmuştur (kontrol et, net bir notla bir kez tekrar dene) ya da confirmation loop'tasındır (kullanıcıya sor).

### "devam edelim" yorumu
"devam edelim" / "continue" kullanıcıdan gelirse: aktif task'a doğru BİR anlamlı sonraki adım at, sonra özetle ve dur.
ANLAMI ŞU DEĞİL: aynı boilerplate'le 5 echo endpoint daha yaz.

5 servis için aynı template'i tekrarladığını fark edersen, geri çekil, abstraction'ı bir kez yaz ve dur.

## Tech stack adherence

Kullanıcı promptu spesifik teknoloji adlandırırsa (FastAPI, Postgres, Prisma, Redis, RabbitMQ, vb.), HayeOS onları kullanır.

### Adı geçen stack'ten sapma
- Açık kabul gerektirir: "Kullanıcı X istedi. Z sebebiyle Y kullanıyorum."
- Kod yazılmadan önce kullanıcı onayı gerektirir
- Sık görülen drift: prompt FastAPI istemiş, HayeOS "daha basit" diye Flask'a uzanmış - bu ihlaldir

### Default safe versions (prompt sessizse)
- Python: 3.12 (3.8/3.9/3.10 yeni projelerde yasak - EOL)
- Node: 20 LTS veya 22 LTS (18 LTS sadece kilitlenmişse)
- Postgres: 16 minimum, 17 tercih
- Docker Compose: v2 syntax (top-level `version: '3'` YOK)

### Sürüm karar kaynağı
Her dependency seçimi ve version pin `<resolved memoryPath>/02-decisions/dependencies-<date>.md`'ye kaydedilir.

## Next.js Project Initialization Defaults

When the user requests a Next.js project from scratch:

### Required scaffolding command

```bash
npx create-next-app@latest <project-name> --typescript --tailwind --app --src-dir=false --import-alias="@/*"
```

This produces:
- Next.js 16+ with App Router (NOT Pages Router)
- TypeScript out of the box
- Tailwind CSS preconfigured
- `app/` directory at root (no `src/` wrapper)

### Forbidden patterns (test7 evidence)

DO NOT manually create `pages/index.tsx` AFTER `npx create-next-app` ran. The scaffold uses App Router by default - adding Pages Router files causes route conflicts:

```text
Error: Conflicting app and page file was found, please remove the conflicting files to continue:
  "pages/index.tsx" - "app/page.tsx"
```

If `app/page.tsx` exists, edit it. Do not introduce `pages/`.

### Tailwind v4+ (Next.js 16+)

For Next.js 16's bundled Tailwind 4:
- `tailwind.config.js` is NOT manually written; `@tailwindcss/postcss` handles it
- `postcss.config.js` should be:
  ```js
  module.exports = {
    plugins: { '@tailwindcss/postcss': {} }
  }
  ```
- NOT the old `plugins: { tailwindcss: {}, autoprefixer: {} }` (this is Tailwind 3 pattern)

If `tailwindcss init -p` fails (Tailwind 4 removed this command), do not retry. Use the create-next-app output directly.

### Component file locations
- App Router: `app/page.tsx` (home), `app/about/page.tsx` (about), `app/layout.tsx` (shared layout)
- Components: `components/<Name>.tsx` (or `app/_components/` for App Router-private)
- "use client" required at top of any component with useState, useEffect, event handlers, or browser APIs

## Windows Shell Awareness

Claude Code's Bash tool runs through Git Bash (or WSL) on Windows. This means:

### Commands that DO NOT work in the Bash tool on Windows

```text
rmdir /S /Q "C:\path"      # Windows cmd syntax - bash sees /S and /Q as paths
del C:\path\file           # Windows cmd command - bash has no 'del'
copy /Y src dest           # Windows cmd - bash has no 'copy'
```

### Use POSIX commands instead

```bash
rm -rf "/c/path"           # Forward slashes, /c for C: drive
rm "/c/path/file"
cp src dest
```

### For Windows-specific operations, route through PowerShell

```bash
powershell -Command "Remove-Item -Path 'C:\\path' -Recurse -Force"
powershell -Command "Get-Process node | Stop-Process"
```

### Path conversions

In Bash tool on Windows, prefer:
- Forward slashes: `/c/Path/To/project`
- Or escape backslashes: `C:\\Path\\To\\project`
- Avoid mixing: `C:\Path\To\project` may be misinterpreted

### Test7 evidence

Sonnet attempted `Bash(rmdir /S /Q "C:\Path\To\Project\premium-doctor-landing-page\pages")` and bash interpreted `/S` and `/Q` as file paths, returning errors. The correct command was `Bash(powershell -Command "Remove-Item -Path '...' -Recurse -Force")`.

## File Modification Tool Preference

When modifying an EXISTING file:

### Preferred: Edit tool

Edit replaces specific strings. It is safer for incremental changes. It cannot accidentally duplicate imports or other lines.

### Avoid: Update tool when adding imports / re-editing recently-changed files

The Update tool has a known failure mode where re-applying edits to a recently-modified file can DUPLICATE lines at the top of the file:

```text
1  import React from 'react';
2
3 +import React from 'react';           <- DUPLICATE
4 +import ServiceCard from '...';
```

If you need to add an import to a file:
1. First Read the file
2. Use Edit with old_str = existing import block, new_str = existing imports + new import
3. Verify the result with another Read

### Test7 evidence

Sonnet used Update to add `import ServiceCard` to `pages/index.tsx`. The result was 3 duplicate `import React from 'react';` statements, breaking the build.

## Required Next Steps

After mode classification:

**REQUIRED SUB-SKILL (massive/large/full-architecture):** `Skill(haye:team-mode)` — never invent a plan inline.

**REQUIRED SUB-SKILL (small/medium with multiple files):** `Skill(haye:checkpoint)` after the active task is written to vault.

After each work chunk (>=5 files or phase boundary):

**REQUIRED SUB-SKILL:** `Skill(haye:checkpoint)`.

Before any "complete"/"done"/"works"/"passes"/"ready" claim:

**REQUIRED GATE FUNCTION** (see The Gate Function above). Skipping this is Iron Law violation.

At the end of meaningful work, before user runs /haye:close:

**REQUIRED SUB-SKILL:** `Skill(haye:close)`.
