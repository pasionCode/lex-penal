# BACKLOG DE AJUSTES — FASE E4

**Proyecto:** LEX_PENAL  
**Fase:** E4 — Consolidación post-MVP  
**Fecha:** 2026-03-25  
**Origen:** Hallazgos de Sprint 7 (E3.5 Testing de guerrilla)

---

## Prioridad Alta

Items que bloquean calidad de producción o generan errores visibles al usuario.

| ID | Tipo | Descripción | Impacto | Acción |
|----|------|-------------|---------|--------|
| BUG-001 | Bug | Encoding UTF-8 corrupto: "Investigación" → "Investigaci�n" | Usuario ve caracteres rotos | Verificar charset en PostgreSQL, Prisma y headers HTTP |
| H-006 | Contrato-Código | HerramientaIA: contrato dice `basic-info` (kebab), DTO acepta `basic_info` (snake) | Request con valores del contrato rechazados con 400 | Decidir convención y alinear contrato + código |
| DT-002 | Deuda técnica | Encoding UTF-8 en respuestas (confirmado como BUG-001) | Mismo que BUG-001 | Consolidar con BUG-001 |

**Criterio de cierre:** Los tres items resueltos y verificados en runtime.

---

## Prioridad Media

Items que afectan mantenibilidad, consistencia o generan confusión técnica.

| ID | Tipo | Descripción | Impacto | Acción |
|----|------|-------------|---------|--------|
| H-007 | Deuda técnica | 12 enums duplicados entre `/types/enums.ts` y DTOs individuales | Riesgo de divergencia, mantenimiento difícil | Consolidar enums en ubicación canónica única |
| H-004 | Código muerto | `RolesGuard` en `/src/common/guards/roles.guard.ts` tiene `throw new Error('not implemented')` | Confusión, no se usa en ningún lado | Eliminar o implementar si se necesita |
| H-008 | Código muerto | `TransitionCaseDto` definido pero no usado (controller usa `TransitionStateDto`) | Confusión, código muerto | Eliminar |
| DT-001 | Deuda técnica | Unificar `message` vs `mensaje` en respuestas de error | Inconsistencia de API | Decidir convención y aplicar |
| DT-008 | Deuda técnica | Encoding UTF-8 en respuesta placeholder AI | Posibles caracteres rotos | Verificar junto con BUG-001 |
| H-002 | Contrato-Código | `/proceedings` documentado en CONTRATO_API_v4 pero NO implementado | Contrato promete algo que no existe | Documentar como "pendiente post-MVP" o eliminar del contrato |

**Criterio de cierre:** Items resueltos o documentados explícitamente como diferidos.

---

## Prioridad Baja

Items de higiene que no afectan funcionalidad ni mantenibilidad crítica.

| ID | Tipo | Descripción | Impacto | Acción |
|----|------|-------------|---------|--------|
| H-003 | Modelo-Código | Modelos `Actuacion` y `Documento` en Prisma sin endpoints MVP | Modelos sin uso actual | Documentar como pendiente Fase 2 |
| H-005 | Contrato-Código | HttpExceptionFilter agrega `statusCode`, `path`, `timestamp` no documentados | Campos extra en respuestas de error | Documentar en contrato o evaluar si eliminar |
| DT-007 | Deuda técnica | AI module simplificado (removidos context builders) | Funcionalidad limitada, aceptable MVP | Documentar para Fase 2 |

**Criterio de cierre:** Items documentados; no requieren corrección inmediata.

---

## Matriz de dependencias

```
BUG-001 ←── DT-002 (mismo issue)
    │
    └── DT-008 (relacionado, verificar junto)

H-006 ←── Decisión de convención snake_case vs kebab-case
    │
    └── Actualización de CONTRATO_API

H-007 ←── Decisión de ubicación canónica de enums
    │
    └── H-006 (HerramientaIA es uno de los enums duplicados)
```

---

## Plan de ejecución sugerido

### Sprint 8 — Críticos (estimado: 1-2 días)

1. **BUG-001 + DT-002 + DT-008:** Resolver encoding UTF-8
   - Verificar `client_encoding` en PostgreSQL
   - Verificar `charset` en headers HTTP de NestJS
   - Probar con datos con tildes y ñ

2. **H-006:** Alinear HerramientaIA
   - Decidir: ¿snake_case en código, kebab-case en contrato? o ¿unificar?
   - Actualizar DTO o contrato según decisión
   - Verificar con curl

### Sprint 9 — Consolidación (estimado: 1-2 días)

3. **H-007:** Consolidar enums
   - Crear `/src/types/enums/index.ts` como fuente única
   - Migrar todos los DTOs a usar esa fuente
   - Eliminar duplicados

4. **H-004 + H-008:** Limpieza de código muerto
   - Eliminar `RolesGuard` si no se usa
   - Eliminar `TransitionCaseDto`

5. **DT-001:** Unificar mensajes de error
   - Decidir: `message` o `mensaje`
   - Aplicar en HttpExceptionFilter y DTOs

### Sprint 10 — Alineación documental (estimado: 1 día)

6. **H-002 + H-003 + H-005:** Actualizar contrato
   - Marcar `/proceedings` como pendiente
   - Documentar campos extra de HttpExceptionFilter
   - Documentar `Actuacion` y `Documento` como Fase 2

7. **CONTRATO_API v5:** Publicar versión alineada

---

## Verificación de cierre

| Criterio | Verificación |
|----------|--------------|
| BUG-001 resuelto | Respuesta JSON con "Investigación" correcta |
| H-006 resuelto | POST /ai/query acepta únicamente la convención oficial definida; contrato, DTO y runtime alineados |
| H-007 resuelto | `grep -r "enum.*Herramienta"` devuelve solo una ubicación |
| Código muerto eliminado | `RolesGuard` y `TransitionCaseDto` no existen |
| Contrato v5 publicado | Archivo `CONTRATO_API_v5.md` en ruta canónica vigente del proyecto |

---

## Notas de ejecución

_Espacio para registrar decisiones y observaciones durante E4_

| Fecha | Decisión/Observación |
|-------|----------------------|
| 2026-03-25 | Backlog creado con base en hallazgos de Sprint 7 |

---

**Backlog E4 ACTIVO — 2026-03-25**
