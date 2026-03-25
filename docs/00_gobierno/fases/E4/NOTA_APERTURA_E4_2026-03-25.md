# NOTA DE APERTURA — FASE E4

## 1. Identificación

- **Proyecto:** LEX_PENAL
- **Fase:** E4 — Consolidación post-MVP
- **Fecha de apertura:** 2026-03-25
- **Estado:** ABIERTO
- **Precedente:** E3.5 (Sprint 7 — Testing de guerrilla)

---

## 2. Contexto de entrada

### 2.1 Estado de fases

| Etapa | Estado | Descripción |
|-------|--------|-------------|
| E1 | ✅ CERRADA | Estructuración y línea base canónica |
| E2 | ✅ CERRADA | Gobierno, arquitectura y modelo de datos |
| E3 | ✅ CERRADA | Construcción MVP (15/15 módulos) |
| E3.5 | ✅ CERRADA | Testing de guerrilla (Sprint 7) |
| E4 | 🔄 EN CURSO | Consolidación post-MVP |

### 2.2 Evidencia de entrada

Sprint 7 ejecutó testing de guerrilla sobre caso existente:
- 13/15 módulos con validación directa
- 2/15 módulos con validación indirecta (users, clients)
- Pruebas negativas 400/401/404 correctas
- Naturaleza append-only verificada (timeline, review)
- 1 bug mayor encontrado (BUG-001: encoding UTF-8)
- 7 hallazgos de revisión estática priorizados

---

## 3. Principio rector de E4

> **E4 no es construir más. Es revisar arquitectura y contrato con evidencia real de Sprint 7.**

### 3.1 Permitido

- Correcciones de bugs encontrados en E3.5
- Alineación contrato-modelo-código
- Consolidación de enums y tipos
- Limpieza de código muerto
- Endurecimiento de validaciones con evidencia real
- Precisión de mensajes de error

### 3.2 Prohibido

- Nuevas funcionalidades
- Nuevos módulos
- Cambios de arquitectura sin incidente documentado
- Refactors amplios sin evidencia de necesidad

---

## 4. Alcance de E4

### 4.1 Objetivo principal

Dejar el MVP arquitectónicamente sólido antes de:
- testing de aceptación con usuarios reales, o
- despliegue a producción, o
- extensión funcional (Fase 2)

### 4.2 Entregables esperados

| # | Entregable | Descripción |
|---|------------|-------------|
| 1 | Backlog E4 | Lista priorizada de ajustes derivados de Sprint 7 |
| 2 | Correcciones | Bugs y hallazgos críticos/mayores resueltos |
| 3 | Alineación | Contrato API v5 sincronizado con código real |
| 4 | Limpieza | Código muerto eliminado, enums consolidados |
| 5 | Nota de cierre | Documentación formal de E4 |

---

## 5. Hallazgos heredados de Sprint 7

### 5.1 Bugs

| ID | Severidad | Descripción | Prioridad E4 |
|----|-----------|-------------|--------------|
| BUG-001 | 🟠 Mayor | Encoding UTF-8 corrupto en `etapa_procesal` | **Alta** |

### 5.2 Hallazgos de revisión estática

| ID | Severidad | Descripción | Prioridad E4 |
|----|-----------|-------------|--------------|
| H-002 | 🟠 Mayor | `/proceedings` en contrato, NO implementado | Media |
| H-003 | 🟡 Menor | Actuacion y Documento sin endpoints MVP | Baja |
| H-004 | 🟡 Menor | `RolesGuard` stub no implementado | Media |
| H-005 | 🟡 Menor | HttpExceptionFilter campos extra no documentados | Baja |
| H-006 | 🟠 Mayor | HerramientaIA kebab vs snake_case | **Alta** |
| H-007 | 🟠 Mayor | 12 enums duplicados | Media |
| H-008 | 🟡 Menor | `TransitionCaseDto` código muerto | Media |

### 5.3 Deuda técnica arrastrada

| ID | Descripción | Origen | Prioridad E4 |
|----|-------------|--------|--------------|
| DT-001 | Unificar `message` vs `mensaje` | Sprint 2 | Media |
| DT-002 | Encoding UTF-8 (confirmado como BUG-001) | Sprint 5 | **Alta** |
| DT-007 | AI module simplificado | Sprint 6 | Baja |
| DT-008 | Encoding UTF-8 respuesta AI | Sprint 6 | Media |

---

## 6. Criterios de salida de E4

E4 puede cerrarse cuando se cumplan todos los siguientes:

- [ ] **Contrato alineado:** CONTRATO_API v5 refleja comportamiento real del código
- [ ] **Bugs mayores resueltos:** BUG-001 (encoding) corregido y verificado
- [ ] **Hallazgos mayores priorizados cerrados:** H-006 (HerramientaIA) alineado
- [ ] **Enums consolidados:** Una sola fuente de verdad para enums compartidos
- [ ] **Código muerto eliminado:** RolesGuard, TransitionCaseDto revisados
- [ ] **API consistente:** Respuestas de error uniformes y documentadas
- [ ] **Sin deuda estructural relevante:** DT-001 y DT-002 resueltas; DT-007 y DT-008 cerradas o reclasificadas formalmente fuera del alcance de E4

---

## 7. Riesgos de E4

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Scope creep (añadir features) | Media | Alto | Regla rectora: solo correcciones con evidencia |
| Corrección introduce regresión | Baja | Alto | Testing de cada corrección antes de merge |
| Tiempo excesivo en E4 | Media | Medio | Timeboxing: máximo 3 sprints, con consolidación anticipada si el volumen real es menor |

---

## 8. Plan de ejecución

E4 se estructura en sprints cortos de corrección:

| Sprint | Foco | Items |
|--------|------|-------|
| Sprint 8 | Críticos | BUG-001, H-006, DT-002 |
| Sprint 9 | Consolidación | H-007, H-004, H-008, DT-001 |
| Sprint 10 | Alineación documental | Contrato v5, hallazgos menores |

> **Nota:** Los sprints pueden consolidarse si el volumen de trabajo es menor al estimado.

---

**Fase E4 ABIERTA — 2026-03-25**
