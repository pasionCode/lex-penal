# CHECKLIST APERTURA UNIDAD E27-02 — 2026-04-14

## 1. Identificación
- Fase: E27
- Unidad: E27-02
- Nombre: Normalización de escritura, vínculo y semántica operativa de Evidence
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la unidad
Verificar y alinear la semántica real de acceso, escritura, actualización, `link/unlink`, control por estado y errores del módulo Evidence respecto al contrato y a la política general del caso.

## 3. Entradas
- E27-01 cerrada
- Contrato vigente de Evidence
- Controller, service y repository del módulo Evidence

## 4. Tareas mínimas
- Inspeccionar controller, service y repository completos
- Verificar create, update, link y unlink
- Verificar si existe control real por estado del caso
- Verificar protección de `hecho_id` y aislamiento por caso
- Definir ajuste mínimo necesario
- Ejecutar alineación técnica y/o contractual según evidencia

## 5. Criterios de cierre
- Semántica de Evidence confirmada o corregida
- Contrato y código alineados
- Evidencia archivada
