# CHECKLIST APERTURA UNIDAD E10-01 — 2026-04-13
**Proyecto:** LEX_PENAL
**Fase:** E10
**Unidad:** E10-01
**Nombre:** Criterio de paso a preproducción y validación funcional priorizada
**Fecha de apertura:** 2026-04-13
**Estado:** ABIERTA

## 1. Objetivo
Definir los criterios mínimos de paso a preproducción y ordenar una validación funcional priorizada sobre la base del staging ya consolidado.

## 2. Precondiciones verificadas
- E9 cerrada formalmente
- staging estable y validado externamente
- backend accesible por el punto de entrada real
- secretos ya rotados
- gobernanza documental preservada

## 3. Alcance
Incluye:
- matriz de criterios de paso a preproducción
- clasificación de bloqueantes y no bloqueantes
- priorización de validaciones funcionales
- recomendación de siguiente secuencia operativa

No incluye:
- ejecución completa de todas las validaciones funcionales
- despliegue preproductivo real
- cambio de infraestructura

## 4. Riesgos controlados
- confundir estabilidad técnica con preparación real para el siguiente entorno
- avanzar sin criterios explícitos
- desperdiciar tiempo en validaciones de bajo valor antes de las críticas

## 5. Criterios de aceptación
- existe matriz clara de criterios
- existe clasificación de bloqueantes / no bloqueantes
- existe recomendación concreta del siguiente bloque técnico
