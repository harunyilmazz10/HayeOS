---
name: ingest-session
description: Use when raw chat transcripts, terminal logs, or session dumps need to be summarized into structured vault entries
---

# Haye Skill: ingest-session

## Purpose
Turn unstructured raw inputs (Claude session JSONL, terminal logs, n8n execution dumps, screenshots' text) into structured entries in the right memory folders. Without this, `08-raw/` grows forever and the rest of the vault never benefits from it.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa özet Türkçe yazılır; komutlar/yollar orijinal kalır.

## Inputs to inspect first
1. The raw files under `<resolved memoryPath>/08-raw/` — list, sizes, dates.
2. `<resolved memoryPath>/current.md` to know what the work is about.
3. Existing entries in `<resolved memoryPath>/02-decisions/`, `03-bugs/`, `<resolved memoryPath>/04-tasks/`, `<resolved memoryPath>/12-risks/` — so we don't duplicate.
4. The raw file the user named, or the oldest unprocessed file if they didn't specify.

## Token discipline
- Do NOT read entire raw files. Read `head -200` and `tail -200` of each; extract structure, not transcript.
- Don't summarize verbatim; capture decisions, bugs, risks, and questions, not chatter.

## Workflow

### Step 1 — Triage the raw file
- What kind of file? Session transcript, terminal log, monitor output, screenshot text.
- What was the user trying to do?
- Did they succeed?

### Step 2 — Extract structured items
For each raw file, ask:
- **Decision**: was a choice made (use X library, not Y)? → `<resolved memoryPath>/02-decisions/<topic>.md`.
- **Bug seen**: did something fail? → `03-bugs/open/<short-name>.md` with symptom + repro.
- **Bug fixed**: did something get fixed? → `03-bugs/solved/<short-name>.md` with root cause.
- **Task started/completed**: → `<resolved memoryPath>/04-tasks/`.
- **Risk identified**: → `<resolved memoryPath>/12-risks/<topic>.md`.
- **Open question**: → `<resolved memoryPath>/next.md` as an action item.
- **Useful command/snippet**: → `07-checklists/<topic>.md` if it's reusable.

### Step 3 — Write structured entries
- One file per extracted item, named descriptively.
- Each entry: date, source (which raw file), one-paragraph summary, key links/commands, status.
- Cross-link back to the raw file (`source: 08-raw/<filename>`) so the chain is auditable.

### Step 4 — Update core memory
- `<resolved memoryPath>/current.md`: any new active context worth keeping near top.
- `<resolved memoryPath>/next.md`: actions newly discovered.
- `<resolved memoryPath>/changelog.md`: shipped items found in the log.

### Step 5 — Archive the raw file
- After ingestion: move from `08-raw/` to `08-raw/processed/<YYYY-MM>/<filename>` (NEVER delete).
- The `processed/` move signals "this has been mined".
- Files older than 6 months in `processed/` can be moved to `99-archive/raw/`.

### Step 6 — Output report
- What was processed.
- What new entries were created (paths).
- What was found that was already in memory (no duplicate).
- Token cost of the ingest operation (so the user can decide how often to run).

## Anti-patterns to refuse
- Copying full transcripts into memory — defeats the purpose.
- Re-summarizing things already in `<resolved memoryPath>/02-decisions/` (check first).
- "Memorable quotes" — not what this is for.
- Ingesting raw files in random order; oldest first or user-directed.
- Skipping the archive step (raw queue still grows).

## Output format
```markdown
## Ingested
- file: 08-raw/<name>
- size: <KB>
- date:

## Extracted
- decisions:
  - <resolved memoryPath>/02-decisions/<topic>.md (new)
- bugs:
  - 03-bugs/open/<name>.md (new)
  - 03-bugs/solved/<name>.md (new)
- tasks:
  - <resolved memoryPath>/04-tasks/<name>.md
- risks:
  - <resolved memoryPath>/12-risks/<topic>.md
- questions added to <resolved memoryPath>/next.md:

## Already in memory (not duplicated)
- ...

## Core memory updates
- <resolved memoryPath>/current.md: ...
- <resolved memoryPath>/next.md: ...
- <resolved memoryPath>/changelog.md: ...

## Raw file moved to
- 08-raw/processed/<YYYY-MM>/<filename>
```

## Safety rules
- Never delete raw files; archive only.
- Never write secrets found in raw files into structured memory — redact aggressively, note in `<resolved memoryPath>/12-risks/` that a secret leaked.
- Never assume the user wanted everything ingested; default to oldest 1–3 files per run.
- If a raw file references a major decision, prefer creating the `<resolved memoryPath>/02-decisions/` entry over only summarizing in `<resolved memoryPath>/current.md`.
- Long ingestion runs go incrementally; check token cost between files.
