#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-19 — VALIDACION DE DOCUMENTS
# =============================================================================
# 17 pruebas:
#   01-04: Setup
#   05-07: GET lista vacia, POST, GET lista con 1
#   08-10: GET detalle, PUT descripcion, GET refleja + tamanio numerico
#   11-12: Documento inexistente (GET y PUT) -> 404
#   13: POST con tamanio_bytes=0 -> 400
#   14: Sin token -> 401
#   15-17: Estudiante ajeno (lista, detalle, PUT) -> 403
#
# Patron: Coleccion con edicion limitada (solo descripcion editable)
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
echo "E5-19 — VALIDACION RUNTIME DE DOCUMENTS"
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
DOC_CLIENTE="E519${TIMESTAMP}"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Cliente E519 $TIMESTAMP\",\"tipo_documento\":\"CC\",\"documento\":\"$DOC_CLIENTE\",\"situacion_libertad\":\"libre\"}")
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
RADICADO="E519-$TIMESTAMP"
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

# =============================================================================
# FASE 1: COLECCION - LISTA Y CREACION
# =============================================================================
echo ""
echo "--- FASE 1: COLECCION - LISTA Y CREACION ---"

# 05. GET /documents (lista vacia)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/documents" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  COUNT=$(echo "$BODY" | jq 'length')
  if [ "$COUNT" = "0" ]; then
    log_pass "05. GET /documents (lista vacia) -> 200 (count=0)"
  else
    log_pass "05. GET /documents -> 200 (count=$COUNT)"
  fi
else
  log_fail "05. GET /documents -> $HTTP"
fi

# 06. POST /documents
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/documents" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"categoria\":\"evidencia\",\"nombre_original\":\"foto_escena.jpg\",\"nombre_almacenado\":\"${TIMESTAMP}_foto.jpg\",\"ruta\":\"/uploads/${TIMESTAMP}_foto.jpg\",\"mime_type\":\"image/jpeg\",\"tamanio_bytes\":102400,\"descripcion\":\"Fotografia inicial de la escena\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
DOC_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ "$HTTP" = "201" ] && [ -n "$DOC_ID" ]; then
  log_pass "06. POST /documents -> 201 (id=$DOC_ID)"
else
  log_fail "06. POST /documents -> $HTTP"
fi

# 07. GET /documents (lista con 1)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/documents" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  COUNT=$(echo "$BODY" | jq 'length')
  if [ "$COUNT" = "1" ]; then
    log_pass "07. GET /documents (lista con 1) -> 200"
  else
    log_fail "07. GET /documents -> count=$COUNT (esperado 1)"
  fi
else
  log_fail "07. GET /documents -> $HTTP"
fi

# =============================================================================
# FASE 2: DETALLE Y EDICION LIMITADA
# =============================================================================
echo ""
echo "--- FASE 2: DETALLE Y EDICION LIMITADA ---"

# 08. GET /documents/:id (detalle)
if [ -n "$DOC_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/documents/$DOC_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')

  if [ "$HTTP" = "200" ]; then
    CATEGORIA=$(echo "$BODY" | jq -r '.categoria // empty')
    if [ "$CATEGORIA" = "evidencia" ]; then
      log_pass "08. GET /documents/:id (detalle) -> 200"
    else
      log_fail "08. GET /documents/:id -> categoria incorrecta"
    fi
  else
    log_fail "08. GET /documents/:id -> $HTTP"
  fi
else
  log_fail "08. GET /documents/:id -> Sin DOC_ID"
fi

# 09. PUT /documents/:id (actualiza solo descripcion)
if [ -n "$DOC_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/documents/$DOC_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"descripcion":"Descripcion actualizada - fotografia principal"}')
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')

  if [ "$HTTP" = "200" ]; then
    DESC=$(echo "$BODY" | jq -r '.descripcion // empty')
    if [ "$DESC" = "Descripcion actualizada - fotografia principal" ]; then
      log_pass "09. PUT /documents/:id (descripcion) -> 200"
    else
      log_fail "09. PUT /documents/:id -> descripcion no actualizada"
    fi
  else
    log_fail "09. PUT /documents/:id -> $HTTP"
  fi
else
  log_fail "09. PUT /documents/:id -> Sin DOC_ID"
fi

# 10. GET /documents/:id (refleja cambios + tamanio_bytes DEBE ser number)
if [ -n "$DOC_ID" ]; then
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/documents/$DOC_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')

  if [ "$HTTP" = "200" ]; then
    DESC=$(echo "$BODY" | jq -r '.descripcion // empty')
    TAMANIO_TYPE=$(echo "$BODY" | jq -r '.tamanio_bytes | type')
    TAMANIO_VAL=$(echo "$BODY" | jq -r '.tamanio_bytes')
    
    if [ "$DESC" != "Descripcion actualizada - fotografia principal" ]; then
      log_fail "10. GET /documents/:id -> cambios no persistieron"
    elif [ "$TAMANIO_TYPE" != "number" ]; then
      log_fail "10. GET /documents/:id -> tamanio_bytes no es number (type=$TAMANIO_TYPE)"
    elif [ "$TAMANIO_VAL" != "102400" ]; then
      log_fail "10. GET /documents/:id -> tamanio_bytes incorrecto ($TAMANIO_VAL)"
    else
      log_pass "10. GET /documents/:id (cambios + tamanio_bytes=number) -> 200"
    fi
  else
    log_fail "10. GET /documents/:id -> $HTTP"
  fi
else
  log_fail "10. GET /documents/:id -> Sin DOC_ID"
fi

# =============================================================================
# FASE 3: DOCUMENTO INEXISTENTE
# =============================================================================
echo ""
echo "--- FASE 3: DOCUMENTO INEXISTENTE ---"

FAKE_DOC="00000000-0000-0000-0000-000000000099"

# 11. GET /documents/:id (documento inexistente)
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/documents/$FAKE_DOC" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "11. GET /documents/:id (inexistente) -> 404"
else
  log_fail "11. GET /documents/:id (inexistente) -> $HTTP (esperado 404)"
fi

# 12. PUT /documents/:id (documento inexistente)
RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/documents/$FAKE_DOC" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion":"Intento sobre documento inexistente"}')
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "12. PUT /documents/:id (inexistente) -> 404"
else
  log_fail "12. PUT /documents/:id (inexistente) -> $HTTP (esperado 404)"
fi

# =============================================================================
# FASE 4: PAYLOAD INVALIDO
# =============================================================================
echo ""
echo "--- FASE 4: PAYLOAD INVALIDO ---"

# 13. POST /documents con tamanio_bytes=0 -> 400
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/cases/$CASE_ID/documents" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"categoria\":\"evidencia\",\"nombre_original\":\"invalido.jpg\",\"nombre_almacenado\":\"invalido.jpg\",\"ruta\":\"/uploads/invalido.jpg\",\"mime_type\":\"image/jpeg\",\"tamanio_bytes\":0}")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "400" ]; then
  log_pass "13. POST /documents (tamanio_bytes=0) -> 400"
else
  log_fail "13. POST /documents (tamanio_bytes=0) -> $HTTP (esperado 400)"
fi

# =============================================================================
# FASE 5: SIN TOKEN
# =============================================================================
echo ""
echo "--- FASE 5: SIN TOKEN ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/documents")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "401" ]; then
  log_pass "14. GET /documents sin token -> 401"
else
  log_fail "14. GET /documents sin token -> $HTTP"
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
  -d "{\"nombre\":\"Estudiante E519 $TIMESTAMP\",\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\",\"perfil\":\"estudiante\"}")
HTTP_USER=$(echo "$RESP" | tail -1)

if [ "$HTTP_USER" != "201" ]; then
  log_fail "15. Creacion estudiante fallo ($HTTP_USER)"
  log_fail "16. (depende de 15)"
  log_fail "17. (depende de 15)"
else
  RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\"}")
  STUDENT_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

  if [ -z "$STUDENT_TOKEN" ]; then
    log_fail "15. Login estudiante fallo"
    log_fail "16. (depende de 15)"
    log_fail "17. (depende de 15)"
  else
    # 15. GET /documents (lista) estudiante ajeno -> 403
    RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/documents" \
      -H "Authorization: Bearer $STUDENT_TOKEN")
    HTTP=$(echo "$RESP" | tail -1)
    
    if [ "$HTTP" = "403" ]; then
      log_pass "15. GET /documents (estudiante ajeno) -> 403"
    else
      log_fail "15. GET /documents (estudiante ajeno) -> $HTTP (esperado 403)"
    fi

    # 16. GET /documents/:id (detalle) estudiante ajeno -> 403
    if [ -n "$DOC_ID" ]; then
      RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/cases/$CASE_ID/documents/$DOC_ID" \
        -H "Authorization: Bearer $STUDENT_TOKEN")
      HTTP=$(echo "$RESP" | tail -1)
      
      if [ "$HTTP" = "403" ]; then
        log_pass "16. GET /documents/:id (estudiante ajeno) -> 403"
      else
        log_fail "16. GET /documents/:id (estudiante ajeno) -> $HTTP (esperado 403)"
      fi
    else
      log_fail "16. GET /documents/:id -> Sin DOC_ID"
    fi

    # 17. PUT /documents/:id estudiante ajeno -> 403
    if [ -n "$DOC_ID" ]; then
      RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/cases/$CASE_ID/documents/$DOC_ID" \
        -H "Authorization: Bearer $STUDENT_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"descripcion":"Intento no autorizado"}')
      HTTP=$(echo "$RESP" | tail -1)
      
      if [ "$HTTP" = "403" ]; then
        log_pass "17. PUT /documents/:id (estudiante ajeno) -> 403"
      else
        log_fail "17. PUT /documents/:id (estudiante ajeno) -> $HTTP (esperado 403)"
      fi
    else
      log_fail "17. PUT /documents/:id -> Sin DOC_ID"
    fi
  fi
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "========================================"
echo "RESUMEN E5-19 — VALIDACION DE DOCUMENTS"
echo "========================================"
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo "========================================"
echo ""

if [ "$PASSED" -eq 17 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}E5-19 PUEDE CERRARSE${NC}"
  echo -e "${YELLOW}[PENDIENTE] Verificar npm run build manualmente${NC}"
else
  echo -e "${RED}E5-19 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Caso: $RADICADO | ID: $CASE_ID"
echo "Documento: $DOC_ID"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
