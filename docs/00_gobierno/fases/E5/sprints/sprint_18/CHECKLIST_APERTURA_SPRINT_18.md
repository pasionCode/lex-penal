# CHECKLIST DE APERTURA — SPRINT 18

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
| Sprint | 18 |
| Fase | E5 — Expansión funcional controlada |
| Foco | Hardening de `subjects` — filtro por nombre |
| Fecha | 2026-03-27 |
| Commit base | (pendiente confirmar) |

---

## 1. Contexto

Sprint 17 cerró con filtro por `tipo` funcional en `GET /subjects`. El endpoint
acepta `page`, `per_page` y `tipo`, retorna estructura paginada, y valida el
enum de tipos.

Sprint 18 extiende el endpoint para aceptar filtro por `nombre` sin alterar
la paginación, el filtro por `tipo` ni la política append-only.

**Secuencia del módulo subjects:**
- S15: creación del subrecurso (CRUD append-only)
- S16: paginación
- S17: filtro por tipo
- **S18: filtro por nombre**

---

## 2. Baseline actual

### 2.1 Endpoint actual
```
GET /api/v1/cases/{caseId}/subjects
Authorization: Bearer {token}
```

### 2.2 Estado esperado pre-intervención

El endpoint ya debe:
- aceptar `page`, `per_page` y `tipo`,
- responder `{ data, total, page, per_page }`,
- no aceptar aún filtro por `nombre`.

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

### 2.5 Datos de prueba existentes (post-S17)

| ID | Tipo | Nombre |
|----|------|--------|
| `c1834348-6f95-42fa-b2f4-a143cff789f3` | victima | Juan Pérez García |
| `440c0ec4-5d05-4aed-90f2-2767759b3015` | testigo | María López Test S16 |
| `6cff5b53-e8a0-45a3-ac7a-48a08621e190` | imputado | Test S17 Regresion |

**Total:** 3 sujetos (baseline actualizado post-S17).

---

## 3. Diseño propuesto

### 3.1 Parámetros de query

| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `page` | number | 1 | Página actual |
| `per_page` | number | 20 | Elementos por página |
| `tipo` | enum | — | Filtra por tipo procesal |
| `nombre` | string | — | Filtra por coincidencia parcial en nombre |

### 3.2 Comportamiento del filtro `nombre`

- Búsqueda parcial (contains)
- Case-insensitive
- Se aplica sobre el campo `nombre` del sujeto
- Compatible con filtro por `tipo` (ambos pueden usarse simultáneamente)
- `count` debe reflejar la colección ya filtrada

### 3.3 Comportamiento esperado

- Si no se envía `nombre`: comportamiento actual de S17.
- Si se envía `nombre` válido: filtra la colección antes de paginar.
- Si `nombre` no coincide con registros: `200 OK` con `data: []`, `total: 0`.
- Si `nombre` es vacío o solo espacios: `400 Bad Request`.

### 3.4 Criterio de diseño

El cambio aplica solo al listado. No modifica:
- `POST /subjects`
- `GET /subjects/{subjectId}`
- política append-only
- estructura paginada ya adoptada
- orden por defecto actual

---

## 4. Checklist de implementación

### 4.1 Pre-vuelo

- [ ] Verificar servidor corriendo en puerto 3001
- [ ] Confirmar commit base con `git rev-parse --short HEAD`
- [ ] Confirmar baseline real de los 4 archivos involucrados
- [ ] Confirmar que el endpoint responde paginado y con filtro por `tipo`
- [ ] Confirmar caseId de pruebas
- [ ] Confirmar baseline de 3 sujetos

### 4.2 Implementación

- [ ] Extender `ListSubjectsQueryDto` para aceptar `nombre`
- [ ] Validar `nombre` como string opcional no vacío
- [ ] Normalizar valor de `nombre` para evitar blancos
- [ ] Modificar controller para propagar `query.nombre`
- [ ] Modificar service para recibir y propagar `nombre`
- [ ] Modificar repository para filtrar por `nombre`
- [ ] Mantener compatibilidad con filtro por `tipo`
- [ ] Asegurar que `count` refleje la colección filtrada
- [ ] Mantener intacta la respuesta `{ data, total, page, per_page }`

### 4.3 Pruebas runtime

| # | Prueba | Esperado |
|---|--------|----------|
| 1 | GET sin filtros | 200, comportamiento actual |
| 2 | GET `?nombre=Juan` | 200, 1 coincidencia |
| 3 | GET `?nombre=Test` | 200, coincidencias parciales |
| 4 | GET `?nombre=zzz` | 200, `data=[]`, `total=0` |
| 5 | GET `?nombre=%20%20` | 400 validación |
| 6 | GET `?nombre=Test&page=1&per_page=1` | 200, filtro + paginación |
| 7 | GET `?tipo=imputado&nombre=Test` | 200, filtros coexistiendo |
| 8 | GET detalle existente | 200 regresión |

### 4.4 Contrato

- [ ] Actualizar sección 6.1 de `CONTRATO_API.md`
- [ ] Documentar query param `nombre`
- [ ] Documentar búsqueda parcial case-insensitive
- [ ] Documentar convivencia con `tipo`
- [ ] Documentar que el filtro aplica antes de paginación
- [ ] Actualizar historial de cambios
- [ ] Actualizar metadata superior del contrato

### 4.5 Documentación de cierre

- [ ] `NOTA_CIERRE_SPRINT_18_2026-03-27.md`
- [ ] Commit con mensaje convencional
- [ ] Push a main

---

## 5. Fuera de alcance

| Ítem | Razón |
|------|-------|
| Ordenamiento configurable | Mantener foco único |
| Búsqueda por múltiples campos | Superficie mayor |
| Reglas de relevancia o ranking | No aprobado |
| Cambios en POST o GET detalle | Solo regresión |
| Corrección de encoding histórico | Deuda aparte |
| Nuevo subrecurso | Rompe continuidad de conducción |
| Cambios de política append-only | No autorizado |

---

## 6. Riesgos

| Riesgo | Mitigación |
|--------|------------|
| `count` incorrecto con filtros compuestos | Validar `total` sobre colección filtrada |
| Búsqueda sensible a mayúsculas/minúsculas | Forzar comparación case-insensitive |
| Espacios en blanco generando falsos positivos | Normalizar y rechazar vacío |
| Ruptura de paginación | Probar `nombre + page + per_page` |
| Regresión del filtro por `tipo` | Ejecutar prueba combinada |

---

## 7. Criterios de cierre

- [ ] GET `/subjects` acepta `nombre`
- [ ] `nombre` válido filtra correctamente
- [ ] `nombre` vacío responde 400
- [ ] `nombre` y `tipo` conviven correctamente
- [ ] Filtro y paginación conviven correctamente
- [ ] 8 pruebas runtime verdes
- [ ] Contrato actualizado
- [ ] Nota de cierre documentada
- [ ] Commit realizado
- [ ] Push a main realizado

---

*Checklist generado: 2026-03-27*
