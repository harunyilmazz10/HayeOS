@echo off
REM Windows wrapper for HayeOS SessionStart hook.
REM Tries Python first (works without Git Bash), falls back to bash if available.

setlocal
set "SCRIPT_DIR=%~dp0"
set "HOOK_SH=%SCRIPT_DIR%session-start.sh"
set "HOOK_PY=%SCRIPT_DIR%session-start.py"

REM Try Python (preferred on Windows since Python is required by HayeOS CLI)
where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    if exist "%HOOK_PY%" (
        python "%HOOK_PY%"
        exit /b %ERRORLEVEL%
    )
)

where py >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    if exist "%HOOK_PY%" (
        py "%HOOK_PY%"
        exit /b %ERRORLEVEL%
    )
)

REM Try Git Bash
if exist "C:\Program Files\Git\bin\bash.exe" (
    "C:\Program Files\Git\bin\bash.exe" "%HOOK_SH%"
    exit /b %ERRORLEVEL%
)

if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    "C:\Program Files (x86)\Git\bin\bash.exe" "%HOOK_SH%"
    exit /b %ERRORLEVEL%
)

REM Try bash on PATH
where bash >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    bash "%HOOK_SH%"
    exit /b %ERRORLEVEL%
)

REM No shell or Python - emit empty hook output, plugin still works without context injection
echo {"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":""}}
exit /b 0
