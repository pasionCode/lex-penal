# BASELINE UNIDAD E11-05 — 2026-04-13

## 1. Punto de partida
El backend está desplegado, alineado y operativo en el VPS, con proxy Nginx funcional y procedimiento estándar de despliegue ya establecido.

## 2. Brecha actual
La validación mínima post-deploy depende hoy de una ruta funcional (`POST /api/v1/auth/login`) que no fue diseñada como endpoint técnico de salud.

## 3. Resultado esperado
Disponer de un endpoint técnico simple, estable y reusable para smoke test, readiness y verificación operativa.
