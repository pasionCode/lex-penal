# NOTA DE CIERRE UNIDAD E5-10 — 2026-03-28

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5
- Unidad: E5-10 — Validación runtime y cierre funcional de proceedings
- Fecha de cierre: 2026-03-28
- Estado: CERRADA

## 2. Objetivo
Validar y cerrar funcionalmente la superficie append-only del subrecurso `proceedings`.

## 3. Alcance validado
- `GET /api/v1/cases/{caseId}/proceedings`
- `POST /api/v1/cases/{caseId}/proceedings`
- `GET /api/v1/cases/{caseId}/proceedings/{proceedingId}`

Fuera de alcance:
- `PUT`
- `DELETE`
- refactor de deuda interna en service/repository

## 4. Resultado
La superficie expuesta por controller quedó validada con política append-only y control de acceso operativo.

## 5. Evidencia de validación

### 5.1 Runtime
Script `test_e5_10.sh` ejecutado con resultado:

- 16 pruebas pasadas
- 0 fallidas

Validaciones satisfactorias:
- `POST /proceedings` → `201`
- `GET /proceedings` → `200`
- `GET /proceedings/:id` → `200`
- caso inexistente → `404`
- actuación inexistente → `404`
- fuga entre casos → `404`
- acceso sin token → `401`
- estudiante en caso ajeno → `403`

### 5.2 Build
- `npm run build` → OK

## 6. Observaciones
- La política append-only está alineada en controller y contrato.
- Persiste una deuda interna no bloqueante: métodos `update/remove` aún existen en service/repository, pero no están expuestos por controller.

## 7. Estado de cierre
La unidad E5-10 queda cerrada técnica y documentalmente.
