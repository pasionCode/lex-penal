# NOTA DE CIERRE SPRINT 02 — 2026-03-24

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E3 — Construcción del MVP
- Sprint: Sprint 2 — Gestión básica de casos
- Fecha de cierre: 2026-03-24
- Estado: CERRADO

## 2. Objetivo del sprint
Implementar y validar el flujo base de gestión de casos del MVP, incluyendo:
- creación de caso;
- listado de casos;
- consulta de detalle;
- transición de estado;
- actualización de metadata editable;

todo ello con control de acceso por rol, aislamiento por propietario y validaciones de negocio mínimas.

## 3. Historias incluidas
- US-06 Crear caso
- US-07 Listar mis casos
- US-08 Consultar detalle de caso
- US-09 Transicionar estado
- US-10 Actualizar caso editable

## 4. Resultado general
Sprint 2 cerrado funcionalmente.

Se implementaron y validaron los endpoints del módulo `cases` comprometidos para este sprint, con evidencia de funcionamiento real sobre entorno local, autenticación activa y base de datos operativa.

## 5. Validaciones funcionales superadas

### US-06 — Crear caso
- creación exitosa de caso;
- asociación automática al usuario autenticado;
- rechazo de intento de forzar `responsable_id` desde payload;
- rechazo de radicado duplicado con `409 Conflict`.

Resultado:
- APROBADA.

### US-07 — Listar mis casos
- administrador visualiza universo completo de casos;
- estudiante visualiza únicamente sus casos;
- no se evidencian fugas de información en listado general.

Resultado:
- APROBADA.

### US-08 — Consultar detalle de caso
- acceso correcto al caso propio;
- bloqueo de acceso a caso ajeno con `403 Forbidden`;
- manejo correcto de inexistencia con `404 Not Found`.

Resultado:
- APROBADA.

### US-09 — Transicionar estado
- transición válida `borrador -> en_analisis`;
- rechazo de transición inválida `en_analisis -> cerrado` con `409 Conflict`;
- bloqueo de transición por usuario sin permiso con `403 Forbidden`;
- trazabilidad completa del cambio de estado:
  - `estado_actual`
  - `estado_anterior`
  - `fecha_cambio_estado`
  - `usuario_cambio_estado`

Resultado:
- APROBADA.

### US-10 — Actualizar caso editable
- rechazo de edición en estado no editable (`borrador`) con `409 Conflict`;
- bloqueo de edición de caso ajeno con `403 Forbidden`;
- manejo correcto de caso inexistente con `404 Not Found`;
- actualización exitosa en ruta feliz sobre caso en estado `en_analisis`;
- persistencia comprobada de:
  - `despacho`
  - `proxima_actuacion`
  - `observaciones`
  - `fecha_proxima_actuacion`
  - `actualizado_en`

Resultado:
- APROBADA.

## 6. Reglas verificadas
- aislamiento por propietario (owner-based access);
- visibilidad diferenciada por rol;
- unicidad de radicado;
- rechazo de propiedades no permitidas en DTOs;
- protección contra asignación arbitraria de responsable;
- control de editabilidad por estado;
- control de transiciones válidas por máquina de estados;
- trazabilidad de cambios de estado;
- respuestas consistentes con códigos `403`, `404` y `409`.

## 7. Deuda técnica detectada
### 7.1 Codificación de caracteres
Se detectaron síntomas de codificación UTF-8 en algunos textos de respuesta y/o valores persistidos, por ejemplo:
- `ya estÃ¡ registrado en el sistema`
- `Investigaciï¿½n`

Clasificación:
- deuda técnica no bloqueante para cierre funcional del Sprint 2.

Acción sugerida:
- revisar normalización UTF-8 en semillas, archivos fuente, conexión con base de datos, serialización HTTP y terminal.

## 8. Decisión de cierre
Con base en la evidencia funcional obtenida, se declara:

**SPRINT 02 CERRADO**

Queda autorizada la apertura del Sprint 3, correspondiente a:
- hechos;
- pruebas;
- vínculos entre prueba y hecho.
