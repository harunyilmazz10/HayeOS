---
description: Run security, dependency and safe-version workflows.
---

# /haye:secure

Use `skills/secure/SKILL.md`.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

Route to advanced workflows when needed:
- `security`, `dependency-security`, `dependency-audit` and `version-policy`.
- `react-nextjs-security` for React Server Components, Next.js App Router, middleware/proxy, server actions, image optimization or cache components.
- `secrets-audit`, `auth-audit` and `exposed-port-audit` for application risk.

Never blindly use `latest`. Use official live advisories when available; when they are unavailable, say the result is based on local files and embedded Haye rules only.

Read `package.json` and the active lockfile from `.hayeos.json` `sourcePath`. If no lockfile exists, report that dependency resolution is not pinned. For React/Next projects, check the embedded baselines: avoid RSC `19.0.0-19.0.5`, `19.1.0-19.1.6`, `19.2.0-19.2.5`; require Next.js `15.5.16+` for 15.x and `16.2.5+` for 16.x. Treat Cloudflare WAF as defense-in-depth only.

Security reports and memory notes must be written under the resolved `.hayeos.json` `memoryPath`, never under `CLAUDE_PLUGIN_ROOT`.
