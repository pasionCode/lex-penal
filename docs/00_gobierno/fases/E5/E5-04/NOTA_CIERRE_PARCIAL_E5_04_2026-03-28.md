# NOTA DE CIERRE PARCIAL — UNIDAD E5-04

## 1. Identificación

| Campo | Valor |
|-------|-------|
| Proyecto | LEX_PENAL |
| Fase | E5 |
| Unidad | E5-04 |
| Alcance | Unificación del flujo de transición |
| Fecha | 2026-03-28 |
| Tipo de cierre | **PARCIAL** |

---

## 2. Veredicto

| Aspecto | Estado |
|---------|--------|
| Estado | Cerrado parcialmente |
| Resultado | Unificación estructural completada |
| Hallazgo nuevo | D-05 — Bootstrap U008 inconsistente |
| Bloqueante siguiente | E5-05 (checklist) |
| D-02 | Resuelta estructuralmente |

---

## 3. Resumen ejecutivo

La unidad E5-04 completó la unificación estructural del flujo de transición: `CasesService.transition()` ahora conserva `checkAccess()` y delega a `CasoEstadoService.transicionar()`, habilitando guardas, persistencia de revisión y auditoría por el camino correcto.

Sin embargo, el runtime descubrió un hallazgo bloqueante nuevo: el bootstrap U008 (12 bloques) no crea items, y la guarda de `en_analisis → pendiente_revision` verifica `checklistBloque.completado`, no items. Esto impide completar el ciclo desde bootstrap hasta `pendiente_revision` sin intervención adicional.

La unidad se cierra parcialmente. D-02 queda resuelta estructuralmente. D-05 se abre como nueva deuda que bloquea el ciclo completo.

---

## 4. Cambio implementado

### 4.1 Archivo modificado

`src/modules/cases/cases.service.ts`

### 4.2 Cambio exacto

```typescript
// ANTES
constructor(
  private readonly repository: CasesRepository,
  private readonly checklistService: ChecklistService,
) {}

async transition(id, estadoDestino, userId, perfil, observaciones?) {
  const caso = await this.checkAccess(id, userId, perfil);
  // ~50 líneas de lógica incompleta:
  // - matriz local
  // - bootstrap parcial
  // - update directo sin guardas/review/auditoría
}

// DESPUÉS
constructor(
  private readonly repository: CasesRepository,
  private readonly checklistService: ChecklistService,
  private readonly casoEstadoService: CasoEstadoService,
) {}

async transition(id, estadoDestino, userId, perfil, observaciones?) {
  await this.checkAccess(id, userId, perfil);
  return this.casoEstadoService.transicionar(
    id, estadoDestino, userId, perfil,
    observaciones ? { observaciones } : undefined,
  );
}
```

### 4.3 Justificación

- Conserva `checkAccess()` que valida acceso del estudiante a su caso
- Delega al motor completo que tiene guardas, review y auditoría
- Controller intacto = menor riesgo de regresión
- Elimina lógica duplicada/incompleta

---

## 5. Matriz de validación

### 5.1 Cumplido

| Componente | Estado | Evidencia |
|------------|--------|-----------|
| Unificación flujo transición | ✅ | Código modificado |
| Conservación checkAccess() | ✅ | Wrapper mantiene validación |
| Habilitación guardas | ✅ | CasoEstadoService.verificarGuardas() conectado |
| Habilitación review | ✅ | CasoEstadoService.persistirRevisionSupervisor() conectado |
| Habilitación auditoría | ✅ | CasoEstadoService registra eventoAuditoria |
| D-02 resuelta | ✅ | Motor único real conectado |

### 5.2 No cumplido (bloqueado por D-05)

| Componente | Estado | Causa |
|------------|--------|-------|
| Ciclo completo runtime | ❌ | Bootstrap U008 sin items |
| Transición en_analisis→pendiente_revision | ❌ | Guarda de checklist insatisfacible |
| Pruebas E5-04 completas | ❌ | Bloqueadas por D-05 |

---

## 6. Hallazgo nuevo: D-05

### 6.1 Descripción

**D-05 — Bootstrap U008 inconsistente con guardas de checklist**

El bootstrap fuerte (`CasoEstadoService.generarEstructuraBase()`) crea 12 bloques según `BLOQUES_CHECKLIST_U008`, pero no crea items.

La guarda de `en_analisis → pendiente_revision` verifica:
```typescript
const bloquesCriticosIncompletos = await this.prisma.checklistBloque.count({
  where: { caso_id: casoId, critico: true, completado: false },
});
```

Sin items, no hay mecanismo runtime para marcar `bloque.completado = true`.

### 6.2 Datos

| Métrica | Valor |
|---------|-------|
| Bloques creados | 12 |
| Bloques críticos | 10 |
| Items creados | 0 |
| Items en TODO | Sí (código tiene `// TODO`) |

### 6.3 Impacto

- La transición `en_analisis → pendiente_revision` queda permanentemente bloqueada
- El ciclo de revisión no puede completarse desde bootstrap U008
- Las pruebas E5-04 fallan en paso 11

### 6.4 Severidad

**Alta** — Bloquea el flujo pedagógico completo.

### 6.5 Pendiente para

E5-05 o unidad específica de checklist.

### 6.6 Verificación requerida antes de resolver

```bash
cat src/modules/checklist/checklist.service.ts
cat src/modules/checklist/checklist.repository.ts
cat src/modules/checklist/checklist.controller.ts
```

Preguntas a resolver:
1. ¿`PUT /checklist` recalcula `bloque.completado` automáticamente?
2. ¿Existe endpoint para marcar bloques directamente?
3. ¿La solución es crear items, recalcular completado, o ambas?

---

## 7. Estado de deudas

| ID | Descripción | Severidad | Estado |
|----|-------------|-----------|--------|
| D-01 | Duplicidad POST /review vs /transition | Media | Abierta |
| D-02 | Servicios de transición no conectados | Alta | **RESUELTA** |
| D-03 | Naming aprobado vs aprobado_supervisor | Baja | Abierta |
| D-04 | POST /users stub | Media | Abierta |
| D-05 | Bootstrap U008 inconsistente | **Alta** | **NUEVA** |

---

## 8. Deuda menor identificada

`ChecklistService` quedó inyectado en `CasesService` pero ya no se usa en `transition()`. No bloquea, pero es higiene pendiente.

---

## 9. Artefactos

| Artefacto | Ubicación |
|-----------|-----------|
| cases.service.ts modificado | Entregado para aplicación |
| Baseline comparativo | `BASELINE_COMPARATIVO_E5_04_2026-03-28.md` |
| Esta nota | `NOTA_CIERRE_PARCIAL_E5_04_2026-03-28.md` |

---

## 10. Siguiente paso

1. Aplicar `cases.service.ts` modificado
2. Verificar build (`npm run build`)
3. Levantar baseline de checklist (D-05)
4. Abrir E5-05 para resolver inconsistencia checklist

---

**Fecha:** 2026-03-28  
**Metodología:** MDS v2.3
