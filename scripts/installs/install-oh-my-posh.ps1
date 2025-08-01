<#
.SYNOPSIS
    Installs Oh My Posh via winget.

.DESCRIPTION
    Uses winget to install the latest version of Oh My Posh.
#>

# Requires: Add-LogMessage already loaded

if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Add-LogMessage -Message "Installing Oh My Posh..." -Level INFO
    winget install JanDeDobbeleer.OhMyPosh -e --source winget
    Add-LogMessage -Message "Oh My Posh installed." -Level SUCCESS
} else {
    Add-LogMessage -Message "Oh My Posh already installed. Skipping." -Level INFO
}