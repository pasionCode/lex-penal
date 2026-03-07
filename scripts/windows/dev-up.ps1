param([string]$Root = ".")
& (Join-Path $Root "scripts\windows\bootstrap-env.ps1") -Root $Root
Start-Process powershell -ArgumentList "-NoExit", "-File", (Join-Path $Root "scripts\windows\start-backend.ps1"), "-Root", $Root
Start-Process powershell -ArgumentList "-NoExit", "-File", (Join-Path $Root "scripts\windows\start-frontend.ps1"), "-Root", $Root
Write-Host "Backend y frontend lanzados en ventanas separadas."
