param([string]$Root = ".")
Push-Location (Join-Path $Root "src\backend")
npm run db:seed
Pop-Location
