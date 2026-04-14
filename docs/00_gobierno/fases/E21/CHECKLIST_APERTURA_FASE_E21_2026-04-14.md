# CHECKLIST APERTURA FASE E21 — 2026-04-14

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E21
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la fase
Consolidar funcionalmente el módulo de Review del backend, verificando y alineando contrato, implementación, reglas de acceso, semántica de revisión vigente, versionado y acoplamiento con el flujo del caso.

## 3. Justificación
Las fases E17 a E20 consolidaron módulos funcionales ya visibles del producto. Review representa un frente crítico porque impacta directamente el circuito de validación del caso, la devolución/aprobación del supervisor y la trazabilidad del proceso.

## 4. Alcance inicial
- Baseline real del módulo Review.
- Revisión contractual de endpoints y reglas.
- Inventario técnico del módulo.
- Identificación de brechas semánticas, contractuales o de validación.
- Selección de un ajuste funcional mínimo y trazable.

## 5. Exclusiones iniciales
- No se reabre toda la máquina de estados salvo necesidad estricta.
- No se mezcla este bloque con Reports, Subjects o IA salvo dependencia directa.
- No se altera infraestructura.

## 6. Baseline de arranque
- Rama base: `main`
- Commit base: `72a8a5a`
- Referencia inmediata anterior: cierre formal fase E20

## 7. Riesgos iniciales
- Contrato e implementación desalineados en acceso o semántica.
- Reglas ambiguas sobre review vigente, historial y resultado.
- Acoplamiento incompleto con estado del caso.
- Dispersión hacia transiciones del caso sin evidencia suficiente.

## 8. Unidad inicial
- E21-01 — Baseline funcional del módulo Review

## 9. Criterios de salida de fase
- Baseline funcional suficiente del módulo Review.
- Brecha priorizada y delimitada.
- Ajuste funcional mínimo ejecutado bajo MDS.
- Cierre documental por unidad y cierre formal de fase.

## 10. Estado
- Fase abierta formalmente.
