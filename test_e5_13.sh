#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-13 — VALIDACION DE REPORTS
# =============================================================================
# 17 pruebas:
#   01-04: Setup
#   05: POST /reports genera -> 201
#   06: GET /reports lista -> 200
#   07: GET /reports/:id detalle -> 200
#   08: POST idempotente -> 201 mismo ID
#   09-11: Caso inexistente -> 404
#   12: Informe inexistente -> 404
#   13: Fuga entre casos -> 404
#   14-15: Sin token -> 401
#   16-17: Estudiante caso ajeno -> 403
# =============================================================================
set -euo pipefail

BASE_URL="${1:-http://localhost:3001/api/v1}"
PASSED=0
FAILED=0
TIMESTAMP=$(date +%s)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; PASSED=$((PASSED + 1)); }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; FAILED=$((FAILED + 1)); }
log_info() { echo -e "${YELLOW}[INFO]${NC} $1"; }
log_body() { echo -e "${RED}[BODY]${NC} $1"; }

if ! command -v jq &> /dev/null; then
  echo -e "${RED}[ERROR] jq no instalado.${NC}"
  exit 1
fi

echo ""
echo "========================================"
echo "E5-13 — VALIDACION RUNTIME DE REPORTS"
echo "========================================"
echo "Timestamp: $TIMESTAMP"
echo ""

# =============================================================================
# SETUP
# =============================================================================
log_info "Fase 0: Setup..."

RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@lexpenal.local","password":"CambiarEnProduccion_2026!"}')
ADMIN_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -z "$ADMIN_TOKEN" ]; then
  echo -e "${RED}[ERROR] No se obtuvo token admin. Abortando.${NC}"
  exit 1
fi
log_pass "01. Login admin -> 200"

DOC_CLIENTE="E513${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E513 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CLIENT_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" = "201" ] && [ -n "$CLIENT_ID" ]; then
  log_pass "02. POST /clients -> 201"
else
  log_fail "02. POST /clients -> $HTTP"
  exit 1
fi

RADICADO="E513-$TIMESTAMP"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"cliente_id\":\"$CLIENT_ID\",\"radicado\":\"$RADICADO\",\"delito_imputado\":\"Hurto\",\"despacho\":\"Juzgado 1\",\"regimen_procesal\":\"Ley 906\",\"etapa_procesal\":\"Investigacion\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CASE_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" = "201" ] && [ -n "$CASE_ID" ]; then
  log_pass "03. POST /cases -> 201"
else
  log_fail "03. POST /cases -> $HTTP"
  exit 1
fi

RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"estado_destino":"en_analisis"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
  log_pass "04. Activar caso -> $HTTP"
else
  log_fail "04. Activar caso -> $HTTP"
fi

# =============================================================================
# FASE 1: POST /reports genera informe
# =============================================================================
echo ""
echo "--- FASE 1: POST /reports ---"

RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/reports" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tipo":"resumen_ejecutivo","formato":"pdf"}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "201" ]; then
  REPORT_ID=$(echo "$BODY" | jq -r '.id // empty')
  REPORT_TIPO=$(echo "$BODY" | jq -r '.tipo_informe // empty')
  
  if [ -n "$REPORT_ID" ]; then
    log_pass "05. POST /reports -> 201 (id=$REPORT_ID, tipo=$REPORT_TIPO)"
  else
    log_fail "05. POST /reports -> respuesta incompleta"
  fi
else
  log_fail "05. POST /reports -> $HTTP"
  log_body "$BODY"
  REPORT_ID=""
fi

# =============================================================================
# FASE 2: GET /reports lista
# =============================================================================
echo ""
echo "--- FASE 2: GET /reports (lista) ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/reports" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  IS_ARRAY=$(echo "$BODY" | jq 'if type == "array" then true else false end')
  
  if [ "$IS_ARRAY" = "true" ]; then
    ARRAY_LENGTH=$(echo "$BODY" | jq 'length')
    log_pass "06. GET /reports -> 200 (array con $ARRAY_LENGTH elementos)"
  else
    log_fail "06. GET /reports -> respuesta no es array"
  fi
else
  log_fail "06. GET /reports -> $HTTP"
fi

# =============================================================================
# FASE 3: GET /reports/:id detalle
# =============================================================================
echo ""
echo "--- FASE 3: GET /reports/:id ---"

if [ -n "$REPORT_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/reports/$REPORT_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  
  if [ "$HTTP" = "200" ]; then
    RETURNED_ID=$(echo "$BODY" | jq -r '.id // empty')
    
    if [ "$RETURNED_ID" = "$REPORT_ID" ]; then
      log_pass "07. GET /reports/:id -> 200"
    else
      log_fail "07. GET /reports/:id -> ID no coincide"
    fi
  else
    log_fail "07. GET /reports/:id -> $HTTP"
  fi
else
  log_fail "07. GET /reports/:id -> Sin REPORT_ID"
fi

# =============================================================================
# FASE 4: POST idempotente (mismo tipo+formato <5min)
# =============================================================================
echo ""
echo "--- FASE 4: POST idempotente ---"

RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/reports" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tipo":"resumen_ejecutivo","formato":"pdf"}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "201" ]; then
  IDEMPOTENT_ID=$(echo "$BODY" | jq -r '.id // empty')
  
  if [ "$IDEMPOTENT_ID" = "$REPORT_ID" ]; then
    log_pass "08. POST idempotente -> 201 (mismo ID: $IDEMPOTENT_ID)"
  else
    log_fail "08. POST idempotente -> ID diferente (esperado $REPORT_ID, obtuvo $IDEMPOTENT_ID)"
  fi
else
  log_fail "08. POST idempotente -> $HTTP (esperado 201)"
fi

# =============================================================================
# FASE 5: CASO INEXISTENTE
# =============================================================================
echo ""
echo "--- FASE 5: CASO INEXISTENTE ---"

FAKE_CASE="00000000-0000-0000-0000-000000000000"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$FAKE_CASE/reports" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "09. GET /reports (caso inexistente) -> 404"
else
  log_fail "09. GET /reports (caso inexistente) -> $HTTP"
fi

RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$FAKE_CASE/reports" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tipo":"resumen_ejecutivo","formato":"pdf"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "10. POST /reports (caso inexistente) -> 404"
else
  log_fail "10. POST /reports (caso inexistente) -> $HTTP"
fi

if [ -n "$REPORT_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$FAKE_CASE/reports/$REPORT_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "404" ]; then
    log_pass "11. GET /reports/:id (caso inexistente) -> 404"
  else
    log_fail "11. GET /reports/:id (caso inexistente) -> $HTTP"
  fi
else
  log_fail "11. GET /reports/:id (caso inexistente) -> Sin REPORT_ID"
fi

# =============================================================================
# FASE 6: INFORME INEXISTENTE
# =============================================================================
echo ""
echo "--- FASE 6: INFORME INEXISTENTE ---"

FAKE_REPORT="00000000-0000-0000-0000-000000000001"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/reports/$FAKE_REPORT" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "12. GET /reports/:id (informe inexistente) -> 404"
else
  log_fail "12. GET /reports/:id (informe inexistente) -> $HTTP"
fi

# =============================================================================
# FASE 7: FUGA ENTRE CASOS
# =============================================================================
echo ""
echo "--- FASE 7: FUGA ENTRE CASOS ---"

RADICADO2="E513B-$TIMESTAMP"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"cliente_id\":\"$CLIENT_ID\",\"radicado\":\"$RADICADO2\",\"delito_imputado\":\"Estafa\",\"despacho\":\"Juzgado 2\",\"regimen_procesal\":\"Ley 906\",\"etapa_procesal\":\"Juicio\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CASE_ID_2=$(echo "$BODY" | jq -r '.id // empty')

if [ -n "$CASE_ID_2" ] && [ -n "$REPORT_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID_2/reports/$REPORT_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "404" ]; then
    log_pass "13. Fuga entre casos -> 404 PROTEGIDO"
  else
    log_fail "13. Fuga entre casos -> $HTTP (VULNERABILIDAD)"
  fi
else
  log_fail "13. Fuga entre casos -> No se pudo crear segundo caso"
fi

# =============================================================================
# FASE 8: ACCESO SIN TOKEN
# =============================================================================
echo ""
echo "--- FASE 8: ACCESO SIN TOKEN ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/reports")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "14. GET /reports sin token -> 401"
else
  log_fail "14. GET /reports sin token -> $HTTP"
fi

RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/reports" \
  -H "Content-Type: application/json" \
  -d '{"tipo":"resumen_ejecutivo","formato":"pdf"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "15. POST /reports sin token -> 401"
else
  log_fail "15. POST /reports sin token -> $HTTP"
fi

# =============================================================================
# FASE 9: ESTUDIANTE EN CASO AJENO
# =============================================================================
echo ""
echo "--- FASE 9: ESTUDIANTE EN CASO AJENO ---"

STUDENT_EMAIL="student${TIMESTAMP}@lexpenal.local"
curl -sS -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Estudiante E513 $TIMESTAMP\",\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\",\"perfil\":\"estudiante\"}" > /dev/null

RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\"}")
STUDENT_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -n "$STUDENT_TOKEN" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/reports" \
    -H "Authorization: Bearer $STUDENT_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "403" ]; then
    log_pass "16. GET /reports (estudiante caso ajeno) -> 403"
  else
    log_fail "16. GET /reports (estudiante caso ajeno) -> $HTTP"
  fi
  
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/reports" \
    -H "Authorization: Bearer $STUDENT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"tipo":"resumen_ejecutivo","formato":"pdf"}')
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "403" ]; then
    log_pass "17. POST /reports (estudiante caso ajeno) -> 403"
  else
    log_fail "17. POST /reports (estudiante caso ajeno) -> $HTTP"
  fi
else
  log_fail "16. Login estudiante fallo"
  log_fail "17. (depende de 16)"
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "========================================"
echo "RESUMEN E5-13 — VALIDACION DE REPORTS"
echo "========================================"
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "========================================"
echo ""

if [ "$PASSED" -eq 17 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}E5-13 PUEDE CERRARSE${NC}"
  echo -e "${YELLOW}[PENDIENTE] Verificar npm run build manualmente${NC}"
else
  echo -e "${RED}E5-13 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Caso: $RADICADO | ID: $CASE_ID"
echo "Informe: $REPORT_ID"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
