# CHECKLIST APERTURA UNIDAD E18-01 — 2026-04-14

## 1. Identificación
- Fase: E18
- Unidad: E18-01
- Nombre: Baseline funcional del módulo de IA
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la unidad
Levantar una fotografía precisa del módulo IA del backend, identificando su superficie contractual, implementación real, prompts, logging, auditoría y comportamiento observable.

## 3. Entradas
- Commit base `b448b5a`
- Contrato API vigente
- Módulo `src/modules/ai`
- Reglas de logging y auditoría asociadas

## 4. Salidas esperadas
- Inventario del módulo IA
- Evidencia contractual y técnica
- Posibles brechas o inconsistencias
- Base para E18-02

## 5. Verificaciones mínimas
- Revisión de `POST /api/v1/ai/query` en contrato
- Inventario de archivos del módulo IA
- Referencias a prompts, logging y auditoría
- Verificación de cableado general del módulo

## 6. Criterios de cierre
- Baseline funcional suficiente
- Brecha priorizada
- Siguiente ajuste delimitado con precisión
