---
name: database-doctor
description: Diagnose PostgreSQL connectivity, schema, performance, locks, backups and exposure risks. Complements prisma-doctor.
---

# Haye Skill: database-doctor

## Purpose
Diagnose PostgreSQL itself, separately from Prisma. Useful when the issue is the DB host, connection layer, query plan, or operational concern (backups, exposure).

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar Türkçe verilecek; kod, komutlar, dosya yolları orijinal kalır.

## Inputs to inspect first
1. The exact error or symptom (timeout, slow query, "connection refused", "too many connections").
2. Where Postgres runs: Coolify-managed service, Docker Compose, separate VPS, managed (Neon/Supabase).
3. `docker-compose.yml` / Coolify config for the DB service — port exposure, volume, version.
4. The slow query if performance is the symptom (with the table involved).
5. `pg_settings` for `max_connections`, `shared_buffers`, `work_mem` (ask user to run if not on shared infra).

## Token discipline
- Do not request `EXPLAIN ANALYZE` output for every query. One representative slow query.
- Do not request a full `pg_dump`. Schema only.

## Symptoms → first place to look

### Connectivity
- "Connection refused" → Postgres is not listening on the expected interface. `listen_addresses = '*'` in `postgresql.conf` (or `localhost` only by default). Container's `5432` bound only to the Docker network.
- "FATAL: password authentication failed" → wrong password, or `pg_hba.conf` requires `md5` while client sent `scram-sha-256` (mismatch on newer Postgres + older client).
- "FATAL: no pg_hba.conf entry for host" → the connecting IP isn't authorized in `pg_hba.conf`. For Docker-network apps, host is the container's network IP.
- "too many connections" → `max_connections` hit. Either reduce app pool size, add pgbouncer, or use Prisma's `connection_limit` parameter.

### Performance
- Slow specific query → `EXPLAIN (ANALYZE, BUFFERS)` for that one query. Look for `Seq Scan` on large tables, missing index hint.
- Whole DB slow → `pg_stat_activity` for long-running queries; `pg_stat_statements` for hot queries (extension must be enabled).
- Sudden slowness after a deploy → check recent migrations; an index might have been dropped, or a query changed its shape.
- High write latency → autovacuum might be off, or `synchronous_commit = on` with slow disk. Coolify default volumes are usually fine but Hetzner shared storage can be slow.

### Locks / blocking
- App hangs intermittently → `pg_stat_activity` with `wait_event_type = 'Lock'` shows the chain.
- Migration locks production → DDL is taking `AccessExclusiveLock`. Refactor to add column first (default NULL, no rewrite), then add NOT NULL constraint as a separate step.

### Schema
- Foreign keys without indexes → FK constraints don't auto-index on the referencing column. Query plans on DELETE / UPDATE of parents will seq-scan child tables.
- Boolean columns with no index → fine until they are used in WHERE on a huge table; consider partial index for the minority value.
- Soft-delete (`deletedAt IS NULL`) without a partial index → every read pays a filter cost.
- JSONB used as a generic bucket → if a property is always read, promote it to a column with a check; index JSONB with GIN only on properties you actually query.

### Backups / recovery
- "We have backups" but no restore test → schedule a quarterly restore drill. Document the restore command. Untested backup is no backup.
- Backup is `pg_dump` of a live DB without `--single-transaction` or `pg_dumpall` → may be inconsistent. Prefer `pg_basebackup` or a managed PITR service.
- No WAL archiving → recovery point objective (RPO) is "last full backup". For anything real, set up streaming replication or use a managed provider.

### Exposure
- `5432:5432` in `docker-compose.yml` → Postgres reachable from public internet. **Stop and raise as a security risk.** Bind only to the Docker network, or to `127.0.0.1` if a tunnel is used.
- Postgres on a public Hetzner IP with `pg_hba.conf` allowing `0.0.0.0/0` → same risk.
- Default `postgres` role with weak password → audit `pg_authid`, rotate.
- `pg_dump` running over plain TCP from outside the host → use SSH tunnel or `sslmode=require` minimum.

### Version
- Postgres 14 in production but local is 16 → behavior differences in `IDENTITY`, JSON path operators. Align dev and prod versions.
- Postgres 17 minor version drift → minor versions are wire-compatible; bump dev and prod together.

## Verification commands
- `pg_isready -h <host> -p 5432 -U <user>` — connectivity smoke test.
- `psql "$DATABASE_URL" -c 'SELECT version();'` — server version.
- `psql -c 'SELECT count(*) FROM pg_stat_activity;'` — current connections.
- `psql -c 'SELECT pid, query, state, wait_event_type FROM pg_stat_activity WHERE state = ''active'';'` — what's running.
- `psql -c '\dt+' <schema>` — table sizes.
- `EXPLAIN (ANALYZE, BUFFERS) <query>` — plan + actual time.

## Output format
- What I found (top 3 candidates with confidence)
- File / config / setting / query to change
- Smallest fix
- Verification command
- Memory update needed (especially for any exposure finding → `<resolved memoryPath>/12-risks/`)

## Safety rules
- `DROP TABLE`, `DROP DATABASE`, `TRUNCATE` are HARD risk gates. Never execute without explicit approval and a fresh backup.
- `pg_ctl restart` on a production DB is a risk gate.
- `ALTER TABLE ... ALTER COLUMN TYPE` rewrites the table; on big tables, plan downtime or use the "add new column → backfill → swap → drop old" pattern.
- Do not propose `pg_hba.conf trust` for anything reachable beyond localhost.
- If DB is exposed to the public internet, raise it as a CRITICAL risk and write to `<resolved memoryPath>/12-risks/exposed-database.md` immediately.
