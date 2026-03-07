#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.}"
"$ROOT/scripts/linux/bootstrap-env.sh" "$ROOT"
( cd "$ROOT/src/backend" && npm run dev ) &
( cd "$ROOT/src/frontend" && npm run dev ) &
wait
