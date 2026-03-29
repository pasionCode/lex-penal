#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-22 — VALIDACION DE BASIC-INFO (CORRECCION CONTRACTUAL)
# =============================================================================
# 6 pruebas:
#   01: Login admin
#   02: GET /cases/:id (ficha basica via agregado raiz)
#   03: PUT /cases/:id (actualiza campos editables)
#   04: GET /cases/:id (refleja cambios)
#   05: GET /cases/:id/basic-info (confirma 404)
#   06: PUT /cases/:id/basic-info (confirma 404)
#
# Objetivo: Confirmar hallazgo y validar superficie real
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
echo "E5-22 — VALIDACION BASIC-INFO"
echo "========================================"
echo "Timestamp: $TIMESTAMP"
echo ""

# =============================================================================
# FASE 1: SETUP Y SUPERFICIE REAL
# =============================================================================
log_info "Fase 1: Setup y superficie real..."

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

# Crear cliente y caso para pruebas
DOC_CLIENTE="E522${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E522 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CLIENT_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" != "201" ] || [ -z "$CLIENT_ID" ]; then
  echo -e "${RED}[ERROR] No se pudo crear cliente ($HTTP). Abortando.${NC}"
  exit 1
fi

RADICADO="E522-$TIMESTAMP"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"cliente_id\":\"$CLIENT_ID\",\"radicado\":\"$RADICADO\",\"delito_imputado\":\"Hurto\",\"despacho\":\"Juzgado Original\",\"regimen_procesal\":\"Ley 906\",\"etapa_procesal\":\"Investigacion\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CASE_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" != "201" ] || [ -z "$CASE_ID" ]; then
  echo -e "${RED}[ERROR] No se pudo crear caso ($HTTP). Abortando.${NC}"
  exit 1
fi

# Activar caso
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"estado_destino":"en_analisis"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" != "200" ] && [ "$HTTP" != "201" ]; then
  echo -e "${RED}[ERROR] No se pudo activar caso ($HTTP). Abortando.${NC}"
  exit 1
fi

log_info "Setup completo: cliente=$CLIENT_ID, caso=$CASE_ID"

# 02. GET /cases/:id (ficha basica via agregado raiz)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  DESPACHO=$(echo "$BODY" | jq -r '.despacho // empty')
  RADICADO_RET=$(echo "$BODY" | jq -r '.radicado // empty')
  if [ "$DESPACHO" = "Juzgado Original" ] && [ -n "$RADICADO_RET" ]; then
    log_pass "02. GET /cases/:id (ficha basica) -> 200"
  else
    log_fail "02. GET /cases/:id -> respuesta incompleta"
  fi
else
  log_fail "02. GET /cases/:id -> $HTTP"
fi

# 03. PUT /cases/:id (actualiza campos editables)
RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"despacho":"Juzgado Modificado","observaciones":"Observacion de prueba E522","agravantes":"Ninguno"}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  DESPACHO=$(echo "$BODY" | jq -r '.despacho // empty')
  OBS=$(echo "$BODY" | jq -r '.observaciones // empty')
  if [ "$DESPACHO" = "Juzgado Modificado" ] && [ "$OBS" = "Observacion de prueba E522" ]; then
    log_pass "03. PUT /cases/:id (actualiza campos) -> 200"
  else
    log_fail "03. PUT /cases/:id -> campos no actualizados"
  fi
else
  log_fail "03. PUT /cases/:id -> $HTTP"
fi

# 04. GET /cases/:id (refleja cambios)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  DESPACHO=$(echo "$BODY" | jq -r '.despacho // empty')
  OBS=$(echo "$BODY" | jq -r '.observaciones // empty')
  AGR=$(echo "$BODY" | jq -r '.agravantes // empty')
  if [ "$DESPACHO" = "Juzgado Modificado" ] && [ "$OBS" = "Observacion de prueba E522" ] && [ "$AGR" = "Ninguno" ]; then
    log_pass "04. GET /cases/:id (refleja cambios) -> 200"
  else
    log_fail "04. GET /cases/:id -> cambios no persistieron"
  fi
else
  log_fail "04. GET /cases/:id -> $HTTP"
fi

# =============================================================================
# FASE 2: CONFIRMAR HALLAZGO - SUBRECURSO NO EXISTE
# =============================================================================
echo ""
echo "--- FASE 2: CONFIRMAR HALLAZGO ---"

# 05. GET /cases/:id/basic-info (confirma 404)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/basic-info" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "05. GET /cases/:id/basic-info -> 404 (NO EXISTE - confirma hallazgo)"
else
  log_fail "05. GET /cases/:id/basic-info -> $HTTP (esperado 404)"
fi

# 06. PUT /cases/:id/basic-info (confirma 404)
RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/basic-info" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"despacho":"Intento via basic-info"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "06. PUT /cases/:id/basic-info -> 404 (NO EXISTE - confirma hallazgo)"
else
  log_fail "06. PUT /cases/:id/basic-info -> $HTTP (esperado 404)"
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "========================================"
echo "RESUMEN E5-22 — VALIDACION BASIC-INFO"
echo "========================================"
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "========================================"
echo ""

if [ "$PASSED" -eq 6 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}E5-22 PUEDE CERRARSE${NC}"
  echo -e "${YELLOW}[HALLAZGO CONFIRMADO]${NC} /basic-info NO existe en runtime"
  echo -e "${YELLOW}[SUPERFICIE REAL]${NC} GET/PUT /cases/:id funciona correctamente"
  echo -e "${YELLOW}[CONTRATO ALINEADO]${NC} Correccion contractual aplicada en CONTRATO_API.md"
else
  echo -e "${RED}E5-22 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Caso: $RADICADO | ID: $CASE_ID"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
