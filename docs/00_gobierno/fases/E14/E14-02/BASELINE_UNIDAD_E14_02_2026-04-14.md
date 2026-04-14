# BASELINE UNIDAD E14-02 — 2026-04-14

## 1. Punto de partida
El proxy de LEX_PENAL funciona, pero convive con bloques heredados activos que generan ruido y reducen claridad operacional.

## 2. Estrategia
Aplicar únicamente saneamiento de bajo riesgo y alta reversibilidad, empezando por `legaltech-api`, que ya mostró evidencia concreta de ruido en `error.log`.

## 3. Resultado esperado
Proxy más limpio, con menor ruido heredado y sin afectar disponibilidad del backend actual.
