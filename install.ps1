# Minimal bootstrap install.ps1 (for use with irm | iex)
$zenWinPath = "$env:USERPROFILE\.zenwin"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget is not available. Please install App Installer from the Microsoft Store."
    exit 1
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
}

if (-not (Test-Path $zenWinPath)) {
    git clone https://github.com/cdly450/ZenWin.git $zenWinPath
} else {
    Write-Host "ZenWin already cloned. Updating..."
    Set-Location $zenWinPath
    git pull
}

# Run the full setup
& "$zenWinPath\utilities\bootstrap.ps1"