param([string]$File = ".\infra\backups\lexpenal_backup.sql")
docker exec -t lexpenal-db pg_dump -U lexpenal -d lexpenal > $File
Write-Host "Backup generado en $File"
