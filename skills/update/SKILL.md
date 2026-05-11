---
name: update
description: Safely update the installed HayeOS Claude Code plugin from GitHub without touching project memory.
---

# Haye Skill: update

## Purpose
Update the installed HayeOS plugin repository from GitHub so users do not need to manually run git commands on every machine.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

## Scope and safety
- `/haye:update` only updates the HayeOS plugin repository.
- If plugin root cannot be detected, stop.
- Never run `git init`.
- Never run `git remote add` with a placeholder.
- Never set remote to a placeholder.
- Never create a git repo in the current user/project directory.
- Do not commit.
- Do not push.
- Do not use placeholder repository URLs.
- Do not remove, overwrite, discard, clean or hard reset local files.
- Do not touch project vault files.
- Do not create project memory, context packs, checkpoints or active tasks.
- Keep plugin root and project vault separate: `CLAUDE_PLUGIN_ROOT` is plugin code root; `.hayeos.json` `memoryPath` belongs to the current project and is not used by this update flow.
- must not execute implementation
- must not create context packs
- must not touch project memory

## Plugin root detection
1. Prefer `CLAUDE_PLUGIN_ROOT`.
2. If unavailable, use the marketplace install path or current plugin path exposed by Claude Code.
3. If unavailable, stop and say in Turkish: "HayeOS plugin root klasörünü bulamadım. Güncelleme için plugin kurulum yolunu belirtmelisin."

## Git repository checks
Run from plugin root.

1. Check whether `.git` exists.
   - If missing, stop and say: "Bu HayeOS kurulumu git repo değil. Güncelleme için GitHub'dan tekrar clone etmek gerekir."
2. Capture old commit:
   - `git rev-parse --short HEAD`
3. Check remotes:
   - `git remote -v`
   - Expected origin URL: `https://github.com/harunyilmazz10/HayeOS.git`
   - If origin is missing or different, show the current value and ask before changing anything. Do not auto-set a placeholder remote.
4. Check branch:
   - `git branch --show-current`
   - If branch is not `main`, report it and behave conservatively. Do not change branches automatically.
5. Check local changes:
   - `git status --porcelain`
   - If output is not empty, do not pull. Ask in Turkish: "HayeOS klasöründe local değişiklikler var. Güncellemeden önce bunları çözmelisin. Değişiklikleri göstereyim mi?"

## Update flow
Only if the repo is clean, origin is correct and branch is safe:

```bash
git fetch origin
git pull --ff-only origin main
```

Then capture new commit:

```bash
git rev-parse --short HEAD
```

If old commit equals new commit, report that HayeOS was already up to date.

## Validation flow
After update, run what is available from plugin root:

```bash
claude plugin validate .
./scripts/verify.sh
bin/haye --help
```

If `./scripts/verify.sh` or `bin/haye` is missing, report that it was not run and why. Do not claim validation passed unless command output confirms it.

## Manual fallback commands
Windows PowerShell:

```powershell
cd C:\Path\To\HayeOS
git pull
claude plugin validate .
```

Mac/Linux:

```bash
cd /path/to/HayeOS
git pull
claude plugin validate .
```

## Output format
Respond in Turkish and keep it concise:

- Plugin root
- Eski commit
- Yeni commit
- Güncelleme var mıydı?
- `claude plugin validate .` sonucu
- `./scripts/verify.sh` sonucu
- `bin/haye --help` sonucu
- Yeniden başlatma gerekli mi?

End with:

```text
Güncelleme tamamlandıysa Claude Code'u kapatıp yeniden açmanız önerilir.
```
