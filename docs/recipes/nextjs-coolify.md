# Recipe: Next.js on Coolify (Hetzner)

Quick reference. For full diagnostics, use the `nextjs-doctor`, `coolify-doctor` and `docker-doctor` skills.

## Stack assumed
- Next.js 15+ App Router, `output: 'standalone'`
- Node 20 base image, multi-stage Dockerfile
- Coolify-managed deploy on a Hetzner box
- Cloudflare proxy in front, Full (strict) SSL

## Minimum Dockerfile shape
- builder stage: `npm ci`, `npm run build`
- runner stage: copy `.next/standalone`, `.next/static`, `public/`
- `EXPOSE 3000` and `CMD ["node","server.js"]`
- non-root `USER node`

## Coolify settings to check
- Build pack: Dockerfile (not Nixpacks) when standalone build is used
- Healthcheck path: `/api/health` returning 200 fast (no DB queries)
- All env vars from `.env.example` declared in the app's Env section
- Persistent storage only for things that must survive redeploy

## Cloudflare
- DNS proxied (orange-cloud) for the public hostname
- SSL/TLS mode: Full (strict); Coolify provisions Let's Encrypt at origin
- WAF: keep OWASP rules on; bypass for `/api/webhooks/*` if needed

## Common breakage
- `output: 'standalone'` missing → 502 in Coolify
- Healthcheck does a DB query → flaps on DB blip
- Env var added but not redeployed → `NEXT_PUBLIC_*` baked at build time
- Cloudflare SSL "Flexible" + origin TLS → redirect loop

## When to escalate to a skill
- Build fails → `nextjs-doctor`
- Deploys but 502s → `coolify-doctor`
- Dockerfile issues → `docker-doctor`
- 522/525 → `cloudflare-doctor`
