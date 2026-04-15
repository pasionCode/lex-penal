#!/usr/bin/env bash
set -Eeuo pipefail

BASE_URL="${BASE_URL:-http://localhost:3000/api/v1}"
TOKEN_EST="${TOKEN_EST:-}"
TOKEN_OTRO="${TOKEN_OTRO:-}"
CASE_ID="${CASE_ID:-}"
CASE_ID_CERRADO="${CASE_ID_CERRADO:-}"

if [ -z "$TOKEN_EST" ] || [ -z "$TOKEN_OTRO" ] || [ -z "$CASE_ID" ] || [ -z "$CASE_ID_CERRADO" ]; then
  echo "Faltan variables: TOKEN_EST, TOKEN_OTRO, CASE_ID, CASE_ID_CERRADO"
  exit 1
fi

echo "=== 1) POST valido ==="
CREATE_RESPONSE="$(curl -sS -X POST "$BASE_URL/cases/$CASE_ID/risks" \
  -H "Authorization: Bearer $TOKEN_EST" \
  -H "Content-Type: application/json" \
  -d '{
    "descripcion":"Riesgo E28-01",
    "probabilidad":"alta",
    "impacto":"alto",
    "prioridad":"alta"
  }')"

echo "$CREATE_RESPONSE" | tee /tmp/e28_risk_create.json

RISK_ID="$(echo "$CREATE_RESPONSE" | jq -r '.id // empty')"
echo
echo "RISK_ID=$RISK_ID"

echo
echo "=== 2) POST 400 por critica sin estrategia ==="
curl -sS -o /tmp/e28_risk_400.json -w "%{http_code}\n" -X POST "$BASE_URL/cases/$CASE_ID/risks" \
  -H "Authorization: Bearer $TOKEN_EST" \
  -H "Content-Type: application/json" \
  -d '{
    "descripcion":"Riesgo critico sin estrategia",
    "probabilidad":"alta",
    "impacto":"alto",
    "prioridad":"critica"
  }'

echo
echo "=== 3) GET list ==="
curl -sS "$BASE_URL/cases/$CASE_ID/risks" \
  -H "Authorization: Bearer $TOKEN_EST"

echo
echo "=== 4) GET list 403 por aislamiento ==="
curl -sS -o /tmp/e28_risk_403.json -w "%{http_code}\n" "$BASE_URL/cases/$CASE_ID/risks" \
  -H "Authorization: Bearer $TOKEN_OTRO"

echo
echo "=== 5) GET detail ==="
if [ -z "$RISK_ID" ]; then
  echo "No se obtuvo RISK_ID del POST inicial"
  exit 1
fi

curl -sS "$BASE_URL/cases/$CASE_ID/risks/$RISK_ID" \
  -H "Authorization: Bearer $TOKEN_EST"

echo
echo "=== 6) PUT valido ==="
curl -sS -X PUT "$BASE_URL/cases/$CASE_ID/risks/$RISK_ID" \
  -H "Authorization: Bearer $TOKEN_EST" \
  -H "Content-Type: application/json" \
  -d '{
    "prioridad":"critica",
    "estrategia_mitigacion":"Mitigacion definida en E28-01",
    "estado_mitigacion":"en_curso"
  }'

echo
echo "=== 7) POST 409 en caso bloqueado ==="
curl -sS -o /tmp/e28_risk_409_create.json -w "%{http_code}\n" -X POST "$BASE_URL/cases/$CASE_ID_CERRADO/risks" \
  -H "Authorization: Bearer $TOKEN_EST" \
  -H "Content-Type: application/json" \
  -d '{
    "descripcion":"No debe crear",
    "probabilidad":"media",
    "impacto":"medio",
    "prioridad":"alta"
  }'

echo
echo "=== 8) PUT 409 en caso bloqueado ==="
curl -sS -o /tmp/e28_risk_409_update.json -w "%{http_code}\n" -X PUT "$BASE_URL/cases/$CASE_ID_CERRADO/risks/$RISK_ID" \
  -H "Authorization: Bearer $TOKEN_EST" \
  -H "Content-Type: application/json" \
  -d '{
    "descripcion":"No debe actualizar"
  }'

echo
echo "=== 9) Resumen codigos ==="
echo -n "POST 400 esperado -> "
cat /tmp/e28_risk_400.json >/dev/null 2>&1 || true
echo "ver codigo arriba"

echo -n "GET 403 esperado -> "
cat /tmp/e28_risk_403.json >/dev/null 2>&1 || true
echo "ver codigo arriba"

echo -n "POST 409 esperado -> "
cat /tmp/e28_risk_409_create.json >/dev/null 2>&1 || true
echo "ver codigo arriba"

echo -n "PUT 409 esperado -> "
cat /tmp/e28_risk_409_update.json >/dev/null 2>&1 || true
echo "ver codigo arriba"
