<#
.SYNOPSIS
    Installs Windows Terminal and links settings.json from ZenWin config.

.DESCRIPTION
    Uses winget to install Windows Terminal if not already installed.
    Then symlinks the settings.json from ~/.zenwin/.config/windows-terminal
    to the official LocalState path used by Windows Terminal.
#>

# Requires: Add-LogMessage already imported

$ErrorActionPreference = "Stop"

# Paths
$officialSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$zenwinConfigPath     = "$env:USERPROFILE\.zenwin\.config\windows-terminal\settings.json"

# Install Windows Terminal
if (-not (Get-Command wt.exe -ErrorAction SilentlyContinue)) {
    Add-LogMessage -Message "Installing Windows Terminal via winget..." -Level INFO
    winget install --id Microsoft.WindowsTerminal -e --source winget
    Add-LogMessage -Message "Windows Terminal installed." -Level SUCCESS
} else {
    Add-LogMessage -Message "Windows Terminal already installed. Skipping." -Level INFO
}

# Ensure source config exists
if (-not (Test-Path $zenwinConfigPath)) {
    Add-LogMessage -Message "Missing ZenWin config at $zenwinConfigPath" -Level ERROR
    exit 1
}

# Create LocalState folder if needed
$localStateFolder = Split-Path $officialSettingsPath
if (-not (Test-Path $localStateFolder)) {
    New-Item -ItemType Directory -Path $localStateFolder -Force | Out-Null
}

# Backup old config if it exists
if (Test-Path $officialSettingsPath) {
    Copy-Item -Path $officialSettingsPath -Destination "$officialSettingsPath.bak" -Force
    Remove-Item -Path $officialSettingsPath -Force
}

# Symlink the settings file
New-Item -ItemType SymbolicLink -Path $officialSettingsPath -Target $zenwinConfigPath -Force | Out-Null
Add-LogMessage -Message "Linked settings.json to Windows Terminal config." -Level SUCCESS
