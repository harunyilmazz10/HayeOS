# Obsidian Vault Standard

Core files: `HAYE.md`, `index.md`, `current.md`, `next.md`, `changelog.md`, `health.md`.

Generated vaults must contain useful starter content, not empty placeholders:

- `HAYE.md` records operating rules, simple commands, raw-read policy and dependency security policy.
- `index.md` links core files, active task, dependency checklist, risk log and safe-version decisions.
- `current.md` records project state, configured source path and constraints.
- `next.md` keeps the top actions short.
- `health.md` tracks memory lint, dependency audit and React/Next audit status.
- `04-tasks/active-task.md` gives the next session a place to record goal, scope and verification.
- `07-checklists/dependency-security-checklist.md`, `12-risks/dependency-risks.md` and `02-decisions/safe-dependency-versions.md` support safe dependency decisions.

The `08-raw/` area is for explicit ingestion only. Normal start/work commands should prefer summarized memory and context packs.

## Work discipline

`HAYE.md` should include:

- User Response Language Rule for Turkish-first responses.
- Smart Work Router summary for `/haye:work`.
- Approval Friction Rule.
- No Fake Completion Rule.
- Output Budget Rule.
- Auto Checkpoint Rule.
- Safe Resume Rule.
- Scope Control Rule.
- Token discipline for Team Mode and large tasks.

## Checkpoint files

Long or risky sessions should maintain:

- `05-sessions/latest-checkpoint.md`
- `04-tasks/active-task.md`
- `current.md`
- `next.md`

`latest-checkpoint.md` preserves current task, phase, last successful step, changed files, commands run, verification status, blockers, risks and next 3 actions. `/haye:start` uses it for Safe Resume and must not continue implementation without user approval.
