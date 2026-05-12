---
name: cloudflare-doctor
description: Diagnose Cloudflare DNS, proxy, SSL/TLS mode, WAF, page rules, cache rules, R2, Workers and tunnel issues.
---

# Haye Skill: cloudflare-doctor

## Purpose
Diagnose Cloudflare-side issues without changing settings until the root cause is identified. Cloudflare is fast to blame and slow to actually fault; this skill treats it as the most stable layer until proven otherwise.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar Türkçe verilecek; kod, komutlar, dosya yolları orijinal kalır.

## Inputs to inspect first
1. The exact error code / page the user is seeing (522, 524, 525, 526, 1015, 1020, "Error 1000 DNS points to prohibited IP").
2. The hostname and whether the orange-cloud proxy is on.
3. SSL/TLS mode (Off, Flexible, Full, Full strict).
4. Whether the origin has its own TLS cert (Coolify with Let's Encrypt usually does).
5. Any active Page Rules, Cache Rules, WAF Custom Rules.

## Token discipline
- Do not list every rule. Ask which rule was last changed.
- Do not fetch the whole zone via API.

## Symptoms → first place to look

### Connection / status codes
- **522 (origin timeout)**: TCP handshake didn't complete with the origin. Origin is slow to start, firewalled (UFW blocking Cloudflare IP ranges), or app is binding `127.0.0.1`. From the origin host: `curl -v https://<origin>:443`. From outside: `curl -v --resolve <host>:443:<origin-ip> https://<host>/`.
- **524 (timeout after handshake)**: TCP connected but no response in 100s. App is hanging on a request (long DB query, blocking SSR). Move the slow op to a background job or use a streaming response.
- **525 (SSL handshake failed)**: Cloudflare in Full / Full strict, origin has no cert, expired cert, or wrong SNI. Check `openssl s_client -connect <origin>:443 -servername <host>`.
- **526 (invalid SSL cert)**: Full strict mode + self-signed cert at origin. Either install a real cert (Let's Encrypt via Coolify) or downgrade to Full (less safe) — never to Flexible.
- **520 (web server returned unknown error)**: origin sent an invalid or truncated response. Often headers too large or app crashed mid-response.

### SSL/TLS mode
- "Too many redirects" loop → Cloudflare is "Flexible" (https to origin via http) and the origin is forcing https-redirect. Switch to Full (strict) and remove duplicate redirect from origin OR remove origin redirect entirely.
- Mixed-content warnings in browser → Flexible mode + page with hard-coded `http://...` resources. Switch to Full strict and fix the assets.

### DNS
- "DNS points to prohibited IP" → the A record is using a Cloudflare-owned IP. Set it to your origin IP.
- Domain works on Cloudflare DNS but not on registrar's nameservers → registrar's nameservers are still authoritative; check NS records at registrar.
- A record orange-cloud on, but `dig +short <host>` returns origin IP → DNS just propagated; wait. Proxy IPs come after a few minutes.

### WAF / rate limit (Error 1xxx)
- **1015 (rate limited)** → custom rate limiting rule triggered. Check the rule that names the user's IP or pattern.
- **1020 (access denied)** → a Firewall / WAF Custom Rule blocked it. Filter the Events log by the user's IP to find which rule fired.
- WAF blocks legitimate API traffic → managed rule false positive. Either bypass the rule for that path (`/api/*`) or skip the OWASP managed ruleset on that path.

### Cache
- Old content served after deploy → cached at edge. Purge the URL or set `Cache-Control: no-store` on dynamic responses.
- Cache miss when it should hit → query string variant (Cloudflare caches with full URL unless told otherwise), or origin sending `Cache-Control: private`.
- Cookie present → many bypass rules skip cache when `Cookie` header exists. Check Cache Rule "Bypass cache on cookie".

### R2 (storage)
- Public bucket returns 401 → bucket needs a public access policy or a Worker / `r2.dev` subdomain configured.
- Signed URL expired → check skew between client and server clocks; signed URLs are time-bound.
- Upload size limit hit → R2's per-PUT limit is 5 GB; for larger, use multipart upload.

### Workers
- Worker returns 1101 → exception thrown in the script; check `wrangler tail`.
- Worker times out → 50ms CPU limit on free, 30s wall-clock; either upgrade plan or move work to a Queue/Cron.

### Tunnel (cloudflared)
- Tunnel shows "healthy" but site 502 → ingress rules in `config.yml` point to wrong local URL.
- Tunnel works but with high latency → no `originRequest.keepAliveConnections`; add it.

## Verification commands
- `dig +short <host>` and `dig +trace <host>` — DNS state, safe.
- `curl -v --resolve <host>:443:<origin-ip> https://<host>/` — bypass Cloudflare to test origin directly.
- `openssl s_client -connect <origin>:443 -servername <host>` — origin TLS state.
- `wrangler tail` (Worker) — live logs.
- Cloudflare dashboard → Security → Events — what rule fired for a given IP.

## Output format
- What I found (top 3 candidates with confidence)
- Setting / rule to change (be specific: which rule, which page, which mode)
- Smallest change
- Verification: cheapest first (curl --resolve before changing any setting)
- Memory update if a Cloudflare decision is made (record in `<resolved memoryPath>/02-decisions/`)

## Safety rules
- Do not "Pause Cloudflare" as a fix; that disables protection entirely. Use Development Mode (3h) only as a diagnostic.
- Do not downgrade SSL/TLS mode to Flexible to "make it work"; that breaks security.
- Do not delete WAF rules without copying their config first.
- WAF is defense-in-depth, not a replacement for fixing the application bug.
- Purging cache can mask a deploy issue; verify deploy actually shipped before purging.
