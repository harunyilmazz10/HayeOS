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
```

Internal routing:

- `/haye:start` -> `start`, `memory-start`, `project-map`, `token-audit`
- `/haye:init-memory` -> `init-memory`
- `/haye:work` -> `work`, `context-pack`, `feature`, `refactor`, `api-integration`, `migration`, `test-plan`, internal `team-mode`
- `/haye:fix` -> `fix`, `bugfix`, `nextjs-doctor`, `prisma-doctor`, `docker-doctor`, `coolify-doctor`, `cloudflare-doctor`, `database-doctor`
- `/haye:secure` -> `secure`, `security`, `dependency-security`, `dependency-audit`, `version-policy`, `react-nextjs-security`, `secrets-audit`, `auth-audit`, `exposed-port-audit`
- `/haye:ship` -> `ship`, `deploy`, `review`, `security`, `dependency-security`, `cloudflare-doctor`, `coolify-doctor`, `docker-doctor`
- `/haye:close` -> `close`, `session-close`, `memory-lint`, `token-audit`

# /haye:work Smart Modes

`/haye:work "görev"` Smart Work Router olarak çalışır. Kullanıcıdan sürekli başka komut kullanmasını istemez; bug ise fix workflow, security ise secure workflow, deploy/release ise ship workflow mantığını içeride uygular.

Classification fields:
- `task_size`: `small`, `medium`, `large`, `massive`
- `task_type`: `feature`, `bugfix`, `refactor`, `architecture`, `security`, `deploy`, `research`, `bootstrap`, `documentation`, `media-pipeline`, `AI-system`
- `risk_level`: `low`, `medium`, `high`
- `affected_layers`: frontend, backend, database, infra, AI, security, deployment, media pipeline, queue/event system, storage, analytics
- `recommended_mode`: `fast`, `standard`, `team`, `full-architecture`

1. Fast Mode: small + low risk. Kısa planla direkt uygular, gereksiz onay sormaz.
2. Standard Mode: medium. Kısa plan + implementation + verification yapar.
3. Team Mode: large veya high risk. Uzman rollere böler, `token-economist` her zaman dahil edilir.
4. Full Architecture Mode: massive veya sıfırdan production-grade sistem. Kodlamadan önce mimari plan ve onay gerekir.

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

# No Fake Completion Rule

HayeOS doğrulama çıktısı olmadan "çalışıyor", "tamamlandı", "geçti", "production-ready" veya "başarılı" demez.

Phase sonunda Verification Status verir:
- commands run
- passed
- failed
- not run
- reason if not run

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
- `riskLevel`, `defaultWorkflow`, `sessionCloseRequired` and `rawReadPolicy` guide workflow strictness.

Do not read `08-raw/` unless the user asks or a context pack names specific raw files.

## Memory initialization

Users normally do not need to run `bin/haye` manually. After the global plugin is installed, `/haye:start` is enough in each project.

If `.hayeos.json` or the Obsidian vault is missing, `/haye:start` asks in Turkish:

```text
Bu projede Haye hafızası bulunamadı. Şimdi otomatik oluşturayım mı?
```

If approved, Haye runs the `/haye:init-memory` flow. That flow tries `${CLAUDE_PLUGIN_ROOT}` based CLI commands first and falls back to creating `.hayeos.json` and the vault files directly when CLI execution is unavailable.

On Windows, manual fallback commands are:

```text
C:\Users\hayed\Desktop\HayeOS\bin\haye.cmd init
powershell -ExecutionPolicy Bypass -File C:\Users\hayed\Desktop\HayeOS\bin\haye.ps1 init
```
