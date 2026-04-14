# CHECKLIST APERTURA FASE E20 — 2026-04-14

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E20
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la fase
Consolidar funcionalmente el módulo de Reports del backend, verificando y alineando contrato, implementación, reglas de negocio, semántica de acceso, idempotencia y comportamiento observable.

## 3. Justificación
Las fases E17 a E19 retomaron el backlog funcional y consolidaron módulos concretos bajo MDS. Reports representa un frente de producto visible y de alto valor, apto para una consolidación funcional específica sin dispersión excesiva.

## 4. Alcance inicial
- Baseline real del módulo Reports.
- Revisión contractual de endpoints, tipos, formatos e idempotencia.
- Inventario técnico del módulo.
- Identificación de brechas semánticas, contractuales o de validación.
- Selección de un ajuste funcional mínimo y trazable.

## 5. Exclusiones iniciales
- No se rediseña el sistema completo de generación documental.
- No se abre integración nueva de PDF/DOCX fuera del alcance existente.
- No se mezcla este bloque con Review, IA u otros módulos salvo dependencia estricta.

## 6. Baseline de arranque
- Rama base: `main`
- Commit base: `341af61`
- Referencia inmediata anterior: cierre formal fase E19

## 7. Riesgos iniciales
- Contrato e implementación desalineados en tipos, formatos o idempotencia.
- Reglas de acceso insuficientemente explícitas.
- Semántica de generación y reutilización de informes ambigua.
- Dispersión hacia módulos contiguos del flujo del caso.

## 8. Unidad inicial
- E20-01 — Baseline funcional del módulo Reports

## 9. Criterios de salida de fase
- Baseline funcional suficiente del módulo Reports.
- Brecha priorizada y delimitada.
- Ajuste funcional mínimo ejecutado bajo MDS.
- Cierre documental por unidad y cierre formal de fase.

## 10. Estado
- Fase abierta formalmente.
