# NOTA DE CIERRE — E9-02 — Exposición controlada del backend en staging mediante nginx
**Proyecto:** LEX_PENAL  
**Fase:** E9  
**Unidad:** E9-02  
**Fecha de cierre:** 2026-04-12  
**Estado:** CERRADA

## 1. Objeto de la unidad
Exponer de forma controlada el backend de LEX_PENAL en staging mediante `nginx`, apuntando al servicio `lex-penal` ya operativo en `127.0.0.1:3010`, sin afectar el resto del ecosistema heredado del servidor.

## 2. Resultado general
Se concluye que **E9-02 queda CUMPLIDA EN LO TÉCNICO**, con exposición controlada validada por HTTPS hacia el backend para el host/IP de staging definido.

## 3. Evidencia consolidada
1. El backend NestJS se encontraba previamente activo por `systemd` mediante `lex-penal.service`, escuchando en `3010`.
2. Se identificó `00-default-ssl.conf` como punto de entrada catch-all de HTTPS para staging.
3. Se incorporó un bloque `location /api/v1/` con `proxy_pass http://127.0.0.1:3010`.
4. Se limpiaron configuraciones de respaldo conflictivas dentro de `sites-enabled`.
5. `nginx -t` validó correctamente.
6. `systemctl reload nginx` ejecutó sin fallo.
7. La raíz `/` continuó respondiendo con el placeholder institucional del VPS.
8. La ruta `/api/v1/cases`, bajo `Host: 207.180.248.126`, respondió `401 Unauthorized` desde Express/Nest, acreditando que el proxy llegó efectivamente al backend.

## 4. Interpretación técnica
- La respuesta `401 Unauthorized` en `/api/v1/cases` no constituye error de proxy.
- Por el contrario, demuestra que el request alcanzó correctamente el backend y fue rechazado por control de acceso de la aplicación.
- La exposición controlada por `nginx` queda materialmente verificada para el host/IP de staging.

## 5. Observaciones
1. El acceso por `https://127.0.0.1/api/v1/cases` sin host objetivo siguió devolviendo el placeholder del catch-all.
2. Esto no invalida la unidad, porque la validación funcional relevante se realizó sobre el host/IP de staging definido.
3. No se realizó commit en el host staging, conforme a la restricción metodológica por encontrarse el repo en `detached HEAD`.
4. La documentación generada en el VPS debe bajarse y consolidarse en el repo local canónico.

## 6. Decisión de cierre
Se declara **CERRADA** la unidad **E9-02 — Exposición controlada del backend en staging mediante nginx** por cumplimiento técnico verificable.

## 7. Pendientes heredados
- Unificar la traza documental VPS → repo local
- Rotar secretos expuestos en sesión de trabajo
- Definir siguiente unidad de trabajo sobre staging, validaciones externas o endurecimiento complementario
