# NOTA DE CIERRE PARCIAL — UNIDAD E5-03

## 1. Identificación

| Campo | Valor |
|-------|-------|
| Proyecto | LEX_PENAL |
| Fase | E5 |
| Unidad | E5-03 |
| Alcance | Bloque B: Análisis y revisión |
| Fecha | 2026-03-28 |
| Tipo de cierre | **PARCIAL** |

---

## 2. Veredicto

| Aspecto | Estado |
|---------|--------|
| Estado | Cerrado parcialmente |
| Resultado | Flujo observable validado |
| Hallazgo crítico | D-02 materializada |
| Bloqueante siguiente | E5-04 |
| Permisos | Diferidos por D-04 |

---

## 3. Resumen ejecutivo

La unidad E5-03 validó satisfactoriamente el flujo observable del ciclo de estados del caso, incluyendo bootstrap del checklist, preparación mínima del caso y transiciones hasta `aprobado_supervisor`. No obstante, el runtime confirmó la materialización de la deuda D-02: el endpoint real `POST /cases/:id/transition` opera a través de `cases.service.transition()`, que actualiza estado pero no ejecuta las guardas de negocio ni persiste revisiones. En consecuencia, el bloque review integrado no quedó validado y la unidad se cierra de forma parcial, dejando D-02 como bloqueante funcional para E5-04. Adicionalmente, la validación fuerte de permisos quedó diferida por D-04 (`POST /users` stub no implementado).

---

## 4. Resultado de pruebas runtime

| Métrica | Valor |
|---------|-------|
| Pasadas | 16 |
| Fallidas | 0 |
| Omitidas | 8 |
| Script | `test_e5_03_bloque_b.sh` |
| Caso de prueba | E503-1774659297 |

---

## 5. Matriz de validación

### 5.1 Flujo observable (validado)

| Componente | Estado | Evidencia |
|------------|--------|-----------|
| Ciclo de estados completo | ✅ Validado | Pruebas 06, 11, 16, 19, 20, 22 |
| Bootstrap checklist (3 bloques, 6 items) | ✅ Validado | Prueba 07 |
| PUT /checklist (completar bloques) | ✅ Validado | Prueba 08 |
| POST /facts con payload correcto | ✅ Validado | Prueba 09 |
| PUT /strategy | ✅ Validado | Prueba 10 |
| GET /review (endpoint responde) | ✅ Validado | Prueba 12 |
| GET /review/feedback (endpoint responde) | ✅ Validado | Prueba 14 |
| Estado final aprobado_supervisor | ✅ Validado | Prueba 24 |

### 5.2 Reglas de negocio esperadas (no conectadas — D-02)

| Componente | Estado | Causa |
|------------|--------|-------|
| Guardas de transición | ❌ No validado | `cases.service.transition()` no ejecuta guardas |
| Persistencia automática de revisión | ❌ No validado | `cases.service.transition()` no persiste revisión |
| Feedback de revisión | ❌ No validado | Sin revisión persistida, feedback es null |

### 5.3 Permisos por actor real (diferidos — D-04)

| Componente | Estado | Causa |
|------------|--------|-------|
| Separación estudiante/supervisor | ⏭ Diferido | `POST /users` stub no implementado |
| Controles de permisos | ⏭ Diferido | Sin actor estudiante real |

---

## 6. Hallazgo materializado: D-02

### 6.1 Descripción

Existen dos servicios de transición de estado no alineados:

| Servicio | Conectado | Guardas | Revisión |
|----------|-----------|---------|----------|
| `cases.service.transition()` | ✅ Sí | ❌ No | ❌ No |
| `caso-estado.service.transicionar()` | ❌ No | ✅ Sí | ✅ Sí |

### 6.2 Flujo actual

```
POST /api/v1/cases/:id/transition
    │
    ▼
cases.controller.transition()
    │
    ▼
cases.service.transition()
    │
    ├─ Valida matriz de transiciones permitidas ✓
    ├─ Bootstrap checklist en borrador→en_analisis ✓
    ├─ Actualiza estado en tabla casos ✓
    │
    ├─ NO verifica guardas ✗
    ├─ NO persiste revisión ✗
    └─ NO registra auditoría completa ✗
```

### 6.3 Impacto

1. **Transición sin guardas:** Caso puede avanzar sin cumplir requisitos
2. **Sin trazabilidad:** Devoluciones/aprobaciones no quedan registradas
3. **Feedback nulo:** `GET /review/feedback` siempre retorna null

### 6.4 Severidad

**Alta** — El flujo de revisión pedagógica (core del sistema) no está operativo.

---

## 7. Siguiente paso

Apertura de E5-04 enfocada en:

1. Unificación del flujo de transición con reglas de negocio
2. Conexión de `caso-estado.service.transicionar()` al controller (o migración de lógica)
3. Persistencia de revisiones en transiciones devuelto/aprobado_supervisor
4. Validación de guardas efectivas

---

## 8. Artefactos de respaldo

| Artefacto | Ubicación |
|-----------|-----------|
| Script de pruebas | `test_e5_03_bloque_b.sh` |
| Baseline técnico | `docs/00_gobierno/fases/E5/unidades/unidad_03/BASELINE_REVIEW_UNIDAD_E5_03_2026-03-27.md` |
| Esta nota | `docs/00_gobierno/fases/E5/unidades/unidad_03/NOTA_CIERRE_PARCIAL_E5_03_2026-03-28.md` |

---

**Fecha:** 2026-03-28  
**Metodología:** MDS v2.3
