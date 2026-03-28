#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-09 — VALIDACIÓN DE SUBJECTS
# =============================================================================
# VALIDA:
#   - POST /subjects crea sujeto → 201
#   - GET /subjects lista paginada → 200
#   - GET /subjects/:id retorna detalle → 200
#   - GET /subjects con caso inexistente → 404
#   - POST /subjects con caso inexistente → 404
#   - GET /subjects/:id con caso inexistente → 404
#   - GET /subjects/:id con sujeto inexistente → 404
#   - Fuga entre casos → 404
#   - Página fuera de rango → 200 con data: []
#   - Filtro tipo funcional → 200 filtrado
#   - Estructura paginada correcta
#   - Acceso sin token → 401
#   - npm run build → verde (verificar manualmente)
#
# NOTA: Este módulo NO tiene control de perfil (403).
#       Solo tiene JwtAuthGuard (401 por no autenticado).
#
# Requiere: jq instalado, backend en puerto 3001
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
echo "=========================================="
echo "E5-09 — VALIDACIÓN RUNTIME DE SUBJECTS"
echo "=========================================="
echo "Timestamp: $TIMESTAMP"
echo ""

# =============================================================================
# SETUP
# =============================================================================
log_info "Fase 0: Setup..."

# Login admin
RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@lexpenal.local","password":"CambiarEnProduccion_2026!"}')
TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -z "$TOKEN" ]; then
  echo -e "${RED}[ERROR] No se obtuvo token. Abortando.${NC}"
  exit 1
fi
log_pass "01. Login admin → 200"

# Crear cliente y caso de prueba
DOC_CLIENTE="E509${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E509 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CLIENT_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" = "201" ] && [ -n "$CLIENT_ID" ]; then
  log_pass "02. POST /clients → 201"
else
  log_fail "02. POST /clients → $HTTP"
  exit 1
fi

RADICADO="E509-$TIMESTAMP"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"cliente_id\":\"$CLIENT_ID\",\"radicado\":\"$RADICADO\",\"delito_imputado\":\"Hurto\",\"despacho\":\"Juzgado 1\",\"regimen_procesal\":\"Ley 906\",\"etapa_procesal\":\"Investigacion\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CASE_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" = "201" ] && [ -n "$CASE_ID" ]; then
  log_pass "03. POST /cases → 201"
else
  log_fail "03. POST /cases → $HTTP"
  exit 1
fi

# Activar caso (borrador → en_analisis)
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"estado_destino":"en_analisis"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
  log_pass "04. Activar caso → $HTTP"
else
  log_fail "04. Activar caso → $HTTP"
fi

# =============================================================================
# FASE 1: POST /subjects → 201
# =============================================================================
echo ""
echo "--- FASE 1: CREAR SUJETO ---"

RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/subjects" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tipo":"victima","nombre":"María García López","identificacion":"1234567890","tipo_identificacion":"CC","contacto":"3001234567","direccion":"Calle 123","notas":"Víctima principal"}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "201" ]; then
  SUBJECT_ID=$(echo "$BODY" | jq -r '.id // empty')
  SUBJECT_TIPO=$(echo "$BODY" | jq -r '.tipo // empty')
  
  if [ -n "$SUBJECT_ID" ] && [ "$SUBJECT_TIPO" = "victima" ]; then
    log_pass "05. POST /subjects → 201 (tipo=$SUBJECT_TIPO)"
  else
    log_fail "05. POST /subjects → respuesta incompleta"
  fi
else
  log_fail "05. POST /subjects → $HTTP"
  log_body "$BODY"
  SUBJECT_ID=""
fi

# Crear segundo sujeto (testigo) para verificar filtros
curl -sS -X POST "$BASE_URL/cases/$CASE_ID/subjects" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tipo":"testigo","nombre":"Juan Pérez Ruiz"}' > /dev/null

# =============================================================================
# FASE 2: GET /subjects → 200 (lista paginada)
# =============================================================================
echo ""
echo "--- FASE 2: LISTAR SUJETOS ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/subjects" \
  -H "Authorization: Bearer $TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  # Verificar estructura paginada
  HAS_DATA=$(echo "$BODY" | jq 'has("data")')
  HAS_TOTAL=$(echo "$BODY" | jq 'has("total")')
  HAS_PAGE=$(echo "$BODY" | jq 'has("page")')
  HAS_PER_PAGE=$(echo "$BODY" | jq 'has("per_page")')
  
  if [ "$HAS_DATA" = "true" ] && [ "$HAS_TOTAL" = "true" ] && \
     [ "$HAS_PAGE" = "true" ] && [ "$HAS_PER_PAGE" = "true" ]; then
    TOTAL=$(echo "$BODY" | jq '.total')
    log_pass "06. GET /subjects → 200 (total=$TOTAL, estructura correcta)"
  else
    log_fail "06. GET /subjects → estructura incorrecta (falta data/total/page/per_page)"
  fi
else
  log_fail "06. GET /subjects → $HTTP"
fi

# =============================================================================
# FASE 3: GET /subjects/:id → 200 (detalle)
# =============================================================================
echo ""
echo "--- FASE 3: DETALLE DE SUJETO ---"

if [ -n "$SUBJECT_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/subjects/$SUBJECT_ID" \
    -H "Authorization: Bearer $TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  
  if [ "$HTTP" = "200" ]; then
    RETURNED_ID=$(echo "$BODY" | jq -r '.id // empty')
    RETURNED_NOMBRE=$(echo "$BODY" | jq -r '.nombre // empty')
    
    if [ "$RETURNED_ID" = "$SUBJECT_ID" ]; then
      log_pass "07. GET /subjects/:id → 200 (nombre=$RETURNED_NOMBRE)"
    else
      log_fail "07. GET /subjects/:id → ID no coincide"
    fi
  else
    log_fail "07. GET /subjects/:id → $HTTP"
  fi
else
  log_fail "07. GET /subjects/:id → Sin SUBJECT_ID"
fi

# =============================================================================
# FASE 4: CASO INEXISTENTE → 404
# =============================================================================
echo ""
echo "--- FASE 4: CASO INEXISTENTE ---"

FAKE_CASE="00000000-0000-0000-0000-000000000000"

# GET /subjects con caso inexistente
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$FAKE_CASE/subjects" \
  -H "Authorization: Bearer $TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "08. GET /subjects (caso inexistente) → 404"
else
  log_fail "08. GET /subjects (caso inexistente) → $HTTP (esperado 404)"
fi

# POST /subjects con caso inexistente
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$FAKE_CASE/subjects" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tipo":"testigo","nombre":"Test"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "09. POST /subjects (caso inexistente) → 404"
else
  log_fail "09. POST /subjects (caso inexistente) → $HTTP (esperado 404)"
fi

# GET /subjects/:id con caso inexistente
if [ -n "$SUBJECT_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$FAKE_CASE/subjects/$SUBJECT_ID" \
    -H "Authorization: Bearer $TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "404" ]; then
    log_pass "10. GET /subjects/:id (caso inexistente) → 404"
  else
    log_fail "10. GET /subjects/:id (caso inexistente) → $HTTP (esperado 404)"
  fi
else
  log_fail "10. GET /subjects/:id (caso inexistente) → Sin SUBJECT_ID"
fi

# =============================================================================
# FASE 5: SUJETO INEXISTENTE → 404
# =============================================================================
echo ""
echo "--- FASE 5: SUJETO INEXISTENTE ---"

FAKE_SUBJECT="00000000-0000-0000-0000-000000000001"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/subjects/$FAKE_SUBJECT" \
  -H "Authorization: Bearer $TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "11. GET /subjects/:id (sujeto inexistente) → 404"
else
  log_fail "11. GET /subjects/:id (sujeto inexistente) → $HTTP (esperado 404)"
fi

# =============================================================================
# FASE 6: FUGA ENTRE CASOS → 404
# =============================================================================
echo ""
echo "--- FASE 6: FUGA ENTRE CASOS ---"

# Crear segundo caso
RADICADO2="E509B-$TIMESTAMP"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"cliente_id\":\"$CLIENT_ID\",\"radicado\":\"$RADICADO2\",\"delito_imputado\":\"Estafa\",\"despacho\":\"Juzgado 2\",\"regimen_procesal\":\"Ley 906\",\"etapa_procesal\":\"Juicio\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CASE_ID_2=$(echo "$BODY" | jq -r '.id // empty')

if [ -n "$CASE_ID_2" ] && [ -n "$SUBJECT_ID" ]; then
  # Intentar acceder al sujeto del caso 1 desde el caso 2
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID_2/subjects/$SUBJECT_ID" \
    -H "Authorization: Bearer $TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "404" ]; then
    log_pass "12. Fuga entre casos → 404 ✓ PROTEGIDO"
  else
    log_fail "12. Fuga entre casos → $HTTP (esperado 404, VULNERABILIDAD)"
  fi
else
  log_fail "12. Fuga entre casos → No se pudo crear segundo caso"
fi

# =============================================================================
# FASE 7: PÁGINA FUERA DE RANGO → 200 con data: []
# =============================================================================
echo ""
echo "--- FASE 7: PÁGINA FUERA DE RANGO ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/subjects?page=999" \
  -H "Authorization: Bearer $TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  DATA_LENGTH=$(echo "$BODY" | jq '.data | length')
  if [ "$DATA_LENGTH" = "0" ]; then
    log_pass "13. Página fuera de rango → 200 con data: []"
  else
    log_fail "13. Página fuera de rango → data no vacía ($DATA_LENGTH elementos)"
  fi
else
  log_fail "13. Página fuera de rango → $HTTP (esperado 200)"
fi

# =============================================================================
# FASE 8: FILTRO POR TIPO → 200 FILTRADO
# =============================================================================
echo ""
echo "--- FASE 8: FILTRO POR TIPO ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/subjects?tipo=victima" \
  -H "Authorization: Bearer $TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  # Verificar que todos los resultados son del tipo solicitado
  WRONG_TYPE=$(echo "$BODY" | jq '[.data[] | select(.tipo != "victima")] | length')
  if [ "$WRONG_TYPE" = "0" ]; then
    FILTERED_COUNT=$(echo "$BODY" | jq '.data | length')
    log_pass "14. Filtro tipo=victima → 200 ($FILTERED_COUNT resultados, todos correctos)"
  else
    log_fail "14. Filtro tipo=victima → hay $WRONG_TYPE resultados con tipo incorrecto"
  fi
else
  log_fail "14. Filtro tipo=victima → $HTTP"
fi

# =============================================================================
# FASE 9: ACCESO SIN TOKEN → 401
# =============================================================================
echo ""
echo "--- FASE 9: ACCESO SIN TOKEN ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/subjects")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "15. GET /subjects sin token → 401"
else
  log_fail "15. GET /subjects sin token → $HTTP (esperado 401)"
fi

RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/subjects" \
  -H "Content-Type: application/json" \
  -d '{"tipo":"testigo","nombre":"Sin Auth"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "16. POST /subjects sin token → 401"
else
  log_fail "16. POST /subjects sin token → $HTTP (esperado 401)"
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "=============================================="
echo "RESUMEN E5-09 — VALIDACIÓN DE SUBJECTS"
echo "=============================================="
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "=============================================="
echo ""

echo "CRITERIOS E5-09:"
echo ""
if [ "$PASSED" -eq 16 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "  ${GREEN}✓ POST /subjects → 201${NC}"
  echo -e "  ${GREEN}✓ GET /subjects → 200 (estructura paginada)${NC}"
  echo -e "  ${GREEN}✓ GET /subjects/:id → 200${NC}"
  echo -e "  ${GREEN}✓ Caso inexistente → 404 (GET, POST, GET/:id)${NC}"
  echo -e "  ${GREEN}✓ Sujeto inexistente → 404${NC}"
  echo -e "  ${GREEN}✓ Fuga entre casos → 404${NC}"
  echo -e "  ${GREEN}✓ Página fuera de rango → 200 con data: []${NC}"
  echo -e "  ${GREEN}✓ Filtro tipo funcional${NC}"
  echo -e "  ${GREEN}✓ Acceso sin token → 401${NC}"
  echo ""
  echo -e "${GREEN}E5-09 PUEDE CERRARSE${NC}"
  echo -e "${YELLOW}[PENDIENTE] Verificar npm run build manualmente${NC}"
else
  echo -e "  ${RED}✗ Criterios no cumplidos (PASSED=$PASSED, FAILED=$FAILED)${NC}"
  echo ""
  echo -e "${RED}E5-09 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Caso: $RADICADO | ID: $CASE_ID"
echo "Sujeto: $SUBJECT_ID"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
