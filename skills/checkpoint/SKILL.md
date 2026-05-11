---
name: checkpoint
description: Internal Auto Checkpoint and Safe Resume workflow for preserving HayeOS work state during long or risky sessions.
---

# Haye Skill: checkpoint

## Purpose
Internal workflow used by `/haye:work`, `/haye:fix`, `/haye:ship`, `/haye:start` and `/haye:close`. It preserves state before `/haye:close` so a crashed or interrupted Claude Code session can resume safely.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

## Auto Checkpoint Rule
HayeOS uzun, riskli veya çok adımlı işlerde `/haye:close` beklemeden checkpoint yazar.

## Plugin root vs project vault
- `CLAUDE_PLUGIN_ROOT` or HayeOS install path is the plugin code root only.
- `.hayeos.json` `memoryPath` is the only source of truth for the current project memory vault.
- Resolve `memoryPath` relative to current project root.
- Never write project checkpoints to `CLAUDE_PLUGIN_ROOT`.
- Never create project memory directories or files under the plugin installation directory.
- If a target path is under `CLAUDE_PLUGIN_ROOT`, stop and warn in Turkish: "Bu dosya plugin klasörüne yazılmaya çalışılıyor. Proje vault’u kullanılmalı."

Checkpoint file locations under resolved `memoryPath`:
- `<resolved memoryPath>/05-sessions/latest-checkpoint.md`
- `<resolved memoryPath>/04-tasks/active-task.md`
- `<resolved memoryPath>/current.md`
- `<resolved memoryPath>/next.md`

Chat'e uzun checkpoint basma. Sadece şunu söyle:

```text
Checkpoint güncellendi: <resolved memoryPath>/05-sessions/latest-checkpoint.md
```

## When to checkpoint
Checkpoint şu durumlarda mutlaka yazılır:
1. phase başında
2. phase sonunda
3. 5 veya daha fazla dosya oluşturulduğunda/değiştirildiğinde
4. dependency/security/deploy işlemi öncesinde
5. docker/build/test/lint/typecheck komutundan önce ve sonra
6. hata alındığında
7. büyük kod üretimi bittikten sonra
8. output çok uzayacaksa chat'e basmadan önce
9. riskli işlemden önce
10. kullanıcı uzun/büyük proje promptu verdiyse ilk plan tamamlandığında

## Checkpoint boundaries
- must not execute implementation
- must not create context packs
- must not start task classification
- must not run tests/build/lint
- must only update checkpoint-related files under `<resolved memoryPath>`

## Checkpoint template
Use `skills/checkpoint/templates/latest-checkpoint.md`:

```markdown
# Latest Checkpoint

## Project
## Current Task
## Current Phase
## Last Successful Step
## Completed Steps
## Files Created or Changed
## Commands Run
## Verification Status
## Current Blockers
## Risks
## Next 3 Actions
## Notes for Next Session
## Status
open
```

## Safe Resume Rule
When `/haye:start` runs:
1. Read `.hayeos.json`.
2. Locate the HayeOS vault path.
3. Read `HAYE.md`, `index.md`, `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, optional `<resolved memoryPath>/04-tasks/active-task.md`, and optional `<resolved memoryPath>/05-sessions/latest-checkpoint.md`.
4. If `latest-checkpoint.md` exists, provide a short recovery summary.
5. Do not automatically continue implementation.
6. Ask in Turkish: "Son checkpoint'e göre kaldığımız yeri buldum. Devam edeyim mi?"
7. Continue only if the user says yes, devam et, kaldığın yerden devam, or a similar approval.

Recovery summary format:

```markdown
# HayeOS Recovery Summary

## Current Task
## Current Phase
## Last Successful Step
## Changed Files
## Current Blocker
## Next 3 Actions
## Recommended Next Mode

Kaldığımız yerden devam edeyim mi?
```

## Output Budget Rule
- Checkpoint and recovery outputs must be short.
- Long details go to `<resolved memoryPath>/05-sessions/latest-checkpoint.md`, `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, or session summary files under `<resolved memoryPath>/05-sessions/`.
- Chat shows only recovery summary, next 3 actions and approval question.

## Quality Preservation Rule
- Token discipline must never reduce implementation quality.
- Do not skip necessary code reading, tests, validation, security checks, error handling, or architecture reasoning just to save tokens.
- Save tokens by reducing verbose chat output, repeated explanations, unnecessary repo scans, huge pasted logs, and oversized reports.
- Detailed technical artifacts should be written to files when needed.
- Chat should be concise, but code and project files must remain complete, maintainable, secure, and production-quality.
- If there is a conflict between token saving and correctness, correctness wins.
- If there is a conflict between speed and safety, safety wins.
