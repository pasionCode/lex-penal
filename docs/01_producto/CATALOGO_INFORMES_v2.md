# Catálogo de informes

Documento de referencia de todos los informes que el sistema LexPenal
puede generar sobre un caso. Define para cada informe: su propósito,
su contenido, sus requisitos de generación, los perfiles que pueden
solicitarlo y los estados del caso desde los que está disponible.

**Documentos relacionados**
- `docs/03_datos/REGLAS_NEGOCIO.md` — RN-INF-01 a RN-INF-04
- `docs/03_datos/MODELO_DATOS.md` — tabla `informes_generados`
- `docs/04_api/CONTRATO_API.md` — `POST /api/v1/cases/{id}/reports`
- `docs/01_producto/ESTADOS_DEL_CASO.md`
- `docs/01_producto/MATRIZ_ROLES_PERMISOS.md`

| Campo | Valor |
|---|---|
| Última revisión | (completar) |
| Responsable | (completar) |

---

## Principios del módulo de informes

**PI-01 — Los informes se generan en el backend.**
Ningún informe se genera en el frontend. El motor de plantillas, la conversión
a PDF o DOCX y el almacenamiento del archivo son responsabilidad exclusiva
del backend. El frontend solicita el informe y descarga el resultado. (RN-INF-01)

**PI-02 — Todo informe generado queda registrado.**
Cada generación produce un registro inmutable en `informes_generados` con:
tipo, formato, ruta del archivo, estado del caso al momento de generación,
usuario solicitante y fecha. Este registro no se elimina aunque el archivo
sea descargado múltiples veces. (RN-INF-02)

**PI-03 — Los informes son una fotografía del caso en el momento de generación.**
El informe no se actualiza automáticamente si el caso cambia después.
Si el responsable necesita un informe actualizado, debe generar uno nuevo.
El historial de informes anteriores se conserva.

**PI-04 — La idempotencia protege contra doble generación.**
Si ya existe un informe del mismo tipo y formato generado dentro de una ventana
de tiempo configurable (por defecto 5 minutos), el backend retorna el informe
existente. Esto previene generación duplicada por reintento de timeout o
doble clic desde el frontend.

**PI-05 — Los formatos disponibles son PDF y DOCX.**
Todos los informes pueden generarse en ambos formatos salvo indicación
específica en el catálogo. El formato no cambia el contenido — solo la
presentación y el tipo de archivo resultante.

---

## Tabla resumen

| Código | Nombre | Estados disponibles | Perfiles |
|---|---|---|---|
| `resumen_ejecutivo` | Resumen ejecutivo del caso | `en_analisis`, `pendiente_revision`, `devuelto`, `aprobado_supervisor`, `listo_para_cliente`, `cerrado` | Todos con acceso al caso |
| `conclusion_operativa` | Conclusión operativa | `aprobado_supervisor`, `listo_para_cliente`, `cerrado` | Supervisor, Admin |
| `control_calidad` | Control de calidad *(supervisión formal)* | `en_analisis`, `pendiente_revision`, `devuelto`, `aprobado_supervisor`, `listo_para_cliente`, `cerrado` | Supervisor, Admin |
| `riesgos` | Matriz de riesgos | `en_analisis`, `pendiente_revision`, `devuelto`, `aprobado_supervisor`, `listo_para_cliente`, `cerrado` | Todos con acceso al caso |
| `cronologico` | Cronológico del caso | `en_analisis`, `pendiente_revision`, `devuelto`, `aprobado_supervisor`, `listo_para_cliente`, `cerrado` | Todos con acceso al caso |
| `revision_supervisor` | Revisión del supervisor | `aprobado_supervisor`, `listo_para_cliente`, `cerrado` | Supervisor, Admin |
| `agenda_vencimientos` | Agenda de vencimientos | `borrador`, `en_analisis`, `pendiente_revision`, `devuelto`, `aprobado_supervisor`, `listo_para_cliente`, `cerrado` | Todos con acceso al caso |

**Nota sobre "Todos con acceso al caso"**: para Estudiante implica solo sus casos propios;
Supervisor y Administrador acceden a todos los casos del sistema.
`agenda_vencimientos` es el único informe disponible desde `borrador`.

---

## Fichas de informe

---

### `resumen_ejecutivo` — Resumen ejecutivo del caso

**Propósito**
Síntesis general del caso para consulta rápida del estado del expediente.
Cubre los datos de identificación, la calificación jurídica, el estado procesal
y las herramientas diligenciadas. No requiere análisis completo.

**Contenido**
- Datos del caso: radicado, procesado, delito imputado, etapa procesal, régimen.
- Estado actual del caso y fecha de última actualización.
- Datos del responsable.
- Estado de diligenciamiento de cada herramienta (completa / incompleta / vacía).
- Próxima actuación registrada y fecha.
- Fecha de generación del informe.

**Requisitos de generación**
- Ninguno más allá de que el caso exista y el usuario tenga acceso.
- Disponible desde `en_analisis` — no en `borrador` (el caso aún no tiene
  suficiente información para un resumen útil).

**Perfiles autorizados**
Estudiante (caso propio), Supervisor y Administrador.

**Formatos**: PDF, DOCX.

---

### `conclusion_operativa` — Conclusión operativa

**Propósito**
Informe formal del análisis completo del caso para presentar al cliente o
al supervisor. Es el documento de mayor jerarquía del expediente y sintetiza
el resultado del trabajo de la Unidad 8.

**Contenido**
- Datos completos del caso.
- Síntesis jurídica de los hechos y la calificación.
- Posición defensiva adoptada.
- Recomendación estratégica.
- Próximas actuaciones con plazos.
- Observaciones finales.
- Datos del responsable y del supervisor que aprobó.
- Fecha de aprobación y fecha de generación.

**Requisitos de generación** (RN-INF-03)
- El caso debe estar en estado `aprobado_supervisor`, `listo_para_cliente`
  o `cerrado`.
- El checklist no debe tener bloques críticos incompletos al momento
  de la generación.
- Los cinco bloques de la conclusión operativa deben estar diligenciados.
- El campo de recomendación estratégica no puede estar vacío.

**Perfiles autorizados**
Supervisor y Administrador. El estudiante no puede generar este informe —
la conclusión operativa es un documento formal que requiere supervisión aprobada.

**Formatos**: PDF, DOCX.

---

### `control_calidad` — Control de calidad

**Propósito**
Informe del estado del checklist de la Unidad 8 por bloques. Permite al
supervisor identificar con precisión qué criterios están cumplidos, cuáles
están pendientes y cuáles son críticos. Útil para la revisión y la devolución
con observaciones específicas.

**Contenido**
- Estado de cada bloque del checklist: completo / incompleto / crítico pendiente.
- Lista de ítems no marcados por bloque.
- Porcentaje de avance global y por bloque.
- Ítems críticos pendientes destacados.
- Fecha de generación.

**Requisitos de generación**
- El caso debe tener al menos un bloque del checklist con ítems.
- No disponible en `borrador`.

**Perfiles autorizados**
Supervisor y Administrador. El estudiante no accede a este informe — está
diseñado para el control de supervisión, no para el autocontrol del responsable.

**Nota**: el estudiante puede consultar el estado del checklist directamente
en la herramienta dentro del expediente. El informe formal es de uso supervisor.

**Formatos**: PDF, DOCX.

---

### `riesgos` — Matriz de riesgos

**Propósito**
Informe exportable de la matriz de riesgos del caso con su estado de mitigación.
Útil para comunicar la exposición jurídica del caso al cliente o para
documentar el análisis de riesgos en el expediente.

**Contenido**
- Lista completa de riesgos registrados.
- Por cada riesgo: descripción, probabilidad, impacto, prioridad,
  estrategia de mitigación, estado de mitigación, plazo de acción.
- Riesgos críticos destacados.
- Fecha de generación y estado del caso al momento de generación.

**Requisitos de generación**
- Al menos un riesgo registrado en la matriz.
- No disponible en `borrador`.

**Perfiles autorizados**
Todos los perfiles con acceso al caso.

**Formatos**: PDF, DOCX.

---

### `cronologico` — Cronológico del caso

**Propósito**
Línea de tiempo del caso: todas las actuaciones registradas, las transiciones
de estado y los eventos de auditoría relevantes, ordenados cronológicamente.
Útil para reconstruir el historial del caso y verificar plazos.

**Contenido**
- Actuaciones procesales registradas con fecha, tipo y responsable.
- Transiciones de estado del caso con fecha y usuario.
- Eventos de revisión del supervisor (sin detalle de observaciones).
- Próximas actuaciones pendientes.
- Fecha de generación.

**Requisitos de generación**
- El caso debe tener al menos una actuación o transición registrada.
- No disponible en `borrador`.

**Perfiles autorizados**
Todos los perfiles con acceso al caso.

**Formatos**: PDF, DOCX.

---

### `revision_supervisor` — Revisión del supervisor

**Propósito**
Historial formal de revisiones del supervisor sobre el caso. Documenta
el ejercicio de supervisión: cuántas revisiones hubo, qué resultado tuvieron
y qué observaciones dejó el supervisor en cada una. Es el trazado de
la cadena de supervisión del expediente.

**Contenido**
- Historial completo de revisiones ordenado por versión.
- Por cada revisión: versión, resultado (aprobado / devuelto),
  observaciones completas, supervisor, fecha.
- Revisión vigente destacada.
- Estado final del caso.
- Fecha de generación.

**Requisitos de generación** (RN-INF-04)
- Debe existir al menos una revisión formal registrada en el caso.
- El caso debe estar en `aprobado_supervisor`, `listo_para_cliente` o `cerrado`.
  No se genera informe de revisión sobre un caso que aún no ha sido revisado
  formalmente.

**Perfiles autorizados**
Supervisor y Administrador. El estudiante accede a observaciones individuales
por la vista filtrada (`/review/feedback`) — no al historial formal de revisiones.

Este informe corresponde al historial formal de revisión del expediente.
No es equivalente ni sustituto de la vista operativa de feedback que el
responsable consume para corregir el análisis. Son documentos distintos
con propósitos distintos.

**Formatos**: PDF, DOCX.

---

### `agenda_vencimientos` — Agenda de vencimientos

**Propósito**
Lista de próximas actuaciones y plazos registrados en el caso, ordenada
por fecha. Permite al responsable y al supervisor anticipar vencimientos
críticos y planificar el trabajo procesal.

**Contenido**
- Actuaciones pendientes ordenadas por fecha de vencimiento.
- Por cada actuación: descripción, tipo, fecha, responsable.
- Actuaciones vencidas o próximas a vencer destacadas.
- Estado actual del caso.
- Fecha de generación.

**Requisitos de generación**
- El caso debe tener al menos una actuación futura registrada.
- Disponible en todos los estados del caso incluyendo `borrador`.

**Perfiles autorizados**
Todos los perfiles con acceso al caso.

**Formatos**: PDF, DOCX.

---

## Reglas transversales de generación

**RG-01 — Códigos de error diferenciados por tipo de rechazo.**
La generación de un informe puede ser rechazada por tres razones distintas,
cada una con su código HTTP propio:
- `403` — el perfil del usuario no tiene permiso para generar este tipo de informe.
- `409` — el perfil tiene permiso pero el estado actual del caso no permite
  generar este informe. El mensaje indica el estado requerido.
- `422` — el estado es válido y el perfil tiene permiso, pero faltan datos
  o los requisitos de contenido no están cumplidos (ej. checklist incompleto).
  El backend retorna lista de requisitos no satisfechos.

**RG-02 — Informe solicitado sin datos suficientes: `422`.**
Si el estado del caso es válido pero faltan datos para generar el informe
(ej. checklist incompleto para `conclusion_operativa`), el backend retorna
`422` con lista de requisitos no cumplidos.

**RG-03 — El informe incluye siempre metadatos de generación.**
Todo informe generado incluye en su encabezado o pie: tipo de informe,
fecha y hora de generación, estado del caso al momento de generación,
usuario que lo solicitó y versión del sistema. Esto garantiza trazabilidad
del documento fuera del sistema.

**RG-04 — Los informes no modifican el caso.**
Generar un informe es una operación de solo lectura sobre el caso.
No cambia el estado, no registra eventos de auditoría de transición,
no marca ítems del checklist. Solo produce un archivo y registra la generación
en `informes_generados`.

**RG-05 — El motor de plantillas es independiente del proveedor de IA.**
Los informes se generan desde plantillas del sistema, no desde el módulo de IA.
El contenido del informe es el contenido del expediente — no una generación
de texto por IA. El módulo de IA y el módulo de informes son independientes.
