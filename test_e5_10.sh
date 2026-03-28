#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-10 — VALIDACIÓN DE PROCEEDINGS
# =============================================================================
# VALIDA:
#   - POST /proceedings crea actuación → 201
#   - GET /proceedings lista (array) → 200
#   - GET /proceedings/:id retorna detalle → 200
#   - Caso inexistente → 404
#   - Actuación inexistente → 404
#   - Fuga entre casos → 404
#   - Sin token → 401
#   - Estudiante en caso ajeno → 403
#   - npm run build → verde (verificar manualmente)
#
# NOTA: Este módulo SÍ tiene control de perfil (403 posible).
#       Estudiante solo puede acceder a casos donde es responsable.
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
echo "E5-10 — VALIDACIÓN RUNTIME DE PROCEEDINGS"
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
ADMIN_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -z "$ADMIN_TOKEN" ]; then
  echo -e "${RED}[ERROR] No se obtuvo token admin. Abortando.${NC}"
  exit 1
fi
log_pass "01. Login admin → 200"

# Crear cliente y caso de prueba
DOC_CLIENTE="E510${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E510 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CLIENT_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" = "201" ] && [ -n "$CLIENT_ID" ]; then
  log_pass "02. POST /clients → 201"
else
  log_fail "02. POST /clients → $HTTP"
  exit 1
fi

RADICADO="E510-$TIMESTAMP"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
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
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"estado_destino":"en_analisis"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
  log_pass "04. Activar caso → $HTTP"
else
  log_fail "04. Activar caso → $HTTP"
fi

# =============================================================================
# FASE 1: POST /proceedings → 201
# =============================================================================
echo ""
echo "--- FASE 1: CREAR ACTUACIÓN ---"

RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/proceedings" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Audiencia de imputacion programada","fecha":"2026-04-15T10:00:00Z","completada":false}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "201" ]; then
  PROCEEDING_ID=$(echo "$BODY" | jq -r '.id // empty')
  PROCEEDING_DESC=$(echo "$BODY" | jq -r '.descripcion // empty')
  
  if [ -n "$PROCEEDING_ID" ]; then
    log_pass "05. POST /proceedings → 201 (id=$PROCEEDING_ID)"
  else
    log_fail "05. POST /proceedings → respuesta incompleta"
  fi
else
  log_fail "05. POST /proceedings → $HTTP"
  log_body "$BODY"
  PROCEEDING_ID=""
fi

# Crear segunda actuación para verificar lista
curl -sS -X POST "$BASE_URL/cases/$CASE_ID/proceedings" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Solicitud de pruebas","completada":true}' > /dev/null

# =============================================================================
# FASE 2: GET /proceedings → 200 (array)
# =============================================================================
echo ""
echo "--- FASE 2: LISTAR ACTUACIONES ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/proceedings" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  # Verificar que es un array (no objeto paginado)
  IS_ARRAY=$(echo "$BODY" | jq 'if type == "array" then true else false end')
  
  if [ "$IS_ARRAY" = "true" ]; then
    ARRAY_LENGTH=$(echo "$BODY" | jq 'length')
    log_pass "06. GET /proceedings → 200 (array con $ARRAY_LENGTH elementos)"
  else
    log_fail "06. GET /proceedings → respuesta no es array"
  fi
else
  log_fail "06. GET /proceedings → $HTTP"
fi

# =============================================================================
# FASE 3: GET /proceedings/:id → 200 (detalle)
# =============================================================================
echo ""
echo "--- FASE 3: DETALLE DE ACTUACIÓN ---"

if [ -n "$PROCEEDING_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/proceedings/$PROCEEDING_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  
  if [ "$HTTP" = "200" ]; then
    RETURNED_ID=$(echo "$BODY" | jq -r '.id // empty')
    
    if [ "$RETURNED_ID" = "$PROCEEDING_ID" ]; then
      log_pass "07. GET /proceedings/:id → 200"
    else
      log_fail "07. GET /proceedings/:id → ID no coincide"
    fi
  else
    log_fail "07. GET /proceedings/:id → $HTTP"
  fi
else
  log_fail "07. GET /proceedings/:id → Sin PROCEEDING_ID"
fi

# =============================================================================
# FASE 4: CASO INEXISTENTE → 404
# =============================================================================
echo ""
echo "--- FASE 4: CASO INEXISTENTE ---"

FAKE_CASE="00000000-0000-0000-0000-000000000000"

# GET /proceedings con caso inexistente
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$FAKE_CASE/proceedings" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "08. GET /proceedings (caso inexistente) → 404"
else
  log_fail "08. GET /proceedings (caso inexistente) → $HTTP (esperado 404)"
fi

# POST /proceedings con caso inexistente
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$FAKE_CASE/proceedings" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Test"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "09. POST /proceedings (caso inexistente) → 404"
else
  log_fail "09. POST /proceedings (caso inexistente) → $HTTP (esperado 404)"
fi

# GET /proceedings/:id con caso inexistente
if [ -n "$PROCEEDING_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$FAKE_CASE/proceedings/$PROCEEDING_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "404" ]; then
    log_pass "10. GET /proceedings/:id (caso inexistente) → 404"
  else
    log_fail "10. GET /proceedings/:id (caso inexistente) → $HTTP (esperado 404)"
  fi
else
  log_fail "10. GET /proceedings/:id (caso inexistente) → Sin PROCEEDING_ID"
fi

# =============================================================================
# FASE 5: ACTUACIÓN INEXISTENTE → 404
# =============================================================================
echo ""
echo "--- FASE 5: ACTUACIÓN INEXISTENTE ---"

FAKE_PROCEEDING="00000000-0000-0000-0000-000000000001"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/proceedings/$FAKE_PROCEEDING" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "11. GET /proceedings/:id (actuación inexistente) → 404"
else
  log_fail "11. GET /proceedings/:id (actuación inexistente) → $HTTP (esperado 404)"
fi

# =============================================================================
# FASE 6: FUGA ENTRE CASOS → 404
# =============================================================================
echo ""
echo "--- FASE 6: FUGA ENTRE CASOS ---"

# Crear segundo caso
RADICADO2="E510B-$TIMESTAMP"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"cliente_id\":\"$CLIENT_ID\",\"radicado\":\"$RADICADO2\",\"delito_imputado\":\"Estafa\",\"despacho\":\"Juzgado 2\",\"regimen_procesal\":\"Ley 906\",\"etapa_procesal\":\"Juicio\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CASE_ID_2=$(echo "$BODY" | jq -r '.id // empty')

if [ -n "$CASE_ID_2" ] && [ -n "$PROCEEDING_ID" ]; then
  # Intentar acceder a la actuación del caso 1 desde el caso 2
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID_2/proceedings/$PROCEEDING_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
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
# FASE 7: ACCESO SIN TOKEN → 401
# =============================================================================
echo ""
echo "--- FASE 7: ACCESO SIN TOKEN ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/proceedings")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "13. GET /proceedings sin token → 401"
else
  log_fail "13. GET /proceedings sin token → $HTTP (esperado 401)"
fi

RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/proceedings" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Sin Auth"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "14. POST /proceedings sin token → 401"
else
  log_fail "14. POST /proceedings sin token → $HTTP (esperado 401)"
fi

# =============================================================================
# FASE 8: ESTUDIANTE EN CASO AJENO → 403
# =============================================================================
echo ""
echo "--- FASE 8: ESTUDIANTE EN CASO AJENO ---"

# Crear estudiante
STUDENT_EMAIL="student${TIMESTAMP}@lexpenal.local"
curl -sS -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Estudiante E510 $TIMESTAMP\",\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\",\"perfil\":\"estudiante\"}" > /dev/null

# Login como estudiante
RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\"}")
STUDENT_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -n "$STUDENT_TOKEN" ]; then
  # Intentar acceder al caso (creado por admin, estudiante no es responsable)
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/proceedings" \
    -H "Authorization: Bearer $STUDENT_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "403" ]; then
    log_pass "15. GET /proceedings (estudiante caso ajeno) → 403"
  else
    log_fail "15. GET /proceedings (estudiante caso ajeno) → $HTTP (esperado 403)"
  fi
  
  # POST también debería dar 403
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/proceedings" \
    -H "Authorization: Bearer $STUDENT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"descripcion":"Intento no autorizado"}')
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "403" ]; then
    log_pass "16. POST /proceedings (estudiante caso ajeno) → 403"
  else
    log_fail "16. POST /proceedings (estudiante caso ajeno) → $HTTP (esperado 403)"
  fi
else
  log_fail "15. Login estudiante falló"
  log_fail "16. (depende de 15)"
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "=============================================="
echo "RESUMEN E5-10 — VALIDACIÓN DE PROCEEDINGS"
echo "=============================================="
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "=============================================="
echo ""

echo "CRITERIOS E5-10:"
echo ""
if [ "$PASSED" -eq 16 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "  ${GREEN}✓ POST /proceedings → 201${NC}"
  echo -e "  ${GREEN}✓ GET /proceedings → 200 (array)${NC}"
  echo -e "  ${GREEN}✓ GET /proceedings/:id → 200${NC}"
  echo -e "  ${GREEN}✓ Caso inexistente → 404 (GET, POST, GET/:id)${NC}"
  echo -e "  ${GREEN}✓ Actuación inexistente → 404${NC}"
  echo -e "  ${GREEN}✓ Fuga entre casos → 404${NC}"
  echo -e "  ${GREEN}✓ Acceso sin token → 401${NC}"
  echo -e "  ${GREEN}✓ Estudiante caso ajeno → 403${NC}"
  echo ""
  echo -e "${GREEN}E5-10 PUEDE CERRARSE${NC}"
  echo -e "${YELLOW}[PENDIENTE] Verificar npm run build manualmente${NC}"
else
  echo -e "  ${RED}✗ Criterios no cumplidos (PASSED=$PASSED, FAILED=$FAILED)${NC}"
  echo ""
  echo -e "${RED}E5-10 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Caso: $RADICADO | ID: $CASE_ID"
echo "Actuación: $PROCEEDING_ID"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
