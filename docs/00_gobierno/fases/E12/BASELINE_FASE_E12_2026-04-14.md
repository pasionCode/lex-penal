# BASELINE FASE E12 — 2026-04-14

## 1. Punto de partida
La fase E12 inicia inmediatamente después del cierre formal de E11, tomando como base el commit `25f5df9`.

## 2. Estado heredado
- Despliegue operativo en VPS validado.
- Servicio `lex-penal.service` funcional.
- Proxy Nginx funcional bajo `/api/v1/`.
- Smoke técnico explícito mediante `GET /api/v1/health`.
- Procedimiento estándar de despliegue ya documentado.

## 3. Brecha de la nueva fase
Aunque el despliegue está controlado, persisten frentes de endurecimiento:
- vulnerabilidades reportadas por dependencias,
- endurecimiento del servicio,
- endurecimiento del proxy,
- y formalización de criterios de riesgo residual.

## 4. Decisión de arranque
Se abre E12-01 como unidad diagnóstica y de baseline de hardening, antes de aplicar remediaciones.
