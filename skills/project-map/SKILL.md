---
name: project-map
description: Use when starting on an unfamiliar project, after major refactor, or before planning a cross-cutting change - one structured map of routes, models, env, services
---

# Haye Skill: project-map

## Purpose
Produce a one-page map of a project so you (or another assistant) can navigate without scanning the repo every time. The output lives in memory and is updated, not regenerated, as the project evolves.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa açıklamalar Türkçe verilir; yapısal listeler orijinal kalır.

## Inputs to inspect first
1. Repo root: `package.json`, `pyproject.toml`, `tsconfig.json`, `next.config.js`, `Dockerfile`, `docker-compose.yml`, `prisma/schema.prisma`.
2. Top-level directory listing (2 levels deep is enough).
3. `.env.example` for env catalog.
4. Existing `<resolved memoryPath>/01-project/project-map.md` if it exists — update, don't replace.

## Token discipline
- Don't read every file; you're producing an index, not a summary.
- `ls -la`, `tree -L 2`, listing only.
- Open a file only when its name doesn't tell you what it is.

## Workflow

### Step 1 — Identify stack
- Language/runtime (Node 20 / Python 3.12 / etc.)
- Framework (Next.js App Router / FastAPI / Express)
- ORM/DB (Prisma + Postgres / SQLAlchemy + Postgres)
- Test runner (Vitest / Pytest)
- Build/deploy (Docker, Coolify, etc.)

### Step 2 — Map the directory tree
- 2-3 levels deep, with a one-line description per folder.
- Group: `app/`, `lib/`, `components/`, `prisma/`, `scripts/`, `docs/`, `tests/`.

### Step 3 — Route inventory (web apps)
- Every API route with its method and a one-line purpose.
- Group by area: auth, billing, admin, public.
- Pages: route → page component file.

### Step 4 — Data model summary
- Models (Prisma) with row counts approximated (small / medium / large) — do not query DB.
- Relations: which model owns which.
- Ownership column: `userId` / `organizationId` / global.

### Step 5 — Env vars
- From `.env.example`: name → purpose (one line).
- Note which are public (`NEXT_PUBLIC_*`) vs server.
- Note which are required vs optional.

### Step 6 — Third-party services
- Each service: what it's used for, where the integration lives, where the credential lives.

### Step 7 — Key files
- Entry points: server start, route registration, auth config.
- "If you only read 5 files to understand this project, read these."

### Step 8 — Deploy map
- Hosts: which Hetzner server runs what.
- Domains: which subdomains route where.
- Cron / scheduled jobs: where they live, what they do.

### Step 9 — Write to memory
- `<resolved memoryPath>/01-project/project-map.md` (overwrite if older than 30 days, else update).
- Link from `index.md`.

## Anti-patterns to refuse
- Copying the entire repo tree (output explosion); 2 levels is the cap.
- Mapping a project nobody asked about — this is on-demand.
- Embedding code; the map is an index, not a documentation export.
- Producing a map that's older than the repo's last week of commits — date it, or it lies.

## Output format
```markdown
# Project map — <project> (<date>)

## Stack
- runtime:
- framework:
- ORM/DB:
- test:
- deploy:

## Tree (key folders)
- app/ — Next.js App Router pages
- lib/api/ — external API adapters
- ...

## Routes
### API
- POST /api/auth/login — credentials login
- ...
### Pages
- /dashboard — main user view

## Data model
- User (medium) ← owns Session, Subscription
- ...

## Env vars
- DATABASE_URL (server, required) — Postgres connection
- ...

## Third-party services
- Stripe (billing) — lib/integrations/stripe.ts — STRIPE_SECRET_KEY
- ...

## If you read 5 files
1. app/layout.tsx
2. prisma/schema.prisma
3. lib/auth.ts
4. middleware.ts
5. app/api/<key-route>/route.ts

## Deploy
- production: Hetzner AX42 → Coolify → app + db
- staging: ...
- cron: ...

## Last updated
- <date>
- commit: <sha>
```

## Safety rules
- Don't include real env values, only names.
- Don't include credentials, even partial.
- The map is in `01-project/`, never in `08-raw/` and never under `CLAUDE_PLUGIN_ROOT`.
- If the project has a `docs/architecture.md`, link to it rather than duplicate; map is the index, architecture doc is the explanation.
