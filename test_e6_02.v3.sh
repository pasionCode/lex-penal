#!/bin/bash
# =============================================================================
# PRUEBAS RUNTIME E6-02 v3 — EVENTOS CASE-SCOPED CRITICOS
# =============================================================================
# 15 pruebas runtime:
#   01-03: Login (admin, supervisor, estudiante)
#   04: Crear cliente y caso
#   05: Activar caso
#   06: Generar informe
#   07: Preparar y avanzar a pendiente_revision
#   08: Crear revision supervisor
#   09: GET /audit admin -> 200
#   10: GET /audit supervisor -> 200
#   11: GET /audit estudiante -> 403
#   12: GET /audit?tipo=informe_generado -> 200 + data >= 1 + tipo correcto
#   13: GET /audit?tipo=revision_supervisor -> 200 + data >= 1 + tipo correcto
#   14: Verificar no duplicidad informe_generado (exactamente 1)
#   15: Verificar no duplicidad revision_supervisor (exactamente 1)
#
# NOTA: Las pruebas 14-15 validan no duplicidad secuencial observable.
# No constituyen hardening concurrente exhaustivo.
#
# Build verde: obligatorio y separado (npm run build)
# =============================================================================

set -euo pipefail

BASE_URL="${1:-http://localhost:3001/api/v1}"
PASSED=0
FAILED=0
TIMESTAMP=$(date +%s)

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_pass() { echo -e "[${GREEN}PASS${NC}] $1"; PASSED=$((PASSED + 1)); }
log_fail() { echo -e "[${RED}FAIL${NC}] $1"; FAILED=$((FAILED + 1)); }
log_info() { echo -e "[${YELLOW}INFO${NC}] $1"; }

echo "========================================"
echo "E6-02 v3 — EVENTOS CASE-SCOPED CRITICOS"
echo "========================================"
echo "Timestamp: $TIMESTAMP"

# =============================================================================
# FASE 0: LOGINS
# =============================================================================
log_info "Fase 0: Logins..."

# 01. Login admin
RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@lexpenal.local","password":"CambiarEnProduccion_2026!"}')
ADMIN_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -n "$ADMIN_TOKEN" ]; then
  log_pass "01. Login admin -> 200"
else
  log_fail "01. Login admin fallo"
  exit 1
fi

# 02. Login supervisor
SUPERVISOR_EMAIL="supervisor${TIMESTAMP}@lexpenal.local"
curl -sS -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Supervisor E602\",\"email\":\"$SUPERVISOR_EMAIL\",\"password\":\"SuperPass123!\",\"perfil\":\"supervisor\"}" > /dev/null 2>&1

RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$SUPERVISOR_EMAIL\",\"password\":\"SuperPass123!\"}")
SUPERVISOR_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -n "$SUPERVISOR_TOKEN" ]; then
  log_pass "02. Login supervisor -> 200"
else
  log_fail "02. Login supervisor fallo"
fi

# 03. Login estudiante
STUDENT_EMAIL="student${TIMESTAMP}@lexpenal.local"
curl -sS -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Estudiante E602\",\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\",\"perfil\":\"estudiante\"}" > /dev/null 2>&1

RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\"}")
STUDENT_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -n "$STUDENT_TOKEN" ]; then
  log_pass "03. Login estudiante -> 200"
else
  log_fail "03. Login estudiante fallo"
fi

# =============================================================================
# FASE 1: CREAR CASO Y GENERAR EVENTOS
# =============================================================================
echo ""
echo "--- FASE 1: CREAR CASO Y GENERAR EVENTOS ---"

# 04. Crear cliente y caso
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E602 $TIMESTAMP\",\"documento\":\"E602$TIMESTAMP\",\"tipo_documento\":\"CC\",\"situacion_libertad\":\"libre\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CLIENT_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" != "201" ] || [ -z "$CLIENT_ID" ]; then
  log_fail "04. Crear cliente fallo ($HTTP)"
  exit 1
fi

RADICADO="E602-$TIMESTAMP"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"cliente_id\":\"$CLIENT_ID\",\"radicado\":\"$RADICADO\",\"delito_imputado\":\"Hurto\",\"despacho\":\"Juzgado 1\",\"regimen_procesal\":\"Ley 906\",\"etapa_procesal\":\"Investigacion\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CASE_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" != "201" ] || [ -z "$CASE_ID" ]; then
  log_fail "04. Crear caso fallo ($HTTP)"
  exit 1
fi

log_pass "04. Crear cliente y caso -> 201"

# 05. Activar caso (genera evento transicion_estado)
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"estado_destino":"en_analisis"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
  log_pass "05. Activar caso -> $HTTP"
else
  log_fail "05. Activar caso -> $HTTP"
  exit 1
fi

# 06. Generar informe (debe generar evento informe_generado)
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/reports" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tipo":"resumen_ejecutivo","formato":"pdf"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
  log_pass "06. Generar informe -> $HTTP"
else
  log_fail "06. Generar informe -> $HTTP"
fi

# 07. Preparar y avanzar a pendiente_revision
log_info "07. Preparando precondiciones para pendiente_revision..."

# Agregar estrategia
curl -sS -X PUT "$BASE_URL/cases/$CASE_ID/strategy" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"linea_principal":"Estrategia E602"}' > /dev/null

# Agregar hecho
curl -sS -X POST "$BASE_URL/cases/$CASE_ID/facts" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Hecho E602","estado_hecho":"acreditado"}' > /dev/null

# Marcar checklist completo
RESP=$(curl -sS "$BASE_URL/cases/$CASE_ID/checklist" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
ITEMS=$(echo "$RESP" | jq -r '[.bloques[].items[].id]' 2>/dev/null || echo "[]")

if [ "$ITEMS" != "[]" ] && [ -n "$ITEMS" ]; then
  MARCADOS=$(echo "$ITEMS" | jq '[.[] | {id: ., marcado: true}]')
  curl -sS -X PUT "$BASE_URL/cases/$CASE_ID/checklist" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"items\":$MARCADOS}" > /dev/null
fi

# Transicion a pendiente_revision
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"estado_destino":"pendiente_revision"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
  log_pass "07. Avanzar a pendiente_revision -> $HTTP"
else
  log_fail "07. Avanzar a pendiente_revision -> $HTTP"
  log_info "Continuando sin revision_supervisor..."
fi

# 08. Crear revision supervisor (debe generar evento revision_supervisor)
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/review" \
  -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"observaciones":"Revision E602","resultado":"aprobado"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "201" ]; then
  log_pass "08. Crear revision supervisor -> 201"
else
  log_fail "08. Crear revision supervisor -> $HTTP (esperado 201)"
fi

# =============================================================================
# FASE 2: VERIFICAR ACCESO A AUDIT
# =============================================================================
echo ""
echo "--- FASE 2: VERIFICAR ACCESO A AUDIT ---"

# 09. GET /audit admin
RESP=$(curl -sS -w "\n%{http_code}" -X GET "$BASE_URL/cases/$CASE_ID/audit" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ]; then
  log_pass "09. GET /audit admin -> 200"
else
  log_fail "09. GET /audit admin -> $HTTP"
fi

# 10. GET /audit supervisor
RESP=$(curl -sS -w "\n%{http_code}" -X GET "$BASE_URL/cases/$CASE_ID/audit" \
  -H "Authorization: Bearer $SUPERVISOR_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ]; then
  log_pass "10. GET /audit supervisor -> 200"
else
  log_fail "10. GET /audit supervisor -> $HTTP"
fi

# 11. GET /audit estudiante
RESP=$(curl -sS -w "\n%{http_code}" -X GET "$BASE_URL/cases/$CASE_ID/audit" \
  -H "Authorization: Bearer $STUDENT_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "403" ]; then
  log_pass "11. GET /audit estudiante -> 403"
else
  log_fail "11. GET /audit estudiante -> $HTTP (esperado 403)"
fi

# =============================================================================
# FASE 3: VERIFICAR EVENTOS REGISTRADOS CON TIPO CORRECTO
# =============================================================================
echo ""
echo "--- FASE 3: VERIFICAR EVENTOS REGISTRADOS ---"

# 12. GET /audit?tipo=informe_generado -> verificar tipo correcto
RESP=$(curl -sS -w "\n%{http_code}" -X GET "$BASE_URL/cases/$CASE_ID/audit?tipo=informe_generado" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  COUNT=$(echo "$BODY" | jq '.data | length')
  # Verificar que todos los eventos tienen tipo correcto
  TIPOS_CORRECTOS=$(echo "$BODY" | jq '[.data[].tipo] | all(. == "informe_generado")')
  
  if [ "$COUNT" -ge 1 ] && [ "$TIPOS_CORRECTOS" = "true" ]; then
    log_pass "12. GET /audit?tipo=informe_generado -> 200 + $COUNT evento(s) + tipo correcto"
  elif [ "$COUNT" -ge 1 ]; then
    log_fail "12. GET /audit?tipo=informe_generado -> tipo incorrecto en respuesta"
  else
    log_fail "12. GET /audit?tipo=informe_generado -> 200 pero data vacio"
  fi
else
  log_fail "12. GET /audit?tipo=informe_generado -> $HTTP"
fi

# 13. GET /audit?tipo=revision_supervisor -> verificar tipo correcto
RESP=$(curl -sS -w "\n%{http_code}" -X GET "$BASE_URL/cases/$CASE_ID/audit?tipo=revision_supervisor" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  COUNT=$(echo "$BODY" | jq '.data | length')
  # Verificar que todos los eventos tienen tipo correcto
  TIPOS_CORRECTOS=$(echo "$BODY" | jq '[.data[].tipo] | all(. == "revision_supervisor")')
  
  if [ "$COUNT" -ge 1 ] && [ "$TIPOS_CORRECTOS" = "true" ]; then
    log_pass "13. GET /audit?tipo=revision_supervisor -> 200 + $COUNT evento(s) + tipo correcto"
  elif [ "$COUNT" -ge 1 ]; then
    log_fail "13. GET /audit?tipo=revision_supervisor -> tipo incorrecto en respuesta"
  else
    log_fail "13. GET /audit?tipo=revision_supervisor -> 200 pero data vacio"
  fi
else
  log_fail "13. GET /audit?tipo=revision_supervisor -> $HTTP"
fi

# =============================================================================
# FASE 4: VERIFICAR NO DUPLICIDAD (SECUENCIAL)
# =============================================================================
echo ""
echo "--- FASE 4: VERIFICAR NO DUPLICIDAD (SECUENCIAL) ---"

# 14. Verificar exactamente 1 evento informe_generado
RESP=$(curl -sS "$BASE_URL/cases/$CASE_ID/audit?tipo=informe_generado&per_page=100" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
COUNT_INFORME=$(echo "$RESP" | jq '.data | length')

if [ "$COUNT_INFORME" = "1" ]; then
  log_pass "14. No duplicidad informe_generado -> exactamente 1 evento"
else
  log_fail "14. No duplicidad informe_generado -> $COUNT_INFORME eventos (esperado 1)"
fi

# 15. Verificar exactamente 1 evento revision_supervisor
RESP=$(curl -sS "$BASE_URL/cases/$CASE_ID/audit?tipo=revision_supervisor&per_page=100" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
COUNT_REVISION=$(echo "$RESP" | jq '.data | length')

if [ "$COUNT_REVISION" = "1" ]; then
  log_pass "15. No duplicidad revision_supervisor -> exactamente 1 evento"
else
  log_fail "15. No duplicidad revision_supervisor -> $COUNT_REVISION eventos (esperado 1)"
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "========================================"
echo "RESUMEN E6-02 v3 — EVENTOS CASE-SCOPED"
echo "========================================"
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "========================================"
echo ""

echo "Caso de prueba: $RADICADO | ID: $CASE_ID"
echo ""

if [ "$PASSED" -eq 15 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}E6-02 RUNTIME VALIDADO${NC}"
  echo -e "${YELLOW}[PENDIENTE]${NC} Build verde obligatorio: npm run build"
else
  echo -e "${RED}E6-02 NO PUEDE CERRARSE${NC}"
fi
