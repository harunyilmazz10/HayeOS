# Commands

## Simple

The simple command layer stays user-facing and routes to advanced skills instead of replacing them.

- `/haye:start` -> `start`, `memory-start`, `project-map`, `token-audit`
- `/haye:work` -> `work`, `context-pack`, `feature`, `refactor`, `api-integration`, `migration`, `test-plan`
- `/haye:fix` -> `fix`, `bugfix`, `nextjs-doctor`, `prisma-doctor`, `docker-doctor`, `coolify-doctor`, `cloudflare-doctor`, `database-doctor`
- `/haye:secure` -> `secure`, `security`, `dependency-security`, `dependency-audit`, `version-policy`, `react-nextjs-security`, `secrets-audit`, `auth-audit`, `exposed-port-audit`
- `/haye:ship` -> `ship`, `deploy`, `review`, `security`, `dependency-security`, `cloudflare-doctor`, `coolify-doctor`, `docker-doctor`
- `/haye:close` -> `close`, `session-close`, `memory-lint`, `token-audit`

## Advanced

Use detailed skills directly when the request is already specific. The simple commands are convenience routers for daily use.

## Configuration

Commands inspect `.hayeos.json` first:

- `memoryPath` points to the Obsidian vault.
- `sourcePath` points to the source tree for package/security checks.
- `riskLevel`, `defaultWorkflow`, `sessionCloseRequired` and `rawReadPolicy` guide workflow strictness.

Do not read `08-raw/` unless the user asks or a context pack names specific raw files.
