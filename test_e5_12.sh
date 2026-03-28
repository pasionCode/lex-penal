#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-12 — VALIDACION DE CLIENT-BRIEFING
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
echo "=============================================="
echo "E5-12 — VALIDACION RUNTIME DE CLIENT-BRIEFING"
echo "=============================================="
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

DOC_CLIENTE="E512${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E512 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CLIENT_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" = "201" ] && [ -n "$CLIENT_ID" ]; then
  log_pass "02. POST /clients -> 201"
else
  log_fail "02. POST /clients -> $HTTP"
  exit 1
fi

RADICADO="E512-$TIMESTAMP"
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
# FASE 1: GET /client-briefing (auto-crea)
# =============================================================================
echo ""
echo "--- FASE 1: GET CLIENT-BRIEFING (AUTO-CREACION) ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/client-briefing" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  BRIEFING_ID=$(echo "$BODY" | jq -r '.id // empty')
  BRIEFING_CASO_ID=$(echo "$BODY" | jq -r '.caso_id // empty')
  
  if [ -n "$BRIEFING_ID" ] && [ "$BRIEFING_CASO_ID" = "$CASE_ID" ]; then
    log_pass "05. GET /client-briefing (auto-crea) -> 200"
  else
    log_fail "05. GET /client-briefing -> respuesta incompleta"
  fi
else
  log_fail "05. GET /client-briefing -> $HTTP"
  log_body "$BODY"
fi

# =============================================================================
# FASE 2: PUT /client-briefing
# =============================================================================
echo ""
echo "--- FASE 2: PUT CLIENT-BRIEFING ---"

RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/client-briefing" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"delito_explicado":"Hurto calificado Art 240 CP","riesgos_informados":"Pena de 6 a 14 anios","recomendacion":"Preacuerdo recomendado"}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  UPDATED_DELITO=$(echo "$BODY" | jq -r '.delito_explicado // empty')
  
  if [ "$UPDATED_DELITO" = "Hurto calificado Art 240 CP" ]; then
    log_pass "06. PUT /client-briefing -> 200 (campos actualizados)"
  else
    log_fail "06. PUT /client-briefing -> campos no reflejados"
  fi
else
  log_fail "06. PUT /client-briefing -> $HTTP"
  log_body "$BODY"
fi

# =============================================================================
# FASE 3: GET despues de PUT
# =============================================================================
echo ""
echo "--- FASE 3: GET DESPUES DE PUT ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/client-briefing" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  PERSISTED_DELITO=$(echo "$BODY" | jq -r '.delito_explicado // empty')
  PERSISTED_RIESGOS=$(echo "$BODY" | jq -r '.riesgos_informados // empty')
  PERSISTED_RECOM=$(echo "$BODY" | jq -r '.recomendacion // empty')
  
  if [ "$PERSISTED_DELITO" = "Hurto calificado Art 240 CP" ] && \
     [ "$PERSISTED_RIESGOS" = "Pena de 6 a 14 anios" ] && \
     [ "$PERSISTED_RECOM" = "Preacuerdo recomendado" ]; then
    log_pass "07. GET despues de PUT -> 200 (cambios persistidos)"
  else
    log_fail "07. GET despues de PUT -> cambios no persistidos"
  fi
else
  log_fail "07. GET despues de PUT -> $HTTP"
fi

# =============================================================================
# FASE 4: CASO INEXISTENTE
# =============================================================================
echo ""
echo "--- FASE 4: CASO INEXISTENTE ---"

FAKE_CASE="00000000-0000-0000-0000-000000000000"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$FAKE_CASE/client-briefing" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "08. GET /client-briefing (caso inexistente) -> 404"
else
  log_fail "08. GET /client-briefing (caso inexistente) -> $HTTP"
fi

RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$FAKE_CASE/client-briefing" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"delito_explicado":"Test"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "09. PUT /client-briefing (caso inexistente) -> 404"
else
  log_fail "09. PUT /client-briefing (caso inexistente) -> $HTTP"
fi

# =============================================================================
# FASE 5: ACCESO SIN TOKEN
# =============================================================================
echo ""
echo "--- FASE 5: ACCESO SIN TOKEN ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/client-briefing")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "10. GET /client-briefing sin token -> 401"
else
  log_fail "10. GET /client-briefing sin token -> $HTTP"
fi

RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/client-briefing" \
  -H "Content-Type: application/json" \
  -d '{"delito_explicado":"Sin Auth"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "11. PUT /client-briefing sin token -> 401"
else
  log_fail "11. PUT /client-briefing sin token -> $HTTP"
fi

# =============================================================================
# FASE 6: ESTUDIANTE EN CASO AJENO
# =============================================================================
echo ""
echo "--- FASE 6: ESTUDIANTE EN CASO AJENO ---"

STUDENT_EMAIL="student${TIMESTAMP}@lexpenal.local"
curl -sS -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Estudiante E512 $TIMESTAMP\",\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\",\"perfil\":\"estudiante\"}" > /dev/null

RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\"}")
STUDENT_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -n "$STUDENT_TOKEN" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/client-briefing" \
    -H "Authorization: Bearer $STUDENT_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "403" ]; then
    log_pass "12. GET /client-briefing (estudiante caso ajeno) -> 403"
  else
    log_fail "12. GET /client-briefing (estudiante caso ajeno) -> $HTTP"
  fi
  
  RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/client-briefing" \
    -H "Authorization: Bearer $STUDENT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"delito_explicado":"Intento no autorizado"}')
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "403" ]; then
    log_pass "13. PUT /client-briefing (estudiante caso ajeno) -> 403"
  else
    log_fail "13. PUT /client-briefing (estudiante caso ajeno) -> $HTTP"
  fi
else
  log_fail "12. Login estudiante fallo"
  log_fail "13. (depende de 12)"
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "================================================"
echo "RESUMEN E5-12 — VALIDACION DE CLIENT-BRIEFING"
echo "================================================"
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "================================================"
echo ""

if [ "$PASSED" -eq 13 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}E5-12 PUEDE CERRARSE${NC}"
  echo -e "${YELLOW}[PENDIENTE] Verificar npm run build manualmente${NC}"
else
  echo -e "${RED}E5-12 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Caso: $RADICADO | ID: $CASE_ID"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
