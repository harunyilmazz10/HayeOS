# Token Discipline

Context window is a budget. HayeOS v3.0.0 spends it deliberately.

## Where tokens go

1. SessionStart hook injects `using-hayeos` content (~9 KB)
2. Skill invocations load their full content (~5-15 KB each)
3. File reads (source code, plans, specs)
4. Conversation history (your prompts + Claude's responses)
5. Tool use markup (Bash output, Read content)

A long session can easily reach 50% context. When that happens, `/haye:close` writes the current state to vault and a fresh `/haye:start` resumes with full context but light token usage.

## Memory vault saves tokens

Instead of:
- Re-reading the same file every turn
- Pasting long logs into chat
- Re-summarizing project state for each new request

Use the vault:
- `current.md` keeps the active focus (under 150 lines)
- `next.md` keeps next actions short
- `04-plans/<plan>.md` contains the full plan; chat references it
- `09-context-packs/` bundles relevant snippets for handoff
- `08-raw/` stores logs; chat references but does not paste

## Patterns

### Long log analysis
Bad: Paste 800 lines of build output into chat.
Good: Save to `08-raw/terminal-logs/<timestamp>-build.log`, then `grep`/`head` for the relevant section.

### Repo scan
Bad: Read 40 files to "understand the codebase".
Good: Run `glob` to map structure, read 3 high-information files, write findings to `09-context-packs/<topic>.md`.

### Multi-session work
Bad: Re-explain the project to Claude every session.
Good: `/haye:start` loads HAYE.md + current.md + next.md + active-task.md, instantly resuming context.

### Plan vs implementation
Bad: Long planning discussion in chat, then implementation in the same chat.
Good: Brainstorming -> spec saved to `02-decisions/`. Writing-plans -> plan saved to `04-plans/`. Execution dispatches fresh subagents with curated context, not the full chat history.

## Subagent dispatch saves tokens

The Superpowers subagent pattern is itself token discipline:

- Implementer subagent gets exactly the task text + relevant file paths, not the entire chat history
- Spec reviewer subagent gets the plan + the diff, not the back-and-forth
- Code quality reviewer gets the diff + style guide, not the chat

Each subagent runs in fresh context, doing its narrow job efficiently. Your main context stays free for coordination.

## When context approaches 50%

When a session feels heavy, run `/haye:close` to checkpoint and then `/haye:start` in a fresh session. A helpful pattern when reaching context limits is:

> "Bağlam %50'ye yaklaşıyor. /haye:close ile checkpoint kaydedip yeni session açabiliriz."

`close` writes the current state to vault. The next session resumes with full context but light token usage.
