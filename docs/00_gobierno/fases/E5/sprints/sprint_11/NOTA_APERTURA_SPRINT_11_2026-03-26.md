# APERTURA FORMAL — SPRINT 11

**Proyecto:** LEX_PENAL  
**Fase:** E5 — Expansión funcional controlada  
**Sprint:** Sprint 11 — Consolidación funcional de Documento  
**Fecha de apertura:** 2026-03-26  
**Estado:** ABIERTO

---

## 1. Objetivo formal

Consolidar el subrecurso `Documento` abierto en el Sprint 10, ampliando su ciclo funcional dentro del backend sin incorporar todavía infraestructura de almacenamiento real, de manera que el sistema pase de un esquema de registro de metadatos-only a una gestión documental funcional más completa, coherente con el modelo de datos, el contrato API y el comportamiento observable del runtime.

---

## 2. Justificación de apertura

El Sprint 10 dejó dos resultados distintos:

- `proceedings` quedó funcionalmente consolidado.
- `documents` quedó habilitado en una primera capa operativa, todavía restringida a consulta y alta de metadatos.

Por tanto, el siguiente paso metodológicamente correcto en E5 es profundizar `documents` antes de abrir una nueva superficie funcional o de incorporar infraestructura pesada.

---

## 3. Decisión de política funcional

### Política adoptada: C — Híbrido

> **En Sprint 11, el recurso `documents` conservará naturaleza append-only respecto de su identidad documental y metadatos estructurales. Se habilitará únicamente la actualización del campo `descripcion`, sin implementación de eliminación del registro.**

### Campos inmutables

Estos campos no se editan en Sprint 11:

- `caso_id`
- `categoria`
- `nombre_original`
- `nombre_almacenado`
- `ruta`
- `mime_type`
- `tamanio_bytes`
- `subido_en`
- `subido_por`

### Campo editable

Solo se podrá editar:

- `descripcion`

### Eliminación

- No se implementa `DELETE`
- El recurso mantiene comportamiento append-only estructural, con descripción ajustable

### Justificación de la política

- **Por qué no A (append-only puro):** Demasiado defensiva para un sprint completo. Deja poco avance funcional real.
- **Por qué no B (editable controlado):** Prematura. Requiere migración Prisma, abre deuda de trazabilidad y auditoría.
- **Por qué C:** Conserva el carácter prudente del recurso, permite corregir/enriquecer la descripción sin alterar la identidad documental.

---

## 4. Alcance del sprint

### Endpoints objetivo

| Endpoint | Estado | Acción |
|----------|--------|--------|
| `GET /api/v1/cases/{id}/documents` | ✅ Existente | Validar |
| `POST /api/v1/cases/{id}/documents` | ✅ Existente | Validar |
| `GET /api/v1/cases/{id}/documents/{doc_id}` | ✅ Existente | Validar |
| `PUT /api/v1/cases/{id}/documents/{doc_id}` | 🔨 Nuevo | Implementar (solo `descripcion`) |
| `DELETE /api/v1/cases/{id}/documents/{doc_id}` | ❌ Fuera | No implementar |

---

## 5. Fuera de alcance

Quedan expresamente por fuera del Sprint 11:

- `DELETE /documents/{doc_id}`
- edición de campos estructurales del documento
- subida real de archivos
- `multipart/form-data`
- almacenamiento local físico
- object storage
- firma de URLs
- antivirus de archivos
- versionado documental
- OCR
- indexación avanzada de documentos
- rediseño del módulo IA
- endurecimiento de infraestructura

---

## 6. Reglas de implementación

### Regla 1 — El sprint sigue siendo documental, no infraestructural

El recurso `documents` podrá crecer funcionalmente, pero sin tocar todavía la capa de almacenamiento físico.

### Regla 2 — El contrato no anticipa comportamiento no validado

No se documentará `PUT` como operativo hasta que exista implementación real y validación de humo.

### Regla 3 — El documento sigue siendo un registro jurídico-técnico

La identidad del documento registrado no cambia; solo puede ajustarse la forma en que se describe o contextualiza dentro del caso.

### Regla 4 — La política queda definida desde apertura

El Sprint 11 no reabrirá discusión sobre la política funcional. La decisión C ya está adoptada.

---

## 7. Criterio de éxito del sprint

El Sprint 11 se considerará exitoso si al cierre se verifica:

- módulo `documents` ampliado con `PUT` para `descripcion`
- endpoint validado en runtime
- build limpio
- regresión mínima verde
- contrato API alineado con lo realmente implementado
- repositorio limpio al cierre
- nota de cierre emitida

---

## 8. Checklist operativo del Sprint 11

### A. Preparación

- [x] crear carpeta documental del Sprint 11
- [x] emitir nota de apertura del sprint
- [x] definir política funcional del recurso
- [ ] confirmar baseline limpio: `git status`
- [ ] confirmar build limpio: `npm run build`
- [ ] confirmar login OK
- [ ] confirmar runtime actual de `documents` heredado del Sprint 10

### B. Implementación backend

- [ ] crear DTO de update (solo `descripcion`)
- [ ] ampliar repository con método `update`
- [ ] ampliar service con método `update`
- [ ] ampliar controller con endpoint `PUT`
- [ ] validar build

### C. Pruebas de humo

- [ ] login y token
- [ ] crear documento
- [ ] listar documentos
- [ ] consultar detalle por id
- [ ] actualizar descripción del documento
- [ ] validar que campos inmutables no se alteran
- [ ] validar 404 por `case_id` inexistente
- [ ] validar 404 por `doc_id` inexistente
- [ ] validar 400 por payload inválido
- [ ] confirmar que no existe manejo binario real

### D. Contrato API

- [ ] agregar `PUT /documents/{doc_id}` a la sección documents
- [ ] documentar que solo `descripcion` es editable
- [ ] documentar respuestas (`200`, `400`, `404`)

### E. Regresión mínima

- [ ] `cases` OK
- [ ] `timeline` OK
- [ ] `review` OK
- [ ] `reports` OK
- [ ] `ai/query` OK
- [ ] `proceedings` OK
- [ ] `documents` OK

### F. Cierre

- [ ] `npm run build` exitoso
- [ ] `git status` limpio
- [ ] nota de cierre Sprint 11
- [ ] commit de cierre
- [ ] push a remoto

---

## 9. Orden de ejecución

1. ✅ apertura documental del sprint
2. ✅ definición funcional de la política
3. baseline
4. implementación de `PUT /documents/:id`
5. pruebas de humo
6. ajuste del contrato API
7. regresión mínima
8. cierre documental y git

---

## 10. Micronota de apertura

**MICRONOTA — APERTURA SPRINT 11 / E5**

- Fase activa: **E5 — Expansión funcional controlada**
- Sprint: **11 — Consolidación funcional de Documento**
- Política adoptada: **C — Híbrido (PUT solo descripcion, sin DELETE)**
- Dominante del sprint: **`documents`**
- Restricción crítica: **sin abrir infraestructura de carga o almacenamiento real**
- Criterio de disciplina: **no documentar como disponible nada que no haya pasado por runtime**

---

## 11. Estado de apertura

Sprint 11 queda formalmente abierto con política C adoptada.
