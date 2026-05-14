# Hooks

HayeOS v3.0.0 ships four hooks. Three are required for plugin behavior; one is a gentle reminder.

## SessionStart hook (required)

The most important hook. At session start, it reads `skills/using-hayeos/SKILL.md` and emits its content as `additionalContext` JSON. Claude receives this content as part of the system context at session start, so the discipline rules are visible from message one.

Files (v3.0.0 Superpowers polyglot pattern):
- `hooks/run-hook.cmd` — cross-platform polyglot wrapper. On Windows, cmd.exe runs the batch portion; on Unix, bash interprets it as a shell script (`:` is a no-op in bash, then the script falls through to the `exec bash` line below the `CMDBLOCK` marker).
- `hooks/session-start` — extensionless bash script (uzantısız because Claude Code's Windows runtime auto-prepends `bash` to any `.sh` command, which interferes with the cmd wrapper)
- `hooks/session-start.py` — Python implementation. Called by `session-start` when python is available, or directly by `run-hook.cmd` on Windows.
- `hooks/hooks.json` — Claude Code hook configuration; all hook entries call `run-hook.cmd <script-name>`

### Windows specifics

Claude Code on Windows can invoke `.cmd` files directly but cannot run extensionless or `.sh` files without bash. The `run-hook.cmd` polyglot wrapper handles this: it first tries Python (since HayeOS already requires Python for `bin/haye`), then falls back to Git Bash in standard locations, then bash on PATH.

If neither Python nor Git Bash is installed, the hook silently exits with 0 — the plugin still works, just without SessionStart context injection.

If `bash` is missing on PATH but Git Bash is installed, recommend the user add this to their PowerShell profile:

```powershell
Set-Alias -Name bash -Value 'C:\Program Files\Git\bin\bash.exe' -Scope Global
```

After restart, `bash hooks/session-start` works directly.

## PreToolUse:Bash hook (safety guard)

`hooks/dangerous-command-guard` (extensionless) blocks destructive commands before they execute:

- `rm -rf /`, `rm -rf ~`
- `drop database`, `drop schema`
- `git push --force` to main/master without explicit confirmation
- `chmod -R 777 /`
- Other obvious foot-guns

The hook reads the proposed Bash command on stdin (Claude Code injects it), pattern-matches, and exits non-zero with a Turkish message if matched. Claude sees the failure and stops.

## PreToolUse:Read hook (resource warning)

`hooks/large-file-warning` (extensionless) warns when Claude tries to read very large files (default threshold: 200 KB, ~200000 bytes). It also warns when the read target is under `08-raw/` regardless of size, since raw files should be summarized rather than fully loaded. The hook does not block; it emits a `PreToolUse` `additionalContext` warning so Claude considers using `head`/`grep`/extraction first.

## Stop hook (gentle reminder)

`hooks/session-close-reminder` (extensionless) runs when a session stops. It looks for a `<project>_obs/` vault sibling in the current working directory. If a vault exists but `<vault>/05-sessions/latest-checkpoint.md` does not, it prints a Turkish reminder on stderr suggesting `/haye:close`. Non-blocking — always exits 0.

## Why hooks matter

The SessionStart hook is the load-bearing piece. Without it, Sonnet does not see the `using-hayeos` rules at all - the Iron Law, Red Flags, Mandatory Triggers, all of it is invisible. The plugin's skills are still callable, but they never auto-trigger because Sonnet has no awareness of them.

Test for hook correctness:

```bash
bash hooks/run-hook.cmd session-start | grep "Iron Law"
```

Output should include the Iron Law section content.
