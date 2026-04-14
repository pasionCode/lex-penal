# NOTA OPERATIVA — BACKUPS NGINX — 2026-04-14

## Regla
Queda prohibido almacenar archivos de respaldo dentro de:

- `/etc/nginx/sites-enabled/`
- `/etc/nginx/sites-available/`

## Justificación
Nginx puede interpretar esos archivos durante el test o recarga de configuración, generando errores de duplicidad o conflicto de bloques.

## Ruta autorizada
Los respaldos operativos de sitios Nginx deberán guardarse en:

- `/opt/lex_penal/shared/ops/backups/nginx-sites/`

## Alcance
Esta regla aplica a intervenciones manuales y a scripts operativos futuros.
