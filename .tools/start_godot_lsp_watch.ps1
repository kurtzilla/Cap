# Detached launcher for godot_lsp_watch.ps1 (avoids nested shell quoting in VS Code tasks).
param(
    [int]$EditorPid = 0
)

$ErrorActionPreference = "Stop"

if ($EditorPid -le 0 -and $env:VSCODE_PID -match '^\d+$') {
    $EditorPid = [int]$env:VSCODE_PID
}

$watchScript = Join-Path $PSScriptRoot "godot_lsp_watch.ps1"
$argumentList = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", $watchScript
)

if ($EditorPid -gt 0) {
    $argumentList += @("-EditorPid", "$EditorPid")
}

Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -ArgumentList $argumentList
