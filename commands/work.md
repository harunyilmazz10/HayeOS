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

Route to advanced workflows when needed:
- `context-pack` before non-trivial work.
- `feature`, `refactor`, `api-integration`, `migration` or `test-plan` based on the task.

Respect `.hayeos.json`, keep scope narrow, verify with real commands, and leave memory updates for `/haye:close`.
