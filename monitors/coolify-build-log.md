# Monitor: Coolify Build Log

Capture a single Coolify deploy/build for offline analysis. Off by default — turn on only when investigating a build failure.

## Capture
Coolify exposes build logs in the UI; for terminal capture, SSH to the Coolify host:

```bash
# Find the latest deployment ID for the app
docker ps --filter "label=coolify.applicationName=<app-slug>" --format "{{.ID}} {{.Names}}"

# Capture the last build log (Coolify writes it to /data/coolify/applications/<id>/logs/)
ssh coolify-host "tail -n 2000 /data/coolify/applications/<app-id>/logs/build-<deploy-id>.log" \
  > /tmp/coolify-build.log
```

## Save to vault
```bash
DATE=$(date -u +%Y-%m-%d)
SHORT="coolify-build-<app>-<short-symptom>"
mv /tmp/coolify-build.log "<resolved memoryPath>/08-raw/coolify-builds/${DATE}-${SHORT}.log"
```

## Ingest
- Invoke `Skill(haye:systematic-debugging)` against the saved file path; Phase 1 (Root Cause Investigation) reads the failing step, the dependency that broke, and any env mismatch.
- Write findings as a structured entry: `02-decisions/coolify-<topic>.md` (architectural decision) or `03-bugs/open/coolify-<topic>.md` (active bug).
- During `/haye:close`, mention the new vault entries in the session changelog.

## What to capture
- First failing line + 20 lines before
- The last 30 lines (often contains the error summary)
- The environment block at the top (shows env vars, build pack)

## What NOT to capture
- Successful builds in their entirety; only the build that failed
- Logs containing secrets (Coolify usually masks but verify)
