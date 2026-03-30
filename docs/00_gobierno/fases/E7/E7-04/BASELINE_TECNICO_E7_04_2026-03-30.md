# BASELINE TÉCNICO E7-04 — 2026-03-30

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E7
- Unidad: E7-04
- Fecha: 2026-03-30
- Estado: EN ELABORACIÓN

## 2. Superficie inspeccionada

| Componente | Archivo | Líneas clave |
|------------|---------|--------------|
| Service | `client-briefing.service.ts` | 28-42 (findByCaseId), 44-79 (update) |
| Repository | `client-briefing.repository.ts` | CRUD estándar |
| Controller | `client-briefing.controller.ts` | GET + PUT |
| Estados | `types/enums.ts` | EstadoCaso (7 estados) |
| Contrato | `CONTRATO_API.md` | líneas 652-660 |

## 3. Hallazgo principal — Deuda confirmada

### Asimetría GET vs PUT

```
GET /client-briefing
├── checkCaseAccess() → valida existencia + permisos
├── findByCaseId()
└── if (!briefing) → create() ← ESCRITURA SIN VALIDAR ESTADO

PUT /client-briefing
├── checkCaseAccess() → valida existencia + permisos
├── checkWritePermission() ← VALIDA ESTADO
└── update()
```

**La auto-creación en GET es una escritura que bypasea la validación de estado.**

## 4. Estados y permisos actuales

### Constante de control (E6-03)
```typescript
const ESTADOS_ESCRITURA_PERMITIDA_CLIENT_BRIEFING: EstadoCaso[] = [
  EstadoCaso.EN_ANALISIS,
  EstadoCaso.DEVUELTO,
  EstadoCaso.LISTO_PARA_CLIENTE,
];
```

### Matriz de comportamiento actual

| Estado | PUT | GET (si no existe) | Deuda |
|--------|-----|-------------------|-------|
| BORRADOR | ❌ 409 | ✅ Auto-crea | ⚠️ |
| EN_ANALISIS | ✅ | ✅ Auto-crea | — |
| PENDIENTE_REVISION | ❌ 409 | ✅ Auto-crea | ⚠️ |
| DEVUELTO | ✅ | ✅ Auto-crea | — |
| APROBADO_SUPERVISOR | ❌ 409 | ✅ Auto-crea | ⚠️ |
| LISTO_PARA_CLIENTE | ✅ | ✅ Auto-crea | — |
| CERRADO | ❌ 409 | ✅ Auto-crea | ⚠️ |

## 5. Contrato observable

```markdown
Recurso **singleton**: existe exactamente una explicación al cliente por caso.

**Comportamiento especial:**
- Si `GET /client-briefing` se invoca y no existe aún una explicación 
  para el caso, el sistema la crea automáticamente y retorna el recurso resultante.
- `PUT /client-briefing` actualiza la explicación existente del caso.
```

El contrato **no especifica restricción por estado** para la auto-creación. Esto deja margen para:
1. Corregir la implementación y actualizar contrato
2. Documentar la asimetría como decisión explícita

## 6. Análisis funcional

### ¿Cuándo tiene sentido que exista client-briefing?

El recurso `client-briefing` representa la **explicación al cliente** sobre:
- delito_explicado
- riesgos_informados
- panorama_probatorio
- beneficios_informados
- opciones_explicadas
- recomendacion
- **decision_cliente** ← crítico para transición a CERRADO

Funcionalmente, este recurso tiene sentido cuando el caso está en etapa de comunicación con el cliente, no en etapas tempranas de análisis interno.

### Flujo lógico esperado

```
BORRADOR ──────────────────────────────────────────────────┐
EN_ANALISIS ───────────────────────────────────────────────┤ (trabajo interno)
PENDIENTE_REVISION ────────────────────────────────────────┤
DEVUELTO ──────────────────────────────────────────────────┘
                                                           ↓
APROBADO_SUPERVISOR ──────────────────────────────────────→ (transición)
                                                           ↓
LISTO_PARA_CLIENTE ────────────────────────────────────────┐
CERRADO ───────────────────────────────────────────────────┘ (comunicación cliente)
```

## 7. Opciones de resolución

### Opción A: Alinear GET con PUT (recomendada)
Aplicar misma validación de estado a la auto-creación.

```typescript
async findByCaseId(...): Promise<ExplicacionCliente> {
  await this.checkCaseAccess(casoId, userId, perfil);
  
  let briefing = await this.repository.findByCaseId(casoId);
  
  if (!briefing) {
    // E7-04: Validar estado antes de auto-crear
    await this.checkWritePermission(casoId);
    briefing = await this.repository.create({...});
  }
  
  return briefing;
}
```

**Comportamiento resultante:**
- GET en estado permitido + no existe → auto-crea → 200
- GET en estado permitido + existe → retorna → 200
- GET en estado no permitido + no existe → 409
- GET en estado no permitido + existe → retorna → 200 (lectura permitida)

### Opción B: Separar lectura de auto-creación
Retornar 404 si no existe y estado no permite.

### Opción C: Documentar asimetría actual
Justificar funcionalmente y actualizar contrato.

## 8. Recomendación

**Opción A** — Reutilizar `checkWritePermission()` antes de auto-crear.

Razones:
1. Consistencia con política existente de E6-03
2. Reutiliza constante `ESTADOS_ESCRITURA_PERMITIDA_CLIENT_BRIEFING`
3. Cambio mínimo (2-3 líneas)
4. No rompe lecturas de recursos ya creados

## 9. Superficie a intervenir

| Archivo | Cambio |
|---------|--------|
| `client-briefing.service.ts` | Agregar `checkWritePermission()` antes de `create()` en `findByCaseId()` |
| `CONTRATO_API.md` | Actualizar comportamiento especial de GET |

## 10. Criterios de aceptación

- [ ] GET en estado no permitido + briefing no existe → 409
- [ ] GET en estado no permitido + briefing existe → 200 (lectura)
- [ ] GET en estado permitido + briefing no existe → 200 (auto-crea)
- [ ] GET en estado permitido + briefing existe → 200
- [ ] PUT mantiene comportamiento actual
- [ ] Build verde

## 11. Riesgos

- Romper flujo de UI que espere siempre 200 en GET
- Necesidad de ajustar frontend para manejar 409 en GET

## 12. Propuesta de continuidad

1. Confirmar decisión de opción A
2. Generar instrucción para CC
3. Aplicar corrección
4. Actualizar contrato
5. Script runtime
6. Build + evidencia
7. Cierre
