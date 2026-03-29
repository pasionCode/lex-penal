# NOTA DE CIERRE UNIDAD E5-23 — 2026-03-28

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Consolidación
- Unidad: E5-23 — Validación runtime y alineación contractual de evidence
- Fecha de cierre: 2026-03-28
- Estado: CERRADA

## 2. Objetivo de la unidad
Validar en runtime la superficie real del módulo `evidence`, confirmar su semántica operativa, documentar la regla de aislamiento entre casos y dejar definido el ajuste contractual requerido para la sección 5.2 del contrato API.

## 3. Alcance ejecutado
Durante la unidad E5-23 se ejecutaron las siguientes acciones:

1. Se levantó baseline de la superficie real del módulo `evidence`.
2. Se verificó la existencia de las rutas implementadas:
   - `POST /api/v1/cases/{caseId}/evidence`
   - `GET /api/v1/cases/{caseId}/evidence`
   - `GET /api/v1/cases/{caseId}/evidence/{evidenceId}`
   - `PUT /api/v1/cases/{caseId}/evidence/{evidenceId}`
   - `PATCH /api/v1/cases/{caseId}/evidence/{evidenceId}/link`
   - `PATCH /api/v1/cases/{caseId}/evidence/{evidenceId}/unlink`
3. Se revisaron los DTOs del módulo para identificar campos, enums y patrón de actualización.
4. Se ejecutó validación runtime dedicada mediante `test_e5_23.sh`.
5. Se confirmó el comportamiento de aislamiento cross-case para vínculo de evidencia con hecho de otro caso.
6. Se ejecutó `npm run build` con resultado satisfactorio.
7. Se dejó definido el bloque contractual a aplicar sobre la sección 5.2 de `docs/04_api/CONTRATO_API.md` mediante `DIFF_EVIDENCE_CONTRATO.md`.

## 4. Hallazgos de baseline
Se confirmó que el módulo `evidence` implementa una superficie más amplia que la documentada originalmente en el contrato:

- El contrato vigente sí reflejaba el CRUD base.
- El contrato no documentaba:
  - `PATCH /link`
  - `PATCH /unlink`
  - DTOs reales
  - enums válidos
  - tabla de códigos
  - semántica de aislamiento entre casos

El hallazgo no corresponde a código faltante, sino a una desalineación contractual respecto de la implementación runtime.

## 5. Patrón funcional validado
El módulo `evidence` quedó caracterizado así:

| Aspecto | Valor validado |
|---|---|
| Tipo de recurso | Colección editable sin DELETE |
| Cardinalidad | N pruebas por caso |
| Edición | `PUT` con actualización parcial de campos presentes |
| Vínculo con hechos | `PATCH /link` y `PATCH /unlink` |
| Aislamiento | `409 Conflict` si se intenta vincular con un hecho de otro caso |

## 6. Evidencia runtime

### 6.1 Script ejecutado
- Script: `test_e5_23.sh`

### 6.2 Resultado global
- Pasadas: `19`
- Fallidas: `0`

### 6.3 Resultado por fases

| Fase | Pruebas | Resultado |
|---|---|---|
| Setup | 01-05 | ✅ |
| CRUD básico | 06-09 | ✅ |
| Update parcial | 10 | ✅ |
| Link / unlink | 11-14 | ✅ |
| Evidence inexistente | 15 | ✅ `404` |
| Hecho de otro caso | 16 | ✅ `409` |
| Payload inválido | 17 | ✅ `400` |
| Sin token | 18 | ✅ `401` |
| Estudiante ajeno | 19 | ✅ `403` |

### 6.4 Evidencia del último escenario ejecutado
- Caso principal: `E523-1774749842`
- ID caso principal: `0ec23101-0999-4350-aa67-7ffc950f76ff`
- Caso secundario: `E523B-1774749842`
- ID caso secundario: `4e3538e9-400d-48fe-9640-19cbd89fb6da`
- Hecho 1: `db59b515-dc7e-4999-9713-777e36118476`
- Hecho 2 (otro caso): `001b2918-dacf-486f-a434-c68a0326198a`
- Evidence: `71605ec4-8a2e-44eb-a936-9a4be0b0f5e0`

## 7. Semántica validada del módulo
Se validó en runtime que:

1. `GET /evidence` retorna lista vacía cuando el caso no tiene pruebas.
2. `POST /evidence` crea correctamente una prueba.
3. `GET /evidence/{id}` retorna el detalle esperado.
4. `PUT /evidence/{id}` opera como actualización parcial.
5. `PATCH /link` vincula la evidencia a un hecho del mismo caso.
6. `PATCH /unlink` elimina correctamente el vínculo.
7. El intento de vincular evidencia con un hecho de otro caso retorna `409`.
8. El recurso mantiene correctamente los controles de:
   - `400` para payload inválido
   - `401` sin token
   - `403` para estudiante ajeno
   - `404` para evidencia inexistente

## 8. Build
Se ejecutó `npm run build` con resultado satisfactorio.

Estado:
- Build: ✅ VERDE

## 9. Resultado contractual a incorporar
Para alinear contrato y runtime, la unidad deja identificado que la sección **5.2 Pruebas del caso** debe completarse con el bloque contenido en:

- `DIFF_EVIDENCE_CONTRATO.md`

Ese bloque debe reflejar:

- endpoints `PATCH /link` y `PATCH /unlink`
- DTOs reales del módulo
- enums válidos
- tabla de códigos
- regla de `409 Conflict` cuando el hecho no pertenece al mismo caso

## 10. Criterios de cierre verificados
La unidad E5-23 se considera cerrada porque se verificó que:

- la superficie real de `evidence` quedó identificada
- el runtime del módulo fue validado con cobertura suficiente
- el build del proyecto permanece estable
- la regla de aislamiento cross-case quedó demostrada
- el ajuste contractual requerido quedó definido de forma explícita

## 11. Estado actualizado de la fase E5
- E5-09 a E5-22: ✅
- E5-23 (`evidence`): ✅

Backlog restante de E5:

| Orden | Unidad | Módulo | Tipo |
|---|---|---|---|
| 1 | E5-24 | `ai` | Baseline + alineación |
| 2 | E5-25 | `audit` | Decisión: implementar o documentar fuera de MVP |

## 12. Conclusión
La unidad E5-23 queda cerrada con evidencia runtime satisfactoria, build estable y patrón funcional del módulo `evidence` correctamente caracterizado.

El hallazgo principal de la unidad fue la consolidación de la regla de aislamiento cross-case mediante `409 Conflict` en `PATCH /link` cuando se intenta vincular una evidencia con un hecho perteneciente a otro caso.

No se identificó deuda funcional crítica dentro del alcance de la unidad. El ajuste restante es de alineación contractual sobre la sección 5.2 del contrato API.

