# Run game window in Godot 4.6 .NET. Use when F5 debug does not spawn Godot.
param(
    [switch]$DebugServer,
    [switch]$ForDebugger
)

$ErrorActionPreference = "Stop"

function Set-CapGodotDebugPid {
    param(
        [string]$RepoRoot,
        [int]$ProcessId
    )

    $settingsPath = Join-Path $RepoRoot ".vscode\settings.json"
    $pidFile = Join-Path $RepoRoot ".vscode\godot-debug.pid"
    Set-Content -LiteralPath $pidFile -Value $ProcessId -NoNewline

    $content = Get-Content -LiteralPath $settingsPath -Raw
    if ($content -match '"cap\.godotDebugPid"\s*:') {
        $content = [regex]::Replace($content, '"cap\.godotDebugPid"\s*:\s*\d+', "`"cap.godotDebugPid`": $ProcessId")
    }
    else {
        $content = [regex]::Replace(
            $content,
            '("cap\.godotProcessName"\s*:\s*"[^"]+"\s*,)',
            "`$1`r`n  `"cap.godotDebugPid`": $ProcessId,"
        )
    }
    Set-Content -LiteralPath $settingsPath -Value $content -NoNewline
}

# Dynamically resolve absolute repo workspace root
$repo = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

# Include the custom Godot location helper utility
. (Join-Path $PSScriptRoot "find_godot.ps1")

$godot = Get-GodotExe
if (-not $godot) {
    Write-Error "Godot 4 C# not found. Set godotTools.editorPath.godot4 in .vscode/settings.json or install via gdvm."
}

# The decoupled game files sit under src/Godot relative to the root path
$projectPath = Join-Path $repo "src\Godot"

# Direct Godot precisely to the subfolder containing the project.godot file
$args = @("--path", $projectPath)
if ($DebugServer) {
    $args += "--debug-server", "6007"
}

if ($ForDebugger) {
    $proc = Start-Process -FilePath $godot -ArgumentList $args -WorkingDirectory $projectPath -PassThru
    $deadline = (Get-Date).AddSeconds(15)
    while ((Get-Date) -lt $deadline) {
        if (-not (Get-Process -Id $proc.Id -ErrorAction SilentlyContinue)) {
            Write-Error "Godot exited before the debugger could attach (pid $($proc.Id))."
        }
        try {
            $proc.Refresh()
            if ($proc.MainWindowHandle -ne [IntPtr]::Zero -or $proc.Responding) {
                break
            }
        }
        catch {
            break
        }
        Start-Sleep -Milliseconds 200
    }
    Write-Host "Godot debugger ready: pid $($proc.Id)"
    Set-CapGodotDebugPid -RepoRoot $repo -ProcessId $proc.Id
    return
}

Write-Host "Starting: $godot $($args -join ' ')"
& $godot @args
