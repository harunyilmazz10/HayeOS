---
description: Update the installed HayeOS plugin repository safely.
---

# /haye:update

Use `skills/update/SKILL.md`.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

## Purpose
HayeOS plugin repo'sunu GitHub'dan güvenli şekilde güncelle. Project vault, context pack, checkpoint veya kullanıcı proje dosyalarına dokunma.

## Version and cache UX
- Güncelleme öncesi HayeOS sürümünü `.claude-plugin/plugin.json` üzerinden raporla.
- Güncelleme sonrası yeni sürümü tekrar raporla.
- Kod güncellendi ama sürüm değişmediyse bunu dürüstçe söyle.
- HayeOS'a özel plugin cache varsa yalnızca HayeOS cache subtree'sini temizle; tüm Claude cache'i silme.
- Güncelleme veya cache refresh sonrası kullanıcıya `/reload-plugins` çalıştırmasını söyle.

## Safety summary
- Önce plugin root'u tespit et.
- Plugin root bulunamazsa dur; bulunduğun kullanıcı/proje klasöründe git repo oluşturma.
- `.git` yoksa güncelleme yapma; yeniden clone gerektiğini Türkçe açıkla.
- `origin` URL farklıysa onay almadan değiştirme.
- `git init`, placeholder remote veya placeholder repository URL kullanma.
- Local değişiklik varsa otomatik pull yapma.
- Sadece temiz repo'da `git fetch origin` ve `git pull --ff-only origin main` kullan.
- Güncellemeden sonra `claude plugin validate .`, varsa `./scripts/verify.sh`, mümkünse `bin/haye --help` ve `bin/haye version` çalıştır.
- Commit veya push yapma.
- Sonunda `/reload-plugins` çalıştırmayı öner; gerekirse Claude Code'u kapatıp yeniden açmanın da güvenli fallback olduğunu belirt.
