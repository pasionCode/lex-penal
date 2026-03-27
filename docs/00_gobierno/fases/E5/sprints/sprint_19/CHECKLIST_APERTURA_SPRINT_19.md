# CHECKLIST DE APERTURA — SPRINT 19

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
| Sprint | 19 |
| Fase | E5 — Expansión funcional controlada |
| Foco | Hardening de `subjects` — filtro por `identificacion` |
| Fecha | 2026-03-27 |
| Commit base | `8a01663` |

---

## 1. Contexto

Sprint 18 cerró con filtro por `nombre` funcional en `GET /subjects`.  
El endpoint ya acepta `page`, `per_page`, `tipo` y `nombre`, retorna estructura paginada y valida `nombre` vacío con `400`.

Sprint 19 extiende el endpoint para aceptar filtro por `identificacion` sin alterar:
- la paginación,
- el filtro por `tipo`,
- el filtro por `nombre`,
- ni la política append-only.

**Secuencia del módulo subjects:**
- S15: creación del subrecurso (CRUD append-only)
- S16: paginación
- S17: filtro por `tipo`
- S18: filtro por `nombre`
- **S19: filtro por `identificacion`**

---

## 2. Baseline actual

### 2.1 Endpoint actual
```http
GET /api/v1/cases/{caseId}/subjects
Authorization: Bearer {token}
```

### 2.2 Estado esperado pre-intervención

El endpoint ya debe:
- aceptar `page`, `per_page`, `tipo` y `nombre`,
- responder `{ data, total, page, per_page }`,
- no aceptar aún filtro por `identificacion`.

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

Confirmar sujetos actuales del caso y, si ninguno tiene `identificacion` útil para prueba positiva, crear o ubicar un registro controlado antes de la intervención.

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

### 3.2 Comportamiento del filtro `identificacion`

- Se aplica sobre el campo `identificacion` del sujeto
- Comparación exacta
- Se normaliza con `trim`
- Si tras normalización queda vacío: `400 Bad Request`
- Compatible con `tipo` y `nombre`
- `count` debe reflejar la colección ya filtrada

### 3.3 Comportamiento esperado

- Si no se envía `identificacion`: comportamiento actual de S18
- Si se envía `identificacion` válida: filtra antes de paginar
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

---

## 4. Checklist de implementación

### 4.1 Pre-vuelo

- [ ] Verificar servidor corriendo en puerto 3001
- [ ] Confirmar commit base con `git rev-parse --short HEAD`
- [ ] Confirmar baseline real de los archivos involucrados
- [ ] Confirmar que el endpoint responde paginado con `tipo` y `nombre`
- [ ] Confirmar `caseId` de pruebas
- [ ] Confirmar existencia de al menos un sujeto con `identificacion` útil para prueba positiva
- [ ] Si no existe baseline apto, crear dato controlado antes de desarrollar

### 4.2 Implementación

- [ ] Extender `ListSubjectsQueryDto` para aceptar `identificacion`
- [ ] Validar `identificacion` como string opcional no vacío
- [ ] Normalizar valor de `identificacion` para evitar blancos
- [ ] Modificar controller para propagar `query.identificacion`
- [ ] Modificar service para recibir y propagar `identificacion`
- [ ] Modificar repository para filtrar por `identificacion`
- [ ] Mantener compatibilidad con filtros `tipo` y `nombre`
- [ ] Asegurar que `count` refleje la colección filtrada
- [ ] Mantener intacta la respuesta `{ data, total, page, per_page }`

### 4.3 Pruebas runtime

| # | Prueba | Esperado |
|---|--------|----------|
| 1 | GET sin filtros | 200, comportamiento actual |
| 2 | GET `?identificacion=<valor_valido>` | 200, 1 coincidencia esperada |
| 3 | GET `?identificacion=<valor_inexistente>` | 200, `data=[]`, `total=0` |
| 4 | GET `?identificacion=%20%20` | 400 validación |
| 5 | GET `?identificacion=<valor>&page=1&per_page=1` | 200, filtro + paginación |
| 6 | GET `?tipo=<tipo_valido>&identificacion=<valor>` | 200, filtros coexistiendo |
| 7 | GET `?nombre=<fragmento>&identificacion=<valor>` | 200, filtros coexistiendo |
| 8 | GET detalle existente | 200 regresión |

### 4.4 Contrato

- [ ] Actualizar sección de `GET /subjects` en `CONTRATO_API.md`
- [ ] Documentar query param `identificacion`
- [ ] Documentar comparación exacta
- [ ] Documentar convivencia con `tipo` y `nombre`
- [ ] Documentar que el filtro aplica antes de paginación
- [ ] Actualizar historial de cambios
- [ ] Actualizar metadata superior del contrato

### 4.5 Documentación de cierre

- [ ] `NOTA_CIERRE_SPRINT_19_2026-03-27.md`
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
| Filtro por `tipo_identificacion` | Se reserva para sprint posterior |

---

## 6. Riesgos

| Riesgo | Mitigación |
|--------|------------|
| No existir dato base con identificación | Preparar baseline controlado antes de intervenir |
| `count` incorrecto con filtros compuestos | Validar `total` sobre colección filtrada |
| Espacios en blanco generando falsos positivos | Normalizar y rechazar vacío |
| Ruptura de paginación | Probar `identificacion + page + per_page` |
| Regresión de filtros previos | Ejecutar prueba combinada con `tipo` y `nombre` |

---

## 7. Criterios de cierre

- [ ] GET `/subjects` acepta `identificacion`
- [ ] `identificacion` válida filtra correctamente
- [ ] `identificacion` vacía responde 400
- [ ] `identificacion` convive con `tipo`
- [ ] `identificacion` convive con `nombre`
- [ ] Filtro y paginación conviven correctamente
- [ ] 8 pruebas runtime verdes
- [ ] Contrato actualizado
- [ ] Nota de cierre documentada
- [ ] Commit realizado
- [ ] Push a main realizado

---

*Checklist generado: 2026-03-27*
