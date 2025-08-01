<#
.SYNOPSIS
    Installs PowerShell 7+ using winget and prepares ZenWin config.

.DESCRIPTION
    Checks for `pwsh.exe` (PowerShell Core). Installs it via winget if not found.
    Optionally prepares the profile.ps1 dotfile from ZenWin's config directory.

#>

# Requires: Add-LogMessage already imported

$ErrorActionPreference = "Stop"

# Paths
$pwshPath = (Get-Command pwsh.exe -ErrorAction SilentlyContinue)?.Source
$zenwinProfilePath = "$env:USERPROFILE\.zenwin\.config\powershell\profile.ps1"
$targetProfileDir = "$env:USERPROFILE\Documents\PowerShell"
$targetProfilePath = Join-Path $targetProfileDir "Microsoft.PowerShell_profile.ps1"

# Install pwsh if needed
if (-not $pwshPath) {
    Add-LogMessage -Message "Installing PowerShell via winget..." -Level INFO
    winget install --id Microsoft.PowerShell -e --source winget
    Add-LogMessage -Message "PowerShell installed." -Level SUCCESS
} else {
    Add-LogMessage -Message "PowerShell already installed at $pwshPath" -Level INFO
}

# Ensure config folder exists
if (-not (Test-Path $targetProfileDir)) {
    New-Item -ItemType Directory -Path $targetProfileDir -Force | Out-Null
}

# Apply ZenWin profile if it exists
if (Test-Path $zenwinProfilePath) {
    if (Test-Path $targetProfilePath) {
        Copy-Item -Path $targetProfilePath -Destination "$targetProfilePath.bak" -Force
        Remove-Item -Path $targetProfilePath -Force
    }

    New-Item -ItemType SymbolicLink -Path $targetProfilePath -Target $zenwinProfilePath -Force | Out-Null
    Add-LogMessage -Message "Linked ZenWin PowerShell profile to $targetProfilePath" -Level SUCCESS
} else {
    Add-LogMessage -Message "No ZenWin PowerShell profile found at $zenwinProfilePath" -Level WARNING
}
