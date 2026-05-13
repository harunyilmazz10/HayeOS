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

## Team Mode perspectives are inline

Workflow and domain guidance come from skills.
Specialist role execution for Team Mode is embedded inside `skills/team-mode/SKILL.md`.

If Team Mode needs `project-manager`, `security-reviewer`, `token-economist`, or any other specialist role, load `Skill(haye:team-mode)` and walk the embedded perspectives inline. Do not call `Skill(haye:<role-name>)` and do not attempt Task-tool subagent dispatch.

## Mandatory Invocation Triggers

Without any user prompting, you MUST invoke:

- **work skill** - when user describes a feature, system, or non-trivial change to implement
- **fix skill** - when user describes a bug, error, or failure
- **secure skill** - when user mentions security, auth, secrets, exposure, or hardening
- **ship skill** - when user mentions deploy, release, production, or rollout
- **close skill** - at the end of a meaningful work block, before user runs `/haye:close`
- **checkpoint skill** - after 5 file modifications or before any risky operation
- **verification-before-completion mindset** - before any "done", "complete", "works", "passes" claim
- **team-mode skill** - when work skill recommends Full Architecture Mode or Team Mode AND user accepts. NEVER skip this in favor of writing a plan inline.
- **init-memory skill** - when /haye:start has been answered "yes" for memory creation. NEVER use Write tool to create .hayeos.json or vault files directly; the init-memory skill is the only authorized path.

If you find yourself typing one of these claim words and you haven't verified, STOP. Run the verification. Read the output. Then claim.

## Verification Template Trap

If you find yourself ABOUT to write a verification block that looks like:

- build: pass
- tests: pass
- typecheck: pass
- lint: pass
- manual smoke: pass

STOP. This is the placeholder template, not a real verification report. You have not run those commands. Writing "pass" without running the command is the most common lie Claude tells. If the command has not been run in this turn, write "not yet verified" - never "pass".

Real verification format:

- [ ] `npm run build`
  - Exit code: 0
  - Output (last 5 lines): ...
  - Result: pass

If you don't have an exit code and an output snippet, you don't have verification.

## Init Memory Trap

If `/haye:start` asked "Bu projede Haye hafızası bulunamadı. Şimdi otomatik oluşturayım mı?" and the user said yes, your NEXT tool call MUST be `Skill(haye:init-memory)`. Not Write. Not Bash. Not anything else.

If you find yourself reaching for the Write tool to create `.hayeos.json` or `<project>_obs/<file>.md` - STOP. That is forbidden. Call the skill.

## Mode Selection Trap

If `/haye:work` offered the user a choice between Full Architecture Mode, Team Mode, Plan First, Standard Single Agent, or Fast Single Agent, and the user picked one - your NEXT tool call depends on the choice. See `skills/work/SKILL.md` "Mandatory routing after mode selection" table. The most common error is dropping into `Skill(haye:feature)` because it has imperative description language. `feature` is for ONE small slice - NOT for routing out of mode selection.

## Stub Plan Trap

If you find yourself about to write a plan section like:

```markdown
## 3. Role Findings
Belirlenen uzman rolleriyle yapılandırmalar ve görevler detaylandırılacak.

## 4. Birleştirilmiş Uygulama Planı
Uygulama planı burada oluşturulacak.

## 6. Doğrulama Planı
Her bir aşama tamamlandıkça doğrulama testleri yapılacak.
```

STOP. These are stub-plan phrases. Specifically banned in this skill:

- "Uygulama planı burada oluşturulacak"
- "burada belirtilecek"
- "ileride detaylandırılacak"
- "aşağıda detaylı olarak verilecek"
- "X yapılandırılacaktır"
- "(Devamı ... detaylı olarak belirtilmeli)"
- "Plan implementation will be defined"
- "TBD" / "TBA" / "..." as a section body

A plan section must contain ACTUAL content (file names, decisions, risks, commands, exit criteria) or it must not be claimed complete.

If you cannot fill a section with real content right now, mark it `[ ] (pending - needs <X>)` and do not check it off.

### Test7 evidence

Sonnet produced exactly this stub plan in test7:
> "3. Rol Buluntuları: Belirlenen uzman rolleriyle yapılandırmalar ve görevler detaylandırılacak."
> "4. Birleştirilmiş Uygulama Planı: Uygulama planı burada oluşturulacak."

This is the canonical Plan Depth Rule violation. Add this section's banned phrases to your active filter.

## Gate Function — Mandatory pre-claim check

Before typing any of these words in your response, run the gate function in your head:

- "başarıyla" / "successfully"
- "tamamlandı" / "completed" / "done"
- "oluşturuldu" / "created"
- "ready" / "production-ready"
- "passes" / "works"

### Gate steps

1. **Was there a Bash() / tool call in your last 5 actions whose output contained "Invalid", "Error", "Failed", "Exit code: 1", "exit code 1"?**
   - YES -> DO NOT claim success. Report the failure honestly. Write "şu hata alındı: ...".
   - NO -> continue to step 2.

2. **Was there a verification command (build/test/lint/typecheck) confirming the claim?**
   - YES with exit code 0 -> success is justified.
   - NO -> DO NOT claim success. Write "henüz doğrulanmadı".

3. **Is the claim about something that NEEDS verification (functionality, build, tests, deploy)?**
   - YES + no verification -> DO NOT claim. Run the verification first.
   - NO (e.g. file written, vault initialized) -> success acceptable if the tool call succeeded.

### Gate violations are lying

Saying "başarıyla oluşturuldu" right after 10 "Invalid tool parameters" errors is lying.
Saying "tamamlandı" without an npm run build exit code is lying.
The Iron Law's first line - "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE" - is gate-enforced, not just a guideline.

### Test8 evidence

In test8, after 10 consecutive `Task()` calls returning "Invalid tool parameters", Sonnet wrote:
> "Tim modu kapsamında aşağıdaki görevler başarıyla oluşturuldu: Görev 1: Landing Page Scope and Phase..."

No görev was actually created. Every Task() call failed. The "başarıyla" word was a direct Iron Law violation. The Gate Function exists to catch this pattern before the words leave the response.

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
