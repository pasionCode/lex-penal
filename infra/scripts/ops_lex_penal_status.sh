#!/usr/bin/env bash
set -Eeuo pipefail

echo "=== FECHA ==="
date -Is

echo
echo "=== SYSTEMD STATUS ==="
systemctl status lex-penal.service --no-pager || true

echo
echo "=== HEALTH LOCAL ==="
curl -sS -i http://127.0.0.1:3010/api/v1/health || true

echo
echo "=== HEALTH NGINX ==="
curl -k -sS -i https://127.0.0.1/api/v1/health || true

echo
echo "=== JOURNAL ULTIMAS 40 ==="
journalctl -u lex-penal.service -n 40 --no-pager || true

echo
echo "=== LEX_PENAL ACCESS LOG (TAIL 40) ==="
tail -n 40 /var/log/nginx/lex_penal_access.log 2>/dev/null || echo "LOG_NO_DISPONIBLE"

echo
echo "=== LEX_PENAL ERROR LOG (TAIL 40) ==="
tail -n 40 /var/log/nginx/lex_penal_error.log 2>/dev/null || echo "LOG_NO_DISPONIBLE"
