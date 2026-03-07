# Criterios de aceptación jurídico-funcionales — LexPenal MVP

| Campo | Valor |
|---|---|
| Versión | 1.0 |
| Fecha | 2026-03-06 |
| Estado | Vigente — pendiente verificación por módulo |
| Documentos relacionados | `docs/14_legal_funcional/REGLAS_FUNCIONALES_VINCULANTES.md`, `docs/09_calidad/CALIDAD_BASE.md`, `docs/01_producto/ESTADOS_DEL_CASO_v3.md` |

---

## Propósito

Este documento define los criterios de aceptación jurídico-funcionales
del MVP. Cada criterio puede responderse con SÍ o NO sin ambigüedad —
si no puede responderse así, el criterio debe reformularse antes de usarse
en pruebas.

**Estado por criterio**: `pendiente` / `verificado` / `fallido`.

---

## Ficha del caso

- [ ] El sistema permite registrar todos los campos obligatorios de la
  ficha: radicado, datos del procesado, delito imputado, etapa procesal,
  situación de libertad.
  **Condición**: crear un caso y completar todos los campos — verificar
  persistencia al recargar.
  **Estado**: pendiente

- [ ] El radicado es único por caso — no pueden existir dos casos con
  el mismo radicado.
  **Condición**: intentar crear dos casos con el mismo radicado — el
  segundo debe retornar error.
  **Estado**: pendiente

- [ ] Un caso en estado `borrador` no acepta escritura en herramientas
  operativas.
  **Condición**: intentar escribir en hechos o pruebas con caso en
  `borrador` — debe retornar `409`.
  **Estado**: pendiente

---

## Hechos

- [ ] El sistema permite registrar múltiples hechos con descripción, estado y fuente.
  **Condición**: registrar tres hechos con `descripcion`, `estado_hecho` y `fuente`
  distintos — verificar que todos persisten con sus datos correctos.
  **Estado**: pendiente

- [ ] El intento de enviar a revisión sin hechos registrados es bloqueado.
  **Condición**: activar caso, no registrar hechos, intentar transición
  a `pendiente_revision` — debe retornar `422`.
  **Estado**: pendiente

- [ ] Los hechos son de solo lectura en `pendiente_revision`.
  **Condición**: transitar a `pendiente_revision` e intentar editar
  un hecho — debe retornar `409`.
  **Estado**: pendiente

---

## Pruebas

- [ ] El sistema permite registrar pruebas con los campos canónicos del modelo:
  `tipo_prueba`, `descripcion`, `licitud`, `legalidad`, `suficiencia`,
  `credibilidad` y `posicion_defensiva`.
  **Condición**: registrar al menos dos pruebas de distintos `tipo_prueba`
  con todos los campos diligenciados — verificar persistencia completa.
  **Estado**: pendiente

- [ ] Una prueba puede vincularse a un hecho de la matriz (`hecho_id`) o
  usar texto libre (`hecho_descripcion_libre`). Al menos uno de los dos
  debe estar diligenciado.
  **Condición**: intentar guardar una prueba con ambos campos vacíos —
  debe retornar `422`. Guardar con solo `hecho_descripcion_libre` diligenciado
  debe persistir correctamente.
  **Estado**: pendiente

---

## Riesgos

- [ ] El sistema permite registrar riesgos con probabilidad, impacto y
  estrategia de mitigación.
  **Condición**: registrar dos riesgos con todos los campos y verificar
  persistencia.
  **Estado**: pendiente

- [ ] El estado de mitigación de un riesgo puede actualizarse.
  **Condición**: cambiar el estado de un riesgo de `pendiente` a `mitigado`
  y verificar el cambio.
  **Estado**: pendiente

---

## Estrategia

- [ ] El campo `linea_principal` es obligatorio para enviar a revisión.
  **Condición**: dejar `linea_principal` vacío e intentar transición
  a `pendiente_revision` — debe retornar `422`.
  **Estado**: pendiente

- [ ] El análisis dogmático (tipicidad, antijuridicidad, culpabilidad)
  puede registrarse de forma independiente por bloque.
  **Condición**: diligenciar solo el bloque de tipicidad y guardar —
  debe persistir sin requerir los otros bloques.
  **Estado**: pendiente

---

## Checklist de control de calidad

- [ ] El checklist se genera automáticamente al activar el caso.
  **Condición**: crear un caso, activarlo (`borrador → en_analisis`)
  y verificar que `checklist_bloques` y `checklist_items` existen.
  **Estado**: pendiente

- [ ] El avance a `pendiente_revision` requiere checklist sin bloques
  críticos incompletos (R02).
  **Condición**: intentar la transición con al menos un bloque crítico
  incompleto — debe retornar `422` con detalle del bloque.
  **Estado**: pendiente

- [ ] Marcar todos los ítems de un bloque crítico actualiza `completado`
  del bloque.
  **Condición**: marcar todos los ítems de un bloque crítico y consultar
  el estado del bloque — debe aparecer como completo.
  **Estado**: pendiente

---

## Conclusión operativa

- [ ] La conclusión tiene cinco bloques estructurados que pueden
  diligenciarse independientemente.
  **Condición**: completar dos de los cinco bloques y guardar — deben
  persistir sin requerir los otros tres.
  **Estado**: pendiente

- [ ] El informe de conclusión operativa no puede generarse con bloques
  de la conclusión incompletos.
  **Condición**: dejar dos bloques de conclusión vacíos e intentar
  generar el informe — debe retornar `422` con lista de bloques faltantes.
  **Estado**: pendiente

- [ ] La conclusión no puede generarse si el checklist tiene bloques
  críticos incompletos.
  **Condición**: tener conclusión completa pero checklist incompleto
  e intentar generar el informe — debe retornar `422`.
  **Estado**: pendiente

---

## Flujo de revisión del supervisor

- [ ] Un caso no puede pasar a `aprobado_supervisor` sin revisión formal
  con observaciones (R04).
  **Condición**: intentar aprobar sin registrar revisión — debe retornar `422`.
  **Estado**: pendiente

- [ ] Las observaciones del supervisor son obligatorias tanto en
  aprobación como en devolución.
  **Condición**: intentar aprobar o devolver con campo de observaciones
  vacío — debe retornar `422`.
  **Estado**: pendiente

- [ ] El caso devuelto pasa a estado `devuelto`, no directamente a
  `en_analisis`.
  **Condición**: ejecutar devolución y verificar que el estado del caso
  es `devuelto` — no `en_analisis`.
  **Estado**: pendiente

- [ ] El historial de revisiones es inmutable — las revisiones anteriores
  no pueden modificarse.
  **Condición**: registrar dos revisiones y verificar que la primera
  sigue intacta tras registrar la segunda.
  **Estado**: pendiente

---

## Módulo de IA

- [ ] Toda llamada al módulo de IA queda registrada en `ai_request_log` (R05, R06).
  **Condición**: hacer tres consultas al asistente y verificar que existen
  tres registros en el log con proveedor, modelo y tokens.
  **Estado**: pendiente

- [ ] La respuesta de IA no modifica directamente ningún campo del caso (R05).
  **Condición**: hacer una consulta al asistente y verificar que ningún
  campo de las herramientas del caso fue modificado.
  **Estado**: pendiente

- [ ] El fallo del proveedor de IA retorna `503` sin afectar el flujo
  del caso.
  **Condición**: simular fallo del proveedor y verificar que el caso
  sigue en su estado actual y las herramientas son accesibles.
  **Estado**: pendiente

- [ ] El proveedor de IA es configurable sin cambiar código (R07).
  **Condición**: cambiar la variable de entorno del proveedor y verificar
  que el sistema usa el nuevo proveedor sin recompilación.
  **Estado**: pendiente

---

## Auditoría

- [ ] Las transiciones de estado del caso quedan registradas con usuario,
  fecha y estados origen/destino (R06).
  **Condición**: ejecutar tres transiciones y verificar que existen
  tres eventos en `eventos_auditoria` con los datos correctos.
  **Estado**: pendiente

- [ ] Los eventos de auditoría son inmutables.
  **Condición**: intentar modificar un evento de auditoría directamente
  — debe ser rechazado por el sistema.
  **Estado**: pendiente

- [ ] El administrador puede consultar el log de auditoría de un caso.
  El estudiante no puede.
  **Condición**: consultar el endpoint de auditoría con perfil estudiante
  — debe retornar `403`.
  **Estado**: pendiente

---

## Criterios transversales de autorización

- [ ] Un estudiante no puede acceder a casos que no le pertenecen.
  **Condición**: intentar acceder al caso de otro estudiante con el
  token del primero — debe retornar `403`.
  **Estado**: pendiente

- [ ] Un supervisor no puede editar el análisis de un caso.
  **Condición**: intentar escribir en una herramienta con perfil supervisor
  — debe retornar `403`.
  **Estado**: pendiente

- [ ] Un usuario desactivado no puede iniciar sesión.
  **Condición**: desactivar un usuario e intentar login — debe retornar `401`.
  **Estado**: pendiente
