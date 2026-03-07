param([string]$Root = ".")
Push-Location (Join-Path $Root "src\backend")
npm run dev
Pop-Location
