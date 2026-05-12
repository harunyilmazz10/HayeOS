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
