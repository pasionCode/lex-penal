# CHECKLIST DE APERTURA — UNIDAD E5-02

## 1. Identificación

| Campo | Valor |
|-------|-------|
| Proyecto | LEX_PENAL |
| Fase | E5 — Consolidación / expansión controlada |
| Unidad | E5-02 |
| Nombre | Bloque A: Núcleo del caso |
| Fecha de apertura | 2026-03-27 |
| Estado | ABIERTA |
| Precedente | E5-01 (baseline y replanificación) |

---

## 2. Objetivo

Cerrar el núcleo funcional del caso: implementar el módulo faltante y validar los subrecursos parciales hasta tener un flujo de caso completo y probado.

---

## 3. Alcance permitido

| Módulo | Acción |
|--------|--------|
| clients | Implementar CRUD mínimo |
| strategy | Pruebas runtime |
| timeline | Pruebas runtime + paginación |
| checklist | Pruebas runtime |
| client-briefing | Pruebas runtime |
| conclusion | Pruebas runtime |
| Integración | Smoke test flujo caso completo |

---

## 4. Alcance prohibido

| Módulo/Tema | Razón |
|-------------|-------|
| review | Bloque B |
| reports | Bloque C |
| ai | Bloque C |
| audit | Bloque C |
| BUG-001 encoding | Bloque C |
| Refactor transversal | Fuera de foco |

---

## 5. Secuencia de pasos

| Paso | Descripción |
|------|-------------|
| 1 | Apertura + regularización mínima del baseline |
| 2 | Implementación y validación del Bloque A |
| 3 | Cierre del Bloque A + decisión del Bloque B |

---

## 6. Entregables esperados

| Entregable | Descripción |
|------------|-------------|
| clients funcional | CRUD mínimo implementado y probado |
| Subrecursos validados | strategy, timeline, checklist, client-briefing, conclusion con pruebas runtime |
| Smoke test integrado | Flujo caso completo verificado |
| Nota de cierre | Unidad E5-02 cerrada con evidencia |

---

## 7. Criterios de cierre

- [ ] clients implementado y probado
- [ ] strategy probado runtime
- [ ] timeline probado runtime (+ paginación)
- [ ] checklist probado runtime
- [ ] client-briefing probado runtime
- [ ] conclusion probado runtime
- [ ] Smoke test integrado ejecutado
- [ ] Nota de cierre emitida
- [ ] Bloque B priorizado

---

## 8. Baseline de entrada

| Módulo | Estado entrada | Estado esperado salida |
|--------|----------------|------------------------|
| clients | ⏳ Pendiente | ✅ Cerrado |
| strategy | ⚠️ Parcial | ✅ Cerrado |
| timeline | ⚠️ Parcial | ✅ Cerrado |
| checklist | ⚠️ Parcial | ✅ Cerrado |
| client-briefing | ⚠️ Parcial | ✅ Cerrado |
| conclusion | ⚠️ Parcial | ✅ Cerrado |

---

## 9. Juicio metodológico

Esta unidad marca el paso de micro-sprints a bloques amplios. El foco es cerrar el núcleo del caso en una sola unidad cohesiva, no en 6 sprints separados.

---

*Checklist generado: 2026-03-27*
