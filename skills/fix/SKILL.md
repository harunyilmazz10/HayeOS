---
name: fix
description: Use when encountering any bug, test failure, build error, runtime crash, or unexpected behavior - smart router that selects between systematic-debugging, bugfix, and security investigation
---

# Haye Skill: fix

## The Iron Law

```text
NO IMPLEMENTATION CODE BEFORE PLAN APPROVAL
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
NO PROJECT SOURCE INSIDE THE MEMORY VAULT
NO STUB PLAN ARTIFACTS - UNDER 20 LINES OR WITH PLACEHOLDERS
```

Violating the letter of any rule is violating the spirit. Don't rephrase your way out.

## Red Flags - STOP, you're rationalizing

| Thought | Reality |
|---------|---------|
| "This is too simple to need a plan" | Every project gets a plan. Short is fine. Stub is not. |
| "I'll add detail to the plan later" | Stub plan in vault = lying about completion. |
| "Tests/build look fine, no need to run" | If you didn't run it in this turn, you can't claim it. |
| "User said 'devam', so 5 more files" | "Devam" = one meaningful step then stop. |
| "Let me set up the vault later" | Auto Checkpoint Rule applies from file #1. |
| "Team Mode is overkill here" | Trigger conditions are written in this skill. Read them, don't guess. |
| "I'll skip the planning section, the prompt is clear" | The plan IS the prompt's contract. Skip = scope drift. |
| "Just one quick fix without verification" | Quick = unverified = a lie. |
| "Stack drift is fine, FastAPI vs Flask is similar" | Drift requires explicit user approval. |
| "Placeholder is OK, user will fix it" | User explicitly said 'no placeholders'. You wrote them anyway. |

## The Gate Function

Before claiming "complete", "done", "works", "passes", "ready":

1. IDENTIFY: What command/check proves this claim?
2. RUN: Execute the FULL command (fresh, in this turn)
3. READ: Full output, exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence, don't claim
   - If YES: Claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying.

## Purpose
Smart router for debugging

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
2. Read minimal memory.
3. Identify task type, risks and affected files.
4. Create or reuse a context pack when work is non-trivial.
5. Execute the smallest safe step.
6. Verify with real commands when possible.
7. Update memory through `/haye:close` or session-close rules.

## Auto Checkpoint Rule
Bug/debug sırasında:
- hata görüldüğünde `<resolved memoryPath>/05-sessions/latest-checkpoint.md` yaz
- root-cause denemelerini checkpoint'e kısa yaz
- son başarılı komutu kaydet
- current blocker alanını güncelle
- çözüm bulunursa verification status yaz
- `/haye:close` beklemeden latest checkpoint güncel kalsın

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

## Smart routing
This simplified command may route internally to:
- `bugfix`
- `nextjs-doctor`
- `prisma-doctor`
- `docker-doctor`
- `coolify-doctor`
- `cloudflare-doctor`
- `database-doctor`
