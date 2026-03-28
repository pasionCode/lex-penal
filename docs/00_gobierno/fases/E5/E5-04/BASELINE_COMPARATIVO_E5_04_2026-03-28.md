# BASELINE COMPARATIVO E5-04 — SERVICIOS DE TRANSICIÓN

## 1. Identificación

| Campo | Valor |
|-------|-------|
| Proyecto | LEX_PENAL |
| Fase | E5 |
| Unidad | E5-04 |
| Fecha | 2026-03-28 |
| Objetivo | Unificar flujo de transición con reglas de negocio |

---

## 2. Mapa comparativo

### 2.1 Cableado ANTES de E5-04 (estado heredado)

```
POST /api/v1/cases/:id/transition
    │
    ▼
cases.controller.transition()
    │
    ▼
cases.service.transition()      ← CONECTADO (sin guardas, sin review)
    │
    └─► CasesRepository
    └─► ChecklistService.bootstrapIfNeeded()


caso-estado.service.transicionar()  ← NO CONECTADO (tiene guardas + review)
    │
    └─► PrismaService (directo)
```

### 2.2 Cableado DESPUÉS de E5-04 (implementado)

```
POST /api/v1/cases/:id/transition
    │
    ▼
cases.controller.transition()
    │
    ▼
cases.service.transition()      ← WRAPPER
    │
    ├─► checkAccess()           ← CONSERVADO (valida responsable)
    │
    └─► casoEstadoService.transicionar()  ← DELEGACIÓN
            │
            ├─► Guardas ✓
            ├─► Bootstrap 12 bloques ✓
            ├─► Persistir revisión ✓
            └─► Auditoría ✓
```

### 2.3 cases.service.transition() — Estado heredado (ANTES)

| Aspecto | Implementación | Estado |
|---------|----------------|--------|
| Validar acceso | `checkAccess()` | ✅ |
| Validar matriz transiciones | Inline `transicionesPermitidas` | ✅ |
| Validar permisos por perfil | ❌ No implementado | ❌ |
| Ejecutar guardas | ❌ No implementado | ❌ |
| Bootstrap checklist | `checklistService.bootstrapIfNeeded()` | ✅ (3 bloques) |
| Persistir revisión | ❌ No implementado | ❌ |
| Actualizar estado | `repository.update()` | ✅ |
| Registrar auditoría | ❌ No implementado | ❌ |

**Dependencias:**
- `CasesRepository`
- `ChecklistService`

**Líneas de código:** ~50

### 2.4 caso-estado.service.transicionar()

| Aspecto | Implementación | Estado |
|---------|----------------|--------|
| Validar caso existe | `prisma.caso.findUnique()` | ✅ |
| Validar matriz transiciones | `TRANSICIONES_VALIDAS` (constantes) | ✅ |
| Validar permisos por perfil | `PERMISOS_TRANSICION` | ✅ |
| Ejecutar guardas | `verificarGuardas()` con 7 casos | ✅ |
| Bootstrap estructura | `generarEstructuraBase()` | ✅ (12 bloques) |
| Persistir revisión | `persistirRevisionSupervisor()` | ✅ |
| Actualizar estado | `tx.caso.update()` | ✅ |
| Registrar auditoría | `tx.eventoAuditoria.create()` | ✅ |

**Dependencias:**
- `PrismaService` (directo, sin repository)

**Líneas de código:** ~450

---

## 3. Detalle de guardas en caso-estado.service

| Transición | Guarda | Verificación |
|------------|--------|--------------|
| `borrador→en_analisis` | Ficha básica completa | radicado, cliente_id, delito_imputado, etapa_procesal |
| `en_analisis→pendiente_revision` | Checklist OK | bloques críticos completados |
| `en_analisis→pendiente_revision` | Estrategia OK | linea_principal no vacía |
| `en_analisis→pendiente_revision` | Hechos OK | count(hechos) ≥ 1 |
| `pendiente_revision→devuelto` | Observaciones | metadata.observaciones no vacío |
| `pendiente_revision→aprobado_supervisor` | Observaciones | metadata.observaciones no vacío |
| `devuelto→en_analisis` | Revisión existe | count(revisiones) ≥ 1 |
| `aprobado_supervisor→listo_para_cliente` | Conclusión completa | 5 bloques + recomendación |
| `listo_para_cliente→cerrado` | Decisión cliente | decision_cliente no vacío |

---

## 4. Detalle de side effects por servicio (estado heredado)

> **Nota:** Esta sección describe el comportamiento ANTES de E5-04. Tras el cambio, `cases.service.transition()` delega a `casoEstadoService.transicionar()`, por lo que los side effects son los de la sección 4.2.

### 4.1 cases.service.transition() — ANTES

| Side effect | Transición | Implementación |
|-------------|------------|----------------|
| Bootstrap checklist | `borrador→en_analisis` | `checklistService.bootstrapIfNeeded()` → 3 bloques, 6 items |
| Actualizar observaciones | Todas | Copia `dto.observaciones` a `caso.observaciones` |

### 4.2 caso-estado.service.transicionar()

| Side effect | Transición | Implementación |
|-------------|------------|----------------|
| Bootstrap estructura | `borrador→en_analisis` | `generarEstructuraBase()` → 12 bloques + estrategia + explicación + conclusión |
| Persistir revisión | `pendiente_revision→devuelto` | `persistirRevisionSupervisor()` con resultado='devuelto' |
| Persistir revisión | `pendiente_revision→aprobado_supervisor` | `persistirRevisionSupervisor()` con resultado='aprobado' |
| Auditoría | Todas | `eventoAuditoria.create()` con TipoEvento.TRANSICION_ESTADO |

---

## 5. Discrepancia crítica: Bootstrap — RESUELTA

| Servicio | Bloques | Items | Extras |
|----------|---------|-------|--------|
| `cases.service` (antes) | 3 | 6 | — |
| `caso-estado.service` (ahora) | 12 | 0 (TODO) | estrategia, explicación, conclusión |

**Decisión tomada:** Se adoptó bootstrap de 12 bloques (U008) al conectar `caso-estado.service`.

**Impacto real:**
1. ✅ Pruebas ajustadas para esperar 12 bloques
2. ⚠️ Items no creados (D-05)
3. ✅ Estructuras auxiliares creadas (estrategia, explicación, conclusión)

**Hallazgo D-05:** Los 12 bloques se crean pero sin items. La guarda de `en_analisis → pendiente_revision` verifica `checklistBloque.completado`, que no puede marcarse true sin items. Ver sección 11.2.

---

## 6. Análisis de dependencias

### 6.1 cases.service — DESPUÉS de E5-04

```typescript
constructor(
  private readonly repository: CasesRepository,
  private readonly checklistService: ChecklistService,  // Deuda menor: sin uso en transition()
  private readonly casoEstadoService: CasoEstadoService,
) {}
```

**Módulos requeridos:** CasesModule importa ChecklistModule; CasoEstadoService ya está en providers/exports de CasesModule.

### 6.2 caso-estado.service

```typescript
constructor(private readonly prisma: PrismaService) {}
```

**Módulos requeridos:** Solo PrismaModule (ya global)

**Nota del código:** "Este servicio NO debe inyectar ChecklistService directamente para evitar dependencia circular"

### 6.3 Verificación de exportación

**Pregunta:** ¿CasoEstadoService está exportado desde CasesModule?

```bash
# Verificar
cat src/modules/cases/cases.module.ts
```

---

## 7. Opciones de implementación

### 7.1 Opción A: Conectar caso-estado.service al controller

**Cambio:**
```typescript
// cases.controller.ts
constructor(
  private readonly service: CasesService,
  private readonly casoEstadoService: CasoEstadoService,  // Agregar
) {}

@Post(':id/transition')
async transition(...) {
  return this.casoEstadoService.transicionar(
    id,
    dto.estado_destino,
    user.sub,
    user.perfil as PerfilUsuario,
    dto.observaciones ? { observaciones: dto.observaciones } : undefined,
  );
}
```

**Archivos a modificar:** 1 (cases.controller.ts)

**Líneas:** ~5

**Pros:**
- Cambio mínimo
- Reutiliza lógica completa existente
- Guardas, revisión, auditoría funcionan inmediatamente

**Contras:**
- Dos servicios coexisten (cases.service.transition queda sin uso)
- Bootstrap cambia de 3 a 12 bloques
- Posible confusión futura

**Riesgos:**
- CasoEstadoService debe estar exportado en CasesModule
- Bootstrap de 12 bloques puede requerir ajuste de pruebas

### 7.2 Opción B: Migrar lógica a cases.service

**Cambio:** Copiar guardas + persistirRevisionSupervisor + auditoría de caso-estado a cases.service

**Archivos a modificar:** 1 (cases.service.ts)

**Líneas:** ~200

**Pros:**
- Un solo servicio
- Más limpio a largo plazo

**Contras:**
- Mayor refactor
- Duplicación de código
- Riesgo de regresión en migración

### 7.3 Opción C: Wrapper en cases.service ← IMPLEMENTADA

**Cambio:**
```typescript
// cases.service.ts
constructor(
  private readonly repository: CasesRepository,
  private readonly checklistService: ChecklistService,
  private readonly casoEstadoService: CasoEstadoService,  // Agregar
) {}

async transition(...) {
  await this.checkAccess(id, userId, perfil);  // Conservar
  return this.casoEstadoService.transicionar(id, estadoDestino, userId, perfil, { observaciones });
}
```

**Archivos modificados:** 1 (`cases.service.ts`). Nota: `cases.module.ts` ya tenía CasoEstadoService en providers/exports.

**Pros:**
- Controller no cambia
- Delegación limpia
- Conserva checkAccess()

**Contras:**
- ChecklistService queda inyectado sin uso en transition() (deuda menor)

---

## 8. Decisión implementada

### Opción implementada: C mínima — Wrapper en CasesService

**Estado:** ✅ IMPLEMENTADA

**Justificación:**
1. Conserva `checkAccess()` que valida acceso del estudiante a su caso
2. Opción A directa al controller omite esta validación crítica
3. Cambio mínimo: inyectar CasoEstadoService en CasesService + reescribir transition()
4. Controller intacto = menor riesgo de regresión
5. Motor único real en CasoEstadoService

### Riesgo mitigado

`CasoEstadoService.transicionar()` valida permisos por perfil (supervisor puede devolver/aprobar), pero NO valida que el estudiante sea responsable del caso. Esa validación vive en `CasesService.checkAccess()`.

Con Opción A directa, un estudiante con token válido podría intentar transicionar casos ajenos si el perfil está permitido para esa transición específica.

Con Opción C, `checkAccess()` se ejecuta primero y bloquea el acceso.

### Pasos completados

| Paso | Acción | Estado |
|------|--------|--------|
| 1 | Agregar import de CasoEstadoService | ✅ |
| 2 | Inyectar CasoEstadoService en constructor | ✅ |
| 3 | Reescribir transition() como wrapper | ✅ |
| 4 | Ajustar script de pruebas para 12 bloques | ✅ |
| 5 | Aplicar y ejecutar pruebas | ⏳ Pendiente |

### Código implementado

```typescript
// cases.service.ts — IMPLEMENTADO
constructor(
  private readonly repository: CasesRepository,
  private readonly checklistService: ChecklistService,  // Deuda menor: ya no se usa en transition()
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

**Archivos a modificar:** 1 (cases.service.ts)

**Líneas netas:** -45 (elimina lógica duplicada), +10 (wrapper)

---

## 9. Juicio de riesgo

| Área | Impacto | Mitigación |
|------|---------|------------|
| Bootstrap checklist | **Alto** — Cambia de 3 a 12 bloques | Ajustar pruebas; verificar que 12 bloques es lo esperado |
| Review | **Positivo** — Se activa persistencia automática | Ninguna |
| Auditoría | **Positivo** — Se activa registro | Ninguna |
| Guardas | **Medio** — Se activan validaciones | Pruebas deben satisfacer hechos, estrategia, checklist |
| Control de acceso | **Mitigado** — checkAccess() conservado | Opción C garantiza validación de responsable |
| Duplicidad | **Bajo** — Lógica antigua en transition() eliminada | Código limpio |
| Regresión | **Bajo** — Controller intacto | Pruebas runtime |

---

## 11. Estado final

### 11.1 Verificaciones completadas

```
✅ CasoEstadoService en providers: Sí
✅ CasoEstadoService en exports: Sí
✅ Dependencia circular: No
```

### 11.2 D-05 descubierta durante análisis

**D-05 — Bootstrap U008 inconsistente con guardas de checklist**

| Aspecto | Valor |
|---------|-------|
| Bloques creados | 12 |
| Bloques críticos | 10 |
| Items creados | 0 |
| Estado items | `// TODO` en código |

La guarda de `en_analisis → pendiente_revision` verifica `checklistBloque.count({ critico: true, completado: false })`. Sin items, no hay mecanismo para marcar `bloque.completado = true`.

**Severidad:** Alta — Bloquea ciclo completo.

**Pendiente para:** E5-05

---

## 12. Siguiente paso

1. ✅ Baseline comparativo generado
2. ✅ Decisión: Opción C mínima (wrapper en CasesService)
3. ⏳ Aplicar `cases.service.ts` modificado
4. ⏳ Ejecutar `test_e5_04_estructural.sh`
5. ⏳ Cerrar E5-04 parcial
6. ⏳ Abrir E5-05 para resolver D-05

---

**Fecha:** 2026-03-28  
**Metodología:** MDS v2.3
