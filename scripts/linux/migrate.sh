#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.}"
(cd "$ROOT/src/backend" && npm run db:migrate)
