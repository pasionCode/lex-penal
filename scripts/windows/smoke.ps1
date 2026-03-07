param([string]$BaseUrl = "http://localhost:8080/api/v1")
$loginBody = @{ email = "admin@lexpenal.local"; password = "ChangeMe123!" } | ConvertTo-Json
$login = Invoke-RestMethod -Method Post -Uri "$BaseUrl/auth/login" -Body $loginBody -ContentType "application/json"
$token = $login.data.token
$health = Invoke-RestMethod -Method Get -Uri "$BaseUrl/health"
Write-Host "Health:" ($health | ConvertTo-Json -Depth 5)
$caseBody = @{ title = "Caso smoke test"; client_name = "Cliente smoke"; risk_level = "medium"; facts = @{ summary = "Caso creado por smoke test." } } | ConvertTo-Json -Depth 5
$case = Invoke-RestMethod -Method Post -Uri "$BaseUrl/cases" -Headers @{ Authorization = "Bearer $token" } -Body $caseBody -ContentType "application/json"
Write-Host "Case created:" ($case | ConvertTo-Json -Depth 5)
