# NOTA DE CIERRE UNIDAD E5-19 — 2026-03-28

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Consolidación
- Unidad: E5-19 — Alineación contractual y validación runtime de documents
- Fecha de cierre: 2026-03-28
- Estado: CERRADA

## 2. Objetivo de la unidad
Alinear el contrato API del subrecurso `documents` con la implementación vigente y validar en runtime su semántica como **colección con edición limitada**, incluyendo listado, creación, detalle, actualización restringida de `descripcion`, serialización de `tamanio_bytes` y controles de acceso.

## 3. Alcance ejecutado
Durante la unidad E5-19 se ejecutaron las siguientes acciones:

1. Se revisó la superficie funcional real del recurso `documents`.
2. Se confirmó la existencia de cuatro endpoints operativos:
   - `GET /api/v1/cases/{caseId}/documents`
   - `POST /api/v1/cases/{caseId}/documents`
   - `GET /api/v1/cases/{caseId}/documents/{documentId}`
   - `PUT /api/v1/cases/{caseId}/documents/{documentId}`
3. Se verificó que el recurso opera como **colección con edición limitada**:
   - múltiples documentos por caso
   - creación por `POST`
   - consulta por lista y detalle
   - actualización restringida únicamente al campo `descripcion`
4. Se confirmó la política de inmutabilidad definida en Sprint 11:
   - `categoria`
   - `nombre_original`
   - `nombre_almacenado`
   - `ruta`
   - `mime_type`
   - `tamanio_bytes`
   permanecen inmutables después de la creación.
5. Se validó que el recurso implementa **solo metadatos**, sin subida real de archivos binarios.
6. Se confirmó la serialización de `tamanio_bytes` desde persistencia `BigInt` hacia respuesta JSON como `Number`.
7. Se actualizó `CONTRATO_API.md` para reflejar:
   - semántica del recurso
   - comportamiento de cada endpoint
   - política de inmutabilidad
   - campos de `CreateDocumentDto`
   - campo de `UpdateDocumentDto`
   - enum `categoria`
   - tabla de códigos de respuesta

## 4. Evidencia de validación runtime
Se ejecutó el script `test_e5_19.sh` con el siguiente resultado:

- Pruebas pasadas: **17**
- Pruebas fallidas: **0**

### Validaciones satisfactorias
1. `GET /documents` sobre colección vacía → `200`
2. `POST /documents` → `201`
3. `GET /documents` con elemento creado → `200`
4. `GET /documents/:id` → `200`
5. `PUT /documents/:id` actualizando `descripcion` → `200`
6. `GET /documents/:id` refleja cambios y entrega `tamanio_bytes` como número → `200`
7. `GET /documents/:id` con documento inexistente → `404`
8. `PUT /documents/:id` con documento inexistente → `404`
9. `POST /documents` con payload inválido (`tamanio_bytes=0`) → `400`
10. `GET /documents` sin token → `401`
11. `GET /documents` con estudiante ajeno → `403`
12. `GET /documents/:id` con estudiante ajeno → `403`
13. `PUT /documents/:id` con estudiante ajeno → `403`

## 5. Evidencia de build
Se ejecutó adicionalmente `npm run build`.

Resultado:
- `nest build` completado sin errores.

## 6. Alineación contractual consolidada
El contrato API del recurso `documents` quedó alineado con la implementación real en los siguientes puntos:

- recurso modelado como **colección con edición limitada**
- `POST` registra metadatos del documento
- `PUT` solo permite actualizar `descripcion`
- inexistencia de endpoint `DELETE`
- explicitación de campos obligatorios y opcionales
- explicitación del enum `categoria`
- tabla de respuestas `200`, `201`, `400`, `401`, `403` y `404`
- nota de serialización de `tamanio_bytes`
- nota de ausencia de carga binaria real

## 7. Resultado de la unidad
La unidad E5-19 queda cerrada con resultado satisfactorio.

### Conclusión
- La implementación vigente del recurso `documents` es consistente con la política definida.
- No se identifican deudas estructurales que obliguen ajuste de código en esta unidad.
- La deuda existente era principalmente **contractual y documental**, y queda resuelta con esta alineación.

## 8. Archivos de soporte de la unidad
- `docs/00_gobierno/fases/E5/E5-19/CHECKLIST_APERTURA_E5_19_2026-03-28.md`
- `docs/00_gobierno/fases/E5/E5-19/NOTA_CIERRE_UNIDAD_E5_19_2026-03-28.md`
- `docs/04_api/CONTRATO_API.md`
- `test_e5_19.sh`

## 9. Estado final
**E5-19 CERRADA**  
Subrecurso `documents` validado en runtime y alineado contractualmente.
