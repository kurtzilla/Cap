# Track Cursor/VS Code session for LSP tooling. LSP is left running between editor sessions.
param(
    [int]$EditorPid = 0
)

$ErrorActionPreference = "Stop"

$repo = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$watchPidFile = Join-Path $repo ".tools\godot-lsp-watch.pid"

if ($EditorPid -le 0 -and $env:VSCODE_PID -match '^\d+$') {
    $EditorPid = [int]$env:VSCODE_PID
}

if ($EditorPid -le 0) {
    Write-Warning "[LSP Watch] Editor PID not available; watch task exiting."
    exit 0
}

if (Test-Path -LiteralPath $watchPidFile) {
    $previousWatchPid = (Get-Content -LiteralPath $watchPidFile -Raw).Trim()
    if ($previousWatchPid -match '^\d+$') {
        Stop-Process -Id ([int]$previousWatchPid) -Force -ErrorAction SilentlyContinue
    }
}

Set-Content -LiteralPath $watchPidFile -Value $PID -NoNewline

try {
    Write-Host "[LSP Watch] Godot LSP will stay running after Cursor closes (pid $EditorPid)."
    while (Get-Process -Id $EditorPid -ErrorAction SilentlyContinue) {
        Start-Sleep -Seconds 2
    }
}
finally {
    Remove-Item -LiteralPath $watchPidFile -Force -ErrorAction SilentlyContinue
}
