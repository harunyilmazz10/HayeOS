---
name: start
description: Use when starting a new HayeOS session - detects vault, loads context, summarizes prior state
---

# Haye Skill: start

## Purpose
Start simple session

At the beginning or end of a successful start response, show one concise version line:

```text
HayeOS aktif. (Sürüm için: `/haye:version`)
```

### Version display

If the user wants the active version inline, you may call:

```text
Bash: ${CLAUDE_PLUGIN_ROOT}/bin/haye.cmd version
# (Windows)
```

or

```text
Bash: ${CLAUDE_PLUGIN_ROOT}/bin/haye version
# (Mac/Linux)
```

Then quote the version line from that output. Do NOT fabricate a version number. Do NOT use a placeholder like `v<...>`.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

## When to use
- Use when the user's request matches this workflow.
- Use when the current project has `.hayeos.json` or an Obsidian memory vault.
- Use instead of loading a huge old conversation or scanning the entire repository.

## Start Light Rule
`/haye:start` must stay lightweight. It may only:
- check whether `.hayeos.json` exists
- read `memoryPath` when config exists
- read minimal memory files: `HAYE.md`, `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, optional `<resolved memoryPath>/04-tasks/active-task.md`, optional `<resolved memoryPath>/05-sessions/latest-checkpoint.md`
- provide a short recovery summary when a checkpoint exists
- ask which task to continue when no checkpoint exists
- ask before creating `.hayeos.json`

`/haye:start` must not:
- must not load `/haye:work`
- must not start a task classification wizard
- must not ask "Şimdi hafızayı başlatmamı ister misiniz?" after init
- must not use subagents
- must not enter plan mode
- must not scan the whole repository
- must not perform codebase exploration
- must not search test patterns
- must not produce an automatic project plan
- must not create `.hayeos.json` without explicit user approval
- must not write project files before the user says yes to init

## Inputs to inspect first
1. `.hayeos.json` if present.
2. Memory root from `memoryPath`.
3. Only minimal memory files:
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
1. Locate project config and memory path.
   - If `.hayeos.json` is missing, ask before creating `.hayeos.json`. Ask only in Turkish: "Bu projede Haye hafızası bulunamadı. Şimdi otomatik oluşturayım mı?"
   - Do not create files until the user explicitly says yes.
   - If the user says yes, IMMEDIATELY call `Skill(haye:init-memory)`. Do not use the Write tool to create `.hayeos.json` or any vault file directly.
   - Do not enumerate vault folders inline; the init-memory skill handles that.
   - Do not say "Memory başarıyla oluşturuldu" before init-memory has actually run and reported success.
   - If init-memory fails or returns an error, report the exact failure and ask the user how to proceed.
   - Legacy `/haye:init-memory` wording is only a user-facing command name; the required continuation is the Skill tool call above.
   - After successful creation, memory is already considered started. Do not ask "Şimdi hafızayı başlatmamı ister misiniz?". Read minimal memory (current.md, next.md, active-task.md) inline and ask: "Hangi görevle devam edelim?"
   - If `.hayeos.json` exists but `memoryPath` is missing or invalid, report the exact missing path in Turkish and offer to repair it through `/haye:init-memory`.
2. Read minimal memory.
3. Apply Safe Resume Rule:
   - Read `<resolved memoryPath>/05-sessions/latest-checkpoint.md` if present.
   - If it exists, provide a short `HayeOS Recovery Summary`.
   - Do not automatically continue implementation.
   - Ask in Turkish: "Son checkpoint'e göre kaldığımız yeri buldum. Devam edeyim mi?"
   - Continue only after explicit user approval.
4. If no `latest-checkpoint.md` exists, show a short start summary from `<resolved memoryPath>/next.md` and ask: "Hangi görevle devam edelim?"

## Safe Resume Rule
`/haye:start` reads `.hayeos.json`, locates the vault, then reads:
- `HAYE.md`
- `index.md`
- `<resolved memoryPath>/current.md`
- `<resolved memoryPath>/next.md`
- `<resolved memoryPath>/04-tasks/active-task.md` when present
- `<resolved memoryPath>/05-sessions/latest-checkpoint.md` when present

Recovery summary format:
```markdown
# HayeOS Recovery Summary

## Current Task
## Current Phase
## Last Successful Step
## Changed Files
## Current Blocker
## Next 3 Actions

Kaldığımız yerden devam edeyim mi?
```

Never start coding automatically from `/haye:start` when a checkpoint exists.

## Canonical Init Authority

After user approval, do not create `.hayeos.json` manually.
Delegate project initialization to the canonical HayeOS CLI init flow.

The canonical default is:
- `sourcePath`: `.`
- `memoryPath`: `./<project-name>_obs`

Any other default path is a regression unless explicitly approved by a future migration feature.

`/haye:start` and `init-memory` orchestrate approval and call the CLI. They do not manually synthesize alternate config layouts, do not choose `~/.claude/projects/.../memory`, and do not write raw Windows backslash paths into JSON.

## Init Confirmation Rule

If `.hayeos.json` is missing, do not create files automatically. Ask only in Turkish: "Bu projede Haye hafızası bulunamadı. Şimdi otomatik oluşturayım mı?"

When the user says yes (any of: "evet", "yes", "ok", "tamam", "olur"):

1. IMMEDIATELY call `Skill(haye:init-memory)`. Do not use the Write tool to create `.hayeos.json` or any vault file directly.
2. Do not enumerate vault folders inline; the init-memory skill handles that.
3. Do not say "Memory başarıyla oluşturuldu" before init-memory has actually run and reported success.
4. If init-memory fails or returns an error, report the exact failure and ask the user how to proceed.

**Direct file writes for vault setup are forbidden in this skill.** The init-memory skill is the only authorized path. This includes:
- DO NOT `Write(.hayeos.json)` with hand-written JSON
- DO NOT `Write(<vault>/HAYE.md)` with manual content
- DO NOT `Write(<resolved memoryPath>/current.md)`, `<resolved memoryPath>/next.md`, etc.
- ALL of these go through `Skill(haye:init-memory)`.

After init-memory reports success, memory is already considered started. Do not ask a second initialization question. Read minimal memory inline (current.md, next.md, active-task.md) and ask: "Hangi görevle devam edelim?"

## Canonical Project Root and Vault

The real project root is the current folder where Claude Code is running.

Do NOT treat `~/.claude/projects/<encoded-project-path>/` as the project root. That directory is Claude internal storage only.

After user approval:
- do not hand-write `.hayeos.json`
- delegate to the canonical HayeOS CLI init flow
- the CLI must create:
  - `<real-project-root>/.hayeos.json`
  - `<real-project-root>/<project-name>_obs/`

Default config:
- `sourcePath`: `.`
- `memoryPath`: `./<project-name>_obs`

## Plugin root vs project vault
- `CLAUDE_PLUGIN_ROOT` or HayeOS install path is the Plugin root.
- `.hayeos.json` `memoryPath` resolves to the Memory vault.
- `.hayeos.json` `sourcePath` resolves to the Project root.
- `/haye:start` must show a short path summary:
  - `Project root: ...`
  - `Memory vault: ...`
  - `Plugin root: ...`
- If `Memory vault` is the same as `Plugin root` or resolves under the plugin repository, stop and warn in Turkish: "Memory vault points to plugin root. This is unsafe. Fix .hayeos.json."

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

## Team/Subagent Rule
Subagent dispatch (via subagent-driven-development) is only allowed inside `/haye:work` after brainstorming and writing-plans have produced an approved plan. `/haye:start` must not use subagents and must not enter plan mode.

## No Work Loading Rule
`/haye:start` must not load `/haye:work`, must not start task classification, and must not ask broad work questions like task size, risk level or affected layers. Work classification belongs only to `/haye:work`.

## Internal routing

`/haye:start` is terminal — after presenting the recovery summary (or the "Hangi görevle devam edelim?" question) it stops and waits for the user. It does not auto-route to `/haye:work`, `/haye:close`, or any process skill. The only internal handoff allowed is to `Skill(haye:init-memory)` when the user has approved memory creation.
