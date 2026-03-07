param([string]$Root = ".")
docker compose -f (Join-Path $Root "infra\docker\docker-compose.yml") up --build
