# BASELINE UNIDAD E12-03 — 2026-04-14

## 1. Punto de partida
El backend se encuentra operativo, con hardening systemd conservador ya aplicado, pero persisten vulnerabilidades reportadas por `npm audit`.

## 2. Estrategia
No aplicar fixes automáticos ciegos. Primero se clasifica riesgo, luego se ejecutan solo remediaciones de bajo impacto y alta reversibilidad.

## 3. Resultado esperado
Reducir superficie de riesgo en dependencias sin comprometer la estabilidad operativa alcanzada en E11 y E12.
