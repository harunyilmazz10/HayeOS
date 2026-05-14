# Monitor: Next.js Dev Server Log

Capture `next dev` output during a local reproduction. Use when an error only appears in dev (HMR, RSC boundary, middleware).

## Capture
```bash
# Run with output to both screen and file
npm run dev 2>&1 | tee /tmp/nextjs-dev.log

# OR if you only want errors and warnings
npm run dev 2>&1 | grep -E '(error|warn|fail|✗)' | tee /tmp/nextjs-dev-errors.log
```

## Reproduce, then save
```bash
DATE=$(date -u +%Y-%m-%d)
SHORT="nextjs-dev-<short-symptom>"
mv /tmp/nextjs-dev.log "<resolved memoryPath>/08-raw/nextjs-dev/${DATE}-${SHORT}.log"
```

## What to look for in the log
- "You're importing a component that needs ..." -> RSC boundary issue
- "Hydration failed" -> server/client mismatch
- "Module not found" -> import path or tsconfig paths drift
- Repeated full-page reloads -> HMR break; check the file changed

## Ingest
- Invoke `Skill(haye:systematic-debugging)` against the saved file path; Phase 1 isolates the failing route, the failing component, and the exact error message.
- Output: `03-bugs/open/nextjs-<topic>.md` with repro steps and root cause hypothesis.
- During `/haye:close`, reference the bug entry in the session changelog.

## What NOT to capture
- `next dev` startup output when nothing's wrong
- Full sessions over 10 MB — extract the failing window
