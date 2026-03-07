# Reglas funcionales vinculantes — LexPenal

| Campo | Valor |
|---|---|
| Versión | 1.1 |
| Fecha | 2026-03-07 |
| Estado | Vigente |
| Documentos relacionados | `docs/00_gobierno/adrs/`, `docs/03_datos/REGLAS_NEGOCIO.md`, `docs/01_producto/ESTADOS_DEL_CASO_v3.md`, `docs/03_datos/MODELO_DATOS_v3.md`, `docs/04_api/CONTRATO_API_v4.md` |

---

## Propósito

Este documento registra las reglas funcionales que ninguna decisión técnica
puede ignorar sin una ADR que las modifique formalmente. Son el piso
no negociable del diseño del sistema.

Cada regla tiene: identificador, enunciado, consecuencias técnicas y ADR
asociada cuando aplica.

---

## R01 — El caso es la unidad central del sistema

**Enunciado**: Toda entidad operativa del sistema pertenece a un caso.
No existe registro operativo sin caso asociado. Esto incluye, entre otras:
hechos, línea de tiempo, pruebas, riesgos, estrategia, actuaciones procesales,
explicación al cliente, checklist, conclusión operativa, revisiones del supervisor,
documentos adjuntos, informes generados, logs de IA y eventos de auditoría.

**Consecuencias técnicas**:
- Todas las tablas operativas tienen una clave foránea obligatoria a `casos.id`.
- No se pueden crear registros de herramientas sin un caso activo.
- Al eliminar (o cerrar) un caso, los registros asociados se conservan —
  no se eliminan en cascada.
- El modelo de datos está organizado en torno al caso como agregador central
  (ver `MODELO_DATOS_v3.md` — Principio 1).

**ADR asociada**: ADR-002 (PostgreSQL), ADR-003 (máquina de estados).

---

## R02 — El checklist es una compuerta funcional vinculante

**Enunciado**: El estado del checklist de control de calidad condiciona
el avance del caso. Un caso con bloques críticos incompletos no puede
transitar a `pendiente_revision` ni generar el informe de conclusión
operativa, aunque el supervisor o el administrador lo intenten.

**Consecuencias técnicas**:
- `ChecklistService` verifica el estado del checklist antes de permitir
  las transiciones que lo requieren.
- El bloqueo retorna `422` — la transición existe pero falla una guarda
  de negocio, no es una transición inválida (`409`).
- El campo `completado` del bloque checklist es calculado por el backend
  a partir del estado de sus ítems — no puede escribirse directamente.
- La verificación no puede delegarse al frontend ni al controlador.

**ADR asociada**: ADR-003.

---

## R03 — La conclusión operativa es un entregable formal con estructura obligatoria

**Enunciado**: La conclusión operativa no es un campo de texto libre.
Tiene cinco bloques definidos que deben estar diligenciados para que
el sistema la considere completa. El informe de conclusión operativa
no puede generarse si la conclusión está incompleta.

**Consecuencias técnicas**:
- `conclusion_operativa` tiene campos estructurados en el modelo de datos,
  no un único campo de texto.
- `InformeService` verifica que los cinco bloques estén diligenciados
  antes de generar el informe `conclusion_operativa`.
- El campo de recomendación estratégica no puede estar vacío.
- La conclusión depende además de checklist sin bloques críticos incompletos
  (R02) y de estado `aprobado_supervisor` o posterior.

**ADR asociada**: ADR-005.

---

## R04 — La revisión del supervisor es un paso formal del flujo

**Enunciado**: Para que un caso pase de `pendiente_revision` a
`aprobado_supervisor` o `devuelto`, debe existir una revisión formal
registrada con observaciones escritas. La aprobación sin retroalimentación
no está permitida.

**Consecuencias técnicas**:
- La revisión formal se materializa en la tabla `revision_supervisor`,
  expuesta como el recurso `GET/POST /api/v1/cases/{id}/review`.
- `CasoEstadoService` verifica la existencia de un registro en
  `revision_supervisor` con `vigente = true` y `observaciones` no vacío
  antes de ejecutar la transición.
- Las observaciones son obligatorias tanto en aprobación (`resultado = 'aprobado'`)
  como en devolución (`resultado = 'devuelto'`).
- La revisión queda registrada como versión inmutable — no reemplaza
  revisiones anteriores. Solo un registro puede tener `vigente = true`
  por caso en cada momento.
- El bloqueo por ausencia de revisión retorna `422`.

**ADR asociada**: ADR-003.

---

## R05 — La IA es un asistente, no un decisor

**Enunciado**: El módulo de IA asiste al estudiante en el análisis —
sugiere, orienta, contextualiza. No escribe directamente en ningún campo
del expediente. La autoría del análisis es siempre del estudiante.

**Consecuencias técnicas**:
- La respuesta del módulo de IA se retorna al frontend para que el
  estudiante decida si la incorpora manualmente.
- Ningún endpoint de IA puede modificar campos de `casos` ni de sus
  herramientas operativas.
- Toda llamada al módulo de IA queda registrada en `ai_request_log`
  con prompt completo, respuesta, proveedor, modelo, tokens y duración.
- El log de IA es inmutable: solo `INSERT`, nunca `UPDATE` ni `DELETE`.

**ADR asociada**: ADR-004.

---

## R06 — Toda acción crítica es auditable

**Enunciado**: Las acciones críticas del sistema quedan registradas de
forma inmutable en `eventos_auditoria` con usuario, fecha, tipo de evento
y detalle suficiente para reconstruir lo ocurrido.

**Consecuencias técnicas**:
- `AuditoriaService` registra: login/logout, cambios de perfil, todas
  las transiciones de estado, generación de informes y revisiones del supervisor.
- Los registros de `eventos_auditoria` son inmutables: solo `INSERT`.
- Si el registro de auditoría falla, la operación principal también falla —
  no se permiten operaciones críticas sin rastro de auditoría
  (ver `ARQUITECTURA_BACKEND_v4.md` — reglas de implementación del backend).
- El administrador y el supervisor pueden consultar el log de auditoría
  de un caso. El estudiante no.

**ADR asociada**: N/A — regla de dominio propia del sistema.

---

## R07 — El módulo de IA es desacoplado por proveedor

**Enunciado**: El sistema no tiene dependencia directa de ningún proveedor
de IA. El proveedor es configurable sin cambiar código de la aplicación.
El cambio de proveedor no requiere modificar los servicios que usan el módulo.

**Consecuencias técnicas**:
- El módulo de IA implementa el patrón adaptador: `IAProviderAdapter`
  como interfaz, `AnthropicAdapter` como implementación por defecto del MVP.
- El proveedor, el modelo y las credenciales se configuran por variables
  de entorno — nunca en el código fuente.
- Añadir un nuevo proveedor requiere implementar `IAProviderAdapter`
  sin tocar `IAService` ni los controladores.
- El frontend nunca llama directamente a ningún proveedor de IA externo.

**ADR asociada**: ADR-004.

---

## R08 — Al activar un caso se genera automáticamente su estructura base

**Enunciado**: Al crear un caso y activarlo (transición `borrador → en_analisis`),
el sistema genera automáticamente los registros vacíos de todas las
herramientas operativas que tienen relación uno a uno con el caso.
El estudiante nunca crea estas herramientas manualmente — las encuentra
preexistentes y las diligencia.

Un caso en estado `borrador` no admite escritura en herramientas operativas.
El `borrador` es un estado de registro mínimo — el análisis no ha comenzado.

**Consecuencias técnicas**:
- La transición `borrador → en_analisis` en `CasoEstadoService` dispara
  la creación automática de: `checklist_bloques` y `checklist_items`
  (con todos los bloques e ítems del U008), `estrategia`, `explicacion_cliente`
  y `conclusion_operativa` vacíos (registros con `caso_id` y campos nulos).
- Esta creación es atómica con la transición de estado — si falla alguna
  inserción, la transición completa se revierte.
- Los endpoints de herramientas (`GET /strategy`, `GET /conclusion`, etc.)
  nunca retornan `404` en un caso activo — el registro siempre existe,
  aunque esté vacío.
- Toda operación de escritura sobre herramientas de un caso en `borrador`
  retorna `409` — el estado no permite esa operación. La verificación corre
  en `CasoEstadoService` antes de delegar al servicio de herramienta.
- `linea_tiempo` y `actuaciones` no se pre-crean — son colecciones vacías
  que el usuario popula libremente una vez el caso está activo.

**ADR asociada**: ADR-003.

---

## R09 — Un caso cerrado es inmutable

**Enunciado**: Un caso en estado `cerrado` no admite escritura en ningún
campo ni herramienta operativa. El expediente queda congelado como registro
histórico del trabajo realizado.

**Consecuencias técnicas**:
- Toda operación de escritura (`PUT`, `POST`, `DELETE`) sobre recursos de
  un caso en estado `cerrado` retorna `409` — el estado no permite esa
  operación.
- La verificación corre en `CasoEstadoService` antes de delegar a cualquier
  servicio de herramienta. Los servicios individuales no necesitan
  reimplementar este control.
- La generación de informes sobre un caso cerrado sigue siendo posible —
  es una operación de solo lectura.
- La consulta al módulo de IA sobre un caso cerrado está bloqueada —
  no tiene sentido analizar un expediente ya cerrado y generaría log
  innecesario.

**ADR asociada**: ADR-003.

---

## Reglas adicionales

Nuevas reglas se añaden siguiendo el formato de este documento con
identificador correlativo (R10, R11…). Toda regla que modifique una
existente debe documentarse también en el ADR correspondiente o en
uno nuevo si no existe ADR aplicable.
