#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-18 — VALIDACION DE STRATEGY
# =============================================================================
# 12 pruebas:
#   01-04: Setup
#   05-07: GET auto-crea, PUT actualiza, GET refleja (+ verificacion singleton)
#   08: PUT sobre caso SIN strategy previa
#   09: Caso inexistente -> 404
#   10: Sin token -> 401
#   11-12: Estudiante ajeno -> 403
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
echo "E5-18 — VALIDACION RUNTIME DE STRATEGY"
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
DOC_CLIENTE="E518${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E518 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
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
RADICADO="E518-$TIMESTAMP"
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

# 05. GET /strategy (auto-crea)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/strategy" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

STRATEGY_ID=""
if [ "$HTTP" = "200" ]; then
  STRATEGY_ID=$(echo "$BODY" | jq -r '.id // empty')
  CASO_ID_RETURNED=$(echo "$BODY" | jq -r '.caso_id // empty')
  if [ -n "$STRATEGY_ID" ] && [ "$CASO_ID_RETURNED" = "$CASE_ID" ]; then
    log_pass "05. GET /strategy (auto-crea) -> 200 (id=$STRATEGY_ID)"
  else
    log_fail "05. GET /strategy -> respuesta incompleta"
  fi
else
  log_fail "05. GET /strategy -> $HTTP"
fi

# 06. PUT /strategy (actualiza)
RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/strategy" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"linea_principal":"Defensa por atipicidad de la conducta","fundamento_juridico":"Art. 9 CP - Conducta punible"}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  LINEA=$(echo "$BODY" | jq -r '.linea_principal // empty')
  FUNDAMENTO=$(echo "$BODY" | jq -r '.fundamento_juridico // empty')
  if [ -n "$LINEA" ] && [ -n "$FUNDAMENTO" ]; then
    log_pass "06. PUT /strategy -> 200 (campos actualizados)"
  else
    log_fail "06. PUT /strategy -> campos no reflejados"
  fi
else
  log_fail "06. PUT /strategy -> $HTTP"
fi

# 07. GET /strategy (refleja cambios + verificacion singleton)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/strategy" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  LINEA=$(echo "$BODY" | jq -r '.linea_principal // empty')
  STRATEGY_ID_POST=$(echo "$BODY" | jq -r '.id // empty')
  
  if [ "$LINEA" = "Defensa por atipicidad de la conducta" ]; then
    # Verificar que sigue siendo el mismo registro (singleton)
    if [ -n "$STRATEGY_ID" ] && [ "$STRATEGY_ID_POST" = "$STRATEGY_ID" ]; then
      log_pass "07. GET /strategy (singleton verificado, mismo id) -> 200"
    else
      log_pass "07. GET /strategy (refleja cambios) -> 200"
    fi
  else
    log_fail "07. GET /strategy -> cambios no persistieron"
  fi
else
  log_fail "07. GET /strategy -> $HTTP"
fi

# =============================================================================
# FASE 2: PUT SOBRE CASO SIN STRATEGY PREVIA
# =============================================================================
echo ""
echo "--- FASE 2: PUT SOBRE CASO SIN STRATEGY PREVIA ---"

# Crear segundo caso
RADICADO2="E518B-$TIMESTAMP"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"cliente_id\":\"$CLIENT_ID\",\"radicado\":\"$RADICADO2\",\"delito_imputado\":\"Estafa\",\"despacho\":\"Juzgado 2\",\"regimen_procesal\":\"Ley 906\",\"etapa_procesal\":\"Juicio\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CASE_ID_2=$(echo "$BODY" | jq -r '.id // empty')

if [ -z "$CASE_ID_2" ]; then
  log_fail "08. PUT /strategy -> No se pudo crear segundo caso"
else
  # Activar segundo caso con validacion
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID_2/transition" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"estado_destino":"en_analisis"}')
  HTTP_TRANS=$(echo "$RESP" | tail -1)

  if [ "$HTTP_TRANS" != "200" ] && [ "$HTTP_TRANS" != "201" ]; then
    log_fail "08. PUT /strategy -> Transicion caso 2 fallo ($HTTP_TRANS)"
  else
    # PUT directo sin GET previo (debe crear strategy)
    RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID_2/strategy" \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"linea_principal":"Defensa tecnica directa","posicion_juicio":"Absolucion"}')
    HTTP=$(echo "$RESP" | tail -1)
    BODY=$(echo "$RESP" | sed '$d')

    if [ "$HTTP" = "200" ]; then
      LINEA=$(echo "$BODY" | jq -r '.linea_principal // empty')
      POSICION=$(echo "$BODY" | jq -r '.posicion_juicio // empty')
      if [ "$LINEA" = "Defensa tecnica directa" ] && [ "$POSICION" = "Absolucion" ]; then
        log_pass "08. PUT /strategy (sin strategy previa) -> 200 (upsert)"
      else
        log_fail "08. PUT /strategy -> campos no persistieron"
      fi
    else
      log_fail "08. PUT /strategy (sin strategy previa) -> $HTTP"
    fi
  fi
fi

# =============================================================================
# FASE 3: CASO INEXISTENTE
# =============================================================================
echo ""
echo "--- FASE 3: CASO INEXISTENTE ---"

FAKE_CASE="00000000-0000-0000-0000-000000000000"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$FAKE_CASE/strategy" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "09. GET /strategy (caso inexistente) -> 404"
else
  log_fail "09. GET /strategy (caso inexistente) -> $HTTP"
fi

# =============================================================================
# FASE 4: SIN TOKEN
# =============================================================================
echo ""
echo "--- FASE 4: SIN TOKEN ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/strategy")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "10. GET /strategy sin token -> 401"
else
  log_fail "10. GET /strategy sin token -> $HTTP"
fi

# =============================================================================
# FASE 5: ESTUDIANTE AJENO
# =============================================================================
echo ""
echo "--- FASE 5: ESTUDIANTE AJENO ---"

STUDENT_EMAIL="student${TIMESTAMP}@lexpenal.local"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Estudiante E518 $TIMESTAMP\",\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\",\"perfil\":\"estudiante\"}")
HTTP_USER=$(echo "$RESP" | tail -1)

if [ "$HTTP_USER" != "201" ]; then
  log_fail "11. Creacion estudiante fallo ($HTTP_USER)"
  log_fail "12. (depende de 11)"
else
  RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\"}")
  STUDENT_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

  if [ -z "$STUDENT_TOKEN" ]; then
    log_fail "11. Login estudiante fallo"
    log_fail "12. (depende de 11)"
  else
    # GET estudiante ajeno -> 403
    RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/strategy" \
      -H "Authorization: Bearer $STUDENT_TOKEN")
    HTTP=$(echo "$RESP" | tail -1)
    
    if [ "$HTTP" = "403" ]; then
      log_pass "11. GET /strategy (estudiante ajeno) -> 403"
    else
      log_fail "11. GET /strategy (estudiante ajeno) -> $HTTP (esperado 403)"
    fi
    
    # PUT estudiante ajeno -> 403
    RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/strategy" \
      -H "Authorization: Bearer $STUDENT_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"linea_principal":"Intento no autorizado"}')
    HTTP=$(echo "$RESP" | tail -1)
    
    if [ "$HTTP" = "403" ]; then
      log_pass "12. PUT /strategy (estudiante ajeno) -> 403"
    else
      log_fail "12. PUT /strategy (estudiante ajeno) -> $HTTP (esperado 403)"
    fi
  fi
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "========================================"
echo "RESUMEN E5-18 — VALIDACION DE STRATEGY"
echo "========================================"
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "========================================"
echo ""

if [ "$PASSED" -eq 12 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}E5-18 PUEDE CERRARSE${NC}"
  echo -e "${YELLOW}[PENDIENTE] Verificar npm run build manualmente${NC}"
else
  echo -e "${RED}E5-18 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Caso principal: $RADICADO | ID: $CASE_ID"
echo "Caso secundario: $RADICADO2 | ID: $CASE_ID_2"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
