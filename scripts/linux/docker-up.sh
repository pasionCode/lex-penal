#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.}"
docker compose -f "$ROOT/infra/docker/docker-compose.yml" up --build
