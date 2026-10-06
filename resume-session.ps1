#Requires -Version 5.1
<#
.SYNOPSIS
Setzt die Codex-Sitzung dieses Godot-Projekts fort.
.EXAMPLE
.\resume-session.ps1
.EXAMPLE
.\resume-session.ps1 -Last
#>
[CmdletBinding()]
param(
    [string]$SessionId = '01a11032-c9e8-7ae0-9af1-9fd17a7789ca',
    [switch]$Last
)

$ErrorActionPreference = 'Stop'
$codexCommand = Get-Command codex -ErrorAction SilentlyContinue
if (-not $codexCommand) {
    throw 'Codex wurde nicht im PATH gefunden. Installiere die Codex CLI oder starte dieses Skript in einem Terminal, in dem codex verfuegbar ist.'
}

Push-Location -LiteralPath $PSScriptRoot
try {
    if ($Last) {
        & $codexCommand.Source resume --last --cd $PSScriptRoot
    } else {
        if ([string]::IsNullOrWhiteSpace($SessionId)) {
            throw 'SessionId darf nicht leer sein.'
        }
        & $codexCommand.Source resume $SessionId --cd $PSScriptRoot
    }
    $resumeExitCode = $LASTEXITCODE
} finally {
    Pop-Location
}
exit $resumeExitCode
