# CHECKLIST APERTURA UNIDAD E14-02 — 2026-04-14

## 1. Identificación
- Fase: E14
- Unidad: E14-02
- Nombre: Saneamiento de bajo riesgo del proxy
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la unidad
Reducir ruido heredado y ambigüedad operativa en Nginx mediante el retiro controlado de bloques activos no pertinentes al backend actual de LEX_PENAL.

## 3. Entradas
- E14-01 cerrada
- `legaltech-api` activo en `sites-enabled`
- ruido confirmado en `error.log` por `api.legaltech.local` -> `127.0.0.1:8000`

## 4. Tareas mínimas
- Respaldar archivo activo `legaltech-api`
- Retirarlo de `sites-enabled`
- Validar `nginx -t`
- Recargar Nginx
- Verificar `health` local y vía Nginx
- Verificar reducción de ruido heredado

## 5. Criterios de cierre
- `legaltech-api` fuera de `sites-enabled`
- `nginx -t` exitoso
- `health` en `200`
- evidencia operativa archivada
