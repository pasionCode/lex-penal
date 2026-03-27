# NOTA DE CIERRE — Sprint 16

| Campo | Valor |
|-------|-------|
| Sprint | 16 |
| Fase | E5 — Expansión funcional controlada |
| Foco | Hardening de `subjects` — paginación |
| Fecha de cierre | 2026-03-27 |
| Commit base | `b6f4db2` |
| Commit cierre | pendiente |

---

## 1. Objetivo del sprint

Implementar paginación en `GET /api/v1/cases/{caseId}/subjects` para que el endpoint
escale correctamente con casos que tengan muchos sujetos procesales.

**Alcance definido:**
- Parámetros `page` y `per_page` con validaciones
- Respuesta estructurada `{ data, total, page, per_page }`
- Comportamiento definido para página fuera de rango

**Fuera de alcance (respetado):**
- Filtros por `tipo` o `nombre`
- Ordenamiento configurable
- Alineación de enums DTO/Prisma

---

## 2. Cambios implementados

### 2.1 Archivos creados

| Archivo | Descripción |
|---------|-------------|
| `src/modules/subjects/dto/list-subjects-query.dto.ts` | DTO de query con validaciones |

### 2.2 Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `src/modules/subjects/dto/index.ts` | Export del nuevo DTO |
| `src/modules/subjects/subjects.repository.ts` | `findAllByCaseId()` con skip/take y count paralelo |
| `src/modules/subjects/subjects.service.ts` | Retorna estructura paginada |
| `src/modules/subjects/subjects.controller.ts` | Recibe query params |
| `docs/04_api/CONTRATO_API.md` | Sección 6.1 actualizada, convención de subrecursos corregida |

### 2.3 Diseño de paginación

**Parámetros:**

| Parámetro | Tipo | Default | Validación |
|-----------|------|---------|------------|
| `page` | number | 1 | >= 1, entero |
| `per_page` | number | 20 | >= 1, <= 100, entero |

**Respuesta:**

```json
{
  "data": [...],
  "total": 45,
  "page": 1,
  "per_page": 20
}
```

**Página fuera de rango:** `200 OK` con `data: []`, metadata preservada.

---

## 3. Breaking change

| Antes (S15) | Después (S16) |
|-------------|---------------|
| `GET /subjects` → `[...]` | `GET /subjects` → `{ data, total, page, per_page }` |

**Impacto:** Clientes que consuman este endpoint deben actualizar su parsing
para acceder a `response.data` en lugar de `response` directamente.

---

## 4. Validación runtime

| # | Prueba | Código | Estado |
|---|--------|--------|--------|
| 1 | GET sin params | 200 | ✅ |
| 2 | GET ?page=1&per_page=5 | 200 | ✅ |
| 3 | GET ?page=999 | 200 `data=[]` | ✅ |
| 4 | GET ?per_page=0 | 400 | ✅ |
| 5 | GET ?per_page=101 | 400 | ✅ |
| 6 | GET ?page=-1 | 400 | ✅ |
| 7 | POST regresión | 201 | ✅ |
| 8 | GET detalle regresión | 200 | ✅ |

**Build:** Verde  
**Runtime:** 8/8 pruebas verdes

---

## 5. Documentación del sprint

| Artefacto | Ubicación |
|-----------|-----------|
| Checklist de apertura | `docs/00_gobierno/fases/E5/sprints/sprint_16/CHECKLIST_APERTURA_SPRINT_16.md` |
| Baseline pre-intervención | `docs/00_gobierno/fases/E5/sprints/sprint_16/BASELINE_SUBJECTS_PAGINACION_SPRINT_16_2026-03-27.md` |
| Nota de cierre | `docs/00_gobierno/fases/E5/sprints/sprint_16/NOTA_CIERRE_SPRINT_16_2026-03-27.md` |
| Contrato API | `docs/04_api/CONTRATO_API.md` |

**Cambios en contrato:**
- Sección 6.1 con paginación y comportamiento de página fuera de rango
- Convención de nomenclatura de subrecursos corregida
- Placeholders unificados a `{caseId}`
- Historial de cambios actualizado

---

## 6. Sujetos en base de datos post-sprint

| ID | Tipo | Nombre | Sprint |
|----|------|--------|--------|
| `c1834348-6f95-42fa-b2f4-a143cff789f3` | victima | Juan Pérez García | S15 |
| `440c0ec4-5d05-4aed-90f2-2767759b3015` | testigo | María López Test S16 | S16 |

---

## 7. Deuda técnica

### Cerrada en este sprint
- ✅ Sin paginación en GET subjects

### Pendiente (no bloqueante)
- Enums duplicados DTO vs Prisma (prioridad baja)

---

## 8. Criterios de cierre — Verificación

- [x] GET subjects retorna estructura paginada
- [x] Parámetros `page` y `per_page` validados
- [x] 8 pruebas runtime verdes
- [x] Baseline documentado
- [x] Contrato actualizado con ajustes del analista
- [ ] Commit pusheado a main

---

## 9. Opciones para Sprint 17

| Opción | Descripción |
|--------|-------------|
| A | Filtros en `subjects` (por `tipo`) |
| B | Nuevo subrecurso (`facts`, `evidence`, `risks`) |
| C | Transiciones de estado del caso |
| D | Paginación en otros subrecursos existentes |

---

*Nota de cierre generada: 2026-03-27*  
*Sprint 16 — Hardening `subjects` (paginación)*
