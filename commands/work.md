---
description: Route development work through the right Haye workflow.
---

# /haye:work

Use `skills/work/SKILL.md`.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS komutları Harun için varsayılan olarak Türkçe konuşur.

## Smart Work Router
`/haye:work "görev"` önce görevi sınıflandırır, sonra uygun modu seçer:

- `task_size`: `small`, `medium`, `large`, `massive`
- `task_type`: `feature`, `bugfix`, `refactor`, `architecture`, `security`, `deploy`, `research`, `bootstrap`, `documentation`, `media-pipeline`, `AI-system`
- `risk_level`: `low`, `medium`, `high`
- `affected_layers`: `frontend`, `backend`, `database`, `infra`, `AI`, `security`, `deployment`, `media pipeline`, `queue/event system`, `storage`, `analytics`
- `recommended_mode`: `fast`, `standard`, `team`, `full-architecture`

## Mode behavior
- Small + low risk: Fast Mode. Kısa planla direkt uygula, gereksiz onay sorma.
- Medium: Standard Mode. Kısa plan, implementation ve verification yap; sadece gerekli yerde sor.
- Large veya high risk: Team Mode öner ve Türkçe sor: "Bu görev büyük/riskli görünüyor. Uzman rollere bölerek Team Mode ile önce plan çıkarayım mı?"
- Massive veya sıfırdan büyük sistem: Full Architecture Mode öner, kodlamadan önce detaylı mimari çıkar ve onay almadan kodlamaya başlama.

## Internal routing
Kullanıcıdan komut değiştirmesini isteme. Görev bug ise `/haye:fix` mantığını, security ise `/haye:secure` mantığını, deploy/release ise `/haye:ship` mantığını `/haye:work` içinde uygula.

Team Mode sadece `/haye:work` içinde devreye girer. Ayrı user-facing `/haye:team` komutu yoktur.

## Approval Friction Rule
Plan veya phase onaylandıysa, HayeOS o phase içindeki küçük ve güvenli işleri tekrar tekrar sormadan tamamlar. Onay sadece riskli kapılarda, scope değişiminde veya phase geçişinde istenir.

## No Fake Completion Rule
Verification çıktısı olmadan "çalışıyor", "tamamlandı", "geçti", "production-ready" veya "başarılı" deme. Test/build/lint/typecheck çalışmadıysa bunu açıkça yaz.

Respect `.hayeos.json`, keep scope narrow, verify with real commands, and leave memory updates for `/haye:close`.
