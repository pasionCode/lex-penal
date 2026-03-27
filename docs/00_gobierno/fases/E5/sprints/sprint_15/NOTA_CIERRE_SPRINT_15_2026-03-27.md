# NOTA DE CIERRE — SPRINT 15

**Fecha:** 2026-03-27  
**Proyecto:** LEX_PENAL  
**Fase:** E5 — Expansión funcional controlada  
**Sprint:** 15  
**Foco:** Expansión mínima vertical — `subjects`  
**Política:** B1 — Implementación nueva desde cero

---

## 1. Resumen ejecutivo

Sprint 15 implementó exitosamente el subrecurso `subjects` (sujetos procesales) como expansión funcional nueva. El módulo permite registrar y consultar víctimas, imputados, testigos, apoderados y otros sujetos vinculados a un caso penal. La implementación siguió la política append-only establecida, sin exponer PUT ni DELETE.

---

## 2. Relación con sprints anteriores

| Sprint 14 | Sprint 15 |
|-----------|-----------|
| Cerró hardening de `proceedings` | Abrió nuevo subrecurso `subjects` |
| Consolidó validaciones DTO | Aplicó misma disciplina de validaciones |
| Política append-only | Misma política append-only |
| Build limpio | Build limpio |

---

## 3. Alcance implementado

### Modelo de datos

- 2 enums nuevos: `TipoSujeto`, `TipoIdentificacion`
- 1 modelo nuevo: `Subject`
- Migración: `20260327015609_add_subjects`
- Relaciones: `Caso` ← `Subject`, `Usuario` ← `Subject` (creador/actualizador)

### Endpoints

| Método | Ruta | Estado |
|--------|------|--------|
| GET | `/cases/{caseId}/subjects` | ✅ |
| POST | `/cases/{caseId}/subjects` | ✅ |
| GET | `/cases/{caseId}/subjects/{subjectId}` | ✅ |
| PUT | — | ❌ No expuesto |
| DELETE | — | ❌ No expuesto |

### Módulo NestJS

- `SubjectsModule`
- `SubjectsController`
- `SubjectsService`
- `SubjectsRepository`
- DTOs con validaciones completas

---

## 4. Validación final

| # | Prueba | Código | Estado |
|---|--------|--------|--------|
| 1 | GET lista | 200 | ✅ |
| 2 | POST válido | 201 | ✅ |
| 3 | GET detalle | 200 | ✅ |
| 4 | GET caseId inexistente | 404 | ✅ |
| 5 | GET subjectId inexistente | 404 | ✅ |
| 6 | POST nombre vacío | 400 | ✅ |
| 7 | POST tipo inválido | 400 | ✅ |
| 8 | PUT no expuesto | 404 | ✅ |
| 9 | DELETE no expuesto | 404 | ✅ |

**Build:** Verde  
**Runtime:** Verde  
**Contrato:** Actualizado

---

## 5. Artefactos del sprint

| Documento | Ubicación |
|-----------|-----------|
| Checklist de apertura | `sprint_15/CHECKLIST_APERTURA_SPRINT_15.md` |
| Baseline | `sprint_15/BASELINE_SUBJECTS_SPRINT_15_2026-03-27.md` |
| Nota de cierre | `sprint_15/NOTA_CIERRE_SPRINT_15_2026-03-27.md` |
| Contrato API | `docs/04_api/CONTRATO_API.md` (sección 6) |

---

## 6. Criterio de cierre — Verificación

- [x] Subrecurso `subjects` con alcance mínimo operativo
- [x] Evidencia positiva y negativa en runtime
- [x] Contrato no contradice runtime
- [x] No se abrió refactor transversal fuera del foco
- [x] Nota de cierre emitida
- [ ] Commit realizado
- [ ] Push realizado
- [ ] Repositorio limpio

---

## 7. Commit sugerido

```
feat(subjects): implementa subrecurso subjects Sprint 15

- Modelo Subject con enums TipoSujeto y TipoIdentificacion
- Migración 20260327015609_add_subjects
- Módulo NestJS completo: controller, service, repository
- Endpoints GET lista, POST, GET detalle
- Validaciones DTO con trim y enums
- Política append-only (sin PUT/DELETE)
- Contrato API actualizado sección 6
```

---

## 8. Deuda técnica

| Tipo | Descripción | Prioridad |
|------|-------------|-----------|
| Menor | Enums duplicados DTO vs Prisma | Baja |
| Funcional | Sin paginación en GET lista | Media |
| Funcional | Sin filtros por tipo | Baja |

---

## 9. Siguiente sprint sugerido

Opciones para Sprint 16:

| Opción | Descripción |
|--------|-------------|
| **A** | Hardening de `subjects` (paginación, filtros) |
| **B** | Expansión a otro subrecurso (`hearings`, `notifications`, `terms`) |
| **C** | PUT opcional para `subjects` si negocio lo requiere |

---

*Documento generado: 2026-03-27*  
*Sprint 15 cerrado — Expansión `subjects`*
