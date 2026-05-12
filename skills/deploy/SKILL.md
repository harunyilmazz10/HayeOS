---
name: deploy
description: Execute a deploy with pre-flight checks, controlled rollout and rollback readiness. Coolify/Hetzner default; adaptable to other targets.
---

# Haye Skill: deploy

## Purpose
Run a deploy, not just hit "Deploy" in the Coolify UI. Pre-flight checks, monitor during, verify after, ready to roll back. Complements `/haye:ship` (which is broader release coordination).

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa açıklamalar Türkçe verilir.

## Inputs to inspect first
1. Deploy target: Coolify, Vercel, fly.io, bare Docker host, mobile store?
2. `package.json` version vs `<resolved memoryPath>/changelog.md` — is this a new version?
3. Open migration in `prisma/migrations/` — pending against production?
4. `<resolved memoryPath>/05-sessions/latest-checkpoint.md` — what's the state of work?
5. Whether `/haye:secure` ran this session.

## Token discipline
- Don't paste full build/deploy logs into chat; first failing line + last 30 lines if it fails, otherwise just "deploy completed".

## Workflow

### Step 1 — Pre-flight (refuse to proceed if any fails)
- `npm run build` or equivalent: PASSED.
- Tests: PASSED.
- Typecheck: PASSED.
- Lint: PASSED.
- `prisma migrate status`: in sync, no pending in production that isn't planned.
- `dependency-security` skill output reviewed if there were dep changes this cycle.
- `git status`: clean, current branch matches deploy target.
- A backup of production DB taken within the last N hours (for any DB-affecting deploy).

### Step 2 — Migration (if any)
- `prisma migrate deploy` against production with explicit approval (this is a Risk Gate).
- Wait for `prisma migrate status` → in sync.
- If migration is destructive, the rollback step must be ready in another terminal.

### Step 3 — Deploy
- Coolify: trigger Build & Deploy via UI or webhook. Watch the build log.
- Tag the image with a recoverable identifier (git sha or version), not just `latest`.
- For multi-instance deploys, do rolling or canary — never all-at-once on production-critical paths.

### Step 4 — Verify during
- Health endpoint returns 200: `curl -fsS https://<host>/api/health`.
- One representative authenticated request works.
- Error rate in the first 60 seconds is not spiking.
- A handful of recent users' last actions still succeed.

### Step 5 — Verify after (5-15 min observation)
- Logs free of new ERROR-level entries.
- DB connection count is normal.
- Memory/CPU at expected baseline.
- Sentry / Crashlytics not lighting up.

### Step 6 — Memory update
- `<resolved memoryPath>/changelog.md`: new entry with version, date, summary.
- `<resolved memoryPath>/current.md`: shift forward.
- `<resolved memoryPath>/02-decisions/deploys/<date>.md` for any non-obvious deploy decision.
- Tag the git commit with the version.

### Step 7 — If anything goes wrong
- Stop the deploy immediately (Coolify "Cancel" / `docker compose down` the new stack).
- Promote the previous tagged image back as `current`.
- If migration is the issue, run the down-migration / restoration from backup. Never improvise on a hot DB.
- Document in `03-bugs/<deploy-id>.md` what failed and why.

## Anti-patterns to refuse
- Deploying with red CI
- "Just one small migration during deploy" without backup
- Deploying on Friday afternoon
- Deploying immediately after a security incident without containment
- Skipping the pre-flight to "save time" — you don't save time, you transfer risk
- Deploying with `latest` tag and no version pin

## Output format
```markdown
## Pre-flight
- build: pass
- tests: pass
- typecheck: pass
- lint: pass
- migrations: pending/none/applied
- backup: timestamp
- security review this cycle: yes/no

## Migration plan (if any)
- applies: <files>
- rollback: <command/process>

## Deploy
- target:
- image tag:
- start time:
- end time:

## Post-deploy
- health endpoint: 200
- error rate: baseline
- representative request: ok

## Outcome
- deployed: yes/no
- version:
- rollback executed: yes/no

## Memory
- changelog entry:
- decision file (if any):
```

## Safety rules
- Production deploy is a Risk Gate; explicit user approval required.
- Production DB migration is a HARDER Risk Gate; approval per migration, backup verified.
- Never deploy without a known rollback path.
- Never push a hotfix straight to production without at least running the test suite.
- Rolling back failed deploy is itself a Risk Gate (it may re-introduce an issue the new code fixed). Document why.
- Long deploy plans / runbooks go to `docs/deploys/<system>.md`; chat gets the pre-flight result and outcome.
