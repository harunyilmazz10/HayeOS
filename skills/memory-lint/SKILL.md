---
name: memory-lint
description: Audit the Obsidian memory vault for stale, bloated, contradictory, missing or orphaned files. Read-only; proposes cleanup actions.
---

# Haye Skill: memory-lint

## Purpose
Keep the Obsidian vault healthy without auto-deleting anything. Surfaces lint issues; user approves the cleanup. Complements the `bin/haye lint` CLI by adding cross-file and link-graph checks.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa rapor Türkçe verilir.

## Inputs to inspect first
1. `.hayeos.json` and resolved `memoryPath`.
2. All core files: `HAYE.md`, `index.md`, `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, `<resolved memoryPath>/changelog.md`, `<resolved memoryPath>/health.md`.
3. Directory listing only (sizes, last-modified) for: `01-prompts/`, `<resolved memoryPath>/02-decisions/`, `03-bugs/`, `<resolved memoryPath>/04-tasks/`, `<resolved memoryPath>/05-sessions/`, `06-prompts/`, `07-checklists/`, `08-raw/`, `<resolved memoryPath>/09-context-packs/`, `10-reviews/`, `11-metrics/`, `<resolved memoryPath>/12-risks/`, `99-archive/`.
4. Optionally `bin/haye lint` output (the CLI's structural check).

## Token discipline
- Read directory metadata, not file bodies. Open a file's content only when its size or recency suggests a real problem.

## Checks

### Core file size (HayeOS lint baseline)
- `<resolved memoryPath>/current.md` > 180 lines → recommend moving older context into `<resolved memoryPath>/04-tasks/`, `<resolved memoryPath>/02-decisions/`, or `99-archive/`
- `<resolved memoryPath>/next.md` > 50 actions → propose pruning to 5–10 top actions
- `HAYE.md` > 300 lines → propose splitting platform rules into `01-project/<topic>.md`

### Contradictions
- `<resolved memoryPath>/current.md` says active task is X, but `<resolved memoryPath>/04-tasks/active-task.md` says Y → which one is correct? Reconcile.
- `<resolved memoryPath>/next.md` lists work that `<resolved memoryPath>/changelog.md` already shows as done → prune
- Two `<resolved memoryPath>/02-decisions/*.md` with conflicting dependency versions → keep the newer one, archive the other with cross-reference

### Stale entries
- `<resolved memoryPath>/04-tasks/active-task.md` last modified > 14 days ago → likely no longer active
- `03-bugs/open/*.md` last modified > 30 days ago → was it resolved without being moved to `solved/`?
- `<resolved memoryPath>/09-context-packs/*.md` older than 30 days without inbound link from `<resolved memoryPath>/current.md` → archive

### Raw queue
- `08-raw/claude-sessions/` count > 5 → propose `ingest-session` run
- `08-raw/terminal-logs/` count > 10 → trim oldest, ingest the ones referenced by open bugs
- Any single file in `08-raw/` over 500 KB → must be summarized, not loaded

### Link graph (Obsidian wikilinks)
- `[[name]]` in `index.md` pointing to a file that doesn't exist → broken link
- Files referenced from `<resolved memoryPath>/current.md` that don't exist → broken link
- Files in vault not linked from `index.md` (orphans) → either link or archive

### Naming conventions
- Files under `<resolved memoryPath>/04-tasks/` not following `active-task.md` or `<task-name>.md` pattern
- `<resolved memoryPath>/09-context-packs/` files without a sortable date prefix or scope
- Folders with mixed-case names where lowercase is the convention

### Archive hygiene
- `99-archive/` items that were never timestamped → add date suffix when archiving
- Files moved to archive but still linked from active files → break the link or restore

### Health file
- `<resolved memoryPath>/health.md` reports "pending" on a check that has not been re-run in > 7 days → either re-run via `/haye:secure` etc., or update the status note

## Output format
```markdown
## Lint summary
- core file budget: ok / over budget
- raw queue: <N> files pending ingest
- contradictions: <N>
- stale entries: <N>
- broken links: <N>
- orphans: <N>

## High-priority cleanups (max 5)
1. file → suggested action
2. ...

## Proposed memory updates (to be applied via /haye:close)
- <resolved memoryPath>/current.md changes:
- <resolved memoryPath>/next.md changes:
- files to archive:

## Verification
- run `bin/haye lint` → expected OK
- re-open Obsidian and confirm no broken-link warnings
```

## Safety rules
- Never delete files; archive to `99-archive/` only. Deletion is the user's call.
- Never auto-rewrite `<resolved memoryPath>/current.md` or `<resolved memoryPath>/next.md`. Propose the diff; let `/haye:close` apply it.
- Never collapse two decisions into one without keeping a redirect note.
- Lint runs in `<resolved memoryPath>`, never inside `CLAUDE_PLUGIN_ROOT`.
