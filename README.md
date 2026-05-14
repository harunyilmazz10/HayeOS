# HayeOS

**Memory-first, discipline-first Claude Code workflow plugin.**

HayeOS v3.0.0 is a Turkish-friendly Claude Code plugin built on the Superpowers process model. It enforces a structured workflow:

```
brainstorming  ->  writing-plans  ->  subagent-driven-development (or executing-plans)
       |                                          |
       |                                          +-- test-driven-development per task
       |                                          +-- verification-before-completion gate
       v                                          v
  spec saved to                          plan saved to                    reviews saved to
  <memoryPath>/02-decisions/             <memoryPath>/04-plans/           <memoryPath>/10-reviews/
```

Every project gets a sibling memory vault (`<project>_obs/`) where specs, plans, decisions, sessions, and reviews are persisted across sessions.

---

## Why this exists

Earlier HayeOS versions (v1.x, v2.x) tried to enforce discipline by writing more and more rules into skills. Real-world testing showed Sonnet 4.6 hits a ceiling: it can quote the Iron Law verbatim, then immediately violate it.

v3.0.0 changes approach: **mechanical discipline through subagent dispatch**. Three separate subagents (implementer, spec reviewer, code quality reviewer) must agree before a task is marked complete. No single Sonnet can unilaterally claim "başarıyla tamamlandı".

The process model is from Jesse Vincent's Superpowers plugin. HayeOS wraps it with Turkish UX, project-local memory vaults, and session management.

---

## Skills

### Core process (from Superpowers, with HayeOS adaptation)

| Skill | When to use |
|---|---|
| `brainstorming` | ANY new feature, system, or non-trivial change. HARD-GATE blocks code until design is approved. |
| `writing-plans` | After brainstorming reaches an approved spec. Produces bite-sized plan. |
| `subagent-driven-development` | After plan exists. Dispatches implementer + 2 reviewer subagents per task. |
| `executing-plans` | Fallback when subagent dispatch isn't ideal. |
| `dispatching-parallel-agents` | 2+ independent failures or tasks that can be investigated concurrently. |
| `test-driven-development` | Every feature/bugfix, before writing implementation code. |
| `verification-before-completion` | Before ANY "done"/"completed"/"works"/"başarıyla" claim. |
| `systematic-debugging` | Bug reports, errors, unexpected behavior. |
| `requesting-code-review` | After each task in subagent flow, before merge, on feature completion. |
| `receiving-code-review` | When the user (or another reviewer) gives you feedback — verify technically, don't agree blindly. |
| `using-git-worktrees` | Starting feature work that needs workspace isolation. |
| `finishing-a-development-branch` | Implementation complete, decide merge/PR/cleanup. |
| `writing-skills` | Creating new HayeOS skills or editing existing ones (TDD for documentation). |

### HayeOS-specific (memory + session management)

| Skill | When to use |
|---|---|
| `using-hayeos` | Auto-injected at session start by SessionStart hook. |
| `start` | `/haye:start` slash command — session start, vault detect. |
| `init-memory` | First-time vault creation for a project. |
| `work` | `/haye:work` slash command — routes to brainstorming. |
| `checkpoint` | After 5+ file changes or before risky operations. |
| `close` | End of meaningful work block. |
| `update` | `/haye:update` slash command — pull plugin updates from GitHub. |

---

## Installation

### Quick start

```bash
git clone https://github.com/harunyilmazz10/HayeOS.git
cd HayeOS
```

In Claude Code:

```bash
claude --plugin-dir /path/to/HayeOS
```

Or via marketplace (Mac/Linux):

```bash
claude
# inside Claude Code:
/plugin marketplace add /path/to/HayeOS
/plugin install haye@haye-marketplace
```

### Windows specifics

If `bash hooks/session-start` fails with "execvpe(/bin/bash) failed", add Git Bash to PowerShell:

```powershell
Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "Set-Alias -Name bash -Value 'C:\Program Files\Git\bin\bash.exe' -Scope Global"
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

Then restart PowerShell.

---

## First session

```bash
mkdir my-new-project
cd my-new-project
claude --plugin-dir /path/to/HayeOS
```

In Claude Code:

```
/haye:start
```

Claude asks "HayeOS hafızası bulunamadı. Şimdi oluşturayım mı?" -> answer "evet".

This runs `Skill(haye:init-memory)`, which creates:
- `.hayeos.json` — project config
- `my-new-project_obs/` — memory vault with 16 top-level directories (some with subdirectories)

Now describe what you want to build:

```
Next.js ile premium bir doktor landing page projesi oluşturmak istiyorum. Production-grade, Hero, Services, About, Appointment, Contact.
```

Claude:
1. Invokes `Skill(haye:work)` — router skill.
2. Routes to `Skill(haye:brainstorming)`.
3. brainstorming asks clarifying questions ONE AT A TIME.
4. After spec approval, writes spec to `my-new-project_obs/02-decisions/2026-05-14-doctor-landing-spec.md`.
5. Routes to `Skill(haye:writing-plans)`.
6. Writes plan to `my-new-project_obs/04-plans/2026-05-14-doctor-landing-plan.md` — bite-sized tasks, exact file paths.
7. Routes to `Skill(haye:subagent-driven-development)`.
8. For each task: dispatch implementer -> spec reviewer -> code quality reviewer.
9. Only after all 3 approve does the task get marked complete.

You stay in control: the brainstorming step gates everything. No code gets written before you approve the design.

---

## Memory vault structure

```
<project>_obs/
HAYE.md              # vault index, last-touched files, vault health summary
current.md           # current focus (under 150 lines)
next.md              # next concrete actions
changelog.md         # session-by-session log
health.md            # vault health metadata
01-prompts/          # original user prompts, preserved verbatim
02-decisions/        # specs from brainstorming, architectural decisions
03-bugs/             # open/, solved/, recurring/ subdirectories
04-plans/            # implementation plans from writing-plans
04-tasks/            # active-task.md
05-sessions/         # session checkpoints
06-prompts/          # crafted reusable prompts
07-checklists/
08-raw/              # logs, screenshots, terminal output
09-context-packs/    # context bundles for handoff
10-reviews/          # review notes from subagent reviewers
11-metrics/
12-risks/
99-archive/
```

---

## Slash commands

| Command | What it does |
|---|---|
| `/haye:start` | Start session, detect or create vault, summarize prior state |
| `/haye:work` | Route a new request through brainstorming -> writing-plans -> execution |
| `/haye:close` | End meaningful work block, update changelog/current/next |
| `/haye:update` | Pull plugin updates from GitHub (`git pull` wrapper) |
| `/haye:version` | Show plugin version, commit hash, vault path |
| `/haye:init-memory` | Manually create memory vault (usually `/haye:start` does this) |

---

## Iron Law (non-negotiable)

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
NO IMPLEMENTATION CODE BEFORE BRAINSTORMING + APPROVED PLAN
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST (TDD)
NO PROJECT SOURCE CODE INSIDE THE MEMORY VAULT
NO "DEVAM EDELIM" LOOPS — EACH "DEVAM" = ONE MEANINGFUL STEP THEN STOP
```

---

## Hooks

Four hooks run during sessions:

- **SessionStart** — injects `using-hayeos` skill content into Claude's context. Required for the discipline rules to be visible. On Windows, Git Bash must be accessible (see Installation > Windows specifics).
- **PreToolUse Bash** — blocks destructive commands like `rm -rf /`, `drop database`, `git push --force` unless explicitly confirmed.
- **PreToolUse Read** — warns on large file reads.
- **Stop** — gentle reminder if a meaningful work block ended without `/haye:close`.

---

## Credits

- **Superpowers process model**: Jesse Vincent (Obra) and contributors. https://github.com/obra/superpowers
- **HayeOS**: Haye Labs. https://github.com/harunyilmazz10/HayeOS

Substantial portions of `brainstorming`, `writing-plans`, `executing-plans`, `subagent-driven-development`, `dispatching-parallel-agents`, `test-driven-development`, `verification-before-completion`, `systematic-debugging`, `requesting-code-review`, `receiving-code-review`, `using-git-worktrees`, `finishing-a-development-branch`, and `writing-skills` skill content originates from Superpowers, used with attribution and adapted under MIT.

---

## License

MIT
