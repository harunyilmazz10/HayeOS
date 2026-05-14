# HayeOS Monitors

Optional log/process monitor *recipes*. These are NOT activated by default — they describe how a user can pipe logs from common Haye-stack processes into the HayeOS vault for later inspection during /haye:close or systematic-debugging.

## Why off by default
Live log monitoring is a token-cost trap. Most sessions don't need it. When something is actually misbehaving, follow the recipe for that source, capture only the failing window, and let `/haye:close` skill summarize what was useful.

## What's here
- `coolify-build-log.md` — capture a single Coolify build's log into `08-raw/`
- `docker-log.md` — capture `docker logs` for a specific container/window
- `nextjs-dev-log.md` — capture local `next dev` output during a repro

## Pattern (all recipes)
1. Reproduce the issue with logging enabled
2. Save the captured window to `<resolved memoryPath>/08-raw/<source>/<YYYY-MM-DD>-<short-name>.log`
3. Summarize relevant lines into `<resolved memoryPath>/02-decisions/` or `<resolved memoryPath>/03-bugs/` as needed (do not load the raw file fully into chat)
4. Archive the raw file to `08-raw/processed/`

## Adding a new monitor
- Create a `.md` file here named `<source>.md` describing the capture command and window size
- Keep it short; this is a recipe, not a doc
- If the monitor produces structured data (JSON), name the directory `<source>/` and document the schema
