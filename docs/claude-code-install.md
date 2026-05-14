# Claude Code Install

## A. Development / test (recommended for testing)

Use this when editing the local checkout:

```bash
claude --plugin-dir <hayeos-plugin-root>
```

For Windows users (PowerShell):

```powershell
claude --plugin-dir "C:\Users\<user>\Desktop\HayeOS-v3"
```

## B. Permanent local marketplace install

Use this when you want HayeOS commands available in normal `claude` sessions without `--plugin-dir`:

```text
claude
/plugin marketplace add <hayeos-plugin-root>
/plugin install haye@haye-marketplace
```

## Available commands after install

```text
/haye:start
/haye:init-memory
/haye:work
/haye:close
/haye:update
/haye:version
```

These six commands are the user-facing entry points. Process discipline (brainstorming, writing-plans, subagent-driven-development, systematic-debugging, etc.) lives in skills and is invoked automatically through the `/haye:work` chain.

## Removed in v3.0.0

These commands existed in v2.x and are intentionally removed:

- `/haye:fix` -> use `/haye:work` for bugs, it routes to `Skill(haye:systematic-debugging)`
- `/haye:secure` -> security concerns belong in CLAUDE.md or `haye-extras` plugin
- `/haye:ship` -> `/haye:work` chain ends in `Skill(haye:finishing-a-development-branch)`
- `/haye:bugfix`, `/haye:deploy` -> same as `/haye:fix` and `/haye:ship` removals

## Typical first session

```bash
mkdir my-project
cd my-project
claude --plugin-dir /path/to/HayeOS-v3
```

In Claude Code:

```text
/haye:start
```

If HayeOS memory is missing, `/haye:start` asks:

> Bu projede HayeOS hafızası bulunamadı. Şimdi otomatik oluşturayım mı?

Say "evet". HayeOS creates `.hayeos.json` plus the project memory vault automatically.

Then describe what you want to build:

```text
Next.js ile premium bir doktor landing page projesi oluşturmak istiyorum.
Hero, hizmetler, hakkında, randevu formu ve iletişim bölümleri olsun.
```

The work skill routes to brainstorming. Brainstorming HARD-GATE blocks any code or scaffolding until you approve the design. Then writing-plans produces a bite-sized plan, then subagent-driven-development executes task-by-task.

## Recovery after crash

If Claude Code crashes mid-session, open a new session and run `/haye:start`. HayeOS reads `<resolved memoryPath>/05-sessions/latest-checkpoint.md`, shows a short recovery summary in Turkish, and waits for your approval before continuing.

## Updating the plugin

```text
/haye:update
```

This safely runs `git pull --ff-only origin main` against the plugin repo. After update, run `/reload-plugins` or restart Claude Code so the new skill content takes effect.

Manual fallback:

```bash
cd <hayeos-plugin-root>
git pull origin main
```
