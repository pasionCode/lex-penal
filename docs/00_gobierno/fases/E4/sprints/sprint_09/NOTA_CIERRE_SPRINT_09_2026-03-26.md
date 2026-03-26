# NOTA DE CIERRE SPRINT 09 — 2026-03-26

## 1. Identificación

- **Proyecto:** LEX_PENAL
- **Fase:** E4 — Consolidación post-MVP
- **Sprint:** Sprint 9
- **Fecha de cierre:** 2026-03-26
- **Estado:** CERRADO

---

## 2. Objetivo del sprint

Consolidar consistencia interna del backend, eliminando duplicidades, código muerto e inconsistencias de respuesta, sin ampliar alcance funcional del MVP.

**Regla rectora aplicada:** Primero consolidar código y respuestas; después decidir qué pasa al ajuste documental mayor.

---

## 3. Baseline verificado

| Verificación | Estado |
|--------------|--------|
| Repositorio limpio | ✅ `up to date with origin/main` |
| Build | ✅ `nest build` exitoso |
| Servidor | ✅ Operativo en puerto 3001 |
| Login | ✅ Token JWT obtenido |

---

## 4. Correcciones aplicadas

### 4.1 H-007 — Enums duplicados

**Problema:** 12 enums duplicados entre `src/types/enums.ts` y DTOs individuales.

**Solución aplicada:**
- Consolidados todos los enums en `src/types/enums.ts` (ubicación canónica)
- Eliminados enums locales de 6 DTOs
- Actualizados imports en DTOs y services
- Corregido `HerramientaIA` de kebab-case a snake_case (alineación con Sprint 8)

**Archivos modificados:**
- `src/types/enums.ts`
- `src/modules/ai/dto/ai-query.dto.ts`
- `src/modules/evidence/dto/create-evidence.dto.ts`
- `src/modules/evidence/dto/update-evidence.dto.ts`
- `src/modules/facts/dto/create-fact.dto.ts`
- `src/modules/facts/dto/update-fact.dto.ts`
- `src/modules/reports/dto/generate-report.dto.ts`
- `src/modules/review/dto/create-review.dto.ts`
- `src/modules/risks/dto/create-risk.dto.ts`
- `src/modules/risks/dto/update-risk.dto.ts`
- `src/modules/risks/risks.service.ts`

**Verificación:**
```bash
grep -rn "^export enum" src/modules/
# Resultado: ninguno (OK)
```

**Estado:** ✅ Cerrado

---

### 4.2 H-004 — RolesGuard stub

**Problema:** Guard con `throw new Error('not implemented')` que no se usaba.

**Solución:** Eliminado `src/common/guards/roles.guard.ts`

**Verificación:**
```bash
grep -Rni "RolesGuard" src
# Resultado: ninguno (OK)
```

**Estado:** ✅ Cerrado

---

### 4.3 H-008 — TransitionCaseDto muerto

**Problema:** DTO definido pero no usado (controller usa `TransitionStateDto`).

**Solución:** Eliminado `src/modules/cases/dto/transition-case.dto.ts`

**Verificación:**
```bash
grep -Rni "TransitionCaseDto" src
# Resultado: ninguno (OK)
```

**Estado:** ✅ Cerrado

---

### 4.4 DT-001 — message vs mensaje

**Problema:** Posible inconsistencia entre `message` y `mensaje` en respuestas.

**Análisis:**
- `HttpExceptionFilter` usa `mensaje` (español) ✅
- Contrato API documenta `mensaje` ✅
- Runtime devuelve `mensaje` ✅
- Los `message` en DTOs son parámetros de class-validator, no respuestas HTTP

**Conclusión:** Ya estaba alineado. No requirió cambios.

**Estado:** ✅ Verificado

---

### 4.5 DT-008 — Encoding placeholder AI

**Problema:** Posibles caracteres corruptos en respuesta del módulo IA.

**Verificación:**
```bash
curl -s -X POST ".../ai/query" -d '{"herramienta":"basic_info","consulta":"Resumen breve"}'
# Respuesta: "Análisis de basic_info..." (tilde correcta)
```

**Conclusión:** Encoding funciona correctamente. El problema anterior era la codificación de Git Bash al enviar UTF-8.

**Estado:** ✅ Verificado

---

### 4.6 H-002 — /proceedings documentado pero no implementado

**Problema:** Contrato documenta endpoints que no existen en el backend.

**Solución:** Agregada nota de implementación en contrato:

```markdown
> **⚠️ Nota de implementación:** Los endpoints `/api/v1/cases/{id}/proceedings` 
> se encuentran reservados para desarrollo post-MVP y no están implementados 
> en el backend actual.
```

**Estado:** ✅ Cerrado

---

## 5. Pruebas de regresión

| Módulo | Verificación | Estado |
|--------|--------------|--------|
| cases | GET /cases | ✅ 3 casos |
| timeline | GET /cases/{id}/timeline | ✅ Eventos devueltos |
| review | GET /cases/{id}/review | ✅ Revisiones devueltas |
| reports | POST /cases/{id}/reports | ✅ Informe generado |
| ai | POST /ai/query | ✅ Respuesta con encoding OK |

**Conclusión:** Sin regresiones observadas.

---

## 6. Artefactos modificados

| Tipo | Artefacto | Cambio |
|------|-----------|--------|
| Código | 11 archivos DTO/service | Imports consolidados |
| Código | `src/common/guards/roles.guard.ts` | Eliminado |
| Código | `src/modules/cases/dto/transition-case.dto.ts` | Eliminado |
| Contrato | `docs/04_api/CONTRATO_API_v4.md` | Nota post-MVP en /proceedings |

**Estadísticas:** 14 archivos, +16/-134 líneas (limpieza neta)

---

## 7. Commits del sprint

| Hash | Mensaje |
|------|---------|
| 80c9358 | refactor: cierra Sprint 9 con limpieza interna y contrato alineado |

---

## 8. Criterios de cierre cumplidos

- [x] H-007: Enums consolidados en ubicación única
- [x] H-004: RolesGuard stub eliminado
- [x] H-008: TransitionCaseDto eliminado
- [x] DT-001: Convención `mensaje` verificada
- [x] DT-008: Encoding IA verificado
- [x] H-002: /proceedings marcado como post-MVP
- [x] Sin regresión visible
- [x] Build limpio
- [x] Repositorio sincronizado

---

## 9. Estado de E4 post-Sprint 9

| Prioridad | Total | Cerrados | Diferidos |
|-----------|-------|----------|-----------|
| Alta | 3 | 3 ✅ | 0 |
| Media | 6 | 6 ✅ | 0 |
| Baja | 3 | 0 | 3 |

### Items diferidos a Fase 2

| ID | Descripción | Recomendación |
|----|-------------|---------------|
| H-003 | Actuacion/Documento sin endpoints | Diferir a Fase 2 |
| H-005 | HttpExceptionFilter campos extra | Documentar o diferir |
| DT-007 | AI module simplificado | Diferir a Fase 2 |

---

## 10. Decisión de continuidad

**Sprint 9 cerrado satisfactoriamente.**

Los hallazgos de prioridad alta y media de E4 están resueltos. Los 3 items de prioridad baja son mejoras de higiene que no afectan funcionalidad ni mantenibilidad crítica.

**Recomendación:** Cerrar E4 con Sprint 9. Los items de prioridad baja pueden reclasificarse como backlog de Fase 2 o abordarse en un Sprint 10 corto si se considera necesario antes de pasar a producción.

---

**Sprint 09 CERRADO — 2026-03-26**
