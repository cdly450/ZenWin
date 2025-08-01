<#
.SYNOPSIS
    Installs Git for Windows using winget, if not already installed.

.DESCRIPTION
    This script checks whether Git is installed and installs it using winget if needed.
    Designed for clean Windows setups using ZenWin.

.NOTES
    Author: Craig Dempsey
    License: MIT
#>

# Enable strict error handling
$ErrorActionPreference = "Stop"

# Check for winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "`n❌ winget is not available on this system.`n"
    Write-Host "➡️  Please install 'App Installer' from the Microsoft Store:"
    Write-Host "    https://apps.microsoft.com/store/detail/app-installer/9NBLGGH4NNS1"
    exit 1
}

# Check for Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "`n📦 Git not found. Installing Git via winget..." -ForegroundColor Yellow
    try {
        winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
        Write-Host "`n✅ Git successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Error "`n❌ Git installation failed. Error: $_"
        exit 1
    }
} else {
    Write-Host "`n✅ Git is already installed. Skipping." -ForegroundColor Cyan
}