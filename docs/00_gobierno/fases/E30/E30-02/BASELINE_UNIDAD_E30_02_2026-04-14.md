# BASELINE UNIDAD E30-02 — 2026-04-14

## 1. Punto de partida
La unidad E30-01 diagnosticó el estado post-E29 del backend y confirmó que el contrato mantiene el bloque `6. Sujetos procesales`, mientras que el código contiene módulo y controller `subjects`.

## 2. Hipótesis
`subjects` es el siguiente frente con mejor relación impacto/esfuerzo por su superficie acotada pero semánticamente rica: listado paginado, filtros, creación y detalle.

## 3. Brecha a resolver
Aún no existe evidencia reciente y explícita en esta fase sobre la semántica real de `GET list`, `POST create` y `GET detail` de `subjects`.

## 4. Resultado esperado
Dejar el módulo `subjects` contrastado, validado y listo para cierre técnico dentro de E30.
