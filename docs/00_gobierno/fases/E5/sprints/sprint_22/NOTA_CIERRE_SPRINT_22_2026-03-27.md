# NOTA DE CIERRE — SPRINT 22

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Consolidación / expansión controlada
- Sprint: 22
- Fecha de cierre: 2026-03-27
- Estado: CERRADO

## 2. Objetivo del sprint
Cerrar integralmente el subrecurso `subjects` mediante la consolidación contractual y funcional de:
- `POST /api/v1/cases/:caseId/subjects`
- `GET /api/v1/cases/:caseId/subjects/:subjectId`

## 3. Alcance ejecutado
- Se validó creación exitosa de sujeto (`201 Created`)
- Se validó consulta de detalle (`200 OK`)
- Se validó `404` por caso inexistente en create y detail
- Se validó `400` por payload inválido
- Se validó `404` por sujeto inexistente
- Se validó protección contra fuga entre casos
- Se confirmó política append-only mediante ausencia operativa de `PUT`
- Se verificó `npm run build` en verde
- Se actualizó el contrato API para create y detail

## 4. Evidencia mínima de validación
- `POST /subjects` válido → `201`
- `GET /subjects/:subjectId` válido → `200`
- `POST /subjects` con `caseId` inexistente → `404`
- `POST /subjects` inválido → `400`
- `GET /subjects/:subjectId` con sujeto inexistente → `404`
- `GET /subjects/:subjectId` con caso inexistente → `404`
- `GET /subjects/:subjectId` desde otro caso → `404`
- `PUT /subjects/:subjectId` → `404`
- `npm run build` → exitoso

## 5. Resultado funcional
El subrecurso `subjects` queda cerrado integralmente bajo política append-only con tres operaciones consolidadas:
- GET lista
- POST create
- GET detalle

## 6. Juicio metodológico
Sprint 22 cierra dentro del alcance aprobado.
No se abrieron endpoints nuevos, no se agregaron campos, no se habilitaron operaciones mutables y no se introdujeron migraciones Prisma.

## 7. Estado de cierre
Sprint 22 queda cerrado como sprint de cierre integral del subrecurso `subjects`.
