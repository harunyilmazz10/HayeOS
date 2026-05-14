# HayeOS Architecture

HayeOS v3.0.0 is built on the Superpowers process model with HayeOS-specific extensions for memory vault management, Turkish UX, and session lifecycle.

## High-level shape

```
+--- Plugin (~/.claude/plugins/haye or --plugin-dir) -----------+
|                                                               |
|  .claude-plugin/         skills/         commands/            |
|    plugin.json (v3.0.0)    20 skill dirs   6 slash commands   |
|                                                               |
|  bin/                    hooks/          scripts/             |
|    haye (Python CLI)       SessionStart     verify.sh         |
|    haye.cmd (Windows)      PreToolUse                         |
|    haye-find-vault         Stop                               |
|                                                               |
|  tests/                  docs/           examples/            |
+---------------------------------------------------------------+

+--- Per-project (cwd) ----------------------------------------+
|                                                              |
|  .hayeos.json           <project>_obs/  (memory vault)       |
|    project, sourcePath,   HAYE.md, current, next, changelog  |
|    memoryPath, riskLevel  04-plans/, 02-decisions/,          |
|                            04-tasks/, 10-reviews/, ...       |
|                                                              |
+--------------------------------------------------------------+
```

## Skill ecosystem

20 skills total, two categories:

### Superpowers-derived (13 skills, with HayeOS Layer)

Process discipline skills adapted from Obra's Superpowers (https://github.com/obra/superpowers):

| Skill | Purpose |
|---|---|
| `brainstorming` | Idea -> design spec, HARD-GATE before any code |
| `writing-plans` | Spec -> bite-sized implementation plan |
| `executing-plans` | Manual plan execution (when subagent dispatch isn't ideal) |
| `subagent-driven-development` | Task-by-task: implementer + spec reviewer + code quality reviewer subagents |
| `dispatching-parallel-agents` | 2+ independent failures investigated concurrently |
| `test-driven-development` | RED-GREEN-REFACTOR, no production code without failing test |
| `verification-before-completion` | Gate function before any completion claim |
| `systematic-debugging` | Strict procedure for bugs, errors, unexpected behavior |
| `requesting-code-review` | Dispatch code reviewer subagent |
| `receiving-code-review` | Handle review feedback (verify technically, not performatively) |
| `using-git-worktrees` | Isolated workspace via native or git fallback |
| `finishing-a-development-branch` | Merge/PR/cleanup decision flow |
| `writing-skills` | TDD applied to skill documentation |

Each ends with a "HayeOS Layer" section adding:
- Turkish UX rule
- Memory vault paths (`<memoryPath>/04-plans/`, `<memoryPath>/02-decisions/`, `<memoryPath>/10-reviews/`)
- Path Separation enforcement

### HayeOS-specific (7 skills)

Skills that handle memory vault and session lifecycle - no Superpowers equivalent:

| Skill | Purpose |
|---|---|
| `using-hayeos` | Master orchestrator, injected at SessionStart |
| `start` | Session start, vault detect, Turkish welcome |
| `init-memory` | First-time vault creation |
| `work` | Router: brainstorming -> writing-plans -> subagent-driven-development |
| `checkpoint` | Write current state to vault (5+ files, risky op, phase boundary) |
| `close` | End meaningful work block, update changelog/current/next |
| `update` | `git pull` wrapper for plugin updates |

## Slash commands

Six commands map to the seven HayeOS-specific skills:

| Command | Skill invoked |
|---|---|
| `/haye:start` | `Skill(haye:start)` -> may chain to `Skill(haye:init-memory)` |
| `/haye:work` | `Skill(haye:work)` -> chains to `Skill(haye:brainstorming)` |
| `/haye:close` | `Skill(haye:close)` |
| `/haye:update` | `Skill(haye:update)` -> runs `git pull` |
| `/haye:version` | runs `bin/haye version` |
| `/haye:init-memory` | `Skill(haye:init-memory)` (manual fallback) |

There is intentionally no `/haye:fix`, `/haye:secure`, `/haye:ship` etc. in v3 - those map to process skills (`systematic-debugging`, `finishing-a-development-branch`) that are auto-invoked.

## Hooks

| Hook | Type | What it does |
|---|---|---|
| `SessionStart` | injects context | Reads `using-hayeos` SKILL.md, emits as `additionalContext` JSON for Claude to load |
| `PreToolUse:Bash` | safety guard | Blocks `rm -rf /`, `drop database`, `git push --force` etc. unless confirmed |
| `PreToolUse:Read` | safety guard | Warns on very large file reads |
| `Stop` | gentle reminder | Suggests `/haye:close` if meaningful work block ended without one |

Hook files (v3.0.0 Superpowers polyglot pattern):
- `hooks/run-hook.cmd` — cross-platform polyglot wrapper (cmd.exe on Windows, bash on Unix)
- `hooks/session-start` — extensionless bash script (avoids Claude Code's Windows .sh auto-detection)
- `hooks/session-start.py` — Python implementation (used when python is available; called from session-start)
- `hooks/dangerous-command-guard` — extensionless bash script
- `hooks/large-file-warning` — extensionless bash script
- `hooks/session-close-reminder` — extensionless bash script
- `hooks/hooks.json` — Claude Code hook configuration; all entries route through run-hook.cmd

## Memory vault

Every project gets a sibling vault at `<project>_obs/`. Created by `bin/haye init` or `Skill(haye:init-memory)`.

16 top-level directories (some with subdirectories), organized for discoverability:

```
00-system/           # system-level metadata
01-project/          # project meta (rare use)
01-prompts/          # original user prompts, preserved verbatim
02-decisions/        # specs from brainstorming, architectural decisions
03-bugs/             # open/, solved/, recurring/
04-plans/            # implementation plans from writing-plans
04-tasks/            # active-task.md
05-sessions/         # session checkpoints
06-prompts/          # crafted reusable prompts
07-checklists/
08-raw/              # claude-sessions, terminal-logs, screenshots, old-prompts, docs
09-context-packs/    # context bundles for handoff
10-reviews/          # outputs from reviewer subagents
11-metrics/
12-risks/
99-archive/
```

Top-level files:
- `HAYE.md` — vault index
- `current.md` — current focus (under 150 lines)
- `next.md` — next concrete actions
- `changelog.md` — session-by-session log
- `health.md` — vault health metadata
- `index.md` — quick navigation index

## CLI (`bin/haye`)

Python script with subcommands:

| Command | Purpose |
|---|---|
| `bin/haye init` | Create `.hayeos.json` and vault directories |
| `bin/haye version` | Show plugin version, commit, branch |
| `bin/haye init-config` | Create only `.hayeos.json` (no vault directories) |
| `bin/haye find-vault` | Resolve memoryPath from current cwd |
| `bin/haye print-config` | Print effective `.hayeos.json` to stdout |
| `bin/haye lint` | Vault hygiene checks |
| `bin/haye health` | Run lint + summarize vault state |
| `bin/haye raw-status` | List files under `08-raw/` for triage |
| `bin/haye context-pack [task]` | Create a context-pack template under `09-context-packs/` |

Windows wrappers:
- `bin/haye.cmd` — calls `py -3 bin/haye` or `python bin/haye`
- `bin/haye.ps1` — PowerShell wrapper

## Why the Superpowers chain

HayeOS v1.x and v2.x tried to enforce discipline through written rules: longer Iron Law, more Red Flags tables, sharper "Mandatory Triggers". Testing showed Sonnet 4.6 hits a ceiling: it can quote the Iron Law verbatim, then immediately violate it.

v3.0.0 changes approach: mechanical discipline through subagent dispatch. The Superpowers `subagent-driven-development` skill requires three separate subagents (implementer + spec reviewer + code quality reviewer) to agree before any task is marked complete. The orchestrator cannot unilaterally declare success.

This is the load-bearing insight of the v3 architecture. Everything else (brainstorming HARD-GATE, writing-plans bite-sized tasks, verification-before-completion gate) supports or feeds into this mechanical-agreement pattern.

## Credits

Process skills adapted from Jesse Vincent's Superpowers (https://github.com/obra/superpowers). HayeOS wraps that model with memory vault, Turkish UX, and session lifecycle. Substantial portions used under MIT with attribution in CHANGELOG.md and README.md.
