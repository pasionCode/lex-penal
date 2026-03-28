#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-14 — VALIDACION DE RISKS
# =============================================================================
# 20 pruebas:
#   01-04: Setup
#   05-08: CRUD basico
#   09-10: Regla prioridad critica
#   11-14: Caso inexistente
#   15: Riesgo inexistente
#   16: Fuga entre casos
#   17-18: Sin token
#   19-20: Estudiante caso ajeno
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
echo "===================================="
echo "E5-14 — VALIDACION RUNTIME DE RISKS"
echo "===================================="
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

DOC_CLIENTE="E514${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E514 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CLIENT_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" = "201" ] && [ -n "$CLIENT_ID" ]; then
  log_pass "02. POST /clients -> 201"
else
  log_fail "02. POST /clients -> $HTTP"
  exit 1
fi

RADICADO="E514-$TIMESTAMP"
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
# FASE 1: CRUD BASICO
# =============================================================================
echo ""
echo "--- FASE 1: CRUD BASICO ---"

# POST /risks (prioridad alta, no requiere estrategia)
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/risks" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Riesgo de prescripcion","probabilidad":"alta","impacto":"alto","prioridad":"alta"}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "201" ]; then
  RISK_ID=$(echo "$BODY" | jq -r '.id // empty')
  if [ -n "$RISK_ID" ]; then
    log_pass "05. POST /risks -> 201 (id=$RISK_ID)"
  else
    log_fail "05. POST /risks -> respuesta incompleta"
  fi
else
  log_fail "05. POST /risks -> $HTTP"
  log_body "$BODY"
  RISK_ID=""
fi

# GET /risks lista
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/risks" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  IS_ARRAY=$(echo "$BODY" | jq 'if type == "array" then true else false end')
  if [ "$IS_ARRAY" = "true" ]; then
    ARRAY_LENGTH=$(echo "$BODY" | jq 'length')
    log_pass "06. GET /risks -> 200 (array con $ARRAY_LENGTH elementos)"
  else
    log_fail "06. GET /risks -> respuesta no es array"
  fi
else
  log_fail "06. GET /risks -> $HTTP"
fi

# GET /risks/:id detalle
if [ -n "$RISK_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/risks/$RISK_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  
  if [ "$HTTP" = "200" ]; then
    RETURNED_ID=$(echo "$BODY" | jq -r '.id // empty')
    if [ "$RETURNED_ID" = "$RISK_ID" ]; then
      log_pass "07. GET /risks/:id -> 200"
    else
      log_fail "07. GET /risks/:id -> ID no coincide"
    fi
  else
    log_fail "07. GET /risks/:id -> $HTTP"
  fi
else
  log_fail "07. GET /risks/:id -> Sin RISK_ID"
fi

# PUT /risks/:id actualiza
if [ -n "$RISK_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/risks/$RISK_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"descripcion":"Riesgo actualizado","estado_mitigacion":"en_curso"}')
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  
  if [ "$HTTP" = "200" ]; then
    UPDATED_DESC=$(echo "$BODY" | jq -r '.descripcion // empty')
    UPDATED_ESTADO=$(echo "$BODY" | jq -r '.estado_mitigacion // empty')
    if [ "$UPDATED_DESC" = "Riesgo actualizado" ] && [ "$UPDATED_ESTADO" = "en_curso" ]; then
      log_pass "08. PUT /risks/:id -> 200 (campos actualizados)"
    else
      log_fail "08. PUT /risks/:id -> campos no reflejados"
    fi
  else
    log_fail "08. PUT /risks/:id -> $HTTP"
  fi
else
  log_fail "08. PUT /risks/:id -> Sin RISK_ID"
fi

# =============================================================================
# FASE 2: REGLA PRIORIDAD CRITICA
# =============================================================================
echo ""
echo "--- FASE 2: REGLA PRIORIDAD CRITICA ---"

# POST con prioridad critica SIN estrategia -> 400
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/risks" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Riesgo critico sin estrategia","probabilidad":"alta","impacto":"alto","prioridad":"critica"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "400" ]; then
  log_pass "09. POST critica sin estrategia -> 400"
else
  log_fail "09. POST critica sin estrategia -> $HTTP (esperado 400)"
fi

# PUT a prioridad critica SIN estrategia -> 400
if [ -n "$RISK_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/risks/$RISK_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"prioridad":"critica"}')
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "400" ]; then
    log_pass "10. PUT a critica sin estrategia -> 400"
  else
    log_fail "10. PUT a critica sin estrategia -> $HTTP (esperado 400)"
  fi
else
  log_fail "10. PUT a critica sin estrategia -> Sin RISK_ID"
fi

# =============================================================================
# FASE 3: CASO INEXISTENTE
# =============================================================================
echo ""
echo "--- FASE 3: CASO INEXISTENTE ---"

FAKE_CASE="00000000-0000-0000-0000-000000000000"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$FAKE_CASE/risks" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "11. GET /risks (caso inexistente) -> 404"
else
  log_fail "11. GET /risks (caso inexistente) -> $HTTP"
fi

RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$FAKE_CASE/risks" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Test","probabilidad":"alta","impacto":"alto","prioridad":"alta"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "12. POST /risks (caso inexistente) -> 404"
else
  log_fail "12. POST /risks (caso inexistente) -> $HTTP"
fi

if [ -n "$RISK_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$FAKE_CASE/risks/$RISK_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "404" ]; then
    log_pass "13. GET /risks/:id (caso inexistente) -> 404"
  else
    log_fail "13. GET /risks/:id (caso inexistente) -> $HTTP"
  fi
  
  RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$FAKE_CASE/risks/$RISK_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"descripcion":"Test"}')
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "404" ]; then
    log_pass "14. PUT /risks/:id (caso inexistente) -> 404"
  else
    log_fail "14. PUT /risks/:id (caso inexistente) -> $HTTP"
  fi
else
  log_fail "13. GET /risks/:id (caso inexistente) -> Sin RISK_ID"
  log_fail "14. PUT /risks/:id (caso inexistente) -> Sin RISK_ID"
fi

# =============================================================================
# FASE 4: RIESGO INEXISTENTE
# =============================================================================
echo ""
echo "--- FASE 4: RIESGO INEXISTENTE ---"

FAKE_RISK="00000000-0000-0000-0000-000000000001"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/risks/$FAKE_RISK" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "15. GET /risks/:id (riesgo inexistente) -> 404"
else
  log_fail "15. GET /risks/:id (riesgo inexistente) -> $HTTP"
fi

# =============================================================================
# FASE 5: FUGA ENTRE CASOS
# =============================================================================
echo ""
echo "--- FASE 5: FUGA ENTRE CASOS ---"

RADICADO2="E514B-$TIMESTAMP"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"cliente_id\":\"$CLIENT_ID\",\"radicado\":\"$RADICADO2\",\"delito_imputado\":\"Estafa\",\"despacho\":\"Juzgado 2\",\"regimen_procesal\":\"Ley 906\",\"etapa_procesal\":\"Juicio\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CASE_ID_2=$(echo "$BODY" | jq -r '.id // empty')

if [ -n "$CASE_ID_2" ] && [ -n "$RISK_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID_2/risks/$RISK_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "404" ]; then
    log_pass "16. Fuga entre casos -> 404 PROTEGIDO"
  else
    log_fail "16. Fuga entre casos -> $HTTP (VULNERABILIDAD)"
  fi
else
  log_fail "16. Fuga entre casos -> No se pudo crear segundo caso"
fi

# =============================================================================
# FASE 6: ACCESO SIN TOKEN
# =============================================================================
echo ""
echo "--- FASE 6: ACCESO SIN TOKEN ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/risks")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "17. GET /risks sin token -> 401"
else
  log_fail "17. GET /risks sin token -> $HTTP"
fi

RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/risks" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Test","probabilidad":"alta","impacto":"alto","prioridad":"alta"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "18. POST /risks sin token -> 401"
else
  log_fail "18. POST /risks sin token -> $HTTP"
fi

# =============================================================================
# FASE 7: ESTUDIANTE EN CASO AJENO
# =============================================================================
echo ""
echo "--- FASE 7: ESTUDIANTE EN CASO AJENO ---"

STUDENT_EMAIL="student${TIMESTAMP}@lexpenal.local"
curl -sS -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Estudiante E514 $TIMESTAMP\",\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\",\"perfil\":\"estudiante\"}" > /dev/null

RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\"}")
STUDENT_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -n "$STUDENT_TOKEN" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/risks" \
    -H "Authorization: Bearer $STUDENT_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "403" ]; then
    log_pass "19. GET /risks (estudiante caso ajeno) -> 403"
  else
    log_fail "19. GET /risks (estudiante caso ajeno) -> $HTTP"
  fi
  
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/risks" \
    -H "Authorization: Bearer $STUDENT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"descripcion":"Test","probabilidad":"alta","impacto":"alto","prioridad":"alta"}')
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "403" ]; then
    log_pass "20. POST /risks (estudiante caso ajeno) -> 403"
  else
    log_fail "20. POST /risks (estudiante caso ajeno) -> $HTTP"
  fi
else
  log_fail "19. Login estudiante fallo"
  log_fail "20. (depende de 19)"
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "===================================="
echo "RESUMEN E5-14 — VALIDACION DE RISKS"
echo "===================================="
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "===================================="
echo ""

if [ "$PASSED" -eq 20 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}E5-14 PUEDE CERRARSE${NC}"
  echo -e "${YELLOW}[PENDIENTE] Verificar npm run build manualmente${NC}"
else
  echo -e "${RED}E5-14 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Caso: $RADICADO | ID: $CASE_ID"
echo "Riesgo: $RISK_ID"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
