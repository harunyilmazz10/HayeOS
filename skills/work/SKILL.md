---
name: work
description: Use when user describes a feature, system, refactor, or non-trivial change to implement - the entry point that routes to brainstorming, writing-plans, and subagent-driven-development
---

# Haye Skill: work

## Purpose

`work` is the entry router for non-trivial implementation requests. Its only job is to route to the correct Superpowers process skill chain, while attaching HayeOS-specific concerns (memory vault, Turkish UX, Path Separation).

## ABSOLUTE FIRST STEP — route, don't plan

When this skill loads, do not attempt to write a plan or code yourself.
Your FIRST action is to determine which sub-skill to invoke next, based on what the user provided.

## HARD-GATE Enforcement (v3.0.0 Iron Rule)

After invoking `Skill(haye:brainstorming)`, you are **forbidden** from using `Write`, `Edit`, `Create`, `Bash` (for code), or any code-producing tool until the user has explicitly approved a written design proposal.

This applies to:
- ALL requests including ones that sound trivial ("basit bir X yaz", "hello world", "küçük bir helper", "tek satırlık script")
- ALL languages (Python, JS, Bash, SQL, anything)
- ALL file types (source, config, test, doc)

The "this is too simple to need a design" trap is the most common HARD-GATE bypass. Do not fall for it.

**Correct sequence:**
1. work loads, routes to brainstorming
2. brainstorming presents a 3-5 sentence design proposal in Turkish:
   > "Şunu öneriyorum: [tasarım]. Onaylıyor musunuz?"
3. STOP. Wait for explicit user approval ("evet", "tamam", "onayla", "devam").
4. Only after approval, invoke `Skill(haye:writing-plans)` or proceed with implementation.

**Forbidden sequence:**
- work loads → brainstorming loads → Write tool fires (HARD-GATE bypass, Iron Law violation)
- Any code tool call between brainstorming load and explicit user approval

If you catch yourself about to call Write/Edit/Bash before approval, STOP. Output the design proposal instead.

### Routing Decision

| User input shape | Route to |
|---|---|
| Idea / feature description / "let's build X" / "I want a Y" | `Skill(haye:brainstorming)` |
| Already approved spec, asking for plan | `Skill(haye:writing-plans)` |
| Already written plan, asking for execution | `Skill(haye:subagent-driven-development)` (preferred) or `Skill(haye:executing-plans)` |
| Bug report / error / "X doesn't work" | `Skill(haye:systematic-debugging)` |
| Implementation complete, asking about merge/PR | `Skill(haye:finishing-a-development-branch)` |

If the user gave a feature description (e.g., "Premium doktor landing page" — an idea, not a spec, not a plan), the route is **brainstorming**.

### What `work` does in the message

Step 1 — Create the brainstorming-gate marker (Windows-safe):

```bash
# Windows (PowerShell tool call):
New-Item -ItemType Directory -Force -Path .hayeos-state | Out-Null
New-Item -ItemType File -Force -Path .hayeos-state\awaiting-design-approval | Out-Null

# Mac/Linux (Bash tool call):
mkdir -p .hayeos-state && touch .hayeos-state/awaiting-design-approval
```

The brainstorming-gate hook checks this file before allowing Write/Edit/MultiEdit. While it exists, the hook denies all code-producing tools EXCEPT writes inside the memory vault (`<project>_obs/`) — that way brainstorming can still save its design doc to `02-decisions/`.

Step 2 — Announce in Turkish:

> "Bu iş için HayeOS akışı: brainstorming -> writing-plans -> subagent-driven-development. Önce design üzerinde anlaşalım. brainstorming skill'ini açıyorum."

Step 3 — Invoke `Skill(haye:brainstorming)`.

The marker stays in place until brainstorming receives explicit user approval (see brainstorming/SKILL.md for the delete step).

DO NOT:
- Output a "Task Classification" block with task_size/task_type/risk_level. That was v2.x. v3 uses brainstorming for scoping instead.
- Output an inline plan. writing-plans skill handles that.
- Output a 5-perspective Team Mode plan. v2.x's team-mode is removed.
- Skip brainstorming because "this seems simple." HARD-GATE in brainstorming applies to every project.

## HayeOS Concerns Layered On Top

When you route to a Superpowers skill, attach these reminders **once**, at the start of brainstorming:

1. **Memory vault context** — the project has a memoryPath at `<resolved memoryPath>`. The user prompt is preserved in `01-prompts/`. Past decisions live in `02-decisions/`. Read `current.md` and `next.md` if they exist.
2. **Path Separation Rule** — code goes to `sourcePath` (proje kökü). Plans, specs, reviews go to `<memoryPath>/04-plans/`, `<memoryPath>/02-decisions/`, `<memoryPath>/10-reviews/`.
3. **Turkish UX** — respond to the user in Turkish. Keep code, file paths, identifiers in English.

After attaching these, hand off to brainstorming. Do not continue narrating.

## When Memory Is Missing

If `.hayeos.json` is not present in cwd:

> "Bu projede HayeOS hafızası bulunamadı. Önce `/haye:start` çalıştırıp hafızayı kurabilir miyiz?"

STOP. Do not proceed without memory init.

## When Active Task Exists

If `<memoryPath>/04-tasks/active-task.md` exists with a goal that contradicts the current request:

> "Aktif görev: '<old goal>'. Yeni istek: '<new>'. Eski görevi /haye:close ile kapatalım mı, yoksa yeni isteği eski görevin alt parçası olarak mı değerlendirelim?"

Wait for user choice.

## Iron Law Reminder

- NO code without brainstorming-approved design
- NO implementation in this skill — only routing
- NO long preamble — announce route, invoke skill, stop
