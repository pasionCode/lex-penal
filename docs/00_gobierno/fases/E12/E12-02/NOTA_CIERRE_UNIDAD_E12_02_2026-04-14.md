# NOTA DE CIERRE UNIDAD E12-02 — 2026-04-14

## 1. Identificación
- Fase: E12
- Unidad: E12-02
- Nombre: Hardening systemd de bajo riesgo
- Estado: CERRADA

## 2. Objetivo de la unidad
Aplicar endurecimiento de bajo riesgo al servicio `lex-penal.service`, aumentando aislamiento del proceso sin romper el backend ni el procedimiento operativo de despliegue.

## 3. Resultado
Unidad cumplida.

## 4. Medidas aplicadas
- `ProtectSystem=full`
- `ProtectHome=true`
- `ProtectKernelTunables=true`
- `ProtectKernelModules=true`
- `ProtectControlGroups=true`
- `RestrictSUIDSGID=true`
- `LockPersonality=true`

## 5. Validación
- El servicio reinició correctamente.
- `GET /api/v1/health` respondió `200 OK` en local.
- `GET /api/v1/health` respondió `200 OK` vía Nginx.

## 6. Riesgo residual
No se abordaron aún vulnerabilidades de dependencias ni endurecimiento adicional de proxy.

## 7. Decisión de cierre
Se cierra E12-02 y se abre E12-03 para triage y remediación de dependencias de bajo riesgo.
