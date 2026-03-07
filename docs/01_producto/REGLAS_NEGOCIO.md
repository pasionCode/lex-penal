# Reglas de negocio y datos

Documento de referencia de todas las reglas de negocio del sistema LexPenal.
Consolida las reglas dispersas en ADRs, modelo de datos, roles y permisos,
y las derivadas directamente de la Unidad 8 del Manual de Defensa Penal Colombiana.

Toda regla tiene un identificador, su enunciado, su origen y sus consecuencias
técnicas. Ninguna regla puede modificarse sin una ADR o una decisión formal
documentada en `docs/00_gobierno/`.

**Documentos fuente**
- `docs/00_gobierno/adrs/ADR-003-maquina-de-estados-del-caso.md`
- `docs/01_producto/ROLES_Y_PERMISOS.md`
- `docs/03_datos/MODELO_DATOS.md`
- `docs/14_legal_funcional/REGLAS_FUNCIONALES_VINCULANTES.md`
- Unidad 8, Manual de Defensa Penal Colombiana

| Campo | Valor |
|---|---|
| Última revisión | (completar) |
| Responsable | (completar) |

---

## Dominios de reglas

1. [Caso — ciclo de vida y estados](#1-caso--ciclo-de-vida-y-estados)
2. [Caso — herramientas operativas](#2-caso--herramientas-operativas)
3. [Checklist — control de calidad](#3-checklist--control-de-calidad)
4. [Conclusión operativa](#4-conclusión-operativa)
5. [Revisión del supervisor](#5-revisión-del-supervisor)
6. [Módulo de IA](#6-módulo-de-ia)
7. [Usuarios y autorización](#7-usuarios-y-autorización)
8. [Auditoría e inmutabilidad](#8-auditoría-e-inmutabilidad)
9. [Unicidad e identificación](#9-unicidad-e-identificación)
10. [Documentos adjuntos](#10-documentos-adjuntos)
11. [Integridad de datos](#11-integridad-de-datos)
12. [Informes](#12-informes)

---

## 1. Caso — ciclo de vida y estados

**RN-CAS-01** — El caso es la entidad agregadora del sistema.
Toda entidad operativa (hechos, pruebas, riesgos, checklist, conclusión, documentos,
logs de IA, eventos de auditoría) pertenece a un caso.
No existe registro operativo sin `caso_id` válido.
*Origen: R01, MODELO_DATOS RI-01.*

---

**RN-CAS-02** — El estado del caso lo controla exclusivamente el backend.
El campo `estado_actual` de la tabla `casos` solo puede modificarse a través
del servicio `CasoEstadoService`. Ningún otro servicio, endpoint ni consulta directa
puede escribir ese campo.
*Origen: ADR-003, MODELO_DATOS RI-01.*

---

**RN-CAS-03** — Las transiciones de estado son las únicas válidas.
```
borrador → en_analisis
en_analisis → pendiente_revision
pendiente_revision → devuelto
pendiente_revision → aprobado_supervisor
devuelto → en_analisis
aprobado_supervisor → listo_para_cliente
listo_para_cliente → cerrado
```
Cualquier otra transición es inválida y el backend la rechaza con `409 Conflict`.
*Origen: ADR-003.*

---

**RN-CAS-04** — Un caso en estado `cerrado` es de solo lectura absoluta.
Ninguna herramienta operativa, campo del caso ni documento adjunto puede
modificarse mientras el caso esté cerrado. El backend rechaza toda escritura con `409`.
La reapertura no forma parte del MVP 1.0 y requiere ADR posterior.
*Origen: ADR-003, MODELO_DATOS RI-02.*

---

**RN-CAS-05** — El caso en estado `devuelto` no puede avanzar sin regresar primero a `en_analisis`.
Mientras esté en `devuelto`, no puede transitar a `aprobado_supervisor`
ni a `listo_para_cliente` directamente.
*Origen: ADR-003.*

---

**RN-CAS-06** — La transición `borrador → en_analisis` exige ficha básica mínima.
Campos obligatorios antes de iniciar el análisis: radicado, procesado,
delito imputado y etapa procesal. Sin ellos, la transición es rechazada con `422`.
*Origen: ADR-003.*

---

**RN-CAS-07** — Al crear un caso, el sistema genera automáticamente los registros relacionados.
La creación del caso dispara la generación de:
los registros de `checklist_bloques` e `checklist_items` según la plantilla de la U008,
y los registros vacíos de `estrategia`, `explicacion_cliente` y `conclusion_operativa`.
*Origen: MODELO_DATOS RI-04.*

---

## 2. Caso — herramientas operativas

**RN-HER-01** — Las herramientas solo son editables en estados activos.
Las ocho herramientas operativas (ficha, hechos, pruebas, riesgos, estrategia,
explicación al cliente, checklist y conclusión) solo admiten escritura cuando
el caso está en estado `en_analisis` o `devuelto`.
En cualquier otro estado son de solo lectura. El backend rechaza escrituras con `409`.

Durante `pendiente_revision`, las herramientas operativas permanecen bloqueadas
para edición para todos los perfiles, incluido el supervisor.
El supervisor solo puede escribir en ese estado: el bloque `revision_supervisor`,
sus observaciones y la decisión de aprobar o devolver.
Esta restricción preserva la separación entre autoría del análisis (responsable)
y revisión del análisis (supervisor), con efectos directos en trazabilidad,
responsabilidad y auditoría.
*Origen: ADR-003, CONTRATO_API.*

---

**RN-HER-02** — La matriz de hechos debe tener al menos un hecho para enviar a revisión.
La transición `en_analisis → pendiente_revision` requiere al menos un hecho
registrado en la tabla `hechos` para el caso.
*Origen: ADR-003.*

---

**RN-HER-03** — La estrategia debe tener al menos una línea defensiva para enviar a revisión.
La transición `en_analisis → pendiente_revision` requiere que el campo
`linea_principal` de `estrategia` no sea nulo ni vacío.
*Origen: ADR-003.*

---

**RN-HER-04** — La situación de libertad del cliente condiciona un campo obligatorio.
Si `clientes.situacion_libertad = 'detenido'`,
el campo `lugar_detencion` no puede ser nulo.
*Origen: MODELO_DATOS.*

---

**RN-HER-05** — Cada herramienta corresponde a un apartado de la Unidad 8.
Ninguna herramienta puede eliminarse del sistema sin una decisión formal
documentada en `docs/14_legal_funcional/TRAZABILIDAD_U008.md`.
*Origen: U008, REGLAS_FUNCIONALES_VINCULANTES R01.*

---

## 3. Checklist — control de calidad

**RN-CHK-01** — El checklist es una compuerta funcional vinculante.
La transición `en_analisis → pendiente_revision` requiere que ningún bloque
marcado como `critico = true` esté con `completado = false`.
El backend evalúa este criterio antes de ejecutar la transición. No es una advertencia:
si falla, la transición se rechaza con `422` y se retornan los bloques incompletos.
*Origen: ADR-003, R02, MODELO_DATOS.*

---

**RN-CHK-02** — El checklist se verifica también antes de entregar al cliente.
La transición `aprobado_supervisor → listo_para_cliente` requiere igualmente
que no haya bloques críticos incompletos. Un caso aprobado por el supervisor
pero con inconsistencias materiales posteriores no puede avanzar.
*Origen: ADR-003 corrección C3.*

---

**RN-CHK-03** — `checklist_bloques.completado` es un campo calculado.
Se actualiza automáticamente (trigger o lógica de servicio) cada vez que
un ítem del bloque cambia su campo `marcado`.
Un bloque se marca como completado cuando todos sus ítems están marcados.
*Origen: MODELO_DATOS RI-05.*

---

**RN-CHK-04** — Un bloque aparentemente irrelevante debe documentarse, no ignorarse.
Si el responsable del caso considera que un bloque no aplica al expediente concreto,
debe registrar la justificación en el campo de observaciones del bloque,
no simplemente omitirlo. El bloque debe marcarse explícitamente.
*Origen: U008, Apartado 7.*

---

**RN-CHK-05** — El porcentaje de avance del checklist es visible en el dashboard.
El sistema debe calcular y exponer el porcentaje de ítems completados
sobre el total de ítems del caso para mostrarlo en la lista de casos
sin necesidad de abrir el expediente.
*Origen: ESTADOS_DEL_CASO, prototipo LexPenal.*

---

## 4. Conclusión operativa

**RN-CON-01** — La conclusión operativa tiene estructura obligatoria de cinco bloques.
Los cinco bloques son: síntesis del caso, panorama probatorio y procesal,
panorama punitivo, opciones disponibles y recomendación.
Ningún bloque puede eliminarse del formato.
*Origen: U008 Apartado 8, R03.*

---

**RN-CON-02** — La recomendación no puede ser genérica ni vacía.
El campo `recomendacion` de `conclusion_operativa` no puede ser nulo,
vacío ni contener texto por defecto como "(completar)".
Es condición para la transición `aprobado_supervisor → listo_para_cliente`.
*Origen: ADR-003, U008 Apartado 8.*

---

**RN-CON-03** — La conclusión no puede presentarse al cliente sin aprobación del supervisor.
La transición a `listo_para_cliente` requiere que exista un registro de
`revision_supervisor` con `resultado = 'aprobado'` para el caso.
*Origen: R03, R04, ADR-003.*

---

**RN-CON-04** — La conclusión operativa depende del checklist completo.
No puede generarse el informe de conclusión operativa si el checklist
tiene bloques críticos incompletos. El motor de informes verifica este
criterio antes de producir el documento.
*Origen: U008 Apartado 8, R02.*

---

**RN-CON-05** — La conclusión operativa es un entregable formal exportable.
Debe poder exportarse en PDF y DOCX. La versión exportada registra:
el nombre del responsable, el nombre del supervisor que aprobó,
la fecha de generación y el estado del caso al momento de la exportación.
*Origen: R03, CATALOGO_INFORMES.*

---

## 5. Revisión del supervisor

**RN-REV-01** — La revisión del supervisor es un paso formal del flujo.
Para transitar a `aprobado_supervisor`, debe existir un registro en
`revision_supervisor` con `resultado = 'aprobado'` y `observaciones` no vacío.
Para transitar a `devuelto`, debe existir un registro con `resultado = 'devuelto'`
y `observaciones` no vacío.
Las observaciones son obligatorias en ambos casos — aprobación y devolución.
Un supervisor que aprueba sin dejar constancia escrita de su criterio no genera
trazabilidad auditable. Esta es una decisión consciente de diseño.
*Origen: R04, ADR-003.*

---

**RN-REV-02** — Solo supervisor o administrador puede diligenciar la revisión.
El bloque de revisión del supervisor en la tabla `revision_supervisor`
solo puede ser escrito por usuarios con perfil `supervisor` o `administrador`.
El backend rechaza escrituras de estudiantes con `403`.
*Origen: ROLES_Y_PERMISOS, ADR-003.*

---

**RN-REV-03** — Las observaciones del supervisor son obligatorias en toda revisión.
Tanto en aprobación como en devolución, el campo `observaciones` no puede
estar vacío. Una revisión sin fundamento escrito no es válida.
*Origen: ADR-003.*

---

**RN-REV-04** — La reapertura desde `devuelto` a `en_analisis` requiere observación registrada.
Antes de que el responsable pueda reabrir el caso, debe existir al menos
una observación del supervisor registrada. La reapertura queda auditada
con usuario, fecha y estado de origen.
*Origen: ADR-003 corrección C2.*

---

## 6. Módulo de IA

**RN-IA-01** — La IA es un asistente, no un decisor.
Ninguna respuesta del módulo de IA puede escribirse directamente en ningún
campo del caso ni modificar el estado del expediente.
Toda respuesta es orientativa y visible solo en el panel del asistente.
*Origen: R05, REGLAS_FUNCIONALES_VINCULANTES.*

---

**RN-IA-02** — Toda llamada al módulo de IA es auditada obligatoriamente.
Cada invocación genera un registro en `ai_request_log` con: caso, usuario,
herramienta, proveedor, modelo, prompt completo, respuesta, tokens y duración.
Este registro es inmutable.
*Origen: R05, R06, MODELO_DATOS.*

---

**RN-IA-03** — El frontend nunca llama directamente a proveedores de IA.
En producción, toda consulta de IA pasa por el endpoint interno
`POST /api/v1/ai/query`. El backend gestiona credenciales, selección de
proveedor y registro. El frontend no tiene acceso a las claves del proveedor.
*Origen: R07, ADR-004.*

---

**RN-IA-04** — El proveedor de IA es configurable sin cambiar código.
El proveedor por defecto y el modelo son parámetros de configuración
del sistema, no constantes en el código fuente.
Un administrador puede cambiar el proveedor desde la configuración.
*Origen: R07, ADR-004.*

---

**RN-IA-05** — Si el proveedor de IA no está disponible, el sistema sigue operando.
El módulo de IA es una capa de asistencia, no un componente crítico del flujo.
Si el servicio de IA falla, el sistema retorna `503` en el endpoint de consulta
pero no bloquea ninguna acción sobre el caso.
*Origen: R07, ADR-004.*

---

## 7. Usuarios y autorización

**RN-USR-01** — La autorización la verifica siempre el backend.
El perfil del usuario se verifica en cada solicitud en el servidor.
El frontend puede ocultar acciones no disponibles, pero el backend
es el único árbitro de lo que está permitido.
*Origen: R-PERM-01, ROLES_Y_PERMISOS.*

---

**RN-USR-02** — Un estudiante solo accede a sus propios casos.
Un usuario con perfil `estudiante` solo puede ver y editar los casos
que creó o que le fueron asignados explícitamente.
El backend filtra automáticamente por `responsable_id`.
*Origen: R-PERM-02, ROLES_Y_PERMISOS.*

---

**RN-USR-03** — El perfil de usuario solo lo cambia el administrador.
Un usuario no puede modificar su propio perfil. Solo un administrador
puede cambiar el perfil de cualquier usuario.
*Origen: R-PERM-03, ROLES_Y_PERMISOS.*

---

**RN-USR-04** — El perfil es condición necesaria pero no suficiente para una transición.
Tener el perfil correcto no garantiza que una transición sea posible.
El backend verifica primero el perfil y luego las reglas de guardia.
Ambas condiciones deben cumplirse.
*Origen: R-PERM-04, ADR-003.*

---

**RN-USR-05** — El administrador no puede saltarse las compuertas metodológicas.
El perfil `administrador` tiene los mismos permisos de flujo que `supervisor`,
pero no puede ignorar las reglas de guardia (checklist, conclusión, revisión).
Las compuertas aplican para todos los perfiles sin excepción.
*Origen: R-PERM-05, ROLES_Y_PERMISOS.*

---

**RN-USR-06** — Un usuario desactivado no puede iniciar sesión.
Si `usuarios.activo = false`, el sistema rechaza el login con `401`.
Los registros del usuario se conservan por trazabilidad histórica.
*Origen: MODELO_DATOS.*

---

## 8. Auditoría e inmutabilidad

**RN-AUD-01** — Toda transición de estado genera un evento de auditoría.
Cada llamada a `CasoEstadoService`, sea exitosa o rechazada, genera
un registro en `eventos_auditoria` con: caso, usuario, estado origen,
estado destino, resultado y motivo de rechazo si aplica.
*Origen: R06, ADR-003, MODELO_DATOS.*

---

**RN-AUD-02** — Los registros de auditoría e IA son inmutables.
Las tablas `eventos_auditoria` y `ai_request_log` no admiten `UPDATE` ni `DELETE`
bajo ninguna circunstancia ni perfil. Solo `INSERT`.
*Origen: R06, MODELO_DATOS RI-03.*

---

**RN-AUD-03** — Las acciones críticas adicionales también se auditan.
Además de las transiciones de estado, se auditan obligatoriamente:
generación de informes, revisiones del supervisor, login y logout,
eliminación de casos, y cambios de perfil de usuario.
*Origen: R06.*

---

## 9. Unicidad e identificación

**RN-UNI-01** — El email del usuario es único en el sistema.
No pueden existir dos registros en `usuarios` con el mismo `email`,
independientemente del perfil o estado del usuario.
El backend rechaza el registro con `422` si el email ya existe.
*Origen: MODELO_DATOS, RN-USR-06.*

---

**RN-UNI-02** — La combinación tipo y número de documento del cliente es única.
No pueden existir dos registros en `clientes` con la misma combinación
`tipo_documento + documento`. Evita registrar al mismo procesado dos veces.
El backend rechaza el registro con `422` e informa el caso existente vinculado.
*Origen: MODELO_DATOS C4.*

---

**RN-UNI-03** — El radicado judicial es único en el sistema.
No pueden existir dos casos con el mismo `radicado`.
Si se necesita gestionar el mismo radicado en etapas distintas,
debe usarse el mismo caso actualizando su etapa procesal.
El backend rechaza la creación con `422` si el radicado ya existe.
*Origen: MODELO_DATOS C5.*

---

## 10. Documentos adjuntos

**RN-DOC-01** — Todo documento adjunto debe estar asociado a un caso.
No existen documentos flotantes en el sistema.
El campo `caso_id` en `documentos` es obligatorio y no puede ser nulo.
*Origen: MODELO_DATOS, RN-CAS-01.*

---

**RN-DOC-02** — Todo documento adjunto debe tener categoría asignada.
El campo `categoria` es obligatorio y debe corresponder a uno de los
valores definidos: `acusacion`, `defensa`, `cliente`, `actuacion`,
`informe`, `evidencia`, `anexo`, `otro`.
No se admiten documentos sin clasificar. El valor `otro` existe como
categoría de último recurso, no como valor por defecto.
*Origen: MODELO_DATOS C8.*

---

**RN-DOC-03** — Los documentos adjuntos no se eliminan, se desactivan.
Para preservar la integridad del expediente, los documentos no se borran físicamente.
Si un documento debe retirarse del expediente, se marca con un campo `activo = false`.
El archivo físico se conserva en el almacenamiento.
Esta regla aplica especialmente a casos en estados avanzados (`aprobado_supervisor`,
`listo_para_cliente`, `cerrado`).
*Origen: principio de trazabilidad, R06.*

---

**RN-DOC-04** — La subida de documentos solo está disponible en estados activos.
Los documentos solo pueden adjuntarse cuando el caso está en `en_analisis`
o `devuelto`. En cualquier otro estado el backend rechaza la subida con `409`.
*Origen: RN-HER-01, consistencia de flujo.*

---

## 11. Integridad de datos

**RN-DAT-01** — Toda entidad crítica tiene trazabilidad mínima.
Los campos `creado_en`, `actualizado_en`, `creado_por` y `actualizado_por`
son obligatorios en todas las entidades operativas del sistema.
Se consideran entidades críticas: `casos`, `hechos`, `pruebas`, `riesgos`,
`estrategia`, `actuaciones`, `explicacion_cliente`, `checklist_bloques`,
`checklist_items`, `conclusion_operativa`, `revision_supervisor`, `documentos`.
Las entidades de soporte inmutables (`ai_request_log`, `eventos_auditoria`,
`linea_tiempo`) solo requieren `creado_en` y `creado_por` dado que no admiten
actualizaciones.
*Origen: MODELO_DATOS principio 2.*

---

**RN-DAT-02** — Los identificadores son UUID v4.
Todas las entidades principales usan UUID v4 como clave primaria.
No se usan identificadores enteros secuenciales para entidades expuestas en la API.
*Origen: MODELO_DATOS principio 5, CONTRATO_API.*

---

**RN-DAT-03** — La nomenclatura es snake_case en toda la capa de datos y API.
Campos, tablas, índices y campos del contrato API usan snake_case sin excepción.
*Origen: MODELO_DATOS principio 4, CONTRATO_API.*

---

**RN-DAT-04** — Las contraseñas nunca se almacenan en claro.
El campo `password_hash` de `usuarios` almacena exclusivamente el hash
de la contraseña con un algoritmo seguro (bcrypt o argon2).
*Origen: MODELO_DATOS, SEGURIDAD_BASE.*

---

**RN-DAT-05** — `checklist_bloques.completado` es calculado, nunca escrito directamente.
Este campo se actualiza automáticamente cuando cambia el estado `marcado`
de cualquier ítem del bloque. No puede ser modificado directamente por
ningún servicio fuera del mecanismo de actualización automática.
*Origen: MODELO_DATOS RI-05.*

---

## 12. Informes

**RN-INF-01** — Los informes se generan desde el backend.
Ningún informe se genera en el frontend. El motor de plantillas,
la exportación a PDF y DOCX, y el almacenamiento del archivo residen
en el backend. El frontend solo recibe la URL de descarga.
*Origen: ADR-005, ARQUITECTURA_GENERAL.*

---

**RN-INF-02** — Todo informe generado queda registrado.
Cada informe produce un registro en `informes_generados` con: tipo,
formato, ruta del archivo, estado del caso al momento de generación,
fecha y usuario que lo solicitó.
*Origen: MODELO_DATOS, R06.*

---

**RN-INF-03** — El informe de conclusión operativa requiere checklist completo.
El motor de informes verifica que no haya bloques críticos incompletos
antes de generar el informe de conclusión operativa.
Si los hay, retorna `422` con los bloques pendientes.
*Origen: RN-CON-04, U008.*

---

**RN-INF-04** — El informe de revisión del supervisor requiere revisión formal.
No puede generarse el informe de revisión del supervisor si no existe
un registro en `revision_supervisor` para el caso.
*Origen: R04, CATALOGO_INFORMES.*

---

## Resumen de reglas por entidad afectada

| Entidad | Reglas aplicables |
|---|---|
| `casos` — estado | RN-CAS-01, RN-CAS-02, RN-CAS-03, RN-CAS-04, RN-CAS-05 |
| `casos` — creación | RN-CAS-06, RN-CAS-07 |
| `hechos`, `pruebas`, `riesgos`, `estrategia` | RN-HER-01, RN-HER-02, RN-HER-03, RN-HER-04, RN-HER-05 |
| `checklist_bloques`, `checklist_items` | RN-CHK-01, RN-CHK-02, RN-CHK-03, RN-CHK-04, RN-CHK-05 |
| `conclusion_operativa` | RN-CON-01, RN-CON-02, RN-CON-03, RN-CON-04, RN-CON-05 |
| `revision_supervisor` | RN-REV-01, RN-REV-02, RN-REV-03, RN-REV-04 |
| `ai_request_log` | RN-IA-01, RN-IA-02, RN-IA-03, RN-IA-04, RN-IA-05 |
| `usuarios` | RN-USR-01, RN-USR-02, RN-USR-03, RN-USR-04, RN-USR-05, RN-USR-06 |
| `eventos_auditoria` | RN-AUD-01, RN-AUD-02, RN-AUD-03 |
| `usuarios` — unicidad | RN-UNI-01 |
| `clientes` — unicidad | RN-UNI-02 |
| `casos` — unicidad | RN-UNI-03 |
| `documentos` | RN-DOC-01, RN-DOC-02, RN-DOC-03, RN-DOC-04 |
| Todas las entidades críticas | RN-DAT-01, RN-DAT-02, RN-DAT-03, RN-DAT-04, RN-DAT-05 |
| `informes_generados` | RN-INF-01, RN-INF-02, RN-INF-03, RN-INF-04 |
