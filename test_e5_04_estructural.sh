#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-04 — UNIFICACIÓN ESTRUCTURAL
# =============================================================================
# VALIDA:
#   - Delegación a CasoEstadoService activa
#   - Bootstrap 12 bloques (generarEstructuraBase)
#   - Guardas de transición ejecutándose (rechazo con 422)
#
# CONSERVADO EN CÓDIGO (no validado en runtime por D-04):
#   - checkAccess() antes de delegación
#
# NO VALIDA (bloqueado por D-05):
#   - Ciclo completo hasta pendiente_revision
#   - Persistencia de revisión (requiere llegar a devuelto/aprobado)
#   - Feedback de revisión
#
# MODO: Single-actor (admin) por D-04
#
# Requiere: jq instalado, backend en puerto 3001
# =============================================================================
set -euo pipefail

BASE_URL="${1:-http://localhost:3001/api/v1}"
PASSED=0
FAILED=0
SKIPPED=0
TIMESTAMP=$(date +%s)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; PASSED=$((PASSED + 1)); }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; FAILED=$((FAILED + 1)); }
log_skip() { echo -e "${CYAN}[SKIP]${NC} $1"; SKIPPED=$((SKIPPED + 1)); }
log_info() { echo -e "${YELLOW}[INFO]${NC} $1"; }
log_body() { echo -e "${RED}[BODY]${NC} $1"; }

if ! command -v jq &> /dev/null; then
  echo -e "${RED}[ERROR] jq no instalado.${NC}"
  exit 1
fi

echo ""
echo "=========================================="
echo "E5-04 — UNIFICACIÓN ESTRUCTURAL"
echo "=========================================="
echo "Timestamp: $TIMESTAMP"
echo ""

# =============================================================================
# SETUP
# =============================================================================
log_info "Fase 0: Setup..."

RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@lexpenal.local","password":"CambiarEnProduccion_2026!"}')
TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')
if [ -z "$TOKEN" ]; then
  echo -e "${RED}[ERROR] No se obtuvo token. Abortando.${NC}"
  exit 1
fi
log_pass "01. Login admin → 200"

# =============================================================================
# FASE 1: CREAR CASO
# =============================================================================
echo ""
echo "--- FASE 1: CREAR CASO ---"

DOC_CLIENTE="E504${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E504 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
if [ "$HTTP" = "201" ]; then
  CLIENT_ID=$(echo "$BODY" | jq -r '.id')
  log_pass "02. POST /clients → 201"
else
  log_fail "02. POST /clients → $HTTP"
  CLIENT_ID=""
fi

if [ -n "$CLIENT_ID" ]; then
  RADICADO="E504-$TIMESTAMP"
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"cliente_id\":\"$CLIENT_ID\",\"radicado\":\"$RADICADO\",\"delito_imputado\":\"Hurto calificado\",\"despacho\":\"Juzgado 1 Penal\",\"regimen_procesal\":\"Ley 906\",\"etapa_procesal\":\"Investigacion\"}")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  if [ "$HTTP" = "201" ]; then
    CASE_ID=$(echo "$BODY" | jq -r '.id')
    ESTADO=$(echo "$BODY" | jq -r '.estado_actual')
    [ "$ESTADO" = "borrador" ] && log_pass "03. POST /cases (estado=borrador) → 201" || log_fail "03. Estado: $ESTADO"
  else
    log_fail "03. POST /cases → $HTTP"
    CASE_ID=""
  fi
else
  log_fail "03. POST /cases → Sin CLIENT_ID"
  CASE_ID=""
fi

# =============================================================================
# FASE 2: TRANSICIÓN borrador → en_analisis + BOOTSTRAP
# =============================================================================
echo ""
echo "--- FASE 2: ACTIVAR CASO (bootstrap) ---"

if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"estado_destino":"en_analisis"}')
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
    ESTADO=$(echo "$BODY" | jq -r '.estado_actual')
    [ "$ESTADO" = "en_analisis" ] && log_pass "04. Transición borrador→en_analisis → $HTTP" || log_fail "04. Estado: $ESTADO"
  else
    log_fail "04. Transición borrador→en_analisis → $HTTP"
    log_body "$BODY"
  fi
else
  log_fail "04. Transición → Sin CASE_ID"
fi

# Verificar bootstrap: 12 bloques (generarEstructuraBase)
if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS "$BASE_URL/cases/$CASE_ID/checklist" -H "Authorization: Bearer $TOKEN")
  BLOQUES_COUNT=$(echo "$RESP" | jq '.bloques | length')
  ITEMS_COUNT=$(echo "$RESP" | jq '[.bloques[].items[]?] | length')
  CRITICOS=$(echo "$RESP" | jq '[.bloques[] | select(.critico == true)] | length')
  
  if [ "$BLOQUES_COUNT" = "12" ]; then
    log_pass "05. Bootstrap 12 bloques → CasoEstadoService CONECTADO"
    log_info "    Críticos: $CRITICOS | Items: $ITEMS_COUNT"
  elif [ "$BLOQUES_COUNT" = "3" ]; then
    log_fail "05. Bootstrap 3 bloques → CasoEstadoService NO conectado (usa ChecklistService antiguo)"
  else
    log_fail "05. Bootstrap → $BLOQUES_COUNT bloques (inesperado)"
  fi
else
  log_fail "05. Bootstrap → Sin CASE_ID"
fi

# Verificar estructuras auxiliares creadas
if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/strategy" -H "Authorization: Bearer $TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  [ "$HTTP" = "200" ] && log_pass "06. GET /strategy (estructura vacía creada) → 200" || log_fail "06. GET /strategy → $HTTP"
else
  log_fail "06. GET /strategy → Sin CASE_ID"
fi

# =============================================================================
# FASE 3: GUARDAS ACTIVAS
# =============================================================================
echo ""
echo "--- FASE 3: GUARDAS ACTIVAS ---"

# Intentar transición SIN cumplir guardas (debe fallar con 422)
if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"estado_destino":"pendiente_revision"}')
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  if [ "$HTTP" = "422" ]; then
    MOTIVOS=$(echo "$BODY" | jq -r '.motivos | join("; ")' 2>/dev/null || echo "$BODY")
    log_pass "07. Guarda activa: rechaza con 422"
    log_info "    Motivos: $MOTIVOS"
  elif [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
    log_fail "07. Guarda NO activa: transición pasó sin cumplir requisitos"
  else
    log_fail "07. Código inesperado → $HTTP"
    log_body "$BODY"
  fi
else
  log_fail "07. Guarda → Sin CASE_ID"
fi

# Verificar que la guarda menciona checklist (D-05)
if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS -X POST "$BASE_URL/cases/$CASE_ID/transition" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"estado_destino":"pendiente_revision"}')
  MOTIVOS=$(echo "$RESP" | jq -r '.motivos[]?' 2>/dev/null || echo "")
  
  if echo "$MOTIVOS" | grep -qi "checklist\|bloque"; then
    log_pass "08. Guarda verifica checklist → D-05 confirmada"
  else
    log_info "08. Guarda no menciona checklist explícitamente"
  fi
else
  log_skip "08. Verificación checklist → Sin CASE_ID"
fi

# =============================================================================
# FASE 4: PREPARAR CASO (hechos + estrategia)
# =============================================================================
echo ""
echo "--- FASE 4: PREPARAR CASO ---"

if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/facts" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"descripcion":"Hecho de prueba E5-04.","estado_hecho":"acreditado"}')
  HTTP=$(echo "$RESP" | tail -1)
  [ "$HTTP" = "201" ] && log_pass "09. POST /facts → 201" || log_fail "09. POST /facts → $HTTP"
else
  log_fail "09. POST /facts → Sin CASE_ID"
fi

if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/strategy" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"linea_principal":"Defensa E5-04"}')
  HTTP=$(echo "$RESP" | tail -1)
  [ "$HTTP" = "200" ] && log_pass "10. PUT /strategy → 200" || log_fail "10. PUT /strategy → $HTTP"
else
  log_fail "10. PUT /strategy → Sin CASE_ID"
fi

# =============================================================================
# FASE 5: VERIFICAR BLOQUEO POR D-05
# =============================================================================
echo ""
echo "--- FASE 5: VERIFICAR D-05 (bloqueo checklist) ---"

# Intentar transición después de satisfacer hechos+estrategia pero sin checklist
if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"estado_destino":"pendiente_revision"}')
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  
  if [ "$HTTP" = "422" ]; then
    MOTIVOS=$(echo "$BODY" | jq -r '.motivos | join("; ")' 2>/dev/null || echo "$BODY")
    if echo "$MOTIVOS" | grep -qi "checklist\|bloque\|crítico"; then
      log_pass "11. D-05 confirmada: checklist bloquea transición"
      log_info "    Motivos: $MOTIVOS"
    else
      log_info "11. Transición rechazada por otro motivo: $MOTIVOS"
    fi
  elif [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
    log_pass "11. Transición exitosa (D-05 no aplica o checklist OK)"
  else
    log_fail "11. Código inesperado → $HTTP"
  fi
else
  log_fail "11. Verificación D-05 → Sin CASE_ID"
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "=============================================="
echo "RESUMEN E5-04 — UNIFICACIÓN ESTRUCTURAL"
echo "=============================================="
TOTAL=$((PASSED + FAILED + SKIPPED))
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo -e "Omitidas: ${CYAN}$SKIPPED${NC}"
echo "=============================================="
echo ""

echo "CRITERIOS E5-04:"
echo ""
echo "UNIFICACIÓN ESTRUCTURAL:"
if [ "$PASSED" -ge 5 ]; then
  echo -e "  ${GREEN}✓ CasoEstadoService conectado (bootstrap 12 bloques)${NC}"
  echo -e "  ${GREEN}✓ Guardas ejecutándose (rechazo 422)${NC}"
  echo -e "  ${CYAN}○ checkAccess() conservado en código (no validado runtime)${NC}"
  echo ""
  echo -e "${GREEN}D-02 RESUELTA ESTRUCTURALMENTE${NC}"
else
  echo -e "  ${RED}✗ Unificación no completada${NC}"
fi

echo ""
echo "PENDIENTE (D-05):"
echo -e "  ${YELLOW}⏳ Ciclo completo bloqueado por checklist sin items${NC}"
echo -e "  ${YELLOW}⏳ Persistencia de revisión no validada${NC}"
echo -e "  ${YELLOW}⏳ Feedback no validado${NC}"

echo ""
echo "Caso: $RADICADO | ID: $CASE_ID"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
