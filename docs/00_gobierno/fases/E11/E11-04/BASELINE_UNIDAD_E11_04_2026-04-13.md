# BASELINE UNIDAD E11-04 — 2026-04-13

## 1. Punto de partida
El VPS ya quedó alineado con el commit `67a1b84`, con servicio `lex-penal.service` operativo y smoke mínimo satisfactorio.

## 2. Problema residual
El despliegue mostró contaminación del árbol de trabajo por archivos no rastreados y falta de trazabilidad suficientemente explícita del artefacto compilado.

## 3. Resultado esperado
Dejar el despliegue en condición operativa más limpia, reproducible y gobernable, reduciendo riesgo de fallos en próximas actualizaciones.
