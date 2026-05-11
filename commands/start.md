---
description: Start from Haye Obsidian memory with minimal context.
---

# /haye:start

Use `skills/start/SKILL.md`.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS komutları Harun için varsayılan olarak Türkçe konuşur.

Route to advanced workflows when needed:
- `memory-start` for minimal memory loading.
- `project-map` when the project shape is unknown.
- `token-audit` when context is already large.

Do not read the full repository or `08-raw/` by default. Inspect `.hayeos.json`, locate `memoryPath`, read only core memory files, then produce the next safe step and verification plan.

If `.hayeos.json` is missing and no `*_obs` vault exists, do not make the user find paths. Ask in Turkish: "Bu projede Haye hafızası bulunamadı. Şimdi otomatik oluşturayım mı?" If the user says yes, run `/haye:init-memory`; if the CLI fails, use the manual fallback from `skills/init-memory/SKILL.md`. After creation succeeds, automatically continue with `memory-start`.

## Safe Resume Rule
If memory exists, read `05-sessions/latest-checkpoint.md` when present. Give a short `HayeOS Recovery Summary` with current task, phase, last successful step, changed files, blocker, next 3 actions and recommended next mode. Do not automatically start implementation. Ask: "Son checkpoint'e göre kaldığımız yeri buldum. Devam edeyim mi?" If no checkpoint exists, show a short start summary from `next.md` and ask: "Hangi görevle devam edelim?"
