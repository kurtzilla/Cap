# Start (or reuse) the headless Godot LSP for this repo. Writes .tools/godot-lsp.pid.
param(
    [int]$Port = 6007
)

$ErrorActionPreference = "Stop"

$repo = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$projectPath = Join-Path $repo "src\Godot"
$pidFile = Join-Path $repo ".tools\godot-lsp.pid"

. (Join-Path $PSScriptRoot "find_godot.ps1")
$godot = Get-GodotExe
if (-not $godot) {
    Write-Error "Godot 4 C# not found. Set godotTools.editorPath.godot4 in .vscode/settings.json or install via gdvm."
}

function Test-LspProcess {
    param([int]$ProcessId)

    if (-not (Get-Process -Id $ProcessId -ErrorAction SilentlyContinue)) {
        return $false
    }

    return [bool](Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue |
        Where-Object { $_.OwningProcess -eq $ProcessId } |
        Select-Object -First 1)
}

if (Test-Path -LiteralPath $pidFile) {
    $existingPid = [int](Get-Content -LiteralPath $pidFile -Raw).Trim()
    if (Test-LspProcess -ProcessId $existingPid) {
        Write-Host "[Launch] Godot LSP already running on port $Port (pid $existingPid)."
        return $existingPid
    }
    Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
}

Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue |
ForEach-Object {
    Write-Host "[Launch] Stopping stale process on port $Port (pid $($_.OwningProcess))..."
    Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue
}

Write-Host "[Launch] Starting Godot headless LSP on port $Port..."
$proc = Start-Process -FilePath $godot `
    -ArgumentList @("--path", $projectPath, "--editor", "--headless", "--lsp-port", "$Port") `
    -WindowStyle Hidden `
    -PassThru

Set-Content -LiteralPath $pidFile -Value $proc.Id -NoNewline

$deadline = (Get-Date).AddSeconds(15)
while ((Get-Date) -lt $deadline) {
    if (Test-LspProcess -ProcessId $proc.Id) {
        Write-Host "[Launch] Godot LSP ready (pid $($proc.Id))."
        return $proc.Id
    }
    Start-Sleep -Milliseconds 250
}

Write-Error "Godot LSP failed to bind port $Port within 15 seconds."
