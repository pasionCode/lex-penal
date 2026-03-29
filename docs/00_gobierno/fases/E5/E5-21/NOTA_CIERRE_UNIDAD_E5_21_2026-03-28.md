# NOTA DE CIERRE UNIDAD E5-21 — 2026-03-28

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Consolidación
- Unidad: E5-21 — Alineación contractual y validación runtime de timeline
- Fecha de cierre: 2026-03-28
- Estado: CERRADA

## 2. Objetivo de la unidad
Alinear contractualmente el recurso `timeline` con la implementación vigente y validar en runtime su comportamiento como colección anidada `append-only`, con creación secuencial, orden automático por caso, respuesta paginada y controles de acceso consistentes con el modelo de seguridad del sistema.

## 3. Alcance ejecutado
Durante la unidad E5-21 se ejecutaron las siguientes acciones:

1. Se revisó la superficie funcional real del recurso `timeline`.
2. Se confirmó la existencia de dos endpoints operativos:
   - `GET /api/v1/cases/{caseId}/timeline`
   - `POST /api/v1/cases/{caseId}/timeline`
3. Se verificó que el recurso sigue un patrón `append-only` puro:
   - sin `GET` de detalle individual,
   - sin `PUT`,
   - sin `DELETE`.
4. Se validó que el backend asigna automáticamente el campo `orden` por caso al crear nuevas entradas.
5. Se validó la paginación funcional del listado mediante `page` y `per_page`.
6. Se documentó contractualmente el comportamiento del recurso en la sección 5.9 del `CONTRATO_API`.
7. Se ejecutó el script `test_e5_21.sh` con cobertura funcional y de seguridad.
8. Se validó compilación satisfactoria mediante `npm run build`.

## 4. Evidencia runtime
Resultado de ejecución de `test_e5_21.sh`:

- Pruebas pasadas: 13
- Pruebas fallidas: 0

### Cobertura validada
- Setup:
  - 01. Login admin → `200`
  - 02. POST `/clients` → `201`
  - 03. POST `/cases` → `201`
  - 04. Activar caso → `201`

- Colección append-only:
  - 05. GET `/timeline` lista vacía paginada → `200`
  - 06. POST `/timeline` primera entrada → `201`
  - 07. GET `/timeline` lista con 1 entrada → `200`

- Orden automático y paginación:
  - 08. POST `/timeline` segunda entrada con orden automático → `201`
  - 09. GET `/timeline` con paginación estricta → `200`

- Validaciones de error y acceso:
  - 10. POST `/timeline` con fecha inválida → `400`
  - 11. GET `/timeline` sobre caso inexistente → `404`
  - 12. GET `/timeline` sin token → `401`
  - 13. GET `/timeline` como estudiante ajeno → `403`

### Evidencia adicional
- Build del proyecto:
  - `npm run build` → OK

## 5. Patrón funcional validado
El recurso `timeline` quedó validado con el siguiente patrón:

- Tipo: colección anidada append-only paginada
- Cardinalidad: múltiples entradas por caso
- Alta: permitida vía `POST`
- Edición: no expuesta
- Eliminación: no expuesta
- Detalle individual: no expuesto
- Orden: automático y verificado en runtime
- Paginación: funcional y verificada en runtime

## 6. Contrato API
Se aplicó el ajuste contractual correspondiente al recurso `timeline`, incorporando:

- semántica `append-only` pura,
- parámetros de paginación,
- estructura de respuesta paginada,
- DTO de entrada,
- asignación automática de `orden`,
- tabla de códigos esperados.

Bloque aplicado:
- Sección 5.9 del `CONTRATO_API`

## 7. Resultado de la unidad
La unidad E5-21 queda cerrada satisfactoriamente, al haberse verificado que:

1. El recurso `timeline` implementa correctamente el patrón funcional esperado.
2. La superficie expuesta coincide con el diseño `append-only`.
3. La paginación funciona de forma consistente.
4. El orden automático fue comprobado en runtime.
5. Los controles de acceso y errores esperados fueron validados.
6. El contrato API quedó alineado con la implementación real.
7. La compilación del sistema permaneció en estado verde.

## 8. Estado actualizado del bloque C
- E5-09 — `subjects` → ✅
- E5-10 — `proceedings` → ✅
- E5-11 — `conclusion` → ✅
- E5-12 — `client-briefing` → ✅
- E5-13 — `reports` → ✅
- E5-14 — `risks` → ✅
- E5-15 — `review` → ✅
- E5-16 — `conclusion (runtime)` → ✅
- E5-17 — `checklist` → ✅
- E5-18 — `strategy` → ✅
- E5-19 — `documents` → ✅
- E5-20 — `facts` → ✅
- E5-21 — `timeline` → ✅

## 9. Declaración de cierre
Con evidencia runtime satisfactoria, contrato alineado y build exitoso, se declara formalmente cerrada la unidad **E5-21 — timeline** dentro de la fase E5 del proyecto LEX_PENAL.
