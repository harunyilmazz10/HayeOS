---
name: nextjs-doctor
description: Use when diagnosing Next.js build failures, App Router errors, RSC issues, middleware bugs, server action failures, caching anomalies, or Coolify-deployed Next.js problems
---

# Haye Skill: nextjs-doctor

## Purpose
Diagnose Next.js issues fast without scanning the whole repo. Focused on App Router + RSC + Coolify/Cloudflare hosting (Haye Labs default).

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar Türkçe verilecek; kod, komutlar, dosya yolları orijinal kalır.

## Inputs to inspect first
1. `.hayeos.json` and resolved `memoryPath`.
2. `package.json` (next version, react version, scripts.build / scripts.start), lockfile name only.
3. `next.config.js` / `next.config.mjs` (output mode, experimental flags, headers, redirects).
4. `app/` vs `pages/` to confirm router; if both exist, that itself is often the issue.
5. `middleware.ts` if present.
6. The specific error message or stack the user pasted (first + last 20 lines).
7. `<resolved memoryPath>/03-bugs/recurring/` for matching prior incidents.

## Token discipline
- Do not scan the whole repo; ask the user which route or component.
- Do not read full `.next/` output; ask for the first failing line and the last failing line.
- Prefer to inspect `next.config.*`, `middleware.ts`, `app/layout.tsx`, and the single failing route only.

## Common symptoms → first place to look

### Build fails
- `Module not found: Can't resolve '...'` → check tsconfig `paths`, `package.json` `imports`, case sensitivity (Linux is case-sensitive, macOS often is not).
- `ReferenceError: window is not defined` → server-rendered component touching browser API; needs `"use client"` or dynamic import with `ssr: false`.
- `Error: Image with src "/x.png" has invalid "src" property` → static image path wrong, or `images.remotePatterns` not configured for remote.
- Build hangs at "Collecting page data" → top-level `await` against a service that is not reachable from build (DB, env-required service). Move to `runtime`, not module scope.

### Dev runs but production fails
- Works in `next dev`, fails in `next start` / Coolify → `output: 'standalone'` missing, or `experimental.serverActions` config drifted, or env not set in prod.
- `next.config.js` uses `experimental.serverActions: true` on Next 14+ — that flag moved to top-level config; either remove or update.

### App Router / RSC
- "You're importing a component that needs `useState`. It only works in a Client Component" → add `"use client"` at top of the leaf, not the layout.
- Server Component passing functions/Date/Map to client → only serializable props cross the RSC boundary; pass primitives or use Server Actions.
- `cookies()` / `headers()` called in a static page → mark the route `dynamic = 'force-dynamic'` or move read to a route handler.

### Caching surprises
- Page shows old data after deploy → fetch() is cached by default in App Router; pass `{ cache: 'no-store' }` or `next: { revalidate: N }`, or call `revalidatePath` / `revalidateTag` after mutation.
- Route is statically generated when you expected dynamic → presence of `cookies()`, `headers()`, dynamic `searchParams`, or `cache: 'no-store'` opts out; otherwise Next will SSG.

### Middleware
- Middleware runs on every request including `_next/static` → set `matcher` correctly; default match is broader than people expect.
- Cookies set in middleware not seen on next request → `NextResponse.next({ request: { headers } })` pattern is required for cookie writes to propagate.

### Coolify / standalone
- `next start` works locally but Coolify deploy 502s → did you set `output: 'standalone'` and copy `.next/standalone`, `.next/static`, `public/` in the Dockerfile?
- Healthcheck path returns 200 in dev but 404 in prod → standalone build's static assets need explicit copy step.

### Cloudflare in front
- 522 origin timeout → the app is starting slowly (cold), or `next.config.js` has a wrong `assetPrefix`, or healthcheck path is wrong on Coolify side.
- Mixed content warnings → Cloudflare SSL mode is "Flexible"; switch to "Full (strict)" if origin has a cert (Coolify + Let's Encrypt does).

## Verification commands
- `npx next info` — captures versions and platform; safe.
- `npm run build` (with approval if it installs anything) — only after the user accepts the install gate.
- `curl -fsS https://<host>/api/health` — if the project has a healthcheck.
- `cat .next/BUILD_ID` — confirms a build completed.

## Embedded version baseline
- `next` 15.x: must be `15.5.16+`; 16.x: must be `16.2.5+`.
- `react`, `react-dom`: 19.0.x must be `19.0.6+`, 19.1.x `19.1.7+`, 19.2.x `19.2.6+`.
- Cross-check with `dependency-security` skill before recommending an upgrade.

## Output format
- What I found (top 3 candidates with confidence: high / medium / low)
- File:line(s) to look at
- Smallest diff to test the top hypothesis
- Verification command and expected output
- Memory update: `03-bugs/<id>.md` if reproduced and fixed

## Safety rules
- Do not run `npm install`, `pnpm add`, version bumps, or `prisma migrate` without the dependency / migration approval gate.
- Do not propose `next dev --turbo` as a "fix" for production behavior.
- Do not claim "fixed" without running `next build` and capturing the result.
