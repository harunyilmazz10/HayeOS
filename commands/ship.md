---
description: Check release and deploy readiness.
---

# /haye:ship

Use `skills/ship/SKILL.md`.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS komutları Harun için varsayılan olarak Türkçe konuşur.

Route to advanced workflows when needed:
- `deploy`, `review`, `security` and `dependency-security`.
- `cloudflare-doctor`, `coolify-doctor` and `docker-doctor` for hosting/release checks.

Confirm tests, dependency risk, deployment assumptions and rollback notes before claiming release readiness.

## Auto Checkpoint Rule
Deploy/release sırasında pre-ship checkpoint yaz. Build/test/deploy öncesi ve sonrası `<resolved memoryPath>/05-sessions/latest-checkpoint.md` güncelle. Failure olursa current blocker yaz; rollback gerekiyorsa next 3 actions içine ekle.
