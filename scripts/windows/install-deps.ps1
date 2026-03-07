param([string]$Root = ".")
Push-Location (Join-Path $Root "src\backend")
npm install
Pop-Location
Push-Location (Join-Path $Root "src\frontend")
npm install
Pop-Location
Write-Host "Dependencias instaladas."
