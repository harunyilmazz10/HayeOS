# Monitor: Docker Container Log

Capture `docker logs` output for a specific container window. Use when a runtime error is suspected.

## Capture
```bash
# List containers and find the suspect
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"

# Capture last N lines + tail follow until you reproduce
docker logs --tail 500 --timestamps <container-name> > /tmp/docker-window.log 2>&1

# OR continuous capture during a repro
docker logs --since 1m --follow --timestamps <container-name> > /tmp/docker-window.log 2>&1 &
PID=$!
# ... reproduce issue ...
kill $PID
```

## Save to vault
```bash
DATE=$(date -u +%Y-%m-%d)
SHORT="docker-<service>-<short-symptom>"
mv /tmp/docker-window.log "<resolved memoryPath>/08-raw/docker/${DATE}-${SHORT}.log"
```

## Ingest
- `ingest-session` extracts: stack trace, repeated error pattern, restart loop indicators
- Output: `03-bugs/` entry with repro and root cause hypothesis

## Tips
- Use `--timestamps` to correlate with frontend errors / user reports
- Use `--since` (not `--tail`) when investigating a specific time window
- For a service in Docker Compose: `docker compose logs --since 1m <service>`

## What NOT to capture
- Logs from healthy containers — wastes vault space
- Logs containing PII or secrets — redact before saving
