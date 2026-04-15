# BASELINE UNIDAD E29-02 — 2026-04-14

## 1. Punto de partida
La unidad E29-01 diagnosticó el estado post-E28 del backend y confirmó que el contrato mantiene el subrecurso `5.9 Actuaciones procesales`, mientras que el código contiene módulo y controller `proceedings`.

## 2. Hipótesis
`proceedings` es el siguiente frente con mejor relación impacto/esfuerzo, por su superficie acotada y por permitir un cierre rápido de consistencia entre contrato e implementación.

## 3. Brecha a resolver
Aún no existe evidencia reciente y explícita en esta fase sobre la semántica real de `GET list`, `POST create` y `GET detail` de `proceedings`.

## 4. Resultado esperado
Dejar el módulo `proceedings` contrastado, validado y listo para cierre técnico dentro de E29.
