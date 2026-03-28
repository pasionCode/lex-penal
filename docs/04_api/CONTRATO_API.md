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
| Última revisión | 2026-03-27 (Sprint 22) |
| Responsable | Pablo Jaramillo |

---

## Convenciones generales

- **Base path**: `/api/v1` definido exclusivamente por prefijo global en `src/main.ts`.
- **Regla de controllers**: los decorators `@Controller(...)` deben declarar rutas relativas al recurso. Queda prohibido repetir `api/v1` dentro del controller.
- **Formato**: JSON en todas las solicitudes y respuestas.
- **Fechas**: ISO 8601 (`2026-03-06T14:30:00Z`).
- **Identificadores**: UUID v4.
- **Nomenclatura de campos**: snake_case en todo el contrato.
- **Paginación**: parámetros `page` y `per_page` en endpoints de listado.

> Nota de consistencia: la convención de versionado y prefijo de rutas se rige por ADR-009.

### Convención de nomenclatura de subrecursos

Los subrecursos de un caso siguen una convención según su naturaleza:

| Naturaleza | Convención | Ejemplos |
|---|---|---|
| Colección — representa múltiples elementos | Plural | `/facts`, `/evidence`, `/risks`, `/subjects` |
| Documento único — representa exactamente un documento por caso | Singular o kebab-case descriptivo | `/basic-info`, `/strategy`, `/client-briefing`, `/checklist`, `/conclusion`, `/review` |

Esta convención aplica a todos los subrecursos de `/api/v1/cases/{caseId}/*`.
Los subrecursos de colección exponen operaciones sobre una colección de elementos
(listar, crear, obtener por ID). Los subrecursos de documento único exponen
operaciones sobre un recurso singular (obtener, actualizar).

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

### 1. Autenticación

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
  "access_token": "<JWT_DE_EJEMPLO>",
  "user": {
    "id": "uuid",
    "nombre": "Nombre Apellido",
    "email": "usuario@dominio.com",
    "perfil": "estudiante"
  }
}
```

El servidor establece simultáneamente una cookie HttpOnly de sesión.
El cliente conserva `access_token` en memoria para las llamadas operativas.

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

---

### 2. Usuarios

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
Retorna un usuario por ID. Solo Administrador.

Para consultar datos propios, usar `GET /api/v1/users/me`.

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

### 3. Clientes

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

### 4. Casos

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
      "regimen_procesal": "Ley 906",
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

**Body**

```json
{
  "cliente_id": "uuid",
  "radicado": "11001600002820260001",
  "delito_imputado": "Hurto calificado",
  "regimen_procesal": "Ley 906",
  "etapa_procesal": "Investigación"
}
```

| Campo | Obligatorio | Nota |
|-------|-------------|------|
| `cliente_id` | ✅ | UUID del cliente/procesado |
| `radicado` | ✅ | Identificador único del proceso |
| `delito_imputado` | ✅ | Tipo penal imputado |
| `regimen_procesal` | ✅ | Ley 600 / Ley 906 |
| `etapa_procesal` | ✅ | Fase procesal actual |
| `despacho` | ❌ | Opcional |
| `fecha_apertura` | ❌ | Opcional (ISO date) |

**Respuestas**

- `201` — Caso creado.
- `400` — Datos inválidos o campos obligatorios faltantes.
- `403` — Sin permiso para crear casos.
- `409` — El radicado ya está registrado en el sistema.

---

#### `GET /api/v1/cases/{caseId}`
Retorna el caso completo con metadatos del estado actual.

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
  "regimen_procesal": "Ley 906",
  "creado_en": "2026-03-06T14:30:00Z",
  "actualizado_en": "2026-03-06T15:00:00Z"
}
```

**Respuestas**
- `200` — Caso encontrado.
- `403` — Sin acceso a este caso.
- `404` — Caso no encontrado.

---

#### `PUT /api/v1/cases/{caseId}`

Actualiza metadata editable del caso.

**Campos modificables:**

| Campo | Nota |
|-------|------|
| `despacho` | Juzgado o despacho asignado |
| `etapa_procesal` | Fase procesal actual |
| `regimen_procesal` | Ley 600 / Ley 906 |
| `proxima_actuacion` | Descripción de próxima diligencia |
| `fecha_proxima_actuacion` | Fecha ISO |
| `responsable_proxima_actuacion` | Texto libre |
| `observaciones` | Notas generales |
| `agravantes` | Circunstancias agravantes |

Solo disponible en estados `en_analisis` y `devuelto`.

**Respuestas**

- `200` — Caso actualizado.
- `403` — Sin permiso o no es propietario del caso.
- `404` — Caso no encontrado.
- `409` — El estado actual no permite edición.

---

### 4.1 Transición de estado del caso

#### `POST /api/v1/cases/{caseId}/transition`
Solicita una transición de estado del caso.

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

---

### 5. Herramientas operativas del caso

Las herramientas del caso siguen un patrón uniforme:

**Comportamiento por estado del caso**

| Operación | `borrador` | `en_analisis` | `pendiente_revision` | `devuelto` | `aprobado_supervisor` / `listo_para_cliente` / `cerrado` |
|---|---|---|---|---|---|
| `GET` (lectura) | ✅ | ✅ | ✅ | ✅ | ✅ |
| `PUT` (escritura) | ❌ `409` | ✅ | ❌ `409` | ✅ | ❌ `409` |

---

#### 5.1 Ficha básica

```
GET  /api/v1/cases/{caseId}/basic-info
PUT  /api/v1/cases/{caseId}/basic-info
```

---

#### 5.2 Hechos del caso
```
POST   /api/v1/cases/{caseId}/facts
GET    /api/v1/cases/{caseId}/facts
GET    /api/v1/cases/{caseId}/facts/{factId}
PUT    /api/v1/cases/{caseId}/facts/{factId}
```

---

#### 5.3 Pruebas del caso
```
POST   /api/v1/cases/{caseId}/evidence
GET    /api/v1/cases/{caseId}/evidence
GET    /api/v1/cases/{caseId}/evidence/{evidenceId}
PUT    /api/v1/cases/{caseId}/evidence/{evidenceId}
```

---

#### 5.4 Riesgos del caso
```
POST   /api/v1/cases/{caseId}/risks
GET    /api/v1/cases/{caseId}/risks
GET    /api/v1/cases/{caseId}/risks/{riskId}
PUT    /api/v1/cases/{caseId}/risks/{riskId}
```

Coleccion editable sin DELETE expuesto.

**Enums validos:**

| Campo | Valores |
|-------|---------|
| `probabilidad` | `alta`, `media`, `baja` |
| `impacto` | `alto`, `medio`, `bajo` |
| `prioridad` | `critica`, `alta`, `media`, `baja` |
| `estado_mitigacion` | `pendiente`, `en_curso`, `mitigado`, `aceptado` |

**Regla de negocio:** Si `prioridad = critica`, el campo `estrategia_mitigacion` es obligatorio.

**Respuestas:**

| Codigo | Descripcion |
|--------|-------------|
| `200` | Lista o detalle de riesgos, o riesgo actualizado |
| `201` | Riesgo creado |
| `400` | Payload invalido o prioridad critica sin estrategia |
| `401` | No autenticado |
| `403` | Estudiante sin acceso al caso |
| `404` | Caso o riesgo no encontrado |
---

#### 5.5 Estrategia de defensa

```
GET  /api/v1/cases/{caseId}/strategy
PUT  /api/v1/cases/{caseId}/strategy
```

Recurso **singleton**: existe exactamente una instancia de estrategia por cada caso.

**Comportamiento especial:**
- Si `GET /strategy` se invoca y no existe, el sistema la crea automáticamente (lazy initialization).
- `PUT /strategy` actualiza la estrategia existente o la crea si no existe (upsert funcional).
- Siempre retorna `200`, nunca `201`.

**Campos:**

| Campo | Tipo | MaxLength | Descripción |
|-------|------|-----------|-------------|
| `linea_principal` | string | 2000 | Línea defensiva principal |
| `fundamento_juridico` | string | 3000 | Fundamento jurídico de la defensa |
| `fundamento_probatorio` | string | 3000 | Fundamento probatorio |
| `linea_subsidiaria` | string | 2000 | Línea defensiva subsidiaria |
| `posicion_allanamiento` | string | 1000 | Posición frente a allanamiento |
| `posicion_preacuerdo` | string | 1000 | Posición frente a preacuerdo |
| `posicion_juicio` | string | 1000 | Posición frente a juicio |

Todos los campos son opcionales en `PUT`.

**Dependencia funcional:** El campo `linea_principal` es obligatorio para la transición `en_analisis -> pendiente_revision`. Esta validación se ejecuta en el servicio de transiciones, no en este endpoint.

**Respuestas:**

| Código | Descripción |
|--------|-------------|
| `200` | Estrategia obtenida, auto-creada o actualizada correctamente |
| `400` | Payload inválido o incumplimiento de validaciones del DTO en `PUT` |
| `401` | No autenticado |
| `403` | Estudiante sin acceso al caso |
| `404` | Caso no encontrado |

---

#### 5.6 Explicación al cliente
```
GET  /api/v1/cases/{caseId}/client-briefing
PUT  /api/v1/cases/{caseId}/client-briefing
```

Recurso **singleton**: existe exactamente una explicación al cliente por caso.

**Comportamiento especial:**
- Si `GET /client-briefing` se invoca y no existe aún una explicación para el caso, el sistema la crea automáticamente y retorna el recurso resultante.
- `PUT /client-briefing` actualiza la explicación existente del caso.

**Respuestas:**

| Código | Descripción |
|--------|-------------|
| `200` | Explicación obtenida, auto-creada o actualizada |
| `400` | Payload inválido en `PUT` |
| `401` | No autenticado |
| `403` | Estudiante sin acceso al caso |
| `404` | Caso no encontrado |
```

---

#### 5.7 Checklist de calidad
```
GET  /api/v1/cases/{caseId}/checklist
PUT  /api/v1/cases/{caseId}/checklist
```

Recurso **jerarquico**: estructura fija de bloques con items.

**Bootstrap:** El checklist se crea automaticamente al activar el caso (transicion `borrador -> en_analisis`). No se auto-crea en `GET`.

**Estructura de respuesta:**
```json
{
  "bloques": [
    {
      "id": "uuid",
      "codigo_bloque": "B01",
      "nombre_bloque": "Verificacion de hechos",
      "critico": true,
      "completado": false,
      "items": [
        {
          "id": "uuid",
          "codigo_item": "B01_01",
          "descripcion": "Hechos contrastados con denuncia",
          "marcado": false
        }
      ]
    }
  ]
}
```

**Formato PUT:**
```json
{
  "items": [
    { "id": "uuid-item", "marcado": true },
    { "id": "uuid-item", "marcado": false }
  ]
}
```

**Recalculo automatico:** Al actualizar items, `bloque.completado` se recalcula como `true` solo si todos sus items estan marcados.

**Respuestas:**

| Codigo | Descripcion |
|--------|-------------|
| `200` | Checklist obtenido o actualizado |
| `400` | Item inexistente en payload |
| `401` | No autenticado |
| `403` | Estudiante sin acceso al caso o item de otro caso |
| `404` | Caso no encontrado |
---

#### 5.8 Conclusión operativa
```
GET  /api/v1/cases/{caseId}/conclusion
PUT  /api/v1/cases/{caseId}/conclusion
```

Recurso **singleton**: existe exactamente una conclusión operativa por caso.

**Comportamiento especial:**
- Si `GET /conclusion` se invoca y no existe aún una conclusión para el caso, el sistema la crea automáticamente y retorna el recurso resultante.
- `PUT /conclusion` actualiza la conclusión existente del caso.

**Respuestas:**

| Código | Descripción |
|--------|-------------|
| `200` | Conclusión obtenida, auto-creada o actualizada |
| `400` | Payload inválido en `PUT` |
| `401` | No autenticado |
| `403` | Estudiante sin acceso al caso |
| `404` | Caso no encontrado |
---

#### 5.9 Línea de tiempo

```
GET  /api/v1/cases/{caseId}/timeline
POST /api/v1/cases/{caseId}/timeline
```

---

#### 5.10 Actuaciones procesales

```
GET    /api/v1/cases/{caseId}/proceedings
POST   /api/v1/cases/{caseId}/proceedings
GET    /api/v1/cases/{caseId}/proceedings/{proceedingId}
```

Entidad con **política append-only**. No se permite edición ni eliminación.

**Respuestas:**

| Código | Descripción |
|--------|-------------|
| `200` | Lista o detalle de actuaciones |
| `201` | Actuación creada |
| `400` | Payload inválido |
| `404` | Caso o actuación no encontrada |

> **Nota de implementación (Sprint 13):** Se retiró la exposición de `PUT` y `DELETE`
> para alinear el recurso con la política append-only.

---

#### 5.11 Documentos del caso
```
GET    /api/v1/cases/{caseId}/documents
POST   /api/v1/cases/{caseId}/documents
GET    /api/v1/cases/{caseId}/documents/{documentId}
PUT    /api/v1/cases/{caseId}/documents/{documentId}
```

Entidad con **política híbrida**: solo el campo `descripcion` es editable. No se permite eliminación.

---

### 6. Sujetos procesales

Entidad con **política append-only**. No se permite edición ni eliminación.

#### 6.1 Listar sujetos de un caso
```
GET /api/v1/cases/{caseId}/subjects
Authorization: Bearer {token}
```

**Parámetros de query:**

| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `page` | number | 1 | Página actual (1-indexed) |
| `per_page` | number | 20 | Elementos por página (1-100) |
| `tipo` | enum | — | Filtra por tipo de sujeto procesal |
| `nombre` | string | — | Filtra por coincidencia parcial case-insensitive en `nombre` |
| `identificacion` | string | — | Filtra por coincidencia exacta en `identificacion` |
| `tipo_identificacion` | enum | — | Filtra por coincidencia exacta en `tipo_identificacion` |

**Valores válidos de `tipo`:** `victima`, `imputado`, `testigo`, `apoderado`, `otro`

**Valores válidos de `tipo_identificacion`:** `CC`, `TI`, `CE`, `PAS`, `NIT`, `otro`

#### Reglas de comportamiento
- Los filtros se aplican antes de la paginación.
- `tipo`, `nombre`, `identificacion` y `tipo_identificacion` pueden combinarse entre sí.
- `nombre` aplica búsqueda parcial case-insensitive.
- `identificacion` aplica comparación exacta.
- `tipo_identificacion` aplica comparación exacta.
- Si no hay coincidencias, la respuesta es `200 OK` con `data: []` y `total: 0`.
- Si `tipo` es inválido, la respuesta es `400 Bad Request`.
- Si `nombre` es vacío o contiene solo espacios, la respuesta es `400 Bad Request`.
- Si `identificacion` es vacía o contiene solo espacios, la respuesta es `400 Bad Request`.
- Si `tipo_identificacion` es inválido, la respuesta es `400 Bad Request`.
- Si `tipo_identificacion` es vacío, la respuesta es `400 Bad Request`.

**Respuesta exitosa:** `200 OK`
```json
{
  "data": [
    {
      "id": "uuid",
      "caso_id": "uuid",
      "tipo": "victima | imputado | testigo | apoderado | otro",
      "nombre": "string",
      "identificacion": "string | null",
      "tipo_identificacion": "CC | TI | CE | PAS | NIT | otro | null",
      "contacto": "string | null",
      "direccion": "string | null",
      "notas": "string | null",
      "creado_en": "datetime",
      "actualizado_en": "datetime",
      "creado_por": "uuid",
      "actualizado_por": "uuid | null"
    }
  ],
  "total": 45,
  "page": 1,
  "per_page": 20
}
```

**Comportamiento de página fuera de rango:** Si `page` excede el total de páginas disponibles, la respuesta es `200 OK` con `data: []`. Los campos `total`, `page` y `per_page` se mantienen informativos.

**Errores:**
- `400` — Parámetros de paginación o filtro inválidos
- `404` — Caso no encontrado

> **Consolidación contractual (Sprint 21):** Se integra en bloque único la semántica de filtros `tipo`, `nombre`, `identificacion` y `tipo_identificacion` para `GET /subjects`.


#### 6.2 Crear sujeto

```
POST /api/v1/cases/{caseId}/subjects
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**

```json
{
  "tipo": "victima | imputado | testigo | apoderado | otro",
  "nombre": "string (requerido, max 120)",
  "identificacion": "string (opcional, max 40)",
  "tipo_identificacion": "CC | TI | CE | PAS | NIT | otro (opcional)",
  "contacto": "string (opcional, max 120)",
  "direccion": "string (opcional, max 255)",
  "notas": "string (opcional)"
}
```

**Campos del sujeto:**

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| `tipo` | enum | Sí | `victima` \| `imputado` \| `testigo` \| `apoderado` \| `otro` |
| `nombre` | string | Sí | Nombre completo (max 120 caracteres) |
| `identificacion` | string | No | Número de documento (max 40 caracteres) |
| `tipo_identificacion` | enum | No | `CC` \| `TI` \| `CE` \| `PAS` \| `NIT` \| `otro` |
| `contacto` | string | No | Teléfono, email u otro (max 120 caracteres) |
| `direccion` | string | No | Dirección física (max 255 caracteres) |
| `notas` | string | No | Observaciones adicionales |

**Respuesta exitosa:** `201 Created`

**Errores:**
- `400` — Validación fallida
- `404` — Caso no encontrado

---

#### 6.3 Obtener sujeto por ID

```
GET /api/v1/cases/{caseId}/subjects/{subjectId}
Authorization: Bearer {token}
```

**Respuesta exitosa:** `200 OK`

**Errores:**
- `404` — Caso no encontrado
- `404` — Sujeto no encontrado

---

> **Nota de implementación (Sprint 15):** Subrecurso `subjects` implementado con
> política append-only (GET lista, POST, GET detalle). PUT y DELETE no expuestos.

---

### 7. Revision del supervisor

#### `GET /api/v1/cases/{caseId}/review`
Retorna el historial completo de revisiones del caso.

**Acceso:** Solo Supervisor y Administrador.

#### `GET /api/v1/cases/{caseId}/review/feedback`
Retorna la vista filtrada de la revision vigente para el responsable del caso.
Retorna `null` si no existe revision vigente.

**Acceso:** Estudiante responsable del caso, Supervisor y Administrador.

#### `POST /api/v1/cases/{caseId}/review`
Registra una nueva revision del caso.

**Restricciones:**
- Solo Supervisor y Administrador
- Solo cuando el caso esta en estado `pendiente_revision`

**Comportamiento:**
- Incrementa `version_revision`
- Marca la nueva revision como `vigente: true`
- Marca revisiones anteriores como `vigente: false`

**Campos requeridos:**

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| `resultado` | enum | `aprobado` o `devuelto` |
| `observaciones` | string | Observaciones del supervisor (max 3000) |
| `fecha_revision` | datetime | Opcional, default: ahora |

**Respuestas (todos los endpoints):**

| Codigo | Descripcion |
|--------|-------------|
| `200` | Historial, feedback o revision obtenida |
| `201` | Revision creada |
| `401` | No autenticado |
| `403` | Estudiante sin acceso o perfil insuficiente |
| `404` | Caso no encontrado |
| `409` | Caso no esta en estado `pendiente_revision` |
---

### 8. Informes

#### `GET /api/v1/cases/{caseId}/reports`
Lista los informes generados para el caso.

#### `POST /api/v1/cases/{caseId}/reports`
Solicita la generación de un informe del caso.

**Tipos disponibles:** `resumen_ejecutivo`, `conclusion_operativa`, `control_calidad`,
`riesgos`, `cronologico`, `revision_supervisor`, `agenda_vencimientos`

**Formatos disponibles:** `pdf`, `docx`

**Idempotencia:** Si existe un informe del mismo tipo y formato generado en los últimos 5 minutos, se retorna ese informe en lugar de crear uno nuevo.

#### `GET /api/v1/cases/{caseId}/reports/{reportId}`
Retorna el detalle de un informe específico.

**Respuestas (todos los endpoints):**

| Código | Descripción |
|--------|-------------|
| `200` | Lista o detalle de informes |
| `201` | Informe generado |
| `400` | Payload inválido (tipo o formato no válido) |
| `401` | No autenticado |
| `403` | Estudiante sin acceso al caso |
| `404` | Caso o informe no encontrado |

---

### 9. Módulo de IA

#### `POST /api/v1/ai/query`
Envía una consulta al módulo de IA sobre una herramienta del caso.

**Valores válidos de `herramienta`**: `basic_info`, `facts`, `evidence`,
`risks`, `strategy`, `client_briefing`, `checklist`, `conclusion`.

**Respuestas**
- `200` — Respuesta del asistente.
- `400` — Campos ausentes o `herramienta` inválida.
- `403` — Sin acceso al caso.
- `404` — Caso no encontrado.
- `503` — Proveedor de IA no disponible.

---

### 10. Auditoría

#### `GET /api/v1/cases/{caseId}/audit`
Lista los eventos de auditoría del caso. Solo Supervisor y Administrador.

**Parámetros opcionales**
- `tipo` — filtra por tipo de evento.
- `page`, `per_page` — paginación.

---

## Historial de cambios

| Sprint | Fecha | Cambios |
|--------|-------|---------|
| 21 | 2026-03-27 | Consolidación contractual de `GET /subjects`: integración canónica de filtros `tipo`, `nombre`, `identificacion` y `tipo_identificacion`. |
| 22 | 2026-03-27 | Consolidación contractual de `POST /subjects` y `GET /subjects/{subjectId}`. Validación real de create, detail, 404 por caso inexistente, 404 por sujeto inexistente y protección contra fuga entre casos. |
| 16 | 2026-03-27 | Paginación en `GET /subjects` — breaking change: array → objeto paginado. Comportamiento de página fuera de rango documentado. Unificación de placeholders `{caseId}`. Corrección de convención de subrecursos. |
| 15 | 2026-03-27 | Agregado subrecurso `subjects` (sección 6) con política append-only |
| 14 | 2026-03-27 | Hardening de validaciones en `proceedings` |
| 13 | 2026-03-26 | Política append-only para `proceedings`, removidos PUT/DELETE |
| 12 | 2026-03-26 | Hardening de validaciones en `documents` |
| 17 | 2026-03-27 | Filtro por `tipo` en `GET /subjects`. Parámetro opcional con validación enum. |

---

*Documento actualizado: 2026-03-27 (Sprint 22)*

