# CHECKLIST APERTURA UNIDAD E10-07 — 2026-04-13
**Proyecto:** LEX_PENAL
**Fase:** E10
**Unidad:** E10-07
**Nombre:** Validación del acoplamiento entre review y transición de estado
**Fecha de apertura:** 2026-04-13
**Estado:** ABIERTA

## 1. Objetivo
Determinar si la revisión del supervisor debe producir por sí sola el cambio de estado del caso o si existe una transición adicional explícita requerida por el backend.

## 2. Precondiciones verificadas
- E10 abierta
- E10-01 a E10-06 cerradas
- caso de prueba con revisión creada
- caso de prueba aún en `pendiente_revision`
- autenticación real disponible en staging

## 3. Alcance
Incluye:
- validación del comportamiento posterior a review
- intento controlado de transición explícita desde `pendiente_revision`
- documentación del acoplamiento real review ↔ estado

No incluye:
- cierre integral de fase E10
- validación de todos los estados terminales del sistema

## 4. Riesgos controlados
- asumir bug sin probar ruta explícita
- perder trazabilidad del caso de prueba
- cerrar E10 con ambigüedad en la semántica de review

## 5. Criterios de aceptación
- comportamiento real del acoplamiento identificado
- si existe transición explícita, validada
- si no existe, hallazgo documentado con precisión
