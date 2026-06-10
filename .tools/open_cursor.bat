@echo off

setlocal EnableExtensions EnableDelayedExpansion



rem Desktop shortcut launcher: pre-warm Godot LSP then open Cursor (restores last session).

rem Double-click runs a hidden inner instance so no launcher window stays open.

if /i not "%~1"=="_inner" (

  powershell -NoProfile -WindowStyle Hidden -Command ^

    "Start-Process -FilePath '%~f0' -ArgumentList '_inner' -WindowStyle Hidden"

  exit /b 0

)



set "CURSOR_EXE=%LOCALAPPDATA%\Programs\cursor\Cursor.exe"



powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start_godot_lsp.ps1"

if errorlevel 1 exit /b 1



if exist "%CURSOR_EXE%" (

  echo [Launch] Opening Cursor...

  start "" "%CURSOR_EXE%"

) else (

  echo [Launch] Cursor not found in LocalAppData, using PATH fallback...

  start "" cmd /c "cursor"

)



endlocal

exit /b 0

