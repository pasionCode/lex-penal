# Registro de Desviaciones — LEX_PENAL

**Documento:** Registro centralizado de desviaciones metodológicas  
**Versión:** 1.1  
**Última actualización:** 2026-03-23

---

## Índice de Desviaciones

| ID | Título | Fecha | Estado |
|----|--------|-------|--------|
| DESV-001 | Prefijos duplicados y código diferido | 2026-03-22 | **CERRADA** |

---

# DESV-001 — Prefijos duplicados y código diferido

**Proyecto:** LEX_PENAL  
**Fecha apertura:** 2026-03-22  
**Fecha cierre:** 2026-03-23  
**Estado:** CERRADA

---

## 1. Título

Desviación metodológica por mezcla de código de dominio en etapa declarada como scaffold y duplicación de prefijos de rutas API.

---

## 2. Descripción del hecho

Durante la auditoría J08-A del repositorio se constató:

1. Presencia de lógica de negocio en `src/modules/cases/services/caso-estado.service.ts` dentro de un tramo históricamente descrito como scaffold o infraestructura.

2. Coexistencia de `app.setGlobalPrefix('api/v1')` en `src/main.ts` con controllers que vuelven a declarar `api/v1/...`.

---

## 3. Contexto

La Jornada 07 reconoció la duplicación de prefijos como deuda técnica conocida. Sin embargo, dicha deuda no fue absorbida completamente por el circuito formal del método mediante registro autónomo de desviación, condición de levantamiento o saneamiento previo al siguiente sprint.

---

## 4. Impacto

### 4.1 Impacto técnico

- Riesgo de rutas duplicadas `/api/v1/api/v1/...`
- Desalineación entre contrato API y código
- Riesgo de pruebas inválidas

### 4.2 Impacto metodológico

- Debilita el principio de código diferido
- Permite cierre de jornada con tensión no completamente regularizada
- Genera riesgo de falsa conformidad

---

## 5. Causa probable

- Racionalización de código de dominio como scaffold
- Continuidad del sprint con deuda técnica reconocida pero no formalizada como desviación
- Falta de regla explícita anti-falsa conformidad en el MDS

---

## 6. Corrección requerida

1. Mantener prefijo global en `src/main.ts`
2. Remover `api/v1/` de todos los decorators `@Controller(...)` que lo repiten
3. Emitir ADR-009 de convención de rutas
4. Actualizar contrato API
5. Reforzar MDS con regla expresa sobre deuda técnica que afecta gates, rutas, contrato o pruebas

---

## 7. Acción preventiva

A partir de esta desviación, ninguna jornada podrá cerrarse con deuda técnica que afecte contrato, rutas, pruebas o habilitación de gate sin:

- Registro formal de desviación
- Impacto documentado
- Responsable asignado
- Prioridad establecida
- Condición de saneamiento definida

---

## 8. Cierre

### 8.1 Acciones ejecutadas

| # | Acción | Fecha | Evidencia |
|---|--------|-------|-----------|
| 1 | Remover prefijo `api/v1` de 14 controllers | 2026-03-23 | `git diff src/modules/` |
| 2 | Emitir ADR-009 | 2026-03-22 | `docs/00_gobierno/adrs/ADR-009-*.md` |
| 3 | Actualizar CONTRATO_API_v4 convenciones | 2026-03-23 | `docs/04_api/CONTRATO_API_v4.md` |
| 4 | Alinear contrato con implementación real | 2026-03-23 | `access_token`, `user` |
| 5 | Corregir smoke tests | 2026-03-23 | `tests/e2e/smoke.sh`, `tests/e2e/smoke.ps1`, `scripts/linux/smoke.sh`, `scripts/windows/smoke.ps1` |
| 6 | MDS v2.2 §10.2.2 regla de deuda sensible | 2026-03-22 | MDS actualizado |

### 8.2 Controllers corregidos (14)

| Módulo | Archivo | Antes | Después |
|--------|---------|-------|---------|
| ai | `ai.controller.ts` | `@Controller('api/v1/ai')` | `@Controller('ai')` |
| audit | `audit.controller.ts` | `@Controller('api/v1/cases/:caseId/audit')` | `@Controller('cases/:caseId/audit')` |
| cases | `cases.controller.ts` | `@Controller('api/v1/cases')` | `@Controller('cases')` |
| checklist | `checklist.controller.ts` | `@Controller('api/v1/cases/:caseId/checklist')` | `@Controller('cases/:caseId/checklist')` |
| client-briefing | `client-briefing.controller.ts` | `@Controller('api/v1/cases/:caseId/client-briefing')` | `@Controller('cases/:caseId/client-briefing')` |
| clients | `clients.controller.ts` | `@Controller('api/v1/clients')` | `@Controller('clients')` |
| conclusion | `conclusion.controller.ts` | `@Controller('api/v1/cases/:caseId/conclusion')` | `@Controller('cases/:caseId/conclusion')` |
| evidence | `evidence.controller.ts` | `@Controller('api/v1/cases/:caseId/evidence')` | `@Controller('cases/:caseId/evidence')` |
| facts | `facts.controller.ts` | `@Controller('api/v1/cases/:caseId/facts')` | `@Controller('cases/:caseId/facts')` |
| reports | `reports.controller.ts` | `@Controller('api/v1/cases/:caseId/reports')` | `@Controller('cases/:caseId/reports')` |
| review | `review.controller.ts` | `@Controller('api/v1/cases/:caseId/review')` | `@Controller('cases/:caseId/review')` |
| risks | `risks.controller.ts` | `@Controller('api/v1/cases/:caseId/risks')` | `@Controller('cases/:caseId/risks')` |
| strategy | `strategy.controller.ts` | `@Controller('api/v1/cases/:caseId')` | `@Controller('cases/:caseId')` |
| strategy | `timeline.controller.ts` | `@Controller('api/v1/cases/:caseId/timeline')` | `@Controller('cases/:caseId/timeline')` |

### 8.3 Verificación final

```
✓ grep "@Controller('api/v1" src/modules/ → 0 coincidencias
✓ npm run build → exitoso
✓ ./tests/e2e/smoke.sh → SMOKE TEST COMPLETADO
✓ POST /api/v1/auth/login + GET /api/v1/users/me → exitoso
```

### 8.4 Responsable de cierre

**Pablo Jaramillo** — 2026-03-23

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-22 | Apertura por auditoría J08-A |
| 2026-03-22 | Pausa metodológica declarada |
| 2026-03-23 | Saneamiento ejecutado |
| 2026-03-23 | **CIERRE** |
