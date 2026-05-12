# Recipe: Prisma + Postgres (Haye default)

Quick reference. Diagnostics: `prisma-doctor`, `database-doctor`.

## Stack assumed
- Prisma latest stable, `@prisma/client` matching version
- Postgres 16 (Coolify-managed or external)
- App connects via pooler if serverless; direct otherwise

## Schema baseline
- `id` is `cuid()` or `uuid()` for anything externally referenced
- Every FK has a matching index
- Tenant tables include `organizationId` or `userId` with index
- Soft delete: `deletedAt DateTime?` + partial index `WHERE deletedAt IS NULL`

## Connection string shape
- `postgresql://user:pass@host:5432/db?schema=public&connection_limit=10`
- With pgbouncer (transaction mode): add `pgbouncer=true&statement_cache_size=0`

## Migrations (production-safe pattern)
- Develop: `prisma migrate dev` (local DB only)
- Review: `prisma migrate diff --from-schema-datasource --to-schema-datamodel --script`
- Deploy: `prisma migrate deploy` (gated, with backup taken)
- NEVER `prisma migrate reset` or `db push --force-reset` against shared DBs

## Backup minimum
- Daily `pg_dump` + offsite copy
- Quarterly restore drill into a scratch DB
- WAL archiving for tighter RPO if business-critical

## Common breakage
- OpenSSL mismatch in Docker → set `binaryTargets`
- pgbouncer + prepared statements → disable cache
- Drift from manual SQL → corrective migration via `migrate diff`

## When to escalate
- Client / migration / OpenSSL → `prisma-doctor`
- Postgres itself (locks, perf, exposure) → `database-doctor`
