@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
set "HAYE_SCRIPT=%SCRIPT_DIR%haye"

set "PYTHONUNBUFFERED=1"
set "PYTHONIOENCODING=utf-8"

where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
  python -u "%HAYE_SCRIPT%" %*
  exit /b %ERRORLEVEL%
)

where py >nul 2>nul
if %ERRORLEVEL% EQU 0 (
  py -u "%HAYE_SCRIPT%" %*
  exit /b %ERRORLEVEL%
)

echo Python bulunamadı. Lütfen Python kurun veya PATH'e ekleyin.
exit /b 1
