---
name: docker-doctor
description: Diagnose Dockerfile, Compose, image, build, port, volume, healthcheck and runtime container problems.
---

# Haye Skill: docker-doctor

## Purpose
Diagnose Docker issues fast without rebuilding the whole repo. Focused on the Haye Labs stack: Compose v2, multi-stage builds for Node/Python, Coolify-managed runtime.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar Türkçe verilecek; kod, komutlar, dosya yolları orijinal kalır.

## Inputs to inspect first
1. `Dockerfile` (or `Dockerfile.*`) of the failing service.
2. `docker-compose.yml` / `docker-compose.*.yml` — service definition only, not all of them.
3. `.dockerignore` — often the root cause of slow builds and image bloat.
4. The first 5 and last 30 lines of the build/run failure log.
5. `package.json` scripts or `pyproject.toml` for the entrypoint.

## Token discipline
- Do not paste full build logs. Ask for the line containing the error and ~10 lines before.
- Do not list every layer; focus on the failing stage.

## Symptoms → first place to look

### Build fails
- `failed to solve: failed to compute cache key: ... no such file or directory` → `.dockerignore` is excluding a file the Dockerfile copies, or the path is wrong relative to build context.
- `npm ci` fails inside container but `npm install` works locally → lockfile not committed, or `engines.node` mismatch with the base image.
- `prisma generate` fails in build → missing `prisma/schema.prisma` in build context (check `.dockerignore`), or wrong working directory.
- Native modules (`bcrypt`, `sharp`, `canvas`) fail on Alpine → install build deps (`apk add --no-cache python3 make g++`) in builder stage, or switch to `node:20-slim` (Debian).
- Build very slow / huge context (`Sending build context to Docker daemon X.X GB`) → `.dockerignore` is missing `node_modules`, `.next`, `.git`, `*.log`.

### Multi-stage
- Final image still contains build tools and dev dependencies → not actually multi-stage; check that the runtime stage `FROM`s a fresh base and `COPY --from=builder` only what's needed.
- For Next.js standalone: must copy `.next/standalone`, `.next/static`, `public/`. Missing any of the three causes 404s at runtime.

### Runtime
- Container exits immediately with code 0 → PID 1 process exited (you ran `npm run build` instead of `npm start`).
- Container exits with 137 → OOM killed. Either raise memory limit or actually fix the leak (Node `--max-old-space-size`).
- Container starts, port not reachable → app listens on `127.0.0.1` instead of `0.0.0.0`. For Next.js: `HOSTNAME=0.0.0.0` env, or `next start -H 0.0.0.0`.
- Permission denied on `/app` → image runs as non-root but `COPY` set wrong owner. Add `--chown=node:node` to COPY, or `USER node` after `chown`.

### Compose
- Top-level `version: '3.8'` warning → Compose v2 ignores it. Remove the field.
- `depends_on: [db]` doesn't wait for DB to be ready → use `condition: service_healthy` and define a healthcheck on the DB service.
- Two services bind to host port 5432 → port conflict; one of them shouldn't expose to host at all, only on the internal network.
- Volume changes not reflected → bind mount points to wrong path, or named volume cached old content; `docker compose down -v` is destructive and a risk-gated command.
- `env_file: .env` not loaded → file path is relative to compose file location, not project root.

### Networking
- Service can't reach another service by name → both must be on the same network; in Compose default network this is automatic, but custom networks need explicit `networks:` on each service.
- DNS for service name resolves but connection refused → target service is listening on `127.0.0.1`, not `0.0.0.0`.

### Healthcheck
- Healthcheck always fails → using `curl` in an Alpine image without installing it; use `wget --spider` or install curl.
- Healthcheck passes but proxy 502s → check the path; reverse proxy might check `/` while healthcheck targets `/healthz`.

### Image hygiene
- Image tag `myapp:latest` → no rollback path. Tag with git sha or version.
- Base image `node:18` → past Node 18 LTS end-of-life (April 2025). Use `node:20` or `node:22`.
- `python:3.8` → EOL October 2024. Use `python:3.12-slim` if compatible.

## Verification commands
- `docker compose config` — validates merge of overrides; warns about deprecated fields. Safe.
- `docker compose build --progress=plain` — verbose build output, easier to diagnose. Approval gate (it builds).
- `docker compose run --rm <service> sh` — interactive debug of a one-shot. Approval gate.
- `docker inspect <container>` — runtime state. Safe.
- `docker compose logs --tail 100 <service>` — recent logs. Safe.

## Output format
- What I found (top 3 candidates, with confidence)
- Failing line / Dockerfile stage / service
- Smallest fix (file + diff)
- Verification command (cheapest first)
- Memory update needed

## Safety rules
- `docker compose down -v` deletes volumes; HARD risk gate.
- `docker system prune -a` deletes images on the host; HARD risk gate.
- `docker pull` of an unknown image is a dependency install gate.
- Do not propose `:latest` for any production image.
- Do not bypass healthchecks "to make it start".
