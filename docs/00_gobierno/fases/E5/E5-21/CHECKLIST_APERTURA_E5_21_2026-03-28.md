# CHECKLIST APERTURA E5-21 — TIMELINE: ALINEACIÓN CONTRACTUAL Y VALIDACIÓN RUNTIME DE COLECCIÓN APPEND-ONLY PAGINADA

**Fecha:** 2026-03-28
**Unidad:** E5-21
**Tipo:** Alineación contractual + Validación runtime

---

## 1. OBJETIVO

Validar y documentar el subrecurso `timeline` como colección anidada append-only, paginada, sin detalle individual ni edición/eliminación, con orden automático por caso.

---

## 2. NATURALEZA DEL HITO

**Fase A:** Validación runtime (13 pruebas)
**Fase B:** Alineación contractual (si runtime OK)

---

## 3. TESIS OPERATIVA

`timeline` es una colección anidada append-only, paginada, sin detalle individual ni edición/eliminación, con orden automático por caso.

---

## 4. ENDPOINTS A VALIDAR

| Endpoint | Método | Comportamiento |
|----------|--------|----------------|
| `/cases/:caseId/timeline` | GET | Lista paginada de entradas |
| `/cases/:caseId/timeline` | POST | Crea entrada con orden automático |

**Endpoints NO expuestos:**
- GET detalle individual
- PUT
- DELETE

---

## 5. PATRÓN APPEND-ONLY PURO

| Característica | Valor |
|----------------|-------|
| Tipo | Colección append-only paginada |
| Cardinalidad | N entradas por caso |
| Creación | POST con orden automático |
| Edición | No expuesta |
| Eliminación | No expuesta |
| Detalle individual | No expuesto |
| Orden | Asignado automáticamente, no editable |

---

## 5.1 PAGINACIÓN

La respuesta de GET incluye metadatos de paginación:

```json
{
  "data": [...],
  "total": 25,
  "page": 1,
  "per_page": 20
}
```

**Query params:**

| Param | Default | Descripción |
|-------|---------|-------------|
| `page` | 1 | Página actual |
| `per_page` | 20 | Items por página |

---

## 6. DTO

### CreateTimelineEntryDto (2 campos)

| Campo | Tipo | MaxLength | Obligatorio |
|-------|------|-----------|-------------|
| `fecha_evento` | ISO date string | - | Sí |
| `descripcion` | string | 1000 | Sí |

**Campo `orden`:** Asignado automáticamente por el backend, no editable por cliente.

---

## 7. REGLAS DE ACCESO

### Comportamiento observado en código

| Endpoint | Estudiante responsable | Estudiante ajeno | Supervisor | Admin |
|----------|------------------------|------------------|------------|-------|
| GET | 200 | 403 | 200* | 200 |
| POST | 201 | 403 | 201* | 201 |

*Supervisor: comportamiento esperado según código, no validado en runtime de esta unidad.

---

## 8. CRITERIOS DE ACEPTACIÓN (13 pruebas)

| # | Criterio | Código esperado |
|---|----------|-----------------|
| 01 | Login admin | 200 |
| 02 | POST /clients | 201 |
| 03 | POST /cases | 201 |
| 04 | Activar caso | 200/201 |
| 05 | GET /timeline (lista vacía paginada) | 200 |
| 06 | POST /timeline (primera entrada) | 201 |
| 07 | GET /timeline (lista con 1) | 200 |
| 08 | POST /timeline (segunda entrada, orden automático) | 201 |
| 09 | GET /timeline con paginación explícita | 200 |
| 10 | POST /timeline (fecha inválida) | 400 |
| 11 | GET /timeline (caso inexistente) | 404 |
| 12 | GET /timeline sin token | 401 |
| 13 | GET /timeline (estudiante ajeno) | 403 |

---

## 9. FUERA DE ALCANCE

- Endpoint GET detalle individual
- Endpoint PUT
- Endpoint DELETE
- Cambio de política de orden automático
- Migraciones de datos

---

## 10. DIFF CONTRACTUAL

### Ubicación
`docs/04_api/CONTRATO_API.md`, sección **5.9** (~líneas 627+)

### Bloque actual (escueto)
```
GET  /api/v1/cases/{caseId}/timeline
POST /api/v1/cases/{caseId}/timeline
```

### Bloque nuevo (completo)
Ver archivo `DIFF_TIMELINE_CONTRATO.md`

---

## 11. SECUENCIA DE EJECUCIÓN

```bash
# Fase A: Validación runtime
chmod +x test_e5_21.sh
./test_e5_21.sh
npm run build

# Fase B: Aplicar diff contractual (si runtime OK)
```

---

## 12. CRITERIO DE CIERRE

| Resultado | Acción |
|-----------|--------|
| Runtime conforme + contrato actualizado + build verde | E5-21 cierra |
