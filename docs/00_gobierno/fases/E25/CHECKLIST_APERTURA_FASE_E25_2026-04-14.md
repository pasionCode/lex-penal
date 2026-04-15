# CHECKLIST APERTURA FASE E25 — 2026-04-14

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E25
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la fase
Consolidar funcionalmente el módulo de Checklist del backend, verificando y alineando contrato, implementación, bootstrap estructural, reglas de completitud, acceso y comportamiento observable.

## 3. Justificación
Las fases previas consolidaron los singleton principales y varios subrecursos críticos. Checklist es un frente especialmente sensible porque participa en el bootstrap del caso y en la guarda funcional para la transición `en_analisis -> pendiente_revision`.

## 4. Alcance inicial
- Baseline real del módulo Checklist.
- Revisión contractual de estructura, bootstrap y PUT.
- Inventario técnico del módulo.
- Identificación de brechas semánticas, contractuales o de validación.
- Selección de un ajuste funcional mínimo y trazable.

## 5. Exclusiones iniciales
- No se reabre toda la máquina de estados salvo necesidad estricta.
- No se mezcla este bloque con Facts o transiciones salvo dependencia directa.
- No se altera infraestructura.

## 6. Baseline de arranque
- Rama base: `main`
- Commit base: `b3c7951`
- Referencia inmediata anterior: cierre formal fase E24

## 7. Riesgos iniciales
- Contrato e implementación desalineados en bootstrap o semántica de PUT.
- Reglas ambiguas de completitud por bloque.
- Validación incompleta de pertenencia de items al caso.
- Dispersión hacia la guarda de transición sin evidencia suficiente.

## 8. Unidad inicial
- E25-01 — Baseline funcional del módulo Checklist

## 9. Criterios de salida de fase
- Baseline funcional suficiente del módulo Checklist.
- Brecha priorizada y delimitada.
- Ajuste funcional mínimo ejecutado bajo MDS.
- Cierre documental por unidad y cierre formal de fase.

## 10. Estado
- Fase abierta formalmente.
