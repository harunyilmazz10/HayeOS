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
- Run `ingest-session` skill against the saved file
- It extracts: failing step, dependency that broke, env mismatch
- Output: `02-decisions/coolify-<topic>.md` or `03-bugs/open/coolify-<topic>.md`

## What to capture
- First failing line + 20 lines before
- The last 30 lines (often contains the error summary)
- The environment block at the top (shows env vars, build pack)

## What NOT to capture
- Successful builds in their entirety; only the build that failed
- Logs containing secrets (Coolify usually masks but verify)
