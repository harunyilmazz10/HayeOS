---
name: secrets-audit
description: Find possible secret leaks in env files, code, logs, build artifacts, git history, CI settings and memory notes.
---

# Haye Skill: secrets-audit

## Purpose
Find secrets that escaped from where they belong. Conservative: false positives are cheap; missed real keys are not.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa bulgular Türkçe sıralanır; örnek değerler asla chat'e basılmaz.

## Inputs to inspect first
1. `.env.example` — the catalog of expected secrets (no values).
2. `.gitignore` — does it cover `.env`, `.env.local`, `.env.*.local`, `*.pem`, `*.key`?
3. `package.json` and `requirements.txt` — what services expect tokens (signals what to look for).
4. Recently modified files (the user's diff) — start there, not the whole repo.
5. Any monitoring / log shipping config — secrets often leak through there.

## Token discipline
- Do not paste matched strings into chat or memory. Report file:line + the secret's PURPOSE only ("Stripe live secret key in next.config.js:12").
- Search high-signal places first, expand only if needed.

## Where to look (priority order)

### Filesystem
- `.env`, `.env.local`, `.env.production`, `.env.*` — are any of these committed? `git ls-files | grep -E '\.env'`
- `*.pem`, `*.key`, `*.p12`, `*.pfx`, `id_rsa`, `id_ed25519` files anywhere in the repo
- `terraform.tfvars`, `secrets.yaml`, `kustomization.yaml` with inline values
- `docker-compose.yml` with inline `MYSQL_ROOT_PASSWORD: ...` or `POSTGRES_PASSWORD: ...`

### Code patterns (search but do not echo matches)
- `sk_live_`, `sk_test_` (Stripe), `whsec_` (Stripe webhook), `pk_live_` is public but worth noting
- `AKIA[0-9A-Z]{16}` (AWS access key), `aws_secret_access_key`
- `xox[bsp]-` (Slack tokens), `ghp_`, `gho_`, `ghu_`, `ghs_`, `github_pat_` (GitHub PATs)
- `eyJ` start (JWTs — often legitimate as session tokens but should not be in source)
- `AIza[0-9A-Za-z\\-_]{35}` (Google API key)
- `-----BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY-----`
- `postgres://[^:]+:[^@]+@`, `mongodb(\+srv)?://[^:]+:[^@]+@`, `redis://[^@]+@`
- `OPENAI_API_KEY\s*=\s*['"]sk-`, `ANTHROPIC_API_KEY\s*=\s*['"]sk-ant-`
- High-entropy strings ≥ 32 chars inside source files (false-positive prone — verify before flagging)

### Frontend bundles
- `NEXT_PUBLIC_*` env vars — must be truly public; any token in there is published to every visitor
- Server-side secrets accidentally referenced from a client component → next build will bake them in if imported into a client file

### Git history
- Use `git log -p --all -- .env` to confirm a secret was committed in the past, even if removed now → must rotate the secret; deleting the file does not unleak it
- Force-push history rewriting is destructive (HARD risk gate); usually rotating the secret is the safer choice

### Logs / monitoring
- Sentry / Datadog / Logtail config that scrubs `password`, `authorization`, `cookie` — confirm scrubbing patterns are in place
- Error logs containing full request body (POST signup with password)
- Build logs (Coolify) printing env vars at start of build

### CI / Coolify
- Build commands echoing env: `echo "DATABASE_URL=$DATABASE_URL"` — never
- Secrets in build step environment that get into the image as ARG values are visible in `docker history`
- "Test" or "preview" environments using production secrets

### HayeOS memory
- `<resolved memoryPath>/06-prompts/` or `<resolved memoryPath>/08-raw/` containing pasted API keys from old chats
- Context packs that include `.env` contents

## Output format
```markdown
## Findings
### Critical (real-looking secret in committed file or pushed to remote)
- type: <Stripe live | AWS | OpenAI | ...>
- file:line:
- visibility: committed / staged / local-only
- action: ROTATE the secret immediately at provider, then remove from file/history

### High (likely secret in build output or runtime log)
- ...

### Medium (high-entropy string, unverified)
- ...

### Low (config that could leak in future)
- ...

## Rotation checklist (per critical/high finding)
- [ ] revoke at provider
- [ ] generate replacement
- [ ] update Coolify env / .env (not committed)
- [ ] redeploy
- [ ] verify old secret returns 401/403

## Hygiene additions to .gitignore (if missing)
- .env
- .env.local
- .env.*.local
- *.pem
- *.key
- *.p12
```

## Safety rules
- NEVER print the secret value, even partially redacted, in chat. File:line + type is enough.
- NEVER push removal commits without confirming the rotation happened first; the commit alone does not unleak.
- NEVER rewrite shared history (`git push --force`) without explicit approval and a coordinated team.
- Findings memory write target: `<resolved memoryPath>/10-reviews/secrets-audit-<date>.md`, NEVER inside `08-raw/` or chat history.
