# CHECKLIST APERTURA UNIDAD E21-02 — 2026-04-14

## 1. Identificación
- Fase: E21
- Unidad: E21-02
- Nombre: Normalización semántica y contractual de Review
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la unidad
Verificar y alinear la semántica real de acceso, feedback, versionado, vigencia y errores del módulo Review respecto al contrato, con especial atención a diferencias por endpoint.

## 3. Entradas
- E21-01 cerrada
- Contrato vigente de Review
- Controller, service y repository del módulo Review

## 4. Tareas mínimas
- Inspeccionar controller, service y repository completos
- Verificar diferencias reales entre historial, feedback y creación
- Verificar si `409` aplica solo a POST o también a otros endpoints
- Definir ajuste mínimo necesario
- Ejecutar alineación contractual y/o técnica según evidencia

## 5. Criterios de cierre
- Semántica de Review confirmada o corregida
- Contrato y código alineados
- Evidencia archivada
