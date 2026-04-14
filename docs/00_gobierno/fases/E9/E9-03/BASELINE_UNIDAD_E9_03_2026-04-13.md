# BASELINE UNIDAD E9-03 — 2026-04-13
**Proyecto:** LEX_PENAL
**Fase:** E9
**Unidad:** E9-03
**Tipo:** Línea base de entrada

## 1. Estado heredado
La unidad inicia con staging operativo en `lexum-main`, backend NestJS ejecutándose por `systemd` mediante `lex-penal.service`, y exposición HTTPS funcional de `/api/v1/*` a través de `nginx` para el host/IP de staging.

## 2. Estado técnico de entrada
- host staging: `lexum-main`
- backend activo en `3010`
- proxy nginx validado para `Host: 207.180.248.126`
- repo del VPS sin commits directos
- traza documental ya consolidada en `main`

## 3. Observación heredada crítica
Durante la operación previa se imprimieron secretos de aplicación en la sesión/logs, por lo que `JWT_SECRET` y `COOKIE_SECRET` deben considerarse comprometidos y requieren rotación.

## 4. Resultado esperado
Al cierre de E9-03, el entorno staging deberá seguir operativo con secretos rotados y validación funcional posterior al cambio.
