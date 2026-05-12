---
name: auth-audit
description: Use when reviewing authentication flows, session/cookie security, admin guards, API authorization, RBAC, ownership checks, password handling, or MFA implementation
---

# Haye Skill: auth-audit

## Purpose
Audit auth and authorization surfaces of a Next.js + Prisma + Postgres app (Haye Labs default stack). Read-only review; produces a risk list, not patches.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa bulgular Türkçe sıralanır; kod/komut isimleri orijinal kalır.

## Inputs to inspect first
1. Auth lib in use: `next-auth`/`auth.js`, `lucia`, `clerk`, custom JWT? — find in `package.json` and config file (`auth.ts`, `app/api/auth/[...nextauth]/route.ts`).
2. `middleware.ts` — what does it protect?
3. `app/api/`, `pages/api/`, FastAPI routers — list of routes, especially `*/admin/*`, `*/internal/*`, `*/me`, mutation endpoints (POST/PUT/PATCH/DELETE).
4. `prisma/schema.prisma` — `User`, `Session`, `Account`, `Role` models. Ownership fields on every tenant-scoped model.
5. Cookie config / session strategy (`session: { strategy: 'jwt' | 'database' }`).
6. RBAC: roles enum or table; how is "admin" determined?

## Token discipline
- Don't read every endpoint. List endpoints, then read only those marked `/admin`, `/api/*` with side effects, or the one the user is asking about.

## Checks (in priority order)

### Session and cookies
- Cookie flags: `httpOnly: true`, `secure: true` in production, `sameSite: 'lax'` minimum, `'strict'` for admin
- Session lifetime: explicit `maxAge`, refresh strategy, server-side revocation possible (DB session > JWT for revocation)
- CSRF: state-changing endpoints in a cookie-auth context have CSRF token (NextAuth handles for its routes; custom routes do not)
- Cookie name collisions with other apps on the same domain → use prefixes

### Authentication
- Password hashing: `bcrypt` cost ≥ 10, or `argon2id` with sane params (m=64MB, t=3, p=4)
- Password rules: not pretending strength via length-only — allow paste, allow long passwords, no upper-limit < 64 chars
- Account enumeration on signup / reset: response must be identical regardless of whether email exists
- Reset tokens: cryptographically random, single-use, short TTL (15 min), stored as hash not plaintext
- Email verification before activating sensitive features
- MFA available for at least admin accounts

### Authorization
- Every mutation endpoint checks the requester's identity AND that the target resource is theirs: `where: { id: input.id, userId: session.user.id }` — not just `findUnique({ id })`
- Admin guard: server-side check on every admin route, not just a UI flag. Client-side `if (user.isAdmin)` is presentation, not security.
- IDOR: numeric incremental IDs in URLs → consider switching to `cuid()`/`uuid()`; if keeping numeric, the ownership check above is required
- Tenant isolation: all queries scoped by `organizationId` / `tenantId`

### API route shape
- POST without auth → confirm intentional (signup, webhook)
- DELETE / PATCH without ownership filter → high risk, list specifically
- Endpoints that accept `userId` from request body and trust it → never trust client-supplied identity
- Mass-assignment: `prisma.user.update({ data: req.body })` without an allowlist → user can update `isAdmin: true`

### Webhooks (incoming)
- Signature verification with **constant-time** comparison (`crypto.timingSafeEqual` in Node)
- Replay protection: `event_id` table or `webhook_signature_timestamp` ± 5 min
- HTTPS-only enforcement at the edge (Cloudflare full strict)

### Rate limiting / abuse
- `/auth/signin`, `/auth/reset`, `/auth/signup`, `/contact` have per-IP and per-account limits
- Bot-prone endpoints have hCaptcha/Turnstile or proof-of-work
- 2xx response time ≈ 4xx response time on login (no user-enumeration timing leak)

### Logging / privacy
- No password, token, session ID, or full email in logs
- Auth errors logged but not echoed verbatim to client
- Audit trail for admin actions (who did what when)

## Output format
```markdown
## Risk summary
- critical (fix this session):
- high (fix this phase):
- medium (this sprint):
- low (track in <resolved memoryPath>/12-risks/):

## By area
### Session / cookies
- finding (file:line):

### Authentication
- finding:

### Authorization
- finding:

### Webhooks
- finding:

### Rate limiting
- finding:

### Logging
- finding:

## Recommended next 3 actions (smallest fixes first)
```

## Safety rules
- Do not run `npm install` or change auth library version inside this skill; that is `dependency-security`'s domain with an explicit gate.
- Do not propose disabling MFA or CSRF "for testing"; suggest a feature-flag instead.
- Do not paste tokens, password hashes, or session IDs into chat output even when found.
- Long findings go to `<resolved memoryPath>/10-reviews/auth-audit-<date>.md`; chat gets the risk summary.
