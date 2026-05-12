---
name: using-hayeos
description: Use when starting any conversation - establishes how to find and use HayeOS skills, requiring Skill tool invocation before ANY response including clarifying questions
---

# Using HayeOS

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a HayeOS skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

HayeOS is a memory-first workflow plugin. Every meaningful unit of work flows through: brainstorming/planning -> bite-sized task list -> execution with verification -> checkpoint to vault -> close session.

## Instruction Priority

HayeOS skills override default behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** (CLAUDE.md, AGENTS.md, direct messages) - highest priority
2. **HayeOS skills** - override default behavior where they conflict
3. **Default behavior** - lowest priority

## The Rule

**Invoke relevant HayeOS skills BEFORE any response or action.** Even a 1% chance a skill might apply means invoke it. If invoked skill turns out wrong for the situation, you don't need to follow it.

## Red Flags - These thoughts mean STOP, you're rationalizing

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | The work or feature skill tells you HOW to explore. Check first. |
| "I'll just write the code, it's quick" | The work skill exists for a reason. Use it. |
| "User said 'devam edelim', I should keep going" | "Devam" is not a license to skip the skill check. |
| "This task is too small for Team Mode" | Team Mode triggers are written in the work skill. Read them, don't guess. |
| "I'll just write a stub plan now and detail it later" | Stub plans are explicitly banned. |
| "Verification is overhead, I can see it works" | If you didn't run the command in this turn, you cannot claim it passes. |
| "Vault setup is for next time" | Auto Checkpoint Rule applies from the first file. |
| "Output Budget said be concise, so I'll skip the plan" | Concise chat, but artifacts go to files. Plan is required. |
| "User just wants the code, not the process" | If they wanted a one-shot LLM they wouldn't have installed HayeOS. |

## Skill Priority (when multiple could apply)

1. **Process skills first** - brainstorming, work routing, fix routing - these determine HOW
2. **Domain skills second** - nextjs-doctor, prisma-doctor, etc. - these guide WHAT

"Let's build X" -> brainstorming/work first, then domain skills.
"Fix this bug" -> fix/systematic-debugging first, then domain skills.

## Mandatory Invocation Triggers

Without any user prompting, you MUST invoke:

- **work skill** - when user describes a feature, system, or non-trivial change to implement
- **fix skill** - when user describes a bug, error, or failure
- **secure skill** - when user mentions security, auth, secrets, exposure, or hardening
- **ship skill** - when user mentions deploy, release, production, or rollout
- **close skill** - at the end of a meaningful work block, before user runs `/haye:close`
- **checkpoint skill** - after 5 file modifications or before any risky operation
- **verification-before-completion mindset** - before any "done", "complete", "works", "passes" claim

If you find yourself typing one of these claim words and you haven't verified, STOP. Run the verification. Read the output. Then claim.

## When the Path Separation Rule Applies

Project source code goes to `sourcePath` (proje kökü). Memory goes to `memoryPath` (vault). The work skill has the full rule. Before writing ANY file path, ask: "Is this code/infra/docs, or is this memory?" If it's code and the path goes under `<memoryPath>/`, STOP and warn in Turkish.

This is non-negotiable. Vault pollution was the #1 failure mode in v1.0.0.

## User Response Language Rule

- If user writes Turkish, respond in Turkish.
- Code, file paths, package names, technical identifiers stay in English.
- Don't switch to English unless user explicitly asks for English.

## The Iron Law

```text
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
NO PLAN ARTIFACT UNDER 20 LINES OR WITH PLACEHOLDER PROSE
NO PROJECT SOURCE CODE INSIDE THE MEMORY VAULT
NO "DEVAM EDELIM" LOOPS - EACH "DEVAM" = ONE MEANINGFUL STEP THEN STOP
```

Violating the letter of any rule above is violating the spirit. Don't rephrase your way out.
