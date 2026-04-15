# BASELINE UNIDAD E31-02 — 2026-04-14

## 1. Punto de partida
La unidad E31-01 diagnosticó el estado post-E30 del backend y confirmó que el contrato mantiene el bloque `8. Informes`, mientras que el código contiene módulo y controller `reports`.

## 2. Hipótesis
`reports` es el siguiente frente con mejor relación impacto/esfuerzo por su superficie acotada y por permitir validar comportamiento funcional útil: lista, generación, detalle e idempotencia.

## 3. Brecha a resolver
Aún no existe evidencia reciente y explícita en esta fase sobre la semántica real de `GET list`, `POST create` y `GET detail` de `reports`.

## 4. Resultado esperado
Dejar el módulo `reports` contrastado, validado y listo para cierre técnico dentro de E31.
