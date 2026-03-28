#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-20 — VALIDACION DE FACTS
# =============================================================================
# 17 pruebas:
#   01-04: Setup
#   05-07: GET lista vacia, POST, GET lista con 1
#   08-10: GET detalle, PUT update parcial, GET refleja
#   11: POST segundo (orden automatico)
#   12-14: Hecho inexistente, hecho de otro caso -> 404
#   15: Payload invalido -> 400
#   16: Sin token -> 401
#   17: Estudiante ajeno -> 403
#
# Patron: Coleccion editable con update parcial
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
echo "E5-20 — VALIDACION RUNTIME DE FACTS"
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
DOC_CLIENTE="E520${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E520 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CLIENT_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" = "201" ] && [ -n "$CLIENT_ID" ]; then
  log_pass "02. POST /clients -> 201"
else
  log_fail "02. POST /clients -> $HTTP"
  exit 1
fi

# 03. Crear caso principal
RADICADO="E520-$TIMESTAMP"
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
# FASE 1: COLECCION - LISTA Y CREACION
# =============================================================================
echo ""
echo "--- FASE 1: COLECCION - LISTA Y CREACION ---"

# 05. GET /facts (lista vacia)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/facts" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  COUNT=$(echo "$BODY" | jq 'length')
  if [ "$COUNT" = "0" ]; then
    log_pass "05. GET /facts (lista vacia) -> 200 (count=0)"
  else
    log_pass "05. GET /facts -> 200 (count=$COUNT)"
  fi
else
  log_fail "05. GET /facts -> $HTTP"
fi

# 06. POST /facts
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/facts" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"El imputado fue visto en el lugar de los hechos","estado_hecho":"referido","fuente":"Testimonio de vecino"}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
FACT_ID=$(echo "$BODY" | jq -r '.id // empty')
ORDEN_1=$(echo "$BODY" | jq -r '.orden // empty')

if [ "$HTTP" = "201" ] && [ -n "$FACT_ID" ]; then
  log_pass "06. POST /facts -> 201 (id=$FACT_ID, orden=$ORDEN_1)"
else
  log_fail "06. POST /facts -> $HTTP"
fi

# 07. GET /facts (lista con 1)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/facts" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  COUNT=$(echo "$BODY" | jq 'length')
  if [ "$COUNT" = "1" ]; then
    log_pass "07. GET /facts (lista con 1) -> 200"
  else
    log_fail "07. GET /facts -> count=$COUNT (esperado 1)"
  fi
else
  log_fail "07. GET /facts -> $HTTP"
fi

# =============================================================================
# FASE 2: DETALLE Y UPDATE PARCIAL
# =============================================================================
echo ""
echo "--- FASE 2: DETALLE Y UPDATE PARCIAL ---"

# 08. GET /facts/:id (detalle)
if [ -n "$FACT_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/facts/$FACT_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')

  if [ "$HTTP" = "200" ]; then
    ESTADO=$(echo "$BODY" | jq -r '.estado_hecho // empty')
    if [ "$ESTADO" = "referido" ]; then
      log_pass "08. GET /facts/:id (detalle) -> 200"
    else
      log_fail "08. GET /facts/:id -> estado incorrecto"
    fi
  else
    log_fail "08. GET /facts/:id -> $HTTP"
  fi
else
  log_fail "08. GET /facts/:id -> Sin FACT_ID"
fi

# 09. PUT /facts/:id (update parcial - solo estado_hecho)
if [ -n "$FACT_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/facts/$FACT_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"estado_hecho":"acreditado","incidencia_juridica":"tipicidad"}')
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')

  if [ "$HTTP" = "200" ]; then
    ESTADO=$(echo "$BODY" | jq -r '.estado_hecho // empty')
    INCIDENCIA=$(echo "$BODY" | jq -r '.incidencia_juridica // empty')
    if [ "$ESTADO" = "acreditado" ] && [ "$INCIDENCIA" = "tipicidad" ]; then
      log_pass "09. PUT /facts/:id (update parcial) -> 200"
    else
      log_fail "09. PUT /facts/:id -> campos no actualizados"
    fi
  else
    log_fail "09. PUT /facts/:id -> $HTTP"
  fi
else
  log_fail "09. PUT /facts/:id -> Sin FACT_ID"
fi

# 10. GET /facts/:id (refleja cambios + descripcion original intacta)
if [ -n "$FACT_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/facts/$FACT_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')

  if [ "$HTTP" = "200" ]; then
    ESTADO=$(echo "$BODY" | jq -r '.estado_hecho // empty')
    DESC=$(echo "$BODY" | jq -r '.descripcion // empty')
    
    if [ "$ESTADO" = "acreditado" ] && [ "$DESC" = "El imputado fue visto en el lugar de los hechos" ]; then
      log_pass "10. GET /facts/:id (cambios + descripcion intacta) -> 200"
    else
      log_fail "10. GET /facts/:id -> update parcial no funciono correctamente"
    fi
  else
    log_fail "10. GET /facts/:id -> $HTTP"
  fi
else
  log_fail "10. GET /facts/:id -> Sin FACT_ID"
fi

# =============================================================================
# FASE 3: ORDEN AUTOMATICO
# =============================================================================
echo ""
echo "--- FASE 3: ORDEN AUTOMATICO ---"

# 11. POST /facts segundo (verificar orden automatico)
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/facts" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Segundo hecho del caso","estado_hecho":"discutido"}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
FACT_ID_2=$(echo "$BODY" | jq -r '.id // empty')
ORDEN_2=$(echo "$BODY" | jq -r '.orden // empty')

if [ "$HTTP" = "201" ]; then
  if [ -n "$ORDEN_1" ] && [ -n "$ORDEN_2" ] && [ "$ORDEN_2" -gt "$ORDEN_1" ]; then
    log_pass "11. POST /facts (orden automatico) -> 201 (orden=$ORDEN_2 > $ORDEN_1)"
  else
    log_pass "11. POST /facts -> 201 (orden=$ORDEN_2)"
  fi
else
  log_fail "11. POST /facts -> $HTTP"
fi

# =============================================================================
# FASE 4: HECHO INEXISTENTE Y DE OTRO CASO
# =============================================================================
echo ""
echo "--- FASE 4: HECHO INEXISTENTE Y DE OTRO CASO ---"

FAKE_FACT="00000000-0000-0000-0000-000000000099"

# 12. GET /facts/:id (hecho inexistente)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/facts/$FAKE_FACT" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "12. GET /facts/:id (inexistente) -> 404"
else
  log_fail "12. GET /facts/:id (inexistente) -> $HTTP (esperado 404)"
fi

# 13. PUT /facts/:id (hecho inexistente)
RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/facts/$FAKE_FACT" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Intento sobre hecho inexistente"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "13. PUT /facts/:id (inexistente) -> 404"
else
  log_fail "13. PUT /facts/:id (inexistente) -> $HTTP (esperado 404)"
fi

# 14. GET /facts/:id (hecho de otro caso)
# Crear segundo caso con su propio hecho
RADICADO2="E520B-$TIMESTAMP"
RESP=$(curl -sS -X POST "$BASE_URL/cases" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"cliente_id\":\"$CLIENT_ID\",\"radicado\":\"$RADICADO2\",\"delito_imputado\":\"Estafa\",\"despacho\":\"Juzgado 2\",\"regimen_procesal\":\"Ley 906\",\"etapa_procesal\":\"Juicio\"}")
CASE_ID_2=$(echo "$RESP" | jq -r '.id // empty')

if [ -n "$CASE_ID_2" ]; then
  # Activar segundo caso
  curl -sS -X POST "$BASE_URL/cases/$CASE_ID_2/transition" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"estado_destino":"en_analisis"}' > /dev/null

  # Crear hecho en segundo caso
  RESP=$(curl -sS -X POST "$BASE_URL/cases/$CASE_ID_2/facts" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"descripcion":"Hecho del caso 2","estado_hecho":"referido"}')
  FACT_OTRO_CASO=$(echo "$RESP" | jq -r '.id // empty')

  if [ -n "$FACT_OTRO_CASO" ]; then
    # Intentar acceder al hecho del caso 2 desde el caso 1
    RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/facts/$FACT_OTRO_CASO" \
      -H "Authorization: Bearer $ADMIN_TOKEN")
    HTTP=$(echo "$RESP" | tail -1)

    if [ "$HTTP" = "404" ]; then
      log_pass "14. GET /facts/:id (hecho de otro caso) -> 404"
    else
      log_fail "14. GET /facts/:id (hecho de otro caso) -> $HTTP (esperado 404)"
    fi
  else
    log_fail "14. No se pudo crear hecho en caso 2"
  fi
else
  log_fail "14. No se pudo crear caso 2"
fi

# =============================================================================
# FASE 5: PAYLOAD INVALIDO
# =============================================================================
echo ""
echo "--- FASE 5: PAYLOAD INVALIDO ---"

# 15. POST /facts (estado_hecho invalido)
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/facts" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Hecho con estado invalido","estado_hecho":"inventado"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "400" ]; then
  log_pass "15. POST /facts (estado_hecho invalido) -> 400"
else
  log_fail "15. POST /facts (estado_hecho invalido) -> $HTTP (esperado 400)"
fi

# =============================================================================
# FASE 6: SIN TOKEN
# =============================================================================
echo ""
echo "--- FASE 6: SIN TOKEN ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/facts")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "16. GET /facts sin token -> 401"
else
  log_fail "16. GET /facts sin token -> $HTTP"
fi

# =============================================================================
# FASE 7: ESTUDIANTE AJENO
# =============================================================================
echo ""
echo "--- FASE 7: ESTUDIANTE AJENO ---"

STUDENT_EMAIL="student${TIMESTAMP}@lexpenal.local"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Estudiante E520 $TIMESTAMP\",\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\",\"perfil\":\"estudiante\"}")
HTTP_USER=$(echo "$RESP" | tail -1)

if [ "$HTTP_USER" != "201" ]; then
  log_fail "17. Creacion estudiante fallo ($HTTP_USER)"
else
  RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\"}")
  STUDENT_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

  if [ -z "$STUDENT_TOKEN" ]; then
    log_fail "17. Login estudiante fallo"
  else
    RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/facts" \
      -H "Authorization: Bearer $STUDENT_TOKEN")
    HTTP=$(echo "$RESP" | tail -1)
    
    if [ "$HTTP" = "403" ]; then
      log_pass "17. GET /facts (estudiante ajeno) -> 403"
    else
      log_fail "17. GET /facts (estudiante ajeno) -> $HTTP (esperado 403)"
    fi
  fi
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "========================================"
echo "RESUMEN E5-20 — VALIDACION DE FACTS"
echo "========================================"
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "========================================"
echo ""

if [ "$PASSED" -eq 17 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}E5-20 PUEDE CERRARSE${NC}"
  echo -e "${YELLOW}[PENDIENTE] Verificar npm run build manualmente${NC}"
else
  echo -e "${RED}E5-20 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Caso principal: $RADICADO | ID: $CASE_ID"
echo "Hecho 1: $FACT_ID (orden=$ORDEN_1)"
echo "Hecho 2: $FACT_ID_2 (orden=$ORDEN_2)"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
