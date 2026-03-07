#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${1:-http://localhost:8080/api/v1}"
TOKEN=$(curl -s -X POST "$BASE_URL/auth/login" -H "Content-Type: application/json" -d '{"email":"admin@lexpenal.local","password":"ChangeMe123!"}' | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>console.log(JSON.parse(d).data.token));")
curl -s "$BASE_URL/health"
echo
curl -s -X POST "$BASE_URL/cases" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"title":"Caso smoke test","client_name":"Cliente smoke","risk_level":"medium","facts":{"summary":"Caso creado por smoke test."}}'
echo
