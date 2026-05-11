# Commands

# Simple Daily Commands

The simple command layer stays user-facing and routes to advanced skills instead of replacing them.

```text
/haye:start
/haye:work
/haye:fix
/haye:secure
/haye:ship
/haye:close
/haye:update
```

Internal routing:

- `/haye:start` -> `start`, `memory-start`
- `/haye:init-memory` -> `init-memory`
- `/haye:work` -> `work`, `context-pack`, `feature`, `refactor`, `api-integration`, `migration`, `test-plan`, internal `team-mode`
- `/haye:fix` -> `fix`, `bugfix`, `nextjs-doctor`, `prisma-doctor`, `docker-doctor`, `coolify-doctor`, `cloudflare-doctor`, `database-doctor`
- `/haye:secure` -> `secure`, `security`, `dependency-security`, `dependency-audit`, `version-policy`, `react-nextjs-security`, `secrets-audit`, `auth-audit`, `exposed-port-audit`
- `/haye:ship` -> `ship`, `deploy`, `review`, `security`, `dependency-security`, `cloudflare-doctor`, `coolify-doctor`, `docker-doctor`
- `/haye:close` -> `close`, `session-close`, `memory-lint`, `token-audit`
- `/haye:update` -> `update`

# /haye:update

HayeOS plugin'ini GitHub'dan günceller. Plugin root'u `CLAUDE_PLUGIN_ROOT`, marketplace install path veya mevcut plugin path bilgisinden bulur.

Davranış:
- `.git` yoksa durur ve yeniden clone gerektiğini Türkçe açıklar.
- `origin` URL beklenen repo değilse kullanıcıya gösterir ve onay almadan değiştirmez.
- Local değişiklik varsa durur; otomatik pull yapmaz ve değişiklikleri göstermeyi teklif eder.
- Plugin root bulunamazsa durur; `git init`, placeholder remote veya kullanıcı/proje klasöründe yeni git repo oluşturma davranışı yoktur.
- Temiz repo'da `git fetch origin` ve `git pull --ff-only origin main` çalıştırır.
- Güncelleme sonrası `claude plugin validate .`, varsa `./scripts/verify.sh`, mümkünse `bin/haye --help` çalıştırır.
- Commit/push yapmaz, project vault dosyalarına dokunmaz, context pack veya checkpoint üretmez.
- Güncelleme tamamlandıysa Claude Code'u kapatıp yeniden açmayı önerir.

# /haye:work Smart Modes

`/haye:work "görev"` Smart Work Router olarak çalışır. Kullanıcıdan sürekli başka komut kullanmasını istemez; bug ise fix workflow, security ise secure workflow, deploy/release ise ship workflow mantığını içeride uygular.

Classification fields:
- `task_size`: `small`, `medium`, `large`, `massive`
- `task_type`: `quick fix`, `feature`, `refactor`, `architecture`, `full system`, `security`, `deployment`, `debugging`, `research/planning`
- `risk_level`: `low`, `medium`, `high`
- `affected_layers`: frontend, backend, database, infra, AI pipeline, security, deployment, docs, tests
- `recommended_mode`: Fast Single Agent, Standard Single Agent, Plan First, Team Mode, Full Architecture Mode

# Work Strategy Selection Rule

`/haye:work` büyük, belirsiz veya riskli işlerde çalışma stratejisini kendisi sessizce seçmez. Önce sınıflandırma yapar, önerilen modu açıklar ve Türkçe sorar:

```text
Bu iş [task_size] ve [risk_level] görünüyor. Önerim: [recommended_mode].
Nasıl ilerleyeyim?

1. Önerilen modla devam et
2. Sadece plan çıkar
3. Tek agent ile hızlı ilerle
4. Daha küçük bir MVP'ye indir
```

Modes:
1. Fast Single Agent / Fast Mode: small + low risk. Gereksiz subagent yok, kısa özetle uygular.
2. Standard Single Agent / Standard Mode: medium. Kısa plan + implementation + verification.
3. Plan First: önce plan çıkarır, kod yazmaz, implementation için onay bekler.
4. Team Mode: large/high-risk. Uzman perspektifleri kısa tutar; `token-economist` her zaman dahil edilir.
5. Full Architecture Mode: massive/production-grade/multi-service. Önce docs/plan üretir, kodlamadan önce onay ister.

Kullanıcı modu açıkça belirtmişse tekrar sormaz; seçilen modu kısa teyit eder.

# Massive Task Classification Rule

Şu sinyaller varsa iş `massive` kabul edilir: `production-grade`, `complete system`, `autonomous`, `multi-service`, `microservices`, `24/7`, `scale horizontally`, `Kubernetes`, `monitoring`, `analytics`, `AI pipeline`, `full architecture`, `from scratch`, çok sayıda servis listesi, Phase 0/1/2 roadmap, veya backend + frontend + infra + AI + monitoring birlikte istenmesi.

Massive ise `recommended_mode = Full Architecture Mode`, Team Mode internally enabled, `token-economist`, `security-reviewer`, `deployment-doctor` zorunlu; DB varsa `database-architect` zorunlu. Kodlamadan önce plan onayı gerekir.

# Team Mode Offer Rule

Massive veya high-risk işlerde ilk cevap sınıflandırma + kısa Team Mode planı verir ve Türkçe sorar: "Bu iş massive/high-risk görünüyor. Önerim Full Architecture Mode + Team Mode. Onaylıyor musunuz?" Uzman katkıları 3-7 maddeyle sınırlıdır ve detaylar dosyalara yazılır.

# Full Architecture Mode Gate

Massive projelerde implementation öncesi plan artifact'leri dosyalara yazılır: Project Understanding, Architecture Overview, Service Map, Data Flow, Event Flow, Database Plan, Queue Plan, Storage Plan, AI Pipeline Plan, Monitoring Plan, Security Plan, Deployment Plan, HayeOS Memory Usage Plan, Phased Implementation Roadmap ve First Implementation Plan. Tercih edilen dosyalar `docs/architecture.md`, `docs/roadmap.md`, `docs/services.md`, `docs/events.md`, `docs/database.md`, `docs/deployment.md`, `docs/security.md`, `docs/monitoring.md`, `docs/operations.md`, `docs/ai-pipeline.md`, `docs/queues.md`, `docs/storage.md`. Kodlamaya başlamadan önce onay gerekir.

## Behavior Examples

Örnek 1 - küçük iş:
- User: `/haye:work "README'de typo düzelt"`
- Expected: Fast Single Agent. Sormadan düzeltir, kısa özet verir.

Örnek 2 - orta iş:
- User: `/haye:work "Yeni API endpoint ekle"`
- Expected: Standard Single Agent. Kısa plan + implementation. Risk yoksa sürekli sormaz.

Örnek 3 - büyük iş:
- User: `/haye:work "Production-grade microservices AI media system build"`
- Expected: "Bu iş massive/high-risk görünüyor. Önerim Full Architecture Mode + Team Mode. Onaylıyor musunuz?"

Örnek 4 - kullanıcı modu belirtmiş:
- User: `/haye:work "Full Architecture Mode kullan..."`
- Expected: Tekrar strateji sormadan Full Architecture Mode ile plan üretir, kodlamadan önce onay ister.

# Approval Friction Rule

HayeOS minimizes approval friction. It asks for approval at phase boundaries and risk gates, not after every small edit.

Plan veya phase onaylandıysa küçük ve güvenli işleri tekrar tekrar sormadan tamamlar:
- klasör oluşturma
- stub dosya ekleme
- docs/README güncelleme
- basit config ekleme
- service/route/test placeholder oluşturma
- internal refactor
- HayeOS memory'ye kısa not yazma

Strategy approval = phase içindeki güvenli küçük işleri yapma iznidir. Risk gate ve phase sonunda tekrar sorulur.

# No Placeholder Production Rule

Production-grade veya Full Architecture Mode işlerde Hello world / Merhaba dünya, `myapp:latest`, `your-*-image`, `placeholder-image`, Docker Compose top-level `version`, `python:3.8`, executable commands içinde `./path/to/...` veya `/path/to/...`, yalnızca `assert True` testleri veya 2-line docs ile production foundation tamamlandı denmez. Skeleton yazıldıysa açıkça skeleton olduğu ve production-ready olmadığı belirtilir.

# Foundation Quality Gate

Production foundation iddiası için gerçek yapı, anlamlı test, dependency/security değerlendirmesi, verification status ve next/rollback steps gerekir. Bu gate geçmeden "Aşama tamamlandı", "production-ready", "temel işlevsellik sağlandı", "hazır" veya "başarıyla çalışıyor" denmez.

# Dependency / Base Image Safety Rule

Docker image'larında latest tag kullanma. `myapp:latest`, `image: latest`, Docker Compose top-level `version`, eski/EOL `python:3.8` ve kör dependency install yasaktır. Modern desteklenen explicit version tag kullan; Python için uyumluysa `python:3.12-slim` gibi güncel slim base tercih et ve kararı dependency/security notes içine yaz.

Dependency install/update/remove risk gate'tir. `pip install`, `python -m pip install`, `py -m pip install`, `npm install`, `pnpm add`, `yarn add`, `docker pull` veya unknown image pull eden Docker komutlarından önce onay al. `docker compose up` öncesi fake image, build context, Dockerfile, obsolete top-level `version` ve `latest` tag kontrolü yap.

# No Fake Completion Rule

HayeOS doğrulama çıktısı olmadan "çalışıyor", "tamamlandı", "geçti", "production-ready" veya "başarılı" demez.

Phase sonunda Verification Status verir:
- commands run
- passed
- failed
- not run
- reason if not run

# Output Budget Rule

Chat cevabı kısa tutulur. Varsayılan cevap 1500-3000 token civarında olur; büyük işler için 5000-6000 tokenı geçmemeye çalışır.

Amaç, 64000 output token limitine takılabilecek büyük cevapları önlemektir.

Uzun içerikler chat'e değil dosyalara yazılır:
- büyük mimari
- roadmap
- servis planı
- DB planı
- event schema
- queue schema
- deployment planı
- uzun Team Mode role çıktıları
- uzun session close logları

Detaylar için `docs/` veya HayeOS vault dosyaları kullanılır. Full Architecture Mode detayları örneğin `docs/architecture.md`, `docs/roadmap.md`, `docs/services.md`, `docs/events.md` gibi dosyalara yazılır.

Chat'te sadece kısa özet, değişen/oluşan dosyalar, önemli kararlar, doğrulama durumu, sıradaki 3 adım ve gerekiyorsa onay sorusu verilir. Eğer çıktı çok uzayacaksa bölümlere ayrılır ve kullanıcıdan devam onayı istenir.

# Quality Preservation Rule

Token discipline must never reduce implementation quality.

HayeOS token tasarrufu için şunları azaltır:
- verbose chat output
- repeated explanations
- unnecessary repo scans
- huge pasted logs
- oversized reports

HayeOS token tasarrufu için şunları atlamaz:
- gerekli code reading
- tests
- validation
- security checks
- error handling
- architecture reasoning

Detailed technical artifacts gerektiğinde dosyalara yazılır. Chat concise kalır, ama code ve project files complete, maintainable, secure ve production-quality kalmalıdır. Token saving ile correctness çakışırsa correctness kazanır. Speed ile safety çakışırsa safety kazanır.

# Auto Checkpoint Rule

HayeOS `/haye:work`, `/haye:fix`, `/haye:ship` ve büyük işlemler sırasında `/haye:close` beklemeden checkpoint yazar.

Checkpoint dosyaları:
- `05-sessions/latest-checkpoint.md`
- `04-tasks/active-task.md`
- `current.md`
- `next.md`

Checkpoint phase başında/sonunda, 5+ dosya değiştiğinde, dependency/security/deploy işleminden önce, docker/build/test/lint/typecheck öncesi/sonrası, hata alındığında, büyük kod üretimi bittiğinde, output çok uzayacaksa ve riskli işlemden önce yazılır.

Chat'e uzun checkpoint basılmaz; sadece `Checkpoint güncellendi: 05-sessions/latest-checkpoint.md` denir.

# Safe Resume Rule

`/haye:start` `.hayeos.json` dosyasını okur, vault path'ini bulur ve `HAYE.md`, `index.md`, `current.md`, `next.md`, varsa `04-tasks/active-task.md` ve varsa `05-sessions/latest-checkpoint.md` dosyalarını okur.

Checkpoint varsa kısa recovery özeti verir ve otomatik kodlamaya başlamaz. Türkçe onay ister:

```text
Son checkpoint'e göre kaldığımız yeri buldum. Devam edeyim mi?
```

# What happens if Claude Code crashes?

`/haye:close` çalıştırılamadan oturum giderse sorun değil. Yeni oturumda `/haye:start` checkpoint'i okur, kısa recovery özeti verir ve kullanıcı "evet", "devam et" veya "kaldığın yerden devam" demeden implementation'a devam etmez.

# How /haye:start resumes safely

Recovery summary kısa tutulur: current task, current phase, last successful step, changed files, current blocker, next 3 actions ve recommended next mode.

# How /haye:close finalizes checkpoint

`/haye:close` `latest-checkpoint.md` dosyasını okur, session summary'ye taşır, `changelog.md`, `current.md`, `next.md`, `health.md` ve `active-task.md` dosyalarını günceller. Checkpoint silinmez; `closed` olarak işaretlenir veya son kapanış durumu yazılır.

# When HayeOS asks for approval

- destructive işlem
- database migration veya data loss riski
- dependency install/update/remove
- security/auth/payment/permission değişikliği
- deploy veya production config değişikliği
- secret/env işlemleri
- büyük mimari yön değişikliği
- scope dışına çıkma
- paid API, GPU, cloud resource, canlı webhook, gerçek upload/publish
- kullanıcı açıkça "önce sor" dediyse

# When HayeOS continues automatically

Onaylı phase içindeki küçük ve güvenli işler için "Devam ediyorum: sıradaki adım ..." diyerek ilerler. Phase sonunda "Phase X tamamlandı. Yapılanlar: ... Sıradaki phase'e geçeyim mi?" diye sorar.

## Advanced

Use detailed skills directly when the request is already specific. The simple commands are convenience routers for daily use.

## Configuration

Commands inspect `.hayeos.json` first:

- `memoryPath` points to the Obsidian vault.
- `sourcePath` points to the source tree for package/security checks.
- `defaultWorkflow` and `sessionCloseRequired` guide workflow strictness.

## /haye:start Start Light Rule

`/haye:start` must stay lightweight. It may check `.hayeos.json`, read `memoryPath`, read minimal memory files, show a short recovery summary and ask the next Turkish question.

`/haye:start` must not load `/haye:work`, must not start a task classification wizard, must not ask "Şimdi hafızayı başlatmamı ister misiniz?" after init, must not use subagents, must not enter plan mode, must not scan the whole repository, must not perform codebase exploration, must not search test patterns, must not produce an automatic project plan and must not create `.hayeos.json` before user approval.

Plugin root and project memory vault are different:

- `CLAUDE_PLUGIN_ROOT` or the HayeOS install path is only the plugin code root.
- `.hayeos.json` `memoryPath` is the single source of truth for the current project's memory vault.
- `.hayeos.json` `sourcePath` is the current project's source root.
- Context packs are written only to `<resolved memoryPath>/09-context-packs/`.
- Checkpoints are written only to `<resolved memoryPath>/05-sessions/latest-checkpoint.md`.
- Active task, `current.md`, `next.md` and `changelog.md` are updated only inside the resolved project vault.
- HayeOS must stop before writing any project memory file under `CLAUDE_PLUGIN_ROOT` and warn: `Bu dosya plugin klasörüne yazılmaya çalışılıyor. Proje vault’u kullanılmalı.`

Do not read `08-raw/` unless the user asks or a context pack names specific raw files.

## Memory initialization

Users normally do not need to run `bin/haye` manually. After the global plugin is installed, `/haye:start` is enough in each project.

If `.hayeos.json` or the Obsidian vault is missing, `/haye:start` asks in Turkish:

```text
Bu projede Haye hafızası bulunamadı. Şimdi otomatik oluşturayım mı?
```

If approved, Haye runs the `/haye:init-memory` flow. That flow writes a relative `memoryPath` using `./<project-name>_obs`, writes `sourcePath` as `"."`, never writes Windows absolute paths into JSON and never creates a generic `memory` folder.

On Windows, manual fallback commands are:

```text
C:\Path\To\HayeOS\bin\haye.cmd init
powershell -ExecutionPolicy Bypass -File C:\Path\To\HayeOS\bin\haye.ps1 init
```
