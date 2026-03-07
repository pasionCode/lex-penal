#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.}"
cp -n "$ROOT/src/backend/.env.example" "$ROOT/src/backend/.env" || true
cp -n "$ROOT/src/frontend/.env.example" "$ROOT/src/frontend/.env" || true
echo "Variables de entorno inicializadas."
