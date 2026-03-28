#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-11 — VALIDACIÓN DE CONCLUSION
# =============================================================================
# VALIDA:
#   - GET /conclusion (auto-crea si no existe) → 200
#   - PUT /conclusion actualiza → 200
#   - GET después de PUT refleja cambios → 200
#   - Caso inexistente → 404
#   - Sin token → 401
#   - Estudiante en caso ajeno → 403
#   - npm run build → verde (verificar manualmente)
#
# NOTA: Este módulo es SINGLETON (1 conclusión por caso).
#       GET auto-crea si no existe (no hay POST).
#       Control de perfil activo (403 posible para estudiante).
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
echo "E5-11 — VALIDACIÓN RUNTIME DE CONCLUSION"
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
DOC_CLIENTE="E511${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E511 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CLIENT_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" = "201" ] && [ -n "$CLIENT_ID" ]; then
  log_pass "02. POST /clients → 201"
else
  log_fail "02. POST /clients → $HTTP"
  exit 1
fi

RADICADO="E511-$TIMESTAMP"
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
# FASE 1: GET /conclusion (auto-crea) → 200
# =============================================================================
echo ""
echo "--- FASE 1: GET CONCLUSIÓN (AUTO-CREACIÓN) ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/conclusion" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  CONCLUSION_ID=$(echo "$BODY" | jq -r '.id // empty')
  CONCLUSION_CASO_ID=$(echo "$BODY" | jq -r '.caso_id // empty')
  
  if [ -n "$CONCLUSION_ID" ] && [ "$CONCLUSION_CASO_ID" = "$CASE_ID" ]; then
    log_pass "05. GET /conclusion (auto-crea) → 200 (id=$CONCLUSION_ID)"
  else
    log_fail "05. GET /conclusion → respuesta incompleta o caso_id incorrecto"
  fi
else
  log_fail "05. GET /conclusion → $HTTP"
  log_body "$BODY"
fi

# =============================================================================
# FASE 2: PUT /conclusion → 200
# =============================================================================
echo ""
echo "--- FASE 2: PUT CONCLUSIÓN ---"

RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/conclusion" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"hechos_sintesis":"Resumen de los hechos del caso E511","cargo_imputado":"Hurto calificado","recomendacion":"Preacuerdo recomendado"}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  UPDATED_HECHOS=$(echo "$BODY" | jq -r '.hechos_sintesis // empty')
  
  if [ "$UPDATED_HECHOS" = "Resumen de los hechos del caso E511" ]; then
    log_pass "06. PUT /conclusion → 200 (campos actualizados)"
  else
    log_fail "06. PUT /conclusion → campos no reflejados"
  fi
else
  log_fail "06. PUT /conclusion → $HTTP"
  log_body "$BODY"
fi

# =============================================================================
# FASE 3: GET después de PUT → refleja cambios
# =============================================================================
echo ""
echo "--- FASE 3: GET DESPUÉS DE PUT ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/conclusion" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  PERSISTED_HECHOS=$(echo "$BODY" | jq -r '.hechos_sintesis // empty')
  PERSISTED_CARGO=$(echo "$BODY" | jq -r '.cargo_imputado // empty')
  PERSISTED_RECOM=$(echo "$BODY" | jq -r '.recomendacion // empty')
  
  if [ "$PERSISTED_HECHOS" = "Resumen de los hechos del caso E511" ] && \
     [ "$PERSISTED_CARGO" = "Hurto calificado" ] && \
     [ "$PERSISTED_RECOM" = "Preacuerdo recomendado" ]; then
    log_pass "07. GET después de PUT → 200 (cambios persistidos)"
  else
    log_fail "07. GET después de PUT → cambios no persistidos"
  fi
else
  log_fail "07. GET después de PUT → $HTTP"
fi

# =============================================================================
# FASE 4: CASO INEXISTENTE → 404
# =============================================================================
echo ""
echo "--- FASE 4: CASO INEXISTENTE ---"

FAKE_CASE="00000000-0000-0000-0000-000000000000"

# GET /conclusion con caso inexistente
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$FAKE_CASE/conclusion" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "08. GET /conclusion (caso inexistente) → 404"
else
  log_fail "08. GET /conclusion (caso inexistente) → $HTTP (esperado 404)"
fi

# PUT /conclusion con caso inexistente
RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$FAKE_CASE/conclusion" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"hechos_sintesis":"Test"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "09. PUT /conclusion (caso inexistente) → 404"
else
  log_fail "09. PUT /conclusion (caso inexistente) → $HTTP (esperado 404)"
fi

# =============================================================================
# FASE 5: ACCESO SIN TOKEN → 401
# =============================================================================
echo ""
echo "--- FASE 5: ACCESO SIN TOKEN ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/conclusion")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "10. GET /conclusion sin token → 401"
else
  log_fail "10. GET /conclusion sin token → $HTTP (esperado 401)"
fi

RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/conclusion" \
  -H "Content-Type: application/json" \
  -d '{"hechos_sintesis":"Sin Auth"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "11. PUT /conclusion sin token → 401"
else
  log_fail "11. PUT /conclusion sin token → $HTTP (esperado 401)"
fi

# =============================================================================
# FASE 6: ESTUDIANTE EN CASO AJENO → 403
# =============================================================================
echo ""
echo "--- FASE 6: ESTUDIANTE EN CASO AJENO ---"

# Crear estudiante
STUDENT_EMAIL="student${TIMESTAMP}@lexpenal.local"
curl -sS -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Estudiante E511 $TIMESTAMP\",\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\",\"perfil\":\"estudiante\"}" > /dev/null

# Login como estudiante
RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\"}")
STUDENT_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -n "$STUDENT_TOKEN" ]; then
  # Intentar GET al caso (creado por admin, estudiante no es responsable)
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/conclusion" \
    -H "Authorization: Bearer $STUDENT_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "403" ]; then
    log_pass "12. GET /conclusion (estudiante caso ajeno) → 403"
  else
    log_fail "12. GET /conclusion (estudiante caso ajeno) → $HTTP (esperado 403)"
  fi
  
  # PUT también debería dar 403
  RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/conclusion" \
    -H "Authorization: Bearer $STUDENT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"hechos_sintesis":"Intento no autorizado"}')
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "403" ]; then
    log_pass "13. PUT /conclusion (estudiante caso ajeno) → 403"
  else
    log_fail "13. PUT /conclusion (estudiante caso ajeno) → $HTTP (esperado 403)"
  fi
else
  log_fail "12. Login estudiante falló"
  log_fail "13. (depende de 12)"
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "=============================================="
echo "RESUMEN E5-11 — VALIDACIÓN DE CONCLUSION"
echo "=============================================="
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "=============================================="
echo ""

echo "CRITERIOS E5-11:"
echo ""
if [ "$PASSED" -eq 13 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "  ${GREEN}✓ GET /conclusion (auto-crea) → 200${NC}"
  echo -e "  ${GREEN}✓ PUT /conclusion → 200${NC}"
  echo -e "  ${GREEN}✓ GET después de PUT → cambios persistidos${NC}"
  echo -e "  ${GREEN}✓ Caso inexistente → 404 (GET, PUT)${NC}"
  echo -e "  ${GREEN}✓ Acceso sin token → 401${NC}"
  echo -e "  ${GREEN}✓ Estudiante caso ajeno → 403${NC}"
  echo ""
  echo -e "${GREEN}E5-11 PUEDE CERRARSE${NC}"
  echo -e "${YELLOW}[PENDIENTE] Verificar npm run build manualmente${NC}"
else
  echo -e "  ${RED}✗ Criterios no cumplidos (PASSED=$PASSED, FAILED=$FAILED)${NC}"
  echo ""
  echo -e "${RED}E5-11 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Caso: $RADICADO | ID: $CASE_ID"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
