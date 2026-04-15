# BASELINE UNIDAD E35-01 — 2026-04-14

## 1. Contexto de partida
La fase E35 ya fue abierta formalmente. La unidad E35-01 se define para intervenir de forma controlada una zona sensible del backend: la relación entre el módulo AI y el estado procesal del caso.

## 2. Hipótesis operativa de trabajo
Existe riesgo de desalineación entre:
- la máquina de estados del caso,
- las restricciones efectivas aplicadas al módulo AI,
- y la semántica expuesta por el contrato API o por el comportamiento runtime.

La unidad no presupone fallo; presupone necesidad de verificación rigurosa.

## 3. Línea base técnica
La revisión deberá concentrarse, como mínimo, en:
- `src/modules/ai`
- `src/modules/cases`
- `docs/04_api/CONTRATO_API.md`

También podrán revisarse scripts auxiliares de diagnóstico ya existentes, sin incorporarlos automáticamente al cierre mientras no sean saneados y validados.

## 4. Riesgo controlado
El riesgo principal es permitir consultas AI en estados no habilitados, o bloquearlas con semántica inconsistente respecto de la lógica de negocio. Cualquiera de los dos escenarios afecta predictibilidad, contrato y trazabilidad.

## 5. Resultado esperado de la unidad
Al cierre de E35-01 debe existir una regla técnicamente clara, documentada y validada por ejecución reproducible sobre el comportamiento del módulo AI frente al estado del caso.
