# NOTA DE CIERRE SPRINT 19 — 2026-03-27

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Expansión funcional controlada
- Sprint: 19
- Estado: CERRADO
- Foco: filtro opcional por `identificacion` en listado de `subjects`

## 2. Objetivo del sprint
Extender el endpoint de listado de `subjects` para soportar filtro opcional por `identificacion`, compatible con `tipo`, `nombre`, paginación y política append-only.

## 3. Alcance ejecutado
- DTO de listado actualizado con `identificacion`
- Propagación controller → service → repository
- Filtrado exacto por `identificacion`
- Compatibilidad con filtros `tipo` y `nombre`
- Validación 400 para `identificacion` vacía o con solo espacios
- Contrato API a actualizar en este cierre
- Evidencia runtime documentada

## 4. Validaciones ejecutadas
- Pre-S19: `?identificacion=1234567890` → `400 Bad Request` con mensaje `property identificacion should not exist`
- GET `?identificacion=1234567890` → 200 OK, `data` con 1 coincidencia, `total=1`
- GET `?identificacion=0000000000` → 200 OK, `data=[]`, `total=0`
- GET `?identificacion=%20%20` → 400 Bad Request
- GET `?identificacion=1234567890&page=1&per_page=1` → 200 OK, `data` paginada, `total=1`
- GET `?tipo=victima&identificacion=1234567890` → 200 OK, `data` con 1 coincidencia, `total=1`
- GET `?nombre=Juan&identificacion=1234567890` → 200 OK, `data` con 1 coincidencia, `total=1`
- GET detalle individual `/subjects/{subjectId}` → 200 OK regresión validada

## 5. Resultado
Sprint 19 implementa correctamente el filtro por `identificacion` en `subjects`, preservando compatibilidad con `tipo`, `nombre`, paginación y respuesta estándar del endpoint, sin evidencia de regresión funcional en el detalle individual.

## 6. Hallazgos
- Se mantiene observable un posible problema de encoding en datos preexistentes (`Pérez`, `García` visibles con caracteres degradados), fuera de alcance del sprint.
- El mensaje de validación permanece en inglés (`identificacion should not be empty`), aceptable para backend actual pero susceptible de hardening posterior.

## 7. Fuera de alcance preservado
- Sin cambios en POST de `subjects`
- Sin cambios funcionales en detalle individual más allá de regresión
- Sin búsqueda accent-insensitive
- Sin ordenamiento configurable
- Sin filtro por `tipo_identificacion`
- Sin búsqueda por múltiples campos arbitrarios

## 8. Cierre metodológico
- Sprint de foco único
- Cambio acotado sobre baseline conocido
- Runtime y contrato alineados
- Sin desbordamiento de alcance
- Evidencia suficiente para cierre
