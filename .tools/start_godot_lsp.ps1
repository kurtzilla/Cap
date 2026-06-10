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

function Test-LspTcpReady {
    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $async = $client.BeginConnect("127.0.0.1", $Port, $null, $null)
        $ready = $async.AsyncWaitHandle.WaitOne(500)
        if (-not $ready) {
            return $false
        }
        $client.EndConnect($async)
        return $true
    }
    catch {
        return $false
    }
    finally {
        $client.Close()
    }
}

function Wait-LspReady {
    param([int]$ProcessId)

    $deadline = (Get-Date).AddSeconds(45)
    while ((Get-Date) -lt $deadline) {
        if (Test-LspProcess -ProcessId $ProcessId) {
            if (Test-LspTcpReady) {
                Start-Sleep -Milliseconds 500
                if (Test-LspTcpReady) {
                    return $true
                }
            }
        }
        Start-Sleep -Milliseconds 250
    }

    return $false
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

if (Wait-LspReady -ProcessId $proc.Id) {
    Write-Host "[Launch] Godot LSP ready (pid $($proc.Id))."
    return $proc.Id
}

Write-Error "Godot LSP failed to bind port $Port within 45 seconds."
