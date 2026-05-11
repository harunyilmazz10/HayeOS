# Obsidian Vault Standard

Core files: `HAYE.md`, `index.md`, `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, `<resolved memoryPath>/changelog.md`, `<resolved memoryPath>/health.md`.

## Plugin root vs project vault

Plugin root and project memory vault are different. `CLAUDE_PLUGIN_ROOT` or the HayeOS install path is only where plugin commands, skills and CLI files live. Project memory must always be stored under the current project's `.hayeos.json` `memoryPath`, resolved relative to that project root.

Never write project memory into the plugin repository. Context packs belong in `<resolved memoryPath>/09-context-packs/`; checkpoints belong in `<resolved memoryPath>/05-sessions/latest-checkpoint.md`; active task, `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md` and `<resolved memoryPath>/changelog.md` belong inside the resolved project vault.

Generated vaults must contain useful starter content, not empty placeholders:

New project init must create `.hayeos.json` with a relative vault path:

```json
{
  "project": "<project-name>",
  "memoryPath": "./<project-name>_obs",
  "sourcePath": ".",
  "defaultWorkflow": "memory-first",
  "sessionCloseRequired": true
}
```

Do not write Windows absolute paths or JSON backslash paths into `.hayeos.json`. Do not create a generic `memory` directory; use `<project-name>_obs`.

- `HAYE.md` records operating rules, simple commands, raw-read policy and dependency security policy.
- `index.md` links core files, active task, dependency checklist, risk log and safe-version decisions.
- `<resolved memoryPath>/current.md` records project state, configured source path and constraints.
- `<resolved memoryPath>/next.md` keeps the top actions short.
- `<resolved memoryPath>/health.md` tracks memory lint, dependency audit and React/Next audit status.
- `<resolved memoryPath>/04-tasks/active-task.md` gives the next session a place to record goal, scope and verification.
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

- `<resolved memoryPath>/05-sessions/latest-checkpoint.md`
- `<resolved memoryPath>/04-tasks/active-task.md`
- `<resolved memoryPath>/current.md`
- `<resolved memoryPath>/next.md`

`latest-checkpoint.md` preserves current task, phase, last successful step, changed files, commands run, verification status, blockers, risks and next 3 actions. `/haye:start` uses it for Safe Resume and must not continue implementation without user approval.
