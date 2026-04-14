# CHECKLIST APERTURA UNIDAD E10-04 — 2026-04-13
**Proyecto:** LEX_PENAL
**Fase:** E10
**Unidad:** E10-04
**Nombre:** Activación del caso, transición de estado y validación de herramientas críticas
**Fecha de apertura:** 2026-04-13
**Estado:** ABIERTA

## 1. Objetivo
Validar la activación del caso y el comportamiento mínimo de herramientas críticas del flujo jurídico del backend, partiendo del caso autenticado ya creado en staging.

## 2. Precondiciones verificadas
- E10 abierta
- E10-01 abierta
- E10-02 cerrada
- E10-03 cerrada
- login real validado
- cliente de staging creado
- caso de prueba creado en estado `borrador`

## 3. Alcance
Incluye:
- transición `borrador -> en_analisis`
- verificación de bootstrap/checklist
- creación/listado de hechos
- consulta/actualización básica de estrategia
- registro de respuestas y reglas observadas

No incluye:
- cierre completo del ciclo hasta `pendiente_revision`
- revisión de supervisor
- validación exhaustiva de todos los subrecursos

## 4. Riesgos controlados
- payloads inventados en transiciones o herramientas
- pérdida de trazabilidad del caso de prueba
- asumir reglas de guardia sin validarlas

## 5. Criterios de aceptación
- transición de activación validada con evidencia real
- checklist consultable después de activación
- al menos una herramienta crítica validada con autenticación real
- hallazgos documentados con precisión
