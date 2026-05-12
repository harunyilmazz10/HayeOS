---
name: migration
description: Plan and execute schema, data and infra migrations safely - dry-run, backup, reversible steps, rollback path.
---

# Haye Skill: migration

## Purpose
Move data, schema, or infrastructure from state A to state B without losing data and with a rollback path. Covers Prisma migrations, raw SQL, file moves, and infra cutovers.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa açıklamalar Türkçe verilir.

## Inputs to inspect first
1. What is being migrated: schema (DDL), data (DML), infra (compose/coolify), or filesystem layout?
2. Current state: schema dump, row counts, file inventory.
3. Target state: desired schema, desired layout.
4. Environment: dev only? staging? production? Production is treated as one-shot.
5. Backup status: when was the last verified backup?

## Token discipline
- Don't read every migration in history; read the most recent + the failing one.
- Don't dump full table contents; row counts and a few sample rows are enough to reason about.

## Workflow

### Step 1 — Inventory and backup
- Capture current state: `pg_dump`, file tree, environment dump.
- Verify the backup is restorable (size > 0, format correct, test restore in a scratch DB if possible).
- Without a verified backup, do not proceed.

### Step 2 — Classify the migration
- **Additive only**: new columns/tables/files, no removal. Safest.
- **Mixed**: add new, then deprecate old after a release cycle. Two-phase.
- **Destructive**: drop/rename/delete. Requires explicit user approval and a tested rollback.

### Step 3 — Plan in reversible steps
- For DB:
  1. Add new column NULL-able
  2. Backfill in batches (LIMIT 1000, sleep between)
  3. Add NOT NULL / constraint
  4. Switch app reads to new column (deploy)
  5. Switch writes to new column only (deploy)
  6. Drop old column (separate migration, after stability)
- For file moves: copy → verify → switch readers → switch writers → delete old (after grace period).
- For infra: stand up new alongside old → drain traffic → cut over → keep old for N days.

### Step 4 — Dry-run
- `prisma migrate diff --from-schema-datasource ... --to-schema-datamodel ... --script` produces the SQL without applying.
- For data migrations: run against a copy of production with the migration script, measure runtime and lock time.
- For infra: do the same change in staging, confirm app behavior unchanged.

### Step 5 — Execute with monitoring
- DDL on large tables can lock; pick a window or use online schema change techniques (Postgres concurrent index, MySQL `pt-online-schema-change`).
- Watch DB connections, error rate, and a hand-picked smoke endpoint during the run.
- Have the rollback command ready in another terminal before pressing enter.

### Step 6 — Verify
- Schema matches target.
- Row counts match expectation (before count + transferred = after count, or document the difference).
- App health checks green.
- A handful of representative reads return expected values.

### Step 7 — Memory and changelog
- `<resolved memoryPath>/02-decisions/migration-<scope>-<date>.md`: what migrated, when, how reversed if needed.
- `<resolved memoryPath>/changelog.md` entry with version and date.
- `<resolved memoryPath>/12-risks/` updated if a known risk remains (data inconsistency, partial migration).

## Anti-patterns to refuse
- "Just run `prisma migrate reset`" against any environment that has real data
- Running a destructive migration without a fresh backup
- Combining schema and data migration in a single transaction on a large table
- Pretending a rename is one operation in Prisma (it's drop+add and data goes away)
- Cutting over with no rollback because "we'll just fix forward"
- Letting a migration touch tables outside its declared scope

## Output format
```markdown
## Migration plan
- type: additive / mixed / destructive
- scope:
- pre-state:
- post-state:

## Backup verification
- source:
- timestamp:
- restorable: tested / assumed

## Steps (in order, each reversible)
1.
2.
3.

## Rollback path
- per step:

## Verification queries / checks
- count check:
- shape check:
- smoke endpoint:

## Memory updates
- <resolved memoryPath>/02-decisions/...
- <resolved memoryPath>/changelog.md entry
```

## Safety rules
- Destructive migration is HARD risk gate; require explicit user approval per run.
- Never run `prisma migrate reset`, `DROP TABLE`, `TRUNCATE`, `DROP DATABASE` without approval and backup.
- Never combine "add" and "drop" in the same migration on a production table.
- A migration without a tested rollback is not ready for production.
- Long migration designs go to `docs/migrations/<scope>.md`; chat gets the summary.
