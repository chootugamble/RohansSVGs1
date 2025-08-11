@echo off
echo Running SVG ID Update Script...
echo.

REM Run the PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "%~dp0run.ps1"

echo.
echo Script execution completed.
echo Press any key to close this window...
pause >nul
