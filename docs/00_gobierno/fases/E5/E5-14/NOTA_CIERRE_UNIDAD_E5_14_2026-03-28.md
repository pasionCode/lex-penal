# NOTA DE CIERRE UNIDAD E5-14 — 2026-03-28

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Consolidación
- Unidad: E5-14 — Alineación contractual y validación runtime de risks
- Fecha de cierre: 2026-03-28
- Estado: CERRADA

## 2. Objetivo de la unidad
Alinear el contrato API del recurso `risks` con la implementación vigente y validar en runtime el comportamiento funcional, las reglas de negocio, los controles de acceso, el aislamiento entre casos y el manejo de errores del módulo de riesgos.

## 3. Alcance ejecutado
Durante la unidad E5-14 se ejecutaron las siguientes acciones:

1. Se revisó la superficie funcional del recurso `risks`.
2. Se confirmó la existencia de cuatro endpoints operativos:
   - `POST /api/v1/cases/{caseId}/risks`
   - `GET /api/v1/cases/{caseId}/risks`
   - `GET /api/v1/cases/{caseId}/risks/{riskId}`
   - `PUT /api/v1/cases/{caseId}/risks/{riskId}`
3. Se ajustó el contrato API para reflejar:
   - recurso de colección por caso
   - edición completa mediante `PUT`
   - ausencia de `DELETE`
   - regla de negocio para prioridad crítica
   - códigos esperados
   - enums válidos
4. Se ejecutó validación runtime mediante `test_e5_14.sh`.
5. Se verificó compilación satisfactoria con `npm run build`.

## 4. Alineación contractual realizada
El contrato del módulo `risks` quedó alineado con la implementación validada, incorporando los siguientes elementos:

- documentación expresa de los endpoints:
  - `POST /api/v1/cases/{caseId}/risks`
  - `GET /api/v1/cases/{caseId}/risks`
  - `GET /api/v1/cases/{caseId}/risks/{riskId}`
  - `PUT /api/v1/cases/{caseId}/risks/{riskId}`
- corrección de política de edición:
  - se elimina la afirmación incorrecta de que solo `descripcion` es editable
  - se documenta que `PUT` permite actualización completa del recurso
- documentación de la regla de negocio:
  - si `prioridad = critica`, `estrategia_mitigacion` es obligatoria
- documentación de enums válidos:
  - `probabilidad`: `alta`, `media`, `baja`
  - `impacto`: `alto`, `medio`, `bajo`
  - `prioridad`: `critica`, `alta`, `media`, `baja`
  - `estado_mitigacion`: `pendiente`, `en_curso`, `mitigado`, `aceptado`
- tabla de respuestas esperadas:
  - `200`
  - `201`
  - `400`
  - `401`
  - `403`
  - `404`

## 5. Evidencia de validación runtime
Resultado de ejecución del script `test_e5_14.sh`:

- Pruebas pasadas: **20**
- Pruebas fallidas: **0**
- Resultado general: **VALIDACIÓN SATISFACTORIA**

### Cobertura validada
1. Login de administrador
2. Creación de cliente
3. Creación de caso
4. Activación de caso
5. Creación de riesgo
6. Consulta de lista de riesgos
7. Consulta de detalle de riesgo
8. Actualización de riesgo
9. `POST` crítico sin estrategia de mitigación
10. `PUT` a crítico sin estrategia de mitigación
11. `GET /risks` con caso inexistente
12. `POST /risks` con caso inexistente
13. `GET /risks/:id` con caso inexistente
14. `PUT /risks/:id` con caso inexistente
15. `GET /risks/:id` con riesgo inexistente
16. Protección contra fuga entre casos
17. `GET /risks` sin token
18. `POST /risks` sin token
19. `GET /risks` por estudiante ajeno al caso
20. `POST /risks` por estudiante ajeno al caso

## 6. Hallazgos funcionales confirmados
La validación permitió confirmar los siguientes comportamientos:

- `POST /risks` crea correctamente un riesgo con respuesta `201`
- `GET /risks` retorna la colección de riesgos del caso con respuesta `200`
- `GET /risks/{riskId}` retorna correctamente el detalle del riesgo con respuesta `200`
- `PUT /risks/{riskId}` actualiza correctamente el recurso con respuesta `200`
- la regla de negocio de prioridad crítica se cumple correctamente en creación y actualización
- los casos inexistentes responden con `404`
- los riesgos inexistentes responden con `404`
- la protección contra fuga entre casos responde con `404`
- los accesos sin autenticación responden con `401`
- el acceso de estudiante sobre caso ajeno responde con `403`

## 7. Validación de build
Se ejecutó `npm run build` al cierre de la unidad con resultado satisfactorio.

Estado:
- **Build verde**
- **Sin errores de compilación**

## 8. Resultado de la unidad
La unidad E5-14 queda cerrada satisfactoriamente porque:

- el contrato API del recurso `risks` quedó alineado con la implementación real
- la validación runtime cubrió satisfactoriamente los escenarios funcionales, de negocio y de seguridad definidos
- la compilación del proyecto cerró en verde
- no se identificaron divergencias pendientes entre contrato ajustado e implementación validada

## 9. Conclusión de cierre
Se declara **CERRADA** la unidad **E5-14 — Alineación contractual y validación runtime de risks**.

El recurso `risks` queda consolidado en esta etapa con:
- contrato alineado
- comportamiento funcional validado
- regla crítica validada
- controles de acceso verificados
- aislamiento entre casos verificado
- build satisfactorio
- evidencia trazable de cierre

## 10. Estado posterior
Tramo E5 consolidado al cierre de E5-14 para la superficie validada hasta la fecha.

Siguiente candidato natural de trabajo:
- revisión breve de siguiente recurso pendiente bajo el mismo patrón metodológico
