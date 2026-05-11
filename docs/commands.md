# Commands

## Simple

The simple command layer stays user-facing and routes to advanced skills instead of replacing them.

- `/haye:start` -> `start`, `memory-start`, `project-map`, `token-audit`
- `/haye:init-memory` -> `init-memory`
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

## Memory initialization

Users normally do not need to run `bin/haye` manually. After the global plugin is installed, `/haye:start` is enough in each project.

If `.hayeos.json` or the Obsidian vault is missing, `/haye:start` asks in Turkish:

```text
Bu projede Haye hafızası bulunamadı. Şimdi otomatik oluşturayım mı?
```

If approved, Haye runs the `/haye:init-memory` flow. That flow tries `${CLAUDE_PLUGIN_ROOT}` based CLI commands first and falls back to creating `.hayeos.json` and the vault files directly when CLI execution is unavailable.

On Windows, manual fallback commands are:

```text
C:\Users\hayed\Desktop\HayeOS\bin\haye.cmd init
powershell -ExecutionPolicy Bypass -File C:\Users\hayed\Desktop\HayeOS\bin\haye.ps1 init
```
