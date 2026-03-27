# CHECKLIST DE APERTURA — SPRINT 17

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
| Sprint | 17 |
| Fase | E5 — Expansión funcional controlada |
| Foco | Hardening de `subjects` — filtro por tipo |
| Fecha | 2026-03-27 |
| Commit base | `ddacc21` |

---

## 1. Contexto

Sprint 15 implementó el subrecurso `subjects` con política append-only.
Sprint 16 incorporó paginación en `GET /api/v1/cases/{caseId}/subjects`, incluyendo `page`, `per_page`, respuesta paginada y comportamiento de página fuera de rango. También dejó explícitamente fuera de alcance los filtros por `tipo` o `nombre`, y al cierre propuso como siguiente opción natural del Sprint 17 el filtro por `tipo`.

**Deuda funcional identificada post-S16:**
- No existe filtro por `tipo` en GET `/subjects`.
- La paginación ya existe; el siguiente paso controlado es filtrar sin alterar la política append-only ni introducir otras variables.

---

## 2. Baseline actual

### 2.1 Endpoint actual

```
GET /api/v1/cases/{caseId}/subjects
```

### 2.2 Estado esperado pre-intervención

El endpoint ya debe:
- aceptar `page` y `per_page`,
- responder `{ data, total, page, per_page }`,
- no aceptar aún filtro por `tipo`.

### 2.3 Archivos involucrados

| Archivo | Rol |
|---------|-----|
| `src/modules/subjects/dto/list-subjects-query.dto.ts` | DTO de query actual |
| `src/modules/subjects/dto/index.ts` | Export del DTO |
| `src/modules/subjects/subjects.controller.ts` | Endpoint GET |
| `src/modules/subjects/subjects.service.ts` | Lógica de negocio |
| `src/modules/subjects/subjects.repository.ts` | Acceso a datos |
| `docs/04_api/CONTRATO_API.md` | Contrato de subjects |

### 2.4 Caso de prueba base

Usar el mismo caseId de validación de S16:
`c9f0c313-1042-42f7-8371-faa89fd84f42`

---

## 3. Diseño propuesto

### 3.1 Parámetros de query

| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `page` | number | 1 | Página actual |
| `per_page` | number | 20 | Elementos por página |
| `tipo` | enum/string | — | Filtra sujetos por tipo procesal |

### 3.2 Valores válidos de `tipo`

Tomar como referencia contractual los tipos ya documentados para subjects:
`victima`, `imputado`, `testigo`, `apoderado`, `otro`.

### 3.3 Comportamiento esperado

- Si no se envía `tipo`: comportamiento actual de S16.
- Si se envía `tipo` válido: filtra la colección antes de paginar.
- Si `tipo` no coincide con registros existentes: `200 OK` con `data: []`, `total: 0`.
- Si `tipo` es inválido: `400 Bad Request`.

### 3.4 Criterio de diseño

El filtro debe aplicarse solo al listado.
No modifica:
- `POST /subjects`
- `GET /subjects/{subjectId}`
- política append-only
- estructura paginada ya adoptada en S16.

---

## 4. Checklist de implementación

### 4.1 Pre-vuelo

- [ ] Verificar servidor corriendo en puerto 3001
- [ ] Confirmar commit base con `git rev-parse --short HEAD`
- [ ] Confirmar baseline real de:
  - `subjects.controller.ts`
  - `subjects.service.ts`
  - `subjects.repository.ts`
  - `list-subjects-query.dto.ts`
- [ ] Confirmar que el endpoint actual responde paginado como en S16
- [ ] Confirmar caseId de pruebas
- [ ] Confirmar al menos dos sujetos con tipos distintos para probar filtro real; si no existen, crear datos controlados

### 4.2 Implementación

- [ ] Extender `ListSubjectsQueryDto` para aceptar `tipo`
- [ ] Validar `tipo` contra conjunto permitido
- [ ] Modificar controller para recibir `tipo` dentro del query DTO
- [ ] Modificar service para propagar `tipo` al repository
- [ ] Modificar repository para filtrar por `tipo` y conservar paginación
- [ ] Asegurar que el `count` refleje la colección filtrada y no la total sin filtro
- [ ] Mantener intacta la respuesta `{ data, total, page, per_page }`

### 4.3 Pruebas runtime

| # | Prueba | Esperado |
|---|--------|----------|
| 1 | GET sin tipo | 200, comportamiento actual |
| 2 | GET ?tipo=victima | 200, solo víctimas |
| 3 | GET ?tipo=testigo | 200, solo testigos |
| 4 | GET ?tipo=otro sin registros | 200, data=[], total=0 |
| 5 | GET ?tipo=invalido | 400 validación |
| 6 | GET ?tipo=victima&page=1&per_page=1 | 200, filtro + paginación coexistiendo |
| 7 | POST sigue funcionando | 201 |
| 8 | GET detalle sigue funcionando | 200 |

### 4.4 Contrato

- [ ] Actualizar sección 6.1 de `CONTRATO_API.md`
- [ ] Documentar query param `tipo`
- [ ] Documentar valores válidos
- [ ] Documentar que el filtro se aplica antes de paginación
- [ ] Actualizar historial de cambios

### 4.5 Documentación de cierre

- [ ] `BASELINE_SUBJECTS_FILTRO_TIPO_SPRINT_17_2026-03-27.md`
- [ ] `NOTA_CIERRE_SPRINT_17_2026-03-27.md`
- [ ] Commit con mensaje convencional
- [ ] Push a main

---

## 5. Fuera de alcance

| Ítem | Razón |
|------|-------|
| Filtro por nombre | Mantener foco único |
| Ordenamiento configurable | No aprobado para S17 |
| Combinación de múltiples filtros | Aumenta complejidad sin necesidad |
| Cambios en POST o GET detalle | Solo regresión |
| Alineación enums DTO/Prisma | Sigue siendo deuda menor |
| Nuevo subrecurso | Rompe continuidad de conducción |
| Transiciones de estado del caso | Superficie mayor, posponer |

---

## 6. Riesgos

| Riesgo | Mitigación |
|--------|------------|
| Validación inconsistente del tipo | Tomar catálogo contractual existente |
| `count` incorrecto al aplicar filtro | Validar `total` sobre colección filtrada |
| Cambio colateral en paginación | Probar combinación filtro + paginación |
| Falta de datos para probar tipos distintos | Crear registros controlados de prueba |

---

## 7. Criterios de cierre

- [ ] GET `/subjects` acepta `tipo`
- [ ] `tipo` válido filtra correctamente
- [ ] `tipo` inválido responde 400
- [ ] Filtro y paginación conviven correctamente
- [ ] 8 pruebas runtime verdes
- [ ] Contrato actualizado
- [ ] Baseline documentado
- [ ] Nota de cierre documentada
- [ ] Commit pusheado a main

---

**Observación del analista**

Esta es la mejor apertura para S17 porque mantiene la secuencia natural del módulo `subjects`:
S15 creación del subrecurso → S16 paginación → S17 filtro mínimo por tipo. Eso conserva orden, baja complejidad y trazabilidad.

---

*Checklist generado: 2026-03-27*
