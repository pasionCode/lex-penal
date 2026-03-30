#!/usr/bin/env bash
# ==============================================================================
# E7-02 RUNTIME — VALIDACIÓN MÓDULO DOCUMENTS
# ==============================================================================
# Proyecto: LEX_PENAL
# Fase: E7
# Unidad: E7-02
# Fecha: 2026-03-30
# ==============================================================================
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:3001/api/v1}"
PASS=0
FAIL=0
TOTAL=0

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; PASS=$((PASS + 1)); TOTAL=$((TOTAL + 1)); }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; FAIL=$((FAIL + 1)); TOTAL=$((TOTAL + 1)); }

# ==============================================================================
# AUTENTICACIÓN
# ==============================================================================
echo "=== AUTENTICACIÓN ==="

TOKEN_ADMIN=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@lexpenal.local","password":"CambiarEnProduccion_2026!"}' \
  | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN_ADMIN" ]; then
  echo "ERROR: No se pudo obtener token admin"
  exit 1
fi
echo "Token admin obtenido"

# ==============================================================================
# CONSTANTES
# ==============================================================================
CASE_ID="c9f0c313-1042-42f7-8371-faa89fd84f42"
UUID_INEXISTENTE="00000000-0000-4000-8000-000000000001"
DOC_ID=""

# ==============================================================================
# PRUEBAS
# ==============================================================================
echo ""
echo "=== E7-02 RUNTIME: MÓDULO DOCUMENTS ==="
echo ""

# ------------------------------------------------------------------------------
# 1. GET /documents — lista vacía o con documentos
# ------------------------------------------------------------------------------
echo "--- Prueba 1: GET /documents (listar) ---"
HTTP_CODE=$(curl -s -o /tmp/e7_02_list.json -w "%{http_code}" \
  -X GET "$BASE_URL/cases/$CASE_ID/documents" \
  -H "Authorization: Bearer $TOKEN_ADMIN")

if [ "$HTTP_CODE" = "200" ]; then
  log_pass "GET /documents retorna 200"
else
  log_fail "GET /documents esperaba 200, obtuvo $HTTP_CODE"
fi

# ------------------------------------------------------------------------------
# 2. POST /documents — crear documento
# ------------------------------------------------------------------------------
echo "--- Prueba 2: POST /documents (crear) ---"
TIMESTAMP=$(date +%s)
HTTP_CODE=$(curl -s -o /tmp/e7_02_create.json -w "%{http_code}" \
  -X POST "$BASE_URL/cases/$CASE_ID/documents" \
  -H "Authorization: Bearer $TOKEN_ADMIN" \
  -H "Content-Type: application/json" \
  -d "{
    \"categoria\": \"evidencia\",
    \"nombre_original\": \"prueba_e7_02_$TIMESTAMP.pdf\",
    \"nombre_almacenado\": \"prueba_e7_02_$TIMESTAMP.pdf\",
    \"ruta\": \"/storage/cases/$CASE_ID/prueba_e7_02_$TIMESTAMP.pdf\",
    \"mime_type\": \"application/pdf\",
    \"tamanio_bytes\": 1024,
    \"descripcion\": \"Documento de prueba E7-02\"
  }")

if [ "$HTTP_CODE" = "201" ]; then
  log_pass "POST /documents retorna 201"
  DOC_ID=$(cat /tmp/e7_02_create.json | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
  echo "    Documento creado: $DOC_ID"
else
  log_fail "POST /documents esperaba 201, obtuvo $HTTP_CODE"
  cat /tmp/e7_02_create.json
fi

# ------------------------------------------------------------------------------
# 3. GET /documents/:id — detalle
# ------------------------------------------------------------------------------
if [ -n "$DOC_ID" ]; then
  echo "--- Prueba 3: GET /documents/:id (detalle) ---"
  HTTP_CODE=$(curl -s -o /tmp/e7_02_detail.json -w "%{http_code}" \
    -X GET "$BASE_URL/cases/$CASE_ID/documents/$DOC_ID" \
    -H "Authorization: Bearer $TOKEN_ADMIN")

  if [ "$HTTP_CODE" = "200" ]; then
    log_pass "GET /documents/:id retorna 200"
    
    # Verificar serialización BigInt → number
    TAMANIO=$(cat /tmp/e7_02_detail.json | grep -o '"tamanio_bytes":[0-9]*' | cut -d':' -f2)
    if [ "$TAMANIO" = "1024" ]; then
      log_pass "BigInt serializado correctamente (tamanio_bytes=$TAMANIO)"
    else
      log_fail "BigInt serialización incorrecta (tamanio_bytes=$TAMANIO)"
    fi
  else
    log_fail "GET /documents/:id esperaba 200, obtuvo $HTTP_CODE"
  fi
else
  echo "--- Prueba 3: SKIP (no hay DOC_ID) ---"
  log_fail "GET /documents/:id no ejecutada por falta de DOC_ID"
fi

# ------------------------------------------------------------------------------
# 4. PUT /documents/:id — actualizar descripción
# ------------------------------------------------------------------------------
if [ -n "$DOC_ID" ]; then
  echo "--- Prueba 4: PUT /documents/:id (actualizar descripcion) ---"
  HTTP_CODE=$(curl -s -o /tmp/e7_02_update.json -w "%{http_code}" \
    -X PUT "$BASE_URL/cases/$CASE_ID/documents/$DOC_ID" \
    -H "Authorization: Bearer $TOKEN_ADMIN" \
    -H "Content-Type: application/json" \
    -d '{"descripcion": "Descripción actualizada E7-02"}')

  if [ "$HTTP_CODE" = "200" ]; then
    log_pass "PUT /documents/:id retorna 200"
    
    # Verificar que descripción fue actualizada
    DESC=$(cat /tmp/e7_02_update.json | grep -o '"descripcion":"[^"]*' | cut -d'"' -f4)
    if [ "$DESC" = "Descripción actualizada E7-02" ]; then
      log_pass "Descripción actualizada correctamente"
    else
      log_fail "Descripción no coincide: $DESC"
    fi
  else
    log_fail "PUT /documents/:id esperaba 200, obtuvo $HTTP_CODE"
    cat /tmp/e7_02_update.json
  fi
else
  echo "--- Prueba 4: SKIP (no hay DOC_ID) ---"
  log_fail "PUT /documents/:id no ejecutada por falta de DOC_ID"
fi

# ------------------------------------------------------------------------------
# 5. GET /documents/:id — documento inexistente → 404
# ------------------------------------------------------------------------------
echo "--- Prueba 5: GET /documents/:id inexistente → 404 ---"
HTTP_CODE=$(curl -s -o /tmp/e7_02_404.json -w "%{http_code}" \
  -X GET "$BASE_URL/cases/$CASE_ID/documents/$UUID_INEXISTENTE" \
  -H "Authorization: Bearer $TOKEN_ADMIN")

if [ "$HTTP_CODE" = "404" ]; then
  log_pass "GET documento inexistente retorna 404"
else
  log_fail "GET documento inexistente esperaba 404, obtuvo $HTTP_CODE"
fi

# ------------------------------------------------------------------------------
# 6. PUT /documents/:id — documento inexistente → 404
# ------------------------------------------------------------------------------
echo "--- Prueba 6: PUT /documents/:id inexistente → 404 ---"
HTTP_CODE=$(curl -s -o /tmp/e7_02_put404.json -w "%{http_code}" \
  -X PUT "$BASE_URL/cases/$CASE_ID/documents/$UUID_INEXISTENTE" \
  -H "Authorization: Bearer $TOKEN_ADMIN" \
  -H "Content-Type: application/json" \
  -d '{"descripcion": "No debería funcionar"}')

if [ "$HTTP_CODE" = "404" ]; then
  log_pass "PUT documento inexistente retorna 404"
else
  log_fail "PUT documento inexistente esperaba 404, obtuvo $HTTP_CODE"
fi

# ------------------------------------------------------------------------------
# 7. POST /documents — validación DTO (categoria inválida)
# ------------------------------------------------------------------------------
echo "--- Prueba 7: POST /documents categoria inválida → 400 ---"
HTTP_CODE=$(curl -s -o /tmp/e7_02_bad_cat.json -w "%{http_code}" \
  -X POST "$BASE_URL/cases/$CASE_ID/documents" \
  -H "Authorization: Bearer $TOKEN_ADMIN" \
  -H "Content-Type: application/json" \
  -d '{
    "categoria": "INVALIDA",
    "nombre_original": "test.pdf",
    "nombre_almacenado": "test.pdf",
    "ruta": "/storage/test.pdf",
    "mime_type": "application/pdf",
    "tamanio_bytes": 1024
  }')

if [ "$HTTP_CODE" = "400" ]; then
  log_pass "POST con categoria inválida retorna 400"
else
  log_fail "POST con categoria inválida esperaba 400, obtuvo $HTTP_CODE"
fi

# ------------------------------------------------------------------------------
# 8. POST /documents — validación DTO (tamanio_bytes = 0)
# ------------------------------------------------------------------------------
echo "--- Prueba 8: POST /documents tamanio_bytes=0 → 400 ---"
HTTP_CODE=$(curl -s -o /tmp/e7_02_bad_size.json -w "%{http_code}" \
  -X POST "$BASE_URL/cases/$CASE_ID/documents" \
  -H "Authorization: Bearer $TOKEN_ADMIN" \
  -H "Content-Type: application/json" \
  -d '{
    "categoria": "evidencia",
    "nombre_original": "test.pdf",
    "nombre_almacenado": "test.pdf",
    "ruta": "/storage/test.pdf",
    "mime_type": "application/pdf",
    "tamanio_bytes": 0
  }')

if [ "$HTTP_CODE" = "400" ]; then
  log_pass "POST con tamanio_bytes=0 retorna 400"
else
  log_fail "POST con tamanio_bytes=0 esperaba 400, obtuvo $HTTP_CODE"
fi

# ------------------------------------------------------------------------------
# 9. GET /documents en caso inexistente → 404
# ------------------------------------------------------------------------------
echo "--- Prueba 9: GET /documents en caso inexistente → 404 ---"
HTTP_CODE=$(curl -s -o /tmp/e7_02_case404.json -w "%{http_code}" \
  -X GET "$BASE_URL/cases/$UUID_INEXISTENTE/documents" \
  -H "Authorization: Bearer $TOKEN_ADMIN")

if [ "$HTTP_CODE" = "404" ]; then
  log_pass "GET documents en caso inexistente retorna 404"
else
  log_fail "GET documents en caso inexistente esperaba 404, obtuvo $HTTP_CODE"
fi

# ==============================================================================
# RESUMEN
# ==============================================================================
echo ""
echo "=============================================="
echo "E7-02 RUNTIME COMPLETADO"
echo "=============================================="
echo "PASS: $PASS"
echo "FAIL: $FAIL"
echo "TOTAL: $TOTAL"
echo "=============================================="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
