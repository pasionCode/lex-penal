# ADR-004 — Módulo de IA desacoplado del núcleo del sistema

| Campo | Valor |
|---|---|
| Estado | **Cerrado** |
| Fecha | 2026-03-06 |
| Decisor | Equipo técnico LexPenal |
| Documentos relacionados | `docs/12_ia/ARQUITECTURA_MODULO_IA.md`, `docs/03_datos/REGLAS_NEGOCIO.md`, `docs/06_backend/ARQUITECTURA_BACKEND.md`, `docs/04_api/CONTRATO_API.md` |

---

## Contexto

LexPenal incorpora un asistente de IA jurídico que apoya el análisis
de cada herramienta del expediente. La decisión de arquitectura central
es cómo se integra ese módulo con el resto del sistema: si se acopla
directamente al flujo del caso o si opera como una capa de asistencia
independiente.

El contexto del dominio impone restricciones claras:
- La IA orienta y sugiere — no decide ni valida (RN-IA-01).
- Ninguna respuesta de IA puede escribirse automáticamente en el
  expediente (RN-IA-01).
- El proveedor de IA puede cambiar sin afectar el resto del sistema
  (RN-IA-04).
- Si la IA no está disponible, el sistema debe seguir operando con
  normalidad (RN-IA-05).
- Toda llamada al módulo de IA debe quedar auditada (RN-IA-02).

---

## Opciones evaluadas

### Opción A — Módulo desacoplado con patrón adaptador

El módulo de IA opera como una capa de asistencia completamente
separada del núcleo del sistema. El único punto de entrada es el
endpoint `POST /api/v1/ai/query`. El backend gestiona credenciales,
selección de proveedor y auditoría. El proveedor concreto queda
detrás de una interfaz común (`IAProviderAdapter`), intercambiable
sin modificar servicios ni controladores.

**Flujo**
```
Frontend → POST /api/v1/ai/query
  → IAController (valida entrada y acceso al caso)
  → IAService (orquesta: contexto + prompt + proveedor + log)
  → IAOrchestrator (selecciona proveedor, ejecuta llamada)
  → IAProviderAdapter (interfaz común — Anthropic, OpenAI, etc.)
  → AIRequestLogRepository (registro inmutable, siempre)
  → respuesta al panel del asistente (nunca al formulario)
```

**Ventajas**
- El núcleo del sistema (casos, herramientas, transiciones) no tiene
  dependencia del módulo de IA. Si la IA falla, el sistema opera
  con normalidad.
- El proveedor es intercambiable mediante configuración — cambiar
  de Anthropic a OpenAI implica implementar un nuevo adaptador, sin
  modificar lógica de negocio.
- La auditoría es centralizada y garantizada: todo pasa por
  `IAService`, que escribe en `ai_request_log` incluso si la
  llamada falla.
- La separación física entre panel de asistente y formulario del
  caso refuerza la regla de que la IA no escribe en el expediente.
- El proveedor, modelo y credenciales viven en variables de entorno
  — nunca en el código fuente.

**Desventajas**
- Requiere diseñar e implementar la interfaz `IAProviderAdapter`
  y los adaptadores concretos desde el inicio.
- Mayor estructura inicial comparado con una llamada directa al
  proveedor desde el controlador.

---

### Opción B — Integración directa al flujo del caso

El módulo de IA se integra como parte del flujo de análisis.
Las herramientas del caso pueden llamar directamente al proveedor
de IA y recibir respuestas que alimentan los campos del expediente.

**Ventajas**
- Implementación inicial más rápida.
- Menor cantidad de capas de código.

**Desventajas**
- El núcleo del sistema queda acoplado al proveedor concreto —
  cambiar de proveedor implica modificar múltiples servicios.
- Si la IA no está disponible, el flujo del caso puede verse
  bloqueado o degradado.
- La trazabilidad de qué produjo el estudiante y qué produjo
  la IA queda comprometida — problema grave en contexto
  pedagógico y jurídico.
- Incompatible con RN-IA-01: si la IA puede escribir en los
  campos del caso, se pierde la distinción entre análisis
  humano y sugerencia automatizada.
- Las credenciales del proveedor quedarían expuestas o
  gestionadas de forma distribuida.

---

### Opción C — IA en el frontend (llamada directa al proveedor)

El frontend llama directamente a la API del proveedor de IA
sin pasar por el backend de LexPenal.

**Ventajas**
- Sin carga adicional en el backend.

**Desventajas**
- Las credenciales del proveedor quedan expuestas en el cliente —
  violación directa de RN-IA-03.
- Sin auditoría posible de las llamadas — viola RN-IA-02.
- Sin control centralizado del proveedor ni del modelo usado.
- El frontend no tiene acceso al contexto jurídico completo del
  caso necesario para construir prompts de calidad.
- Incompatible con los principios de seguridad del sistema.

---

## Criterios de decisión

| Criterio | Módulo desacoplado | Integración directa | IA en frontend |
|---|---|---|---|
| Aislamiento de fallos | ✅ Total | ❌ Parcial | ❌ Ninguno |
| Proveedor intercambiable | ✅ Sin tocar negocio | ❌ Requiere cambios | ❌ Requiere cambios |
| Auditoría garantizada | ✅ Centralizada | ⚠️ Parcial | ❌ Imposible |
| Credenciales protegidas | ✅ Solo en servidor | ⚠️ Riesgo | ❌ Expuestas |
| IA no escribe en expediente | ✅ Arquitectura lo impone | ❌ Requiere disciplina | ❌ Requiere disciplina |
| Complejidad de implementación | Media | Baja | Baja |
| Adecuación al dominio jurídico | Alta | Baja | Nula |

---

## Decisión

> **[x] Opción A — Módulo desacoplado con patrón adaptador**

**Justificación**: Las reglas de negocio del dominio jurídico
(RN-IA-01 a RN-IA-05) imponen restricciones que solo la Opción A
puede garantizar arquitectónicamente. El desacoplamiento no es
una preferencia de diseño — es un requisito: la IA no puede
bloquear el flujo del caso, no puede escribir en el expediente,
y su proveedor debe ser intercambiable sin afectar la lógica
de negocio. La complejidad adicional de implementar el patrón
adaptador es proporcional a los beneficios obtenidos en
trazabilidad, seguridad y mantenibilidad.

---

## Consecuencias

- El módulo de IA expone un único endpoint: `POST /api/v1/ai/query`.
  El frontend nunca llama directamente a ningún proveedor externo.
- `IAProviderAdapter` es la interfaz común para todos los proveedores.
  El MVP implementa `AnthropicAdapter` como proveedor inicial. El modelo
  concreto (actualmente `claude-sonnet-4`) es configurable — no es parte
  fija de este ADR ni del código fuente. `OpenAIAdapter` y otros quedan
  como estructura reservada para fases posteriores.
- En el MVP, el proveedor activo es global a la instalación — un único
  proveedor y modelo para todos los usuarios. La selección de proveedor
  por usuario queda fuera del alcance inicial salvo decisión posterior.
- El proveedor y el modelo se configuran fuera del código fuente (RN-IA-04).
  El mecanismo exacto de cambio operativo —variables de entorno, archivo
  de configuración u otro— se define en la arquitectura del módulo.
  Las credenciales nunca residen en el repositorio.
- `AIRequestLogRepository` solo implementa `INSERT`. Ningún
  mecanismo del sistema puede eliminar ni modificar registros de
  IA (RN-AUD-02). El log se escribe incluso si la llamada falla.
- Si el proveedor no responde, el sistema retorna `503` exclusivamente
  en el endpoint de IA. Ningún flujo del caso queda bloqueado
  (RN-IA-05).
- Las credenciales del proveedor viven en variables de entorno del
  servidor. No se incluyen en el repositorio ni son accesibles
  desde el frontend (RN-IA-03).
- El panel del asistente en el frontend es un componente separado
  del formulario de la herramienta. No existe mecanismo automático
  de transferencia de respuesta a campos del expediente (RN-IA-01).
- La arquitectura completa del módulo se documenta en
  `ARQUITECTURA_MODULO_IA.md`.
