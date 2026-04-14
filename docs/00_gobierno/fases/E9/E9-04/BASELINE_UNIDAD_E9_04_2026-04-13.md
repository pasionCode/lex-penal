# BASELINE UNIDAD E9-04 — 2026-04-13
**Proyecto:** LEX_PENAL
**Fase:** E9
**Unidad:** E9-04
**Tipo:** Línea base de entrada

## 1. Estado heredado
La unidad inicia con staging funcional en `lexum-main`, backend activo en `3010`, proxy HTTPS operativo hacia `/api/v1/*` y secretos rotados en E9-03.

## 2. Estado técnico de entrada
- `lex-penal.service` activo
- backend responde `401 Unauthorized` en `/api/v1/cases` a nivel local
- backend responde `401 Unauthorized` en `/api/v1/cases` a través de `nginx` bajo el host/IP de staging
- `nginx -t` exitoso al cierre de E9-03

## 3. Problema operativo a resolver
Aunque el staging ya funciona, se requiere verificar que la configuración de `nginx` haya quedado limpia, consistente y libre de residuos conflictivos o configuraciones activas innecesarias.

## 4. Resultado esperado
Al cierre de E9-04 deberá existir una configuración de `nginx` consolidada, entendida y saneada, sin pérdida de funcionalidad del staging.
