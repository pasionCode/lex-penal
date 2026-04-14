# CHECKLIST APERTURA FASE E19 — 2026-04-14

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E19
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la fase
Consolidar funcionalmente el módulo de Subjects del backend, verificando y alineando contrato, implementación, reglas de negocio, semántica de acceso y comportamiento observable.

## 3. Justificación
Las fases E17 y E18 reabrieron y estabilizaron el retorno al backlog funcional. El módulo Subjects ya existe en código y contrato, y representa un frente de producto con valor directo y baja dispersión respecto al flujo principal del caso.

## 4. Alcance inicial
- Baseline real del módulo Subjects.
- Revisión contractual de endpoints y reglas.
- Inventario técnico del módulo.
- Identificación de posibles brechas semánticas, contractuales o de validación.
- Selección de un ajuste funcional mínimo y trazable.

## 5. Exclusiones iniciales
- No se abre un rediseño transversal de todos los sujetos procesales del sistema.
- No se mezcla este bloque con revisión, informes u otras superficies salvo dependencia estricta.
- No se altera infraestructura salvo necesidad excepcional.

## 6. Baseline de arranque
- Rama base: `main`
- Commit base: `371d1a7`
- Referencia inmediata anterior: cierre formal fase E18

## 7. Riesgos iniciales
- Contrato y comportamiento real desalineados.
- Reglas de negocio o validaciones insuficientemente explícitas.
- Semántica de acceso ambigua sobre lectura y creación de sujetos.
- Dispersión hacia otros módulos del caso.

## 8. Unidad inicial
- E19-01 — Baseline funcional del módulo Subjects

## 9. Criterios de salida de fase
- Baseline funcional suficiente del módulo Subjects.
- Brecha priorizada y delimitada.
- Ajuste funcional mínimo ejecutado bajo MDS.
- Cierre documental por unidad y cierre formal de fase.

## 10. Estado
- Fase abierta formalmente.
