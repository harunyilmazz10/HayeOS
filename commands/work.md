---
description: Route development work through the right Haye workflow.
---

# /haye:work

Use `skills/work/SKILL.md`.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

## Smart Work Router
`/haye:work "görev"` önce görevi sınıflandırır, sonra uygun modu seçer:

- `task_size`: `small`, `medium`, `large`, `massive`
- `task_type`: `feature`, `bugfix`, `refactor`, `architecture`, `security`, `deploy`, `research`, `bootstrap`, `documentation`, `media-pipeline`, `AI-system`
- `risk_level`: `low`, `medium`, `high`
- `affected_layers`: `frontend`, `backend`, `database`, `infra`, `AI`, `security`, `deployment`, `media pipeline`, `queue/event system`, `storage`, `analytics`
- `recommended_mode`: `Fast Single Agent`, `Standard Single Agent`, `Plan First`, `Team Mode`, `Full Architecture Mode`

## Work Strategy Selection Rule
`/haye:work` büyük, belirsiz veya riskli işlerde kafasına göre tek agent/subagent seçmez. Önce `task_size`, `task_type`, `risk_level`, `affected_layers` ve `recommended_mode` sınıflandırmasını kısa verir, sonra Türkçe strateji onayı ister.

Modes:
- Fast Single Agent: küçük ve düşük riskli işler; gereksiz subagent yok.
- Standard Single Agent: orta işler; kısa plan + implementation.
- Plan First: önce sadece plan; kod yazmadan onay bekler.
- Team Mode: büyük/çok katmanlı/riskli işler; uzman perspektifleri kısa tutulur.
- Full Architecture Mode: massive/production-grade/multi-service işler; önce docs/plan, koddan önce onay.

Büyük veya high-risk işlerde soru formatı:

```text
Bu iş [task_size] ve [risk_level] görünüyor. Önerim: [recommended_mode].
Nasıl ilerleyeyim?

1. Önerilen modla devam et
2. Sadece plan çıkar
3. Tek agent ile hızlı ilerle
4. Daha küçük bir MVP'ye indir
```

Küçük ve low-risk işler için strateji sorma; Fast Single Agent ile kısa özet verip uygula.

Kullanıcı modu açıkça belirtmişse tekrar sorma; seçilen modu kısa teyit et ve o moda göre ilerle.

## Original Prompt Preservation Rule
Large, massive, architecture and full-system `/haye:work` requests must preserve the original user prompt verbatim before planning or implementation.

- Write only under the project vault: `<resolved memoryPath>/01-prompts/`.
- First large master prompt target: `<resolved memoryPath>/01-prompts/initial-master-prompt.md`.
- Later work prompt target: `<resolved memoryPath>/01-prompts/work-request-YYYY-MM-DD-HHMM.md`.
- File content must include timestamp, task classification summary, original prompt verbatim and optional short normalized brief.
- Do not summarize or rewrite the original prompt in the preserved section.
- Small one-line bugfix tasks do not require prompt preservation.
- Never write prompt records to `CLAUDE_PLUGIN_ROOT`.

## Mode behavior
- Small + low risk: Fast Mode. Kısa planla direkt uygula, gereksiz onay sorma.
- Medium: Standard Mode. Kısa plan, implementation ve verification yap; sadece gerekli yerde sor.
- Large veya high risk: Team Mode öner ve Türkçe sor: "Bu görev büyük/riskli görünüyor. Uzman rollere bölerek Team Mode ile önce plan çıkarayım mı?"
- Massive veya sıfırdan büyük sistem: Full Architecture Mode öner, kodlamadan önce detaylı mimari çıkar ve onay almadan kodlamaya başlama.

## Internal routing
Kullanıcıdan komut değiştirmesini isteme. Görev bug ise `/haye:fix` mantığını, security ise `/haye:secure` mantığını, deploy/release ise `/haye:ship` mantığını `/haye:work` içinde uygula.

Team Mode sadece `/haye:work` içinde devreye girer. Ayrı user-facing `/haye:team` komutu yoktur.

## Approval Friction Rule
Strategy approval veya phase approval verildiyse, HayeOS o phase içindeki küçük ve güvenli işleri tekrar tekrar sormadan tamamlar. Onay sadece riskli kapılarda, scope değişiminde veya phase geçişinde istenir.

## No Placeholder Production Rule
Production-grade veya Full Architecture Mode işlerde Hello world / Merhaba dünya, `myapp:latest`, Docker Compose top-level `version`, `python:3.8`, yalnızca `assert True` testleri veya yüzeysel docs ile production foundation tamamlandı deme. Skeleton yazıldıysa açıkça skeleton olduğunu, production-ready olmadığını ve doğrulama durumunu dürüstçe belirt.

## No Fake Completion Rule
Verification çıktısı olmadan "çalışıyor", "tamamlandı", "geçti", "production-ready" veya "başarılı" deme. Test/build/lint/typecheck çalışmadıysa bunu açıkça yaz.

## Output Budget Rule
- Chat cevabını kısa tut; varsayılan cevap 1500-3000 token civarında olsun.
- Büyük işler için chat çıktısı 5000-6000 tokenı geçmesin.
- Büyük mimari, roadmap, servis planı, DB planı, event/queue schema ve deployment planı gibi uzun içerikleri chat'e değil dosyalara yaz.
- Detaylı içerikler için `docs/` veya HayeOS vault içinde uygun dosyaları kullan.
- Chat'te sadece kısa özet, değişen/oluşan dosyalar, önemli kararlar, doğrulama durumu, sıradaki 3 adım ve gerekiyorsa onay sorusu ver.
- If output would become long, prefer writing the detailed content to `docs/` or the HayeOS vault and provide a concise chat summary. Ask for continuation only if the user explicitly requested a long multi-part chat response.

## Quality Preservation Rule
- Token discipline must never reduce implementation quality.
- Do not skip necessary code reading, tests, validation, security checks, error handling, or architecture reasoning just to save tokens.
- Save tokens by reducing verbose chat output, repeated explanations, unnecessary repo scans, huge pasted logs, and oversized reports.
- Detailed technical artifacts should be written to files when needed.
- Chat should be concise, but code and project files must remain complete, maintainable, secure, and production-quality.
- If there is a conflict between token saving and correctness, correctness wins.
- If there is a conflict between speed and safety, safety wins.

## Auto Checkpoint Rule
- `/haye:work` başladığında `<resolved memoryPath>/04-tasks/active-task.md` oluştur/güncelle.
- Büyük işlerde `<resolved memoryPath>/05-sessions/latest-checkpoint.md` oluştur.
- Her phase başında ve sonunda checkpoint yaz.
- 5+ dosya değiştiyse checkpoint yaz.
- Hata alınırsa checkpoint yaz.
- Dependency/security/deploy veya riskli işlem öncesinde checkpoint yaz.
- Checkpoint detayını dosyaya yaz; chat'te sadece "Checkpoint güncellendi: <resolved memoryPath>/05-sessions/latest-checkpoint.md" de.

## Project vault write rule
- Project memory dosyaları her zaman `.hayeos.json` içindeki resolved `memoryPath` altına yazılır.
- `context-pack`, `checkpoint`, `active-task`, `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, `<resolved memoryPath>/changelog.md` plugin repo içine yazılmaz.
- Hedef path `CLAUDE_PLUGIN_ROOT` altındaysa yazmayı durdur ve Türkçe uyar: "Bu dosya plugin klasörüne yazılmaya çalışılıyor. Proje vault'u kullanılmalı."

Respect `.hayeos.json`, keep scope narrow and verify with real commands. Checkpoint and active task state may be updated during `/haye:work` according to Auto Checkpoint Rule. Final session handoff and close-time memory consolidation belong to `/haye:close`.

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
