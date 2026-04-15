# CHECKLIST APERTURA FASE E27 — 2026-04-14

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E27
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la fase
Consolidar funcionalmente el módulo de Evidence del backend, verificando y alineando contrato, implementación, reglas de acceso, semántica de colección editable, vínculo con hechos, unlink, control por estado y comportamiento observable.

## 3. Justificación
Las fases previas consolidaron Facts y otros módulos del caso. Evidence es el siguiente frente natural por su cercanía funcional con Facts y por su semántica más delicada en `link/unlink`, aislamiento entre casos y conflictos `409`.

## 4. Alcance inicial
- Baseline real del módulo Evidence.
- Revisión contractual de endpoints, `link/unlink` y reglas de vínculo.
- Inventario técnico del módulo.
- Identificación de brechas semánticas, contractuales o de validación.
- Selección de un ajuste funcional mínimo y trazable.

## 5. Exclusiones iniciales
- No se reabre toda la máquina de estados salvo necesidad estricta.
- No se mezcla este bloque con Facts o transiciones salvo dependencia directa.
- No se altera infraestructura.

## 6. Baseline de arranque
- Rama base: `main`
- Commit base: `f754afc`
- Referencia inmediata anterior: cierre formal fase E26

## 7. Riesgos iniciales
- Contrato e implementación desalineados en `link/unlink`.
- Riesgo de fuga entre casos en vínculo con hechos.
- Reglas ambiguas sobre control por estado del caso.
- Dispersión hacia Facts o transiciones sin evidencia suficiente.

## 8. Unidad inicial
- E27-01 — Baseline funcional del módulo Evidence

## 9. Criterios de salida de fase
- Baseline funcional suficiente del módulo Evidence.
- Brecha priorizada y delimitada.
- Ajuste funcional mínimo ejecutado bajo MDS.
- Cierre documental por unidad y cierre formal de fase.

## 10. Estado
- Fase abierta formalmente.
