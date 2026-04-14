# CHECKLIST APERTURA UNIDAD E12-03 — 2026-04-14

## 1. Identificación
- Fase: E12
- Unidad: E12-03
- Nombre: Triage y remediación de dependencias de bajo riesgo
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la unidad
Analizar la salida de `npm audit`, separar hallazgos por criticidad y factibilidad, y aplicar únicamente remediaciones de bajo riesgo compatibles con la operación actual.

## 3. Entradas
- E12-01 con evidencia local de `npm audit`
- E12-02 cerrada con servicio endurecido y saludable

## 4. Tareas mínimas
- Resumir vulnerabilidades por paquete y criticidad
- Diferenciar remediaciones seguras vs. no seguras
- Aplicar remediación de bajo riesgo si existe
- Rebuild + smoke si se toca lockfile o dependencias
- Documentar pendientes de mayor impacto

## 5. Criterios de cierre
- Riesgos clasificados
- Cambios seguros aplicados o formalmente descartados
- Servicio sigue sano tras cualquier ajuste
