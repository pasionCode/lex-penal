# BASELINE `documents` — Sprint 12

**Fecha:** 2026-03-26  
**Proyecto:** LEX_PENAL  
**Fase:** E5 — Expansión funcional controlada  
**Sprint:** 12  
**Objetivo:** Capturar estado previo del subrecurso `documents` antes de intervención de hardening

---

## 1. Identificación del endpoint

| Campo | Valor |
|-------|-------|
| Ruta | `/api/v1/cases/:caseId/documents` |
| Métodos verificados | GET, POST |
| caseId de pruebas | `c9f0c313-1042-42f7-8371-faa89fd84f42` |
| Usuario autenticado | `admin@lexpenal.local` (perfil: administrador) |

---

## 2. DTO actual de `documents`

Campos requeridos para POST:

| Campo | Tipo | Restricciones |
|-------|------|---------------|
| `categoria` | enum | acusacion, defensa, cliente, actuacion, informe, evidencia, anexo, otro |
| `nombre_original` | string | max 255 caracteres |
| `nombre_almacenado` | string | max 255 caracteres |
| `ruta` | string | max 500 caracteres |
| `mime_type` | string | max 100 caracteres |
| `tamanio_bytes` | integer | debe ser positivo |
| `descripcion` | string | opcional |

---

## 3. Baseline confirmado

### 3.1 GET 200 — Listado de documentos

**Request:**
```bash
curl -s -X GET "http://localhost:3001/api/v1/cases/c9f0c313-1042-42f7-8371-faa89fd84f42/documents" \
  -H "Authorization: Bearer <TOKEN>"
```

**Response:** `200 OK`
```json
[
  {
    "id": "5bc16507-5b6d-4367-b6a6-b086feace988",
    "caso_id": "c9f0c313-1042-42f7-8371-faa89fd84f42",
    "categoria": "defensa",
    "nombre_original": "escrito_defensa.pdf",
    "nombre_almacenado": "def_001_20260326.pdf",
    "ruta": "/docs/casos/c9f0c313/def_001_20260326.pdf",
    "mime_type": "application/pdf",
    "tamanio_bytes": 245678,
    "descripcion": "Escrito inicial de defensa - actualizado Sprint 11",
    "subido_en": "2026-03-26T16:12:05.040Z",
    "subido_por": "71e47a55-8803-4842-bf3c-c573bf2cc709"
  },
  {
    "id": "94851482-7703-4337-9f9b-b2dc4fd79e5d",
    "caso_id": "c9f0c313-1042-42f7-8371-faa89fd84f42",
    "categoria": "defensa",
    "nombre_original": "escrito_defensa.pdf",
    "nombre_almacenado": "def_001_20260326.pdf",
    "ruta": "/docs/casos/c9f0c313/def_001_20260326.pdf",
    "mime_type": "application/pdf",
    "tamanio_bytes": 245678,
    "descripcion": "Escrito inicial de defensa",
    "subido_en": "2026-03-26T16:10:25.010Z",
    "subido_por": "71e47a55-8803-4842-bf3c-c573bf2cc709"
  }
]
```

**Verificación:** ✅ Devuelve array de documentos asociados al caso.

---

### 3.2 POST 201 — Creación válida

**Request:**
```bash
curl -s -X POST "http://localhost:3001/api/v1/cases/c9f0c313-1042-42f7-8371-faa89fd84f42/documents" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "categoria": "defensa",
    "nombre_original": "baseline_s12.pdf",
    "nombre_almacenado": "bas_001_20260326.pdf",
    "ruta": "/docs/casos/baseline/bas_001.pdf",
    "mime_type": "application/pdf",
    "tamanio_bytes": 1024,
    "descripcion": "Baseline S12 - POST válido"
  }'
```

**Response:** `201 Created`
```json
{
  "id": "4ff3d83d-adc3-49c1-83e8-f177387b2650",
  "caso_id": "c9f0c313-1042-42f7-8371-faa89fd84f42",
  "categoria": "defensa",
  "nombre_original": "baseline_s12.pdf",
  "nombre_almacenado": "bas_001_20260326.pdf",
  "ruta": "/docs/casos/baseline/bas_001.pdf",
  "mime_type": "application/pdf",
  "tamanio_bytes": 1024,
  "descripcion": "Baseline S12 - POST válido",
  "subido_en": "2026-03-26T21:17:57.140Z",
  "subido_por": "71e47a55-8803-4842-bf3c-c573bf2cc709"
}
```

**Verificación:** ✅ Documento creado y persistido correctamente.

---

### 3.3 POST 400 — Payload vacío

**Request:**
```bash
curl -s -X POST "http://localhost:3001/api/v1/cases/c9f0c313-1042-42f7-8371-faa89fd84f42/documents" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Response:** `400 Bad Request`
```json
{
  "statusCode": 400,
  "error": "Bad Request",
  "mensaje": [
    "categoria debe ser: acusacion, defensa, cliente, actuacion, informe, evidencia, anexo u otro",
    "nombre_original no puede exceder 255 caracteres",
    "nombre_original debe ser texto",
    "nombre_almacenado no puede exceder 255 caracteres",
    "nombre_almacenado debe ser texto",
    "ruta no puede exceder 500 caracteres",
    "ruta debe ser texto",
    "mime_type no puede exceder 100 caracteres",
    "mime_type debe ser texto",
    "tamanio_bytes debe ser positivo",
    "tamanio_bytes debe ser entero"
  ],
  "path": "/api/v1/cases/c9f0c313-1042-42f7-8371-faa89fd84f42/documents",
  "timestamp": "2026-03-26T21:17:08.992Z"
}
```

**Verificación:** ✅ Validaciones activas, mensajes descriptivos en español.

---

### 3.4 POST 404 — caseId inexistente

**Request:**
```bash
curl -s -X POST "http://localhost:3001/api/v1/cases/00000000-0000-0000-0000-000000000000/documents" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "categoria": "defensa",
    "nombre_original": "baseline_s12.pdf",
    "nombre_almacenado": "bas_001_20260326.pdf",
    "ruta": "/docs/casos/baseline/bas_001.pdf",
    "mime_type": "application/pdf",
    "tamanio_bytes": 1024,
    "descripcion": "Baseline S12 - caseId inexistente"
  }'
```

**Response:** `404 Not Found`
```json
{
  "statusCode": 404,
  "error": "Not Found",
  "mensaje": "Caso 00000000-0000-0000-0000-000000000000 no encontrado",
  "path": "/api/v1/cases/00000000-0000-0000-0000-000000000000/documents",
  "timestamp": "2026-03-26T21:18:03.244Z"
}
```

**Verificación:** ✅ Validación de existencia del caso activa, mensaje claro.

---

## 4. Hallazgos preliminares

| # | Observación | Impacto |
|---|-------------|---------|
| 1 | Encoding UTF-8: `"válido"` aparece como `"v�lido"` en respuesta de prueba | Issue de entorno (terminal Git Bash en Windows), backend OK |
| 2 | Validación DTO ocurre antes de verificar existencia del caso | Comportamiento defensivo correcto |
| 3 | Mensajes de error en español y descriptivos | Alineado con política del proyecto |

**Nota sobre encoding:** Documentos creados en Sprint 11 muestran caracteres UTF-8 correctos. El issue se presenta solo en pruebas enviadas desde Git Bash. No requiere intervención en backend.

---

## 5. Matriz de pruebas de hardening ejecutadas

| # | Prueba | Objetivo | Estado |
|---|--------|----------|--------|
| 1 | GET con caseId inexistente | Verificar si devuelve 404 o array vacío | EJECUTADA |
| 2 | POST con `categoria` inválida | Verificar rechazo de enum fuera de rango | EJECUTADA |
| 3 | POST con `tamanio_bytes = 0` | Verificar validación de límite inferior | EJECUTADA |
| 4 | POST con `tamanio_bytes < 0` | Verificar rechazo de valor negativo | EJECUTADA |
| 5 | POST con `nombre_original = ""` | Verificar comportamiento con string vacío | EJECUTADA |
| 6 | POST omitiendo `nombre_original` | Verificar mensaje específico de campo ausente | EJECUTADA |
| 7 | Validación encoding UTF-8 | Confirmar origen del issue de encoding | EJECUTADA |

**Orden de ejecución:** 1 → 2 → 3 → 4 → 5 → 6 → 7  
(De mayor impacto contractual a validaciones de detalle)

---

## 6. Clasificación de resultados (pre-parche)

| # | Prueba | Código | Resultado | Clasificación |
|---|--------|--------|-----------|---------------|
| 1 | GET caseId inexistente | 404 | `"Caso ... no encontrado"` | ✅ Ya protegido |
| 2 | categoria inválida | 400 | Enum validado, mensaje con valores permitidos | ✅ Ya protegido |
| 3 | tamanio_bytes = 0 | 201 | **Acepta 0 como válido** | 🔧 Requiere ajuste |
| 4 | tamanio_bytes < 0 | 400 | `"debe ser positivo"` | ✅ Ya protegido |
| 5 | nombre_original = "" | 201 | **Acepta string vacío** | 🔧 Requiere ajuste |
| 6 | nombre_original omitido | 400 | Mensaje confuso: `"no puede exceder 255"` + `"debe ser texto"` | ⚠️ Inconsistente |
| 7 | encoding UTF-8 | — | Backend OK; documentos Sprint 11 correctos, issue en terminal Git Bash | ✅ Backend OK |

---

## 7. Brechas identificadas

| # | Brecha | Comportamiento actual | Ajuste requerido |
|---|--------|----------------------|------------------|
| 1 | `tamanio_bytes` acepta 0 | `@Min(0)` permite 0 | Cambiar a `@Min(1)` |
| 2 | Strings vacíos aceptados | No hay validación de contenido | Agregar `@IsNotEmpty()` |
| 3 | Mensaje de campo ausente | Mensajes laterales confusos | Agregar mensaje explícito de requerido |

---

## 8. Intervención aplicada

**Archivo modificado:** `src/modules/documents/dto/create-document.dto.ts`

**Cambios aplicados:**

| Campo | Cambio |
|-------|--------|
| `tamanio_bytes` | `@Min(0)` → `@Min(1)` + mensaje `"debe ser mayor a cero"` |
| `nombre_original` | + `@IsNotEmpty({ message: 'nombre_original es requerido' })` |
| `nombre_almacenado` | + `@IsNotEmpty({ message: 'nombre_almacenado es requerido' })` |
| `ruta` | + `@IsNotEmpty({ message: 'ruta es requerido' })` |
| `mime_type` | + `@IsNotEmpty({ message: 'mime_type es requerido' })` |

---

## 9. Verificación post-parche

### 9.1 Primer intento — Parche con `@ValidateIf` + `@IsDefined`

Se intentó limpiar el mensaje de campo ausente usando:
```typescript
@IsDefined({ message: 'nombre_original es requerido' })
@ValidateIf((o, v) => v !== undefined)
```

**Resultado:** Regresión crítica. El campo omitido produjo `500 Internal Server Error` porque `@ValidateIf` neutralizó las validaciones y dejó pasar `undefined` hasta capas downstream.

**Decisión:** Revertir a versión sin `@ValidateIf`.

### 9.2 Versión final — Solo `@IsNotEmpty`

DTO final usa únicamente:
```typescript
@IsNotEmpty({ message: 'nombre_original es requerido' })
@IsString({ message: 'nombre_original debe ser texto' })
@MaxLength(255, { message: 'nombre_original no puede exceder 255 caracteres' })
```

### 9.3 Mini-regresión final

| # | Prueba | Código | Mensaje | Estado |
|---|--------|--------|---------|--------|
| 1 | Positivo principal | 201 | Documento creado | ✅ |
| 2 | tamanio_bytes = 0 | 400 | `"debe ser mayor a cero"` | ✅ |
| 3 | nombre_original = "" | 400 | `"es requerido"` | ✅ |
| 4 | nombre_original omitido | 400 | Incluye `"es requerido"` (con ruido) | ✅ |

**Fecha de ejecución:** 2026-03-26 16:51

---

## 10. Limitación residual

**Comportamiento actual para campo ausente:**

Cuando `nombre_original` está ausente, el DTO devuelve:
```json
{
  "mensaje": [
    "nombre_original no puede exceder 255 caracteres",
    "nombre_original debe ser texto",
    "nombre_original es requerido"
  ]
}
```

**Causa técnica:** class-validator ejecuta todos los decoradores en paralelo cuando el valor es `undefined`. El mensaje clave ("es requerido") aparece, pero acompañado de mensajes laterales.

**Solución posible:** Configurar `stopAtFirstError: true` en ValidationPipe global (`main.ts`).

**Decisión Sprint 12:** No se implementa. Requiere ajuste transversal fuera de alcance del sprint. Se documenta como deuda técnica menor.

---

## 11. Resultado consolidado del Sprint 12

| Brecha original | Estado final |
|-----------------|--------------|
| `tamanio_bytes` acepta 0 | ✅ CERRADA |
| Strings vacíos aceptados | ✅ CERRADA |
| Campo ausente produce 500 | ✅ CERRADA (regresión intermedia corregida) |
| Mensaje ruidoso en campo ausente | ⚠️ DEUDA TÉCNICA — fuera de alcance Sprint 12 |

**Archivo modificado:** `src/modules/documents/dto/create-document.dto.ts`

**Cambios aplicados:**
- `@Min(0)` → `@Min(1)` en `tamanio_bytes`
- Agregado `@IsNotEmpty()` a todos los campos de texto requeridos
- Mensajes explícitos en español

**Restricciones respetadas:**
- No se tocó `main.ts` ni ValidationPipe global
- No se tocó controller, service ni repository
- No se abrió expansión funcional

---

## 12. Criterio de cierre cumplido

- [x] Positiva principal verde
- [x] Negativas 400 verdes
- [x] Sin regresión 500
- [x] Build verde
- [x] Contrato alineado con runtime
- [x] Cambio acotado al DTO

**Sprint 12 en estado cerrable.**

---

*Documento actualizado: 2026-03-26 16:55*  
*Sprint 12 — Hardening de `documents`*
