# BASELINE REVIEW — UNIDAD E5-03

## 1. Identificación

| Campo | Valor |
|-------|-------|
| Proyecto | LEX_PENAL |
| Fase | E5 |
| Unidad | E5-03 |
| Fecha | 2026-03-27 |
| Alcance | Módulo `review` + flujo de revisión |

---

## 2. Estado real del módulo review

### 2.1 Archivos

| Archivo | Líneas | Estado |
|---------|--------|--------|
| `review.controller.ts` | ~45 | ✅ Implementado |
| `review.service.ts` | ~90 | ✅ Implementado |
| `review.repository.ts` | ~55 | ✅ Implementado |
| `dto/create-review.dto.ts` | ~20 | ✅ Implementado |
| `review.module.ts` | ~10 | ✅ Wired |

### 2.2 Rutas expuestas

| Método | Ruta | Permisos | Descripción |
|--------|------|----------|-------------|
| `GET` | `/cases/:caseId/review` | Supervisor, Admin | Historial completo de revisiones |
| `POST` | `/cases/:caseId/review` | Supervisor, Admin | Crear revisión manualmente |
| `GET` | `/cases/:caseId/review/feedback` | Estudiante responsable, Supervisor, Admin | Feedback de revisión vigente |

### 2.3 Dependencias con cases y máquina de estados

**Dependencia directa:**
- `review.repository` consulta `prisma.caso` para verificar existencia, estado y responsable
- `review.service.create()` verifica `estado === pendiente_revision` antes de permitir crear revisión

**Dependencia indirecta:**
- `caso-estado.service.transicionar()` en `/cases/services/` TAMBIÉN crea revisiones automáticamente en transiciones `pendiente_revision → devuelto/aprobado_supervisor`

### 2.4 DTO de creación

```typescript
// create-review.dto.ts
{
  resultado: ResultadoRevision;       // 'aprobado' | 'devuelto' (obligatorio)
  observaciones: string;               // max 3000, obligatorio
  fecha_revision?: string;             // ISO date, opcional
}
```

---

## 3. Flujo de revisión real

### 3.1 Máquina de estados relevante

```
borrador → en_analisis → pendiente_revision → aprobado_supervisor → listo_para_cliente → cerrado
                               ↓
                           devuelto → en_analisis (ciclo)
```

### 3.2 Actores y transiciones

| Transición | Actor permitido | Guardas |
|------------|-----------------|---------|
| `en_analisis → pendiente_revision` | Estudiante, Supervisor, Admin | Checklist críticos OK, estrategia con línea, ≥1 hecho |
| `pendiente_revision → aprobado_supervisor` | Supervisor, Admin | Observaciones obligatorias |
| `pendiente_revision → devuelto` | Supervisor, Admin | Observaciones obligatorias |
| `devuelto → en_analisis` | Estudiante, Supervisor, Admin | ≥1 revisión existente |

### 3.3 Flujo de transición (estado real post-runtime)

**Endpoint:** `POST /api/v1/cases/:id/transition`

**Body:**
```json
{
  "estado_destino": "pendiente_revision",
  "observaciones": "..."
}
```

**Servicio conectado:** `cases.service.transition()` ⚠️

**Servicio esperado (no conectado):** `caso-estado.service.transicionar()`

> **D-02 MATERIALIZADA:** El controller está conectado a `cases.service.transition()`, que actualiza estado pero NO ejecuta guardas ni persiste revisiones. El servicio `caso-estado.service.transicionar()` contiene la lógica correcta pero no está cableado al endpoint.

### 3.4 Creación automática de revisión (NO OPERATIVA)

En `caso-estado.service.ts` existe el método `persistirRevisionSupervisor()`:

```typescript
// LÓGICA EXISTENTE PERO NO CONECTADA AL ENDPOINT
await this.persistirRevisionSupervisor(
  tx,
  casoId,
  supervisorId,
  metadata?.observaciones || '',
  estadoDestino === EstadoCaso.APROBADO_SUPERVISOR ? 'aprobado' : 'devuelto',
);
```

**Estado real:** Esta lógica NO se ejecuta porque el endpoint usa `cases.service.transition()`.

**Evidencia runtime:** Pruebas 17, 18, 23 de `test_e5_03_bloque_b.sh` confirmaron 0 revisiones persistidas tras transiciones devuelto/aprobado_supervisor.

**Workaround temporal:** `POST /review` crea revisión manualmente, pero rompe el flujo pedagógico esperado.

---

## 4. Contrato vs código real

### 4.1 Contrato vigente (CONTRATO_API.md, sección 7)

| Endpoint | Documentado | Implementado | Alineación |
|----------|-------------|--------------|------------|
| `GET /cases/{caseId}/review` | ✅ | ✅ | ✅ Alineado |
| `GET /cases/{caseId}/review/feedback` | ✅ | ✅ | ✅ Alineado |
| `POST /cases/{caseId}/review` | ✅ | ✅ | ⚠️ Ver nota |

**Nota de alineación POST /review:**
- El contrato dice "Registra una nueva revisión del caso"
- El código lo implementa correctamente
- **D-02:** La transición vía endpoint NO crea revisiones automáticamente (servicio incorrecto conectado)
- `POST /review` es actualmente el ÚNICO camino funcional para crear revisiones

### 4.2 Campos de respuesta review

```typescript
// RevisionSupervisor (Prisma)
{
  id: string;
  caso_id: string;
  supervisor_id: string;
  version_revision: number;
  vigente: boolean;
  observaciones: string;
  resultado: string;        // 'aprobado' | 'devuelto'
  fecha_revision: Date;
  creado_en: Date;
  creado_por: string;
}
```

### 4.3 Vacíos identificados

| Vacío | Severidad | Descripción |
|-------|-----------|-------------|
| Paginación en GET /review | Baja | No implementada, pero historial típicamente pequeño |
| Detalle GET /review/:id | Baja | No existe, pero no parece necesario |
| DELETE review | N/A | No requerido (append-only) |

---

## 5. Riesgos y deuda sensible

### 5.1 ~~Riesgo: Duplicidad de creación de revisiones~~ → D-02 MATERIALIZADA

**Estado original del baseline:** Se asumía que existían dos formas de crear revisión:
1. `POST /review` (review.service.create)
2. `POST /transition` con destino aprobado_supervisor/devuelto (caso-estado.service.transicionar)

**Estado real post-runtime:** Solo `POST /review` crea revisiones. El endpoint `/transition` está conectado a `cases.service.transition()` que NO persiste revisiones.

**Impacto:** El flujo pedagógico esperado (supervisor devuelve → estudiante ve feedback) no funciona porque no hay revisión persistida.

**Corrección requerida:** E5-04 debe conectar la lógica de `caso-estado.service` al endpoint real.

### 5.2 Riesgo: Inconsistencia resultado vs estado

**Problema:** `ResultadoRevision.APROBADO` vs `EstadoCaso.APROBADO_SUPERVISOR`

El enum usa `'aprobado'` pero el estado usa `'aprobado_supervisor'`.

**Impacto:** Menor — solo cosmético, pero puede confundir en queries.

### 5.3 ~~Riesgo: Guardas estrictas~~ → Guardas NO conectadas (D-02)

**Guardas definidas en caso-estado.service (NO EJECUTADAS):**
1. Checklist sin bloques críticos incompletos
2. Estrategia con línea principal
3. Al menos un hecho registrado

**Estado real:** El endpoint `/transition` usa `cases.service.transition()` que NO ejecuta estas guardas. Un caso puede avanzar a `pendiente_revision` sin cumplir ningún requisito.

**Evidencia runtime:** El caso E503-1774659297 avanzó a `pendiente_revision` tras fallar `POST /facts` (payload incorrecto). Esto confirma que las guardas no se validan.

**Impacto para E5-04:** Al conectar el servicio correcto, las guardas se activarán y las pruebas deberán satisfacerlas.

### 5.4 ~~Deuda: No hay endpoint para completar bloques del checklist~~ → RESUELTO

**Hallazgo original:** El checklist tiene GET y PUT, pero no estaba claro cómo marcar bloques.

**Verificación runtime:** `PUT /checklist` acepta `{ items: [{id, marcado: true}, ...] }`. Cuando todos los items de un bloque están marcados, el bloque queda automáticamente `completado: true`.

**Estado:** Funcional. Prueba 08 del script validó esto.

### 5.5 Permisos esperados (NO verificados — D-04)

| Endpoint | Estudiante | Supervisor | Admin |
|----------|------------|------------|-------|
| GET /review | ❌ 403 | ✅ | ✅ |
| GET /review/feedback | ✅ (solo su caso) | ✅ | ✅ |
| POST /review | ❌ 403 | ✅ | ✅ |
| POST /transition (pendiente_revision→devuelto) | ❌ 403 | ✅ | ✅ |
| POST /transition (pendiente_revision→aprobado) | ❌ 403 | ✅ | ✅ |
| POST /transition (devuelto→en_analisis) | ✅ | ✅ | ✅ |

> **Nota:** Esta tabla refleja permisos documentados/esperados. No fue posible verificar en runtime por D-04 (stub POST /users). Validación diferida a E5-04 o unidad de usuarios.

---

## 6. Batería runtime E5-03

### 6.1 Ejecución realizada

**Modo:** Single-actor (admin) — por limitación D-04

**Script:** `test_e5_03_bloque_b.sh`

**Resultado:** 16 PASS / 0 FAIL / 8 SKIP

### 6.2 Batería ideal de referencia (dos actores)

La batería completa requiere actores estudiante y supervisor reales. Se documenta como referencia para cuando D-04 se resuelva.

| # | Prueba | Actor | Expectativa |
|---|--------|-------|-------------|
| 01-19 | Ciclo completo con dos actores | Est/Sup | Validación de flujo y permisos |
| 20-22 | Controles negativos de acceso | Estudiante | 403 en operaciones de supervisor |

### 6.3 Batería ejecutada (actor único)

| # | Prueba | Estado |
|---|--------|--------|
| 01-10 | Setup, caso, bootstrap, preparación | ✅ PASS |
| 11-24 | Ciclo de transiciones | ✅ PASS (transiciones) |
| 17, 18, 23 | Verificación de revisiones persistidas | ⏭ SKIP (D-02) |
| 13, 15, 21 | Controles de permisos | ⏭ SKIP (D-04) |

### 6.4 Nota metodológica

Para E5-03 se adoptó validación funcional single-actor por limitación D-04. La validación fuerte de permisos se difiere. La validación de persistencia de revisiones no pudo completarse por materialización de D-02.

---

## 7. Resumen de deuda sensible

| ID | Descripción | Severidad | Estado |
|----|-------------|-----------|--------|
| D-01 | Duplicidad POST /review vs /transition | Media | Abierta |
| D-02 | Dos servicios de transición no conectados | **Alta** | **MATERIALIZADA** |
| D-03 | Naming 'aprobado' vs 'aprobado_supervisor' | Baja | Abierta |
| D-04 | POST /users stub no implementado | Media | Abierta |

### D-02 — MATERIALIZADA: Servicios de transición no conectados

**Severidad:** Alta

**Estado:** Materializada en runtime 2026-03-28

**Descripción:** El endpoint `POST /cases/:id/transition` está conectado a `cases.service.transition()`, que solo actualiza estado. El servicio `caso-estado.service.transicionar()`, que contiene las guardas de negocio y persiste revisiones, **no está conectado al controller**.

**Evidencia runtime:**
- Pruebas 17, 18, 23 del script `test_e5_03_bloque_b.sh` confirmaron 0 revisiones persistidas
- Transiciones devuelto/aprobado_supervisor ejecutaron sin crear registro en tabla revisiones

**Impacto:**
1. Transición sin guardas efectivas (hechos, estrategia, checklist críticos)
2. Sin persistencia de revisiones al devolver/aprobar
3. Feedback de revisión siempre null

**Bloqueante para:** E5-04

### D-04 — POST /users stub no implementado

**Severidad:** Media

**Impacto:** Impide validación runtime completa de permisos con actor estudiante real. El endpoint `POST /api/v1/users` lanza `NotImplementedException` (Sprint 1 stub).

**Consecuencia:** Los controles negativos de permisos quedan como SKIP, no como PASS.

**Pendiente para:** E5-04 o unidad específica de usuarios/permisos.

---

## 8. Cierre de unidad

**Estado:** CIERRE PARCIAL

**Fecha:** 2026-03-28

**Nota de cierre:** `NOTA_CIERRE_PARCIAL_E5_03_2026-03-28.md`

**Siguiente:** E5-04 — Unificación de flujo de transición con reglas de negocio

---

*Baseline E5-03 — Actualizado 2026-03-28*
