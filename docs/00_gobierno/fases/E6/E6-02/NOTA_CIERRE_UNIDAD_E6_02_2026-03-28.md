# NOTA DE CIERRE UNIDAD E6-02 — EVENTOS CASE-SCOPED CRÍTICOS

**Fecha:** 2026-03-28  
**Unidad:** E6-02  
**Módulo:** audit (extensión de escritura)  
**Resultado:** ✅ CERRADA

---

## 1. OBJETIVO CUMPLIDO

Instrumentar eventos `revision_supervisor` e `informe_generado` para ampliar la superficie real de auditoría del MVP, de forma que `GET /api/v1/cases/{caseId}/audit` refleje operaciones críticas adicionales, no solo transiciones de estado.

---

## 2. EVIDENCIA RUNTIME

**Script ejecutado:** `test_e6_02.v3.sh`

| # | Criterio | Resultado |
|---|----------|-----------|
| 01 | Login admin | ✅ 200 |
| 02 | Login supervisor | ✅ 200 |
| 03 | Login estudiante | ✅ 200 |
| 04 | Crear cliente y caso | ✅ 201 |
| 05 | Activar caso | ✅ 201 |
| 06 | Generar informe | ✅ 201 |
| 07 | Avanzar a pendiente_revision | ✅ 201 |
| 08 | Crear revisión supervisor | ✅ 201 |
| 09 | GET /audit admin | ✅ 200 |
| 10 | GET /audit supervisor | ✅ 200 |
| 11 | GET /audit estudiante | ✅ 403 |
| 12 | Filtro informe_generado | ✅ 200 + tipo correcto |
| 13 | Filtro revision_supervisor | ✅ 200 + tipo correcto |
| 14 | No duplicidad informe_generado | ✅ exactamente 1 |
| 15 | No duplicidad revision_supervisor | ✅ exactamente 1 |

**Caso de prueba:** E602-1774760271  
**ID:** 1cb6dcb3-756f-4c31-a001-1468abb42796

---

## 3. SUPERFICIE INSTRUMENTADA

| Evento | Módulo | Write point | Transacción |
|--------|--------|-------------|-------------|
| `informe_generado` | reports | `ReportsRepository.createWithAudit()` | ✅ Atómica |
| `revision_supervisor` | review | `ReviewRepository.createWithAudit()` | ✅ Atómica |

---

## 4. DECISIONES DE DISEÑO

| Aspecto | Decisión |
|---------|----------|
| Enums | `TipoEvento.INFORME_GENERADO`, `TipoEvento.REVISION_SUPERVISOR` (UPPER_CASE) |
| Resultado auditoría | Siempre `EXITOSO` — refleja éxito técnico, no resultado de negocio |
| Atomicidad | Operación completa en `$transaction()` |
| Race condition review | Cálculo de `version_revision` dentro de transacción |
| Idempotencia reports | Retorno idempotente NO genera evento de auditoría |

---

## 5. ARCHIVOS MODIFICADOS

| Archivo | Cambio |
|---------|--------|
| `src/modules/review/review.repository.ts` | +`createWithAudit()` con transacción completa |
| `src/modules/review/review.service.ts` | Usa `createWithAudit()`, sin `getNextVersion()` externo |
| `src/modules/reports/reports.repository.ts` | +`createWithAudit()` con transacción |
| `src/modules/reports/reports.service.ts` | Usa `createWithAudit()` solo en creación real |

**Script de prueba:** `test_e6_02.v3.sh`

---

## 6. LIMITACIONES Y DEUDA TÉCNICA

### 6.1 Validación de no duplicidad

La validación de no duplicidad en pruebas 14-15 es **runtime funcional secuencial**. No constituye hardening concurrente exhaustivo.

### 6.2 Concurrencia estricta

Aunque el cálculo de `version_revision` ahora ocurre dentro de la transacción, bajo carga concurrente extrema y dependiendo del nivel de aislamiento de PostgreSQL, todavía podría existir una ventana de carrera si dos transacciones leen la misma última versión antes de escribir.

**Mitigación posible (fuera de MVP):**
- Restricción única en `(caso_id, version_revision)`
- Retry con backoff en caso de conflicto
- `SELECT ... FOR UPDATE` en lectura de última versión

### 6.3 Estado pendiente

| Item | Prioridad | Tipo |
|------|-----------|------|
| Hardening concurrencia review | Baja | Mejora |
| Restricción única version_revision | Media | Integridad |

---

## 7. CRITERIOS DE ACEPTACIÓN

| Criterio | Estado |
|----------|--------|
| `revision_supervisor` se registra al crear revisión | ✅ |
| `informe_generado` se registra al generar informe | ✅ |
| Eventos visibles en `GET /audit` | ✅ |
| Control de acceso heredado de E6-01 | ✅ |
| Filtro por tipo funciona | ✅ |
| No duplicidad observable | ✅ |
| Build verde | ✅ |

---

## 8. ESTADO FASE E6

| Unidad | Módulo | Estado |
|--------|--------|--------|
| E6-01 | audit (lectura) | ✅ |
| E6-02 | audit (escritura) | ✅ |

---

## 9. COMMIT

```
feat(audit): E6-02 instrumentar eventos case-scoped

- informe_generado en reports.createWithAudit()
- revision_supervisor en review.createWithAudit()
- Transacciones atómicas en ambos módulos
- 15 pruebas runtime validadas (test_e6_02.v3.sh)
```
