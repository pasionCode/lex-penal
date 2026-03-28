# CHECKLIST APERTURA E5-20 — FACTS: ALINEACIÓN CONTRACTUAL Y VALIDACIÓN RUNTIME DE COLECCIÓN EDITABLE

**Fecha:** 2026-03-28
**Unidad:** E5-20
**Tipo:** Alineación contractual + Validación runtime

---

## 1. OBJETIVO

Confirmar y documentar la superficie funcional real de `facts`, completar el contrato API conforme a la implementación vigente y validar en runtime creación, consulta, edición, control de acceso, orden automático y respuestas esperadas.

---

## 2. NATURALEZA DEL HITO

**Fase A:** Alineación contractual (semántica, DTOs, enums, orden automático, tabla de códigos)
**Fase B:** Validación runtime (17 pruebas)

---

## 3. TESIS OPERATIVA

El recurso `facts` está funcionalmente implementado como colección editable con update parcial; la unidad E5-20 se orienta a evidenciar en runtime esa semántica y a dejarla formalmente alineada en el contrato API.

---

## 4. ENDPOINTS A VALIDAR

| Endpoint | Método | Comportamiento |
|----------|--------|----------------|
| `/cases/:caseId/facts` | POST | Crea hecho con orden automático |
| `/cases/:caseId/facts` | GET | Lista hechos del caso |
| `/cases/:caseId/facts/:factId` | GET | Detalle de hecho |
| `/cases/:caseId/facts/:factId` | PUT | Update parcial (semántica tipo PATCH) |

---

## 5. PATRÓN COLECCIÓN EDITABLE

| Característica | Valor |
|----------------|-------|
| Tipo | Colección editable con update parcial |
| Cardinalidad | N hechos por caso |
| Creación | POST con orden automático |
| Edición | PUT con semántica tipo PATCH (solo campos presentes) |
| Eliminación | No expuesta |
| Orden | Asignado automáticamente, no editable por cliente |

---

## 5.1 SEMÁNTICA DE PUT

`UpdateFactDto` tiene todos los campos opcionales. El service solo persiste los campos presentes en el payload:

```typescript
if (dto.descripcion !== undefined) updateData.descripcion = dto.descripcion;
if (dto.estado_hecho !== undefined) updateData.estado_hecho = dto.estado_hecho;
// ...
```

**Resultado:** Comportamiento de update parcial (tipo PATCH), no reemplazo completo.

**Campo `orden`:** No editable por cliente, asignado automáticamente en creación.

---

## 5.2 DEPENDENCIA FUNCIONAL CON TRANSICIÓN

**Regla de negocio:** Al menos 1 hecho registrado es requisito para la transición `en_analisis → pendiente_revision`.

Esta validación se ejecuta en `caso-estado.service`, no en el módulo `facts`.

---

## 6. DTOs

### CreateFactDto (4 campos)

| Campo | Tipo | MaxLength | Obligatorio |
|-------|------|-----------|-------------|
| `descripcion` | string | 2000 | Sí |
| `estado_hecho` | enum | - | Sí |
| `fuente` | string | 500 | No |
| `incidencia_juridica` | enum | - | No |

### UpdateFactDto (4 campos, todos opcionales)

| Campo | Tipo | MaxLength | Obligatorio |
|-------|------|-----------|-------------|
| `descripcion` | string | 2000 | No |
| `estado_hecho` | enum | - | No |
| `fuente` | string | 500 | No |
| `incidencia_juridica` | enum | - | No |

### Enums

| Enum | Valores |
|------|---------|
| `EstadoHecho` | `acreditado`, `referido`, `discutido` |
| `IncidenciaJuridica` | `tipicidad`, `antijuridicidad`, `culpabilidad`, `procedimiento` |

---

## 7. REGLAS DE ACCESO

### Comportamiento observado en código

`checkCaseAccess()` implementa:
- Caso inexistente → 404
- Estudiante ajeno → 403
- Supervisor/Admin → acceso permitido (no hay restricción adicional)

| Endpoint | Estudiante responsable | Estudiante ajeno | Supervisor | Admin |
|----------|------------------------|------------------|------------|-------|
| POST | 201 | 403 | 201 | 201 |
| GET lista | 200 | 403 | 200 | 200 |
| GET detalle | 200 | 403 | 200 | 200 |
| PUT | 200 | 403 | 200 | 200 |

**Nota:** A verificar en runtime que supervisor/admin efectivamente acceden sin restricción.

---

## 8. CRITERIOS DE ACEPTACIÓN (17 pruebas)

| # | Criterio | Código esperado |
|---|----------|-----------------|
| 01 | Login admin | 200 |
| 02 | POST /clients | 201 |
| 03 | POST /cases | 201 |
| 04 | Activar caso | 200/201 |
| 05 | GET /facts (lista vacía) | 200 |
| 06 | POST /facts | 201 |
| 07 | GET /facts (lista con 1) | 200 |
| 08 | GET /facts/:id (detalle) | 200 |
| 09 | PUT /facts/:id (update parcial) | 200 |
| 10 | GET /facts/:id (refleja cambios) | 200 |
| 11 | POST /facts segundo (verificar orden automático) | 201 |
| 12 | GET /facts/:id (hecho inexistente) | 404 |
| 13 | PUT /facts/:id (hecho inexistente) | 404 |
| 14 | GET /facts/:id (hecho de otro caso) | 404 |
| 15 | POST /facts (estado_hecho inválido) | 400 |
| 16 | GET /facts sin token | 401 |
| 17 | GET /facts (estudiante ajeno) | 403 |

---

## 9. FUERA DE ALCANCE

- Endpoint DELETE
- Cambio de política de orden automático
- Rediseño de transición de estados
- Migraciones de datos

---

## 10. DIFF CONTRACTUAL

### Ubicación
`docs/04_api/CONTRATO_API.md`, sección **5.2** (~líneas 448+)

### Bloque actual (escueto)
```
POST   /api/v1/cases/{caseId}/facts
GET    /api/v1/cases/{caseId}/facts
GET    /api/v1/cases/{caseId}/facts/{factId}
PUT    /api/v1/cases/{caseId}/facts/{factId}
```

### Bloque nuevo (completo)
Ver archivo `DIFF_FACTS_CONTRATO.md`

---

## 11. SECUENCIA DE EJECUCIÓN

```bash
# Fase A: Validación runtime
chmod +x test_e5_20.sh
./test_e5_20.sh
npm run build

# Fase B: Aplicar diff contractual (si runtime OK)
```

---

## 12. CRITERIO DE CIERRE

| Resultado | Acción |
|-----------|--------|
| Contrato alineado + 17 PASS + build verde | E5-20 cierra |
