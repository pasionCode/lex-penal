# CHECKLIST DE APERTURA — SPRINT 20

**Micronota metodológica de arranque**

Este sprint se abre bajo MDS + buen gobierno.
Reglas de conducción:

- foco único;
- baseline antes de intervenir;
- contrato y runtime deben quedar alineados;
- no se aceptan cambios colados por fuera del alcance;
- al cierre se validará técnica, metodología y trazabilidad documental.

| Campo | Valor |
|-------|-------|
| Sprint | 20 |
| Fase | E5 — Expansión funcional controlada |
| Foco | Hardening de `subjects` — filtro por `tipo_identificacion` |
| Fecha | 2026-03-27 |
| Commit base | `e4f9875` |

---

## 1. Contexto

Sprint 19 cerró con filtro por `identificacion` funcional en `GET /subjects`.
El endpoint ya acepta `page`, `per_page`, `tipo`, `nombre` e `identificacion`, retorna estructura paginada y valida `identificacion` vacía con `400`.

Sprint 20 extiende el endpoint para aceptar filtro por `tipo_identificacion` sin alterar:
- la paginación,
- el filtro por `tipo`,
- el filtro por `nombre`,
- el filtro por `identificacion`,
- ni la política append-only.

**Secuencia del módulo subjects:**
- S15: creación del subrecurso (CRUD append-only)
- S16: paginación
- S17: filtro por `tipo`
- S18: filtro por `nombre`
- S19: filtro por `identificacion`
- **S20: filtro por `tipo_identificacion`**

---

## 2. Baseline actual

### 2.1 Endpoint actual
```http
GET /api/v1/cases/{caseId}/subjects
Authorization: Bearer {token}
```

### 2.2 Estado esperado pre-intervención

El endpoint ya debe:
- aceptar `page`, `per_page`, `tipo`, `nombre` e `identificacion`,
- responder `{ data, total, page, per_page }`,
- no aceptar aún filtro por `tipo_identificacion`.

### 2.3 Archivos involucrados

| Archivo | Rol |
|---------|-----|
| `src/modules/subjects/dto/list-subjects-query.dto.ts` | DTO de query actual |
| `src/modules/subjects/subjects.controller.ts` | Endpoint GET |
| `src/modules/subjects/subjects.service.ts` | Lógica de negocio |
| `src/modules/subjects/subjects.repository.ts` | Acceso a datos |
| `docs/04_api/CONTRATO_API.md` | Contrato de subjects |

### 2.4 Caso de prueba base

`c9f0c313-1042-42f7-8371-faa89fd84f42`

### 2.5 Baseline de datos

Confirmar sujetos actuales del caso y, si ninguno tiene `tipo_identificacion` útil para prueba positiva, crear o ubicar un registro controlado antes de la intervención.

**Regla de conducción:** no improvisar pruebas con datos inciertos.

---

## 3. Diseño propuesto

### 3.1 Parámetros de query

| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `page` | number | 1 | Página actual |
| `per_page` | number | 20 | Elementos por página |
| `tipo` | enum | — | Filtra por tipo procesal |
| `nombre` | string | — | Filtra por coincidencia parcial en nombre |
| `identificacion` | string | — | Filtra por coincidencia exacta en identificación |
| `tipo_identificacion` | enum/string | — | Filtra por tipo de identificación |

### 3.2 Comportamiento del filtro `tipo_identificacion`

- Se aplica sobre el campo `tipo_identificacion` del sujeto
- Comparación exacta
- Se normaliza con `trim` si el tipo en query llega como string
- Si tras normalización queda vacío: `400 Bad Request`
- Compatible con `tipo`, `nombre` e `identificacion`
- `count` debe reflejar la colección ya filtrada

### 3.3 Comportamiento esperado

- Si no se envía `tipo_identificacion`: comportamiento actual de S19
- Si se envía `tipo_identificacion` válida: filtra antes de paginar
- Si no coincide con registros: `200 OK` con `data: []`, `total: 0`
- Si es vacío o solo espacios: `400 Bad Request`

### 3.4 Criterio de diseño

El cambio aplica solo al listado. No modifica:
- `POST /subjects`
- `GET /subjects/{subjectId}`
- política append-only
- estructura paginada ya adoptada
- orden por defecto actual
- reglas de búsqueda parcial de `nombre`
- reglas de coincidencia exacta de `identificacion`

---

## 4. Checklist de implementación

### 4.1 Pre-vuelo

- [ ] Verificar servidor corriendo en puerto 3001
- [ ] Confirmar commit base con `git rev-parse --short HEAD`
- [ ] Confirmar baseline real de los archivos involucrados
- [ ] Confirmar que el endpoint responde paginado con `tipo`, `nombre` e `identificacion`
- [ ] Confirmar `caseId` de pruebas
- [ ] Confirmar existencia de al menos un sujeto con `tipo_identificacion` útil para prueba positiva
- [ ] Si no existe baseline apto, crear dato controlado antes de desarrollar

### 4.2 Implementación

- [ ] Extender `ListSubjectsQueryDto` para aceptar `tipo_identificacion`
- [ ] Validar `tipo_identificacion` como parámetro opcional no vacío
- [ ] Normalizar valor de `tipo_identificacion` para evitar blancos si aplica
- [ ] Modificar controller para propagar `query.tipo_identificacion`
- [ ] Modificar service para recibir y propagar `tipo_identificacion`
- [ ] Modificar repository para filtrar por `tipo_identificacion`
- [ ] Mantener compatibilidad con filtros `tipo`, `nombre` e `identificacion`
- [ ] Asegurar que `count` refleje la colección filtrada
- [ ] Mantener intacta la respuesta `{ data, total, page, per_page }`

### 4.3 Pruebas runtime

| # | Prueba | Esperado |
|---|--------|----------|
| 1 | GET sin filtros | 200, comportamiento actual |
| 2 | GET `?tipo_identificacion=<valor_valido>` | 200, coincidencia esperada |
| 3 | GET `?tipo_identificacion=<valor_inexistente>` | 200, `data=[]`, `total=0` |
| 4 | GET `?tipo_identificacion=%20%20` | 400 validación |
| 5 | GET `?tipo_identificacion=<valor>&page=1&per_page=1` | 200, filtro + paginación |
| 6 | GET `?identificacion=<valor>&tipo_identificacion=<valor>` | 200, filtros coexistiendo |
| 7 | GET `?tipo=<tipo_valido>&tipo_identificacion=<valor>` | 200, filtros coexistiendo |
| 8 | GET `?nombre=<fragmento>&tipo_identificacion=<valor>` | 200, filtros coexistiendo |
| 9 | GET detalle existente | 200 regresión |

### 4.4 Contrato

- [ ] Actualizar sección de `GET /subjects` en `CONTRATO_API.md`
- [ ] Documentar query param `tipo_identificacion`
- [ ] Documentar comparación exacta
- [ ] Documentar convivencia con `tipo`, `nombre` e `identificacion`
- [ ] Documentar que el filtro aplica antes de paginación
- [ ] Actualizar historial de cambios
- [ ] Actualizar metadata superior del contrato

### 4.5 Documentación de cierre

- [ ] `NOTA_CIERRE_SPRINT_20_2026-03-27.md`
- [ ] Commit con mensaje convencional
- [ ] Push a main

---

## 5. Fuera de alcance

| Ítem | Razón |
|------|-------|
| Ordenamiento configurable | Mantener foco único |
| Búsqueda por múltiples campos arbitrarios | Superficie mayor |
| Reglas de relevancia o ranking | No aprobado |
| Cambios en POST o GET detalle | Solo regresión |
| Búsqueda accent-insensitive | No aplica al foco |
| Nuevo subrecurso | Rompe continuidad de conducción |
| Cambios de política append-only | No autorizado |
| Filtro por rangos o listas de tipos de documento | Se reserva para sprint posterior |

---

## 6. Riesgos

| Riesgo | Mitigación |
|--------|------------|
| No existir dato base con tipo de identificación | Preparar baseline controlado antes de intervenir |
| `count` incorrecto con filtros compuestos | Validar `total` sobre colección filtrada |
| Espacios en blanco generando falsos positivos | Normalizar y rechazar vacío |
| Ruptura de paginación | Probar `tipo_identificacion + page + per_page` |
| Regresión de filtros previos | Ejecutar pruebas combinadas con `tipo`, `nombre` e `identificacion` |

---

## 7. Criterios de cierre

- [ ] GET `/subjects` acepta `tipo_identificacion`
- [ ] `tipo_identificacion` válida filtra correctamente
- [ ] `tipo_identificacion` vacía responde 400
- [ ] `tipo_identificacion` convive con `identificacion`
- [ ] `tipo_identificacion` convive con `tipo`
- [ ] `tipo_identificacion` convive con `nombre`
- [ ] Filtro y paginación conviven correctamente
- [ ] 9 pruebas runtime verdes
- [ ] Contrato actualizado
- [ ] Nota de cierre documentada
- [ ] Commit realizado
- [ ] Push a main realizado

---

*Checklist generado: 2026-03-27*
