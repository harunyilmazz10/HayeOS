---
name: coolify-doctor
description: Diagnose Coolify deployment, build pack, Traefik routing, env, healthcheck and container lifecycle on Hetzner-hosted Coolify.
---

# Haye Skill: coolify-doctor

## Purpose
Diagnose Coolify-specific deployment issues without SSHing or restarting services blindly. Assumes the Haye Labs setup: Coolify on a Hetzner box, Traefik as the reverse proxy, Cloudflare in front.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar Türkçe verilecek; kod, komutlar, dosya yolları orijinal kalır.

## Inputs to inspect first
1. The Coolify application page screenshot or output the user shared (do not auto-fetch Coolify API).
2. `Dockerfile` and `docker-compose.yml` (Coolify reads the latter for compose apps).
3. `.env.example` to know what env vars the app expects.
4. The exact error visible in Coolify's "Deployments" tab — first failing line.
5. Whether the app is configured as "Dockerfile", "Docker Compose", or a Nixpacks build.

## Token discipline
- Do not request entire Coolify build logs. Ask for the failing step and the line before/after.
- Do not list every env var; ask for the one referenced in the error.

## Symptoms → first place to look

### Build phase
- "FROM not found" / wrong base image → Dockerfile path in Coolify settings is wrong. Default is `./Dockerfile` relative to build context root.
- Nixpacks chosen for a project that should use Dockerfile → switch the build pack in Coolify app settings. Symptom: a Next.js or FastAPI project getting an unexpected runtime.
- Build times out → image too large, no `.dockerignore`, or the project keeps generating types at build time. Move type generation behind a cache layer.
- "Could not resolve hostname github.com" → DNS in the build container is broken; usually a Coolify server-level issue (Docker daemon DNS). Check `/etc/docker/daemon.json` on the host.

### Env vars
- App boots but immediately exits "missing env X" → env declared in `.env.example` but not added in Coolify's app env section. Coolify does NOT auto-load `.env` from the repo.
- `NEXT_PUBLIC_*` not visible in the browser → these are baked at build time; you must redeploy after changing them, not just restart.
- Secret added but app still says undefined → `Build & Deploy` step needs to be re-triggered; "Restart" alone does not rebuild.

### Healthcheck
- Coolify marks the deploy as failed because health endpoint times out → app starts slowly (Next.js cold start, Prisma engine load). Increase health check timeout/retries in Coolify, do not remove the healthcheck.
- Healthcheck calls `/` and gets a 308/307 redirect → Coolify follows redirects but Traefik might serve the redirect before app is ready; use a dedicated `/api/health` that returns 200 fast.
- Healthcheck path returns 200 but probes the DB → one Postgres blip and the app gets restarted. Health endpoint should test process liveness only.

### Traefik / domain
- "404 page not found" (Traefik's, not the app's) → labels missing on the service. Coolify usually adds them; for compose apps, check the generated `docker-compose.yml` output in the deployment logs.
- Domain shows certificate mismatch → Coolify uses Let's Encrypt; the FQDN must point to the server's IP for the challenge to succeed. If Cloudflare proxy is on, set DNS-01 challenge or use "DNS Only" for the cert challenge.
- "Bad Gateway 502" from Coolify proxy → the target container is not on the Coolify proxy network; check the network configuration.

### Cloudflare in front
- 522 origin timeout → start-up time too long, or the app is binding 127.0.0.1. From inside the app container, `curl localhost:<PORT>` must work.
- TLS warning despite Cloudflare proxy ON → Cloudflare SSL mode is "Flexible" with an origin that has TLS; switch to "Full (strict)".
- Worker / page rule overriding cache → check Cloudflare's "Cache Rules" and "Page Rules"; one of them is bypassing `Cache-Control` from the origin.

### Volumes / data
- Data lost after redeploy → app wrote to a path that wasn't a Coolify-defined persistent volume. Move writes to a path declared as a persistent storage in Coolify's app settings.
- DB inside the same Compose app → on Coolify, prefer a separate "Service" or external managed DB. Co-located DB volumes are tied to that deploy's lifecycle and can be lost on certain operations.

### After a Coolify upgrade
- Old apps stop working → Traefik config schema may have changed; rebuild the affected app. The first sign is usually `entryPoints` errors in Traefik logs.

## Verification commands
- From the app container: `curl -fsS localhost:$PORT/api/health` — confirms the app itself is healthy.
- From the host: `docker compose ps` (inside Coolify's app stack directory) — container state.
- `docker logs --tail 200 <container>` — runtime errors.
- `dig +short <host>` and `curl -v https://<host>/api/health` — DNS and Cloudflare passthrough.
- Coolify "Logs" tab: filter to the failing step.

## Output format
- What I found (top 3 candidates, with confidence)
- Coolify setting / file / line to change
- Smallest fix
- Verification (cheapest first)
- Memory update needed (especially if this was a recurring class of issue → `03-bugs/recurring/`)

## Safety rules
- Do not run `coolify` CLI destructive operations.
- Do not delete the deploy from Coolify "to retry"; redeploy in place.
- Do not change Cloudflare SSL mode without confirming the origin has a valid cert.
- 522/524 is an origin problem until proven otherwise; do not blame Cloudflare first.
- "Restart" is not "redeploy" — be explicit which one you mean.
