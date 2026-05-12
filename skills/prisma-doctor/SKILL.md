---
name: prisma-doctor
description: Use when diagnosing Prisma client errors, migration failures, OpenSSL/libssl mismatches, connection pool exhaustion, schema drift, or generator problems
---

# Haye Skill: prisma-doctor

## Purpose
Diagnose Prisma + Postgres issues without scanning the whole repo or running destructive migrations.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar Türkçe verilecek; kod, komutlar, dosya yolları orijinal kalır.

## Inputs to inspect first
1. `.hayeos.json` and resolved `memoryPath`.
2. `prisma/schema.prisma` (datasource provider, generator output, engineType).
3. `package.json` — `prisma` and `@prisma/client` versions (must match).
4. `prisma/migrations/` directory listing (timestamps + names only; do not read SQL of all of them).
5. The error message verbatim.
6. `<resolved memoryPath>/02-decisions/safe-dependency-versions.md` and `<resolved memoryPath>/12-risks/`.

## Token discipline
- Do not read every migration file. Read only the most recent + the one named in the error.
- Do not paste full table contents. Schema-level reasoning first.

## Symptoms → first place to look

### Client generation / install
- `@prisma/client did not initialize yet` → `prisma generate` did not run, or build doesn't include it. Add `prisma generate` to `postinstall` or build step.
- `prisma` and `@prisma/client` version mismatch → both must be the same minor; bump both.
- `Error loading libssl` / `libssl.so.1.1: cannot open` → Alpine / Debian image OpenSSL mismatch. Use a base image with OpenSSL 3, or pin Prisma `binaryTargets` to match (`debian-openssl-3.0.x`, `linux-musl-openssl-3.0.x`).
- Docker build OK on Mac, fails on Linux → `binaryTargets` not including `["native", "linux-musl-openssl-3.0.x"]` (or matching Debian target).

### Connection
- `P1001: Can't reach database server` → DATABASE_URL host/port wrong, firewall, Postgres not running, or in Coolify the service name not yet resolvable. From an app container, try `pg_isready -h <host> -p <port>`.
- `P1010: User was denied access` → role does not have CONNECT on the DB or schema USAGE missing.
- `P1017: Server has closed the connection` → typically pgbouncer in transaction mode + Prisma prepared statements. Use `pgbouncer=true` in connection string or `?statement_cache_size=0`.
- Serverless / edge: connection storms — must use Prisma Data Proxy, Accelerate, or a pooler (pgbouncer / Supavisor).

### Migrations
- `P3009: Migration failed to apply` → check `_prisma_migrations` table; the row is in "failed" state. Either `prisma migrate resolve --rolled-back <name>` (after manually undoing) or `--applied` if the change is actually there.
- "Drift detected" → schema on the DB differs from the migration history. Common causes: someone ran `prisma db push` against shared DB, or hand-applied SQL. Generate a corrective migration with `prisma migrate diff`.
- Rename appears as drop+add → Prisma cannot infer renames; either accept data loss + reseed, or hand-edit the migration SQL to use `ALTER TABLE ... RENAME` before applying.
- Long migration on big table locks production → break into: add nullable column → backfill in batches → add NOT NULL with `SET DEFAULT` separately, or use `CREATE INDEX CONCURRENTLY` (raw SQL migration).

### Schema design red flags
- Every model has `id Int @id @default(autoincrement())` and IDs leak in URLs → propose `cuid()` / `uuid()` for any model exposed externally.
- Foreign keys without explicit `onDelete` → defaults vary; be explicit (`Cascade`, `Restrict`, `SetNull`).
- `String` for emails, slugs, usernames → consider `@db.Citext` (case-insensitive) or a normalized field + index.
- Soft delete via `deletedAt`, but no partial index on `WHERE deletedAt IS NULL` for hot queries.

### Query performance
- `findMany` over a join without `include` shape → check generated SQL with `prisma:query` logging.
- N+1 in a loop → use `findMany` with `where: { id: { in: [...] } }` and group client-side.
- `Prisma.sql` raw queries — make sure all interpolations use `Prisma.sql` tag, not string concatenation (SQL injection risk).

## Verification commands
- `npx prisma -v` — version and binary target info.
- `npx prisma migrate status` — applied vs pending vs failed; safe.
- `npx prisma migrate diff --from-schema-datamodel prisma/schema.prisma --to-schema-datasource prisma/schema.prisma --script` — what would migrate without applying. Safe and the best dry-run.
- `psql "$DATABASE_URL" -c '\dt'` and `\d <table>` — confirm reality.
- `npx prisma db pull --print` — what does Prisma see in the DB?

## Output format
- What I found (with confidence)
- Failing migration / file / line
- Smallest safe action (prefer `migrate diff` over `migrate dev`)
- Verification command + expected output
- Memory update: record in `<resolved memoryPath>/02-decisions/` if a schema decision was made

## Safety rules
- NEVER run `prisma migrate reset` or `prisma db push --force-reset` without an explicit user gate; both destroy data.
- NEVER run `prisma migrate dev` against a production DATABASE_URL; that command is for dev only.
- NEVER auto-apply a destructive migration. Stage as a `--create-only` migration and ask for review.
- Dependency install (`@prisma/client` / `prisma` bump) is a risk gate; ask before installing.
