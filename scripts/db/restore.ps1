param([Parameter(Mandatory = $true)][string]$File)
Get-Content $File | docker exec -i lexpenal-db psql -U lexpenal -d lexpenal
Write-Host "Restore ejecutado desde $File"
