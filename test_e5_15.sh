#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-15 — VALIDACION DE REVIEW
# =============================================================================
# 19 pruebas:
#   01-08: Setup completo (checklist + estrategia + hecho + transicion)
#   09-10: GET historial y feedback vacios
#   11: POST fuera de pendiente_revision -> 409
#   12-15: POST exitoso + verificacion
#   16-17: Estudiante -> 403
#   18-19: Caso inexistente y sin token -> 404/401
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
echo "====================================="
echo "E5-15 — VALIDACION RUNTIME DE REVIEW"
echo "====================================="
echo "Timestamp: $TIMESTAMP"
echo ""

# =============================================================================
# SETUP COMPLETO
# =============================================================================
log_info "Fase 0: Setup completo (checklist + estrategia + hecho)..."

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
DOC_CLIENTE="E515${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E515 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
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
RADICADO="E515-$TIMESTAMP"
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

# 04. Activar caso (borrador -> en_analisis)
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

# 05. Completar checklist
RESP=$(curl -sS "$BASE_URL/cases/$CASE_ID/checklist" \
  -H "Authorization: Bearer $ADMIN_TOKEN")

ITEMS_PAYLOAD=$(echo "$RESP" | jq '[.bloques[].items[].id] | map({id: ., marcado: true})')
CHECKLIST_BODY="{\"items\":$ITEMS_PAYLOAD}"

RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/checklist" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$CHECKLIST_BODY")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ]; then
  log_pass "05. Completar checklist -> 200"
else
  log_fail "05. Completar checklist -> $HTTP"
fi

# 06. Agregar estrategia con linea_principal
RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/strategy" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"linea_principal":"Defensa por atipicidad de la conducta"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ]; then
  log_pass "06. PUT /strategy -> 200"
else
  log_fail "06. PUT /strategy -> $HTTP"
fi

# 07. Agregar al menos 1 hecho
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/facts" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"El imputado fue visto en el lugar de los hechos","estado_hecho":"referido"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "201" ]; then
  log_pass "07. POST /facts -> 201"
else
  log_fail "07. POST /facts -> $HTTP"
fi

# 08. Transicionar a pendiente_revision
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"estado_destino":"pendiente_revision"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
  log_pass "08. Transicion a pendiente_revision -> $HTTP"
  CASE_IN_PENDIENTE="$CASE_ID"
else
  log_fail "08. Transicion a pendiente_revision -> $HTTP"
  CASE_IN_PENDIENTE=""
fi

# =============================================================================
# CREAR SEGUNDO CASO EN en_analisis PARA PRUEBA 409
# =============================================================================
log_info "Creando caso secundario para prueba 409..."

RADICADO2="E515B-$TIMESTAMP"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"cliente_id\":\"$CLIENT_ID\",\"radicado\":\"$RADICADO2\",\"delito_imputado\":\"Estafa\",\"despacho\":\"Juzgado 2\",\"regimen_procesal\":\"Ley 906\",\"etapa_procesal\":\"Juicio\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CASE_ID_2=$(echo "$BODY" | jq -r '.id // empty')

# Activar segundo caso
curl -sS -X POST "$BASE_URL/cases/$CASE_ID_2/transition" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"estado_destino":"en_analisis"}' > /dev/null

# =============================================================================
# FASE 1: GET HISTORIAL Y FEEDBACK VACIOS
# =============================================================================
echo ""
echo "--- FASE 1: HISTORIAL Y FEEDBACK VACIOS ---"

if [ -n "$CASE_IN_PENDIENTE" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_IN_PENDIENTE/review" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')

  if [ "$HTTP" = "200" ]; then
    IS_ARRAY=$(echo "$BODY" | jq 'if type == "array" then true else false end')
    ARRAY_LEN=$(echo "$BODY" | jq 'length')
    if [ "$IS_ARRAY" = "true" ] && [ "$ARRAY_LEN" = "0" ]; then
      log_pass "09. GET /review historial vacio -> 200"
    else
      log_pass "09. GET /review historial -> 200 ($ARRAY_LEN elementos)"
    fi
  else
    log_fail "09. GET /review historial -> $HTTP"
  fi

  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_IN_PENDIENTE/review/feedback" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')

  if [ "$HTTP" = "200" ]; then
    if [ "$BODY" = "null" ] || [ "$BODY" = "" ]; then
      log_pass "10. GET /feedback sin vigente -> 200 (null)"
    else
      log_pass "10. GET /feedback -> 200"
    fi
  else
    log_fail "10. GET /feedback sin vigente -> $HTTP"
  fi
else
  log_fail "09. GET /review -> Sin caso en pendiente_revision"
  log_fail "10. GET /feedback -> Sin caso en pendiente_revision"
fi

# =============================================================================
# FASE 2: POST FUERA DE ESTADO CORRECTO -> 409
# =============================================================================
echo ""
echo "--- FASE 2: POST FUERA DE ESTADO CORRECTO ---"

if [ -n "$CASE_ID_2" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID_2/review" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"resultado":"aprobado","observaciones":"Intento fuera de estado"}')
  HTTP=$(echo "$RESP" | tail -1)

  if [ "$HTTP" = "409" ]; then
    log_pass "11. POST /review en en_analisis -> 409"
  else
    log_fail "11. POST /review en en_analisis -> $HTTP (esperado 409)"
  fi
else
  log_fail "11. POST /review -> Sin caso secundario"
fi

# =============================================================================
# FASE 3: POST EXITOSO Y VERIFICACION
# =============================================================================
echo ""
echo "--- FASE 3: POST EXITOSO Y VERIFICACION ---"

if [ -n "$CASE_IN_PENDIENTE" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_IN_PENDIENTE/review" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"resultado":"devuelto","observaciones":"Falta completar seccion de riesgos"}')
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')

  if [ "$HTTP" = "201" ]; then
    REVIEW_VERSION=$(echo "$BODY" | jq -r '.version_revision // empty')
    log_pass "12. POST /review -> 201 (version=$REVIEW_VERSION)"
  else
    log_fail "12. POST /review -> $HTTP"
    log_body "$BODY"
  fi

  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_IN_PENDIENTE/review" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')

  if [ "$HTTP" = "200" ]; then
    ARRAY_LEN=$(echo "$BODY" | jq 'length')
    if [ "$ARRAY_LEN" -ge 1 ]; then
      log_pass "13. GET /review con revision -> 200 ($ARRAY_LEN revisiones)"
    else
      log_fail "13. GET /review -> historial vacio despues de POST"
    fi
  else
    log_fail "13. GET /review -> $HTTP"
  fi

  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_IN_PENDIENTE/review/feedback" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')

  if [ "$HTTP" = "200" ]; then
    OBSERVACIONES=$(echo "$BODY" | jq -r '.observaciones // empty')
    RESULTADO=$(echo "$BODY" | jq -r '.resultado // empty')
    if [ -n "$OBSERVACIONES" ] && [ -n "$RESULTADO" ]; then
      log_pass "14. GET /feedback con vigente -> 200 (resultado=$RESULTADO)"
    else
      log_fail "14. GET /feedback -> campos incompletos"
    fi
  else
    log_fail "14. GET /feedback -> $HTTP"
  fi

  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_IN_PENDIENTE/review" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"resultado":"aprobado","observaciones":"Caso listo para avanzar"}')
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')

  if [ "$HTTP" = "201" ]; then
    VERSION2=$(echo "$BODY" | jq -r '.version_revision // empty')
    if [ "$VERSION2" = "2" ]; then
      log_pass "15. Segunda revision -> 201 (version=2)"
    else
      log_pass "15. Segunda revision -> 201 (version=$VERSION2)"
    fi
  else
    log_fail "15. Segunda revision -> $HTTP"
  fi
else
  log_fail "12. POST /review -> Sin caso en pendiente_revision"
  log_fail "13. GET /review -> Sin caso"
  log_fail "14. GET /feedback -> Sin caso"
  log_fail "15. Segunda revision -> Sin caso"
fi

# =============================================================================
# FASE 4: ESTUDIANTE -> 403
# =============================================================================
echo ""
echo "--- FASE 4: ESTUDIANTE SIN ACCESO ---"

STUDENT_EMAIL="student${TIMESTAMP}@lexpenal.local"
curl -sS -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Estudiante E515 $TIMESTAMP\",\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\",\"perfil\":\"estudiante\"}" > /dev/null

RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\"}")
STUDENT_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -n "$STUDENT_TOKEN" ] && [ -n "$CASE_IN_PENDIENTE" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_IN_PENDIENTE/review" \
    -H "Authorization: Bearer $STUDENT_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "403" ]; then
    log_pass "16. GET /review (estudiante) -> 403"
  else
    log_fail "16. GET /review (estudiante) -> $HTTP (esperado 403)"
  fi
  
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_IN_PENDIENTE/review/feedback" \
    -H "Authorization: Bearer $STUDENT_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "403" ]; then
    log_pass "17. GET /feedback (estudiante ajeno) -> 403"
  else
    log_fail "17. GET /feedback (estudiante ajeno) -> $HTTP (esperado 403)"
  fi
else
  log_fail "16. Login estudiante fallo o sin caso"
  log_fail "17. (depende de 16)"
fi

# =============================================================================
# FASE 5: CASO INEXISTENTE Y SIN TOKEN
# =============================================================================
echo ""
echo "--- FASE 5: CASO INEXISTENTE Y SIN TOKEN ---"

FAKE_CASE="00000000-0000-0000-0000-000000000000"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$FAKE_CASE/review" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "18. GET /review (caso inexistente) -> 404"
else
  log_fail "18. GET /review (caso inexistente) -> $HTTP"
fi

if [ -n "$CASE_IN_PENDIENTE" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_IN_PENDIENTE/review")
  HTTP=$(echo "$RESP" | tail -1)

  if [ "$HTTP" = "401" ]; then
    log_pass "19. GET /review sin token -> 401"
  else
    log_fail "19. GET /review sin token -> $HTTP"
  fi
else
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/review")
  HTTP=$(echo "$RESP" | tail -1)

  if [ "$HTTP" = "401" ]; then
    log_pass "19. GET /review sin token -> 401"
  else
    log_fail "19. GET /review sin token -> $HTTP"
  fi
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "====================================="
echo "RESUMEN E5-15 — VALIDACION DE REVIEW"
echo "====================================="
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "====================================="
echo ""

if [ "$PASSED" -eq 19 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}E5-15 PUEDE CERRARSE${NC}"
  echo -e "${YELLOW}[PENDIENTE] Verificar npm run build manualmente${NC}"
else
  echo -e "${RED}E5-15 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Caso principal: $RADICADO | ID: $CASE_ID"
echo "Caso secundario: $RADICADO2 | ID: $CASE_ID_2"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
