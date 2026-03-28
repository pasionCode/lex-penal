#!/usr/bin/env bash
# =============================================================================
# PRUEBAS RUNTIME E5-06 — CIERRE ADMINISTRATIVO DE USERS
# =============================================================================
# VALIDA:
#   - GET /users → 200 (lista usuarios)
#   - GET /users/:id existente → 200
#   - GET /users/:id inexistente → 404
#   - PUT /users/:id actualiza nombre
#   - PUT /users/:id actualiza activo
#   - PUT /users/:id actualiza email válido
#   - PUT /users/:id con email duplicado → 409
#   - usuario no admin → 403
#   - password_hash no aparece en respuestas
#   - npm run build → verde (verificar manualmente)
#
# MODO: Admin + estudiante para verificar 403
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
echo "E5-06 — CIERRE ADMINISTRATIVO DE USERS"
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

# =============================================================================
# FASE 1: CREAR USUARIO DE PRUEBA
# =============================================================================
echo ""
echo "--- FASE 1: CREAR USUARIO DE PRUEBA ---"

TEST_EMAIL="test${TIMESTAMP}@lexpenal.local"
RESP=$(curl -sS -w "\n%{http_code}" -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Usuario Test $TIMESTAMP\",\"email\":\"$TEST_EMAIL\",\"password\":\"TestPassword123!\",\"perfil\":\"estudiante\"}")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "201" ]; then
  TEST_USER_ID=$(echo "$BODY" | jq -r '.id')
  log_pass "02. POST /users (crear estudiante) → 201"
  
  # Verificar que no viene password_hash
  HAS_HASH=$(echo "$BODY" | jq 'has("password_hash")')
  if [ "$HAS_HASH" = "false" ]; then
    log_pass "03. POST /users respuesta sin password_hash ✓"
  else
    log_fail "03. POST /users respuesta CONTIENE password_hash"
  fi
else
  log_fail "02. POST /users → $HTTP"
  log_body "$BODY"
  TEST_USER_ID=""
  log_skip "03. (depende de 02)"
fi

# =============================================================================
# FASE 2: GET /users (lista)
# =============================================================================
echo ""
echo "--- FASE 2: LISTAR USUARIOS ---"

RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP" = "200" ]; then
  COUNT=$(echo "$BODY" | jq 'length')
  log_pass "04. GET /users → 200 ($COUNT usuarios)"
  
  # Verificar estructura saneada (ningún objeto tiene password_hash)
  HAS_ANY_HASH=$(echo "$BODY" | jq '[.[] | has("password_hash")] | any')
  if [ "$HAS_ANY_HASH" = "false" ]; then
    log_pass "05. GET /users sin password_hash en ningún registro ✓"
  else
    log_fail "05. GET /users CONTIENE password_hash en algún registro"
  fi
  
  # Verificar campos esperados
  FIRST_USER=$(echo "$BODY" | jq '.[0]')
  HAS_ID=$(echo "$FIRST_USER" | jq 'has("id")')
  HAS_NOMBRE=$(echo "$FIRST_USER" | jq 'has("nombre")')
  HAS_EMAIL=$(echo "$FIRST_USER" | jq 'has("email")')
  HAS_PERFIL=$(echo "$FIRST_USER" | jq 'has("perfil")')
  HAS_ACTIVO=$(echo "$FIRST_USER" | jq 'has("activo")')
  HAS_CREADO=$(echo "$FIRST_USER" | jq 'has("creado_en")')
  
  if [ "$HAS_ID" = "true" ] && [ "$HAS_NOMBRE" = "true" ] && [ "$HAS_EMAIL" = "true" ] && \
     [ "$HAS_PERFIL" = "true" ] && [ "$HAS_ACTIVO" = "true" ] && [ "$HAS_CREADO" = "true" ]; then
    log_pass "06. GET /users estructura correcta (id,nombre,email,perfil,activo,creado_en) ✓"
  else
    log_fail "06. GET /users faltan campos esperados"
  fi
else
  log_fail "04. GET /users → $HTTP"
  log_body "$BODY"
  log_skip "05. (depende de 04)"
  log_skip "06. (depende de 04)"
fi

# =============================================================================
# FASE 3: GET /users/:id
# =============================================================================
echo ""
echo "--- FASE 3: DETALLE DE USUARIO ---"

if [ -n "$TEST_USER_ID" ]; then
  # GET existente
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/users/$TEST_USER_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  
  if [ "$HTTP" = "200" ]; then
    RETURNED_ID=$(echo "$BODY" | jq -r '.id')
    if [ "$RETURNED_ID" = "$TEST_USER_ID" ]; then
      log_pass "07. GET /users/:id existente → 200"
    else
      log_fail "07. GET /users/:id ID no coincide"
    fi
    
    # Sin password_hash
    HAS_HASH=$(echo "$BODY" | jq 'has("password_hash")')
    if [ "$HAS_HASH" = "false" ]; then
      log_pass "08. GET /users/:id sin password_hash ✓"
    else
      log_fail "08. GET /users/:id CONTIENE password_hash"
    fi
  else
    log_fail "07. GET /users/:id → $HTTP"
    log_skip "08. (depende de 07)"
  fi
else
  log_skip "07. GET /users/:id (sin TEST_USER_ID)"
  log_skip "08. (depende de 07)"
fi

# GET inexistente
FAKE_UUID="00000000-0000-0000-0000-000000000000"
RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/users/$FAKE_UUID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")
HTTP=$(echo "$RESP" | tail -1)

if [ "$HTTP" = "404" ]; then
  log_pass "09. GET /users/:id inexistente → 404"
else
  log_fail "09. GET /users/:id inexistente → $HTTP (esperado 404)"
fi

# =============================================================================
# FASE 4: PUT /users/:id (actualizaciones)
# =============================================================================
echo ""
echo "--- FASE 4: ACTUALIZAR USUARIO ---"

if [ -n "$TEST_USER_ID" ]; then
  # Actualizar nombre
  NUEVO_NOMBRE="Nombre Actualizado $TIMESTAMP"
  RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/users/$TEST_USER_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"nombre\":\"$NUEVO_NOMBRE\"}")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  
  if [ "$HTTP" = "200" ]; then
    RETURNED_NOMBRE=$(echo "$BODY" | jq -r '.nombre')
    if [ "$RETURNED_NOMBRE" = "$NUEVO_NOMBRE" ]; then
      log_pass "10. PUT /users/:id actualiza nombre → 200"
    else
      log_fail "10. PUT nombre no reflejado en respuesta"
    fi
  else
    log_fail "10. PUT /users/:id (nombre) → $HTTP"
    log_body "$BODY"
  fi
  
  # Actualizar activo
  RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/users/$TEST_USER_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"activo":false}')
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  
  if [ "$HTTP" = "200" ]; then
    RETURNED_ACTIVO=$(echo "$BODY" | jq '.activo')
    if [ "$RETURNED_ACTIVO" = "false" ]; then
      log_pass "11. PUT /users/:id actualiza activo → 200"
    else
      log_fail "11. PUT activo no reflejado en respuesta"
    fi
  else
    log_fail "11. PUT /users/:id (activo) → $HTTP"
  fi
  
  # Reactivar para pruebas siguientes
  curl -sS -X PUT "$BASE_URL/users/$TEST_USER_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"activo":true}' > /dev/null
  
  # Actualizar email válido
  NUEVO_EMAIL="updated${TIMESTAMP}@lexpenal.local"
  RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/users/$TEST_USER_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$NUEVO_EMAIL\"}")
  HTTP=$(echo "$RESP" | tail -1)
  BODY=$(echo "$RESP" | sed '$d')
  
  if [ "$HTTP" = "200" ]; then
    RETURNED_EMAIL=$(echo "$BODY" | jq -r '.email')
    if [ "$RETURNED_EMAIL" = "$NUEVO_EMAIL" ]; then
      log_pass "12. PUT /users/:id actualiza email → 200"
    else
      log_fail "12. PUT email no reflejado en respuesta"
    fi
  else
    log_fail "12. PUT /users/:id (email) → $HTTP"
    log_body "$BODY"
  fi
  
  # Sin password_hash en respuesta de PUT
  HAS_HASH=$(echo "$BODY" | jq 'has("password_hash")')
  if [ "$HAS_HASH" = "false" ]; then
    log_pass "13. PUT /users/:id sin password_hash en respuesta ✓"
  else
    log_fail "13. PUT /users/:id CONTIENE password_hash"
  fi
else
  log_skip "10-13. PUT /users/:id (sin TEST_USER_ID)"
  SKIPPED=$((SKIPPED + 4))
fi

# =============================================================================
# FASE 5: EMAIL DUPLICADO
# =============================================================================
echo ""
echo "--- FASE 5: EMAIL DUPLICADO ---"

if [ -n "$TEST_USER_ID" ]; then
  # Intentar cambiar email al del admin
  RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/users/$TEST_USER_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"email":"admin@lexpenal.local"}')
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "409" ]; then
    log_pass "14. PUT /users/:id email duplicado → 409"
  else
    log_fail "14. PUT email duplicado → $HTTP (esperado 409)"
  fi
else
  log_skip "14. (sin TEST_USER_ID)"
fi

# =============================================================================
# FASE 6: ACCESO NO ADMIN → 403
# =============================================================================
echo ""
echo "--- FASE 6: ACCESO NO ADMIN ---"

# Crear estudiante y obtener su token
STUDENT_EMAIL="student${TIMESTAMP}@lexpenal.local"
curl -sS -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Estudiante $TIMESTAMP\",\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\",\"perfil\":\"estudiante\"}" > /dev/null

RESP=$(curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$STUDENT_EMAIL\",\"password\":\"StudentPass123!\"}")
STUDENT_TOKEN=$(echo "$RESP" | jq -r '.access_token // empty')

if [ -n "$STUDENT_TOKEN" ]; then
  # GET /users como estudiante
  RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/users" \
    -H "Authorization: Bearer $STUDENT_TOKEN")
  HTTP=$(echo "$RESP" | tail -1)
  
  if [ "$HTTP" = "403" ]; then
    log_pass "15. GET /users como estudiante → 403"
  else
    log_fail "15. GET /users como estudiante → $HTTP (esperado 403)"
  fi
  
  # GET /users/:id como estudiante
  if [ -n "$TEST_USER_ID" ]; then
    RESP=$(curl -sS -w "\n%{http_code}" "$BASE_URL/users/$TEST_USER_ID" \
      -H "Authorization: Bearer $STUDENT_TOKEN")
    HTTP=$(echo "$RESP" | tail -1)
    
    if [ "$HTTP" = "403" ]; then
      log_pass "16. GET /users/:id como estudiante → 403"
    else
      log_fail "16. GET /users/:id como estudiante → $HTTP (esperado 403)"
    fi
  else
    log_skip "16. (sin TEST_USER_ID)"
  fi
  
  # PUT /users/:id como estudiante
  if [ -n "$TEST_USER_ID" ]; then
    RESP=$(curl -sS -w "\n%{http_code}" -X PUT "$BASE_URL/users/$TEST_USER_ID" \
      -H "Authorization: Bearer $STUDENT_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"nombre":"Intento no autorizado"}')
    HTTP=$(echo "$RESP" | tail -1)
    
    if [ "$HTTP" = "403" ]; then
      log_pass "17. PUT /users/:id como estudiante → 403"
    else
      log_fail "17. PUT /users/:id como estudiante → $HTTP (esperado 403)"
    fi
  else
    log_skip "17. (sin TEST_USER_ID)"
  fi
else
  log_fail "15. No se pudo obtener token de estudiante"
  log_skip "16. (depende de 15)"
  log_skip "17. (depende de 15)"
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "=============================================="
echo "RESUMEN E5-06 — CIERRE ADMINISTRATIVO USERS"
echo "=============================================="
TOTAL=$((PASSED + FAILED + SKIPPED))
echo -e "Pasadas:  ${GREEN}$PASSED${NC}"
echo -e "Fallidas: ${RED}$FAILED${NC}"
echo -e "Omitidas: ${CYAN}$SKIPPED${NC}"
echo "=============================================="
echo ""

echo "CRITERIOS E5-06:"
echo ""
if [ "$PASSED" -eq 17 ] && [ "$FAILED" -eq 0 ]; then
  echo -e "  ${GREEN}✓ GET /users → 200${NC}"
  echo -e "  ${GREEN}✓ GET /users/:id existente → 200${NC}"
  echo -e "  ${GREEN}✓ GET /users/:id inexistente → 404${NC}"
  echo -e "  ${GREEN}✓ PUT /users/:id actualiza nombre${NC}"
  echo -e "  ${GREEN}✓ PUT /users/:id actualiza activo${NC}"
  echo -e "  ${GREEN}✓ PUT /users/:id actualiza email${NC}"
  echo -e "  ${GREEN}✓ PUT /users/:id email duplicado → 409${NC}"
  echo -e "  ${GREEN}✓ usuario no admin → 403${NC}"
  echo -e "  ${GREEN}✓ password_hash nunca expuesto${NC}"
  echo ""
  echo -e "${GREEN}E5-06 PUEDE CERRARSE${NC}"
  echo -e "${YELLOW}[PENDIENTE] Verificar npm run build manualmente${NC}"
elif [ "$FAILED" -eq 0 ] && [ $((PASSED + SKIPPED)) -eq 17 ]; then
  echo -e "  ${CYAN}○ Cierre con skips controlados (PASSED=$PASSED, SKIPPED=$SKIPPED)${NC}"
  echo ""
  echo -e "${CYAN}E5-06 CIERRE PARCIAL POSIBLE${NC}"
else
  echo -e "  ${RED}✗ Criterios no cumplidos (PASSED=$PASSED, FAILED=$FAILED)${NC}"
  echo ""
  echo -e "${RED}E5-06 NO PUEDE CERRARSE${NC}"
fi

echo ""
echo "Usuario test: $TEST_EMAIL | ID: $TEST_USER_ID"
echo ""

[ "$FAILED" -gt 0 ] && exit 1 || exit 0
