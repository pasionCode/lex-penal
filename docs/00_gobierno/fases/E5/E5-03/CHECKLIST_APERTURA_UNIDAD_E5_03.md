# CHECKLIST DE APERTURA — UNIDAD E5-03

## 1. Identificación

| Campo | Valor |
|-------|-------|
| Proyecto | LEX_PENAL |
| Fase | E5 — Consolidación / expansión controlada |
| Unidad | E5-03 |
| Nombre | Bloque B: Análisis y revisión |
| Fecha de apertura | 2026-03-27 |
| Estado | ABIERTA |
| Precedente | E5-02 (Bloque A cerrado) |

---

## 2. Objetivo

Cerrar el bloque de análisis y revisión del caso, validando el módulo `review` y el flujo de transición entre estudiante y supervisor hasta dejar probado el ciclo: `pendiente_revision → aprobado_supervisor / devuelto → retorno a análisis`.

---

## 3. Alcance permitido

- `review`: pruebas runtime completas
- Flujo de revisión: validar transición a `pendiente_revision`
- Decisión supervisor: validar `aprobado_supervisor` y `devuelto`
- Ciclo de retorno: validar regreso del caso a análisis tras devolución
- Integración: probar ciclo estudiante → supervisor → estudiante

---

## 4. Alcance prohibido

- `reports`
- `ai`
- `audit`
- `BUG-001 encoding`
- Refactor transversal
- Cambios estructurales de contrato no exigidos por runtime

---

## 5. Secuencia de pasos

| Paso | Descripción | Estado |
|------|-------------|--------|
| 1 | Baseline técnico de `review` y flujo de revisión | ⏳ |
| 2 | Validación runtime del Bloque B | 🔒 |
| 3 | Cierre del Bloque B + decisión del Bloque C | 🔒 |

---

## 6. Entregables esperados

| Entregable | Estado |
|------------|--------|
| Baseline de `review` | ⏳ |
| Pruebas runtime de `review` y transiciones | 🔒 |
| Smoke integrado del ciclo estudiante → supervisor → estudiante | 🔒 |
| Nota de cierre de E5-03 | 🔒 |

---

## 7. Criterios de cierre

- [ ] Baseline de `review` levantado
- [ ] `review` validado runtime
- [ ] Transición a `pendiente_revision` validada
- [ ] Decisión `aprobado_supervisor` validada
- [ ] Decisión `devuelto` validada
- [ ] Retorno a análisis validado
- [ ] Smoke del ciclo completo ejecutado
- [ ] Nota de cierre emitida
- [ ] Bloque C priorizado

---

## 8. Juicio metodológico

Esta unidad continúa el modelo de bloques amplios validado en E5-01 y E5-02. El foco es cerrar de forma cohesionada el frente de análisis y revisión antes de pasar a salidas y transversales.

---

*Unidad E5-03 ABIERTA — 2026-03-27*
