@echo off
where pwsh >nul 2>&1
if errorlevel 1 (
  echo PowerShell 7 ^(pwsh^) is required to run template smoke tests.
  exit /b 1
)
pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0Test-Templates.ps1" %*
exit /b %ERRORLEVEL%
