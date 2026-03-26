# BASELINE `proceedings` — Sprint 13

**Fecha:** 2026-03-26  
**Proyecto:** LEX_PENAL  
**Fase:** E5 — Expansión funcional controlada  
**Sprint:** 13  
**Foco:** `proceedings`  
**Política:** A — Append-only

---

## 1. Identificación del endpoint

| Campo | Valor |
|-------|-------|
| Ruta base | `/api/v1/cases/:caseId/proceedings` |
| caseId de pruebas | `c9f0c313-1042-42f7-8371-faa89fd84f42` |
| Usuario autenticado | `admin@lexpenal.local` (perfil: administrador) |

---

## 2. Política confirmada

**Opción seleccionada:** A — Append-only

| Método | Estado |
|--------|--------|
| GET lista | ✅ Permitido |
| POST | ✅ Permitido |
| GET detalle | ✅ Permitido |
| PUT | ❌ No permitido |
| DELETE | ❌ No permitido |

---

## 3. Baseline pre-ajuste

### 3.1 Estado inicial del módulo

El módulo `proceedings` existía con CRUD completo implementado:
- Controller con GET, POST, PUT, DELETE
- Service con métodos para todas las operaciones
- Contrato API anunciando los 5 endpoints

### 3.2 Hallazgo crítico

| Método | Código pre-ajuste | Interpretación |
|--------|-------------------|----------------|
| PUT | 404 "Actuación no encontrada" | Endpoint expuesto, lógica activa |
| DELETE | 404 "Actuación no encontrada" | Endpoint expuesto, lógica activa |

**Diagnóstico:** Runtime sobredimensionado respecto a política append-only.

---

## 4. Intervención aplicada

**Archivo modificado:** `src/modules/proceedings/proceedings.controller.ts`

**Cambios:**
- Removido decorador `@Put(':proceedingId')` y método `update()`
- Removido decorador `@Delete(':proceedingId')` y método `remove()`
- Removidos imports de `Put`, `Delete`, `UpdateProceedingDto`
- Actualizado comentario de documentación

**Naturaleza del cambio:** Solo exposición HTTP. La lógica interna en service y repository permanece intacta pero ya no es accesible vía API.

**Capas no tocadas:** Service, Repository

---

## 5. Baseline post-ajuste

### 5.1 GET lista — 200

**Request:**
```bash
GET /api/v1/cases/c9f0c313-1042-42f7-8371-faa89fd84f42/proceedings
```

**Response:** `200 OK`
```json
[
  {
    "id": "bcba0f7e-9116-41d3-9956-2b417a33dbde",
    "caso_id": "c9f0c313-1042-42f7-8371-faa89fd84f42",
    "descripcion": "Audiencia de imputacion",
    "fecha": "2026-04-15T00:00:00.000Z",
    "responsable_id": null,
    "responsable_externo": null,
    "completada": false,
    "creado_en": "2026-03-26T22:22:22.374Z",
    "actualizado_en": "2026-03-26T22:22:22.374Z",
    "creado_por": "71e47a55-8803-4842-bf3c-c573bf2cc709",
    "actualizado_por": null
  }
]
```

### 5.2 GET caseId inexistente — 404

**Request:**
```bash
GET /api/v1/cases/00000000-0000-0000-0000-000000000000/proceedings
```

**Response:** `404 Not Found`
```json
{
  "statusCode": 404,
  "error": "Not Found",
  "mensaje": "Caso 00000000-0000-0000-0000-000000000000 no encontrado"
}
```

### 5.3 POST válido — 201

**Request:**
```bash
POST /api/v1/cases/c9f0c313-1042-42f7-8371-faa89fd84f42/proceedings
Content-Type: application/json

{
  "descripcion": "Audiencia preparatoria - post ajuste S13",
  "fecha": "2026-05-10",
  "completada": false
}
```

**Response:** `201 Created`
```json
{
  "id": "fdc812ed-a2c2-4c0a-9b41-76b0330142d8",
  "caso_id": "c9f0c313-1042-42f7-8371-faa89fd84f42",
  "descripcion": "Audiencia preparatoria - post ajuste S13",
  "fecha": "2026-05-10T00:00:00.000Z",
  "responsable_id": null,
  "responsable_externo": null,
  "completada": false,
  "creado_en": "2026-03-26T22:27:35.906Z",
  "actualizado_en": "2026-03-26T22:27:35.906Z",
  "creado_por": "71e47a55-8803-4842-bf3c-c573bf2cc709",
  "actualizado_por": null
}
```

### 5.4 GET detalle — 200

**Nota:** Se verificó sobre el registro creado en el baseline inicial (`bcba0f7e...`), previo al POST post-ajuste.

**Request:**
```bash
GET /api/v1/cases/c9f0c313-1042-42f7-8371-faa89fd84f42/proceedings/bcba0f7e-9116-41d3-9956-2b417a33dbde
```

**Response:** `200 OK`
```json
{
  "id": "bcba0f7e-9116-41d3-9956-2b417a33dbde",
  "caso_id": "c9f0c313-1042-42f7-8371-faa89fd84f42",
  "descripcion": "Audiencia de imputacion",
  "fecha": "2026-04-15T00:00:00.000Z",
  "responsable_id": null,
  "responsable_externo": null,
  "completada": false,
  "creado_en": "2026-03-26T22:22:22.374Z",
  "actualizado_en": "2026-03-26T22:22:22.374Z",
  "creado_por": "71e47a55-8803-4842-bf3c-c573bf2cc709",
  "actualizado_por": null
}
```

### 5.5 PUT — 404 Cannot PUT

**Request:**
```bash
PUT /api/v1/cases/c9f0c313-1042-42f7-8371-faa89fd84f42/proceedings/bcba0f7e-9116-41d3-9956-2b417a33dbde
```

**Response:** `404 Not Found`
```json
{
  "statusCode": 404,
  "error": "Not Found",
  "mensaje": "Cannot PUT /api/v1/cases/.../proceedings/..."
}
```

**Verificación:** ✅ Endpoint removido, ruta no expuesta.

### 5.6 DELETE — 404 Cannot DELETE

**Request:**
```bash
DELETE /api/v1/cases/c9f0c313-1042-42f7-8371-faa89fd84f42/proceedings/bcba0f7e-9116-41d3-9956-2b417a33dbde
```

**Response:** `404 Not Found`
```json
{
  "statusCode": 404,
  "error": "Not Found",
  "mensaje": "Cannot DELETE /api/v1/cases/.../proceedings/..."
}
```

**Verificación:** ✅ Endpoint removido, ruta no expuesta.

---

## 6. Resumen de verificación post-ajuste

| # | Prueba | Código | Estado |
|---|--------|--------|--------|
| 1 | GET lista | 200 | ✅ |
| 2 | GET caseId inexistente | 404 | ✅ |
| 3 | POST válido | 201 | ✅ |
| 4 | GET detalle | 200 | ✅ |
| 5 | PUT | 404 Cannot PUT | ✅ Removido |
| 6 | DELETE | 404 Cannot DELETE | ✅ Removido |

**Ejecución:** 2026-03-26 ~17:27 (hora local Colombia, COT)

---

## 7. Ajuste contractual realizado

El runtime quedó alineado con la política A — Append-only; el contrato fue actualizado en la misma jornada.

**Archivo:** `docs/04_api/CONTRATO_API.md`

**Cambios aplicados:**
- Endpoints reducidos a GET, POST, GET detalle
- Agregada nota: `Entidad con **política append-only**. No se permite edición ni eliminación.`
- Agregada nota de implementación Sprint 13

---

## 8. Criterio de cierre

- [x] Política append-only implementada
- [x] GET lista operativo
- [x] POST operativo
- [x] GET detalle operativo
- [x] PUT removido del controller
- [x] DELETE removido del controller
- [x] Build verde
- [x] Mini-regresión verde
- [x] Contrato actualizado
- [x] Nota de cierre emitida

---

*Documento generado: 2026-03-26 ~17:30 (hora local Colombia, COT)*  
*Sprint 13 — Política append-only para `proceedings`*
