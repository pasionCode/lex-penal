# CHECKLIST APERTURA UNIDAD E10-05 — 2026-04-13
**Proyecto:** LEX_PENAL
**Fase:** E10
**Unidad:** E10-05
**Nombre:** Validación de guardas para pendiente_revision
**Fecha de apertura:** 2026-04-13
**Estado:** ABIERTA

## 1. Objetivo
Validar las reglas de guardia de la transición `en_analisis -> pendiente_revision` sobre un caso real de staging, verificando tanto escenarios de rechazo como de aceptación.

## 2. Precondiciones verificadas
- E10 abierta
- E10-01 abierta
- E10-02 cerrada
- E10-03 cerrada
- E10-04 cerrada
- caso de prueba activo en `en_analisis`
- checklist bootstrappeado
- al menos un hecho registrado
- estrategia del caso existente con `linea_principal`

## 3. Alcance
Incluye:
- intento controlado de transición a `pendiente_revision`
- lectura de rechazo o aceptación real
- verificación del peso de checklist, hechos y estrategia en la guarda
- documentación del comportamiento observado

No incluye:
- revisión del supervisor
- aprobación final del caso
- cierre integral de la fase E10

## 4. Riesgos controlados
- asumir guardas sin probarlas
- marcar checklist crítico sin trazabilidad
- perder control del estado real del caso de prueba

## 5. Criterios de aceptación
- transición intentada con evidencia real
- resultado documentado (rechazo o aceptación)
- si hay rechazo, causa de guarda identificada con precisión
- si hay aceptación, cambio de estado verificado
