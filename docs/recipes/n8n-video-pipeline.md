# Recipe: n8n + Video Pipeline

Combines `n8n-pipeline` and `video-factory` skills.

## Pattern
- n8n is the orchestrator; the actual heavy compute (Wan2.1, ffmpeg) lives in dedicated services.
- n8n calls HTTP endpoints; doesn't run ffmpeg inside Function nodes.

## Workflow shape
- Trigger (cron / webhook) → Validate input → Sub-workflow per pipeline stage → Aggregate → Notify
- Each sub-workflow is independently testable

## Credentials
- `wan21-render-prod`, `r2-storage-prod`, `youtube-data-prod` per environment
- All in n8n Credentials store, never inline

## Idempotency
- Each pipeline run has a `run_id`; sub-workflows accept it and write outputs to `runs/<run_id>/<stage>`
- Re-run a stage = overwrite that specific path; downstream re-reads

## Error path
- Error Trigger workflow logs failure to DB + posts to Telegram/Slack
- Workflow status set so dashboard reflects it

## Scaling
- Multiple worker workflows can process the queue in parallel
- Per-account rate limits enforced at the publish stage (1/day LinkedIn, etc.)

## Coolify-hosted n8n notes
- Persistent volume at `/home/node/.n8n`
- External Postgres (not SQLite) for production
- `WEBHOOK_URL` set to public HTTPS endpoint

## Common breakage
- n8n executions DB bloats → enable `EXECUTIONS_DATA_PRUNE`
- Encryption key rotation → all credentials become unreadable
- Big binary data through every node → memory blowup; pass URLs only

## When to escalate
- Workflow design → `n8n-pipeline` skill
- Render pipeline → `video-factory` skill
