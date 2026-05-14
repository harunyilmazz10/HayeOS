---
description: Route development work through the HayeOS process chain (brainstorming -> writing-plans -> subagent-driven-development).
---

# /haye:work

Use `skills/work/SKILL.md`.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.

## What /haye:work does

`work` is a router. It does not classify task size, recommend a mode, or write any plan inline. v3.0.0 removes the v2.x mode selection layer (Fast / Standard / Plan First / Team Mode / Full Architecture Mode) because the Superpowers chain handles complexity through brainstorming.

When the user gives a work request, the work skill picks one of these routes:

| User input shape | Route to |
|---|---|
| Idea or feature description | `Skill(haye:brainstorming)` |
| Already approved spec, asking for plan | `Skill(haye:writing-plans)` |
| Already written plan, asking for execution | `Skill(haye:subagent-driven-development)` (preferred) or `Skill(haye:executing-plans)` |
| Bug report or error | `Skill(haye:systematic-debugging)` |
| Implementation complete, asking about merge/PR | `Skill(haye:finishing-a-development-branch)` |

## Original Prompt Preservation

The original user prompt (verbatim, in Turkish if user wrote Turkish) is preserved to `<resolved memoryPath>/01-prompts/<YYYY-MM-DD-HHMM>-<topic>.md` before any processing. This is non-negotiable for any work that goes through brainstorming.

## Path Separation

- Project source code -> `sourcePath` (project root)
- Memory artifacts -> `<resolved memoryPath>/`
  - `01-prompts/` for original prompts
  - `02-decisions/` for specs from brainstorming
  - `04-plans/` for plans from writing-plans
  - `04-tasks/active-task.md` for current task
  - `10-reviews/` for reviewer subagent outputs

Never write source code under `<resolved memoryPath>/`. Never write memory under `sourcePath/`.

## Removed in v3.0.0

`/haye:work` no longer routes to these (skills are deleted):
- `feature` -> brainstorming handles scoping now
- `team-mode` -> subagent-driven-development handles multi-perspective execution
- `refactor`, `migration`, `api-integration`, `test-plan` -> brainstorming + writing-plans cover these
- `context-pack` -> writing-plans includes a Context Section in plan format

Routing is now lean: one entry, three possible destinations (brainstorming, systematic-debugging, finishing-a-development-branch), depending on input shape.
