#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.}"
(cd "$ROOT/src/backend" && npm install)
(cd "$ROOT/src/frontend" && npm install)
echo "Dependencias instaladas."
