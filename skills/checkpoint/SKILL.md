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
- HayeOS komutları Harun için varsayılan olarak Türkçe konuşur.

## Auto Checkpoint Rule
HayeOS uzun, riskli veya çok adımlı işlerde `/haye:close` beklemeden checkpoint yazar.

Checkpoint file locations:
- `<vault>/05-sessions/latest-checkpoint.md`
- `<vault>/04-tasks/active-task.md`
- `<vault>/current.md`
- `<vault>/next.md`

Chat'e uzun checkpoint basma. Sadece şunu söyle:

```text
Checkpoint güncellendi: 05-sessions/latest-checkpoint.md
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
3. Read `HAYE.md`, `index.md`, `current.md`, `next.md`, optional `04-tasks/active-task.md`, and optional `05-sessions/latest-checkpoint.md`.
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
- Long details go to `latest-checkpoint.md`, `current.md`, `next.md`, or session summary files.
- Chat shows only recovery summary, next 3 actions and approval question.
