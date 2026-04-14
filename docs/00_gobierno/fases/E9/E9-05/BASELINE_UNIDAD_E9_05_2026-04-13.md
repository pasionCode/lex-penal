# BASELINE UNIDAD E9-05 — 2026-04-13
**Proyecto:** LEX_PENAL
**Fase:** E9
**Unidad:** E9-05
**Tipo:** Línea base de entrada

## 1. Estado heredado
El staging de LEX_PENAL se encuentra operativo en `lexum-main`, con backend activo en `3010`, proxy `nginx` funcional hacia `/api/v1/*` y configuración activa de `nginx` saneada en lo esencial.

## 2. Estado técnico de entrada
- backend responde localmente en `/api/v1/cases`
- staging responde vía `nginx` al host/IP definido
- Nextcloud sigue operativo
- documentación E9-01.A a E9-04 ya consolidada en `main`

## 3. Resultado esperado
Al cierre de E9-05 deberá existir confirmación observable desde cliente externo de que el staging responde conforme a lo esperado.
