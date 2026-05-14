# Windows Install

## Prerequisites

- Windows 10 or 11
- Claude Code installed (https://docs.claude.com/en/docs/claude-code/installation)
- Python 3.10+ on PATH
- Git for Windows installed (includes Git Bash)

## Step 1: Clone the plugin

PowerShell:

```powershell
cd C:\Users\<user>\Desktop
git clone https://github.com/harunyilmazz10/HayeOS.git HayeOS-v3
```

## Step 2: Make Git Bash discoverable

HayeOS hooks use shell scripts. Windows native PowerShell does not run `.sh` files, but Git Bash does. Make `bash` available as a PowerShell alias.

Open PowerShell (regular, not Admin) and run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
Add-Content -Path $PROFILE.CurrentUserAllHosts -Value "Set-Alias -Name bash -Value 'C:\Program Files\Git\bin\bash.exe' -Scope Global"
```

Close PowerShell and open a fresh window. Test:

```powershell
bash --version
```

You should see Git Bash's version. If not, check that Git for Windows is installed at `C:\Program Files\Git\`.

## Step 3: Try the plugin

```powershell
mkdir C:\Users\<user>\Desktop\Projeler\test-v3
cd C:\Users\<user>\Desktop\Projeler\test-v3
claude --plugin-dir C:\Users\<user>\Desktop\HayeOS-v3
```

Inside Claude Code:

```text
/haye:start
```

If HayeOS memory is missing, it asks (in Turkish):

> Bu projede HayeOS hafızası bulunamadı. Şimdi otomatik oluşturayım mı?

Say "evet". HayeOS creates `.hayeos.json` and the project memory vault.

## Step 4: Sanity check

```powershell
Get-Content C:\Users\<user>\Desktop\HayeOS-v3\.claude-plugin\plugin.json | Select-String "version"
# Expected: "version": "3.0.0"

cd C:\Users\<user>\Desktop\HayeOS-v3
bash scripts/verify.sh
# Expected: verification OK
```

## Step 5: Permanent install (optional)

If you want `/haye:start` available in any session without `--plugin-dir`:

```text
claude
/plugin marketplace add C:\Users\<user>\Desktop\HayeOS-v3
/plugin install haye@haye-marketplace
```

Then close and reopen Claude Code.

## Manual fallback commands

Users normally do not need to run `bin/haye` manually, but if `/haye:init-memory` skill fails:

```powershell
cd C:\path\to\project
C:\Users\<user>\Desktop\HayeOS-v3\bin\haye.cmd init
```

Or directly via Python:

```powershell
py -3 C:\Users\<user>\Desktop\HayeOS-v3\bin\haye init
```

## Troubleshooting

### Hook fails with "execvpe(/bin/bash) failed"

`bash` is not on PATH or the PowerShell profile didn't load. Re-run Step 2 and restart PowerShell.

### `/haye:update` fails: "Local changes prevent pull"

```powershell
cd C:\Users\<user>\Desktop\HayeOS-v3
git status
```

Either commit/stash the changes or `git reset --hard origin/main` to discard them.

### Cache shows old skills after update

```powershell
Remove-Item -Path "$env:USERPROFILE\.claude\plugins\cache\*" -Recurse -Force -ErrorAction SilentlyContinue
```

Then restart Claude Code.
