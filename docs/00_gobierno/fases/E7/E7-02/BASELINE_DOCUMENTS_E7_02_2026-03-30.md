# BASELINE DOCUMENTS E7-02 — 2026-03-30

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E7
- Unidad: E7-02
- Fecha: 2026-03-30
- Estado: EN ELABORACIÓN

## 2. Superficie actual observada
### Endpoints visibles
- `GET /api/v1/cases/{caseId}/documents`
- `POST /api/v1/cases/{caseId}/documents`
- `GET /api/v1/cases/{caseId}/documents/{documentId}`
- `PUT /api/v1/cases/{caseId}/documents/{documentId}`

### Semántica observable
- `POST` registra documento referenciado con metadatos.
- `PUT` actualiza solo `descripcion`.
- No existe upload real ni gestión binaria.

## 3. Hallazgo principal
El comentario del controller sigue declarando “append-only: no hay PUT ni DELETE”, pero la implementación real sí expone `PUT`, y el contrato lo documenta.

## 4. Hipótesis de trabajo
La semántica correcta del módulo no es “append-only puro”, sino “registro de documentos referenciados con actualización limitada de descripción”.

## 5. Superficie a intervenir
- `src/modules/documents/documents.controller.ts`
- `src/modules/documents/documents.service.ts`
- `src/modules/documents/documents.repository.ts`
- `src/modules/documents/dto/create-document.dto.ts`
- `src/modules/documents/dto/update-document.dto.ts`
- `docs/04_api/CONTRATO_API.md` solo si se detecta nueva divergencia
- script runtime nuevo para E7-02

## 6. Riesgos
- expandir alcance hacia almacenamiento real
- introducir cambios semánticos no validados en DTOs
- tocar contrato sin evidencia runtime

## 7. Propuesta de ejecución
1. inspeccionar DTOs
2. corregir semántica interna mínima
3. construir script runtime
4. ejecutar build + pruebas
5. cerrar unidad
