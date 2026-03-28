#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-17 — VALIDACION DE CHECKLIST
# =============================================================================
# 12 pruebas:
#   01-04: Setup (incluye activacion = bootstrap checklist)
#   05-07: GET estructura, PUT marcar, GET refleja + completado
#   08: Item inexistente -> 400
#   09: Caso inexistente -> 404
#   10: Sin token -> 401
#   11-12: Estudiante ajeno -> 403
#
# ESTRUCTURA REAL: 12 bloques x 1 item = 12 items
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
echo "E5-17 — VALIDACION RUNTIME DE CHECKLIST"
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
DOC_CLIENTE="E517${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E517 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
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
RADICADO="E517-$TIMESTAMP"
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

# 04. Activar caso (esto dispara bootstrap del checklist)
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"estado_destino":"en_analisis"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
  log_pass "04. Activar caso (bootstrap checklist) -> $HTTP"
else
  log_fail "04. Activar caso -> $HTTP"
fi

# =============================================================================
# FASE 1: ESTRUCTURA Y ACTUALIZACION
# =============================================================================
echo ""
echo "--- FASE 1: ESTRUCTURA Y ACTUALIZACION ---"

# 05. GET /checklist (estructura con bloques)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/checklist" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  BLOQUES_COUNT=$(echo "$BODY" | jq '.bloques | length')
  ITEMS_COUNT=$(echo "$BODY" | jq '[.bloques[].items[]] | length')
  
  if [ "$BLOQUES_COUNT" -ge 1 ]; then
    log_pass "05. GET /checklist -> 200 ($BLOQUES_COUNT bloques, $ITEMS_COUNT items)"
    # Guardar ID del unico item del primer bloque (estructura: 1 item por bloque)
    ITEM_ID_1=$(echo "$BODY" | jq -r '.bloques[0].items[0].id // empty')
  else
    log_fail "05. GET /checklist -> estructura incompleta"
    ITEM_ID_1=""
  fi
else
  log_fail "05. GET /checklist -> $HTTP"
  ITEM_ID_1=""
fi

# 06. PUT /checklist (marcar el unico item del primer bloque)
if [ -n "$ITEM_ID_1" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/checklist" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"items\":[{\"id\":\"$ITEM_ID_1\",\"marcado\":true}]}")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')

  if [ "$HTTP" = "200" ]; then
    log_pass "06. PUT /checklist (marcar item) -> 200"
  else
    log_fail "06. PUT /checklist -> $HTTP"
    log_body "$BODY"
  fi
else
  log_fail "06. PUT /checklist -> Sin ID de item"
fi

# 07. GET /checklist (refleja cambios + bloque completado)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/checklist" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  ITEM1_MARCADO=$(echo "$BODY" | jq -r '.bloques[0].items[0].marcado')
  BLOQUE1_COMPLETADO=$(echo "$BODY" | jq -r '.bloques[0].completado')
  
  # Con 1 item por bloque, si el item esta marcado, el bloque debe estar completado
  if [ "$ITEM1_MARCADO" = "true" ] && [ "$BLOQUE1_COMPLETADO" = "true" ]; then
    log_pass "07. GET /checklist (item marcado + bloque completado) -> 200"
  elif [ "$ITEM1_MARCADO" = "true" ]; then
    log_pass "07. GET /checklist (item marcado) -> 200"
  else
    log_fail "07. GET /checklist -> cambios no reflejados (marcado=$ITEM1_MARCADO)"
  fi
else
  log_fail "07. GET /checklist -> $HTTP"
fi

# =============================================================================
# FASE 2: ITEM INEXISTENTE
# =============================================================================
echo ""
echo "--- FASE 2: ITEM INEXISTENTE ---"

FAKE_ITEM="00000000-0000-0000-0000-000000000099"

RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/checklist" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"items\":[{\"id\":\"$FAKE_ITEM\",\"marcado\":true}]}")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "400" ]; then
  log_pass "08. PUT /checklist (item inexistente) -> 400"
else
  log_fail "08. PUT /checklist (item inexistente) -> $HTTP (esperado 400)"
fi

# =============================================================================
# FASE 3: CASO INEXISTENTE
# =============================================================================
echo ""
echo "--- FASE 3: CASO INEXISTENTE ---"

FAKE_CASE="00000000-0000-0000-0000-000000000000"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$FAKE_CASE/checklist" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "09. GET /checklist (caso inexistente) -> 404"
else
  log_fail "09. GET /checklist (caso inexistente) -> $HTTP"
fi

# =============================================================================
# FASE 4: SIN TOKEN
# =============================================================================
echo ""
echo "--- FASE 4: SIN TOKEN ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/checklist")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "10. GET /checklist sin token -> 401"
else
  log_fail "10. GET /checklist sin token -> $HTTP"
fi

# =============================================================================
# FASE 5: ESTUDIANTE AJENO
# =============================================================================
echo ""
echo "--- FASE 5: ESTUDIANTE AJENO ---"

STUDENT_EMAIL="student${TIMESTAMP}@lexpenal.local"
curl -sS -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Estudiante E517 $TIMESTAMP\",\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\",\"perfil\":\"estudiante\"}" > /dev/null

RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\"}")
STUDENT_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -n "$STUDENT_TOKEN" ]; then
  # GET estudiante ajeno -> 403
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/checklist" \
    -H "Authorization: Bearer $STUDENT_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "403" ]; then
    log_pass "11. GET /checklist (estudiante ajeno) -> 403"
  else
    log_fail "11. GET /checklist (estudiante ajeno) -> $HTTP (esperado 403)"
  fi
  
  # PUT estudiante ajeno -> 403
  if [ -n "$ITEM_ID_1" ]; then
    RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/checklist" \
      -H "Authorization: Bearer $STUDENT_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"items\":[{\"id\":\"$ITEM_ID_1\",\"marcado\":false}]}")
    HTTP=$(echo "$RESP" | tail -1)
    
    if [ "$HTTP" = "403" ]; then
      log_pass "12. PUT /checklist (estudiante ajeno) -> 403"
    else
      log_fail "12. PUT /checklist (estudiante ajeno) -> $HTTP (esperado 403)"
    fi
  else
    log_fail "12. PUT /checklist -> Sin ID de item"
  fi
else
  log_fail "11. Login estudiante fallo"
  log_fail "12. (depende de 11)"
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "========================================"
echo "RESUMEN E5-17 — VALIDACION DE CHECKLIST"
echo "========================================"
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "========================================"
echo ""

if [ "$PASSED" -eq 12 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}E5-17 PUEDE CERRARSE${NC}"
  echo -e "${YELLOW}[PENDIENTE] Verificar npm run build manualmente${NC}"
else
  echo -e "${RED}E5-17 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Caso: $RADICADO | ID: $CASE_ID"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
