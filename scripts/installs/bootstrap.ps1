<#
.SYNOPSIS
    Entry-point bootstrap script for ZenWin setup

.DESCRIPTION
    Coordinates all modular install steps in order, with centralized logging and error handling.
#>

function Get-GitRepoRoot {
    $gitRoot = git -C $PSScriptRoot rev-parse --show-toplevel 2>$null
    if (-not $gitRoot) {
        throw "Unable to determine Git repository root. Are you inside a Git repo?"
    }
    return $gitRoot
}

# Set a consistent root path for the ZenWin repo
$Global:ZenWinRoot = Get-GitRepoRoot

# Enable strict error handling
$ErrorActionPreference = "Stop"

# Set up log file path relative to ZenWin project
$LogDir = "$ZenWinRoot\logs"
$Global:ZenWinLogFile = Join-Path $LogDir "zenwin-install.log"

# Ensure log folder exists
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Import logging utility
. (Join-Path $ZenWinRoot 'scripts' 'utilities' 'Add-LogMessage.ps1')

Add-LogMessage -Message "Starting ZenWin installation." -Level INFO