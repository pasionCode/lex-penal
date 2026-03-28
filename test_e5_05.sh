#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-05 — ITEMS U008 Y CICLO COMPLETO
# =============================================================================
# VALIDA:
#   - Bootstrap crea 12 bloques con 12 items (1 por bloque)
#   - GET /checklist devuelve items en los 12 bloques
#   - PUT /checklist marca items y recalcula bloque.completado
#   - Bloques críticos pasan a completado = true
#   - en_analisis → pendiente_revision ya no bloquea por checklist
#   - Ciclo completo hasta aprobado_supervisor
#   - Persistencia de revisión operativa
#   - D-05 resuelta
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
echo "E5-05 — ITEMS U008 Y CICLO COMPLETO"
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

DOC_CLIENTE="E505${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E505 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
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
  RADICADO="E505-$TIMESTAMP"
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
# FASE 2: ACTIVAR CASO + VERIFICAR BOOTSTRAP CON ITEMS
# =============================================================================
echo ""
echo "--- FASE 2: ACTIVAR CASO (bootstrap con items) ---"

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

# Verificar bootstrap: 12 bloques con items
if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS "$BASE_URL/cases/$CASE_ID/checklist" -H "Authorization: Bearer $TOKEN")
  BLOQUES_COUNT=$(echo "$RESP" | jq '.bloques | length')
  ITEMS_COUNT=$(echo "$RESP" | jq '[.bloques[].items[]?] | length')
  CRITICOS=$(echo "$RESP" | jq '[.bloques[] | select(.critico == true)] | length')
  
  if [ "$BLOQUES_COUNT" = "12" ] && [ "$ITEMS_COUNT" = "12" ]; then
    log_pass "05. Bootstrap → 12 bloques + 12 items ✓ D-05 RESUELTA"
  elif [ "$BLOQUES_COUNT" = "12" ] && [ "$ITEMS_COUNT" = "0" ]; then
    log_fail "05. Bootstrap → 12 bloques pero 0 items (D-05 NO resuelta)"
  else
    log_fail "05. Bootstrap → $BLOQUES_COUNT bloques, $ITEMS_COUNT items"
  fi
  log_info "    Críticos: $CRITICOS"
else
  log_fail "05. Bootstrap → Sin CASE_ID"
fi

# =============================================================================
# FASE 3: PREPARAR CASO (hechos + estrategia)
# =============================================================================
echo ""
echo "--- FASE 3: PREPARAR CASO ---"

if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/facts" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"descripcion":"El dia 15 de enero de 2026 el procesado fue detenido en flagrancia.","estado_hecho":"acreditado"}')
  HTTP=$(echo "$RESP" | tail -1)
  [ "$HTTP" = "201" ] && log_pass "06. POST /facts → 201" || log_fail "06. POST /facts → $HTTP"
else
  log_fail "06. POST /facts → Sin CASE_ID"
fi

if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/strategy" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"linea_principal":"Defensa por atipicidad objetiva - ausencia de dolo"}')
  HTTP=$(echo "$RESP" | tail -1)
  [ "$HTTP" = "200" ] && log_pass "07. PUT /strategy → 200" || log_fail "07. PUT /strategy → $HTTP"
else
  log_fail "07. PUT /strategy → Sin CASE_ID"
fi

# =============================================================================
# FASE 4: MARCAR ITEMS CRÍTICOS Y COMPLETAR BLOQUES
# =============================================================================
echo ""
echo "--- FASE 4: MARCAR ITEMS (completar bloques críticos) ---"

if [ -n "$CASE_ID" ]; then
  # Obtener todos los item IDs
  RESP=$(curl -sS "$BASE_URL/cases/$CASE_ID/checklist" -H "Authorization: Bearer $TOKEN")
  ITEM_IDS=$(echo "$RESP" | jq -r '[.bloques[].items[]?.id] | join(" ")')
  
  if [ -n "$ITEM_IDS" ] && [ "$ITEM_IDS" != "null" ]; then
    # Construir array de items a marcar
    ITEMS_JSON=$(echo "$ITEM_IDS" | tr ' ' '\n' | jq -R -s 'split("\n") | map(select(length > 0)) | map({id: ., marcado: true})')
    
    RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/checklist" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"items\":$ITEMS_JSON}")
    HTTP=$(echo "$RESP" | tail -1)
    BODY=$(echo "$RESP" | sed '$d')
    
    if [ "$HTTP" = "200" ]; then
      # Verificar que los bloques ahora están completados
      BLOQUES_COMPLETADOS=$(echo "$BODY" | jq '[.bloques[] | select(.completado == true)] | length')
      if [ "$BLOQUES_COMPLETADOS" = "12" ]; then
        log_pass "08. PUT /checklist → 12 bloques completados ✓"
      else
        log_fail "08. PUT /checklist → Solo $BLOQUES_COMPLETADOS bloques completados"
      fi
    else
      log_fail "08. PUT /checklist → $HTTP"
      log_body "$BODY"
    fi
  else
    log_fail "08. PUT /checklist → Sin items para marcar"
  fi
else
  log_fail "08. PUT /checklist → Sin CASE_ID"
fi

# =============================================================================
# FASE 5: SUBIR A REVISIÓN (ya no debe bloquear por checklist)
# =============================================================================
echo ""
echo "--- FASE 5: SUBIR A REVISIÓN ---"

if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"estado_destino":"pendiente_revision"}')
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  
  if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
    ESTADO=$(echo "$BODY" | jq -r '.estado_actual')
    if [ "$ESTADO" = "pendiente_revision" ]; then
      log_pass "09. Transición en_analisis→pendiente_revision → $HTTP ✓ GUARDAS SATISFECHAS"
    else
      log_fail "09. Estado: $ESTADO (esperado: pendiente_revision)"
    fi
  elif [ "$HTTP" = "422" ]; then
    MOTIVOS=$(echo "$BODY" | jq -r '.motivos | join("; ")' 2>/dev/null || echo "$BODY")
    log_fail "09. Transición rechazada → 422"
    log_body "Motivos: $MOTIVOS"
  else
    log_fail "09. Transición → $HTTP"
    log_body "$BODY"
  fi
else
  log_fail "09. Transición → Sin CASE_ID"
fi

# =============================================================================
# FASE 6: DEVOLUCIÓN CON PERSISTENCIA DE REVISIÓN
# =============================================================================
echo ""
echo "--- FASE 6: DEVOLUCIÓN (persistencia de revisión) ---"

if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"estado_destino":"devuelto","observaciones":"Revisar elemento subjetivo del dolo."}')
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
    ESTADO=$(echo "$BODY" | jq -r '.estado_actual')
    [ "$ESTADO" = "devuelto" ] && log_pass "10. Transición pendiente_revision→devuelto → $HTTP" || log_fail "10. Estado: $ESTADO"
  else
    log_fail "10. Transición devuelto → $HTTP"
    log_body "$BODY"
  fi
else
  log_fail "10. Transición → Sin CASE_ID"
fi

# Verificar revisión PERSISTIDA
if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS "$BASE_URL/cases/$CASE_ID/review" -H "Authorization: Bearer $TOKEN")
  REV_COUNT=$(echo "$RESP" | jq 'length')
  REV_DEVUELTO=$(echo "$RESP" | jq '[.[] | select(.resultado == "devuelto")] | length')
  
  if [ "$REV_COUNT" -ge 1 ] && [ "$REV_DEVUELTO" -ge 1 ]; then
    log_pass "11. GET /review → $REV_COUNT revisiones (1+ devuelto) ✓ PERSISTENCIA ACTIVA"
  else
    log_fail "11. GET /review → $REV_COUNT revisiones, $REV_DEVUELTO devuelto"
  fi
else
  log_fail "11. GET /review → Sin CASE_ID"
fi

# Verificar feedback OPERATIVO
if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS "$BASE_URL/cases/$CASE_ID/review/feedback" -H "Authorization: Bearer $TOKEN")
  OBS=$(echo "$RESP" | jq -r '.observaciones // empty')
  RESULTADO=$(echo "$RESP" | jq -r '.resultado // empty')
  
  if [ -n "$OBS" ] && [ "$RESULTADO" = "devuelto" ]; then
    log_pass "12. GET /review/feedback → observaciones + resultado=devuelto ✓"
  else
    log_fail "12. GET /review/feedback → OBS='$OBS', RESULTADO='$RESULTADO'"
  fi
else
  log_fail "12. GET /review/feedback → Sin CASE_ID"
fi

# =============================================================================
# FASE 7: CICLO COMPLETO
# =============================================================================
echo ""
echo "--- FASE 7: CICLO COMPLETO ---"

# devuelto → en_analisis
if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"estado_destino":"en_analisis"}')
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
    ESTADO=$(echo "$BODY" | jq -r '.estado_actual')
    [ "$ESTADO" = "en_analisis" ] && log_pass "13. Transición devuelto→en_analisis → $HTTP" || log_fail "13. Estado: $ESTADO"
  else
    log_fail "13. Transición → $HTTP"
  fi
else
  log_fail "13. Transición → Sin CASE_ID"
fi

# en_analisis → pendiente_revision (2da vez)
if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"estado_destino":"pendiente_revision"}')
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
    ESTADO=$(echo "$BODY" | jq -r '.estado_actual')
    [ "$ESTADO" = "pendiente_revision" ] && log_pass "14. Transición en_analisis→pendiente_revision (2da) → $HTTP" || log_fail "14. Estado: $ESTADO"
  else
    log_fail "14. Transición → $HTTP"
    log_body "$BODY"
  fi
else
  log_fail "14. Transición → Sin CASE_ID"
fi

# pendiente_revision → aprobado_supervisor
if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/transition" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"estado_destino":"aprobado_supervisor","observaciones":"Caso aprobado. Analisis corregido satisfactoriamente."}')
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
    ESTADO=$(echo "$BODY" | jq -r '.estado_actual')
    [ "$ESTADO" = "aprobado_supervisor" ] && log_pass "15. Transición pendiente_revision→aprobado_supervisor → $HTTP" || log_fail "15. Estado: $ESTADO"
  else
    log_fail "15. Transición → $HTTP"
    log_body "$BODY"
  fi
else
  log_fail "15. Transición → Sin CASE_ID"
fi

# Verificar 2 revisiones (1 devuelto + 1 aprobado)
if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS "$BASE_URL/cases/$CASE_ID/review" -H "Authorization: Bearer $TOKEN")
  REV_COUNT=$(echo "$RESP" | jq 'length')
  REV_DEVUELTO=$(echo "$RESP" | jq '[.[] | select(.resultado == "devuelto")] | length')
  REV_APROBADO=$(echo "$RESP" | jq '[.[] | select(.resultado == "aprobado")] | length')
  
  if [ "$REV_COUNT" -ge 2 ] && [ "$REV_DEVUELTO" -ge 1 ] && [ "$REV_APROBADO" -ge 1 ]; then
    log_pass "16. GET /review → $REV_COUNT revisiones (devuelto=$REV_DEVUELTO, aprobado=$REV_APROBADO) ✓"
  else
    log_fail "16. GET /review → Total=$REV_COUNT, Devuelto=$REV_DEVUELTO, Aprobado=$REV_APROBADO"
  fi
else
  log_fail "16. GET /review → Sin CASE_ID"
fi

# Estado final
if [ -n "$CASE_ID" ]; then
  RESP=$(curl -sS "$BASE_URL/cases/$CASE_ID" -H "Authorization: Bearer $TOKEN")
  ESTADO=$(echo "$RESP" | jq -r '.estado_actual')
  [ "$ESTADO" = "aprobado_supervisor" ] && log_pass "17. GET /cases/:id (estado=aprobado_supervisor) → OK" || log_fail "17. Estado final: $ESTADO"
else
  log_fail "17. GET /cases/:id → Sin CASE_ID"
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "=============================================="
echo "RESUMEN E5-05 — ITEMS U008 Y CICLO COMPLETO"
echo "=============================================="
TOTAL=$((PASSED + FAILED + SKIPPED))
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo -e "Omitidas: ${CYAN}$SKIPPED${NC}"
echo "=============================================="
echo ""

echo "CRITERIOS E5-05:"
echo ""
if [ "$PASSED" -ge 15 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "  ${GREEN}✓ Bootstrap 12 bloques + 12 items${NC}"
  echo -e "  ${GREEN}✓ PUT /checklist completa bloques${NC}"
  echo -e "  ${GREEN}✓ en_analisis→pendiente_revision desbloqueado${NC}"
  echo -e "  ${GREEN}✓ Ciclo completo hasta aprobado_supervisor${NC}"
  echo -e "  ${GREEN}✓ Persistencia de revisión operativa${NC}"
  echo ""
  echo -e "${GREEN}D-05 RESUELTA${NC}"
  echo -e "${GREEN}E5-05 PUEDE CERRARSE${NC}"
else
  echo -e "  ${RED}✗ Criterios no cumplidos${NC}"
  echo ""
  echo -e "${RED}E5-05 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Caso: $RADICADO | ID: $CASE_ID"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
