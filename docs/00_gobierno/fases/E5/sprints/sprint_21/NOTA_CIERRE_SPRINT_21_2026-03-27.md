# NOTA DE CIERRE — SPRINT 21

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Consolidación / expansión controlada
- Sprint: 21
- Fecha de cierre: 2026-03-27
- Estado: CERRADO

## 2. Objetivo del sprint
Cerrar coherencia contractual y funcional final del subrecurso `subjects`, alineando:
- contrato API
- comportamiento real del endpoint GET `/api/v1/cases/:caseId/subjects`
- validaciones del query DTO
- evidencia mínima de pruebas por consola

## 3. Alcance ejecutado
- Se verificó `ValidationPipe` activo en `src/main.ts`
- Se validó el comportamiento real del DTO de listado
- Se confirmó por consola la respuesta `400` para `tipo_identificacion` inválido
- Se confirmó por consola la respuesta `400` para `tipo_identificacion` vacío
- Se verificó `npm run build` en verde
- Se consolidó el cierre documental del sprint

## 4. Evidencia mínima de validación
- `grep -n "ValidationPipe" src/main.ts` → presente
- `npm run build` → exitoso
- `GET ?tipo_identificacion=INVALIDO` → `400 Bad Request`
- `GET ?tipo_identificacion=` → `400 Bad Request`

## 5. Resultado funcional
El endpoint GET `/api/v1/cases/:caseId/subjects` queda validado para:
- paginación
- filtro por `tipo`
- filtro por `nombre`
- filtro por `identificacion`
- filtro por `tipo_identificacion`
- rechazo de valores inválidos o vacíos en `tipo_identificacion`

## 6. Juicio metodológico
Sprint 21 cierra dentro del alcance aprobado.
No se ampliaron endpoints, no se agregaron filtros nuevos, no se introdujeron migraciones Prisma y no se alteró la política funcional del subrecurso.

## 7. Pendiente documental controlado
Si `docs/04_api/CONTRATO_API.md` aún no contiene el bloque explícito del GET `/api/v1/cases/:caseId/subjects`, debe incorporarse como ajuste documental inmediato posterior, sin reabrir alcance funcional.

## 8. Estado de cierre
Sprint 21 queda cerrado como sprint de consolidación funcional y documental del bloque `subjects`.
