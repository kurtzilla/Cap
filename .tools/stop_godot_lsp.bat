@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0stop_godot_lsp.ps1"
exit /b %errorlevel%
