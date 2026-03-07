# Contrato API

Documento de referencia de los endpoints del sistema LexPenal.
Define convenciones, recursos, parámetros, respuestas y códigos de error.

**ADR de referencia para transiciones**: `docs/00_gobierno/adrs/ADR-003-maquina-de-estados-del-caso.md`

| Campo | Valor |
|---|---|
| Última revisión | (completar) |
| Responsable | (completar) |

---

## Convenciones generales

- Base path: `/api/v1`
- Formato: JSON en todas las solicitudes y respuestas.
- Autenticación: token en header `Authorization: Bearer {token}`.
- Fechas: ISO 8601 (`2026-03-06T14:30:00Z`).
- Identificadores: UUID v4.
- Nomenclatura de campos: snake_case en todo el contrato.
- Paginación: parámetros `page` y `per_page` en endpoints de listado.

---

## Códigos de respuesta estándar

| Código | Significado general |
|--------|---------------------|
| `200`  | Operación exitosa. |
| `201`  | Recurso creado. |
| `204`  | Operación exitosa sin contenido de retorno. |
| `400`  | Solicitud malformada o con datos inválidos. |
| `401`  | No autenticado. |
| `403`  | Autenticado pero sin permiso para esta acción. |
| `404`  | Recurso no encontrado. |
| `409`  | Conflicto de estado — la operación es inválida dado el estado actual del recurso. |
| `422`  | Entidad no procesable — datos válidos pero reglas de negocio no cumplidas. |
| `500`  | Error interno del servidor. |

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

El campo `motivos` es opcional. Se incluye cuando hay más de un criterio incumplido,
en particular para errores `422` de reglas de guardia en transiciones de estado.

---

## Recursos

### Autenticación

#### `POST /api/v1/auth/login`
Inicia sesión y retorna token de acceso.

**Body**
```json
{
  "email": "usuario@dominio.com",
  "password": "..."
}
```

**Respuestas**
- `200` — Token de acceso y datos básicos del usuario.
- `401` — Credenciales inválidas.

---

#### `POST /api/v1/auth/logout`
Cierra sesión e invalida el token.

**Respuestas**
- `204` — Sesión cerrada.
- `401` — No autenticado.

---

### Usuarios

#### `GET /api/v1/users`
Lista usuarios del sistema. Solo Administrador.

#### `POST /api/v1/users`
Crea un usuario. Solo Administrador.

#### `GET /api/v1/users/{id}`
Retorna un usuario por ID.

#### `PUT /api/v1/users/{id}`
Actualiza datos de un usuario. Solo Administrador.

---

### Clientes

#### `GET /api/v1/clients`
Lista clientes. Estudiante ve solo los suyos; Supervisor y Admin ven todos.

#### `POST /api/v1/clients`
Crea un cliente (procesado).

#### `GET /api/v1/clients/{id}`
Retorna un cliente por ID.

#### `PUT /api/v1/clients/{id}`
Actualiza datos del cliente.

---

### Casos

#### `GET /api/v1/cases`
Lista casos. Estudiante ve solo los propios; Supervisor y Admin ven todos.

**Parámetros opcionales**
- `estado` — filtra por estado del caso.
- `responsable_id` — filtra por usuario responsable.
- `page`, `per_page` — paginación.

**Respuesta `200`**
```json
{
  "data": [ { ...caso } ],
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
  "responsable_id": "uuid"
}
```

**Respuestas**
- `201` — Caso creado.
- `403` — Sin permiso.

---

#### `GET /api/v1/cases/{id}`
Retorna el caso completo con todas sus herramientas.

**Respuestas**
- `200` — Caso completo.
- `403` — Sin acceso a este caso.
- `404` — Caso no encontrado.

---

#### `PUT /api/v1/cases/{id}`
Actualiza datos generales del caso. Solo disponible en estados `borrador`, `en_analisis` y `devuelto`.

**Respuestas**
- `200` — Caso actualizado.
- `409` — El estado actual no permite edición.

---

### Transición de estado del caso

#### `POST /api/v1/cases/{id}/transition`
Solicita una transición de estado del caso.
El backend evalúa perfil, reglas de guardia y registra el evento de auditoría.

**Body**
```json
{
  "estado_destino": "pendiente_revision"
}
```

**Respuestas**

| Código | Significado |
|--------|-------------|
| `200`  | Transición aplicada. Retorna el caso con su nuevo estado. |
| `403`  | El perfil del usuario no tiene permiso para esta transición. |
| `404`  | El caso no existe o no es accesible por el usuario en sesión. |
| `409`  | El estado actual del caso es incompatible con el estado destino solicitado. |
| `422`  | Las reglas de guardia no se cumplen. Se retorna detalle de los motivos. |

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

Todos los endpoints de herramientas siguen el mismo patrón.
Solo operan sobre casos en estado `en_analisis` o `devuelto`; en cualquier otro estado retornan `409`.

#### `GET /api/v1/cases/{id}/facts`
#### `PUT /api/v1/cases/{id}/facts`

#### `GET /api/v1/cases/{id}/evidence`
#### `PUT /api/v1/cases/{id}/evidence`

#### `GET /api/v1/cases/{id}/risks`
#### `PUT /api/v1/cases/{id}/risks`

#### `GET /api/v1/cases/{id}/strategy`
#### `PUT /api/v1/cases/{id}/strategy`

#### `GET /api/v1/cases/{id}/client-briefing`
#### `PUT /api/v1/cases/{id}/client-briefing`

#### `GET /api/v1/cases/{id}/checklist`
#### `PUT /api/v1/cases/{id}/checklist`

#### `GET /api/v1/cases/{id}/conclusion`
#### `PUT /api/v1/cases/{id}/conclusion`

---

### Revisión del supervisor

#### `GET /api/v1/cases/{id}/review`
Retorna el bloque de revisión del supervisor.

#### `PUT /api/v1/cases/{id}/review`
Diligencia o actualiza el bloque de revisión. Solo Supervisor y Administrador.
Solo disponible cuando el caso está en `pendiente_revision`.

---

### Informes

#### `GET /api/v1/cases/{id}/reports`
Lista los informes generados para el caso.

#### `POST /api/v1/cases/{id}/reports`
Genera un informe del caso.

**Body**
```json
{
  "tipo": "conclusion_operativa",
  "formato": "pdf"
}
```

**Tipos disponibles**
- `resumen_ejecutivo`
- `conclusion_operativa`
- `control_calidad`
- `riesgos`
- `cronologico`
- `revision_supervisor`
- `agenda_vencimientos`

**Formatos disponibles**
- `pdf`
- `docx`

**Respuestas**
- `201` — Informe generado. Incluye URL de descarga.
- `409` — El estado del caso no permite generar este informe.
- `422` — Datos insuficientes para generar el informe solicitado.

---

### Módulo de IA

#### `POST /api/v1/ai/query`
Envía una consulta al módulo de IA sobre una herramienta del caso.
Toda llamada queda registrada en el log de auditoría.

**Body**
```json
{
  "caso_id": "uuid",
  "herramienta": "matriz_probatoria",
  "consulta": "Texto de la consulta o instrucción adicional."
}
```

**Respuestas**
- `200` — Respuesta del asistente.
- `403` — Sin permiso.
- `503` — Proveedor de IA no disponible.

---

### Auditoría

#### `GET /api/v1/cases/{id}/audit`
Lista los eventos de auditoría del caso. Solo Supervisor y Administrador.

**Respuesta `200`**
```json
{
  "data": [
    {
      "caso_id": "uuid",
      "estado_origen": "en_analisis",
      "estado_destino": "pendiente_revision",
      "usuario_id": "uuid",
      "fecha_evento": "2026-03-06T14:30:00Z",
      "resultado": "aprobado",
      "motivo_rechazo": null
    }
  ]
}
```
