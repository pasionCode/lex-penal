# NOTA DE CIERRE UNIDAD E12-01 — 2026-04-14

## 1. Identificación
- Fase: E12
- Unidad: E12-01
- Nombre: Baseline de hardening operativo mínimo
- Estado: CERRADA

## 2. Objetivo de la unidad
Levantar baseline de riesgos y medidas de endurecimiento inmediatas en dependencias, servicio systemd, proxy Nginx y procedimiento operativo del backend desplegado.

## 3. Resultado
Unidad cumplida.

## 4. Hallazgos principales
- El endpoint técnico `GET /api/v1/health` responde correctamente en local y vía Nginx.
- El servicio `lex-penal.service` ya cuenta con controles básicos valiosos: usuario dedicado, `NoNewPrivileges=true`, `PrivateTmp=true` y `UMask=0027`.
- Persisten brechas claras de hardening en systemd: `ProtectSystem`, `ProtectHome`, `ProtectKernelTunables`, `ProtectKernelModules`, `ProtectControlGroups`, `LockPersonality`, `MemoryDenyWriteExecute` y `RestrictSUIDSGID` permanecen desactivados.
- Nginx opera correctamente para `/api/v1/`, con headers incluidos, pero la publicación sigue descansando en un `default_server` con certificado snakeoil para el bloque por defecto.
- Se generó evidencia local de `npm audit`, pendiente de explotación analítica posterior.

## 5. Decisión operativa
El siguiente bloque de remediación debe concentrarse primero en endurecimiento systemd de bajo riesgo y alta ganancia, antes de tocar el proxy.

## 6. Decisión de cierre
Se cierra E12-01 y se abre E12-02 para hardening systemd de bajo riesgo.
