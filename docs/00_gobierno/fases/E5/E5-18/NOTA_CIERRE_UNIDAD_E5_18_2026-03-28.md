# NOTA DE CIERRE UNIDAD E5-18 — 2026-03-28

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Consolidación
- Unidad: E5-18 — Strategy: alineación contractual y validación runtime de subrecurso singleton
- Fecha de cierre: 2026-03-28
- Estado: CERRADA

## 2. Objetivo de la unidad
Alinear el contrato API del recurso `strategy` con la implementación vigente y validar en runtime su semántica singleton, la auto-creación en `GET`, el comportamiento de actualización y upsert en `PUT`, y los controles de acceso asociados al caso.

## 3. Alcance ejecutado
Durante la unidad E5-18 se ejecutaron las siguientes acciones:

1. Se revisó la superficie funcional real del recurso `strategy`.
2. Se confirmó la existencia de dos endpoints operativos:
   - `GET /api/v1/cases/{caseId}/strategy`
   - `PUT /api/v1/cases/{caseId}/strategy`
3. Se validó que el recurso opera como **singleton**, con exactamente una estrategia por caso.
4. Se verificó que `GET /strategy` auto-crea el registro si no existe (lazy initialization).
5. Se verificó que `PUT /strategy` actualiza la estrategia existente o la crea si no existe (upsert funcional), retornando `200` en ambos escenarios.
6. Se documentaron los siete campos del `UpdateStrategyDto` y sus restricciones de longitud.
7. Se alineó el contrato API con la semántica singleton, el comportamiento de auto-creación y upsert, y la tabla de códigos observada en runtime.
8. Se dejó trazabilidad explícita de la dependencia funcional de `linea_principal` para la transición `en_analisis -> pendiente_revision`, indicando que dicha guarda se ejecuta en el servicio de transiciones y no en el endpoint de `strategy`.
9. Se ejecutó validación runtime con doce pruebas y resultado satisfactorio.
10. Se verificó compilación del backend con `npm run build` en verde.

## 4. Evidencia runtime
Script ejecutado:
- `test_e5_18.sh`

Resultado observado:
- 12 pruebas pasadas
- 0 fallidas

Validaciones satisfactorias:
- Login admin → `200`
- `POST /clients` → `201`
- `POST /cases` → `201`
- Activación de caso → `201`
- `GET /strategy` sin registro previo → `200` con auto-creación
- `PUT /strategy` sobre registro existente → `200`
- `GET /strategy` posterior confirma persistencia y semántica singleton → `200`
- `PUT /strategy` sobre caso sin strategy previa → `200` con creación funcional
- caso inexistente → `404`
- sin token → `401`
- estudiante ajeno en `GET` → `403`
- estudiante ajeno en `PUT` → `403`

Casos de prueba reportados por el script:
- Caso principal: `E518-1774729107` → `f9704a04-fbe0-4030-b9bb-cdf7ce493432`
- Caso secundario: `E518B-1774729107` → `914d82f5-3695-4f8c-abb3-1adeff76a2eb`

## 5. Alineación contractual aplicada
Se actualizó la sección **5.5 Estrategia de defensa** en `docs/04_api/CONTRATO_API.md` para reflejar la implementación real del recurso.

Quedó documentado:
- que `strategy` es un recurso **singleton** por caso;
- que `GET /strategy` auto-crea el registro si no existe;
- que `PUT /strategy` actualiza o crea si no existe;
- que ambos caminos retornan `200`, nunca `201`;
- los siete campos del DTO con sus longitudes máximas;
- la tabla de respuestas esperadas: `200`, `400`, `401`, `403`, `404`;
- la dependencia funcional de `linea_principal` respecto de la transición a `pendiente_revision`.

## 6. Verificación de compilación
Se ejecutó:

```bash
npm run build
```

Resultado:
- compilación satisfactoria (`nest build` en verde)

## 7. Resultado técnico
La unidad E5-18 queda **resuelta**.

No se identificó necesidad de ajuste estructural en el módulo `strategy`.
La evidencia confirma que la implementación vigente es coherente con el patrón ya observado en `client-briefing` y `conclusion`, y que la deuda principal estaba en la documentación contractual, no en el código del recurso.

## 8. Trazabilidad MDS
La unidad se ejecutó conforme al enfoque MDS definido para E5:
- primero se contrastó baseline vs implementación real;
- luego se verificó comportamiento runtime con evidencia reproducible;
- posteriormente se alineó el contrato API;
- y finalmente se consolidó el cierre con build verde.

No se realizaron refactors cosméticos, cambios de modelo de datos ni ampliaciones de alcance fuera del objetivo validado.

## 9. Conclusión de cierre
Con base en la evidencia documental, runtime y de compilación, la unidad **E5-18 — Strategy** queda formalmente **CERRADA**.

Se declara satisfecho el objetivo de alineación contractual y validación runtime del subrecurso `strategy`, sin deuda estructural remanente en el alcance de la unidad.
