# NOTA DE CIERRE SPRINT 18 — 2026-03-27

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Expansión funcional controlada
- Sprint: 18
- Estado: CERRADO
- Foco: filtro opcional por `nombre` en listado de `subjects`

## 2. Objetivo del sprint
Extender el endpoint de listado de `subjects` para soportar filtro opcional por `nombre`, compatible con `tipo`, paginación y política append-only.

## 3. Alcance ejecutado
- DTO de listado actualizado con `nombre`
- Propagación controller → service → repository
- Filtrado parcial case-insensitive por `nombre`
- Compatibilidad con filtro `tipo`
- Validación 400 para `nombre` vacío o con solo espacios
- Contrato API alineado
- Nota de cierre documentada con evidencia runtime

## 4. Validaciones ejecutadas
- GET `?nombre=Test` → 200 OK, `data` con 2 coincidencias, `total=2`
- GET `?tipo=victima&nombre=Test` → 200 OK, `data=[]`, `total=0`
- GET `?tipo=imputado&nombre=Test` → 200 OK, `data` con 1 coincidencia, `total=1`
- GET `?tipo=testigo&nombre=Test` → 200 OK, `data` con 1 coincidencia, `total=1`
- GET `?nombre=Test&page=1&per_page=1` → 200 OK, `data` paginada, `total=2`, `per_page=1`
- GET `?nombre=%20%20` → 400 Bad Request
- GET detalle individual `/subjects/{subjectId}` → 200 OK regresión validada

## 5. Resultado
Sprint 18 implementa correctamente el filtro por `nombre` en `subjects`, preservando compatibilidad con `tipo`, paginación y respuesta estándar del endpoint, sin evidencia de regresión funcional en el detalle individual.

## 6. Hallazgos
- Durante el sprint se corrigió una inconsistencia previa de tipado de `TipoSujeto` entre DTO y Prisma.
- Se observó un posible problema de encoding en datos preexistentes (`María` visible como `Mar�a`), fuera de alcance del sprint.

## 7. Fuera de alcance preservado
- Sin cambios en POST de `subjects`
- Sin cambios funcionales en detalle individual más allá de regresión
- Sin búsqueda accent-insensitive
- Sin ordenamiento configurable
- Sin búsqueda por múltiples campos

## 8. Cierre metodológico
- Sprint de foco único
- Cambio acotado sobre baseline conocido
- Runtime y contrato alineados
- Sin desbordamiento de alcance
- Evidencia suficiente para cierre
