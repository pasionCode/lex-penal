# CHECKLIST APERTURA UNIDAD E20-02 — 2026-04-14

## 1. Identificación
- Fase: E20
- Unidad: E20-02
- Nombre: Normalización de acceso e idempotencia de Reports
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la unidad
Verificar y alinear las reglas de acceso, ownership, detalle por caso e idempotencia efectiva del módulo Reports respecto al resto de subrecursos case-scoped del backend.

## 3. Entradas
- E20-01 cerrada
- Contrato vigente de Reports
- Controller, service y repository del módulo Reports

## 4. Tareas mínimas
- Inspeccionar controller, service y repository
- Verificar uso de guardas y contexto de usuario
- Verificar semántica de idempotencia y auditoría
- Verificar aislamiento por caso en `findOne`
- Definir ajuste mínimo necesario

## 5. Criterios de cierre
- Reglas de acceso e idempotencia confirmadas o corregidas
- Contrato y código alineados
- Evidencia archivada
