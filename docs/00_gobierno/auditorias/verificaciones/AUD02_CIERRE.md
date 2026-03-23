# VERIFICACIÓN DE CIERRE — AUD-02

## Hallazgo original

**ID**: AUD-02  
**Descripción**: CasoEstadoService no estructurado  
**Prioridad**: P1  
**Estado anterior**: FALTANTE

---

## Criterio de cierre definido

| # | Criterio | Estado |
|---|---|---|
| 1 | Decisión emitida: servicio separado o integrado | ✅ Servicio separado |
| 2 | Responsabilidades documentadas explícitamente | ✅ |
| 3 | R08 mapeada a método | ✅ `generarEstructuraBase()` |
| 4 | R09 mapeada a método | ✅ `verificarEscritura()` |
| 5 | Punto único de transición definido | ✅ `transicionar()` |
| 6 | Transiciones válidas documentadas | ✅ |

---

## Evidencia de cumplimiento

### Criterio 1 — Decisión de arquitectura

**Decisión**: CasoEstadoService es un servicio **separado** de CasesService.

**Justificación** (de PROPUESTA_CASO_ESTADO_SERVICE.md):
- ADR-003 lo indica explícitamente
- Principio de responsabilidad única
- Ningún otro servicio puede modificar `estado_actual` directamente
- La complejidad de las guardas justifica un servicio dedicado

**Archivos creados**:
- `src/modules/cases/caso-estado.service.ts` — servicio principal (716 líneas)
- `src/modules/cases/caso-estado.constants.ts` — constantes y matrices (104 líneas)
- `src/modules/cases/dto/transition-case.dto.ts` — DTO de transición (30 líneas)

### Criterio 2 — Responsabilidades documentadas

| Responsabilidad | Método | Fuente canónica |
|---|---|---|
| Ejecutar transiciones de estado | `transicionar()` | ADR-003 |
| Verificar guardas por transición | `verificarGuardas()` | ADR-003 |
| Verificar permisos por perfil | dentro de `transicionar()` | ADR-003 |
| Generar estructura base al activar | `generarEstructuraBase()` | R08 |
| Verificar si caso permite escritura | `verificarEscritura()` | R09 |
| Persistir revisión del supervisor | `persistirRevisionSupervisor()` | R04 |
| Registrar evento de auditoría | dentro de `transicionar()` | R06 |
| Obtener transiciones disponibles | `obtenerTransicionesDisponibles()` | para frontend |
| Validar transición sin ejecutar | `validarTransicion()` | para preview |

### Criterio 3 — R08 mapeada

**Regla R08**: Al activar un caso se genera automáticamente su estructura base.

**Implementación**: Método `generarEstructuraBase()` ejecutado en transición `borrador → en_analisis`.

**Genera**:
- 12 bloques de checklist (BLOQUES_CHECKLIST_U008)
- Registro vacío de `estrategia`
- Registro vacío de `explicacion_cliente`
- Registro vacío de `conclusion_operativa`

**Atomicidad**: Ejecutado dentro de `prisma.$transaction()`.

**Pendiente**: Definir ítems específicos del checklist por bloque (marcado como TODO en código).

### Criterio 4 — R09 mapeada

**Regla R09**: Un caso cerrado es inmutable.

**Implementación**: Método `verificarEscritura()`.

**Estados que bloquean escritura** (ESTADOS_ESCRITURA_BLOQUEADA):
- `borrador` (R08 — análisis no iniciado)
- `pendiente_revision` (caso en revisión)
- `listo_para_cliente` (conclusión lista)
- `cerrado` (R09 — inmutable)

**Uso por otros servicios**:
```typescript
// En FactsService, EvidenceService, etc.
async update(casoId: string, dto: UpdateDto) {
  await this.casoEstadoService.verificarEscritura(casoId);
  // ... lógica de actualización
}
```

### Criterio 5 — Punto único de transición

**Método**: `transicionar(casoId, estadoDestino, usuarioId, perfilUsuario, metadata?)`

**Flujo interno**:
1. Obtener caso con estado actual
2. Verificar transición válida (matriz TRANSICIONES_VALIDAS)
3. Verificar permiso del perfil (matriz PERMISOS_TRANSICION)
4. Ejecutar guardas específicas
5. Generar estructura base si aplica (borrador → en_analisis)
6. Actualizar caso (estado_anterior, estado_actual, fecha, usuario)
7. Registrar evento de auditoría
8. Retornar caso actualizado

**Todo en transacción**: Pasos 5-7 atómicos.

### Criterio 6 — Transiciones documentadas

**Matriz de transiciones válidas** (de ADR-003):

| Estado origen | Estados destino válidos |
|---|---|
| `borrador` | `en_analisis` |
| `en_analisis` | `pendiente_revision` |
| `pendiente_revision` | `devuelto`, `aprobado_supervisor` |
| `devuelto` | `en_analisis` |
| `aprobado_supervisor` | `listo_para_cliente` |
| `listo_para_cliente` | `cerrado` |
| `cerrado` | (ninguno) |

**Implementada en**: `caso-estado.constants.ts` → `TRANSICIONES_VALIDAS`

**Permisos por perfil**: `PERMISOS_TRANSICION` con 7 transiciones definidas.

---

## Guardas implementadas

| Transición | Guardas | Estado |
|---|---|---|
| borrador → en_analisis | radicado, cliente_id, delito_imputado, etapa_procesal | ✅ |
| en_analisis → pendiente_revision | checklist sin críticos incompletos, estrategia con línea, hechos > 0 | ✅ |
| pendiente_revision → devuelto | observaciones no vacías | ✅ |
| pendiente_revision → aprobado_supervisor | observaciones no vacías, revisión vigente existe | ✅ |
| devuelto → en_analisis | al menos una revisión existe | ✅ |
| aprobado_supervisor → listo_para_cliente | conclusión completa (5 bloques), recomendación, checklist | ✅ |
| listo_para_cliente → cerrado | decisión_cliente documentada | ✅ |

---

## Códigos de respuesta del endpoint

| Código | Significado | Implementación |
|---|---|---|
| `200` | Transición aplicada | retorno normal |
| `403` | Perfil sin permiso | `ForbiddenException` |
| `404` | Caso no existe | `NotFoundException` |
| `409` | Transición inválida | `ConflictException` |
| `422` | Guardas no cumplidas | `UnprocessableEntityException` |

---

## Índice parcial para revision_supervisor

**Decisión**: Implementar como raw SQL en migración inicial.

```sql
CREATE UNIQUE INDEX revision_supervisor_vigente_unico
ON revision_supervisor (caso_id)
WHERE vigente = true;
```

**Estado**: Pendiente de agregar al archivo de migración cuando se ejecute `prisma migrate dev`.

---

## Ajustes adicionales aplicados

### Enums sincronizados

Se agregaron a `src/types/enums.ts`:
- `CategoriaDocumento` (8 valores)
- `TipoEvento` (7 valores)

Ahora sincronizado con `schema.prisma` (19 enums en ambos).

---

## Pendientes menores (no bloquean cierre)

| Pendiente | Prioridad | Descripción |
|---|---|---|
| Ítems de checklist por bloque | P2 | Definir ítems específicos del U008 |
| Índice parcial en migración | P2 | Agregar SQL al migrar |
| Tests unitarios | P2 | Cubrir cada combinación estado/perfil/guarda |

---

## Ajustes finos aplicados (revisión final)

| # | Ajuste | Implementación |
|---|---|---|
| 1 | Idempotencia en `generarEstructuraBase()` | Verifica existencia antes de crear cada registro |
| 2 | 404 explícito en `verificarEscritura()` | Documentado y estructurado con error code |
| 3 | Dependencia circular ChecklistService | Nota en header: usar consultas Prisma directas, no inyectar servicio |
| 4 | Persistencia de observaciones | Método `persistirRevisionSupervisor()` crea registro en transición |

---

## Decisión de cierre

**AUD-02 se declara CERRADO.**

El servicio CasoEstadoService está estructurado con:
- Decisión arquitectónica explícita (servicio separado)
- Responsabilidades documentadas y mapeadas a métodos
- R08 y R09 implementadas
- Punto único de transición definido
- Matriz de transiciones y permisos completa
- Guardas por transición implementadas
- Códigos de error alineados con ADR-003

---

## Control de cambios

**Fecha**: 2026-03-08  
**Responsable propuesta**: Claude  
**Responsable decisión**: Paul  
**Documento relacionado**: AUDITORIA_SCAFFOLD_LEX_PENAL_v1.2.md, ADR-003, R08, R09

### Historial
- **v1.0**: propuesta y verificación de cierre inicial
- **v1.1**: ajustes finos:
  - idempotencia en `generarEstructuraBase()`
  - 404 explícito en `verificarEscritura()`
  - nota de wiring para evitar dependencia circular
  - método `persistirRevisionSupervisor()` para flujo de observaciones
