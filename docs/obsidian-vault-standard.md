# Obsidian Vault Standard

HayeOS v3.0.0 vault layout. Created by `Skill(haye:init-memory)` or `bin/haye init`.

## Top-level core files

- `HAYE.md` — vault index, layout guide
- `index.md` — quick navigation
- `current.md` — current work focus (keep under 150 lines)
- `next.md` — next concrete actions
- `changelog.md` — session-by-session log
- `health.md` — vault health metadata

## Directories

```
00-system/           # system-level metadata
01-project/          # project meta (rare use)
01-prompts/          # original user prompts, preserved verbatim
02-decisions/        # specs from brainstorming, architectural decisions
03-bugs/             # open/, solved/, recurring/
04-plans/            # implementation plans from writing-plans skill
04-tasks/            # active-task.md
05-sessions/         # session checkpoints (latest-checkpoint.md)
06-prompts/          # crafted reusable prompts
07-checklists/       # security and dependency checklists
08-raw/              # claude-sessions, terminal-logs, screenshots, old-prompts, docs
09-context-packs/    # context bundles for handoff
10-reviews/          # outputs from subagent code reviewers
11-metrics/
12-risks/
99-archive/
```

## Plugin root vs project vault

Plugin root and project memory vault are different. `CLAUDE_PLUGIN_ROOT` or the HayeOS install path is only where plugin commands, skills and CLI files live. Project memory always lives under the current project's `.hayeos.json` `memoryPath`, resolved relative to that project root.

Never write project memory into the plugin repository. Plans belong in `<resolved memoryPath>/04-plans/`; specs belong in `<resolved memoryPath>/02-decisions/`; reviews belong in `<resolved memoryPath>/10-reviews/`; active task belongs in `<resolved memoryPath>/04-tasks/active-task.md`; checkpoints belong in `<resolved memoryPath>/05-sessions/latest-checkpoint.md`.

## .hayeos.json shape

Init must create `.hayeos.json` with relative paths:

```json
{
  "project": "<project-name>",
  "memoryPath": "./<project-name>_obs",
  "sourcePath": ".",
  "defaultWorkflow": "memory-first",
  "sessionCloseRequired": true,
  "riskLevel": "medium"
}
```

Do not write Windows absolute paths or JSON backslash paths into `.hayeos.json`. Do not create a generic `memory` directory; use `<project-name>_obs`.

## File contents

- `HAYE.md` — vault index plus links to active task, dependency checklist, risk log, and v3 process flow.
- `index.md` — quick links to top-level files and most-used directories.
- `current.md` — project state, configured source path, current focus, constraints.
- `next.md` — top concrete actions.
- `health.md` — vault structure version, last lint date, dependency audit freshness.
- `changelog.md` — append-only session log.
- `04-tasks/active-task.md` — current goal, scope, verification plan.
- `02-decisions/<YYYY-MM-DD>-<topic>-spec.md` — brainstorming output.
- `04-plans/<YYYY-MM-DD>-<feature>-plan.md` — writing-plans output, bite-sized tasks.
- `10-reviews/<task-id>/` — subagent code reviewer outputs.

## Original Prompt Preservation

Large or complex work requests must preserve the original user prompt verbatim under `<resolved memoryPath>/01-prompts/<YYYY-MM-DD-HHMM>-<topic>.md`. This is non-negotiable - lossy summarization before persistence is the root cause of context drift across sessions.

## 08-raw read policy

The `08-raw/` area is for explicit ingestion only. Normal start/work commands prefer summarized memory and context packs. Do not pull raw logs into chat without an explicit reason.
