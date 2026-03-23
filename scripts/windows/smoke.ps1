param([string]$BaseUrl = "http://localhost:3001/api/v1")

Write-Host "[1/2] Login"
$loginBody = @{ email = "admin@lexpenal.local"; password = "CambiarEnProduccion_2026!" } | ConvertTo-Json
$login = Invoke-RestMethod -Method Post -Uri "$BaseUrl/auth/login" -Body $loginBody -ContentType "application/json"
if (-not $login.access_token) {
  throw "No se recibió access_token"
}
$token = $login.access_token
Write-Host "[OK] Login — token obtenido"

Write-Host "[2/2] GET /users/me"
$me = Invoke-RestMethod -Method Get -Uri "$BaseUrl/users/me" -Headers @{ Authorization = "Bearer $token" }
Write-Host "[OK] /users/me — autenticación verificada"

Write-Host "=== SMOKE TEST COMPLETADO ==="
