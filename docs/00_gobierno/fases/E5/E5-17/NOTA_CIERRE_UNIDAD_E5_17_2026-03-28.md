# NOTA DE CIERRE UNIDAD E5-17 — 2026-03-28

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Consolidación
- Unidad: E5-17 — Alineación contractual y validación runtime de checklist
- Fecha de cierre: 2026-03-28
- Estado: CERRADA

## 2. Objetivo de la unidad
Alinear el contrato API del recurso `checklist` con la implementación vigente y validar en runtime su estructura jerárquica, el bootstrap al activar el caso, la actualización de ítems, el recálculo automático de bloques y los controles de acceso.

## 3. Alcance ejecutado
Durante la unidad E5-17 se ejecutaron las siguientes acciones:

1. Se revisó la superficie funcional real del recurso `checklist`.
2. Se confirmó la existencia de dos endpoints operativos:
   - `GET /api/v1/cases/{caseId}/checklist`
   - `PUT /api/v1/cases/{caseId}/checklist`
3. Se verificó la estructura jerárquica real del checklist por caso.
4. Se confirmó que el bootstrap del checklist se ejecuta al activar el caso (`borrador -> en_analisis`).
5. Se validó la actualización de ítems mediante `PUT /checklist`.
6. Se validó el recálculo automático de `bloque.completado`.
7. Se ejecutó validación runtime mediante `test_e5_17.sh`.
8. Se verificó compilación satisfactoria con `npm run build`.

## 4. Estructura validada
La validación confirmó la siguiente estructura funcional real del checklist:

| Aspecto | Valor |
|--------|-------|
| Bloques | 12 (`B01` a `B12`) |
| Items | 12 (1 por bloque) |
| Bootstrap | Al activar caso (`borrador -> en_analisis`) |
| Fuente operativa | `caso-estado.service` + `caso-estado.constants` |
| Recálculo | `PUT /checklist` recalcula `bloque.completado` |

## 5. Lectura funcional confirmada
La validación confirmó que el recurso `checklist` opera con los siguientes comportamientos:

- el checklist se expone como una estructura jerárquica `bloques -> items`
- el bootstrap real se ejecuta al activar el caso
- cada caso recibe 12 bloques y 12 items
- `PUT /checklist` actualiza ítems mediante un array de `{ id, marcado }`
- si un bloque queda con todos sus ítems marcados, `bloque.completado` se recalcula automáticamente
- item inexistente responde `400`
- caso inexistente responde `404`
- acceso sin token responde `401`
- estudiante ajeno al caso responde `403`

## 6. Alineación contractual
El contrato del recurso `checklist` quedó alineado con la implementación real, incorporando:

- estructura jerárquica documentada
- bootstrap en activación del caso
- formato del DTO de actualización
- recálculo automático de `bloque.completado`
- tabla de códigos:
  - `200`
  - `400`
  - `401`
  - `403`
  - `404`

## 7. Evidencia de validación runtime
Resultado de ejecución del script `test_e5_17.sh`:

- Pruebas pasadas: **12**
- Pruebas fallidas: **0**
- Resultado general: **VALIDACIÓN SATISFACTORIA**

### Cobertura validada
1. Login de administrador
2. Creación de cliente
3. Creación de caso
4. Activación de caso con bootstrap de checklist
5. `GET /checklist` con estructura válida
6. `PUT /checklist` marcando ítem
7. `GET /checklist` reflejando cambios y completado
8. `PUT /checklist` con ítem inexistente
9. `GET /checklist` con caso inexistente
10. `GET /checklist` sin token
11. `GET /checklist` por estudiante ajeno
12. `PUT /checklist` por estudiante ajeno

## 8. Deuda técnica registrada
Se identificó la siguiente deuda técnica no bloqueante:

| Componente | Estado |
|-----------|--------|
| `ChecklistRepository.createBaseStructure()` | Vestigial (3 bloques + 6 items) |
| `ChecklistService.bootstrapIfNeeded()` | Ruta secundaria no usada |
| Ruta operativa real | `CasoEstadoService.generarEstructuraBase()` |

**Acción futura recomendada:** eliminar o alinear el código vestigial del módulo `checklist` para evitar divergencias entre implementación secundaria y ruta operativa real.

## 9. Validación de build
Se ejecutó `npm run build` al cierre de la unidad con resultado satisfactorio.

Estado:
- **Build verde**
- **Sin errores de compilación**

## 10. Resultado de la unidad
La unidad E5-17 queda cerrada satisfactoriamente porque:

- el contrato API del recurso `checklist` quedó alineado con la implementación real
- la estructura jerárquica real quedó validada
- el bootstrap en activación quedó validado
- el recálculo automático de bloques quedó validado
- los controles de acceso quedaron verificados
- la compilación del proyecto cerró en verde

## 11. Conclusión de cierre
Se declara **CERRADA** la unidad **E5-17 — Alineación contractual y validación runtime de checklist**.

El recurso `checklist` queda consolidado en esta etapa con:
- contrato alineado
- estructura real validada
- bootstrap validado
- recálculo automático validado
- controles de acceso verificados
- build satisfactorio
- evidencia trazable de cierre

## 12. Estado actualizado del tramo
| Unidad | Módulo | Estado |
|-------|--------|--------|
| E5-09 | subjects | ✅ |
| E5-10 | proceedings | ✅ |
| E5-11 | conclusion | ✅ |
| E5-12 | client-briefing | ✅ |
| E5-13 | reports | ✅ |
| E5-14 | risks | ✅ |
| E5-15 | review | ✅ |
| E5-16 | conclusion (runtime) | ✅ |
| E5-17 | checklist | ✅ |
