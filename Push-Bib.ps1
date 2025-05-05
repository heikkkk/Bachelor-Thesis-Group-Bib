# === Load .env file ===
$envFilePath = "$PSScriptRoot\.env"

if (Test-Path $envFilePath) {
    Get-Content $envFilePath | ForEach-Object {
        if ($_ -match "^\s*([^#][\w_]+)\s*=\s*(.+)\s*$") {
            $key = $matches[1]
            $value = $matches[2]
            [System.Environment]::SetEnvironmentVariable($key, $value, "Process")
        }
    }
} else {
    Write-Host "Missing .env file: $envFilePath"
    exit 1
}

# === CONFIGURATION FROM ENV ===
$bibPath = $env:BIB_PATH
$repoDir = $env:REPO_DIR
$bibName = "bachelor.bib"
$commitMessage = "Auto-update bibliography"

# === SCRIPT LOGIC ===
Write-Host "Copying .bib file to repo..."
Copy-Item -Path $bibPath -Destination (Join-Path $repoDir $bibName) -Force

Set-Location $repoDir

# Check for changes
$gitDiff = git diff --name-only $bibName

if (-not [string]::IsNullOrWhiteSpace($gitDiff)) {
    git add $bibName
    git commit -m $commitMessage
    git push origin main
    Write-Host "Bibliography updated and pushed to GitHub."
} else {
    Write-Host "No changes to commit."
}
