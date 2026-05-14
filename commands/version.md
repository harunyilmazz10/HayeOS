---
description: Show the active/local HayeOS version and update state.
---

# /haye:version

Show the installed/local HayeOS version in a concise, user-friendly form.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.

## Behavior
Run the local CLI version helper from the HayeOS plugin root when available:

```bash
python3 bin/haye version || python bin/haye version
```

Report:
- HayeOS plugin version from `.claude-plugin/plugin.json`
- local repo commit
- current branch
- working tree clean/dirty state
- plugin cache status when it can be checked safely

If plugin cache freshness cannot be verified from the current session, say: "Plugin cache durumu bu oturumda doğrulanmadı."

## Output shape

```text
HayeOS v3.0.0
Local repo commit: <short-sha>
Branch: main
Working tree: clean/dirty
Plugin cache: refreshed / stale suspected / not checked
```
