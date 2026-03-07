# Contrato API

Documento de referencia de los endpoints del sistema LexPenal.
Define convenciones, recursos, parámetros, respuestas y códigos de error.

**Documentos relacionados**
- `docs/00_gobierno/adrs/ADR-003-maquina-de-estados-del-caso.md`
- `docs/01_producto/ESTADOS_DEL_CASO_v3.md`
- `docs/01_producto/MATRIZ_ROLES_PERMISOS.md`
- `docs/03_datos/REGLAS_NEGOCIO.md`
- `docs/06_backend/ARQUITECTURA_BACKEND.md`
- `docs/05_frontend/ARQUITECTURA_FRONTEND_v2.md`
- `docs/12_ia/ARQUITECTURA_MODULO_IA_v3.md`

| Campo | Valor |
|---|---|
| Última revisión | (completar) |
| Responsable | (completar) |

---

## Convenciones generales

- **Base path**: `/api/v1`
- **Formato**: JSON en todas las solicitudes y respuestas.
- **Fechas**: ISO 8601 (`2026-03-06T14:30:00Z`).
- **Identificadores**: UUID v4.
- **Nomenclatura de campos**: snake_case en todo el contrato.
- **Paginación**: parámetros `page` y `per_page` en endpoints de listado.

### Convención de nomenclatura de subrecursos

Los subrecursos de un caso siguen una convención según su naturaleza:

| Naturaleza | Convención | Ejemplos |
|---|---|---|
| Colección — el subrecurso contiene múltiples elementos | Plural | `/facts`, `/evidence`, `/risks` |
| Documento único — existe exactamente uno por caso | Singular o kebab-case descriptivo | `/basic-info`, `/strategy`, `/client-briefing`, `/checklist`, `/conclusion`, `/review` |

Esta convención aplica a todos los subrecursos de `/api/v1/cases/{id}/*`.
La distinción no es solo estética: los subrecursos de colección aceptan
listas en su payload; los de documento único aceptan un objeto.

### Autenticación de solicitudes

El sistema usa un esquema híbrido con dos mecanismos diferenciados:

| Contexto | Mecanismo | Uso |
|---|---|---|
| Next.js middleware y SSR | Cookie HttpOnly | Protección de rutas, validación inicial de sesión, rehidratación |
| Client Components → backend | `Authorization: Bearer <JWT_DE_EJEMPLO>` | Todas las llamadas operativas desde el cliente |

El backend valida el mecanismo correcto según la ruta.
Las rutas operativas (`/api/v1/*`) requieren Bearer token en el header.
La cookie HttpOnly es gestionada por el servidor — no es accesible ni
debe ser manipulada desde JavaScript cliente.

---

## Códigos de respuesta estándar

| Código | Significado general |
|--------|---------------------|
| `200`  | Operación exitosa. |
| `201`  | Recurso creado. |
| `204`  | Operación exitosa sin contenido de retorno. |
| `400`  | Solicitud malformada o con datos inválidos. |
| `401`  | No autenticado o token inválido. |
| `403`  | Autenticado pero sin permiso para esta acción. |
| `404`  | Recurso no encontrado. |
| `409`  | Conflicto de estado — la operación es inválida dado el estado actual del recurso. |
| `422`  | Reglas de negocio no cumplidas — datos válidos pero condiciones no satisfechas. |
| `500`  | Error interno del servidor. |
| `503`  | Servicio externo no disponible — usado exclusivamente para el módulo de IA. No afecta el flujo del caso. |

---

## Estructura estándar de error

```json
{
  "error": "CODIGO_ERROR",
  "mensaje": "Descripción legible del problema.",
  "motivos": [
    "Detalle específico 1.",
    "Detalle específico 2."
  ]
}
```

El campo `motivos` es opcional. Se incluye cuando hay más de un criterio
incumplido — en particular para errores `422` de reglas de guardia en
transiciones de estado.

---

## Recursos

---

### Autenticación

#### `POST /api/v1/auth/login`
Inicia sesión. Retorna el token de acceso en el body y establece la cookie
de sesión en la respuesta.

**Body**
```json
{
  "email": "usuario@dominio.com",
  "password": "..."
}
```

**Respuesta `200`**
```json
{
  "token_acceso": "<JWT_DE_EJEMPLO>",
  "usuario": {
    "id": "uuid",
    "nombre": "Nombre Apellido",
    "email": "usuario@dominio.com",
    "perfil": "estudiante"
  }
}
```

El servidor establece simultáneamente una cookie HttpOnly de sesión.
El cliente conserva `token_acceso` en memoria para las llamadas operativas.

**Respuestas**
- `200` — Login exitoso.
- `401` — Credenciales inválidas.
- `403` — Usuario desactivado.

---

#### `POST /api/v1/auth/logout`
Cierra sesión. Invalida el token de acceso y elimina la cookie de sesión.

**Respuestas**
- `204` — Sesión cerrada. Cookie eliminada.
- `401` — No autenticado.

---

#### `GET /api/v1/auth/session`
Rehidrata la sesión del cliente usando la cookie HttpOnly.
Usado por el frontend tras una recarga de página para recuperar el token
de acceso y el perfil del usuario sin pedir credenciales nuevamente.

**Autenticación**: cookie HttpOnly (no requiere Bearer).

**Respuesta `200`**
```json
{
  "token_acceso": "eyJ...",
  "usuario": {
    "id": "uuid",
    "nombre": "Nombre Apellido",
    "email": "usuario@dominio.com",
    "perfil": "supervisor"
  }
}
```

> El `token_acceso` retornado por este endpoint es para uso del cliente
> en memoria de sesión exclusivamente. No debe persistirse en `localStorage`,
> `sessionStorage` ni ningún almacenamiento accesible desde JavaScript.
> La cookie HttpOnly — que este endpoint usa para validar la sesión —
> no es ni debe ser leída desde el cliente para derivar el token.

**Respuestas**
- `200` — Sesión válida. Retorna token y perfil.
- `401` — Cookie ausente, expirada o inválida. El cliente redirige a login.

---

### Usuarios

#### `GET /api/v1/users`
Lista usuarios del sistema. Solo Administrador.

**Parámetros opcionales**
- `perfil` — filtra por perfil (`estudiante`, `supervisor`, `administrador`).
- `activo` — filtra por estado (`true`, `false`).
- `page`, `per_page` — paginación.

**Respuestas**
- `200` — Lista paginada de usuarios.
- `403` — Sin permiso.

---

#### `POST /api/v1/users`
Crea un usuario. Solo Administrador.

**Body**
```json
{
  "nombre": "Nombre Apellido",
  "email": "usuario@dominio.com",
  "perfil": "estudiante",
  "password": "..."
}
```

**Respuestas**
- `201` — Usuario creado.
- `400` — Datos inválidos.
- `409` — Email ya registrado.

---

#### `GET /api/v1/users/{id}`
Retorna un usuario por ID. Administrador puede ver cualquiera;
otros perfiles solo su propio registro.

**Respuestas**
- `200` — Usuario encontrado.
- `403` — Sin acceso.
- `404` — No encontrado.

---

#### `PUT /api/v1/users/{id}`
Actualiza datos de un usuario. Solo Administrador.

**Respuestas**
- `200` — Usuario actualizado.
- `403` — Sin permiso.
- `404` — No encontrado.

---

### Clientes

#### `GET /api/v1/clients`
Lista clientes (procesados). Estudiante ve solo los asociados a sus casos;
Supervisor y Administrador ven todos.

**Parámetros opcionales**
- `page`, `per_page` — paginación.

---

#### `POST /api/v1/clients`
Crea un cliente (procesado).

**Body**
```json
{
  "nombre": "Nombre Apellido",
  "tipo_documento": "CC",
  "documento": "1234567890",
  "contacto": "3001234567 / dirección u otro dato de contacto",
  "situacion_libertad": "libre",
  "lugar_detencion": null
}
```

`situacion_libertad`: `libre` | `detenido`. Si `detenido`, `lugar_detencion` es obligatorio.

**Respuestas**
- `201` — Cliente creado.
- `409` — Ya existe un cliente con ese tipo y número de documento.

---

#### `GET /api/v1/clients/{id}`
Retorna un cliente por ID.

---

#### `PUT /api/v1/clients/{id}`
Actualiza datos del cliente.

---

### Casos

#### `GET /api/v1/cases`
Lista casos. Estudiante ve solo sus propios casos; Supervisor y Administrador
ven todos.

**Parámetros opcionales**
- `estado` — filtra por estado del caso.
- `responsable_id` — filtra por usuario responsable.
- `page`, `per_page` — paginación.

**Respuesta `200`**
```json
{
  "data": [
    {
      "id": "uuid",
      "radicado": "11001600002820260001",
      "cliente": { "id": "uuid", "nombre": "Nombre Apellido" },
      "responsable": { "id": "uuid", "nombre": "Nombre Apellido" },
      "estado_actual": "en_analisis",
      "delito_imputado": "Hurto calificado",
      "regimen_procesal": "ordinario",
      "creado_en": "2026-03-06T14:30:00Z",
      "actualizado_en": "2026-03-06T15:00:00Z"
    }
  ],
  "total": 42,
  "page": 1,
  "per_page": 20
}
```

---

#### `POST /api/v1/cases`
Crea un caso nuevo en estado `borrador`.
El backend genera automáticamente los registros asociados vacíos:
checklist, herramientas, conclusión operativa.

**Body**
```json
{
  "cliente_id": "uuid",
  "responsable_id": "uuid",
  "radicado": "11001600002820260001"
}
```

**Respuestas**
- `201` — Caso creado con sus registros asociados.
- `400` — Datos inválidos.
- `403` — Sin permiso.
- `409` — El radicado ya está registrado en el sistema.

---

#### `GET /api/v1/cases/{id}`
Retorna el caso completo con metadatos del estado actual.
Los datos de las herramientas se cargan por sus endpoints propios.

**Respuesta `200`**
```json
{
  "id": "uuid",
  "radicado": "11001600002820260001",
  "cliente": { "id": "uuid", "nombre": "Nombre Apellido" },
  "responsable": { "id": "uuid", "nombre": "Nombre Apellido" },
  "estado_actual": "en_analisis",
  "delito_imputado": "Hurto calificado",
  "etapa_procesal": "Acusación presentada",
  "regimen_procesal": "ordinario",
  "creado_en": "2026-03-06T14:30:00Z",
  "actualizado_en": "2026-03-06T15:00:00Z"
}
```

**Respuestas**
- `200` — Caso encontrado.
- `403` — Sin acceso a este caso.
- `404` — Caso no encontrado.

---

#### `PUT /api/v1/cases/{id}`
Actualiza datos generales del caso (radicado, delito imputado, etapa procesal,
régimen, responsable).

Solo disponible en estados `borrador`, `en_analisis` y `devuelto`.
En cualquier otro estado retorna `409`.

**Respuestas**
- `200` — Caso actualizado.
- `403` — Sin permiso.
- `409` — El estado actual no permite edición general del caso.

---

### Transición de estado del caso

#### `POST /api/v1/cases/{id}/transition`
Solicita una transición de estado del caso.
El backend evalúa: perfil del usuario, validez de la transición y reglas
de guardia. Registra el evento de auditoría en todos los casos, incluyendo
rechazos.

**Body**
```json
{
  "estado_destino": "pendiente_revision"
}
```

**Respuestas**

| Código | Significado |
|--------|-------------|
| `200`  | Transición aplicada. Retorna el caso con su nuevo `estado_actual`. |
| `403`  | El perfil del usuario no tiene permiso para esta transición. |
| `404`  | El caso no existe o no es accesible por el usuario en sesión. |
| `409`  | El estado actual del caso es incompatible con el estado destino solicitado. |
| `422`  | Las reglas de guardia no se cumplen. Retorna detalle de motivos. |

**Idempotencia**: si el caso ya está en el estado destino solicitado, el backend
retorna `200` sin crear un evento de auditoría duplicado.

**Ejemplo de error `422`**
```json
{
  "error": "TRANSITION_REJECTED",
  "mensaje": "Las reglas de guardia no se cumplen para esta transición.",
  "motivos": [
    "El checklist tiene bloques críticos incompletos.",
    "La matriz de hechos no tiene ningún hecho registrado."
  ]
}
```

**Ejemplo de error `409`**
```json
{
  "error": "INVALID_TRANSITION",
  "mensaje": "La transición solicitada no es válida desde el estado actual.",
  "motivos": [
    "El caso está en estado 'cerrado'. No admite transiciones."
  ]
}
```

---

### Herramientas operativas del caso

Las ocho herramientas del caso (U008) siguen un patrón uniforme:

**Comportamiento por estado del caso**

| Operación | `borrador` | `en_analisis` | `pendiente_revision` | `devuelto` | `aprobado_supervisor` / `listo_para_cliente` / `cerrado` |
|---|---|---|---|---|---|
| `GET` (lectura) | ✅ | ✅ | ✅ | ✅ | ✅ |
| `PUT` (escritura) | ✅ | ✅ | ❌ `409` | ✅ | ❌ `409` |

La lectura siempre está disponible en cualquier estado para cualquier perfil
con acceso al caso. La escritura solo es posible en `borrador`, `en_analisis`
y `devuelto`. En `pendiente_revision`, las herramientas son de solo lectura
para **todos** los perfiles incluyendo supervisor — el supervisor diligencia
exclusivamente el bloque de revisión (`/review`), no las herramientas del análisis.

---

#### Ficha básica

```
GET  /api/v1/cases/{id}/basic-info
PUT  /api/v1/cases/{id}/basic-info
```

Campos principales: `etapa_procesal`, `regimen_procesal`, `proxima_actuacion`,
`fecha_proxima_actuacion`, `responsable_proxima_actuacion`.

---

#### Matriz de hechos

```
GET  /api/v1/cases/{id}/facts
PUT  /api/v1/cases/{id}/facts
```

Gestiona la lista de hechos del caso. El `PUT` reemplaza el conjunto completo
de hechos. Cada hecho incluye: `descripcion`, `estado_hecho`, `fuente`,
`incidencia_juridica`.

`estado_hecho`: `acreditado` | `referido` | `discutido`.
`incidencia_juridica`: `tipicidad` | `antijuridicidad` | `culpabilidad` | `procedimiento` | `null`.

> **Advertencia operativa**: `PUT` reemplaza el conjunto completo del recurso.
> El cliente debe enviar el estado completo actual — incluyendo los elementos
> que no cambian. Omitir un elemento implica eliminarlo.

---

#### Matriz probatoria

```
GET  /api/v1/cases/{id}/evidence
PUT  /api/v1/cases/{id}/evidence
```

Gestiona la lista de elementos probatorios. Cada elemento incluye:
`descripcion`, `tipo_prueba`, `hecho_id`, `hecho_descripcion_libre`,
`licitud`, `legalidad`, `suficiencia`, `credibilidad`, `posicion_defensiva`.

> **Advertencia operativa**: `PUT` reemplaza el conjunto completo del recurso.
> El cliente debe enviar el estado completo actual. Omitir un elemento implica eliminarlo.

---

#### Matriz de riesgos

```
GET  /api/v1/cases/{id}/risks
PUT  /api/v1/cases/{id}/risks
```

Gestiona la lista de riesgos. Cada riesgo incluye: `descripcion`,
`probabilidad`, `impacto`, `prioridad`, `estrategia_mitigacion`,
`estado_mitigacion`, `plazo_accion`, `responsable_id`.

> **Advertencia operativa**: `PUT` reemplaza el conjunto completo del recurso.
> El cliente debe enviar el estado completo actual. Omitir un elemento implica eliminarlo.

---

#### Estrategia de defensa

```
GET  /api/v1/cases/{id}/strategy
PUT  /api/v1/cases/{id}/strategy
```

Campos principales: `linea_principal`, `fundamento_juridico`, `fundamento_probatorio`,
`linea_subsidiaria`, `posicion_allanamiento`, `posicion_preacuerdo`, `posicion_juicio`.

---

#### Explicación al cliente

```
GET  /api/v1/cases/{id}/client-briefing
PUT  /api/v1/cases/{id}/client-briefing
```

Campos principales: `delito_explicado`, `riesgos_informados`, `panorama_probatorio`,
`beneficios_informados`, `opciones_explicadas`, `recomendacion`, `decision_cliente`,
`fecha_explicacion`.

`situacion_libertad` del procesado pertenece al recurso `clients`, no a esta herramienta.

---

#### Checklist de calidad

```
GET  /api/v1/cases/{id}/checklist
PUT  /api/v1/cases/{id}/checklist
```

El `GET` retorna todos los bloques con sus ítems y estado de marcado.
El `PUT` actualiza el estado (`marcado: true/false`) de uno o varios ítems.
El campo `completado` del bloque es calculado — no se puede escribir directamente.

> **Nota sobre estructura de contenidos**: la estructura exacta de bloques,
> criterios e ítems del checklist se define en la documentación funcional
> vigente alineada con la Unidad 8 del Manual de Defensa Penal Colombiana.
> El ejemplo a continuación muestra únicamente la forma del recurso y
> no congela el detalle final de contenidos, que será revisado cuando
> se cierre la estructura definitiva del checklist.

**Respuesta `GET` `200`**
```json
{
  "bloques": [
    {
      "id": "uuid",
      "codigo_bloque": "B01",
      "nombre_bloque": "[Nombre del bloque según U008]",
      "critico": true,
      "completado": false,
      "items": [
        {
          "id": "uuid",
          "codigo_item": "B01_01",
          "descripcion": "[Criterio de calidad según U008]",
          "marcado": false,
          "marcado_en": null,
          "marcado_por": null
        }
      ]
    }
  ],
  "progreso_porcentaje": 42
}
```

---

#### Conclusión operativa

```
GET  /api/v1/cases/{id}/conclusion
PUT  /api/v1/cases/{id}/conclusion
```

La conclusión tiene estructura por bloques alineada con el modelo de datos.
El `PUT` acepta un objeto con todos los campos opcionales — solo se
actualizan los que se envíen.

**Bloque 1 — Síntesis jurídica**: `hechos_sintesis`, `cargo_imputado`,
`evaluacion_dogmatica`, `fisuras_fortalezas`.

**Bloque 2 — Panorama procesal**: `fortalezas_acusacion`, `debilidades_acusacion`,
`prueba_defensa`, `etapa_texto`, `oportunidades`.

**Bloque 3 — Dosimetría y beneficios**: `rangos_pena`, `beneficios`,
`restricciones_subrogados`, `riesgos_prioritarios`.

**Bloque 4 — Opciones**: `opcion_a`, `consecuencias_a`, `opcion_b`,
`consecuencias_b`, `opcion_c`, `consecuencias_c`.

**Bloque 5 — Recomendación**: `recomendacion`, `fundamento_recomendacion`,
`condicion_vigencia`.

Campo adicional: `observaciones`.

`recomendacion` no puede ser nulo ni vacío para la transición
`aprobado_supervisor → listo_para_cliente`.

---

#### Línea de tiempo

```
GET  /api/v1/cases/{id}/timeline
POST /api/v1/cases/{id}/timeline
```

Gestiona los eventos cronológicos del caso. El `GET` retorna todos los
eventos ordenados por `fecha_evento` y `orden`. El `POST` añade un evento.

Cada evento incluye: `fecha_evento`, `descripcion`, `orden`.

> **Advertencia operativa**: solo editable en estados activos del caso.
> De solo lectura en `pendiente_revision` y posteriores.

---

#### Actuaciones procesales

```
GET    /api/v1/cases/{id}/proceedings
POST   /api/v1/cases/{id}/proceedings
PUT    /api/v1/cases/{id}/proceedings/{proc_id}
DELETE /api/v1/cases/{id}/proceedings/{proc_id}
```

Gestiona las actuaciones procesales del caso. Vinculadas a la estrategia
y usadas en los informes `cronologico` y `agenda_vencimientos`.

Cada actuación incluye: `descripcion`, `fecha`, `responsable_id`,
`responsable_externo`, `completada`.

Al menos uno de `responsable_id` o `responsable_externo` debe estar
diligenciado cuando la actuación tiene responsable asignado.

---

### Revisión del supervisor

#### `GET /api/v1/cases/{id}/review`
Retorna el historial completo de revisiones del caso, ordenado por versión.
La revisión vigente tiene `vigente: true`.

**Acceso**: Solo Supervisor y Administrador.

**Respuesta `200`**
```json
{
  "data": [
    {
      "id": "uuid",
      "caso_id": "uuid",
      "supervisor_id": "uuid",
      "version_revision": 2,
      "vigente": true,
      "resultado": "devuelto",
      "observaciones": "La matriz probatoria requiere análisis de licitud.",
      "fecha_revision": "2026-03-06T16:00:00Z"
    },
    {
      "id": "uuid",
      "caso_id": "uuid",
      "supervisor_id": "uuid",
      "version_revision": 1,
      "vigente": false,
      "resultado": "devuelto",
      "observaciones": "Primera revisión.",
      "fecha_revision": "2026-03-04T10:00:00Z"
    }
  ]
}
```

---

#### `GET /api/v1/cases/{id}/review/feedback`
Retorna la vista filtrada de la revisión vigente, diseñada para consumo
del responsable del caso. Incluye lo que el responsable necesita para corregir;
omite metadatos internos de revisión y el historial de versiones.

**Acceso**: Estudiante responsable del caso, Supervisor y Administrador.

**Respuesta `200`**
```json
{
  "resultado": "devuelto",
  "observaciones": "La matriz probatoria requiere análisis de licitud en tres elementos.",
  "fecha_revision": "2026-03-06T16:00:00Z",
  "estado_caso": "devuelto"
}
```

**Respuestas**
- `200` — Vista de retroalimentación disponible.
- `403` — Sin acceso al caso.
- `404` — El caso no tiene revisiones registradas.

---

#### `POST /api/v1/cases/{id}/review`
Registra una nueva revisión del caso. Cada llamada crea una nueva versión
de la revisión — no sobrescribe la anterior. La nueva revisión queda como
`vigente: true`; las anteriores pasan a `vigente: false`.

**Solo disponible cuando el caso está en `pendiente_revision`.**
**Solo Supervisor y Administrador.**

**Body**
```json
{
  "resultado": "devuelto",
  "observaciones": "La matriz probatoria requiere análisis de licitud en tres elementos."
}
```

El campo `observaciones` es **obligatorio** tanto para `aprobado` como para
`devuelto`. Una revisión sin observaciones escritas es rechazada con `422`.

**Respuestas**
- `201` — Revisión registrada. Retorna la nueva versión vigente.
- `400` — Datos malformados.
- `403` — El perfil del usuario no tiene permiso para diligenciar revisiones.
- `409` — El caso no está en estado `pendiente_revision`.
- `422` — Observaciones ausentes o valor de `resultado` inválido.

**Nota**: el cambio de estado del caso como consecuencia de la revisión
se ejecuta mediante `POST /api/v1/cases/{id}/transition`, no automáticamente
desde este endpoint.

---

### Informes

#### `GET /api/v1/cases/{id}/reports`
Lista los informes generados para el caso, ordenados por fecha de generación.

**Respuesta `200`**
```json
{
  "data": [
    {
      "id": "uuid",
      "tipo": "conclusion_operativa",
      "formato": "pdf",
      "url_descarga": "https://...",
      "generado_en": "2026-03-06T14:30:00Z",
      "generado_por": { "id": "uuid", "nombre": "Nombre Apellido" }
    }
  ]
}
```

---

#### `POST /api/v1/cases/{id}/reports`
Solicita la generación de un informe del caso.

**Body**
```json
{
  "tipo": "conclusion_operativa",
  "formato": "pdf"
}
```

**Tipos disponibles**

| Tipo | Descripción |
|---|---|
| `resumen_ejecutivo` | Síntesis general del caso |
| `conclusion_operativa` | Conclusión operativa completa |
| `control_calidad` | Estado del checklist por bloques |
| `riesgos` | Matriz de riesgos con estado de mitigación |
| `cronologico` | Línea de tiempo del caso |
| `revision_supervisor` | Historial de revisiones |
| `agenda_vencimientos` | Próximas actuaciones y plazos |

**Formatos disponibles**: `pdf`, `docx`

**Respuestas**
- `201` — Informe generado. Retorna URL de descarga y metadatos.
- `403` — Sin permiso.
- `409` — El estado del caso no permite generar este informe.
- `422` — Datos insuficientes para generar el informe solicitado.

**Idempotencia**: si existe un informe del mismo tipo y formato generado
dentro de una ventana de tiempo configurable (por defecto 5 minutos),
el backend retorna el informe existente con `200` en lugar de generar uno nuevo.
Esto protege contra doble generación por reintento de timeout o doble clic.

---

### Módulo de IA

#### `POST /api/v1/ai/query`
Envía una consulta al módulo de IA sobre una herramienta del caso.
Toda llamada queda registrada en el log de auditoría, incluyendo las fallidas.
La indisponibilidad del módulo de IA no afecta ningún flujo del caso.

**Body**
```json
{
  "caso_id": "uuid",
  "herramienta": "matriz_probatoria",
  "consulta": "¿Qué elementos probatorios presentan mayor riesgo de exclusión?"
}
```

**Valores válidos de `herramienta`**: `basic-info`, `facts`, `evidence`,
`risks`, `strategy`, `client-briefing`, `checklist`, `conclusion`.

**Respuesta `200`**
```json
{
  "respuesta": "Texto de respuesta del asistente jurídico...",
  "tokens_entrada": 312,
  "tokens_salida": 487,
  "modelo_usado": "claude-sonnet-4-20250514"
}
```

**Respuestas**
- `200` — Respuesta del asistente. Ver body arriba.
- `400` — Campos ausentes o `herramienta` inválida.
- `403` — Sin acceso al caso.
- `404` — Caso no encontrado.
- `503` — Proveedor de IA no disponible. El caso y sus herramientas siguen operando.

**Ejemplo de error `503`**
```json
{
  "error": "IA_NO_DISPONIBLE",
  "mensaje": "El asistente no está disponible en este momento. El análisis del caso no se ve afectado.",
  "motivos": []
}
```

---

### Auditoría

#### `GET /api/v1/cases/{id}/audit`
Lista los eventos de auditoría del caso. Solo Supervisor y Administrador.

**Parámetros opcionales**
- `tipo` — filtra por tipo de evento: `transicion_estado`, `ia_query`, `revision_supervisor`, `informe_generado`.
- `page`, `per_page` — paginación.

**Respuesta `200`**
```json
{
  "data": [
    {
      "id": "uuid",
      "caso_id": "uuid",
      "tipo": "transicion_estado",
      "usuario_id": "uuid",
      "fecha_evento": "2026-03-06T14:30:00Z",
      "detalle": {
        "estado_origen": "en_analisis",
        "estado_destino": "pendiente_revision",
        "resultado": "exitoso",
        "motivo_rechazo": null
      }
    },
    {
      "id": "uuid",
      "caso_id": "uuid",
      "tipo": "ia_query",
      "usuario_id": "uuid",
      "fecha_evento": "2026-03-06T13:45:00Z",
      "detalle": {
        "herramienta": "facts",
        "proveedor": "anthropic",
        "estado_llamada": "exitosa",
        "tokens_entrada": 312,
        "tokens_salida": 487
      }
    }
  ],
  "total": 18,
  "page": 1,
  "per_page": 20
}
```

**Nota**: el log de IA filtrado por `tipo=ia_query` no expone el contenido
del prompt ni la respuesta completa — solo metadatos de la llamada.
El contenido completo es de acceso restringido a nivel de base de datos.
