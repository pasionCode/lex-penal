# PROCEDIMIENTO OPERATIVO DE DESPLIEGUE — E11-04 — 2026-04-13

## 1. Regla operativa
Queda prohibido almacenar evidencias, respaldos temporales o salidas operativas dentro del árbol del repositorio desplegado en `/opt/lex_penal/app`.

## 2. Ruta operativa autorizada
Toda evidencia o respaldo del despliegue deberá ubicarse bajo:

- `/opt/lex_penal/shared/ops/evidencias`
- `/opt/lex_penal/shared/ops/quarantine`
- `/opt/lex_penal/shared/ops/backups`

## 3. Script estándar
El despliegue controlado deberá ejecutarse mediante:

- `infra/scripts/deploy_lex_penal_vps.sh`

## 4. Garantías mínimas del script
- respaldo lógico mínimo;
- cuarentena de archivos no rastreados;
- sincronización del repo;
- instalación de dependencias;
- build;
- reinicio del servicio;
- smoke local y vía Nginx.

## 5. Validación mínima post-deploy
Se considera validación mínima satisfactoria cuando:
- `lex-penal.service` queda `active (running)`;
- `POST /api/v1/auth/login` responde distinto de error de transporte, idealmente `400` por validación;
- el mismo comportamiento se reproduce vía Nginx.

## 6. Riesgo controlado
Se mitiga el riesgo de futuras colisiones por archivos no rastreados escritos dentro del repo desplegado.
