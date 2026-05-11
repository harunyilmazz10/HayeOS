---
description: Create or repair Haye Obsidian memory for the current project.
---

# /haye:init-memory

Use `skills/init-memory/SKILL.md`.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

## Init behavior
- Kullanıcıdan `bin/haye`, bash yolu veya Python yolu bulmasını isteme.
- Önce plugin root için `${CLAUDE_PLUGIN_ROOT}` kullanmayı dene.
- Windows'ta sırasıyla `${CLAUDE_PLUGIN_ROOT}\bin\haye.cmd init`, `powershell -ExecutionPolicy Bypass -File ${CLAUDE_PLUGIN_ROOT}\bin\haye.ps1 init`, `python ${CLAUDE_PLUGIN_ROOT}\bin\haye init`, `py ${CLAUDE_PLUGIN_ROOT}\bin\haye init` dene.
- Mac/Linux'ta sırasıyla `python3 ${CLAUDE_PLUGIN_ROOT}/bin/haye init`, `python ${CLAUDE_PLUGIN_ROOT}/bin/haye init`, `${CLAUDE_PLUGIN_ROOT}/bin/haye init` dene.
- CLI çalışmazsa manuel fallback ile `.hayeos.json` ve Obsidian vault dosyalarını doğrudan oluştur.
