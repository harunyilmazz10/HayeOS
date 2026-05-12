# HayeOS Monitors

Optional log/process monitor *recipes*. These are NOT activated by default — they describe how a user can pipe logs from common Haye-stack processes into the HayeOS vault for later ingestion via the `ingest-session` skill.

## Why off by default
Live log monitoring is a token-cost trap. Most sessions don't need it. When something is actually misbehaving, follow the recipe for that source, capture only the failing window, and let `ingest-session` summarize what was useful.

## What's here
- `coolify-build-log.md` — capture a single Coolify build's log into `08-raw/`
- `docker-log.md` — capture `docker logs` for a specific container/window
- `nextjs-dev-log.md` — capture local `next dev` output during a repro

## Pattern (all recipes)
1. Reproduce the issue with logging enabled
2. Save the captured window to `<resolved memoryPath>/08-raw/<source>/<YYYY-MM-DD>-<short-name>.log`
3. Run the `ingest-session` skill against that file to extract decisions / bugs / risks
4. Archive the raw file to `08-raw/processed/`

## Adding a new monitor
- Create a `.md` file here named `<source>.md` describing the capture command and window size
- Keep it short; this is a recipe, not a doc
- If the monitor produces structured data (JSON), name the directory `<source>/` and document the schema
