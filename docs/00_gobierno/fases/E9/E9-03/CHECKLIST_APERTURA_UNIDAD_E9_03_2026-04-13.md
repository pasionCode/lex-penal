# CHECKLIST APERTURA UNIDAD E9-03 — 2026-04-13
**Proyecto:** LEX_PENAL
**Fase:** E9
**Unidad:** E9-03
**Nombre:** Rotación de secretos expuestos y saneamiento fino de staging
**Fecha de apertura:** 2026-04-13
**Estado:** ABIERTA

## 1. Objetivo
Rotar los secretos de aplicación expuestos durante la sesión operativa de staging, reescribir la configuración efectiva del backend y validar continuidad operativa del servicio `lex-penal` y del proxy `nginx`.

## 2. Precondiciones verificadas
- `lexum-main` definido como staging
- `lex-penal.service` activo por systemd
- backend operativo en `3010`
- proxy HTTPS funcional hacia `/api/v1/*` para el host/IP de staging
- traza documental E9-01.A y E9-02 consolidada en el repo local

## 3. Alcance
Incluye:
- rotación de `JWT_SECRET`
- rotación de `COOKIE_SECRET`
- reescritura controlada de `/opt/lex_penal/shared/.env`
- restart de `lex-penal`
- validación de `systemd`, journal, escucha local y smoke test por `nginx`
- revisión fina de warnings/configuración activa de `nginx`

No incluye:
- cambio de credenciales de PostgreSQL
- despliegue productivo
- cambio de dominio
- cierre integral de E9

## 4. Riesgos controlados
- permanencia de secretos materialmente expuestos
- caída del backend por `.env` inconsistente
- desalineación entre backend y proxy
- pérdida de gobernanza documental

## 5. Criterios de aceptación
- secretos nuevos generados y persistidos fuera del repo
- `.env` reescrito con valores nuevos
- `lex-penal.service` reiniciado y activo
- backend respondiendo por `127.0.0.1:3010`
- `/api/v1/cases` respondiendo por el punto de entrada staging
- evidencia documental de cierre
