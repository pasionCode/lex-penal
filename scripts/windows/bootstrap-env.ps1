param([string]$Root = ".")
$backendExample = Join-Path $Root "src\backend\.env.example"
$backendEnv = Join-Path $Root "src\backend\.env"
$frontendExample = Join-Path $Root "src\frontend\.env.example"
$frontendEnv = Join-Path $Root "src\frontend\.env"
if (-not (Test-Path $backendEnv)) { Copy-Item $backendExample $backendEnv }
if (-not (Test-Path $frontendEnv)) { Copy-Item $frontendExample $frontendEnv }
Write-Host "Variables de entorno inicializadas."
