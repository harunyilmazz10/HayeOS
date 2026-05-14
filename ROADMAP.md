# Roadmap

## v3.1 - haye-extras plugin extraction

Move the 25 domain skills from v2.x (nextjs-doctor, prisma-doctor, coolify-doctor, cloudflare-doctor, etc.) into a separate `haye-extras` plugin. Users who need them install both; users who only want the core process model install just HayeOS core.

## v3.2 - JSONL parsing for session ingestion

- Add structured session event ingestion for Claude Code transcripts and runtime logs.
- Add an `ingest-session` companion skill so it can extract decisions, blockers, commands, verification status, and risks from JSONL event streams.
- Expand monitor tooling so captured log windows can be summarized into the vault without loading raw logs into chat.

## v3.3 - Obsidian link graph linting

- Extend a `memory-lint` companion skill with Obsidian link graph checks.
- Detect dead backlinks, orphan decisions, orphan risks, and session summaries with no current/next linkage.
- Produce compact repair suggestions rather than auto-rewriting memory files.

## v3.4 - Project dashboards + metrics export

- Use `<resolved memoryPath>/11-metrics/` as the stable home for project progress/status metrics.
- Generate lightweight dashboards for active task, risk count, verification freshness.
- Add optional exports for manager AI/operator visibility (JSON summaries or Markdown dashboards).
- Keep dashboard generation read-mostly and path-safe; no external upload by default.

## Maintenance backlog

- Track upstream Superpowers changes; sync skill improvements quarterly.
- Add more monitor recipes only when they reduce raw-log token waste.
- Keep plugin metadata, README command truth, and verify coverage aligned with each release.
- Document migration paths from v2.x and v1.x for any new user landing on the repo.
