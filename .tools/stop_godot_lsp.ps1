# Stop the headless Godot LSP started by launch_project.bat.
param(
    [int]$Port = 6007
)

$ErrorActionPreference = "Stop"

$repo = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$pidFile = Join-Path $repo ".tools\godot-lsp.pid"
$watchPidFile = Join-Path $repo ".tools\godot-lsp-watch.pid"

if (Test-Path -LiteralPath $watchPidFile) {
    $watchPid = (Get-Content -LiteralPath $watchPidFile -Raw).Trim()
    if ($watchPid -match '^\d+$') {
        Stop-Process -Id ([int]$watchPid) -Force -ErrorAction SilentlyContinue
    }
    Remove-Item -LiteralPath $watchPidFile -Force -ErrorAction SilentlyContinue
}

if (Test-Path -LiteralPath $pidFile) {
    $existingPid = (Get-Content -LiteralPath $pidFile -Raw).Trim()
    if ($existingPid -match '^\d+$') {
        Write-Host "[Stop] Stopping Godot LSP pid $existingPid..."
        Stop-Process -Id ([int]$existingPid) -Force -ErrorAction SilentlyContinue
    }
    Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
}

Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue |
    ForEach-Object {
        Write-Host "[Stop] Stopping process on port $Port (pid $($_.OwningProcess))..."
        Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue
    }

Write-Host "[Stop] Godot LSP stopped."
