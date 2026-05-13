---
name: init-memory
description: Use ONLY when /haye:start has confirmed init approval and .hayeos.json or the vault is missing - creates the canonical project-local vault. Must not be invoked by user or by other skills without explicit init approval
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
- Do not use `~/.claude/projects/.../memory` as a default memory path.
- Do not create or use a generic `memory` directory.
- Use the `<project-name>_obs` vault naming standard.
- Never initialize project memory inside `CLAUDE_PLUGIN_ROOT`.
- If `memoryPath` resolves to the plugin root or under the HayeOS plugin repo, stop and warn in Turkish: "Memory vault points to plugin root. This is unsafe. Fix .hayeos.json."

### Path Resolution Rule

The `memoryPath` from `.hayeos.json` (e.g. `./test7_obs`) MUST be resolved relative to:
- The current working directory where `claude` was launched (the project root)
- NOT relative to `~` (user home directory)
- NOT relative to the parent of the project root

### Test7 evidence

In test7, `.hayeos.json` was written correctly to `C:\Path\To\Projeler\test7\` with `memoryPath: "./test7_obs"`. The `bin/haye init` CLI created the vault at the right place: `C:\Path\To\Projeler\test7\test7_obs\`.

But later Sonnet wrote vault files to `~\Path\To\Projeler\test7_obs\` (parent directory - NOTE: `test7\` was skipped, the path was resolved against `~` instead of cwd).

### Behavioral guard

Before any Write call with a path containing `_obs/`:
1. Verify the path is anchored at the current project root, not `~`
2. If you find yourself typing `~\Desktop\...\<name>_obs\` or `~/Desktop/.../<name>_obs/`, STOP
3. Use the cwd-anchored path: `./<name>_obs/...` or the absolute path that matches `.hayeos.json` resolution

The vault must be a SIBLING of project files (under project root), not a SIBLING of the project itself.

## Init-memory boundaries
- must not load `/haye:work`
- must not start a task classification wizard
- must not create context packs
- must not execute implementation
- must not ask "Şimdi hafızayı başlatmamı ister misiniz?" after init
- must only create or repair `.hayeos.json` and files under `<resolved memoryPath>`

## Canonical Project Vault Rule

The standard HayeOS vault lives in the project root as:
`./<project-name>_obs`

The standard `.hayeos.json` is generated by the HayeOS CLI init command and must contain:
- `project`
- `memoryPath`
- `sourcePath`
- `defaultWorkflow`
- `sessionCloseRequired`

Do not hand-write an alternate config object in the skill layer.
Do not choose a hidden global `.claude/projects/.../memory` path.

## Canonical Project Root and Vault Rule

`init-memory` coordinates the approved init flow but does not invent a different project root.

The project root is the real current working directory, not Claude internal project storage under `~/.claude/projects/...`.

The standard output is:
- `<real-project-root>/.hayeos.json`
- `<real-project-root>/<project-name>_obs/`

Do not hand-write config into `~/.claude/projects/...`.
Do not create `<project-name>_obs/` there.
Do not default memory to `.claude/projects/.../memory`.

## Manual fallback only after CLI failure
If the CLI cannot run for any reason, Claude Code must create `.hayeos.json` in the current project root and create all memory vault files only under `<resolved memoryPath>`. This fallback must copy the canonical CLI config exactly and must use relative JSON paths. It must not invent alternate layouts.

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

Core markdown files must not be empty. Use useful Turkish starter content.

For `<resolved memoryPath>/HAYE.md`, do not maintain a short fallback template in this skill. Use the canonical template content from `skills/init-memory/templates/HAYE.md` as the behavioral source of truth. The manual fallback HAYE.md must include the same critical sections as the canonical template, including:

- Plugin root vs project vault
- Approval Friction Rule
- No Fake Completion Rule
- Output Budget Rule
- Quality Preservation Rule
- Auto Checkpoint Rule
- Safe Resume Rule
- Scope Control Rule
- Framework Security Rule

If the canonical template cannot be read directly, recreate `<resolved memoryPath>/HAYE.md` from that canonical content as faithfully as possible and preserve all critical rules above.

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

## Path Separation Rule (project source vs memory vault)

`init-memory` sadece proje kökünde `.hayeos.json` oluşturur/onarır ve yapılandırılmış memory vault'u `<resolved memoryPath>` altında kurar. `sourcePath` proje kodu, infra, config ve proje docs alanıdır; `memoryPath` yalnızca HayeOS hafızasıdır.

Memory vault içinde yalnızca şu tür HayeOS memory hedefleri oluşturulur veya güncellenir:
- `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, `<resolved memoryPath>/changelog.md`, `<resolved memoryPath>/health.md`
- `<resolved memoryPath>/01-prompts/`, `<resolved memoryPath>/02-decisions/`, `<resolved memoryPath>/03-bugs/`, `<resolved memoryPath>/04-tasks/`, `<resolved memoryPath>/05-sessions/`, `<resolved memoryPath>/06-prompts/`, `<resolved memoryPath>/07-checklists/`, `<resolved memoryPath>/08-raw/`, `<resolved memoryPath>/09-context-packs/`, `<resolved memoryPath>/10-reviews/`, `<resolved memoryPath>/11-metrics/`, `<resolved memoryPath>/12-risks/`, `<resolved memoryPath>/99-archive/`

Project source, infra, config ve proje docs asla vault'a yazılmaz. Bir hedef path `<resolved memoryPath>` altındaysa ve `.py`, `.ts`, `.tsx`, `.js`, `.jsx`, `.go`, `.rs`, `.java`, `.html`, `.css`, `.sh`, `.yaml`, `.yml`, `.toml`, `Dockerfile`, `docker-compose*`, `package.json`, `requirements.txt`, `pyproject.toml`, `next.config.*` gibi proje dosyası ya da `services/`, `apps/`, `packages/`, `infra/`, `scripts/`, `tests/`, `public/`, `assets/` gibi source klasörü görünüyorsa DUR.

Uyarı mesajı:
"Bu dosya memory vault'una yazılmaya çalışılıyor ama bu proje kodu/dökümanı. Proje kök dizinine (sourcePath) yazılmalı."
