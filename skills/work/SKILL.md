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

Announce in Turkish:

> "Bu iş için HayeOS akışı: brainstorming -> writing-plans -> subagent-driven-development. Önce design üzerinde anlaşalım. brainstorming skill'ini açıyorum."

Then invoke `Skill(haye:brainstorming)`.

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
