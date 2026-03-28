# CHECKLIST DE APERTURA — UNIDAD E5-04

## 1. Identificación

| Campo | Valor |
|-------|-------|
| Proyecto | LEX_PENAL |
| Fase | E5 |
| Unidad | E5-04 |
| Fecha apertura | 2026-03-28 |
| Precedente | E5-03 (cierre parcial) |

---

## 2. Contexto de entrada

### 2.1 Hallazgo bloqueante: D-02 materializada

El runtime de E5-03 confirmó que `cases.service.transition()` (conectado al controller) no ejecuta guardas ni persiste revisiones. El servicio `caso-estado.service.transicionar()` contiene la lógica correcta pero no está conectado.

### 2.2 Estado heredado

| Componente | Estado |
|------------|--------|
| Ciclo de estados | ✅ Funcional |
| Bootstrap checklist | ✅ Funcional |
| POST /facts | ✅ Funcional |
| PUT /strategy | ✅ Funcional |
| PUT /checklist | ✅ Funcional |
| Guardas de transición | ❌ No conectadas |
| Persistencia de revisión | ❌ No conectada |
| Feedback de revisión | ❌ Sin datos |
| Permisos por actor | ⏭ Diferido (D-04) |

---

## 3. Alcance de E5-04

### 3.1 Objetivo principal

Unificar el flujo de transición para que el endpoint `POST /cases/:id/transition` ejecute las reglas de negocio completas.

### 3.2 Alcance permitido

| Componente | Acción |
|------------|--------|
| `cases.controller.ts` | Modificar para usar servicio correcto |
| `cases.service.ts` | Refactorizar o reemplazar `transition()` |
| `caso-estado.service.ts` | Conectar al controller o migrar lógica |
| Guardas de transición | Activar validación |
| Persistencia de revisión | Activar en devuelto/aprobado |
| Pruebas runtime | Validar flujo completo |

### 3.3 Alcance prohibido

| Componente | Razón |
|------------|-------|
| `POST /users` | Fuera de alcance (D-04 separada) |
| Módulo `reports` | Bloque C |
| Módulo `ai` | Bloque C |
| Refactor transversal de arquitectura | Riesgo de regresión |

---

## 4. Opciones de implementación

### 4.1 Opción A: Conectar caso-estado.service al controller

```typescript
// cases.controller.ts
@Post(':id/transition')
async transition(@Param('id') id, @Body() dto, @CurrentUser() user) {
  return this.casoEstadoService.transicionar(id, dto.estado_destino, user.sub, dto);
}
```

**Pros:** Reutiliza lógica existente, menor cambio
**Contras:** Dos servicios coexisten, posible confusión futura

### 4.2 Opción B: Migrar lógica a cases.service

Mover guardas y persistencia de revisión de `caso-estado.service` a `cases.service.transition()`.

**Pros:** Un solo servicio, más limpio
**Contras:** Mayor refactor, riesgo de regresión

### 4.3 Opción C: Deprecar caso-estado.service

Marcar `caso-estado.service` como deprecated, migrar toda lógica a `cases.service`, eliminar en siguiente fase.

**Pros:** Solución definitiva
**Contras:** Mayor esfuerzo, fuera de alcance mínimo

---

## 5. Propuesta de secuencia

| Paso | Descripción | Entregable |
|------|-------------|------------|
| 1 | Baseline técnico de ambos servicios | Documento comparativo |
| 2 | Decisión de implementación (A, B o C) | Decisión documentada |
| 3 | Implementación | Código modificado |
| 4 | Pruebas runtime | Script actualizado |
| 5 | Cierre de unidad | Nota de cierre |

---

## 6. Criterios de cierre

### 6.1 Mínimos obligatorios

- [ ] `POST /cases/:id/transition` ejecuta guardas de `en_analisis → pendiente_revision`
- [ ] `POST /cases/:id/transition` persiste revisión en `devuelto` y `aprobado_supervisor`
- [ ] `GET /cases/:caseId/review` retorna revisiones creadas por transición
- [ ] `GET /cases/:caseId/review/feedback` retorna observaciones de última revisión
- [ ] Script de pruebas con 0 FAIL en componentes de review

### 6.2 Deseables

- [ ] Guardas de todas las transiciones activas
- [ ] Auditoría completa de transiciones
- [ ] D-02 cerrada formalmente

---

## 7. Deuda heredada

| ID | Descripción | Severidad | Bloquea E5-04? |
|----|-------------|-----------|----------------|
| D-01 | Duplicidad POST /review vs /transition | Media | No |
| D-02 | Servicios de transición no conectados | Alta | **SÍ** — objetivo principal |
| D-03 | Naming aprobado vs aprobado_supervisor | Baja | No |
| D-04 | POST /users stub | Media | No |

---

## 8. Siguiente paso

Solicitar código de ambos servicios para baseline comparativo:

```bash
cat src/modules/cases/cases.service.ts
cat src/modules/cases/services/caso-estado.service.ts
```

---

**Fecha:** 2026-03-28  
**Metodología:** MDS v2.3
