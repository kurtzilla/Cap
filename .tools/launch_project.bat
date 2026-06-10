@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Double-click runs a hidden inner instance so no launcher window stays open.
if /i not "%~1"=="_inner" (
  powershell -NoProfile -WindowStyle Hidden -Command ^
    "Start-Process -FilePath '%~f0' -ArgumentList '_inner' -WindowStyle Hidden"
  exit /b 0
)

for %%I in ("%~dp0..") do set "REPO=%%~fI"
set "CURSOR_EXE=%LOCALAPPDATA%\Programs\cursor\Cursor.exe"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start_godot_lsp.ps1"
if errorlevel 1 exit /b 1

if exist "%CURSOR_EXE%" (
  echo [Launch] Opening Cursor workspace...
  start "" "%CURSOR_EXE%" -r "%REPO%"
) else (
  echo [Launch] Cursor not found in LocalAppData, using PATH fallback...
  start "" cmd /c "cursor -r "%REPO%""
)

endlocal
exit /b 0
