param([string]$Root = ".")
Push-Location (Join-Path $Root "src\frontend")
npm run dev
Pop-Location
