---
name: token-audit
description: Find Claude Code context/token waste and recommend /clear, context packs, session splits, summary updates and model selection.
---

# Haye Skill: token-audit

## Purpose
Find what is eating Claude's context budget in the current session and recommend the smallest fix that preserves quality (Quality Preservation Rule wins over savings).

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa öneriler Türkçe verilir.

## Inputs to inspect first
1. Approximate session length (conversation turns + average message length).
2. `<resolved memoryPath>/HAYE.md`, `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, `<resolved memoryPath>/04-tasks/active-task.md` — line counts.
3. Whether a context-pack exists for the active task under `<resolved memoryPath>/09-context-packs/`.
4. Whether long content was written to `docs/` or pasted into chat.
5. Files re-read by Claude multiple times this session (the user can recall, or check tool call history).

## Token discipline (recursive)
- This skill's own output must stay short. If a token-audit report runs more than ~40 lines, the skill is contributing to the problem.

## What to look for

### Memory bloat
- `<resolved memoryPath>/current.md` over 180 lines (HayeOS lint rule)
- `<resolved memoryPath>/next.md` over 50 actions
- `<resolved memoryPath>/04-tasks/active-task.md` carrying notes that should be in a context pack
- `HAYE.md` over 250 lines

### Raw queue
- Files under `<resolved memoryPath>/08-raw/` not yet ingested via `ingest-session` skill
- Each unprocessed raw file is a temptation to re-read

### In-session habits
- Same file read 3+ times (each read costs tokens)
- Big logs pasted whole instead of `head`/`tail`/`grep`
- Full repo tree listed when a single directory would do
- Architecture/roadmap content being written into chat instead of `docs/architecture.md`, `docs/roadmap.md` (Output Budget Rule)
- Team Mode agent outputs longer than 7 bullets each (HayeOS cap)
- Repeated re-explanations of the same context

### Missing context pack
- The active task is non-trivial but `<resolved memoryPath>/09-context-packs/` has nothing for it. Creating one moves persistent task context out of the live conversation.

### Wrong tool for the job
- Asking Claude to grep for "TODO" across the repo when `grep -rn 'TODO' .` would do it in chat
- Pasting JSON when `jq` would extract the field

## Output format
```markdown
## Context state
- approximate session tokens: <low / medium / high / very high>
- top 3 contributors:
  1.
  2.
  3.

## Memory bloat
- file → size → suggested cut

## Raw queue
- files needing ingest:

## Recommendations (in order)
1. <smallest, most-saving action>
2.
3.

## Quality preservation note
- one thing we must NOT skip, even when trimming
```

## When to recommend `/clear` + `/haye:start`
- Conversation is past ~50 turns AND active task is wrapping up
- A fresh phase is starting and previous phase's debris is now noise
- After `/haye:close` so memory has the handoff

## When NOT to recommend `/clear`
- Mid-debugging without a checkpoint and saved repro
- During Full Architecture Mode planning when prior context is still relevant
- When the user is iterating on the same artifact

## Safety rules
- Never recommend clearing context mid-task without a `/haye:close` and a checkpoint in `<resolved memoryPath>/05-sessions/latest-checkpoint.md`.
- Never recommend skipping necessary code reading, tests, or security checks to save tokens (Quality Preservation Rule).
- Never suggest a smaller model for the next step if that step is high-risk (security, payment, migration).
- Long audit findings go to `<resolved memoryPath>/10-reviews/token-audit-<date>.md`; chat gets the summary.
