$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$hayeScript = Join-Path $scriptDir "haye"

function Invoke-HayePython {
    param(
        [string]$CommandName,
        [string[]]$CliArgs
    )

    $cmd = Get-Command $CommandName -ErrorAction SilentlyContinue
    if (-not $cmd) {
        return $false
    }

    & $cmd.Source $hayeScript @CliArgs
    exit $LASTEXITCODE
}

if (Invoke-HayePython "python" $args) {
    exit $LASTEXITCODE
}

if (Invoke-HayePython "py" $args) {
    exit $LASTEXITCODE
}

Write-Error "Python bulunamadı. Lütfen Python kurun veya PATH'e ekleyin."
exit 1
