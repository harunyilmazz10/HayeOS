# Recipe: Cloudflare WAF + Framework Security

The point of this recipe: Cloudflare WAF is defense-in-depth. It is NOT a replacement for patching React, Next.js, Prisma, or your auth code. Treat the framework as the inner layer, WAF as the outer.

## Layered model
1. Inner: dependency versions current (React, Next, Prisma, etc.). See `dependency-security` skill.
2. Middle: app-level auth, RBAC, input validation, CSRF, rate limits. See `auth-audit`.
3. Outer: Cloudflare WAF managed ruleset, custom rules, bot management.

If any layer is weak, the WAF cannot save the others.

## Cloudflare WAF settings to enable
- Managed Rules: OWASP Core Ruleset, Cloudflare Managed Ruleset — both enabled in `Detect` first, then `Block` after tuning
- Bot Fight Mode for low-effort blocking; Super Bot Fight Mode if paid
- Rate Limiting Rules: per-IP cap on `/api/auth/*`, `/api/signup`, `/contact`
- Browser Integrity Check ON for non-API paths

## Custom WAF rules worth having
- Block known bad ASNs from `/api/auth/login` (if you have signal)
- Challenge on geolocation mismatch between login IP and stored session location
- Block User-Agent strings of headless tooling on signup
- Allowlist for `/api/webhooks/<provider>` from provider IP ranges (Stripe, GitHub)

## Common mistakes
- Treating WAF "Off" as the fix for false positives — instead, write a bypass rule for the specific path
- Disabling managed rules entirely because one rule blocks API traffic — bypass that rule on `/api/*` only
- Putting CSRF token check entirely behind WAF — app must still check, WAF is the second layer
- Cloudflare in front but origin firewall allows all → Cloudflare IPs not enforced; bypass is trivial

## Origin hardening
- Origin firewall (UFW / Hetzner) only allows Cloudflare IPs on 80/443
- Or: Cloudflare Tunnel to remove direct origin access entirely
- Authenticated Origin Pulls (mTLS) for the most exposed paths

## When to escalate
- WAF event diagnostics → `cloudflare-doctor`
- Framework version audit → `dependency-security`
- Auth/RBAC review → `auth-audit`
- Exposed origin → `exposed-port-audit`
