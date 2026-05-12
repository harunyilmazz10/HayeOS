# Roadmap

## v1.1 - JSONL parsing + optional MCP integration

- Add structured session event ingestion for Claude Code transcripts and runtime logs.
- Improve `ingest-session` so it can extract decisions, blockers, commands, verification status, and risks from JSONL-style event streams.
- Expand monitor tooling so captured log windows can be summarized into the vault without loading raw logs into chat.
- Explore optional MCP bridge or connector patterns for local vault reads, metrics, and external tool metadata.
- Affected areas: `ingest-session` skill, `monitors/`, `<resolved memoryPath>/11-metrics/`, telemetry/reporting flow.

## v1.2 - Obsidian link graph linting

- Extend `memory-lint` with Obsidian link graph checks.
- Detect dead backlinks, orphan decisions, orphan risks, and session summaries with no current/next linkage.
- Add vault consistency checks for stale context packs, oversized current/next files, and missing decision references.
- Produce compact repair suggestions rather than auto-rewriting memory files.

## v1.3 - Project dashboards + metrics export

- Use `<resolved memoryPath>/11-metrics/` as the stable home for project progress/status metrics.
- Generate lightweight dashboards for active task, risk count, verification freshness, and dependency/security status.
- Add optional exports for manager AI/operator visibility, such as JSON summaries or Markdown dashboards.
- Keep dashboard generation read-mostly and path-safe; no external upload by default.

## Maintenance backlog

- Refresh embedded dependency/security baselines at least every 90 days.
- Add more monitor recipes only when they reduce raw-log token waste.
- Consider richer visual dashboards later, after metrics schemas stabilize.
- Keep plugin metadata, README command truth, and verify coverage aligned with each release.
