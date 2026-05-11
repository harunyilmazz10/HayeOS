@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
set "HAYE_SCRIPT=%SCRIPT_DIR%haye"

where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
  python "%HAYE_SCRIPT%" %*
  exit /b %ERRORLEVEL%
)

where py >nul 2>nul
if %ERRORLEVEL% EQU 0 (
  py "%HAYE_SCRIPT%" %*
  exit /b %ERRORLEVEL%
)

echo Python bulunamadı. Lütfen Python kurun veya PATH'e ekleyin.
exit /b 1
