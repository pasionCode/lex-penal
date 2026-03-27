# Checklist de apertura — Sprint 16

| Campo | Valor |
|-------|-------|
| Sprint | 16 |
| Fase | E5 — Expansión funcional controlada |
| Foco | Hardening de `subjects` — paginación |
| Fecha | 2026-03-27 |
| Commit base | `b6f4db2` |

---

## 1. Contexto

Sprint 15 implementó el subrecurso `subjects` con política append-only (GET lista, POST, GET detalle). El endpoint `GET /cases/{caseId}/subjects` actualmente retorna un array plano sin paginación, lo cual no escala para casos con muchos sujetos procesales.

**Deuda técnica identificada en S15:**
- Sin paginación en GET subjects (prioridad media)
- Enums duplicados DTO vs Prisma (prioridad baja)

**Alcance S16:**
- Paginación en `GET /cases/{caseId}/subjects`
- Filtros: **fuera de alcance** (decisión del PO)

---

## 2. Baseline actual

### 2.1 Endpoint actual

```
GET /api/v1/cases/{caseId}/subjects
Authorization: Bearer {token}
```

**Respuesta actual (200):**
```json
[
  {
    "id": "uuid",
    "caso_id": "uuid",
    "tipo": "victima",
    "nombre": "string",
    "identificacion": "string | null",
    "tipo_identificacion": "CC | null",
    "contacto": "string | null",
    "direccion": "string | null",
    "notas": "string | null",
    "creado_en": "datetime",
    "actualizado_en": "datetime",
    "creado_por": "uuid",
    "actualizado_por": "uuid | null"
  }
]
```

**Problema:** Array plano. Sin metadata de paginación.

### 2.2 Archivos involucrados

| Archivo | Rol |
|---------|-----|
| `src/modules/subjects/subjects.controller.ts` | Endpoint GET |
| `src/modules/subjects/subjects.service.ts` | Lógica de negocio |
| `src/modules/subjects/subjects.repository.ts` | Acceso a datos |
| `docs/04_api/CONTRATO_API.md` | Contrato (sección 6) |

### 2.3 Convención de paginación del proyecto

Según `CONTRATO_API.md` (convenciones generales):

> **Paginación**: parámetros `page` y `per_page` en endpoints de listado.

Ejemplo de respuesta paginada (sección 4, GET /cases):
```json
{
  "data": [...],
  "total": 42,
  "page": 1,
  "per_page": 20
}
```

---

## 3. Diseño propuesto

### 3.1 Parámetros de query

| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `page` | number | 1 | Página actual (1-indexed) |
| `per_page` | number | 20 | Elementos por página (max 100) |

### 3.2 Respuesta paginada

```json
{
  "data": [
    { "id": "...", "tipo": "victima", "nombre": "..." }
  ],
  "total": 45,
  "page": 1,
  "per_page": 20
}
```

### 3.3 DTO de query

```typescript
// src/modules/subjects/dto/list-subjects-query.dto.ts
export class ListSubjectsQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  per_page?: number = 20;
}
```

---

## 4. Checklist de implementación

### 4.1 Pre-vuelo

- [ ] Verificar servidor corriendo en puerto 3001
- [ ] Confirmar commit base `b6f4db2`
- [ ] Revisar baseline de `subjects.controller.ts`
- [ ] Confirmar caseId de pruebas: `c9f0c313-1042-42f7-8371-faa89fd84f42`

### 4.2 Implementación

- [ ] Crear `ListSubjectsQueryDto` con validaciones
- [ ] Modificar `SubjectsRepository.findAllByCaseId()` para aceptar paginación
- [ ] Modificar `SubjectsService.findAll()` para retornar estructura paginada
- [ ] Modificar `SubjectsController.findAll()` para recibir query params
- [ ] Actualizar `SubjectResponseDto` o crear wrapper de respuesta paginada

### 4.3 Pruebas runtime

| # | Prueba | Esperado |
|---|--------|----------|
| 1 | GET sin params | 200, page=1, per_page=20 |
| 2 | GET ?page=1&per_page=5 | 200, max 5 items |
| 3 | GET ?page=999 | 200, data=[], total=N |
| 4 | GET ?per_page=0 | 400 validación |
| 5 | GET ?per_page=101 | 400 validación |
| 6 | GET ?page=-1 | 400 validación |
| 7 | POST sigue funcionando | 201 |
| 8 | GET detalle sigue funcionando | 200 |

### 4.4 Contrato

- [ ] Actualizar sección 6.1 de `CONTRATO_API.md`
- [ ] Agregar parámetros `page` y `per_page`
- [ ] Documentar estructura de respuesta paginada
- [ ] Actualizar historial de cambios

### 4.5 Documentación de cierre

- [ ] `BASELINE_SUBJECTS_PAGINACION_SPRINT_16_2026-03-27.md`
- [ ] `NOTA_CIERRE_SPRINT_16_2026-03-27.md`
- [ ] Commit con mensaje convencional

---

## 5. Fuera de alcance

| Ítem | Razón |
|------|-------|
| Filtros por `tipo` | Decisión PO: no en S16 |
| Filtros por `nombre` | Decisión PO: no en S16 |
| Ordenamiento | No solicitado |
| Alineación enums DTO/Prisma | Deuda menor, no bloqueante |

---

## 6. Riesgos

| Riesgo | Mitigación |
|--------|------------|
| Breaking change en respuesta | Comunicar que array → objeto paginado |
| Performance con muchos sujetos | Índice `caso_id` ya existe |

---

## 7. Criterios de cierre

- [ ] GET subjects retorna estructura paginada
- [ ] Parámetros `page` y `per_page` validados
- [ ] 8 pruebas runtime verdes
- [ ] Contrato actualizado
- [ ] Commit pusheado a main

---

*Checklist generado: 2026-03-27*
