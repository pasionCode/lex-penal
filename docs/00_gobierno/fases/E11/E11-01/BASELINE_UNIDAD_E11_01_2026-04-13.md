# BASELINE UNIDAD E11-01 — 2026-04-13

## 1. Propósito
Esta unidad estableció el punto de control técnico-operativo del entorno objetivo antes de cualquier acción de despliegue o ajuste con impacto.

## 2. Evidencia levantada
Se recolectó evidencia cruda del VPS en:
- `docs/00_gobierno/fases/E11/E11-01/evidencias/BASELINE_VPS_RAW_2026-04-13.txt`
- `docs/00_gobierno/fases/E11/E11-01/evidencias/BASELINE_VPS_SUPLEMENTO_2026-04-13.txt`

## 3. Hallazgos confirmados
- Host objetivo: `lexum-main`
- Usuario de acceso operativo: `lexumadmin`
- SO: Ubuntu 24.04.4 LTS
- Memoria: 11 GiB
- Disco raíz: 96 GiB, con 41 GiB disponibles aproximadamente
- Servicios activos y habilitados: `nginx`, `postgresql`, `docker`, `tailscaled`
- Repo desplegado presente en `/opt/lex_penal/app`
- El backend de LEX_PENAL está escuchando en `*:3010`
- El puerto `3010` corresponde al proceso `node dist/main.js`
- El servicio asociado identificado en systemd es `lex-penal.service`
- `GET /` sobre `127.0.0.1:3010` responde `404`
- `GET /health` sobre `127.0.0.1:3010` responde `404`
- `127.0.0.1:8080` corresponde a Nextcloud y redirige a `cloud.pabloleon.com.co/login`

## 4. Hallazgos de contexto operativo
El VPS no está dedicado exclusivamente a LEX_PENAL. Coexisten:
- Nextcloud
- MariaDB
- Redis
- restos de monitoreo y otros artefactos Docker heredados
- múltiples sitios de Nginx legados

Esto confirma que cualquier publicación posterior debe tratarse como despliegue controlado sobre infraestructura compartida.

## 5. Limitaciones del levantamiento
No fue posible completar en esta unidad, por restricción de privilegios `sudo`, lo siguiente:
- commit exacto desplegado en `/opt/lex_penal/app`
- lectura del `.env` para inventario de claves
- lectura efectiva de los bloques habilitados de Nginx
- validación completa de `nginx -t`

## 6. Conclusión del baseline
La unidad logra su objetivo mínimo:
- existe backend desplegado,
- existe servicio persistente,
- existe puerto operativo identificado,
- y existe contexto suficiente para decidir la siguiente unidad.

No obstante, la evidencia también demuestra que aún no corresponde declarar despliegue controlado cerrado ni publicación validada, porque falta verificación privilegiada de configuración y smoke funcional sobre rutas reales del backend.

## 7. Siguiente paso recomendado
Abrir E11-02 para:
- verificación privilegiada del servicio y Nginx,
- atribución del commit desplegado,
- smoke test sobre endpoint funcional real,
- y preparación de secuencia mínima de publicación/actualización.
