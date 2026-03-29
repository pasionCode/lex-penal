#!/bin/bash
# =============================================================================
# PRUEBAS RUNTIME E6-03 — FLUJO CIERRE + AI 409 + CLIENT-BRIEFING HARDENING
# =============================================================================
# 14 pruebas runtime:
#   01: Login admin
#   02: Login supervisor
#   03: Crear cliente y caso
#   04: Transición borrador → en_analisis
#   05: PUT /client-briefing en en_analisis → 200
#   06: Setup precondiciones + transición → pendiente_revision
#   07: Crear revisión aprobada
#   08: Transición pendiente_revision → aprobado_supervisor
#   09: Transición aprobado_supervisor → listo_para_cliente
#   10: PUT /client-briefing con decision_cliente en listo_para_cliente → 200
#   11: Transición listo_para_cliente → cerrado
#   12: AI query caso cerrado → 409
#   13: PUT /client-briefing en caso cerrado → 409
#   14: AI query caso inexistente → 404
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
echo "E6-03 — FLUJO CIERRE + AI 409 + CLIENT-BRIEFING"
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
  -d "{\"nombre\":\"Supervisor E603\",\"email\":\"$SUPERVISOR_EMAIL\",\"password\":\"SuperPass123!\",\"perfil\":\"supervisor\"}" > /dev/null 2>&1

RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$SUPERVISOR_EMAIL\",\"password\":\"SuperPass123!\"}")
SUPERVISOR_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -n "$SUPERVISOR_TOKEN" ]; then
  log_pass "02. Login supervisor -> 200"
else
  log_fail "02. Login supervisor fallo"
fi

# =============================================================================
# FASE 1: CREAR CASO
# =============================================================================
echo ""
echo "--- FASE 1: CREAR CASO ---"

# 03. Crear cliente y caso
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E603 $TIMESTAMP\",\"documento\":\"E603$TIMESTAMP\",\"tipo_documento\":\"CC\",\"situacion_libertad\":\"libre\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CLIENT_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" != "201" ] || [ -z "$CLIENT_ID" ]; then
  log_fail "03. Crear cliente fallo ($HTTP)"
  exit 1
fi

RADICADO="E603-$TIMESTAMP"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"cliente_id\":\"$CLIENT_ID\",\"radicado\":\"$RADICADO\",\"delito_imputado\":\"Hurto\",\"despacho\":\"Juzgado 1\",\"regimen_procesal\":\"Ley 906\",\"etapa_procesal\":\"Investigacion\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CASE_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" != "201" ] || [ -z "$CASE_ID" ]; then
  log_fail "03. Crear caso fallo ($HTTP)"
  exit 1
fi

log_pass "03. Crear cliente y caso -> 201"

# =============================================================================
# FASE 2: ACTIVAR CASO
# =============================================================================
echo ""
echo "--- FASE 2: ACTIVAR CASO ---"

# 04. Transición borrador → en_analisis
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"estado_destino":"en_analisis"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
  log_pass "04. Transición borrador → en_analisis -> $HTTP"
else
  log_fail "04. Transición borrador → en_analisis -> $HTTP"
  exit 1
fi

# =============================================================================
# FASE 3: CLIENT-BRIEFING EN ESTADO ACTIVO
# =============================================================================
echo ""
echo "--- FASE 3: CLIENT-BRIEFING EN ESTADO ACTIVO ---"

# 05. PUT /client-briefing en en_analisis → debe funcionar
RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/client-briefing" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"delito_explicado":"Explicación inicial del delito para E603"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ]; then
  log_pass "05. PUT /client-briefing en en_analisis -> 200"
else
  log_fail "05. PUT /client-briefing en en_analisis -> $HTTP (esperado 200)"
fi

# =============================================================================
# FASE 4: FLUJO HASTA LISTO_PARA_CLIENTE
# =============================================================================
echo ""
echo "--- FASE 4: FLUJO HASTA LISTO_PARA_CLIENTE ---"

# 06. Setup precondiciones + transición a pendiente_revision
log_info "06. Configurando precondiciones..."

# Agregar estrategia
curl -sS -X PUT "$BASE_URL/cases/$CASE_ID/strategy" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"linea_principal":"Estrategia E603 para cierre"}' > /dev/null

# Agregar hecho
curl -sS -X POST "$BASE_URL/cases/$CASE_ID/facts" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Hecho E603 para cierre","estado_hecho":"acreditado"}' > /dev/null

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

# Transición a pendiente_revision
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"estado_destino":"pendiente_revision"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
  log_pass "06. Setup + transición → pendiente_revision -> $HTTP"
else
  log_fail "06. Setup + transición → pendiente_revision -> $HTTP"
  exit 1
fi

# 07. Crear revisión aprobada
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/review" \
  -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"observaciones":"Caso aprobado para E603","resultado":"aprobado"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "201" ]; then
  log_pass "07. Crear revisión aprobada -> 201"
else
  log_fail "07. Crear revisión aprobada -> $HTTP (esperado 201)"
fi

# 08. Transición pendiente_revision → aprobado_supervisor
# Requiere observaciones del supervisor en el payload
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
  -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"estado_destino":"aprobado_supervisor","observaciones":"Caso revisado y aprobado por supervisor E603"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
  log_pass "08. Transición → aprobado_supervisor -> $HTTP"
else
  log_fail "08. Transición → aprobado_supervisor -> $HTTP"
  exit 1
fi

# 09. Transición aprobado_supervisor → listo_para_cliente
# Requiere conclusión operativa completa
log_info "09. Configurando conclusión operativa..."

curl -sS -X PUT "$BASE_URL/cases/$CASE_ID/conclusion" \
  -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "hechos_sintesis":"Síntesis de hechos E603",
    "fortalezas_acusacion":"Fortalezas identificadas",
    "rangos_pena":"6-12 meses",
    "opcion_a":"Aceptar cargos con beneficios",
    "recomendacion":"Se recomienda negociación"
  }' > /dev/null

RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
  -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"estado_destino":"listo_para_cliente"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
  log_pass "09. Transición → listo_para_cliente -> $HTTP"
else
  log_fail "09. Transición → listo_para_cliente -> $HTTP"
  exit 1
fi

# =============================================================================
# FASE 5: CLIENT-BRIEFING EN LISTO_PARA_CLIENTE (EXCEPCION)
# =============================================================================
echo ""
echo "--- FASE 5: CLIENT-BRIEFING EN LISTO_PARA_CLIENTE ---"

# 10. PUT /client-briefing con decision_cliente en listo_para_cliente → debe funcionar
RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/client-briefing" \
  -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"decision_cliente":"Cliente acepta el análisis y las recomendaciones del equipo jurídico."}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ]; then
  log_pass "10. PUT /client-briefing con decision_cliente en listo_para_cliente -> 200"
else
  log_fail "10. PUT /client-briefing con decision_cliente en listo_para_cliente -> $HTTP (esperado 200)"
fi

# =============================================================================
# FASE 6: CIERRE DEL CASO
# =============================================================================
echo ""
echo "--- FASE 6: CIERRE DEL CASO ---"

# 11. Transición listo_para_cliente → cerrado
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
  -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"estado_destino":"cerrado"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
  log_pass "11. Transición → cerrado -> $HTTP"
else
  log_fail "11. Transición → cerrado -> $HTTP"
  BODY=$(echo "$RESP" | sed '$d')
  echo "    Respuesta: $BODY"
fi

# =============================================================================
# FASE 7: VALIDACION ESTADO TERMINAL
# =============================================================================
echo ""
echo "--- FASE 7: VALIDACION ESTADO TERMINAL ---"

# 12. AI query caso cerrado → 409
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/ai/query" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"caso_id\":\"$CASE_ID\",\"herramienta\":\"strategy\",\"consulta\":\"Analizar estrategia del caso\"}")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "409" ]; then
  log_pass "12. AI query caso cerrado -> 409"
else
  log_fail "12. AI query caso cerrado -> $HTTP (esperado 409)"
fi

# 13. PUT /client-briefing en caso cerrado → 409
RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/client-briefing" \
  -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"recomendacion":"Intento de modificar en estado cerrado"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "409" ]; then
  log_pass "13. PUT /client-briefing en caso cerrado -> 409"
else
  log_fail "13. PUT /client-briefing en caso cerrado -> $HTTP (esperado 409)"
fi

# 14. AI query caso inexistente → 404
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/ai/query" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"caso_id":"00000000-0000-4000-8000-000000000001","herramienta":"strategy","consulta":"Test"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "14. AI query caso inexistente -> 404"
else
  log_fail "14. AI query caso inexistente -> $HTTP (esperado 404)"
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "========================================"
echo "RESUMEN E6-03 — FLUJO CIERRE + AI 409 + CLIENT-BRIEFING"
echo "========================================"
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "========================================"
echo ""

echo "Caso de prueba: $RADICADO | ID: $CASE_ID"
echo ""

if [ "$PASSED" -eq 14 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}E6-03 RUNTIME VALIDADO${NC}"
  echo -e "${YELLOW}[PENDIENTE]${NC} Build verde obligatorio: npm run build"
else
  echo -e "${RED}E6-03 NO PUEDE CERRARSE${NC}"
fi
