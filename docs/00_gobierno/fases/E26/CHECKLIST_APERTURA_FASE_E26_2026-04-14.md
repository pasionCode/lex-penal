# CHECKLIST APERTURA FASE E26 — 2026-04-14

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E26
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la fase
Consolidar funcionalmente el módulo de Facts del backend, verificando y alineando contrato, implementación, reglas de acceso, semántica de colección, asignación de orden, mutabilidad y comportamiento observable.

## 3. Justificación
Las fases previas consolidaron singleton y subrecursos críticos. Facts es ahora un frente natural porque participa directamente en la consistencia probatoria del caso y en la guarda funcional para la transición `en_analisis -> pendiente_revision`.

## 4. Alcance inicial
- Baseline real del módulo Facts.
- Revisión contractual de endpoints, orden y mutabilidad.
- Inventario técnico del módulo.
- Identificación de brechas semánticas, contractuales o de validación.
- Selección de un ajuste funcional mínimo y trazable.

## 5. Exclusiones iniciales
- No se reabre toda la máquina de estados salvo necesidad estricta.
- No se mezcla este bloque con Evidence o transiciones salvo dependencia directa.
- No se altera infraestructura.

## 6. Baseline de arranque
- Rama base: `main`
- Commit base: `6a6755f`
- Referencia inmediata anterior: cierre formal fase E25

## 7. Riesgos iniciales
- Contrato e implementación desalineados en orden automático o mutabilidad.
- Reglas ambiguas sobre actualización parcial del hecho.
- Riesgo de fuga entre casos o validación insuficiente de ownership.
- Dispersión hacia Evidence o transiciones sin evidencia suficiente.

## 8. Unidad inicial
- E26-01 — Baseline funcional del módulo Facts

## 9. Criterios de salida de fase
- Baseline funcional suficiente del módulo Facts.
- Brecha priorizada y delimitada.
- Ajuste funcional mínimo ejecutado bajo MDS.
- Cierre documental por unidad y cierre formal de fase.

## 10. Estado
- Fase abierta formalmente.
