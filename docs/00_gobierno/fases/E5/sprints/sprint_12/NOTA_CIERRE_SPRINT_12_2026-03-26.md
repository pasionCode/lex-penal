# NOTA DE CIERRE — Sprint 12

**Fecha:** 2026-03-26  
**Proyecto:** LEX_PENAL  
**Fase:** E5 — Expansión funcional controlada  
**Sprint:** 12  
**Estado:** CERRADO

---

## 1. Foco del sprint

**Opción seleccionada:** A — Endurecimiento de `documents`

**Objetivo:** Hardening de validaciones y comportamiento ante entradas inválidas en el subrecurso `documents`, sin abrir capacidades nuevas ni expansión transversal.

---

## 2. Política respetada

| Restricción | Cumplimiento |
|-------------|--------------|
| No abrir infraestructura real de almacenamiento | ✅ |
| No introducir DELETE sin decisión formal | ✅ |
| No mezclar refactor amplio con expansión funcional | ✅ |
| No actualizar contrato antes de validar runtime | ✅ |
| No abrir múltiples subrecursos nuevos en paralelo | ✅ |
| No tocar `main.ts` ni ValidationPipe global | ✅ |

---

## 3. Cambio implementado

**Archivo modificado:** `src/modules/documents/dto/create-document.dto.ts`

**Ajustes aplicados:**

| Campo | Cambio |
|-------|--------|
| `tamanio_bytes` | `@Min(0)` → `@Min(1)` con mensaje `"debe ser mayor a cero"` |
| `nombre_original` | + `@IsNotEmpty({ message: 'nombre_original es requerido' })` |
| `nombre_almacenado` | + `@IsNotEmpty({ message: 'nombre_almacenado es requerido' })` |
| `ruta` | + `@IsNotEmpty({ message: 'ruta es requerido' })` |
| `mime_type` | + `@IsNotEmpty({ message: 'mime_type es requerido' })` |

**Capas no tocadas:** Controller, Service, Repository, main.ts

---

## 4. Brechas cerradas

| Brecha | Estado pre-sprint | Estado post-sprint |
|--------|-------------------|-------------------|
| `tamanio_bytes = 0` aceptado | 201 ❌ | 400 ✅ |
| Strings vacíos aceptados | 201 ❌ | 400 ✅ |
| Campo ausente produce 500 | N/A (regresión intermedia) | 400 ✅ |

---

## 5. Regresión intermedia

Durante el sprint se intentó limpiar el mensaje de campo ausente usando:

```typescript
@IsDefined({ message: 'nombre_original es requerido' })
@ValidateIf((o, v) => v !== undefined)
```

**Resultado:** El `@ValidateIf` neutralizó las validaciones y el campo omitido produjo `500 Internal Server Error`.

**Acción correctiva:** Se revirtió a versión sin `@ValidateIf`, restaurando el `400` estable.

**Lección aprendida:** La combinación `@IsDefined` + `@ValidateIf` en class-validator no funciona como cortocircuito para campos ausentes.

---

## 6. Deuda técnica residual

**Comportamiento:** Cuando un campo requerido está ausente, el DTO devuelve múltiples mensajes de validación en lugar de solo `"<campo> es requerido"`.

**Ejemplo:**
```json
{
  "mensaje": [
    "nombre_original no puede exceder 255 caracteres",
    "nombre_original debe ser texto",
    "nombre_original es requerido"
  ]
}
```

**Causa:** class-validator acumula validaciones cuando el valor es `undefined`.

**Decisión Sprint 12:** No se corrige. Requeriría ajuste transversal en `main.ts` (`stopAtFirstError: true`) o validador personalizado, ambos fuera de alcance.

**Impacto:** Cosmético. El sistema bloquea correctamente con `400` y el mensaje incluye la información clave.

---

## 7. Evidencia de validación

### Mini-regresión final

| # | Prueba | Código | Resultado |
|---|--------|--------|-----------|
| 1 | Positivo principal | 201 | ✅ Documento creado |
| 2 | `tamanio_bytes = 0` | 400 | ✅ `"debe ser mayor a cero"` |
| 3 | `nombre_original = ""` | 400 | ✅ `"es requerido"` |
| 4 | `nombre_original` omitido | 400 | ✅ Incluye `"es requerido"` |

**Ejecución:** 2026-03-26 ~16:51 (hora local Colombia, COT)

### Otras verificaciones del baseline

| Prueba | Código | Estado |
|--------|--------|--------|
| GET con caseId válido | 200 | ✅ Ya protegido |
| GET con caseId inexistente | 404 | ✅ Ya protegido |
| POST con categoria inválida | 400 | ✅ Ya protegido |
| POST con tamanio_bytes negativo | 400 | ✅ Ya protegido |

---

## 8. Contrato API

**Archivo:** `docs/04_api/CONTRATO_API_v4.md`

**Decisión:** No se modifica. El contrato ya establece:
- Campos obligatorios correctamente marcados
- `400` para payload inválido
- `404` para recurso no encontrado

Sprint 12 endureció validaciones de implementación, no semántica contractual.

---

## 9. Documentación generada

| Documento | Ubicación |
|-----------|-----------|
| Nota de apertura | `docs/00_gobierno/fases/E5/sprints/sprint_12/SPRINT-12-APERTURA.md` |
| Baseline y evidencia | `docs/00_gobierno/fases/E5/sprints/sprint_12/BASELINE_DOCUMENTS_SPRINT_12_2026-03-26.md` |
| Nota de cierre | `docs/00_gobierno/fases/E5/sprints/sprint_12/NOTA_CIERRE_SPRINT_12_2026-03-26.md` |

---

## 10. Criterio de cierre

- [x] Positiva principal verde
- [x] Negativas 400 verdes
- [x] Sin regresión 500
- [x] Build verde
- [x] Contrato no contradice runtime
- [x] Cambio acotado al DTO
- [x] Documentación emitida
- [ ] Commit realizado
- [ ] Push realizado
- [ ] Repo limpio

---

## 11. Commit sugerido

```
feat(documents): hardening de validaciones DTO Sprint 12

- tamanio_bytes: @Min(0) → @Min(1)
- campos texto: + @IsNotEmpty()
- mensajes explícitos en español

Brechas cerradas:
- tamanio_bytes=0 ahora rechazado
- strings vacíos ahora rechazados

Deuda técnica menor: mensaje ruidoso en campo ausente
(requiere ajuste transversal fuera de alcance)

Refs: Sprint 12, Fase E5
```

---

## 12. Estado final

**Sprint 12: LISTO PARA CIERRE**

El subrecurso `documents` queda endurecido contra entradas inválidas. La deuda técnica residual (mensaje ruidoso) es cosmética y no bloquea operación.

Pendiente: commit, push y verificación de repo limpio.

---

*Documento emitido: 2026-03-26 ~17:10 (hora local Colombia, COT)*  
*Sprint 12 — Hardening de `documents`*
