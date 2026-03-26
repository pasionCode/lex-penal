# NOTA DE CIERRE — SPRINT 13

**Fecha:** 2026-03-26  
**Proyecto:** LEX_PENAL  
**Fase:** E5 — Expansión funcional controlada  
**Sprint:** 13  
**Foco:** `proceedings`  
**Política:** A — Append-only

---

## 1. Resumen ejecutivo

Sprint 13 alineó el runtime del módulo `proceedings` con la política append-only decidida al inicio del sprint. Se removieron PUT y DELETE del controller, dejando solo GET lista, POST y GET detalle como operaciones permitidas.

---

## 2. Decisión de política

| Pregunta | Respuesta |
|----------|-----------|
| ¿Qué política para `proceedings`? | **A — Append-only** |
| ¿Por qué no B (editable controlado)? | No hay necesidad funcional de edición en esta fase |
| ¿Por qué no C (CRUD amplio)? | DELETE sin decisión formal viola regla de gobierno |

---

## 3. Hallazgo crítico del baseline

El módulo existía con CRUD completo implementado. PUT y DELETE respondían con lógica activa (404 "Actuación no encontrada" en lugar de "Cannot PUT/DELETE").

**Diagnóstico:** Runtime sobredimensionado respecto a política decidida.

---

## 4. Intervención aplicada

| Aspecto | Detalle |
|---------|---------|
| Archivo | `src/modules/proceedings/proceedings.controller.ts` |
| Naturaleza | Solo exposición HTTP |
| Removido | `@Put`, `@Delete`, métodos `update()` y `remove()` |
| Intacto | Service, Repository (lógica interna no expuesta) |

---

## 5. Validación post-ajuste

| # | Prueba | Código | Estado |
|---|--------|--------|--------|
| 1 | GET lista | 200 | ✅ |
| 2 | GET caseId inexistente | 404 | ✅ |
| 3 | POST válido | 201 | ✅ |
| 4 | GET detalle | 200 | ✅ |
| 5 | PUT | 404 Cannot PUT | ✅ Removido |
| 6 | DELETE | 404 Cannot DELETE | ✅ Removido |

**Build:** Verde  
**Mini-regresión:** Verde

---

## 6. Ajuste contractual

**Archivo:** `docs/04_api/CONTRATO_API.md`

**Cambios:**
- Endpoints reducidos a GET, POST, GET detalle
- Agregada nota: `Entidad con **política append-only**. No se permite edición ni eliminación.`
- Agregada nota de implementación Sprint 13

---

## 7. Artefactos del sprint

| Documento | Ubicación |
|-----------|-----------|
| Checklist de apertura | `sprint_13/CHECKLIST_APERTURA_SPRINT_13.md` |
| Baseline | `sprint_13/BASELINE_PROCEEDINGS_SPRINT_13_2026-03-26.md` |
| Nota de cierre | `sprint_13/NOTA_CIERRE_SPRINT_13_2026-03-26.md` |
| Contrato actualizado | `docs/04_api/CONTRATO_API.md` |

---

## 8. Criterio de cierre — Verificación

- [x] Política append-only formalmente definida
- [x] Cambio probado en runtime
- [x] Evidencia positiva y negativa capturada
- [x] Mini-regresión verde
- [x] Contrato no contradice runtime
- [x] Nota de cierre emitida
- [x] Commit realizado
- [x] Push realizado
- [x] Repositorio limpio

**Cierre Git:** commit funcional `c754429` + commit de higiene `4ba21a5`

---

## 9. Commit sugerido

```
feat(proceedings): política append-only Sprint 13

- Removidos PUT y DELETE del controller
- Runtime alineado con política A — Append-only
- Contrato actualizado con nota de implementación
- Baseline y nota de cierre documentados
```

---

## 10. Deuda técnica

Deuda técnica menor: `service` y `repository` conservan métodos `update/delete` no expuestos por HTTP. No bloquean operación ni cierre del sprint.

Podrán removerse en un sprint de limpieza futuro si se decide que no serán necesarios.

---

## 11. Siguiente sprint sugerido

Opciones para Sprint 14:
- **A:** Hardening de DTO de `proceedings` (validaciones, mensajes)
- **B:** Expansión a otro subrecurso (notes, tasks)
- **C:** Limpieza de métodos no expuestos en service/repository

---

*Documento generado: 2026-03-26 ~17:35 (hora local Colombia, COT)*  
*Sprint 13 cerrado — Política append-only para `proceedings`*
