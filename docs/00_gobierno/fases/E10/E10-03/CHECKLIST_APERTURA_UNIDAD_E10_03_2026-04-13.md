# CHECKLIST APERTURA UNIDAD E10-03 — 2026-04-13
**Proyecto:** LEX_PENAL
**Fase:** E10
**Unidad:** E10-03
**Nombre:** Validación funcional priorizada de flujos críticos autenticados
**Fecha de apertura:** 2026-04-13
**Estado:** ABIERTA

## 1. Objetivo
Ejecutar una validación funcional priorizada sobre flujos críticos autenticados del backend en staging, partiendo de la autenticación real ya validada en E10-02.

## 2. Precondiciones verificadas
- E10 abierta
- E10-01 abierta
- E10-02 cerrada
- staging funcional
- autenticación real validada extremo a extremo
- usuario administrador de staging disponible de forma controlada

## 3. Alcance
Incluye:
- levantamiento del contrato real de endpoints críticos desde código/DTOs
- validación autenticada de listado de casos
- validación autenticada de creación de caso
- validación de consulta del caso creado
- registro de respuestas esperadas y hallazgos

No incluye:
- validación exhaustiva de todos los módulos
- pruebas de carga
- despliegue preproductivo
- cambios de arquitectura

## 4. Riesgos controlados
- probar con payloads inventados
- declarar funcionalidad sin ejecutar flujos reales
- perder trazabilidad del caso de prueba generado

## 5. Criterios de aceptación
- contrato mínimo del flujo crítico identificado desde el código
- login real reutilizado para pruebas
- al menos un flujo autenticado de casos ejecutado con evidencia real
- hallazgos documentados con precisión
