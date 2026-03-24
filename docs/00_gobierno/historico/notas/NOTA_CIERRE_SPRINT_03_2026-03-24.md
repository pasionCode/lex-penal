# NOTA DE CIERRE SPRINT 03 — 2026-03-24

## 1. Identificación

- Proyecto: LEX_PENAL
- Fase: E3 — Construcción del MVP
- Sprint: Sprint 3 — Hechos y pruebas
- Fecha de cierre: 2026-03-24
- Estado: CERRADO

## 2. Objetivo del sprint

Implementar y validar el flujo de gestión de hechos y pruebas del caso, incluyendo:
- CRUD individual de hechos;
- CRUD individual de pruebas;
- vínculo explícito prueba-hecho;
- control de acceso por ownership;
- validación de integridad cruzada (mismo caso).

## 3. Historias incluidas en el sprint

- US-11 Registrar hecho
- US-12 Consultar hechos del caso
- US-13 Editar hecho
- US-14 Registrar prueba vinculada a caso
- US-15 Vincular prueba a hecho
- US-16 Consultar pruebas del caso
- US-17 Editar prueba

## 4. Resultado general

Sprint 3 cerrado funcionalmente.

Se implementaron y validaron los endpoints de los módulos `facts` y `evidence` con evidencia de funcionamiento real sobre entorno local, autenticación activa y base de datos operativa.

## 5. Decisión de diseño adoptada

Se adoptó **CRUD individual** en lugar del modelo de reemplazo masivo (`PUT` que reemplaza conjunto completo).

Motivos:
- coherencia con backlog y modelo Prisma;
- menor riesgo de pérdida accidental de datos;
- mejor trazabilidad de operaciones;
- mayor simplicidad de validación y pruebas.

El contrato API v4 fue actualizado para reflejar esta decisión.

## 6. Validaciones funcionales superadas

### US-11 — Registrar hecho

Validaciones superadas:
- creación exitosa de hecho;
- orden asignado automáticamente por backend;
- segundo hecho recibe orden incremental;
- campos opcionales (`fuente`, `incidencia_juridica`) funcionan correctamente.

Resultado: APROBADA.

### US-12 — Consultar hechos del caso

Validaciones superadas:
- listado retorna hechos ordenados por `orden`;
- detalle individual funciona correctamente;
- no se filtran hechos de casos ajenos al listar.

Resultado: APROBADA.

### US-13 — Editar hecho

Validaciones superadas:
- actualización de campos editables;
- `actualizado_por` se asigna correctamente;
- campos no enviados permanecen sin cambio.

Resultado: APROBADA.

### US-14 — Registrar prueba vinculada a caso

Validaciones superadas:
- creación exitosa de prueba;
- campos de evaluación probatoria (`licitud`, `legalidad`, `suficiencia`, `credibilidad`) obligatorios;
- `hecho_id` opcional en creación;
- validación de `hecho_id` pertenece al mismo caso si se envía.

Resultado: APROBADA.

### US-15 — Vincular prueba a hecho

Validaciones superadas:
- endpoint `PATCH /evidence/:id/link` vincula correctamente;
- endpoint `PATCH /evidence/:id/unlink` limpia `hecho_id`;
- rechazo de vínculo cruzado entre casos con `409 Conflict`;
- vínculo persiste correctamente en base de datos.

Resultado: APROBADA.

### US-16 — Consultar pruebas del caso

Validaciones superadas:
- listado retorna pruebas del caso;
- detalle individual funciona correctamente;
- no se filtran pruebas de casos ajenos.

Resultado: APROBADA.

### US-17 — Editar prueba

Validaciones superadas:
- actualización de campos editables;
- `hecho_id` no editable via PUT (se gestiona via link/unlink);
- `actualizado_por` se asigna correctamente.

Resultado: APROBADA.

## 7. Reglas de negocio y seguridad verificadas

- aislamiento por propietario (estudiante solo accede a sus casos);
- admin/supervisor acceden a todos los casos;
- unicidad de orden por caso (asignado por backend);
- una prueba pertenece a un solo caso;
- una prueba puede vincularse a un solo hecho del mismo caso;
- rechazo de vínculo cruzado entre casos distintos;
- respuestas consistentes con códigos `403`, `404` y `409`.

## 8. Evidencia funcional observada

Durante el cierre del sprint se verificó en entorno local que:
- el administrador puede crear, listar, editar hechos;
- el orden se asigna automáticamente (1, 2, 3...);
- el administrador puede crear, listar, editar pruebas;
- el vínculo prueba-hecho funciona via `/link` y `/unlink`;
- el estudiante recibe `403` al intentar acceder a caso ajeno;
- el intento de vincular hecho de otro caso responde con `409`;
- recursos inexistentes responden con `404`.

## 9. Deuda técnica detectada

### 9.1 Mensaje de error en `/link`

El endpoint `/link` responde con el mismo mensaje tanto para hecho inexistente como para hecho de otro caso:
- `"El hecho no pertenece al mismo caso"`

Clasificación: deuda técnica menor, no bloqueante.

Acción sugerida: distinguir entre `404` (hecho no existe) y `409` (hecho existe pero pertenece a otro caso).

### 9.2 Deuda arrastrada de Sprint 2

- DT-001: unificar `message` vs `mensaje` en filtro global
- DT-002: codificación UTF-8 en terminal

## 10. Endpoints implementados

### Facts
| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/cases/:id/facts` | Crear hecho |
| GET | `/cases/:id/facts` | Listar hechos |
| GET | `/cases/:id/facts/:factId` | Detalle |
| PUT | `/cases/:id/facts/:factId` | Editar |

### Evidence
| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/cases/:id/evidence` | Crear prueba |
| GET | `/cases/:id/evidence` | Listar pruebas |
| GET | `/cases/:id/evidence/:evidenceId` | Detalle |
| PUT | `/cases/:id/evidence/:evidenceId` | Editar |
| PATCH | `/cases/:id/evidence/:evidenceId/link` | Vincular a hecho |
| PATCH | `/cases/:id/evidence/:evidenceId/unlink` | Desvincular |

## 11. Estado del módulo al cierre

Los módulos `facts` y `evidence` quedan habilitados para continuar con la siguiente etapa del MVP sobre una base funcional en:
- creación individual;
- consulta (listado y detalle);
- edición controlada;
- vinculación prueba-hecho;
- control de acceso y trazabilidad.

## 12. Decisión de cierre

Con base en la evidencia funcional obtenida, se declara:

**SPRINT 03 CERRADO**

Queda autorizada la apertura del Sprint 4.

## 13. Pendiente inmediato recomendado

- registrar apertura formal de Sprint 4;
- definir alcance del siguiente sprint (risks, strategy, timeline, etc.);
- corregir deuda técnica menor en backlog técnico sin bloquear avance funcional.
