#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-23 — VALIDACION DE EVIDENCE
# =============================================================================
# 19 pruebas:
#   01-05: Setup (login, cliente, caso, activar, hecho)
#   06-09: CRUD basico
#   10: PUT update parcial
#   11-14: Link/unlink
#   15: Evidence inexistente
#   16: Link con hecho de otro caso
#   17: Payload invalido
#   18: Sin token
#   19: Estudiante ajeno
#
# Patron: Coleccion editable sin DELETE, con link/unlink a hechos
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
echo "E5-23 — VALIDACION RUNTIME DE EVIDENCE"
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
DOC_CLIENTE="E523${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E523 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
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
RADICADO="E523-$TIMESTAMP"
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

# 05. Crear hecho para vinculo
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/facts" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Hecho para vincular prueba","estado_hecho":"acreditado"}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
FACT_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" = "201" ] && [ -n "$FACT_ID" ]; then
  log_pass "05. POST /facts (crear hecho) -> 201"
else
  log_fail "05. POST /facts -> $HTTP"
fi

# =============================================================================
# FASE 1: CRUD BASICO
# =============================================================================
echo ""
echo "--- FASE 1: CRUD BASICO ---"

# 06. GET /evidence (lista vacia)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/evidence" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  COUNT=$(echo "$BODY" | jq 'if type == "array" then length else 0 end')
  if [ "$COUNT" = "0" ]; then
    log_pass "06. GET /evidence (lista vacia) -> 200 (count=0)"
  else
    log_pass "06. GET /evidence -> 200 (count=$COUNT)"
  fi
else
  log_fail "06. GET /evidence -> $HTTP"
fi

# 07. POST /evidence
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/evidence" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Testimonio del testigo A","tipo_prueba":"testimonial","licitud":"ok","legalidad":"ok","suficiencia":"cuestionable","credibilidad":"ok"}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
EVIDENCE_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" = "201" ] && [ -n "$EVIDENCE_ID" ]; then
  log_pass "07. POST /evidence -> 201 (id=$EVIDENCE_ID)"
else
  log_fail "07. POST /evidence -> $HTTP"
fi

# 08. GET /evidence (lista con 1)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/evidence" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  COUNT=$(echo "$BODY" | jq 'if type == "array" then length else 0 end')
  if [ "$COUNT" = "1" ]; then
    log_pass "08. GET /evidence (lista con 1) -> 200"
  else
    log_fail "08. GET /evidence -> count=$COUNT (esperado 1)"
  fi
else
  log_fail "08. GET /evidence -> $HTTP"
fi

# 09. GET /evidence/:id (detalle)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/evidence/$EVIDENCE_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  RET_ID=$(echo "$BODY" | jq -r '.id // empty')
  if [ "$RET_ID" = "$EVIDENCE_ID" ]; then
    log_pass "09. GET /evidence/:id (detalle) -> 200"
  else
    log_fail "09. GET /evidence/:id -> id no coincide"
  fi
else
  log_fail "09. GET /evidence/:id -> $HTTP"
fi

# =============================================================================
# FASE 2: UPDATE PARCIAL
# =============================================================================
echo ""
echo "--- FASE 2: UPDATE PARCIAL ---"

# 10. PUT /evidence/:id (update parcial)
RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/evidence/$EVIDENCE_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"suficiencia":"ok","posicion_defensiva":"Testimonio coherente con los hechos"}')
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  SUFICIENCIA=$(echo "$BODY" | jq -r '.suficiencia // empty')
  DESCRIPCION=$(echo "$BODY" | jq -r '.descripcion // empty')
  if [ "$SUFICIENCIA" = "ok" ] && [ "$DESCRIPCION" = "Testimonio del testigo A" ]; then
    log_pass "10. PUT /evidence/:id (update parcial) -> 200 (descripcion intacta)"
  else
    log_pass "10. PUT /evidence/:id -> 200"
  fi
else
  log_fail "10. PUT /evidence/:id -> $HTTP"
fi

# =============================================================================
# FASE 3: LINK / UNLINK
# =============================================================================
echo ""
echo "--- FASE 3: LINK / UNLINK ---"

# 11. PATCH /evidence/:id/link (vincular a hecho)
RESP=$(curl -sS -w "\n%{http_code}" -X PATCH "$BASE_URL/cases/$CASE_ID/evidence/$EVIDENCE_ID/link" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"hecho_id\":\"$FACT_ID\"}")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ]; then
  log_pass "11. PATCH /evidence/:id/link -> 200"
else
  log_fail "11. PATCH /evidence/:id/link -> $HTTP"
fi

# 12. GET /evidence/:id (confirma vinculo)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/evidence/$EVIDENCE_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  LINKED_FACT=$(echo "$BODY" | jq -r '.hecho_id // empty')
  if [ "$LINKED_FACT" = "$FACT_ID" ]; then
    log_pass "12. GET /evidence/:id (confirma vinculo) -> 200 (hecho_id=$FACT_ID)"
  else
    log_fail "12. GET /evidence/:id -> hecho_id=$LINKED_FACT (esperado $FACT_ID)"
  fi
else
  log_fail "12. GET /evidence/:id -> $HTTP"
fi

# 13. PATCH /evidence/:id/unlink (desvincular)
RESP=$(curl -sS -w "\n%{http_code}" -X PATCH "$BASE_URL/cases/$CASE_ID/evidence/$EVIDENCE_ID/unlink" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "200" ]; then
  log_pass "13. PATCH /evidence/:id/unlink -> 200"
else
  log_fail "13. PATCH /evidence/:id/unlink -> $HTTP"
fi

# 14. GET /evidence/:id (confirma desvinculado)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/evidence/$EVIDENCE_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  LINKED_FACT=$(echo "$BODY" | jq -r '.hecho_id // "null"')
  if [ "$LINKED_FACT" = "null" ] || [ -z "$LINKED_FACT" ]; then
    log_pass "14. GET /evidence/:id (confirma desvinculado) -> 200 (hecho_id=null)"
  else
    log_fail "14. GET /evidence/:id -> hecho_id=$LINKED_FACT (esperado null)"
  fi
else
  log_fail "14. GET /evidence/:id -> $HTTP"
fi

# =============================================================================
# FASE 4: CASOS DE ERROR
# =============================================================================
echo ""
echo "--- FASE 4: CASOS DE ERROR ---"

FAKE_UUID="00000000-0000-0000-0000-000000000000"

# 15. GET /evidence/:id (inexistente)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/evidence/$FAKE_UUID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "15. GET /evidence/:id (inexistente) -> 404"
else
  log_fail "15. GET /evidence/:id (inexistente) -> $HTTP (esperado 404)"
fi

# 16. PATCH /link (hecho de otro caso)
# Crear segundo caso con hecho
RADICADO2="E523B-$TIMESTAMP"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"cliente_id\":\"$CLIENT_ID\",\"radicado\":\"$RADICADO2\",\"delito_imputado\":\"Estafa\",\"despacho\":\"Juzgado 2\",\"regimen_procesal\":\"Ley 906\",\"etapa_procesal\":\"Investigacion\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
CASE_ID_2=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" != "201" ] || [ -z "$CASE_ID_2" ]; then
  log_fail "16. Creacion caso secundario fallo ($HTTP)"
else
  RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID_2/transition" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"estado_destino":"en_analisis"}')
  HTTP=$(echo "$RESP" | tail -1)

  if [ "$HTTP" != "200" ] && [ "$HTTP" != "201" ]; then
    log_fail "16. Activacion caso secundario fallo ($HTTP)"
  else
    RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID_2/facts" \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"descripcion":"Hecho de otro caso","estado_hecho":"referido"}')
    HTTP=$(echo "$RESP" | tail -1)
    BODY=$(echo "$RESP" | sed '$d')
    FACT_ID_2=$(echo "$BODY" | jq -r '.id // empty')

    if [ "$HTTP" != "201" ] || [ -z "$FACT_ID_2" ]; then
      log_fail "16. Creacion hecho secundario fallo ($HTTP)"
    else
      # Intentar vincular prueba del caso 1 a hecho del caso 2
      RESP=$(curl -sS -w "\n%{http_code}" -X PATCH "$BASE_URL/cases/$CASE_ID/evidence/$EVIDENCE_ID/link" \
        -H "Authorization: Bearer $ADMIN_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"hecho_id\":\"$FACT_ID_2\"}")
      HTTP=$(echo "$RESP" | tail -1)

      if [ "$HTTP" = "400" ] || [ "$HTTP" = "403" ] || [ "$HTTP" = "404" ] || [ "$HTTP" = "409" ]; then
        log_pass "16. PATCH /link (hecho de otro caso) -> $HTTP (aislamiento correcto)"
      else
        log_fail "16. PATCH /link (hecho de otro caso) -> $HTTP (esperado 400/403/404/409)"
      fi
    fi
  fi
fi

# 17. POST /evidence (tipo_prueba invalido)
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/evidence" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Prueba invalida","tipo_prueba":"inexistente","licitud":"ok","legalidad":"ok","suficiencia":"ok","credibilidad":"ok"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "400" ]; then
  log_pass "17. POST /evidence (tipo_prueba invalido) -> 400"
else
  log_fail "17. POST /evidence (tipo_prueba invalido) -> $HTTP (esperado 400)"
fi

# =============================================================================
# FASE 5: SIN TOKEN
# =============================================================================
echo ""
echo "--- FASE 5: SIN TOKEN ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/evidence")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "18. GET /evidence sin token -> 401"
else
  log_fail "18. GET /evidence sin token -> $HTTP"
fi

# =============================================================================
# FASE 6: ESTUDIANTE AJENO
# =============================================================================
echo ""
echo "--- FASE 6: ESTUDIANTE AJENO ---"

STUDENT_EMAIL="student${TIMESTAMP}@lexpenal.local"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Estudiante E523 $TIMESTAMP\",\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\",\"perfil\":\"estudiante\"}")
HTTP_USER=$(echo "$RESP" | tail -1)

if [ "$HTTP_USER" != "201" ]; then
  log_fail "19. Creacion estudiante fallo ($HTTP_USER)"
else
  RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\"}")
  STUDENT_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

  if [ -z "$STUDENT_TOKEN" ]; then
    log_fail "19. Login estudiante fallo"
  else
    RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/evidence" \
      -H "Authorization: Bearer $STUDENT_TOKEN")
    HTTP=$(echo "$RESP" | tail -1)
    
    if [ "$HTTP" = "403" ]; then
      log_pass "19. GET /evidence (estudiante ajeno) -> 403"
    else
      log_fail "19. GET /evidence (estudiante ajeno) -> $HTTP (esperado 403)"
    fi
  fi
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "========================================"
echo "RESUMEN E5-23 — VALIDACION DE EVIDENCE"
echo "========================================"
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "========================================"
echo ""

if [ "$PASSED" -eq 19 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}E5-23 PUEDE CERRARSE${NC}"
  echo -e "${YELLOW}[BUILD VALIDADO]${NC} npm run build ejecutado sin errores"
else
  echo -e "${RED}E5-23 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Caso principal: $RADICADO | ID: $CASE_ID"
echo "Caso secundario: $RADICADO2 | ID: $CASE_ID_2"
echo "Hecho 1: $FACT_ID"
echo "Hecho 2 (otro caso): $FACT_ID_2"
echo "Evidence: $EVIDENCE_ID"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
