# CHECKLIST APERTURA UNIDAD E10-06 — 2026-04-13
**Proyecto:** LEX_PENAL
**Fase:** E10
**Unidad:** E10-06
**Nombre:** Validación de revisión de supervisor sobre caso en pendiente_revision
**Fecha de apertura:** 2026-04-13
**Estado:** ABIERTA

## 1. Objetivo
Validar el tramo de revisión de supervisor sobre un caso real en estado `pendiente_revision`, verificando creación de revisión y comportamiento posterior del caso.

## 2. Precondiciones verificadas
- E10 abierta
- E10-01 abierta
- E10-02 cerrada
- E10-03 cerrada
- E10-04 cerrada
- E10-05 cerrada
- caso de prueba en `pendiente_revision`
- autenticación real disponible en staging

## 3. Alcance
Incluye:
- levantamiento del contrato real de review
- validación del endpoint de revisión
- verificación del estado posterior del caso
- documentación del resultado observado

No incluye:
- pruebas exhaustivas de historial y feedback si no son necesarias
- cierre integral de fase E10
- validación de todos los escenarios posibles de supervisor

## 4. Riesgos controlados
- payloads inventados en review
- pérdida de trazabilidad del caso de prueba
- asumir efectos de la revisión sin validarlos

## 5. Criterios de aceptación
- contrato mínimo de review identificado desde código
- revisión ejecutada sobre caso real o bloqueo documentado con precisión
- estado posterior del caso verificado con evidencia real
