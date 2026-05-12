---
name: n8n-pipeline
description: Use when building, reviewing, or hardening n8n workflows - credentials, error branches, retries, webhooks, idempotency, observability, Coolify-hosted n8n
---

# Haye Skill: n8n-pipeline

## Purpose
Build or harden n8n workflows. Common in the Haye stack as the glue between scraping, scoring, generation and publishing. This skill applies to self-hosted n8n on Coolify/Hetzner.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa açıklamalar Türkçe verilir.

## Inputs to inspect first
1. n8n workflow JSON (export or the file in `workflows/`).
2. Trigger type: webhook, schedule, manual, event.
3. Credentials in use (names, not values).
4. External services it touches (HTTP nodes, DB nodes, Function code).
5. Error handling: is there an "Error Trigger" workflow?

## Core design rules

### Workflow shape
- Single responsibility per workflow; if a workflow does both ingest and publish, split.
- Trigger → small validation node → main logic → success path → error path.
- Use **sub-workflows** for reusable logic; do not copy-paste 30-node chunks.

### Credentials
- Never paste API keys into HTTP node URLs or Function nodes — always via the Credentials store.
- Credential names follow a convention: `<service>-<env>` (e.g., `openai-prod`, `stripe-test`).
- For self-hosted n8n: encryption key set (`N8N_ENCRYPTION_KEY` env) before adding credentials; if it changes, all stored creds become unreadable.
- Rotate credentials when an editor with broad access leaves.

### Webhooks (incoming)
- Path: predictable but not guessable (`/webhook/customer-event/abc123` with a long random segment).
- For production: use Production URL, not Test URL.
- Signature verification node (Function or HTTP Request response check) before doing anything.
- Reply quickly: webhook handler returns 200 within 5–10 seconds. Heavy work goes into a queue → separate worker workflow.

### Retries and idempotency
- HTTP Request nodes: enable "Retry On Fail" with 3 attempts, exponential backoff.
- Make calls idempotent: external API supports `Idempotency-Key` → set it from `$workflow.id + $execution.id + node name`.
- Database writes: use upserts where possible; raw `INSERT` will fail loudly on retry.
- Mark "non-retryable" errors (4xx other than 429) and stop instead of looping.

### Error handling
- Set "On Error" → "Continue (using error output)" for nodes where you want to handle the failure inline.
- One Error Trigger workflow that catches everything else: log to a DB table, notify Slack/Telegram, do not retry the whole chain.
- Capture: workflow name, execution id, failing node, error message, input data (truncated, redacted).

### Performance / cost
- Use "Split In Batches" for large item arrays; do not push thousands of items through a paid API in one execution.
- Cache where possible (e.g., a "lookup" node that hits an internal DB before calling an external API).
- Watch executions log size; long item arrays in successful runs bloat the DB. Set `EXECUTIONS_DATA_PRUNE=true` and `EXECUTIONS_DATA_MAX_AGE`.

### Observability
- Workflow tags: `production`, `staging`, `experimental` — used in filters and metrics.
- Add a final "Log" node that writes `(workflow, status, items_processed, duration_ms)` to your own metrics DB.
- Health check: a separate "Heartbeat" workflow runs every 5 minutes, posts to a status page. If it stops, you know n8n itself is down.

### Coolify-hosted n8n specifics
- Persistent volume MUST be mounted at `/home/node/.n8n` — losing it loses credentials and workflows.
- Database: prefer external Postgres over SQLite for production; SQLite locks under concurrency.
- Set `WEBHOOK_URL` to the public HTTPS URL; otherwise webhook nodes show wrong URLs in the UI.
- Use Traefik labels for routing; don't host n8n on the same domain as other apps with conflicting cookies.

## Common pitfalls
- "It works in the editor but not on schedule" → Manual trigger preserves credentials from your session; Schedule trigger needs everything set in the workflow.
- Webhook URL "test" vs "production" — workflows only respond on production after `Save` and activation.
- Function node with `setTimeout` / `Promise.race` → not supported reliably; use a Wait node.
- Big binary data flowing through every node → memory blowup; offload to S3/R2 and pass only the URL.
- Updating an active workflow without snapshotting → can't roll back.

## Output format
```markdown
## Workflow review
- trigger:
- nodes count:
- sub-workflows:
- error path: present / missing
- retries: configured / missing
- credentials: ok / leaked / missing

## Findings
- correctness:
- safety (credentials, idempotency):
- performance:

## Recommended next 3
- smallest fix first

## Verification
- one manual run with sample input
- error path tested with intentional failure
- webhook signature verified
```

## Safety rules
- Don't edit an active production workflow live; clone, edit, deactivate old, activate new.
- Don't store credentials in workflow JSON exports; n8n redacts them, but verify.
- Activating a workflow that posts to external APIs is a Cost/Risk Gate; require approval.
- Webhook URLs are secrets in practice; treat them like API endpoints, not public docs.
- Long workflow specs and node diagrams go to `docs/n8n/<workflow-name>.md`; chat gets the summary.
