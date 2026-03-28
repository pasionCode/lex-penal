# NOTA DE CIERRE UNIDAD E5-09 — 2026-03-28

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5
- Unidad: E5-09 — Validación runtime y cierre funcional de subjects
- Fecha de cierre: 2026-03-28
- Estado: CERRADA

## 2. Objetivo
Validar y cerrar funcionalmente la superficie del subrecurso `subjects`, sin cambios preventivos de implementación.

## 3. Alcance validado
- `GET /api/v1/cases/{caseId}/subjects`
- `POST /api/v1/cases/{caseId}/subjects`
- `GET /api/v1/cases/{caseId}/subjects/{subjectId}`

Fuera de alcance:
- `PUT`
- `DELETE`
- refactor de enums
- mapper de respuesta
- cambios preventivos sobre repository/service

## 4. Resultado
La superficie expuesta por controller quedó validada con autenticación por `JwtAuthGuard`, paginación operativa, filtros básicos y protección contra fuga entre casos.

## 5. Evidencia de validación

### 5.1 Runtime
Script `test_e5_09.sh` ejecutado con resultado:

- 16 pruebas pasadas
- 0 fallidas

Validaciones satisfactorias:
- `POST /subjects` → `201`
- `GET /subjects` → `200`
- `GET /subjects/:id` → `200`
- caso inexistente → `404`
- sujeto inexistente → `404`
- fuga entre casos → `404`
- página fuera de rango → `200` con `data: []`
- filtro por tipo funcional
- acceso sin token → `401`

### 5.2 Build
- `npm run build` → OK

## 6. Observaciones
- El módulo no implementa control de perfil; la protección validada corresponde a autenticación (`401`) y no a autorización por rol (`403`).
- Se mantiene como observación no bloqueante la consistencia de enums entre DTO y Prisma.
- La observación de caracteres mal renderizados en Git Bash corresponde al encoding del terminal, no a un bug confirmado del backend.

## 7. Estado de cierre
La unidad E5-09 queda cerrada técnica y documentalmente.
