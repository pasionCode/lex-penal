#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${1:-http://localhost:3001/api/v1}"

echo "[1/2] Login"
LOGIN_RESPONSE=$(curl -fsS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@lexpenal.local","password":"CambiarEnProduccion_2026!"}')

TOKEN=$(echo "$LOGIN_RESPONSE" | node -e "
  let d='';
  process.stdin.on('data',c=>d+=c);
  process.stdin.on('end',()=>{
    const j=JSON.parse(d);
    if(!j?.access_token){ console.error('No se recibió access_token'); process.exit(1); }
    console.log(j.access_token);
  });
")
echo "[OK] Login — token obtenido"

echo "[2/2] GET /users/me"
curl -fsS "$BASE_URL/users/me" -H "Authorization: Bearer $TOKEN" > /dev/null
echo "[OK] /users/me — autenticación verificada"

echo "=== SMOKE TEST COMPLETADO ==="
