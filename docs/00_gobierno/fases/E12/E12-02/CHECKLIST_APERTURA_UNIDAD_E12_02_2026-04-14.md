# CHECKLIST APERTURA UNIDAD E12-02 — 2026-04-14

## 1. Identificación
- Fase: E12
- Unidad: E12-02
- Nombre: Hardening systemd de bajo riesgo
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la unidad
Aplicar endurecimiento de bajo riesgo al servicio `lex-penal.service`, aumentando aislamiento del proceso sin romper el backend ni el procedimiento operativo de despliegue.

## 3. Entradas
- E12-01 cerrada.
- Servicio actual operativo con `health` válido.
- Evidencia de brechas de hardening en unit file.

## 4. Tareas mínimas
- Respaldar unit file actual.
- Aplicar directivas seguras de bajo riesgo.
- Recargar systemd.
- Reiniciar servicio.
- Validar `health` local y vía Nginx.
- Documentar resultado y riesgo residual.

## 5. Criterios de cierre
- Servicio reiniciado sin fallo.
- `health` responde `200` local y vía Nginx.
- Nuevas directivas endurecedoras activas y verificadas.
