# Arquitectura del módulo de IA

Documento de referencia de la arquitectura del módulo de inteligencia artificial de LexPenal.
Define principios, componentes, flujos, gestión de prompts, proveedores,
auditoría y reglas de implementación.

**Documentos relacionados**
- `docs/00_gobierno/adrs/ADR-004-modulo-ia-desacoplado.md`
- `docs/03_datos/REGLAS_NEGOCIO.md` — RN-IA-01 a RN-IA-05
- `docs/03_datos/MODELO_DATOS.md` — tabla `ai_request_log`
- `docs/04_api/CONTRATO_API.md` — `POST /api/v1/ai/query`
- `docs/06_backend/ARQUITECTURA_BACKEND.md` — `IAService`
- `docs/07_frontend/ARQUITECTURA_FRONTEND.md` — `PanelAsistente`

| Campo | Valor |
|---|---|
| Última revisión | (completar) |
| Responsable | (completar) |

---

## Alcance de este documento

Este documento cubre el módulo de IA a nivel arquitectónico:
principios, componentes internos, flujo de una consulta, gestión de prompts,
política de proveedores, auditoría y reglas de implementación.

La redacción de prompts por herramienta y los criterios de evaluación
de respuestas se desarrollarán en:
- `PROMPTS_POR_HERRAMIENTA.md` — plantillas y lógica de construcción de prompt.
- `CRITERIOS_EVALUACION_IA.md` — cómo evaluar calidad de respuesta por herramienta.

---

## Principios del módulo

**PIA-01 — La IA es un asistente, no un decisor.**
El módulo de IA orienta, sugiere y apoya el análisis. No puede validar un caso,
aprobar un análisis ni determinar la estrategia de defensa.
Toda decisión jurídica es del responsable del caso. (RN-IA-01)

**PIA-02 — La IA no escribe en el expediente.**
Ninguna respuesta del módulo de IA puede transferirse automáticamente
a ningún campo del caso. No existe botón de "aplicar al caso",
"rellenar con IA" ni mecanismo equivalente.
El usuario lee la respuesta y decide manualmente qué incorpora. (RN-IA-01)

**PIA-03 — El frontend nunca llama a proveedores directamente.**
Toda consulta pasa por el endpoint `POST /api/v1/ai/query`.
El backend gestiona credenciales, selección de proveedor y registro de auditoría.
Las claves de API de los proveedores no son accesibles desde el cliente. (RN-IA-03)

**PIA-04 — El proveedor es intercambiable sin cambiar código de negocio.**
El módulo usa el patrón adaptador. Cambiar de proveedor implica
implementar un nuevo adaptador — no modificar servicios ni controladores. (RN-IA-04)

**PIA-05 — El módulo falla de forma aislada.**
Si el proveedor de IA no responde, el sistema retorna `503` en el endpoint
de consulta. Ningún flujo del caso (transiciones, herramientas, informes) se
bloquea por la indisponibilidad del módulo de IA. (RN-IA-05)

**PIA-06 — Toda llamada es auditada sin excepción.**
Cada invocación genera un registro inmutable en `ai_request_log` con:
prompt completo, respuesta, proveedor, modelo, tokens y duración.
El registro se escribe incluso si la llamada falla. (RN-IA-02)

**PIA-07 — El contexto jurídico del caso acompaña cada consulta.**
El prompt enviado al proveedor incluye siempre el contexto relevante del caso
(radicado, delito imputado, etapa procesal, régimen). El asistente no opera
sobre texto suelto desvinculado del expediente.

---

## Componentes del módulo

```
┌────────────────────────────────────────────────────────┐
│                    IAController                        │
│         POST /api/v1/ai/query                          │
│         Valida entrada, verifica acceso al caso        │
└────────────────────┬───────────────────────────────────┘
                     │
┌────────────────────▼───────────────────────────────────┐
│                    IAService                           │
│   Orquesta: contexto → prompt → proveedor → log       │
└──────┬─────────────┬──────────────────┬────────────────┘
       │             │                  │
┌──────▼──────┐ ┌────▼────────────┐ ┌──▼──────────────────┐
│  Caso       │ │ Prompt          │ │ IAOrchestrator      │
│  Repository │ │ Template        │ │                     │
│             │ │ Repository      │ │ selecciona proveedor│
│ contexto    │ │                 │ │ construye payload   │
│ del caso    │ │ plantilla por   │ │ ejecuta llamada     │
└─────────────┘ │ herramienta     │ └──────────┬──────────┘
                └─────────────────┘            │
                                    ┌──────────▼──────────┐
                                    │  IAProviderAdapter  │
                                    │  (interfaz común)   │
                                    └──────┬──────────────┘
                                           │
                        ┌──────────────────┼──────────────────┐
                        │                  │                  │
               ┌────────▼───────┐ ┌────────▼───────┐ ┌───────▼────────┐
               │ Anthropic      │ │ OpenAI         │ │ (futuro)       │
               │ Adapter        │ │ Adapter        │ │                │
               └────────────────┘ └────────────────┘ └────────────────┘
                        │
                ┌───────▼──────────────┐
                │  AIRequestLog        │
                │  Repository          │
                │  (solo INSERT)       │
                └──────────────────────┘
```

### `IAController`
Recibe la solicitud del cliente. Responsabilidades:
- Validar que `caso_id`, `herramienta` y `consulta` están presentes.
- Verificar que el usuario autenticado tiene acceso al caso.
- Delegar a `IAService`. No contiene lógica de prompt ni de proveedor.

---

### `IAService`
Orquesta el flujo completo de una consulta. Es el único servicio que
coordina todos los componentes del módulo.

Operación `consultar(caso_id, herramienta, consulta, usuario)`:
1. Carga el contexto del caso desde `CasoRepository`.
2. Solicita la plantilla de prompt a `PromptTemplateRepository`.
3. Construye el prompt completo con contexto + plantilla + consulta del usuario.
4. Entrega al `IAOrchestrator` para ejecución.
5. Registra la llamada en `AIRequestLogRepository` — exitosa o fallida.
6. Retorna la respuesta al controlador.

---

### `IAOrchestrator`
Selecciona el proveedor configurado, construye el payload según su API
y ejecuta la llamada HTTP. Encapsula las diferencias de formato entre proveedores.

Responsabilidades:
- Leer proveedor y modelo desde configuración (`ia.config`).
- Adaptar el prompt al formato que espera el proveedor (roles, sistema, usuario).
- Manejar timeout y reintentos según política definida.
- Retornar la respuesta normalizada o lanzar `ProveedorIANoDisponible`.

---

### `IAProviderAdapter` (interfaz)
Contrato común que todo adaptador de proveedor debe implementar:

```typescript
interface IAProviderAdapter {
  consultar(payload: IAPayload): Promise<IARespuesta>
}

interface IAPayload {
  sistema:  string   // instrucción de sistema / rol del asistente
  mensajes: { rol: 'usuario' | 'asistente', contenido: string }[]
  modelo:   string
  max_tokens: number
}

interface IARespuesta {
  contenido:      string
  tokens_entrada: number
  tokens_salida:  number
  modelo_usado:   string
  duracion_ms:    number
}
```

**Alcance del contrato en MVP**: el payload está orientado a consulta simple
por herramienta — una solicitud, una respuesta. El array `mensajes` permite
estructurar el turno de usuario con contexto adicional, pero no implementa
conversación multi-turno persistente entre sesiones.
La conversación multi-turno persistente queda fuera del MVP para evitar
sobreexpectativas: el historial visible en el `PanelAsistente` vive solo
en el estado del componente cliente y se pierde al recargar.

---

### `AnthropicAdapter` — proveedor por defecto del MVP
Implementa `IAProviderAdapter` contra la API de Anthropic.
Los parámetros operativos (timeout, reintentos, max tokens) los hereda
de la política central del módulo — no define valores propios.
El modelo se lee siempre desde `ia.config`, nunca del código fuente.

| Parámetro | Referencia |
|---|---|
| Modelo activo | `ia.config → proveedor.modelo` |
| Parámetros operativos | Política operativa del módulo |

---

### `PromptTemplateRepository`
Repositorio de plantillas de prompt por herramienta.
Cada herramienta de la U008 tiene su propia plantilla con:
- instrucción de sistema (rol del asistente jurídico).
- estructura del contexto del caso a incluir.
- guías de formato de respuesta.

Las plantillas son archivos de texto o registros en base de datos —
la decisión de almacenamiento se documenta en `PROMPTS_POR_HERRAMIENTA.md`.

Herramientas con plantilla obligatoria en MVP:

| Herramienta | Foco del asistente |
|---|---|
| Ficha básica | Identificación de vacíos en la ficha; etapa procesal |
| Matriz de hechos | Identificación de hechos relevantes; puntos de fricción |
| Matriz probatoria | Evaluación de licitud, legalidad y suficiencia |
| Matriz de riesgos | Identificación de riesgos no listados; priorización |
| Estrategia de defensa | Líneas defensivas disponibles; coherencia con hechos |
| Explicación al cliente | Claridad del lenguaje; completitud de opciones |
| Checklist de calidad | Detección de bloques débiles; sugerencias de mejora |
| Conclusión operativa | Coherencia interna; solidez de la recomendación |

---

### `AIRequestLogRepository`
Repositorio de escritura inmutable del log de IA.
Solo implementa `INSERT`. No expone métodos de actualización ni eliminación.

**Política de acceso de lectura**:

| Tipo de lectura | Quién puede | Endpoint |
|---|---|---|
| Por caso — logs del expediente | Supervisor y Administrador | `GET /api/v1/cases/{id}/audit` (filtrado por tipo `ia_query`) |
| Global del sistema | Solo Administrador | Reservado para fase posterior |
| Interna de auditoría | Acceso directo a BD — no por API | Herramienta de administración del servidor |

En el MVP, la lectura del log de IA por caso queda integrada en el endpoint
de auditoría general del caso. No se expone un endpoint específico de log de IA.

Campos que registra por cada llamada:

| Campo | Fuente |
|---|---|
| `caso_id` | Parámetro de entrada |
| `usuario_id` | Usuario autenticado en sesión |
| `herramienta` | Parámetro de entrada |
| `proveedor` | Configuración activa al momento de la llamada |
| `modelo` | Configuración activa al momento de la llamada |
| `prompt_enviado` | Prompt completo construido antes de enviar |
| `respuesta_recibida` | Respuesta completa del proveedor |
| `tokens_entrada` | Retornado por el proveedor |
| `tokens_salida` | Retornado por el proveedor |
| `duracion_ms` | Medido internamente |
| `estado_llamada` | `exitosa`, `fallida`, `timeout` |
| `error_mensaje` | Mensaje de error si aplica |

---

## Flujo completo de una consulta

```
Usuario (Client Component)
  └─ escribe consulta en PanelAsistente
  └─ POST /api/v1/ai/query
       { caso_id, herramienta: "matriz_hechos", consulta: "..." }

IAController
  ├─ valida campos presentes
  ├─ verifica acceso del usuario al caso
  └─ IAService.consultar(...)

IAService
  ├─ 1. CasoRepository.obtener(caso_id)
  │      → { radicado, delito_imputado, etapa_procesal, regimen_procesal }
  ├─ 2. PromptTemplateRepository.obtener("matriz_hechos")
  │      → plantilla con instrucción de sistema y estructura
  ├─ 3. Construir prompt completo:
  │      sistema: [instrucción de rol jurídico + contexto del caso]
  │      usuario: [plantilla + consulta del usuario]
  ├─ 4. IAOrchestrator.ejecutar(payload)
  │      ├─ lee proveedor y modelo desde ia.config
  │      ├─ AnthropicAdapter.consultar(payload)
  │      │    └─ POST https://api.anthropic.com/v1/messages
  │      └─ retorna IARespuesta normalizada
  ├─ 5. AIRequestLogRepository.insertar(log completo) ← SIEMPRE, incluso si falló
  └─ 6. retorna { contenido, tokens_entrada, tokens_salida }

IAController
  └─ 200 { respuesta: "...", tokens_entrada: N, tokens_salida: M }

PanelAsistente (Client Component)
  └─ muestra respuesta en panel separado del formulario
  └─ usuario lee y decide manualmente qué incorpora
```

**Si el proveedor no responde:**
```
IAOrchestrator
  └─ timeout o error de red
  └─ lanza ProveedorIANoDisponible

IAService
  └─ AIRequestLogRepository.insertar({ estado_llamada: 'timeout', error_mensaje: ... })
  └─ relanza ProveedorIANoDisponible

IAController → error.middleware
  └─ 503 { error: "IA_NO_DISPONIBLE", mensaje: "El asistente no está disponible." }

PanelAsistente
  └─ muestra aviso de indisponibilidad
  └─ el caso y sus herramientas siguen operando con normalidad
```

---

## Gestión de prompts

### Estructura base de todo prompt

El contexto del caso se divide en dos niveles:

**Contexto mínimo obligatorio** — presente en toda consulta sin excepción:
```
- Radicado: {radicado}
- Delito imputado: {delito_imputado}
- Etapa procesal: {etapa_procesal}
- Régimen procesal: {regimen_procesal}
```

**Contexto ampliado por herramienta** — campos adicionales incluidos
según la herramienta consultada:

| Herramienta | Contexto adicional incluido |
|---|---|
| Ficha básica | Próxima actuación, fecha, responsable |
| Matriz de hechos | Resumen de hechos registrados, estado de cada hecho |
| Matriz probatoria | Lista de pruebas con su evaluación de licitud y suficiencia |
| Matriz de riesgos | Riesgos registrados con probabilidad, impacto y estado de mitigación |
| Estrategia de defensa | Línea principal, líneas subsidiarias, posición frente a opciones |
| Explicación al cliente | Situación de libertad, opciones comunicadas, decisión del cliente |
| Checklist de calidad | Bloques incompletos, porcentaje de avance |
| Conclusión operativa | Síntesis de los cinco bloques diligenciados |

El contexto ampliado lo construye `IAService` a partir de los datos
del caso ya cargados. No se hace una segunda consulta al repositorio
solo para el contexto de IA.

```
[SISTEMA]
Eres un asistente jurídico especializado en defensa penal colombiana.
Tu función es apoyar el análisis del caso — no tomar decisiones.
No emitas conclusiones definitivas. Orienta, señala vacíos, sugiere perspectivas.

Contexto mínimo del caso:
- Radicado: {radicado}
- Delito imputado: {delito_imputado}
- Etapa procesal: {etapa_procesal}
- Régimen procesal: {regimen_procesal}

Contexto de la herramienta:
{contexto_ampliado_por_herramienta}

[USUARIO]
{plantilla_herramienta}

Consulta del responsable: {consulta_usuario}
```

### Principios de construcción de prompt

**PP-01** — El rol del asistente se establece siempre en la instrucción de sistema.
No en el mensaje de usuario. Esto garantiza que el proveedor trate la instrucción
como restricción de comportamiento, no como solicitud.

**PP-02** — El contexto del caso siempre precede a la consulta.
El asistente necesita el marco jurídico del caso para orientar correctamente.
Una consulta sin contexto produce respuestas genéricas no útiles.

**PP-03** — La plantilla por herramienta guía el foco del asistente.
Cada herramienta tiene una estructura de análisis distinta.
El prompt no es el mismo para la matriz probatoria que para la conclusión operativa.

**PP-04** — Las plantillas son versionadas y auditables.
Cualquier cambio en una plantilla debe registrarse con fecha y justificación.
El log de IA almacena el prompt completo — no la referencia a la plantilla —
para garantizar que el registro sea autosuficiente.

**PP-05** — La longitud de respuesta es acotada.
El límite de tokens de respuesta está configurado en el MVP (1000 tokens).
Respuestas extensas en un panel lateral son ilegibles y contraproducentes.

---

## Política de proveedores

### Modelo de selección de proveedor

El sistema soporta cuatro niveles conceptuales de selección de proveedor:

| Nivel | Descripción | Estado |
|---|---|---|
| Global del sistema | Un proveedor activo para toda la instalación | ✅ MVP |
| Por organización | Proveedor diferente por institución o consultorio | Fase posterior |
| Por usuario | Cada usuario elige su proveedor preferido | Fase posterior |
| Por tarea | Proveedor distinto según herramienta o tipo de consulta | Fase posterior |

**Alcance MVP**: el proveedor activo es global a la instalación.
Lo configura el administrador desde el panel de configuración del sistema.
La selección por usuario y por tarea queda reservada para fase posterior
y requerirá extender el modelo de datos y la lógica de `IAOrchestrator`.

### Política operativa del módulo

Los parámetros operativos aplican a todos los adaptadores de proveedor.
No son características exclusivas de Anthropic — son la política del módulo.
Cada adaptador los lee desde `ia.config` al inicializarse.

| Parámetro | Valor MVP | Configurable | Notas |
|---|---|---|---|
| Timeout por llamada | 30 segundos | Sí | Cubre latencia de red y generación |
| Reintentos ante fallo | 1 | Sí | Solo ante error de red o timeout; no ante error del proveedor |
| Max tokens de respuesta | 1000 | Sí | Respuestas acotadas para panel lateral |
| Backoff entre reintentos | 2 segundos | Sí | Fijo en MVP; exponencial en fase posterior |

---

### Proveedor por defecto — MVP

Anthropic con `claude-sonnet-4-20250514`. Razones:
- Rendimiento sólido en análisis jurídico estructurado.
- API estable con SDK oficial para Node.js / TypeScript.
- Compatible con el modelo de prompt por rol (sistema + usuario).

### Criterios para cambio de proveedor

El proveedor puede cambiarse desde configuración sin cambiar código.
Un cambio de proveedor requiere:
1. Implementar el nuevo adaptador con la interfaz `IAProviderAdapter`.
2. Validar que las plantillas de prompt existentes producen respuestas aceptables.
3. Actualizar `ia.config` con el nuevo proveedor y modelo.
4. Documentar el cambio en una ADR si es un cambio permanente.

### Proveedores contemplados a futuro

| Proveedor | Adaptador | Estado |
|---|---|---|
| Anthropic | `AnthropicAdapter` | ✅ MVP |
| OpenAI | `OpenAIAdapter` | Estructura reservada |
| Google Gemini | `GeminiAdapter` | Estructura reservada |
| Local (Ollama) | `OllamaAdapter` | Contingencia sin conexión |

---

## Minimización y sanitización del contexto enviado

El módulo de IA envía datos del expediente a proveedores externos.
Esta sección establece la política de qué se envía, qué se excluye
y cómo se gestiona la privacidad del contexto.

**MS-01 — Solo se envía el contexto necesario para la consulta.**
El contexto ampliado por herramienta (A5) define exactamente qué campos
se incluyen. Ningún campo adicional del expediente se envía por defecto.
El principio es minimización, no completitud.

**MS-02 — No se envían credenciales, tokens ni datos de sistema.**
El payload enviado al proveedor contiene exclusivamente contenido jurídico
del caso. Identificadores internos de usuario, tokens de sesión, claves
de configuración o datos de infraestructura no forman parte del prompt.

**MS-03 — Los datos de identidad del procesado se tratan con precaución.**
En el MVP, el nombre y documento del procesado pueden incluirse en el contexto
si son necesarios para la herramienta consultada. En fase posterior se evaluará
la conveniencia de anonimizar estos datos antes del envío, sustituyendo
nombre real por identificador neutral ("Procesado A").

**MS-04 — La política de anonimización es una decisión pendiente.**
La anonimización completa del contexto antes del envío al proveedor externo
es una mejora importante para confidencialidad jurídica. Su implementación
requiere una decisión formal documentada en una ADR antes de la fase de
producción con usuarios reales.

**MS-05 — El log almacena el prompt real, no la versión sanitizada.**
`ai_request_log.prompt_enviado` registra el prompt exacto enviado al proveedor,
incluyendo todos los datos de contexto. Este registro es de acceso restringido
(supervisor y administrador) y no se expone en la interfaz general del caso.

---

El `PanelAsistente` es un componente propio, separado del formulario de la herramienta.
Se renderiza como un panel lateral o desplegable dentro de la vista de cada herramienta.

### Reglas de diseño del panel

**RF-IA-01** — El panel siempre está identificado como asistente de IA.
El encabezado del panel incluye una etiqueta visible ("Asistente jurídico")
y una nota de alcance ("Las respuestas son orientativas").

**RF-IA-02** — La respuesta no puede transferirse automáticamente al formulario.
No existe botón de "insertar en el campo", "aplicar" ni mecanismo de autocompletado
alimentado por la IA. El usuario lee y decide manualmente. (PIA-02)

**RF-IA-03** — El estado de carga es explícito y no bloquea el formulario.
Mientras se espera la respuesta del proveedor, el formulario de la herramienta
permanece completamente operativo. La espera solo afecta al panel.

**RF-IA-04** — Los errores de IA se muestran en el panel, no como error global.
Un error `503` del módulo de IA se muestra como aviso dentro del panel.
No interrumpe la sesión, no redirige y no bloquea ninguna acción del caso.

**RF-IA-05** — El historial de consultas de la sesión es visible en el panel.
El usuario puede ver las consultas y respuestas anteriores de la sesión actual
dentro del panel. Este historial vive en el estado del componente (no en servidor)
y se pierde al cerrar sesión o al navegar fuera de la herramienta.

---

## Reglas de implementación transversales

**RI-IA-01** — Las credenciales del proveedor no están en el código fuente.
Las API keys viven en variables de entorno del servidor. El frontend
no tiene acceso a ninguna credencial de proveedor de IA. (RN-IA-03)

**RI-IA-02** — El log se escribe siempre, incluso si la llamada falla.
Si el registro del log falla, la operación de IA también falla y se retorna error.
No puede haber llamadas no registradas. (RN-IA-02, RN-AUD-02)

**RI-IA-03** — El prompt completo se almacena en el log, no solo la consulta del usuario.
El campo `prompt_enviado` en `ai_request_log` contiene el prompt completo
tal como fue enviado al proveedor, incluyendo instrucción de sistema, contexto
del caso y plantilla de herramienta. Esto garantiza la reproducibilidad
de cualquier consulta registrada.

**RI-IA-04** — El módulo no tiene estado entre consultas.
Cada llamada a `POST /api/v1/ai/query` es independiente.
El historial visible en el `PanelAsistente` vive en el cliente.
Si se necesita contexto de conversación multi-turno, el cliente
debe incluirlo en el campo `consulta` de la solicitud.

**RI-IA-05** — Los adaptadores de proveedor son intercambiables en tiempo de configuración.
El `IAOrchestrator` selecciona el adaptador en tiempo de ejecución según
la configuración activa. No hay `if (proveedor === 'anthropic')` en el código
de negocio ni en el orquestador salvo en el punto de selección del adaptador.

**RI-IA-06** — El nombre del modelo nunca aparece en el código fuente.
El modelo activo (ej. `claude-sonnet-4-20250514`) es un valor de configuración
en `ia.config`, no una constante en el código. Este principio tiene consecuencias
operativas directas: actualizar el modelo no requiere despliegue — solo un cambio
de configuración. El documento puede mencionar el modelo como referencia de MVP;
el código nunca debe hardcodearlo. Cualquier adaptador que use un modelo
fijo en el código es una violación de esta regla.

**RI-IA-07** — Las plantillas de prompt son versionadas.
Toda modificación a una plantilla registra la versión anterior.
El log de IA referencia el prompt completo usado — esto hace innecesario
mantener la versión de plantilla en el log, pero sí debe mantenerse
el historial de cambios de las plantillas para auditoría.
