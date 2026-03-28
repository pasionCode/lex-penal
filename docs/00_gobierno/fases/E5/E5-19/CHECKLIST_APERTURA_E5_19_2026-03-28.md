# CHECKLIST APERTURA E5-19 — DOCUMENTS: ALINEACION CONTRACTUAL Y VALIDACION RUNTIME DE COLECCION CON EDICION LIMITADA

**Fecha:** 2026-03-28
**Unidad:** E5-19
**Tipo:** Alineacion contractual + Validacion runtime

---

## 1. OBJETIVO

Evidenciar en runtime la semantica de coleccion con edicion limitada del recurso `documents` y alinear formalmente el contrato API.

---

## 2. NATURALEZA DEL HITO

**Fase A:** Alineacion contractual (semantica, DTOs, enum, politica edicion, tabla de codigos)
**Fase B:** Validacion runtime (17 pruebas)

---

## 3. TESIS OPERATIVA

El recurso `documents` esta funcionalmente implementado como coleccion con edicion limitada; la unidad E5-19 se orienta a evidenciar en runtime esa semantica y a dejarla formalmente alineada en el contrato API.

---

## 4. ENDPOINTS A VALIDAR

| Endpoint | Metodo | Comportamiento |
|----------|--------|----------------|
| `/cases/:caseId/documents` | GET | Lista documentos del caso |
| `/cases/:caseId/documents` | POST | Registra metadatos de documento |
| `/cases/:caseId/documents/:documentId` | GET | Detalle de documento |
| `/cases/:caseId/documents/:documentId` | PUT | Actualiza solo `descripcion` |

---

## 5. PATRON COLECCION CON EDICION LIMITADA

| Caracteristica | Valor |
|----------------|-------|
| Tipo | Coleccion con edicion limitada |
| Cardinalidad | N documentos por caso |
| Creacion | POST registra metadatos |
| Edicion | PUT solo `descripcion` (politica Sprint 11) |
| Eliminacion | No expuesta |
| Inmutabilidad | Todos los campos excepto `descripcion` |

---

## 5.1 POLITICA SPRINT 11

**Solo el campo `descripcion` es editable via PUT.**

Los demas campos permanecen inmutables:
- `categoria`
- `nombre_original`
- `nombre_almacenado`
- `ruta`
- `mime_type`
- `tamanio_bytes`

Esta politica esta implementada en `UpdateDocumentDto` que solo expone `descripcion`.

---

## 5.2 SERIALIZACION DE `tamanio_bytes`

| Persistencia | Respuesta JSON |
|--------------|----------------|
| BigInt | Number |

El servicio serializa `tamanio_bytes` de BigInt a Number para compatibilidad JSON.

---

## 6. DTOs

### CreateDocumentDto (7 campos)

| Campo | Tipo | MaxLength | Obligatorio |
|-------|------|-----------|-------------|
| `categoria` | enum | - | Si |
| `nombre_original` | string | 255 | Si |
| `nombre_almacenado` | string | 255 | Si |
| `ruta` | string | 500 | Si |
| `mime_type` | string | 100 | Si |
| `tamanio_bytes` | int | - | Si (min 1) |
| `descripcion` | string | 1000 | No |

### Enum `categoria`

`acusacion`, `defensa`, `cliente`, `actuacion`, `informe`, `evidencia`, `anexo`, `otro`

### UpdateDocumentDto (1 campo)

| Campo | Tipo | MaxLength | Obligatorio |
|-------|------|-----------|-------------|
| `descripcion` | string | 1000 | No |

---

## 7. REGLAS DE ACCESO

| Endpoint | Estudiante responsable | Estudiante ajeno | Supervisor | Admin |
|----------|------------------------|------------------|------------|-------|
| GET lista | 200 | 403 | 200 | 200 |
| POST | 201 | 403 | 201 | 201 |
| GET detalle | 200 | 403 | 200 | 200 |
| PUT | 200 | 403 | 200 | 200 |

---

## 8. CRITERIOS DE ACEPTACION (17 pruebas)

| # | Criterio | Codigo esperado |
|---|----------|-----------------|
| 01 | Login admin | 200 |
| 02 | POST /clients | 201 |
| 03 | POST /cases | 201 |
| 04 | Activar caso | 200/201 |
| 05 | GET /documents (lista vacia) | 200 |
| 06 | POST /documents | 201 |
| 07 | GET /documents (lista con 1) | 200 |
| 08 | GET /documents/:id (detalle) | 200 |
| 09 | PUT /documents/:id (actualiza descripcion) | 200 |
| 10 | GET /documents/:id (cambios + tamanio_bytes numerico) | 200 |
| 11 | GET /documents/:id (documento inexistente) | 404 |
| 12 | PUT /documents/:id (documento inexistente) | 404 |
| 13 | POST /documents (tamanio_bytes=0) | 400 |
| 14 | GET /documents sin token | 401 |
| 15 | GET /documents (estudiante ajeno) | 403 |
| 16 | GET /documents/:id (estudiante ajeno) | 403 |
| 17 | PUT /documents/:id (estudiante ajeno) | 403 |

---

## 9. FUERA DE ALCANCE

- Carga real de archivos/binarios
- Endpoint DELETE
- Refactor de almacenamiento
- Cambio de politica de mutabilidad
- Migraciones de datos

---

## 10. DIFF CONTRACTUAL

### Ubicacion
`docs/04_api/CONTRATO_API.md`, seccion **5.11** (~lineas 547+)

### Bloque actual (escueto)
```
GET    /api/v1/cases/{caseId}/documents
POST   /api/v1/cases/{caseId}/documents
GET    /api/v1/cases/{caseId}/documents/{documentId}
PUT    /api/v1/cases/{caseId}/documents/{documentId}
```

### Bloque nuevo (completo)
Ver archivo `DIFF_DOCUMENTS_CONTRATO.md`

---

## 11. SECUENCIA DE EJECUCION

```bash
# Fase A: Validacion runtime
chmod +x test_e5_19.sh
./test_e5_19.sh
npm run build

# Fase B: Aplicar diff contractual (si runtime OK)
```

---

## 12. CRITERIO DE CIERRE

| Resultado | Accion |
|-----------|--------|
| Contrato alineado + 17 PASS + build verde | E5-19 cierra |
