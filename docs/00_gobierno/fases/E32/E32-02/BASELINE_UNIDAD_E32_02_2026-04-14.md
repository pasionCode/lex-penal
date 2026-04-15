# BASELINE UNIDAD E32-02 — 2026-04-14

## 1. Punto de partida
La unidad E32-01 diagnosticó el estado post-E31 del backend y confirmó que el contrato mantiene el bloque `10. Auditoría`, mientras que el código contiene módulo y controller `audit`.

## 2. Hipótesis
`audit` es el siguiente frente con mejor relación impacto/esfuerzo porque permite validar acceso por rol, paginación y filtros sobre un recurso ya implementado y con utilidad transversal.

## 3. Brecha a resolver
Aún no existe evidencia reciente y explícita en esta fase sobre la semántica real de `GET /cases/{caseId}/audit`.

## 4. Resultado esperado
Dejar el módulo `audit` contrastado, validado y listo para cierre técnico dentro de E32.
