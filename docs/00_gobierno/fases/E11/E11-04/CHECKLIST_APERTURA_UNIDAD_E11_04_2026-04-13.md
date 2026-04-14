# CHECKLIST APERTURA UNIDAD E11-04 — 2026-04-13

## 1. Identificación
- Fase: E11
- Unidad: E11-04
- Nombre: Saneamiento operativo post-despliegue
- Fecha de apertura: 2026-04-13
- Estado: ABIERTA

## 2. Objetivo de la unidad
Formalizar la higiene del despliegue del VPS para evitar contaminación del árbol de trabajo, mejorar la trazabilidad del artefacto compilado y dejar un procedimiento reproducible de actualización operativa.

## 3. Entradas
- E11-03 cerrada con despliegue alineado a `67a1b84`.
- Servicio y proxy funcionales.
- Antecedente de bloqueo por archivos no rastreados dentro del repo desplegado.

## 4. Tareas mínimas
- Documentar la cuarentena o reubicación de archivos no rastreados.
- Definir política de no escribir evidencias/gobierno dentro del repo desplegado en el VPS.
- Verificar trazabilidad del build generado en `dist/`.
- Preparar script o secuencia estándar de actualización.
- Definir validación mínima post-deploy.

## 5. Criterios de cierre
- Riesgo de contaminación del working tree mitigado.
- Procedimiento operativo reproducible documentado.
- Regla de ubicación de evidencias y respaldos definida.
- Siguiente paso de fase E11 claramente delimitado.
