# BASELINE FASE E14 — 2026-04-14

## 1. Punto de partida
La fase E14 inicia después del cierre formal de E13, tomando como base el commit `d758a09`.

## 2. Estado heredado
- Backend operativo y validado por `GET /api/v1/health`.
- Servicio `lex-penal.service` endurecido de forma conservadora.
- Procedimiento estándar de despliegue vigente.
- Observabilidad mínima operativa funcional.
- Log dedicado de Nginx para `/api/v1/`.

## 3. Brecha de la nueva fase
Aún persisten signos de configuración heredada y ruido en Nginx:
- `access.log` general contaminado,
- `error.log` con señales de hosts/configuraciones históricas,
- y necesidad de mayor claridad operacional del proxy efectivo.

## 4. Decisión de arranque
Se abre E14-01 como unidad diagnóstica para levantar baseline exacto del proxy antes de endurecer o sanear bloques.
