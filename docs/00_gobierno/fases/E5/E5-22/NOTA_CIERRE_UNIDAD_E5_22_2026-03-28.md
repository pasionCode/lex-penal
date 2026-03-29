# NOTA DE CIERRE UNIDAD E5-22 — 2026-03-28

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Consolidación
- Unidad: E5-22 — Alineación contractual de basic-info
- Fecha de cierre: 2026-03-28
- Estado: CERRADA

## 2. Objetivo de la unidad
Verificar la existencia real del subrecurso `basic-info` en runtime, contrastar el contrato API contra la implementación vigente y cerrar la discrepancia documental sin introducir expansión artificial de superficie funcional.

## 3. Hallazgo de baseline
Durante la revisión de E5-22 se confirmó que el subrecurso:

- `GET /api/v1/cases/{caseId}/basic-info`
- `PUT /api/v1/cases/{caseId}/basic-info`

no existe en runtime y retorna `404`.

Se verificó además que la ficha básica del caso se consulta y actualiza a través del agregado raíz:

- `GET /api/v1/cases/{caseId}`
- `PUT /api/v1/cases/{caseId}`

Por tanto, la discrepancia identificada fue contractual y no funcional.

## 4. Decisión adoptada
Se adopta la **Opción B** para E5-22:

- **No** implementar el subrecurso `/basic-info`
- **No** introducir alias ni nueva superficie API
- **Sí** corregir el contrato para alinearlo con el runtime real
- **Sí** documentar expresamente que la ficha básica vive en `GET/PUT /cases/{caseId}`

Esta decisión se considera alineada con el MDS, por tratarse de una inconsistencia documental y no de una deuda funcional real.

## 5. Alcance ejecutado
Durante la unidad E5-22 se ejecutaron las siguientes acciones:

1. Se verificó la superficie real del módulo `cases`.
2. Se confirmó ausencia de rutas `basic-info` en controller runtime.
3. Se revisó `UpdateCaseDto` para validar los campos efectivamente editables del caso.
4. Se ejecutó validación runtime dedicada mediante `test_e5_22.sh`.
5. Se corrigió `docs/04_api/CONTRATO_API.md` para:
   - eliminar la referencia residual a `/basic-info`
   - reforzar que la ficha básica se consulta con `GET /api/v1/cases/{caseId}`
   - reforzar que la ficha básica se actualiza con `PUT /api/v1/cases/{caseId}`
   - documentar campos inmutables
   - registrar la entrada E5-22 en el historial del contrato
6. Se ejecutó `npm run build` con resultado satisfactorio.

## 6. Evidencia técnica y contractual

### 6.1 Verificación estructural
Se confirmó en `cases.controller.ts` la existencia de las rutas:

- `GET /api/v1/cases`
- `POST /api/v1/cases`
- `GET /api/v1/cases/{id}`
- `PUT /api/v1/cases/{id}`
- `POST /api/v1/cases/{id}/transition`

No se encontró ruta `basic-info` implementada en runtime.

### 6.2 DTO de actualización real
Se verificó que `UpdateCaseDto` expone como campos editables:

- `despacho`
- `etapa_procesal`
- `regimen_procesal`
- `proxima_actuacion`
- `fecha_proxima_actuacion`
- `responsable_proxima_actuacion`
- `observaciones`
- `agravantes`

Y mantiene como campos inmutables por diseño:

- `estado_actual`
- `responsable_id`
- `creado_por`
- `creado_en`
- `cliente_id`
- `radicado`
- `delito_imputado`

### 6.3 Validación runtime
Script ejecutado: `test_e5_22.sh`

Resultado:

- 6 pruebas pasadas
- 0 fallidas

Validaciones satisfactorias:
- Login admin exitoso
- `GET /cases/:id` retorna la ficha básica vía agregado raíz
- `PUT /cases/:id` actualiza los campos editables
- `GET /cases/:id` posterior refleja persistencia de cambios
- `GET /cases/:id/basic-info` retorna `404`
- `PUT /cases/:id/basic-info` retorna `404`

Evidencia del último caso de prueba:
- Radicado de prueba: `E522-1774748184`
- Case ID: `81604869-d91d-4ecb-87a1-23384dd49a57`

Resumen final del script:
- `[HALLAZGO CONFIRMADO] /basic-info NO existe en runtime`
- `[SUPERFICIE REAL] GET/PUT /cases/:id funciona correctamente`
- `[CONTRATO ALINEADO] Correccion contractual aplicada en CONTRATO_API.md`

### 6.4 Build
Ejecución de `npm run build` completada sin errores.

## 7. Resultado contractual aplicado
El archivo `docs/04_api/CONTRATO_API.md` quedó alineado con la implementación real mediante los siguientes cambios:

1. Actualización de cabecera de revisión a `2026-03-28 (E5-22)`.
2. Eliminación de la referencia residual a `/basic-info` en la convención de subrecursos.
3. Refuerzo de `GET /api/v1/cases/{caseId}` como vía oficial de consulta de ficha básica.
4. Refuerzo de `PUT /api/v1/cases/{caseId}` como vía oficial de actualización de ficha básica.
5. Incorporación explícita de campos inmutables.
6. Registro de E5-22 en historial de cambios.
7. Actualización del pie del documento.

## 8. Criterios de cierre verificados
La unidad E5-22 se considera cerrada porque se verificó que:

- el subrecurso `/basic-info` no existe en runtime
- la funcionalidad real ya está cubierta por `GET/PUT /cases/{caseId}`
- el contrato quedó alineado con la implementación efectiva
- no fue necesario introducir código productivo nuevo
- la evidencia runtime es satisfactoria
- el build del proyecto permanece estable

## 9. Impacto sobre el MDS
La unidad no implicó construcción funcional nueva ni ampliación de alcance.  
Se trató de una corrección de gobierno y contrato para preservar consistencia entre:

- runtime
- documentación API
- evidencia de validación

Esto mantiene disciplina metodológica y evita deuda por duplicidad semántica de endpoints.

## 10. Estado final
- Contrato API: ALINEADO
- Runtime: VALIDADO
- Build: ESTABLE
- Unidad E5-22: CERRADA

## 11. Observaciones finales
- El artefacto de diff preliminar quedó por fuera del cierre documental al haber sido superado por el estado real del contrato.
- No quedan pendientes funcionales dentro del alcance de E5-22.
- La unidad queda lista para `git add`, commit y push.

