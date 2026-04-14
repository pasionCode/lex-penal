# CHECKLIST APERTURA UNIDAD E14-01 — 2026-04-14

## 1. Identificación
- Fase: E14
- Unidad: E14-01
- Nombre: Baseline de hardening de proxy/Nginx
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la unidad
Levantar baseline real del proxy/Nginx que publica LEX_PENAL, identificando bloques activos, publicaciones heredadas, logs, certificados y focos de ruido o ambigüedad.

## 3. Entradas
- Commit base `d758a09`
- `GET /api/v1/health` operativo
- Script de observación rápida y log dedicado ya existentes

## 4. Salidas esperadas
- Mapa de bloques Nginx relevantes
- Inventario de archivos activos de publicación
- Identificación de ruido heredado
- Base para E14-02

## 5. Verificaciones mínimas
- `sites-enabled`
- `nginx -t`
- bloques `server` relevantes
- referencias a `proxy_pass`
- certificados y nombres de servidor
- logs activos detectables

## 6. Criterios de cierre
- Baseline documental completo
- Hallazgos priorizados
- Siguiente bloque de saneamiento definido
