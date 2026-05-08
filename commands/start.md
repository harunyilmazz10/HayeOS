---
description: Start from Haye Obsidian memory with minimal context.
---

# /haye:start

Use `skills/start/SKILL.md`.

Route to advanced workflows when needed:
- `memory-start` for minimal memory loading.
- `project-map` when the project shape is unknown.
- `token-audit` when context is already large.

Do not read the full repository or `08-raw/` by default. Inspect `.hayeos.json`, locate `memoryPath`, read only core memory files, then produce the next safe step and verification plan.

If `.hayeos.json` is missing and no `*_obs` vault exists, do not pretend memory is ready. Tell the user to run `bin/haye init` or invoke `/haye:init-memory`, then continue only after the config/vault exists.
