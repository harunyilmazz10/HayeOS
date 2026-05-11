---
description: Debug with root-cause-first Haye workflows.
---

# /haye:fix

Use `skills/fix/SKILL.md`.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS komutları Harun için varsayılan olarak Türkçe konuşur.

Route to advanced workflows when needed:
- `bugfix` for root-cause analysis.
- `nextjs-doctor`, `prisma-doctor`, `docker-doctor`, `coolify-doctor`, `cloudflare-doctor` or `database-doctor` for platform-specific failures.

Capture symptoms, identify likely cause, make the smallest safe fix, and report verification output or the limitation.
