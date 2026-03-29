#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-21 — VALIDACION DE TIMELINE
# =============================================================================
# 13 pruebas:
#   01-04: Setup
#   05-07: GET lista vacia, POST primera, GET lista con 1
#   08-09: POST segunda (orden automatico), GET paginacion explicita
#   10: POST fecha invalida -> 400
#   11: GET caso inexistente -> 404
#   12: Sin token -> 401
#   13: Estudiante ajeno -> 403
#
# Patron: Coleccion append-only paginada
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

if ! command -v jq &> /dev/null; then
  echo -e "${RED}[ERROR] jq no instalado.${NC}"
  exit 1
fi

echo ""
echo "========================================"
echo "E5-21 — VALIDACION RUNTIME DE TIMELINE"
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
DOC_CLIENTE="E521${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E521 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
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
RADICADO="E521-$TIMESTAMP"
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
# FASE 1: COLECCION APPEND-ONLY
# =============================================================================
echo ""
echo "--- FASE 1: COLECCION APPEND-ONLY ---"

# 05. GET /timeline (lista vacia paginada)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/timeline" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  DATA_LENGTH=$(echo "$BODY" | jq '.data | length')
  TOTAL=$(echo "$BODY" | jq '.total // empty')
  PAGE=$(echo "$BODY" | jq '.page // empty')
  PER_PAGE=$(echo "$BODY" | jq '.per_page // empty')
  
  if [ "$DATA_LENGTH" = "0" ] && [ -n "$TOTAL" ] && [ -n "$PAGE" ] && [ -n "$PER_PAGE" ]; then
    log_pass "05. GET /timeline (lista vacia paginada) -> 200 (total=$TOTAL, page=$PAGE)"
  else
    log_fail "05. GET /timeline -> respuesta sin estructura paginada"
  fi
else
  log_fail "05. GET /timeline -> $HTTP"
fi

# 06. POST /timeline (primera entrada)
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/timeline" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fecha_evento":"2026-01-15","descripcion":"Audiencia de imputacion realizada"}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
ENTRY_ID_1=$(echo "$BODY" | jq -r '.id // empty')
ORDEN_1=$(echo "$BODY" | jq -r '.orden // empty')

if [ "$HTTP" = "201" ] && [ -n "$ENTRY_ID_1" ]; then
  log_pass "06. POST /timeline -> 201 (id=$ENTRY_ID_1, orden=$ORDEN_1)"
else
  log_fail "06. POST /timeline -> $HTTP"
fi

# 07. GET /timeline (lista con 1)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/timeline" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  DATA_LENGTH=$(echo "$BODY" | jq '.data | length')
  TOTAL=$(echo "$BODY" | jq '.total')
  
  if [ "$DATA_LENGTH" = "1" ] && [ "$TOTAL" = "1" ]; then
    log_pass "07. GET /timeline (lista con 1) -> 200 (total=1)"
  else
    log_fail "07. GET /timeline -> data=$DATA_LENGTH, total=$TOTAL (esperado 1)"
  fi
else
  log_fail "07. GET /timeline -> $HTTP"
fi

# =============================================================================
# FASE 2: ORDEN AUTOMATICO Y PAGINACION
# =============================================================================
echo ""
echo "--- FASE 2: ORDEN AUTOMATICO Y PAGINACION ---"

# 08. POST /timeline (segunda entrada, orden automatico)
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/timeline" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fecha_evento":"2026-02-20","descripcion":"Audiencia preparatoria programada"}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
ENTRY_ID_2=$(echo "$BODY" | jq -r '.id // empty')
ORDEN_2=$(echo "$BODY" | jq -r '.orden // empty')

if [ "$HTTP" = "201" ]; then
  if [ -z "$ORDEN_1" ] || [ -z "$ORDEN_2" ]; then
    log_fail "08. POST /timeline -> orden no disponible para comparar"
  elif [ "$ORDEN_2" -gt "$ORDEN_1" ]; then
    log_pass "08. POST /timeline (orden automatico) -> 201 (orden=$ORDEN_2 > $ORDEN_1)"
  else
    log_fail "08. POST /timeline -> orden=$ORDEN_2 NO es mayor que $ORDEN_1"
  fi
else
  log_fail "08. POST /timeline -> $HTTP"
fi

# 09. GET /timeline con paginacion explicita
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/timeline?page=1&per_page=1" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  DATA_LENGTH=$(echo "$BODY" | jq '.data | length')
  TOTAL=$(echo "$BODY" | jq '.total')
  PAGE=$(echo "$BODY" | jq '.page')
  PER_PAGE=$(echo "$BODY" | jq '.per_page')
  
  if [ "$DATA_LENGTH" = "1" ] && [ "$TOTAL" = "2" ] && [ "$PAGE" = "1" ] && [ "$PER_PAGE" = "1" ]; then
    log_pass "09. GET /timeline (paginacion estricta) -> 200 (data=1, total=2, page=1, per_page=1)"
  else
    log_fail "09. GET /timeline -> paginacion incorrecta (data=$DATA_LENGTH, total=$TOTAL, page=$PAGE, per_page=$PER_PAGE)"
  fi
else
  log_fail "09. GET /timeline (paginacion) -> $HTTP"
fi

# =============================================================================
# FASE 3: PAYLOAD INVALIDO
# =============================================================================
echo ""
echo "--- FASE 3: PAYLOAD INVALIDO ---"

# 10. POST /timeline (fecha invalida)
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/timeline" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fecha_evento":"fecha-no-valida","descripcion":"Evento con fecha invalida"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "400" ]; then
  log_pass "10. POST /timeline (fecha invalida) -> 400"
else
  log_fail "10. POST /timeline (fecha invalida) -> $HTTP (esperado 400)"
fi

# =============================================================================
# FASE 4: CASO INEXISTENTE
# =============================================================================
echo ""
echo "--- FASE 4: CASO INEXISTENTE ---"

FAKE_CASE="00000000-0000-0000-0000-000000000000"

# 11. GET /timeline (caso inexistente)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$FAKE_CASE/timeline" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "11. GET /timeline (caso inexistente) -> 404"
else
  log_fail "11. GET /timeline (caso inexistente) -> $HTTP (esperado 404)"
fi

# =============================================================================
# FASE 5: SIN TOKEN
# =============================================================================
echo ""
echo "--- FASE 5: SIN TOKEN ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/timeline")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "12. GET /timeline sin token -> 401"
else
  log_fail "12. GET /timeline sin token -> $HTTP"
fi

# =============================================================================
# FASE 6: ESTUDIANTE AJENO
# =============================================================================
echo ""
echo "--- FASE 6: ESTUDIANTE AJENO ---"

STUDENT_EMAIL="student${TIMESTAMP}@lexpenal.local"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Estudiante E521 $TIMESTAMP\",\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\",\"perfil\":\"estudiante\"}")
HTTP_USER=$(echo "$RESP" | tail -1)

if [ "$HTTP_USER" != "201" ]; then
  log_fail "13. Creacion estudiante fallo ($HTTP_USER)"
else
  RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\"}")
  STUDENT_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

  if [ -z "$STUDENT_TOKEN" ]; then
    log_fail "13. Login estudiante fallo"
  else
    RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/timeline" \
      -H "Authorization: Bearer $STUDENT_TOKEN")
    HTTP=$(echo "$RESP" | tail -1)
    
    if [ "$HTTP" = "403" ]; then
      log_pass "13. GET /timeline (estudiante ajeno) -> 403"
    else
      log_fail "13. GET /timeline (estudiante ajeno) -> $HTTP (esperado 403)"
    fi
  fi
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "========================================"
echo "RESUMEN E5-21 — VALIDACION DE TIMELINE"
echo "========================================"
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "========================================"
echo ""

if [ "$PASSED" -eq 13 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}E5-21 PUEDE CERRARSE${NC}"
  echo -e "${YELLOW}[PENDIENTE] Verificar npm run build manualmente${NC}"
else
  echo -e "${RED}E5-21 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Caso: $RADICADO | ID: $CASE_ID"
echo "Entrada 1: $ENTRY_ID_1 (orden=$ORDEN_1)"
echo "Entrada 2: $ENTRY_ID_2 (orden=$ORDEN_2)"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
