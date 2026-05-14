---
name: using-hayeos
description: Use when starting any conversation - establishes how to find and use HayeOS skills, requiring Skill tool invocation before ANY response including clarifying questions
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a HayeOS skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

# Using HayeOS

HayeOS is a memory-first, discipline-first workflow plugin built on the Superpowers process model.

Every meaningful unit of work flows through:

1. **brainstorming** — idea -> design spec (with user approval gate)
2. **writing-plans** — spec -> bite-sized implementation plan
3. **subagent-driven-development** OR **executing-plans** — task-by-task execution with review checkpoints
4. **test-driven-development** — every task: failing test first, minimal code, refactor
5. **verification-before-completion** — every claim of completion requires evidence
6. **checkpoint** + **close** — HayeOS-specific memory vault updates

## Instruction Priority

HayeOS skills override default behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** (CLAUDE.md, AGENTS.md, direct messages) — highest priority
2. **HayeOS skills** — override default behavior where they conflict
3. **Default behavior** — lowest priority

## How to Access Skills

**In Claude Code:** Use the `Skill` tool. When you invoke a skill, its content is loaded — follow it directly. Never use the Read tool on skill files.

**Plugin-namespaced form:** `haye:<skill-name>` (e.g., `haye:brainstorming`, `haye:writing-plans`).

## The Rule

**Invoke relevant HayeOS skills BEFORE any response or action.** Even a 1% chance a skill might apply means invoke it. If invoked skill turns out wrong for the situation, you don't need to follow it.

## Red Flags — These thoughts mean STOP, you're rationalizing

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I'll just write the code, it's quick" | brainstorming + writing-plans exist for a reason. Use them. |
| "User said 'devam edelim', I should keep going" | "Devam" is not a license to skip the skill check. |
| "This task is too small to need a plan" | brainstorming HARD-GATE applies to EVERY project. |
| "I'll write a stub plan and detail it later" | Stub plans are explicitly banned in writing-plans. |
| "Verification is overhead, I can see it works" | verification-before-completion is the Iron Law. |
| "User just wants the code, not the process" | If they wanted a one-shot LLM they wouldn't have installed HayeOS. |
| "I know what that skill says, no need to invoke" | Knowing the concept does not equal following the discipline. Invoke it. |

## Skill Priority (when multiple could apply)

1. **Process skills first** — brainstorming, writing-plans, systematic-debugging — these determine HOW
2. **HayeOS-specific skills second** — work, start, checkpoint, close — these handle memory and routing
3. **TDD always applies** — test-driven-development is invoked alongside, not in sequence

"Let's build X" -> brainstorming -> writing-plans -> subagent-driven-development.
"Fix this bug" -> systematic-debugging -> test-driven-development.
"Plan looks done, run it" -> subagent-driven-development OR executing-plans.

## Mandatory Invocation Triggers

Without any user prompting, you MUST invoke:

- **brainstorming skill** — when user describes ANY new feature, system, or non-trivial change
- **writing-plans skill** — when brainstorming reaches an approved spec
- **subagent-driven-development skill** — when a plan is ready and tasks are mostly independent
- **executing-plans skill** — when plan is ready but subagent dispatch isn't ideal
- **dispatching-parallel-agents skill** — when facing 2+ independent failures/tasks that can be investigated concurrently
- **test-driven-development skill** — when implementing any feature or bugfix, before writing implementation code
- **verification-before-completion skill** — before ANY "done", "complete", "works", "passes", "başarıyla" claim
- **systematic-debugging skill** — when user describes a bug, error, or failure
- **requesting-code-review skill** — after each task in subagent-driven-development, before merge, on completion
- **receiving-code-review skill** — when user gives you code review feedback (don't blindly agree, verify technically)
- **using-git-worktrees skill** — when starting feature work that needs workspace isolation
- **finishing-a-development-branch skill** — when implementation is complete, before merge/PR
- **writing-skills skill** — when creating new HayeOS skills or editing existing ones
- **checkpoint skill** — after 5 file modifications or before any risky operation (HayeOS-specific)
- **close skill** — at the end of a meaningful work block (HayeOS-specific)
- **init-memory skill** — when /haye:start has been answered "yes" for memory creation

## Skill Types

**Rigid** (TDD, verification-before-completion, systematic-debugging): Follow exactly. Don't adapt away discipline.

**Flexible** (brainstorming, writing-plans patterns): Adapt principles to context.

The skill itself tells you which.

## HayeOS-Specific Rules

### Path Separation Rule

Project source code goes to `sourcePath` (proje kökü).
Memory and planning artifacts go to `memoryPath` (vault, `<project>_obs/`).

Before writing ANY file path, ask: "Is this code/infra, or is this memory/planning?"
- Source code under `<memoryPath>/` -> STOP and warn in Turkish.
- Plans (`writing-plans` output) go to `<memoryPath>/04-plans/`.
- Specs (`brainstorming` output) go to `<memoryPath>/02-decisions/`.

This is non-negotiable. Vault pollution was the #1 failure mode in v1.0.0.

### User Response Language Rule (Turkish)

- If user writes Turkish, respond in Turkish.
- Code, file paths, package names, technical identifiers stay in English.
- Skill content (which is English) is followed AS-IS — translate only your reply to the user.
- Don't switch to English unless user explicitly asks for English.

### Devam Loop Rule

When user says "devam", "continue", "ilerle", you do ONE meaningful step, then STOP and present results. Never chain multiple steps just because the user said "continue."

### Output Budget Rule

- Chat output is conversational. Plans, specs, large artifacts go to files in `<memoryPath>/`.
- Don't paste long logs in chat; use `head`/`grep`/save to `08-raw/`.
- Don't re-read the same file multiple times per session.

## The Iron Law

```text
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
NO IMPLEMENTATION CODE BEFORE BRAINSTORMING + APPROVED PLAN
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST (TDD)
NO PROJECT SOURCE CODE INSIDE THE MEMORY VAULT
NO "DEVAM EDELIM" LOOPS — EACH "DEVAM" = ONE MEANINGFUL STEP THEN STOP
```

Violating the letter of any rule above is violating the spirit. Don't rephrase your way out.

## Why Subagents Matter

HayeOS v3 builds on `subagent-driven-development` because Sonnet's tendency to claim "başarıyla tamamlandı" without verification is structurally prevented by:

- **Implementer** subagent does the task (fresh context, focused only on this task)
- **Spec reviewer** subagent confirms code matches plan
- **Code quality reviewer** subagent confirms quality
- All three must approve before the task is marked complete

This is mechanical discipline. The orchestrating Sonnet cannot single-handedly declare success — three separate dispatches must agree.

For projects where subagents aren't ideal, `executing-plans` is the fallback with manual review checkpoints.

## Memory Vault Layout

Every HayeOS project has a memory vault at `<project>_obs/` (sibling of project root):

```
<project>_obs/
HAYE.md              # vault index
current.md           # current focus
next.md              # next actions
changelog.md         # session-by-session log
health.md            # vault health metadata
01-prompts/          # original user prompts preserved
02-decisions/        # specs from brainstorming, architectural decisions
03-bugs/             # open/, solved/, recurring/
04-plans/            # plans from writing-plans
04-tasks/            # active-task.md
05-sessions/         # session checkpoints
06-prompts/          # crafted prompts for reuse
07-checklists/
08-raw/              # logs, screenshots, terminal output
09-context-packs/    # context bundles for handoff
10-reviews/          # review notes from reviewer subagents
11-metrics/
12-risks/
99-archive/
```

This vault is created by `Skill(haye:init-memory)`. Never create vault files manually via Write tool.
