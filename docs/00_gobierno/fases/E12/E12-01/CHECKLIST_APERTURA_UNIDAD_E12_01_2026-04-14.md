# CHECKLIST APERTURA UNIDAD E12-01 — 2026-04-14

## 1. Identificación
- Fase: E12
- Unidad: E12-01
- Nombre: Baseline de hardening operativo mínimo
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la unidad
Levantar baseline de riesgos y medidas de endurecimiento inmediatas en dependencias, servicio systemd, proxy Nginx y procedimiento operativo del backend desplegado.

## 3. Entradas
- Cierre formal de E11
- Commit base `25f5df9`
- Endpoint `/api/v1/health` operativo
- Script estándar `infra/scripts/deploy_lex_penal_vps.sh`

## 4. Salidas esperadas
- Evidencia de `npm audit`
- Revisión mínima de unit file de systemd
- Revisión mínima de proxy Nginx activo
- Hallazgos priorizados por criticidad y costo de remediación
- Base para E12-02

## 5. Verificaciones mínimas
- Estado de dependencias vulnerables
- Flags endurecedores actuales del servicio
- Encabezados y comportamiento básico del proxy
- Persistencia del smoke operativo tras validaciones

## 6. Criterios de cierre
- Baseline técnico-documental completo
- Riesgos clasificados
- Siguiente bloque de remediación definido con precisión
