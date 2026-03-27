# NOTA DE CIERRE — SPRINT 14

**Fecha:** 2026-03-27  
**Proyecto:** LEX_PENAL  
**Fase:** E5 — Expansión funcional controlada  
**Sprint:** 14  
**Foco:** Hardening de `proceedings`  
**Política:** A1 — Validaciones de payload

---

## 1. Resumen ejecutivo

Sprint 14 consolidó el módulo `proceedings` mediante hardening de validaciones. Se corrigieron las brechas críticas de validación sobre `descripcion`, rechazando tanto cadena vacía como contenido compuesto únicamente por espacios. La exploración de la regla de responsable no evidenció incumplimiento del contrato actual.

---

## 2. Relación con Sprint 13

| Sprint 13 | Sprint 14 |
|-----------|-----------|
| Definió política append-only | Consolidó calidad |
| Removió PUT y DELETE | Mantuvo sin PUT ni DELETE |
| Alineó contrato | Endureció validaciones DTO |
| Baseline de exposición HTTP | Baseline de validaciones |

---

## 3. Brechas cerradas

| Brecha | Severidad | Solución | Estado |
|--------|-----------|----------|--------|
| `descripcion: ""` aceptado | Alta | `@IsNotEmpty()` | ✅ CERRADA |
| `descripcion: "   "` aceptado | Alta | `@Transform()` + trim | ✅ CERRADA |

---

## 4. Intervención aplicada

| Aspecto | Detalle |
|---------|---------|
| Archivo | `src/modules/proceedings/dto/create-proceeding.dto.ts` |
| Agregado | `@IsNotEmpty()`, `@Transform()` con trim |
| Removido | Import no usado (`ValidateIf`) |
| Naturaleza | Solo DTO, sin cambios en controller/service/repository |

---

## 5. Exploración A2 — Regla de responsable

| Escenario | Resultado | Según contrato |
|-----------|-----------|----------------|
| Ninguno | Aceptado | ✅ Sin responsable asignado |
| Solo `responsable_id` | Aceptado | ✅ Responsable interno |
| Solo `responsable_externo` | Aceptado | ✅ Responsable externo |
| Ambos | Aceptado | ✅ No prohibido expresamente |

**Conclusión:** Comportamiento compatible con el contrato actual. Cualquier restricción XOR es decisión funcional futura, no defecto del Sprint 14.

---

## 6. Validación final

| # | Prueba | Código | Estado |
|---|--------|--------|--------|
| 1 | `descripcion: ""` | 400 | ✅ Rechazado |
| 2 | `descripcion: "   "` | 400 | ✅ Rechazado |
| 3 | POST válido | 201 | ✅ OK |
| 4 | GET lista | 200 | ✅ OK |
| 5 | Fecha inválida | 400 | ✅ Rechazado |
| 6 | Tipo incorrecto | 400 | ✅ Rechazado |

**Build:** Verde  
**Mini-regresión:** Verde

---

## 7. Artefactos del sprint

| Documento | Ubicación |
|-----------|-----------|
| Checklist de apertura | `sprint_14/CHECKLIST_APERTURA_SPRINT_14.md` |
| Baseline | `sprint_14/BASELINE_PROCEEDINGS_SPRINT_14_2026-03-27.md` |
| Nota de cierre | `sprint_14/NOTA_CIERRE_SPRINT_14_2026-03-27.md` |

---

## 8. Criterio de cierre — Verificación

- [x] Subrecurso `proceedings` mantiene política append-only
- [x] Evidencia positiva y negativa en runtime
- [x] Validaciones del POST endurecidas
- [x] PUT y DELETE permanecen no expuestos
- [x] Contrato no contradice runtime
- [x] Nota de cierre emitida
- [ ] Commit realizado
- [ ] Push realizado
- [ ] Repositorio limpio

---

## 9. Commit sugerido

```
feat(proceedings): hardening de validaciones DTO Sprint 14

- Agregado @IsNotEmpty() para rechazar descripcion vacía
- Agregado @Transform() con trim para rechazar solo espacios
- Exploración A2: comportamiento de responsable válido según contrato
- Brechas críticas de validación cerradas
```

---

## 10. Deuda técnica

Deuda técnica menor identificada pero no corregida:

- Mensajes ruidosos cuando campo requerido está ausente (requiere `stopAtFirstError` en main.ts — fuera de alcance)

---

## 11. Pregunta funcional para S15

> ¿`responsable_id` y `responsable_externo` pueden coexistir en una misma actuación o debe imponerse exclusión mutua?

Mientras no se decida, el comportamiento actual es defendible.

---

## 12. Siguiente sprint sugerido

Opciones para Sprint 15:

- **A:** Decisión funcional sobre regla de responsable (XOR vs permisivo)
- **B:** Expansión a otro subrecurso funcional
- **C:** Hardening de otro módulo existente

---

*Documento generado: 2026-03-27*  
*Sprint 14 cerrado — Hardening de `proceedings`*
