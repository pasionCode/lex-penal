# NOTA DE CIERRE — SPRINT 17

**Proyecto:** LEX_PENAL  
**Fase:** E5 — Expansión funcional controlada  
**Sprint:** 17  
**Fecha:** 2026-03-27  
**Commit base:** `ddacc21`  
**Estado:** CERRADO

---

## 1. Objetivo

Implementar filtro por `tipo` en `GET /api/v1/cases/{caseId}/subjects` sin alterar
paginación existente ni política append-only.

---

## 2. Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `src/modules/subjects/dto/list-subjects-query.dto.ts` | Campo `tipo` con `@IsEnum(TipoSujeto)` |
| `src/modules/subjects/subjects.controller.ts` | Propaga `query.tipo` al service |
| `src/modules/subjects/subjects.service.ts` | Recibe `tipo?: TipoSujeto`, propaga al repository |
| `src/modules/subjects/subjects.repository.ts` | `whereClause` dinámico en `findMany` y `count` |
| `docs/04_api/CONTRATO_API.md` | Sección 6.1 actualizada |

---

## 3. Pruebas runtime

| # | Prueba | Esperado | Resultado |
|---|--------|----------|-----------|
| 1 | GET sin tipo | 200, todos los sujetos | ✅ |
| 2 | GET ?tipo=victima | 200, solo víctimas, total=1 | ✅ |
| 3 | GET ?tipo=testigo | 200, solo testigos, total=1 | ✅ |
| 4 | GET ?tipo=otro (sin registros) | 200, data=[], total=0 | ✅ |
| 5 | GET ?tipo=invalido | 400, validación | ✅ |
| 6 | GET ?tipo=victima&page=1&per_page=1 | 200, filtro + paginación | ✅ |
| 7 | POST regresión | 201 | ✅ |
| 8 | GET detalle regresión | 200 | ✅ |

**8/8 verdes.**

---

## 4. Nota operativa — datos de prueba

| Momento | Total sujetos | Detalle |
|---------|---------------|---------|
| Baseline pre-S17 | 2 | victima, testigo |
| Post-pruebas S17 | 3 | +1 imputado de regresión |

**Sujeto creado en prueba 7:**
- ID: `6cff5b53-e8a0-45a3-ac7a-48a08621e190`
- Tipo: `imputado`
- Nombre: `Test S17 Regresion`

Este registro queda en BD. El nuevo baseline para pruebas futuras es **3 sujetos**.

---

## 5. Deudas no introducidas en S17

| Deuda | Estado | Origen |
|-------|--------|--------|
| Encoding corrupto (BUG-001) | Preexistente | Sprint 7 |
| Alineación enums DTO/Prisma | Preexistente, no agravada | Sprint 7 |

S17 reutiliza `TipoSujeto` del DTO existente. Tipado consistente en controller, service y repository.

---

## 6. Fuera de alcance (confirmado)

- Filtro por nombre
- Ordenamiento configurable
- Múltiples filtros combinados
- Cambios en POST o GET detalle

---

## 7. Criterios de cierre

- [x] Código implementado (4 archivos)
- [x] Contrato actualizado
- [x] 8/8 pruebas runtime verdes
- [x] Baseline documentado
- [x] Nota de cierre documentada
- [ ] Commit pusheado a main

---

## 8. Commit sugerido
```bash
git add -A
git commit -m "feat(subjects): add tipo filter to GET /subjects endpoint"
git push origin main
```

---

*Sprint 17 CERRADO — 2026-03-27*
