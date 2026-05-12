---
name: context-pack
description: Use before any non-trivial coding, debugging, or review task - generates minimal task-specific context to avoid loading the whole codebase
---

# Haye Skill: context-pack

## Purpose
Generate a minimal task-specific context pack before coding, debugging, deploying, or reviewing.

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
1. First read `.hayeos.json` from current project root.
2. Resolve `memoryPath` relative to current project root.
3. Only minimal memory files:
   - `HAYE.md`
   - `index.md`
   - `<resolved memoryPath>/current.md`
   - `<resolved memoryPath>/next.md`
   - `<resolved memoryPath>/04-tasks/active-task.md` when present.

## Plugin root vs project vault
- `CLAUDE_PLUGIN_ROOT` or HayeOS install path is the plugin code root only.
- `.hayeos.json` `memoryPath` is the only source of truth for the current project memory vault.
- `.hayeos.json` `sourcePath` is the current project source root.
- Write context packs ONLY to `<resolved memoryPath>/09-context-packs/`.
- Never write project context packs to `CLAUDE_PLUGIN_ROOT`.
- Never create `09-context-packs` under the plugin installation directory.
- If `memoryPath` is missing, stop and ask to run `/haye:init-memory`.
- Before writing, verify the target path is not under `CLAUDE_PLUGIN_ROOT`. If it is, stop and warn in Turkish: "Bu dosya plugin klasörüne yazılmaya çalışılıyor. Proje vault'u kullanılmalı."

## Token discipline
- Do not scan the whole Obsidian vault.
- Do not read `08-raw/` unless explicitly required.
- Do not read the whole repo before a context pack is created.
- Prefer summaries, file paths, root causes, decisions and verification outputs over pasted logs.
- If context is growing, recommend `/clear` plus `/haye:start` after `/haye:close`.

## Output Budget Rule
- Chat cevabını kısa tut; varsayılan 1500-3000 token hedefle.
- Büyük context pack içeriklerini chat'e basma; HayeOS vault içinde `<resolved memoryPath>/09-context-packs/` altına yaz.
- Chat'te context pack dosya yolu, kısa özet, kritik kararlar, doğrulama durumu ve sıradaki 3 adımı ver.
- If output would become long, prefer writing the detailed content to `docs/` or the HayeOS vault and provide a concise chat summary. Ask for continuation only if the user explicitly requested a long multi-part chat response.

## Quality Preservation Rule
- Token discipline must never reduce implementation quality.
- Do not skip necessary code reading, tests, validation, security checks, error handling, or architecture reasoning just to save tokens.
- Save tokens by reducing verbose chat output, repeated explanations, unnecessary repo scans, huge pasted logs, and oversized reports.
- Detailed technical artifacts should be written to files when needed.
- Chat should be concise, but code and project files must remain complete, maintainable, secure, and production-quality.
- If there is a conflict between token saving and correctness, correctness wins.
- If there is a conflict between speed and safety, safety wins.

## Workflow
1. Locate project config and memory path.
2. Read minimal memory.
3. Identify only the task-relevant memory and source files needed for context.
4. Read only the necessary source files; do not scan the entire repository.
5. Create or update a context pack only under `<resolved memoryPath>/09-context-packs/<task>.md`.
6. Return a short chat summary with the context pack path, key included files and any known gaps.

## Context-pack boundaries
- must not execute implementation
- must not run tests/build/lint
- must not start work execution
- must not create project-root `09-context-packs`
- must not write to `CLAUDE_PLUGIN_ROOT`

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

## Path Separation Rule (context packs)

Context pack dosyaları vault içindeki `<resolved memoryPath>/09-context-packs/` altına yazılır. Context pack üretmek, analiz edilen source dosyalarını vault'a taşımak veya proje docs'larını vault içinde yeniden üretmek anlamına gelmez.

- Source code, project docs, infra ve config dosyaları `sourcePath` altından okunur.
- Context pack summary ve handoff içeriği `<resolved memoryPath>/09-context-packs/<task>.md` altına yazılır.
- Proje kodu, `Dockerfile`, `docker-compose*.yml`, `package.json`, `requirements.txt`, `pyproject.toml`, source `docs/`, `services/`, `apps/`, `infra/`, `scripts/`, `tests/`, `public/` ve `assets/` vault'a yazılmaz.
- Hedef path `<resolved memoryPath>` altında proje kodu/dökümanı gibi görünüyorsa DUR ve Türkçe uyar.

Uyarı mesajı:
"Bu dosya memory vault'una yazılmaya çalışılıyor ama bu proje kodu/dökümanı. Proje kök dizinine (sourcePath) yazılmalı."
