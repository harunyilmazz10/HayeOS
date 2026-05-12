---
name: handoff
description: Use when ending a session that another assistant or future-you will resume - produces compact brief of done/next/landmines
---

# Haye Skill: handoff

## Purpose
End a session (or hand off to a teammate, another assistant, or future-you) with a brief that lets the next person start from "I know exactly what to do" instead of "I need to read everything".

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa brief Türkçe yazılır; kod ve dosya yolları orijinal kalır.

## Inputs to inspect first
1. `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, `<resolved memoryPath>/04-tasks/active-task.md`.
2. The last few commits (`git log --oneline -10`) and the working tree state (`git status -sb`).
3. Any open bugs or risks: `03-bugs/open/`, `<resolved memoryPath>/12-risks/`.
4. The user's prompt that started this session (preserved under `01-prompts/`).

## Token discipline
- Brief is at most ~50 lines. Anything longer is a doc, not a handoff.
- Don't paste code; reference file paths.

## Workflow

### Step 1 — One-sentence status
- "We're in the middle of X, blocked on Y" — or — "Just shipped X, next is Z."
- If you can't say it in one sentence, the project is in a confused state and the handoff itself is the fix.

### Step 2 — What's done this session
- 3–7 bullets, each verifiable (commits, tests passed, deploys, files changed).

### Step 3 — What's not done (yet)
- 3–7 bullets, in order of how to attack them next.
- If something is blocked, name the blocker.

### Step 4 — Where the surprises are
- The non-obvious things the next person needs to know:
  - Failing test that's expected to fail right now
  - Environment variable that needs to be set in Coolify before the next deploy
  - Migration that hasn't run yet
  - Dependency on review from someone else
  - "That endpoint looks like it works but actually returns 200 even on error — fix scheduled"

### Step 5 — Files to read first when resuming
- Max 5. Ordered.

### Step 6 — Commands to verify the current state
- 1–3 commands the next person can run to confirm everything is as described.
- Examples: `npm test`, `prisma migrate status`, `curl /api/health`.

### Step 7 — Memory write
- The handoff itself is committed to `<resolved memoryPath>/05-sessions/latest-checkpoint.md`.
- `<resolved memoryPath>/current.md` updated with the one-sentence status.

## Anti-patterns to refuse
- "Just look at the chat history" — chat is a poor handoff medium.
- Handoffs over 100 lines — that's a status report, not a handoff.
- "Should be fine" without a verify command.
- Skipping the "surprises" section because nothing comes to mind — there's always at least one.
- Handoff that requires reading 10 files to understand.

## Output format
```markdown
# Handoff — <date>

## Status (one sentence)

## Done this session
- ...

## Not done / next up
1. (file or task) — what to do — why
2. ...

## Surprises / non-obvious
- ...

## Files to read first (max 5)
1. ...

## Verify current state
- command:
- expected:

## Open risks / decisions awaiting input
- ...
```

## Safety rules
- Handoff captures state but does not unblock approvals; if the next step is a Risk Gate, say so.
- Never include secrets in the handoff (no DB URLs, no tokens).
- A handoff that says "production is broken" must also include the immediate stop-the-bleeding action.
- File path: `<resolved memoryPath>/05-sessions/latest-checkpoint.md` (overwrites previous), plus a dated copy at `<resolved memoryPath>/05-sessions/<YYYY-MM-DD>-handoff.md`.
