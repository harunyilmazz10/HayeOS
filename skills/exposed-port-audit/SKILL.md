---
name: exposed-port-audit
description: Audit exposed network ports, firewall rules, reverse proxy boundaries and direct service exposure on Coolify/Hetzner hosts.
---

# Haye Skill: exposed-port-audit

## Purpose
Confirm which ports of a host are reachable from the internet vs the Docker network only. Catches the classic "Postgres 5432 publicly bound" class of mistake.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa bulgular Türkçe verilir.

## Inputs to inspect first
1. `docker-compose.yml` / `docker-compose.*.yml` for every service's `ports:` declaration.
2. Coolify app settings (services tab) — which ports it declares as public.
3. UFW status (`sudo ufw status numbered`) if accessible to user; the rules are the firewall ground truth.
4. Cloud-provider firewall (Hetzner Cloud Firewall, if used) — separate from UFW; both apply.
5. `iptables -L -n` if no UFW is in use.

## Token discipline
- Do not list every service in `docker-compose.yml`. Identify the ones with `ports:` exposed to host.

## Checks

### Compose declarations
- `ports:` with host binding `5432:5432`, `6379:6379`, `27017:27017`, `9200:9200`, `9090:9090`, `3000:3000` (for app behind reverse proxy) → review each
- Format `"5432"` (short syntax) → binds to `0.0.0.0:5432`. Use `"127.0.0.1:5432:5432"` to bind localhost only, or use `expose:` instead of `ports:` to keep it on the Docker network
- `expose:` is internal-only — that's the safe option for DBs, Redis, queues

### Things that should never be public
- PostgreSQL (5432, custom)
- Redis (6379, 16379)
- MongoDB (27017)
- Elasticsearch (9200, 9300)
- Kafka (9092)
- Memcached (11211)
- Prometheus (9090) — internal metrics
- Coolify dashboard (8000) — admin UI, gate behind VPN/tunnel
- Traefik dashboard (8080) when `--api.insecure=true` is set
- Docker daemon socket (`/var/run/docker.sock` bind-mounted into a container reachable from public web)
- `.git/` directory served by a misconfigured static server

### Reverse proxy correctness
- Traefik labels exist but service also binds host port → app accessible at both `https://host` (via Traefik) AND `http://host:3000` (direct, bypasses Cloudflare/Traefik). Remove the host binding.
- A service has `ports: 80:80` outside Traefik → port conflict with Traefik itself or Cloudflare tunnel

### UFW
- `sudo ufw status` should explicitly allow only the ports the host serves publicly
- Common minimal Hetzner Coolify UFW: `22/tcp` (or custom SSH port), `80/tcp`, `443/tcp`, and nothing else public
- `DEFAULT_INPUT_POLICY` = `DROP` for input chain
- IPv6 rules present (`ip6tables`) — many hosts forget IPv6

### Cloud firewall (Hetzner)
- Inbound rules duplicated with UFW? Both apply; the more restrictive wins
- Separate IPv6 inbound rules?
- Source: `0.0.0.0/0` only on 80/443. SSH locked to a static IP or VPN.

### SSH
- Listening on default `22` and password auth enabled → flag as risk (the user's setup memory says SSH hardening was done; verify against the actual `sshd_config` if accessible)
- Root login enabled → flag
- Fail2ban running (since the user's setup mentions it) — confirm jail count: `sudo fail2ban-client status`

### Edge / DNS
- A subdomain with A record pointing directly to the host, bypassing Cloudflare proxy → loses WAF/DDoS layer
- Wildcard DNS proxied through Cloudflare but origin allows direct connection — Cloudflare's Authenticated Origin Pulls (mTLS) or origin IP allowlist closes this

## Verification commands (run from outside the host whenever possible)
- `nmap -sT -p- --open -T4 <host>` — exhaustive TCP scan (HARD risk gate: ask before scanning; users on shared infra may violate AUP)
- `nmap -sT -p 1-1024 <host>` — common range, faster (still gate)
- `curl -v http://<host>:5432` — quick smoke-test (gets garbage but proves port is open)
- `sudo ss -tlnp` on the host — what is listening locally
- `sudo iptables -L -n -v` — current rules
- `sudo ufw status verbose` — UFW rules

## Output format
```markdown
## Surface inventory
- public (intended): 80, 443, <SSH port>
- public (unintended): list
- internal-only (Docker network): list
- not bound at all: list

## Findings
### Critical (DB/Redis/admin publicly reachable)
- service:
- evidence (compose line / nmap result):
- action: bind to 127.0.0.1 or remove ports: section

### High
- ...

### Medium
- ...

## Recommended diff (smallest changes)
- file → change

## Memory updates
- <resolved memoryPath>/12-risks/exposed-ports.md
```

## Safety rules
- `nmap` against hosts you don't own or have explicit authorization for is a HARD risk gate (and possibly illegal). Always confirm host ownership.
- Changing UFW rules from a remote SSH session can lock you out. Always have a console fallback (Hetzner Rescue / serial console) before modifying SSH or firewall rules.
- Do not propose disabling UFW "for testing"; use a temporary rule that allows your IP.
- If a database is exposed, write to `<resolved memoryPath>/12-risks/exposed-database.md` immediately and propose the smallest closing change.
