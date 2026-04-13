# CHECKLIST APERTURA UNIDAD E9-02 — 2026-04-12
**Proyecto:** LEX_PENAL  
**Fase:** E9  
**Unidad:** E9-02  
**Nombre:** Exposición controlada del backend en staging mediante nginx  
**Fecha de apertura:** 2026-04-12  
**Estado:** ABIERTA

## 1. Objetivo
Exponer de forma controlada el backend de LEX_PENAL en staging mediante `nginx`, proxy inverso hacia el servicio `lex-penal` ya activo en `127.0.0.1:3010`, sin perder endurecimiento ni gobernanza.

## 2. Precondiciones verificadas
- Servidor staging definido: `lexum-main`
- Host reactivo y apto para staging
- Firewall operativo y administración cerrada por Tailnet
- `nginx` activo
- `postgresql` activo y no expuesto públicamente
- `lex-penal.service` activo
- Backend respondiendo en `3010`

## 3. Alcance
Incluye:
- identificar vhost o sitio objetivo en `nginx`
- definir forma de exposición controlada
- configurar proxy hacia `127.0.0.1:3010`
- recargar `nginx`
- validar acceso local y/o externo controlado
- dejar evidencia documental del amarre

No incluye:
- despliegue productivo definitivo
- apertura indiscriminada del entorno
- rediseño integral del proxy de otros servicios
- cierre integral de E9

## 4. Riesgos controlados
- colisión con vhosts existentes
- sobrescritura indebida de configuración heredada
- exposición accidental de servicios no previstos
- proxy apuntando a puerto erróneo
- pérdida de trazabilidad documental

## 5. Criterios de aceptación
- existe identificación clara del vhost afectado
- el proxy apunta a `127.0.0.1:3010`
- `nginx -t` valida sin error
- `systemctl reload nginx` ejecuta correctamente
- existe respuesta válida al backend a través del punto de entrada configurado
- se deja nota de cierre de unidad con evidencia real
