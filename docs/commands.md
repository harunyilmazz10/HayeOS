# Commands

HayeOS v3.0.0 has six slash commands. They are user-facing entry points; process discipline lives in skills.

```
/haye:start
/haye:work
/haye:close
/haye:update
/haye:version
/haye:init-memory
```

## Command to skill routing

| Command | Primary skill | Chains to |
|---|---|---|
| `/haye:start` | `haye:start` | `haye:init-memory` if vault is missing and user approves |
| `/haye:work` | `haye:work` (router) | `haye:brainstorming` for new work; `haye:systematic-debugging` for bugs; `haye:finishing-a-development-branch` on completion |
| `/haye:close` | `haye:close` | none (terminal step) |
| `/haye:update` | `haye:update` | runs `git pull` for plugin repo |
| `/haye:version` | none (CLI direct) | runs `bin/haye version` |
| `/haye:init-memory` | `haye:init-memory` | manual fallback when `/haye:start` chain doesn't fit |

## Removed in v3.0.0

These commands existed in v2.x and earlier and are intentionally removed:

| Removed | Reason |
|---|---|
| `/haye:fix` | Now: `/haye:work` routes to `Skill(haye:systematic-debugging)` for bugs |
| `/haye:secure` | Generic security guidance belongs in CLAUDE.md or `haye-extras` plugin |
| `/haye:ship` | Now: `/haye:work` chain ends in `Skill(haye:finishing-a-development-branch)` |
| `/haye:bugfix` | Same as `/haye:fix` removal |
| `/haye:deploy` | Same as `/haye:ship` removal |

The Superpowers process model means there is one entry point (`/haye:work`) and the chain picks the right discipline skill automatically.

## /haye:version

`/haye:version` runs `bin/haye version` and shows:

```
HayeOS version: 3.0.0
Git commit: <hash>
Branch: main
Working tree: clean | modified
Repository path: <plugin root>
```

## /haye:update

Safe `git pull` from GitHub for the plugin repository. It checks:

1. Plugin root has `.git` directory
2. Working tree is clean (no local changes)
3. Origin URL matches expected GitHub URL
4. Branch is `main`

If all clear, runs `git fetch origin && git pull --ff-only origin main`. Otherwise reports the issue in Turkish and asks how to proceed.

After update, recommends `/reload-plugins` (or restart Claude Code) so the new skill content takes effect.

## /haye:start

Lightweight session start:

1. Detect `.hayeos.json` in cwd
2. If present: read `memoryPath` from it; read `HAYE.md`, `current.md`, `next.md`, `04-tasks/active-task.md`, latest session checkpoint
3. If absent: ask "HayeOS hafızası bulunamadı. Şimdi oluşturayım mı?" and route to `Skill(haye:init-memory)` on "evet"

Reports a one-line summary in Turkish.

## /haye:work

Router skill. Reads user's request shape and routes:

| User's request shape | Routes to |
|---|---|
| New feature/system/non-trivial change | `Skill(haye:brainstorming)` |
| Approved spec, asking for plan | `Skill(haye:writing-plans)` |
| Ready plan, asking for execution | `Skill(haye:subagent-driven-development)` (preferred) or `Skill(haye:executing-plans)` |
| Bug report / error / "X doesn't work" | `Skill(haye:systematic-debugging)` |
| Implementation done, asking about merge | `Skill(haye:finishing-a-development-branch)` |

`work` does not produce a task classification block or pick a mode. v2.x's "Full Architecture Mode / Team Mode / Plan First / Standard / Fast" choice is removed because the Superpowers chain handles complexity automatically through brainstorming.

## /haye:close

End of meaningful work block. Updates:
- `<memoryPath>/changelog.md` — what changed this session
- `<memoryPath>/current.md` — new focus or "Empty"
- `<memoryPath>/next.md` — next concrete actions
- `<memoryPath>/05-sessions/latest-checkpoint.md` — full state snapshot

## /haye:init-memory

Manual vault creation. Normally not invoked directly - `/haye:start` chains to it when the user confirms. Available for cases where the `start` flow doesn't fit (e.g., re-initializing a vault).

Creates:
- `.hayeos.json` (project config: project, sourcePath, memoryPath, riskLevel)
- `<project>_obs/` (16 top-level directories including `04-plans/`, `04-tasks/`, `10-reviews/`)
- `HAYE.md`, `current.md`, `next.md`, `changelog.md`, `health.md`, `index.md`
