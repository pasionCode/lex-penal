# Arquitectura de backend

Documento de referencia de la arquitectura interna del backend de LexPenal.
Define capas, responsabilidades, servicios, patrones y reglas de implementación.

**Documentos relacionados**
- `docs/00_gobierno/adrs/ADR-001-despliegue-inicial-vm.md`
- `docs/00_gobierno/adrs/ADR-002-postgresql-como-base-relacional.md`
- `docs/00_gobierno/adrs/ADR-003-maquina-de-estados-del-caso.md`
- `docs/00_gobierno/adrs/ADR-004-modulo-ia-desacoplado.md`
- `docs/03_datos/MODELO_DATOS.md`
- `docs/03_datos/REGLAS_NEGOCIO.md`
- `docs/04_api/CONTRATO_API.md`

| Campo | Valor |
|---|---|
| Última revisión | (completar) |
| Responsable | (completar) |

---

## Stack tecnológico

| Componente | Decisión |
|---|---|
| Lenguaje | TypeScript |
| Framework | NestJS |
| ORM / acceso a datos | TypeORM o Prisma — (completar antes de iniciar desarrollo) |
| Motor de migraciones | El del ORM elegido (TypeORM migrations o Prisma Migrate) |
| Base de datos | PostgreSQL (ADR-002) |
| Autenticación | JWT con estrategia Bearer. Módulo `@nestjs/jwt` + Passport. |

**Decisión pendiente — refresh token.**
La estrategia JWT Bearer es suficiente para el MVP.
Al entrar a implementación será necesario decidir entre:
- JWT de larga duración (simple, adecuado para sesiones cortas de consultorio);
- access token corto + refresh token (más seguro, mayor complejidad).
Documentar en `ADR-007-estrategia-autenticacion.md` antes de implementar el módulo de auth.
| Gestor de paquetes | npm |
| Entorno de ejecución | Node.js LTS |

**Decisión de ORM pendiente — alta prioridad.**
La elección entre TypeORM y Prisma tiene implicaciones directas en la estructura
de repositorios, el modelo de entidades, las migraciones y el tipado de consultas.
Esta decisión no puede postergarse: debe tomarse y documentarse en
`ADR-006-orm-acceso-a-datos.md` antes de escribir la primera línea de código
de la capa de infraestructura. Es el bloqueador técnico número uno del proyecto.

---

## Alcance de este documento

Este documento cubre la arquitectura de backend a nivel estratégico:
capas, responsabilidades, servicios nombrados, patrones transversales y reglas de implementación.

El detalle de operaciones de cada servicio, los patrones transaccionales específicos
y la política completa de errores se desarrollarán en documentos separados cuando el proyecto lo requiera:
- `SERVICIOS_BACKEND.md` — diseño detallado de cada servicio.
- `PATRONES_TRANSACCIONALES.md` — transacciones, rollback y casos borde.
- `POLITICA_DE_ERRORES.md` — catálogo completo de excepciones y su manejo.

---

## Principios de diseño

**P-01 — El backend es el único árbitro de la lógica de negocio.**
Ninguna regla de negocio reside en el frontend. El frontend es una capa
de presentación que consume la API. Las validaciones del frontend son
orientativas; las del backend son definitivas.

**P-02 — Las capas tienen responsabilidades únicas y no se solapan.**
Cada capa cumple un rol específico. Una capa no debe asumir
responsabilidades de otra. Las violaciones de este principio son
deuda técnica desde el primer día.

**P-03 — Todo flujo crítico pasa por un servicio nombrado.**
Las operaciones de negocio no viven en controladores ni en repositorios.
Viven en servicios con nombre descriptivo. Esto hace el código auditable,
testeable y transferible.

**P-04 — La trazabilidad no es opcional.**
Toda acción crítica genera un registro en `eventos_auditoria`.
Toda llamada de IA genera un registro en `ai_request_log`.
Esta lógica no puede omitirse por optimización ni por simplificación.

**P-05 — El backend no confía en el frontend.**
El token de sesión se valida en cada solicitud. El perfil del usuario
se lee de la base de datos en cada operación crítica. El frontend
no puede elevar sus propios permisos.

---

## Capas de la aplicación

```
┌─────────────────────────────────────────────┐
│             Capa de presentación            │  ← Controladores HTTP
│         (Controllers / Handlers)            │     Validación de entrada
│                                             │     Serialización de respuesta
├─────────────────────────────────────────────┤
│             Capa de aplicación              │  ← Servicios de negocio
│              (Services / Use Cases)         │     Orquestación de flujos
│                                             │     Reglas de guardia
├─────────────────────────────────────────────┤
│             Capa de dominio                 │  ← Entidades del dominio
│              (Domain / Entities)            │     Enums y value objects
│                                             │     Lógica de dominio pura
├─────────────────────────────────────────────┤
│           Capa de infraestructura           │  ← Repositorios (BD)
│            (Infrastructure)                │     Proveedores de IA
│                                             │     Motor de informes
│                                             │     Almacenamiento de archivos
└─────────────────────────────────────────────┘
```

### Reglas entre capas

- Los controladores solo llaman a servicios. Nunca acceden directamente a repositorios.
- Los servicios pueden llamar a repositorios y a otros servicios del mismo nivel.
- Los repositorios solo acceden a la base de datos. No contienen lógica de negocio.
- Las entidades de dominio no dependen de ninguna capa de infraestructura.

---

## Fronteras de integración

El backend se integra con los siguientes sistemas externos. Cada frontera tiene un adaptador
en la capa de infraestructura que aísla el núcleo del sistema del proveedor concreto.

| Sistema externo | Tipo de integración | Adaptador / módulo |
|---|---|---|
| Frontend web | HTTP/REST — consume la API | `api/controllers/` |
| PostgreSQL | Conexión directa via ORM | `infrastructure/repositories/` |
| Almacenamiento documental | Sistema de archivos local o S3-compatible | `infrastructure/storage/file-storage.adapter` |
| Proveedor de IA | HTTP hacia API externa (Anthropic, OpenAI, etc.) | `infrastructure/ia/ia-provider.adapter` |
| Motor de informes | Librería interna de generación PDF/DOCX | `infrastructure/reports/report-engine` |
| Autenticación | JWT firmado internamente — sin proveedor externo en MVP | `api/middleware/auth.middleware` |

**Principio de frontera**: el backend no depende de implementaciones concretas de sistemas externos.
Depende de interfaces. Cambiar de proveedor de almacenamiento o de IA no debe requerir
modificar servicios de negocio.

---

Cada servicio tiene responsabilidad única y nombre descriptivo.
Los servicios son la unidad de prueba principal del backend.

### `AuthService`
**Responsabilidad**: autenticación y gestión de sesión.

Operaciones:
- `login(email, password)` — valida credenciales, genera token, registra evento.
- `logout(token)` — invalida token, registra evento.
- `validateToken(token)` — retorna el usuario autenticado o lanza excepción.

Reglas:
- Un usuario con `activo = false` no puede hacer login. (RN-USR-06)
- Las contraseñas se comparan siempre contra `password_hash`. (RN-DAT-04)

---

### `UsuarioService`
**Responsabilidad**: gestión de usuarios del sistema.

Operaciones:
- `crear(datos, solicitante)` — crea usuario. Solo administrador.
- `actualizar(id, datos, solicitante)` — actualiza datos. Solo administrador.
- `cambiarPerfil(id, perfil, solicitante)` — solo administrador. (RN-USR-03)
- `desactivar(id, solicitante)` — desactiva usuario. Solo administrador. (RN-USR-06)

---

### `ClienteService`
**Responsabilidad**: gestión de procesados.

Operaciones:
- `crear(datos, solicitante)` — crea cliente. Verifica unicidad documental. (RN-UNI-02)
- `actualizar(id, datos, solicitante)` — actualiza datos del procesado.
- `buscar(filtros, solicitante)` — retorna clientes accesibles al solicitante.

Reglas:
- Si `situacion_libertad = detenido`, `lugar_detencion` es obligatorio.

---

### `CasoService`
**Responsabilidad**: creación, consulta y actualización general del caso.

Operaciones:
- `crear(datos, solicitante)` — crea caso en `borrador`. Verifica unicidad de radicado. (RN-UNI-03)
  Dispara `CasoInicializacionService` para crear registros relacionados. (RN-CAS-07)
- `obtener(id, solicitante)` — retorna el caso si el solicitante tiene acceso. (RN-USR-02)
- `listar(filtros, solicitante)` — aplica filtro por `responsable_id` para estudiantes.
- `actualizar(id, datos, solicitante)` — actualiza campos generales. Verifica estado activo.

Reglas:
- Un caso en `cerrado` rechaza toda escritura con `409`. (RN-CAS-04)
- Un estudiante solo accede a sus propios casos. (RN-USR-02)

---

### `CasoInicializacionService`
**Responsabilidad**: generar todos los registros relacionados al crear un caso.

Operaciones:
- `inicializar(caso_id)` — crea en una transacción:
  - registros de `checklist_bloques` e `checklist_items` según plantilla U008.
  - registro vacío de `estrategia`.
  - registro vacío de `explicacion_cliente`.
  - registro vacío de `conclusion_operativa`.

Reglas:
- Toda la inicialización ocurre en una transacción atómica. Si falla algún paso, se revierte todo.
- Este servicio no debe llamarse fuera de `CasoService.crear()`.

---

### `CasoEstadoService`
**Responsabilidad**: única autoridad para cambiar el estado del caso.
Este es el servicio más crítico del backend.

Operaciones:
- `transicionar(caso_id, estado_destino, solicitante)`:
  1. Carga el caso y verifica que existe.
  2. Verifica que el perfil del solicitante tiene permiso para esta transición.
  3. Verifica que la transición es válida desde el estado actual.
  4. Evalúa todas las reglas de guardia de la transición.
  5. Si todo es válido: actualiza `estado_actual`, `estado_anterior`,
     `fecha_cambio_estado`, `usuario_cambio_estado`.
  6. Registra el evento en `eventos_auditoria` con resultado `exitoso`.
  7. Retorna el caso actualizado.
  - Si falla en cualquier paso: registra el evento con resultado `rechazado`
    y `motivo_rechazo`, y lanza excepción con los motivos.

**Reglas de guardia por transición** — ver `docs/00_gobierno/adrs/ADR-003-maquina-de-estados-del-caso.md`.

Reglas de implementación:
- Ningún otro servicio puede escribir `casos.estado_actual` directamente. (RN-CAS-02, RI-01)
- Los pasos 5 y 6 ocurren en una transacción atómica.
- El evento de auditoría se registra incluso si la transición es rechazada.

---

### `HerramientaService` (patrón base para herramientas operativas)
**Responsabilidad**: patrón arquitectónico común a los ocho servicios de herramientas.

`HerramientaService` se entiende como patrón arquitectónico, no como una clase concreta obligatoria.
Su implementación podrá ser una clase abstracta, un mixin, un decorador o una convención
de servicios independientes según las capacidades del stack elegido (NestJS).
Lo que sí es obligatorio es que todos los servicios de herramientas respeten
las dos operaciones base y la regla crítica de verificación de estado.

Cada herramienta tiene su propio servicio que extiende este patrón:
`HechoService`, `PruebaService`, `RiesgoService`, `EstrategiaService`,
`ActuacionService`, `ExplicacionClienteService`, `ChecklistService`, `ConclusionService`.

Operaciones base:
- `obtener(caso_id, solicitante)` — retorna la herramienta. Verifica acceso al caso.
- `guardar(caso_id, datos, solicitante)` — guarda cambios. Verifica estado del caso.

Regla base crítica:
- Antes de cualquier escritura, verificar que `caso.estado_actual` es `en_analisis`
  o `devuelto`. Si no, rechazar con `409`. (RN-HER-01)
- Durante `pendiente_revision`, las herramientas son de solo lectura para todos
  los perfiles, incluido el supervisor. (RN-HER-01, decisión ADR-003)

---

### `ChecklistService`
**Responsabilidad**: gestión del checklist de control de calidad.

Operaciones adicionales al patrón base:
- `marcarItem(caso_id, item_id, marcado, solicitante)` — marca o desmarca un ítem.
  Dispara actualización de `checklist_bloques.completado`.
- `evaluarCompletitud(caso_id)` — retorna los bloques críticos incompletos.
  Usado por `CasoEstadoService` antes de transiciones que lo requieren.
- `calcularProgreso(caso_id)` — retorna porcentaje de ítems completados. (RN-CHK-05)

Regla:
- `checklist_bloques.completado` nunca se escribe directamente. Se calcula
  al cambiar `marcado` en cualquier ítem del bloque. (RN-CHK-03, RN-DAT-05)

---

### `RevisionSupervisorService`
**Responsabilidad**: gestión del bloque de revisión formal del supervisor.

Operaciones:
- `obtener(caso_id, solicitante)` — retorna la revisión vigente.
- `registrar(caso_id, datos, solicitante)` — registra una revisión nueva.
  Solo supervisor o administrador. Solo en `pendiente_revision`. (RN-REV-01, RN-REV-02)
  Marca la revisión anterior como `vigente = false` antes de insertar la nueva.
  Incrementa `version_revision`.

Reglas:
- `observaciones` no puede ser vacío en ningún caso — aprobación ni devolución. (RN-REV-01)
- Solo puede haber un registro con `vigente = true` por caso en cada momento. (C7 MODELO_DATOS)

---

### `DocumentoService`
**Responsabilidad**: gestión de archivos adjuntos del caso.

Operaciones:
- `subir(caso_id, archivo, categoria, solicitante)` — valida estado, guarda archivo,
  registra en `documentos`.
- `listar(caso_id, solicitante)` — retorna documentos del caso filtrados por acceso.
- `desactivar(id, solicitante)` — marca `activo = false`. No elimina físicamente. (RN-DOC-03)

Reglas:
- Solo en `en_analisis` o `devuelto`. (RN-DOC-04)
- `categoria` es obligatoria. `otro` existe pero no es valor por defecto. (RN-DOC-02)
- No se eliminan archivos físicos. (RN-DOC-03)

---

### `InformeService`
**Responsabilidad**: generación y registro de informes exportables.

Operaciones:
- `generar(caso_id, tipo, formato, solicitante)` — genera el informe y lo registra.
- `listar(caso_id, solicitante)` — retorna informes generados del caso.
- `descargar(informe_id, solicitante)` — retorna URL o stream del archivo.

Reglas:
- Toda generación se registra en `informes_generados`. (RN-INF-02)
- Informe de conclusión requiere checklist sin bloques críticos incompletos. (RN-INF-03)
- Informe de revisión requiere `revision_supervisor` vigente. (RN-INF-04)
- Los informes se generan en el backend. El frontend recibe URL de descarga. (RN-INF-01)

---

### `IAService`
**Responsabilidad**: intermediación con proveedores de IA.

Operaciones:
- `consultar(caso_id, herramienta, consulta, solicitante)`:
  1. Construye el prompt desde la plantilla de la herramienta.
  2. Invoca al proveedor configurado.
  3. Registra la llamada completa en `ai_request_log` — exitosa o fallida.
  4. Retorna la respuesta al controlador.

Reglas:
- La respuesta nunca se escribe directamente en ningún campo del caso. (RN-IA-01)
- Toda llamada queda registrada. (RN-IA-02)
- El proveedor se lee de la configuración, no del código. (RN-IA-04)
- Si el proveedor no responde, retorna `503` sin afectar el caso. (RN-IA-05)

Componentes internos:
- `IAOrchestrator` — coordina proveedor, modelo y prompt.
- `IAProviderAdapter` — interfaz común para todos los proveedores.
- `PromptTemplateRepository` — repositorio de plantillas por herramienta.
- `AIRequestLogRepository` — escritura inmutable del log.

---

### `AuditoriaService`
**Responsabilidad**: registro de eventos críticos del sistema.

Operaciones:
- `registrar(evento)` — inserta en `eventos_auditoria`. Solo `INSERT`, nunca `UPDATE`.
- `listar(caso_id, solicitante)` — retorna eventos del caso. Solo supervisor y admin.

Reglas:
- Los registros son inmutables. (RN-AUD-02)
- Se registran: transiciones de estado, revisiones del supervisor, generación de informes,
  login, logout, eliminación de casos, cambios de perfil. (RN-AUD-03)

---

## Middleware y transversales

### Autenticación
- Middleware global que valida el token en cada solicitud antes de llegar al controlador.
- Si el token es inválido o expirado, retorna `401` inmediatamente.
- El middleware inyecta el usuario autenticado en el contexto de la solicitud.

### Autorización
- Verificación de perfil implementada en cada servicio, no en middleware global.
- El middleware solo autentica; los servicios autorizan.
- Razón: la autorización en LexPenal depende del estado del caso y del perfil
  simultáneamente, no solo del perfil. Un middleware global no puede resolver eso.

### Manejo de errores
- Un manejador global convierte excepciones de dominio en respuestas HTTP.
- Excepciones de dominio mapeadas a códigos HTTP:

| Excepción | Código HTTP |
|---|---|
| `RecursoNoEncontrado` | `404` |
| `AccesoNoAutorizado` | `403` |
| `TransicionInvalida` | `409` |
| `GuardiaIncumplida` | `422` |
| `ProveedorIANoDisponible` | `503` |
| Cualquier otra | `500` con log interno |

### Transacciones
- Las operaciones que escriben en múltiples tablas usan transacciones de base de datos.
- Operaciones que requieren transacción obligatoria:
  - `CasoInicializacionService.inicializar()`
  - `CasoEstadoService.transicionar()` (cambio de estado + evento de auditoría)
  - `RevisionSupervisorService.registrar()` (nueva revisión + marcar anterior como no vigente)

### Validación de entrada
- Toda entrada del cliente se valida en el controlador antes de llegar al servicio.
- Esquemas de validación definidos por recurso.
- Los errores de validación retornan `400` con detalle de campos inválidos.

---

## Estructura de directorios sugerida

La siguiente estructura es referencial y está orientada a NestJS con su convención de módulos.
Debe revisarse y ajustarse al iniciar el proyecto según las convenciones del equipo
y la elección de ORM. No es una estructura obligatoria sino un punto de partida documentado.

```
src/backend/
├── api/
│   ├── controllers/
│   │   ├── auth.controller
│   │   ├── usuarios.controller
│   │   ├── clientes.controller
│   │   ├── casos.controller
│   │   ├── herramientas.controller
│   │   ├── revision.controller
│   │   ├── informes.controller
│   │   ├── ia.controller
│   │   └── auditoria.controller
│   ├── middleware/
│   │   ├── auth.middleware
│   │   └── error.middleware
│   └── schemas/           ← esquemas de validación de entrada
│
├── services/
│   ├── auth.service
│   ├── usuario.service
│   ├── cliente.service
│   ├── caso.service
│   ├── caso-inicializacion.service
│   ├── caso-estado.service         ← servicio más crítico
│   ├── herramientas/
│   │   ├── hecho.service
│   │   ├── prueba.service
│   │   ├── riesgo.service
│   │   ├── estrategia.service
│   │   ├── actuacion.service
│   │   ├── explicacion-cliente.service
│   │   ├── checklist.service
│   │   └── conclusion.service
│   ├── revision-supervisor.service
│   ├── documento.service
│   ├── informe.service
│   ├── ia.service
│   └── auditoria.service
│
├── domain/
│   ├── enums/
│   │   ├── estado-caso.enum
│   │   ├── perfil-usuario.enum
│   │   ├── resultado-revision.enum
│   │   └── tipo-informe.enum
│   └── exceptions/
│       ├── recurso-no-encontrado.exception
│       ├── acceso-no-autorizado.exception
│       ├── transicion-invalida.exception
│       └── guardia-incumplida.exception
│
├── infrastructure/
│   ├── repositories/
│   │   ├── usuario.repository
│   │   ├── cliente.repository
│   │   ├── caso.repository
│   │   ├── hecho.repository
│   │   ├── prueba.repository
│   │   ├── riesgo.repository
│   │   ├── estrategia.repository
│   │   ├── checklist.repository
│   │   ├── conclusion.repository
│   │   ├── revision-supervisor.repository
│   │   ├── documento.repository
│   │   ├── informe.repository
│   │   ├── ai-request-log.repository
│   │   └── auditoria.repository
│   ├── ia/
│   │   ├── ia-orchestrator
│   │   ├── ia-provider.adapter       ← interfaz común
│   │   ├── anthropic.adapter         ← implementación Anthropic
│   │   ├── openai.adapter            ← implementación OpenAI (futura)
│   │   └── prompt-template.repository
│   ├── reports/
│   │   ├── report-engine
│   │   └── templates/
│   └── storage/
│       └── file-storage.adapter
│
└── config/
    ├── database.config
    ├── ia.config                     ← proveedor y modelo configurables
    └── app.config
```

---

## Flujo de una solicitud típica

**Ejemplo: estudiante envía caso a revisión**
`POST /api/v1/cases/{id}/transition` con `{ "estado_destino": "pendiente_revision" }`

```
1. auth.middleware
   └─ valida token → inyecta usuario en contexto

2. casos.controller
   └─ valida body (estado_destino presente y válido)
   └─ llama CasoEstadoService.transicionar(id, "pendiente_revision", usuario)

3. CasoEstadoService.transicionar()
   ├─ CasoRepository.obtener(id)               → caso existe?
   ├─ verificar perfil                          → estudiante puede? ✅
   ├─ verificar transición válida               → en_analisis → pendiente_revision? ✅
   ├─ ChecklistService.evaluarCompletitud(id)   → bloques críticos incompletos? ✅
   ├─ HechoRepository.contarPorCaso(id)         → al menos un hecho? ✅
   ├─ EstrategiaRepository.obtener(id)          → línea_principal no vacía? ✅
   ├─ [transacción]
   │   ├─ CasoRepository.actualizarEstado(...)
   │   └─ AuditoriaService.registrar(evento exitoso)
   └─ retorna caso actualizado

4. casos.controller
   └─ serializa respuesta
   └─ retorna 200 con caso actualizado
```

**Si una guardia falla:**
```
3. CasoEstadoService.transicionar()
   ├─ ChecklistService.evaluarCompletitud(id) → bloques B03, B05 incompletos ⚠️
   ├─ [transacción]
   │   └─ AuditoriaService.registrar(evento rechazado, motivos)
   └─ lanza GuardiaIncumplida(["B03 incompleto", "B05 incompleto"])

4. error.middleware
   └─ captura GuardiaIncumplida
   └─ retorna 422 con estructura de error estándar
```

---

## Reglas de implementación transversales

**RI-BACK-01** — Los controladores no contienen lógica de negocio.
Solo validan entrada, llaman al servicio correspondiente y serializan la respuesta.
Un controlador con lógica de negocio embebida, condicionales sobre estado del caso
o acceso directo a repositorios es una señal de alerta que debe revisarse en code review.

**RI-BACK-02** — Los repositorios no contienen lógica de negocio.
Solo ejecutan consultas a la base de datos. Las condiciones de filtro
complejas son aceptables; las reglas de negocio no.

**RI-BACK-03** — `CasoEstadoService` es el único que escribe `estado_actual`.
Ningún otro archivo del proyecto puede escribir `casos.estado_actual` directamente.
Esta restricción debe verificarse en revisión de código.

**RI-BACK-04** — Los servicios de herramientas verifican el estado del caso antes de escribir.
Esta verificación no puede delegarse al controlador ni al repositorio.
Vive en el servicio.

**RI-BACK-05** — Todo servicio que modifica datos críticos registra el evento de auditoría.
La llamada a `AuditoriaService.registrar()` no es opcional.
Si el registro de auditoría falla, la operación principal también debe fallar.

**RI-BACK-06** — Las excepciones de dominio son la forma de comunicar errores de negocio.
Los servicios lanzan excepciones tipificadas. Los controladores no manejan
errores de negocio directamente; el middleware de errores los convierte a HTTP.

**RI-BACK-07** — La configuración de IA nunca está en el código fuente.
El proveedor, el modelo y las credenciales viven en variables de entorno
o en la configuración del sistema. El código solo lee la configuración.

---

**RI-BACK-08** — El versionado de la API es por path.
La versión actual es `v1`: todos los endpoints tienen el prefijo `/api/v1/`.
El contrato de `v1` es estable — no se introducen breaking changes en endpoints existentes.
Si un cambio rompe compatibilidad, se crea una versión `v2` en paralelo;
`v1` se mantiene hasta deprecación formal documentada mediante ADR.
Los cambios aditivos (nuevos campos opcionales en respuesta, nuevos endpoints)
no constituyen breaking change y no requieren nueva versión.

---

**RI-BACK-09** — Las operaciones críticas son idempotentes o están protegidas contra duplicación.

Comportamiento esperado por operación:

| Operación | Comportamiento ante llamada repetida |
|---|---|
| Transición de estado | Si el caso ya está en el estado destino, retorna `200` con el estado actual sin error. Si la transición ya no es válida, retorna `409`. No se crea un evento duplicado. |
| Generación de informe | Si ya existe un informe del mismo tipo y formato generado en el mismo estado del caso en los últimos N minutos, retorna el informe existente sin regenerar. El umbral de tiempo es configurable. |
| Llamada al módulo de IA | Cada llamada genera un nuevo registro en `ai_request_log`. No hay deduplicación — el usuario puede repetir consultas. El frontend debe prevenir doble envío por UX, no el backend por lógica. |
| Marcado de ítem de checklist | Marcar un ítem ya marcado es una no-operación. Retorna `200` sin modificar la base de datos. |
| Creación de revisión del supervisor | *(Regla provisional)* Si ya existe una revisión `vigente = true` con el mismo resultado y observaciones idénticas, el backend advierte pero permite sobrescribir. Queda en el historial. Esta regla debe formalizarse antes de implementación con una de las tres opciones siguientes: (a) permitir nueva revisión siempre, incrementando `version_revision`; (b) bloquear duplicado exacto con `409`; (c) crear nueva versión solo si cambia `resultado` u `observaciones`. |
