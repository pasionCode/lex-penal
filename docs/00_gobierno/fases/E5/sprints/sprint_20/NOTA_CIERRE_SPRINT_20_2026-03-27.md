# NOTA DE CIERRE SPRINT 20 — 2026-03-27

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Consolidación / expansión controlada
- Sprint: Sprint 20 — Hardening de `subjects`
- Fecha de cierre: 2026-03-27
- Estado: CERRADO

## 2. Objetivo del sprint
Extender el endpoint de listado de `subjects` para aceptar filtro por `tipo_identificacion`, manteniendo compatibilidad con:
- paginación existente
- filtro por `tipo`
- filtro por `nombre`
- filtro por `identificacion`

## 3. Alcance ejecutado
Se implementó soporte de `tipo_identificacion` en:
- `ListSubjectsQueryDto`
- `SubjectsController`
- `SubjectsService`
- `SubjectsRepository`

## 4. Ajustes realizados
- Se agregó `tipo_identificacion` como query param opcional en el listado.
- Se endureció la validación con enum `TipoIdentificacion`.
- Se rechazaron valores vacíos y valores inválidos.
- Se mantuvo el conteo (`total`) consistente con el mismo `where` de paginación.
- Se eliminó el uso de tipado laxo para este filtro en el repositorio.

## 5. Validaciones ejecutadas
### 5.1 Build
- `npm run build` → OK

### 5.2 Runtime
- GET `/cases/:caseId/subjects` sin filtros → 200 OK
- GET con `?tipo_identificacion=CC` → 200 OK, coincidencia correcta
- GET con `?tipo_identificacion=CC&page=1&per_page=1` → 200 OK, paginación consistente
- GET con `?tipo_identificacion=CC&identificacion=1234567890` → 200 OK, filtros coexistiendo
- GET con `?tipo_identificacion=` → 400 Bad Request
- GET con `?tipo_identificacion=   ` → 400 Bad Request
- GET con `?tipo_identificacion=XYZ` → 400 Bad Request

## 6. Resultado
Sprint 20 queda cerrado con implementación funcional y validación por consola satisfactoria.

## 7. Riesgos / deuda no bloqueante
- Se observa deuda de encoding en algunos nombres con tildes en la respuesta runtime.
- No bloquea el cierre del sprint, pero debe registrarse para backlog técnico.

## 8. Juicio de alineación con MDS
El sprint se mantuvo dentro de un cambio pequeño, controlado y trazable, sin expandir alcance fuera del subrecurso `subjects`.

## 9. Estado final
- Sprint 20: CERRADO
- Cambio: APROBADO
