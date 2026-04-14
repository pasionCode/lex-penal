# CHECKLIST APERTURA UNIDAD E9-04 — 2026-04-13
**Proyecto:** LEX_PENAL
**Fase:** E9
**Unidad:** E9-04
**Nombre:** Saneamiento fino de nginx y consolidación del staging
**Fecha de apertura:** 2026-04-13
**Estado:** ABIERTA

## 1. Objetivo
Depurar y consolidar la configuración activa de `nginx` en `lexum-main`, eliminando residuos o configuraciones conflictivas heredadas, sin afectar el backend ya operativo ni el proxy funcional del staging.

## 2. Precondiciones verificadas
- E9-01.A cerrada
- E9-02 cerrada
- E9-03 cerrada
- backend activo en `3010`
- `lex-penal.service` operativo
- proxy staging funcional para `/api/v1/*` bajo `Host: 207.180.248.126`

## 3. Alcance
Incluye:
- inventario real de `sites-enabled` y `conf.d`
- identificación de archivos activos, residuos y duplicados
- validación con `nginx -T`
- saneamiento controlado de configuraciones no deseadas
- validación posterior con `nginx -t`, reload y smoke tests

No incluye:
- cambio de dominio
- despliegue productivo
- refactor amplio del esquema de reverse proxy
- cierre integral de E9

## 4. Riesgos controlados
- arrastre de configuraciones obsoletas
- warnings persistentes o ruido de operación
- reapertura innecesaria de fallos ya superados
- pérdida de gobernanza documental

## 5. Criterios de aceptación
- configuración activa de `nginx` identificada con precisión
- archivos residuales o conflictivos saneados
- `nginx -t` limpio o con warnings explícitamente justificados
- reload exitoso
- staging mantiene respuesta válida sobre `/api/v1/cases`
