#!/bin/bash
# =============================================================================
# PRUEBAS RUNTIME E6-01 — VALIDACION DE AUDIT
# =============================================================================
# 12 pruebas runtime:
#   01-03: Login (admin, supervisor, estudiante)
#   04: Crear cliente y caso + activar
#   05: GET /audit sin token -> 401
#   06: GET /audit admin -> 200
#   07: GET /audit supervisor -> 200
#   08: GET /audit estudiante -> 403
#   09: GET /audit caso inexistente -> 404
#   10: GET /audit?page=1&per_page=5 -> 200 + shape
#   11: GET /audit?tipo=transicion_estado -> 200
#   12: GET /audit?tipo=invalido -> 400
#
# Build verde: obligatorio y separado (npm run build)
#
# Patron: Endpoint restringido por perfil (solo supervisor/admin)
# =============================================================================

set -euo pipefail

BASE_URL="${1:-http://localhost:3001/api/v1}"
PASSED=0
FAILED=0
TIMESTAMP=$(date +%s)

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_pass() { echo -e "[${GREEN}PASS${NC}] $1"; PASSED=$((PASSED + 1)); }
log_fail() { echo -e "[${RED}FAIL${NC}] $1"; FAILED=$((FAILED + 1)); }
log_info() { echo -e "[${YELLOW}INFO${NC}] $1"; }

echo "========================================"
echo "E6-01 — VALIDACION RUNTIME DE AUDIT"
echo "========================================"
echo "Timestamp: $TIMESTAMP"

# =============================================================================
# FASE 0: LOGINS
# =============================================================================
log_info "Fase 0: Logins..."

# 01. Login admin
RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@lexpenal.local","password":"CambiarEnProduccion_2026!"}')
ADMIN_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -n "$ADMIN_TOKEN" ]; then
  log_pass "01. Login admin -> 200"
else
  log_fail "01. Login admin fallo"
  echo "Respuesta: $RESP"
  exit 1
fi

# 02. Login supervisor (crear si no existe)
SUPERVISOR_EMAIL="supervisor${TIMESTAMP}@lexpenal.local"
curl -sS -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Supervisor E601\",\"email\":\"$SUPERVISOR_EMAIL\",\"password\":\"SuperPass123!\",\"perfil\":\"supervisor\"}" > /dev/null 2>&1

RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$SUPERVISOR_EMAIL\",\"password\":\"SuperPass123!\"}")
SUPERVISOR_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -n "$SUPERVISOR_TOKEN" ]; then
  log_pass "02. Login supervisor -> 200"
else
  log_fail "02. Login supervisor fallo"
fi

# 03. Login estudiante (crear si no existe)
STUDENT_EMAIL="student${TIMESTAMP}@lexpenal.local"
curl -sS -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Estudiante E601\",\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\",\"perfil\":\"estudiante\"}" > /dev/null 2>&1

RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\"}")
STUDENT_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -n "$STUDENT_TOKEN" ]; then
  log_pass "03. Login estudiante -> 200"
else
  log_fail "03. Login estudiante fallo"
fi

# =============================================================================
# FASE 1: CREAR CASO CON EVENTOS
# =============================================================================
echo ""
echo "--- FASE 1: CREAR CASO CON EVENTOS ---"

# 04. Crear cliente y caso + activar (genera evento de transicion)
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente Audit $TIMESTAMP\",\"documento\":\"AUD$TIMESTAMP\",\"tipo_documento\":\"CC\",\"situacion_libertad\":\"libre\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CLIENT_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" != "201" ] || [ -z "$CLIENT_ID" ]; then
  log_fail "04. Crear cliente fallo ($HTTP)"
  exit 1
fi

RADICADO="E601-$TIMESTAMP"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"cliente_id\":\"$CLIENT_ID\",\"radicado\":\"$RADICADO\",\"delito_imputado\":\"Hurto\",\"despacho\":\"Juzgado 1\",\"regimen_procesal\":\"Ley 906\",\"etapa_procesal\":\"Investigacion\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CASE_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" != "201" ] || [ -z "$CASE_ID" ]; then
  log_fail "04. Crear caso fallo ($HTTP)"
  exit 1
fi

# Activar caso (genera evento de auditoria)
curl -sS -X POST "$BASE_URL/cases/$CASE_ID/transition" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"estado_destino":"en_analisis"}' > /dev/null

log_pass "04. Crear cliente, caso y activar -> 201"

# =============================================================================
# FASE 2: CONTROL DE ACCESO
# =============================================================================
echo ""
echo "--- FASE 2: CONTROL DE ACCESO ---"

# 05. GET /audit sin token
RESP=$(curl -sS -w "\n%{http_code}" -X GET "$BASE_URL/cases/$CASE_ID/audit")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "05. GET /audit sin token -> 401"
else
  log_fail "05. GET /audit sin token -> $HTTP (esperado 401)"
fi

# 06. GET /audit admin
RESP=$(curl -sS -w "\n%{http_code}" -X GET "$BASE_URL/cases/$CASE_ID/audit" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ]; then
  log_pass "06. GET /audit admin -> 200"
else
  log_fail "06. GET /audit admin -> $HTTP (esperado 200)"
fi

# 07. GET /audit supervisor
RESP=$(curl -sS -w "\n%{http_code}" -X GET "$BASE_URL/cases/$CASE_ID/audit" \
  -H "Authorization: Bearer $SUPERVISOR_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ]; then
  log_pass "07. GET /audit supervisor -> 200"
else
  log_fail "07. GET /audit supervisor -> $HTTP (esperado 200)"
fi

# 08. GET /audit estudiante
RESP=$(curl -sS -w "\n%{http_code}" -X GET "$BASE_URL/cases/$CASE_ID/audit" \
  -H "Authorization: Bearer $STUDENT_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "403" ]; then
  log_pass "08. GET /audit estudiante -> 403"
else
  log_fail "08. GET /audit estudiante -> $HTTP (esperado 403)"
fi

# =============================================================================
# FASE 3: CASO INEXISTENTE
# =============================================================================
echo ""
echo "--- FASE 3: CASO INEXISTENTE ---"

FAKE_UUID="00000000-0000-4000-8000-000000000001"

# 09. GET /audit caso inexistente
RESP=$(curl -sS -w "\n%{http_code}" -X GET "$BASE_URL/cases/$FAKE_UUID/audit" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "09. GET /audit caso inexistente -> 404"
else
  log_fail "09. GET /audit caso inexistente -> $HTTP (esperado 404)"
fi

# =============================================================================
# FASE 4: PAGINACION Y FILTROS
# =============================================================================
echo ""
echo "--- FASE 4: PAGINACION Y FILTROS ---"

# 10. GET /audit?page=1&per_page=5 + validar shape
RESP=$(curl -sS -w "\n%{http_code}" -X GET "$BASE_URL/cases/$CASE_ID/audit?page=1&per_page=5" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  # Validar shape
  HAS_DATA=$(echo "$BODY" | jq 'has("data")')
  HAS_TOTAL=$(echo "$BODY" | jq 'has("total")')
  HAS_PAGE=$(echo "$BODY" | jq 'has("page")')
  HAS_PER_PAGE=$(echo "$BODY" | jq 'has("per_page")')
  
  if [ "$HAS_DATA" = "true" ] && [ "$HAS_TOTAL" = "true" ] && [ "$HAS_PAGE" = "true" ] && [ "$HAS_PER_PAGE" = "true" ]; then
    log_pass "10. GET /audit?page=1&per_page=5 -> 200 + shape valido"
  else
    log_fail "10. GET /audit?page=1&per_page=5 -> 200 pero shape invalido"
  fi
else
  log_fail "10. GET /audit?page=1&per_page=5 -> $HTTP (esperado 200)"
fi

# 11. GET /audit?tipo=transicion_estado
RESP=$(curl -sS -w "\n%{http_code}" -X GET "$BASE_URL/cases/$CASE_ID/audit?tipo=transicion_estado" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ]; then
  log_pass "11. GET /audit?tipo=transicion_estado -> 200"
else
  log_fail "11. GET /audit?tipo=transicion_estado -> $HTTP (esperado 200)"
fi

# 12. GET /audit?tipo=invalido
RESP=$(curl -sS -w "\n%{http_code}" -X GET "$BASE_URL/cases/$CASE_ID/audit?tipo=invalido" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "400" ]; then
  log_pass "12. GET /audit?tipo=invalido -> 400"
else
  log_fail "12. GET /audit?tipo=invalido -> $HTTP (esperado 400)"
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "========================================"
echo "RESUMEN E6-01 — VALIDACION DE AUDIT"
echo "========================================"
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "========================================"
echo ""

echo "Caso de prueba: $RADICADO | ID: $CASE_ID"
echo ""

if [ "$PASSED" -eq 12 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}E6-01 RUNTIME VALIDADO${NC}"
  echo -e "${YELLOW}[PENDIENTE]${NC} Build verde obligatorio: npm run build"
else
  echo -e "${RED}E6-01 NO PUEDE CERRARSE${NC}"
fi
