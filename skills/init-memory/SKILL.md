---
name: init-memory
description: Create or repair the Obsidian memory vault for the current project. Use when setting up Haye for a project or when core memory files are missing.
---

# Haye Skill: init-memory

## Purpose
Create or repair the Obsidian memory vault for the current project. Use when setting up Haye for a project or when core memory files are missing.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

## When to use
- Use when the user's request matches this workflow.
- Use when the current project has `.hayeos.json` or an Obsidian memory vault.
- Use instead of loading a huge old conversation or scanning the entire repository.

## Inputs to inspect first
1. `.hayeos.json` if present.
2. Resolve Memory vault from `.hayeos.json` `memoryPath` relative to current project root.
3. Keep Plugin root and Memory vault separate: `CLAUDE_PLUGIN_ROOT` is used only to find HayeOS CLI wrappers.
4. Only minimal memory files:
   - `HAYE.md`
   - `index.md`
   - `<resolved memoryPath>/current.md`
   - `<resolved memoryPath>/next.md`
   - `<resolved memoryPath>/04-tasks/active-task.md` when present.

## Token discipline
- Do not scan the whole Obsidian vault.
- Do not read `08-raw/` unless explicitly required.
- Do not read the whole repo before a context pack is created.
- Prefer summaries, file paths, root causes, decisions and verification outputs over pasted logs.
- If context is growing, recommend `/clear` plus `/haye:start` after `/haye:close`.

## Workflow
1. Locate the current project root.
2. If `.hayeos.json` and the configured vault already exist, report that memory is ready. Do not ask a second memory-start question.
3. If this skill was invoked from `/haye:start`, it may run only after the user answered yes to: "Bu projede Haye hafızası bulunamadı. Şimdi otomatik oluşturayım mı?"
4. If memory is missing and the user has approved init, initialize it without asking the user to find `bin/haye`, bash, Python or plugin paths.
5. First try CLI commands through `${CLAUDE_PLUGIN_ROOT}`.
6. If every CLI command fails, use the mandatory manual fallback below.
7. Verify that `.hayeos.json`, `HAYE.md`, `index.md`, `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, `<resolved memoryPath>/changelog.md` and `<resolved memoryPath>/health.md` exist.
8. After successful creation, memory is already started. Do not ask "Şimdi hafızayı başlatmamı ister misiniz?"
9. Do not load `/haye:work`, do not start a task classification wizard, and do not move into implementation from init-memory.

## Cross-platform CLI init order
Never recommend only `bin/haye init` as a relative command. Use `${CLAUDE_PLUGIN_ROOT}` first.

Windows attempts:
1. `${CLAUDE_PLUGIN_ROOT}\bin\haye.cmd init`
2. `powershell -ExecutionPolicy Bypass -File ${CLAUDE_PLUGIN_ROOT}\bin\haye.ps1 init`
3. `python ${CLAUDE_PLUGIN_ROOT}\bin\haye init`
4. `py ${CLAUDE_PLUGIN_ROOT}\bin\haye init`

Mac/Linux attempts:
1. `python3 ${CLAUDE_PLUGIN_ROOT}/bin/haye init`
2. `python ${CLAUDE_PLUGIN_ROOT}/bin/haye init`
3. `${CLAUDE_PLUGIN_ROOT}/bin/haye init`

If `${CLAUDE_PLUGIN_ROOT}` is unavailable, infer the plugin root from the loaded command/skill location when possible. If it still cannot be resolved, skip CLI execution and use the manual fallback.

## Project vault safety
- `.hayeos.json` `memoryPath` is the only source of truth for project memory.
- New init must write a relative `memoryPath`: `./<project-name>_obs`.
- New init must write `sourcePath`: `"."`.
- Do not write Windows absolute paths into `.hayeos.json`.
- Do not write JSON backslash paths into `.hayeos.json`.
- Do not create or use a generic `memory` directory.
- Use the `<project-name>_obs` vault naming standard.
- Never initialize project memory inside `CLAUDE_PLUGIN_ROOT`.
- If `memoryPath` resolves to the plugin root or under the HayeOS plugin repo, stop and warn in Turkish: "Memory vault points to plugin root. This is unsafe. Fix .hayeos.json."

## Init-memory boundaries
- must not load `/haye:work`
- must not start a task classification wizard
- must not create context packs
- must not execute implementation
- must not ask "Şimdi hafızayı başlatmamı ister misiniz?" after init
- must only create or repair `.hayeos.json` and files under `<resolved memoryPath>`

## Mandatory manual fallback
If the CLI cannot run for any reason, Claude Code must directly create the memory files in the current project root. This fallback is required on Windows, Mac and Linux.

Create `.hayeos.json`:

```json
{
  "project": "<project-name>",
  "memoryPath": "./<project-name>_obs",
  "sourcePath": ".",
  "defaultWorkflow": "memory-first",
  "sessionCloseRequired": true
}
```

Create this vault structure under `<resolved memoryPath>`:

```text
<resolved memoryPath>/HAYE.md
<resolved memoryPath>/index.md
<resolved memoryPath>/current.md
<resolved memoryPath>/next.md
<resolved memoryPath>/changelog.md
<resolved memoryPath>/health.md
<resolved memoryPath>/00-system/
<resolved memoryPath>/01-project/
<resolved memoryPath>/01-prompts/
<resolved memoryPath>/02-decisions/
<resolved memoryPath>/03-bugs/open/
<resolved memoryPath>/03-bugs/solved/
<resolved memoryPath>/03-bugs/recurring/
<resolved memoryPath>/04-tasks/
<resolved memoryPath>/05-sessions/
<resolved memoryPath>/06-prompts/
<resolved memoryPath>/07-checklists/
<resolved memoryPath>/08-raw/claude-sessions/
<resolved memoryPath>/08-raw/terminal-logs/
<resolved memoryPath>/08-raw/screenshots/
<resolved memoryPath>/08-raw/old-prompts/
<resolved memoryPath>/09-context-packs/
<resolved memoryPath>/10-reviews/
<resolved memoryPath>/11-metrics/
<resolved memoryPath>/12-risks/
<resolved memoryPath>/99-archive/
```

Core markdown files must not be empty. Use useful Turkish starter content:

`HAYE.md`:
```markdown
# HAYE.md

Project: <project-name>

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

## Proje kuralları
- Oturum başında `/haye:start`, oturum sonunda `/haye:close` kullan.
- Önce minimal hafıza oku: `HAYE.md`, `index.md`, `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`.
- `08-raw/` klasörünü kullanıcı istemedikçe okuma.

## Token kuralları
- Büyük logları ve tüm repo çıktısını yapıştırma.
- Özet, dosya yolu, karar ve doğrulama çıktısı kullan.

## Dependency security
- Dependency seçerken `latest` kullanma.
- `package.json`, lockfile, audit çıktısı ve mümkünse resmi advisory kaynaklarını kontrol et.
- Cloudflare WAF dependency patch yerine geçmez.
```

`index.md`:
```markdown
# Hafıza Haritası

- [[HAYE]]
- [[current]]
- [[next]]
- [[changelog]]
- [[health]]
- [[<resolved memoryPath>/04-tasks/active-task]]
- [[<resolved memoryPath>/02-decisions/safe-dependency-versions]]
- [[<resolved memoryPath>/12-risks/dependency-risks]]
```

`<resolved memoryPath>/current.md`:
```markdown
# Mevcut Durum

## Proje
- Ad: <project-name>
- Kaynak: `.`

## Aktif odak
- Henüz belirlenmedi.
```

`<resolved memoryPath>/next.md`:
```markdown
# Sıradaki İşler

1. Aktif görevi netleştir.
2. Gerekirse context pack oluştur.
3. En küçük güvenli değişikliği yap.
4. Doğrulama komutunu çalıştır.
5. `/haye:close` ile hafızayı güncelle.
```

`<resolved memoryPath>/changelog.md`:
```markdown
# Değişiklik Geçmişi

## Başlangıç
- Haye hafızası oluşturuldu.
```

`<resolved memoryPath>/health.md`:
```markdown
# Bellek Sağlığı

- Durum: oluşturuldu
- Memory lint: bekliyor
- Dependency audit: gerektiğinde çalıştırılacak
- React/Next güvenlik kontrolü: proje uygunsa çalıştırılacak
```

## Output format
- What I found
- What I will do / did
- Risks
- Files touched or to inspect
- Verification command/result
- Memory updates required

## Safety rules
- Do not run destructive commands without explicit approval.
- Do not auto-upgrade dependencies without approval.
- Do not claim safe/fixed/done without verification output or a clear limitation note.
