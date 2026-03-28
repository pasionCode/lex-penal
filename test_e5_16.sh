#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-16 — VALIDACION DE CONCLUSION
# =============================================================================
# 11 pruebas:
#   01-04: Setup
#   05-07: GET auto-crea, PUT actualiza, GET refleja
#   08: Caso inexistente -> 404
#   09: Sin token -> 401
#   10-11: Estudiante ajeno -> 403
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
echo "E5-16 — VALIDACION RUNTIME DE CONCLUSION"
echo "========================================"
echo "Timestamp: $TIMESTAMP"
echo ""

# =============================================================================
# SETUP
# =============================================================================
log_info "Fase 0: Setup..."

# 01. Login admin
RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@lexpenal.local","password":"CambiarEnProduccion_2026!"}')
ADMIN_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -z "$ADMIN_TOKEN" ]; then
  echo -e "${RED}[ERROR] No se obtuvo token admin. Abortando.${NC}"
  exit 1
fi
log_pass "01. Login admin -> 200"

# 02. Crear cliente
DOC_CLIENTE="E516${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E516 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CLIENT_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" = "201" ] && [ -n "$CLIENT_ID" ]; then
  log_pass "02. POST /clients -> 201"
else
  log_fail "02. POST /clients -> $HTTP"
  exit 1
fi

# 03. Crear caso
RADICADO="E516-$TIMESTAMP"
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

# 04. Activar caso
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
# FASE 1: SINGLETON CON AUTO-CREACION
# =============================================================================
echo ""
echo "--- FASE 1: SINGLETON CON AUTO-CREACION ---"

# 05. GET /conclusion (auto-crea)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/conclusion" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  CONCLUSION_ID=$(echo "$BODY" | jq -r '.id // empty')
  CASO_ID_RETURNED=$(echo "$BODY" | jq -r '.caso_id // empty')
  if [ -n "$CONCLUSION_ID" ] && [ "$CASO_ID_RETURNED" = "$CASE_ID" ]; then
    log_pass "05. GET /conclusion (auto-crea) -> 200"
  else
    log_fail "05. GET /conclusion -> respuesta incompleta"
  fi
else
  log_fail "05. GET /conclusion -> $HTTP"
fi

# 06. PUT /conclusion (actualiza)
RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/conclusion" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"hechos_sintesis":"El imputado fue sorprendido en flagrancia","recomendacion":"Negociar preacuerdo"}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  HECHOS=$(echo "$BODY" | jq -r '.hechos_sintesis // empty')
  RECOMENDACION=$(echo "$BODY" | jq -r '.recomendacion // empty')
  if [ -n "$HECHOS" ] && [ -n "$RECOMENDACION" ]; then
    log_pass "06. PUT /conclusion -> 200 (campos actualizados)"
  else
    log_fail "06. PUT /conclusion -> campos no reflejados"
  fi
else
  log_fail "06. PUT /conclusion -> $HTTP"
fi

# 07. GET /conclusion (refleja cambios)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/conclusion" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  HECHOS=$(echo "$BODY" | jq -r '.hechos_sintesis // empty')
  RECOMENDACION=$(echo "$BODY" | jq -r '.recomendacion // empty')
  if [ "$HECHOS" = "El imputado fue sorprendido en flagrancia" ] && [ "$RECOMENDACION" = "Negociar preacuerdo" ]; then
    log_pass "07. GET /conclusion (refleja cambios) -> 200"
  else
    log_fail "07. GET /conclusion -> cambios no persistieron"
  fi
else
  log_fail "07. GET /conclusion -> $HTTP"
fi

# =============================================================================
# FASE 2: CASO INEXISTENTE
# =============================================================================
echo ""
echo "--- FASE 2: CASO INEXISTENTE ---"

FAKE_CASE="00000000-0000-0000-0000-000000000000"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$FAKE_CASE/conclusion" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "08. GET /conclusion (caso inexistente) -> 404"
else
  log_fail "08. GET /conclusion (caso inexistente) -> $HTTP"
fi

# =============================================================================
# FASE 3: SIN TOKEN
# =============================================================================
echo ""
echo "--- FASE 3: SIN TOKEN ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/conclusion")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "09. GET /conclusion sin token -> 401"
else
  log_fail "09. GET /conclusion sin token -> $HTTP"
fi

# =============================================================================
# FASE 4: ESTUDIANTE AJENO
# =============================================================================
echo ""
echo "--- FASE 4: ESTUDIANTE AJENO ---"

STUDENT_EMAIL="student${TIMESTAMP}@lexpenal.local"
curl -sS -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Estudiante E516 $TIMESTAMP\",\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\",\"perfil\":\"estudiante\"}" > /dev/null

RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\"}")
STUDENT_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -n "$STUDENT_TOKEN" ]; then
  # GET estudiante ajeno -> 403
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/conclusion" \
    -H "Authorization: Bearer $STUDENT_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "403" ]; then
    log_pass "10. GET /conclusion (estudiante ajeno) -> 403"
  else
    log_fail "10. GET /conclusion (estudiante ajeno) -> $HTTP (esperado 403)"
  fi
  
  # PUT estudiante ajeno -> 403
  RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/conclusion" \
    -H "Authorization: Bearer $STUDENT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"observaciones":"Intento no autorizado"}')
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "403" ]; then
    log_pass "11. PUT /conclusion (estudiante ajeno) -> 403"
  else
    log_fail "11. PUT /conclusion (estudiante ajeno) -> $HTTP (esperado 403)"
  fi
else
  log_fail "10. Login estudiante fallo"
  log_fail "11. (depende de 10)"
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "========================================"
echo "RESUMEN E5-16 — VALIDACION DE CONCLUSION"
echo "========================================"
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "========================================"
echo ""

if [ "$PASSED" -eq 11 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}E5-16 PUEDE CERRARSE${NC}"
  echo -e "${YELLOW}[PENDIENTE] Verificar npm run build manualmente${NC}"
else
  echo -e "${RED}E5-16 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Caso: $RADICADO | ID: $CASE_ID"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
