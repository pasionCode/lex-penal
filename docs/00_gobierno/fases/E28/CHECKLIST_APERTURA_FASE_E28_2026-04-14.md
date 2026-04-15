# CHECKLIST APERTURA FASE E28 — 2026-04-14

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E28
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la fase
Consolidar funcionalmente el módulo de Risks del backend, verificando y alineando contrato, implementación, reglas de acceso, semántica de colección editable, regla de prioridad crítica, control por estado y comportamiento observable.

## 3. Justificación
Las fases previas consolidaron Facts y Evidence. Risks es el siguiente frente natural por pertenecer al mismo bloque de recursos editables del caso y por incorporar una regla de negocio material: cuando `prioridad = critica`, `estrategia_mitigacion` debe ser obligatoria.

## 4. Alcance inicial
- Baseline real del módulo Risks.
- Revisión contractual de endpoints, enums y regla de prioridad crítica.
- Inventario técnico del módulo.
- Identificación de brechas semánticas, contractuales o de validación.
- Selección de un ajuste funcional mínimo y trazable.

## 5. Exclusiones iniciales
- No se reabre toda la máquina de estados salvo necesidad estricta.
- No se mezcla este bloque con transiciones salvo dependencia directa.
- No se altera infraestructura.

## 6. Baseline de arranque
- Rama base: `main`
- Commit base: `a5e2877`
- Referencia inmediata anterior: cierre formal fase E27

## 7. Riesgos iniciales
- Contrato e implementación desalineados en la regla de prioridad crítica.
- Ausencia de control por estado del caso en operaciones de escritura.
- Riesgo de fuga entre casos o validación insuficiente de ownership.
- Dispersión hacia otros módulos sin evidencia suficiente.

## 8. Unidad inicial
- E28-01 — Baseline funcional del módulo Risks

## 9. Criterios de salida de fase
- Baseline funcional suficiente del módulo Risks.
- Brecha priorizada y delimitada.
- Ajuste funcional mínimo ejecutado bajo MDS.
- Cierre documental por unidad y cierre formal de fase.

## 10. Estado
- Fase abierta formalmente.
