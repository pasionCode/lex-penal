# NOTA DE CIERRE UNIDAD E5-20 — 2026-03-28

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Consolidación
- Unidad: E5-20 — Alineación contractual y validación runtime de facts
- Fecha de cierre: 2026-03-28
- Estado: CERRADA

## 2. Objetivo de la unidad
Confirmar y documentar la superficie funcional real del subrecurso `facts`, completar el contrato API conforme a la implementación vigente y validar en runtime creación, consulta, edición, control de acceso, orden automático y respuestas esperadas.

## 3. Alcance ejecutado
Durante la unidad E5-20 se ejecutaron las siguientes acciones:

1. Se revisó la superficie funcional real del módulo `facts`.
2. Se confirmó la existencia de cuatro endpoints operativos:
   - `POST /api/v1/cases/{caseId}/facts`
   - `GET /api/v1/cases/{caseId}/facts`
   - `GET /api/v1/cases/{caseId}/facts/{factId}`
   - `PUT /api/v1/cases/{caseId}/facts/{factId}`
3. Se verificó la protección del recurso mediante `JwtAuthGuard`.
4. Se confirmó que el patrón funcional expuesto corresponde a una colección editable sin `DELETE`.
5. Se validó que la actualización expuesta por `PUT` opera con semántica efectiva de actualización parcial.
6. Se confirmó que el campo `orden` es asignado automáticamente por backend y no es editable por cliente.
7. Se documentaron los DTOs vigentes de creación y actualización, junto con sus enums funcionales.
8. Se actualizó el contrato API en la sección **5.1 Hechos** para reflejar el comportamiento implementado.
9. Se ejecutó validación runtime completa del subrecurso `facts`.
10. Se ejecutó compilación de backend satisfactoria mediante `npm run build`.

## 4. Patrón funcional validado
- Tipo: colección editable sin `DELETE` expuesto.
- Cardinalidad: múltiples hechos por caso.
- Creación: `POST` con asignación automática de `orden`.
- Consulta: lista por caso y detalle por identificador.
- Edición: `PUT` con actualización parcial de campos enviados.
- Restricción: `orden` no editable por cliente.
- Dependencia funcional documentada: para la transición `en_analisis -> pendiente_revision` se exige al menos un hecho registrado; esta validación reside en `caso-estado.service` y no en el módulo `facts`.

## 5. Evidencia runtime
Resultado de ejecución de `test_e5_20.sh`:

- Pruebas pasadas: **17**
- Pruebas fallidas: **0**

Cobertura validada:

1. Setup inicial (`01` a `04`) -> OK
2. Colección vacía y creación (`05` a `07`) -> OK
3. Detalle y update parcial (`08` a `10`) -> OK
4. Orden automático incremental (`11`) -> OK
5. Hecho inexistente y hecho perteneciente a otro caso (`12` a `14`) -> OK
6. Payload inválido (`15`) -> OK
7. Ausencia de token (`16`) -> OK
8. Acceso de estudiante ajeno (`17`) -> OK

Evidencias puntuales confirmadas:
- `GET /facts` sobre colección vacía -> `200`
- `POST /facts` -> `201`
- `GET /facts/:factId` -> `200`
- `PUT /facts/:factId` con update parcial -> `200`
- preservación de campos no enviados en update -> verificada
- segundo hecho con `orden=2` > `orden=1` -> verificado
- hecho inexistente -> `404`
- hecho de otro caso -> `404`
- payload inválido -> `400`
- sin token -> `401`
- estudiante ajeno -> `403`

## 6. Evidencia de build
Compilación ejecutada con resultado satisfactorio:

- `npm run build` -> **OK**

## 7. Contrato y documentación
Se dejó alineado el contrato del recurso `facts` con la implementación vigente en:

- `docs/04_api/CONTRATO_API.md`
- Sección **5.1 Hechos**

Aspectos contractuales consolidados:
- endpoints expuestos del subrecurso
- semántica de colección editable sin `DELETE`
- DTOs de create/update
- enums válidos
- orden automático no editable
- tabla de códigos esperados
- dependencia funcional documentada con transición de caso

## 8. Conclusión de la unidad
La unidad E5-20 no requirió ajuste estructural de código. La implementación del subrecurso `facts` ya se encontraba operativa y la unidad permitió:

- confirmar su superficie funcional real,
- validar runtime con evidencia suficiente,
- y completar su alineación contractual conforme al comportamiento vigente.

En consecuencia, la unidad **E5-20 queda formalmente CERRADA**.

## 9. Estado actualizado del bloque
- E5-09 — `subjects` -> CERRADA
- E5-10 — `proceedings` -> CERRADA
- E5-11 — `conclusion` -> CERRADA
- E5-12 — `client-briefing` -> CERRADA
- E5-13 — `reports` -> CERRADA
- E5-14 — `risks` -> CERRADA
- E5-15 — `review` -> CERRADA
- E5-16 — `conclusion (runtime)` -> CERRADA
- E5-17 — `checklist` -> CERRADA
- E5-18 — `strategy` -> CERRADA
- E5-19 — `documents` -> CERRADA
- E5-20 — `facts` -> CERRADA
