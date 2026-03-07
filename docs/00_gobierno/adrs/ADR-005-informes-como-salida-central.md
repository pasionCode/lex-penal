# ADR-005 — Los informes como salida central del sistema

| Campo | Valor |
|---|---|
| Estado | **Cerrado** |
| Fecha | 2026-03-06 |
| Decisor | Equipo técnico LexPenal |
| Documentos relacionados | `docs/11_informes/CATALOGO_INFORMES.md`, `docs/03_datos/REGLAS_NEGOCIO.md`, `docs/04_api/CONTRATO_API.md` |

---

## Contexto

LexPenal produce análisis jurídicos estructurados en herramientas del
expediente (hechos, prueba, tipicidad, riesgos, estrategia, conclusión).
Ese análisis necesita materializarse en documentos exportables que
puedan entregarse al cliente, usarse en supervisión académica y
quedar registrados como evidencia del trabajo realizado.

Se deben resolver dos decisiones relacionadas pero distintas:

1. **¿Dónde se generan los informes?** — ¿en el frontend o en el backend?
2. **¿Los informes son la salida principal del sistema o son un complemento?**

---

## Opciones evaluadas

### Pregunta 1 — ¿Dónde se generan los informes?

#### Opción 1A — Generación en el backend

El backend expone `POST /api/v1/cases/{id}/reports` con el tipo de informe
solicitado. El motor de plantillas, la exportación a PDF y DOCX,
y el almacenamiento del archivo residen completamente en el servidor.
El frontend solo solicita y descarga.

**Ventajas**
- El motor de plantillas tiene acceso directo al modelo de datos
  completo — puede consultar cualquier tabla sin depender de lo
  que el frontend haya cargado.
- La generación queda registrada centralmente en `informes_generados`
  con metadatos completos: tipo, caso, usuario, fecha, versión del
  estado (RN-INF-02).
- Las validaciones de precondición (checklist completo para
  `conclusion_operativa`, revisión formal para `revision_supervisor`)
  se aplican en el mismo lugar que la lógica de negocio — no en el
  cliente (RN-INF-03, RN-INF-04).
- El archivo generado puede almacenarse en el servidor y recuperarse
  sin regeneración.
- Sin dependencia de capacidades del navegador para generación de
  documentos complejos.

**Desventajas**
- Mayor carga en el servidor en generaciones simultáneas.
- Requiere librerías de generación de documentos en el backend
  (PDF, DOCX).

#### Opción 1B — Generación en el frontend

El frontend recibe los datos del caso vía API y genera el informe
directamente en el navegador usando librerías de cliente.

**Ventajas**
- Sin carga adicional en el servidor.
- El resultado es inmediato en el navegador.

**Desventajas**
- El frontend no tiene acceso al modelo de datos completo — solo
  a lo que el backend haya expuesto en sus endpoints.
- La validación de precondiciones debe replicarse en el cliente —
  fuente de inconsistencias.
- El registro de generación en `informes_generados` requiere una
  llamada adicional al backend — la generación y el registro
  pueden desacoplarse si hay error de red.
- Sin control centralizado sobre el formato ni el contenido del
  informe — dos usuarios pueden obtener versiones distintas del
  mismo informe según el estado de la interfaz.
- Las librerías de generación de PDF/DOCX en el navegador tienen
  capacidades más limitadas que las del servidor.

---

### Pregunta 2 — ¿Los informes son la salida principal o un complemento?

#### Opción 2A — Los informes son la salida central del sistema

El sistema se diseña con los informes como producto final
explícito. Hay un catálogo formal de tipos, cada uno con
precondiciones, permisos por estado y por perfil, y registro
obligatorio. El análisis del expediente tiene sentido en la
medida en que culmina en informes exportables.

**Ventajas**
- El sistema tiene un propósito tangible y medible: producir
  documentos jurídicos de calidad.
- El catálogo formal de informes permite definir con precisión
  qué puede generar quién y en qué momento del proceso.
- La supervisión académica se materializa en un informe de
  revisión del supervisor — no en notas informales.
- La entrega al cliente tiene un formato estandarizado.

**Desventajas**
- Mayor complejidad en la definición y mantenimiento del
  catálogo de informes.
- Las precondiciones de generación deben mantenerse sincronizadas
  con la máquina de estados (ADR-003).

#### Opción 2B — Los informes son un complemento de exportación

El sistema se centra en la gestión del caso. Los informes son
una función auxiliar de exportación sin catálogo formal.

**Ventajas**
- Menor complejidad de implementación inicial.

**Desventajas**
- Sin trazabilidad de qué se entregó al cliente y en qué momento.
- Sin diferenciación de permisos por tipo de informe.
- La supervisión académica pierde su soporte documental estructurado.
- El sistema carece de producto tangible verificable.

---

## Criterios de decisión

| Criterio | Backend | Frontend |
|---|---|---|
| Acceso al modelo completo | ✅ Directo | ⚠️ Limitado a endpoints |
| Registro centralizado | ✅ Garantizado | ⚠️ Requiere llamada adicional |
| Validación de precondiciones | ✅ En capa de negocio | ❌ Replicada en cliente |
| Control de formato | ✅ Centralizado | ❌ Dependiente del navegador |
| Capacidad PDF/DOCX | Alta | Limitada |
| Carga en servidor | Media | Ninguna |

---

## Decisión

> **[x] Opción 1A — Generación en el backend**
> **[x] Opción 2A — Los informes son la salida central del sistema**

**Justificación**: La generación en el backend es la única opción
que garantiza consistencia entre el análisis del expediente y el
documento producido, registro trazable obligatorio, y validación
de precondiciones en la capa correcta. Los informes como salida
central del sistema no es solo una decisión técnica — es una
decisión de producto: los informes constituyen la materialización
verificable y trazable del análisis jurídico del expediente.

---

## Consecuencias

- El endpoint `POST /api/v1/cases/{id}/reports` es el único punto de
  generación de informes. El frontend nunca genera documentos
  localmente (RN-INF-01).
- El catálogo formal define 7 tipos de informe: `resumen_ejecutivo`,
  `conclusion_operativa`, `control_calidad`, `riesgos`,
  `cronologico`, `revision_supervisor`, `agenda_vencimientos`.
  Cada uno tiene estados habilitados y permisos por perfil definidos
  en `CATALOGO_INFORMES.md`.
- `conclusion_operativa` requiere estado `aprobado_supervisor` o posterior,
  y checklist sin bloques críticos incompletos (RN-INF-03).
  `revision_supervisor` requiere que exista una revisión formal registrada
  en el sistema — no necesariamente estado `aprobado_supervisor`, ya que
  el informe puede generarse también cuando el caso fue devuelto (RN-INF-04).
- Toda generación produce un registro inmutable en
  `informes_generados`: tipo, caso, usuario, fecha, estado del
  caso en el momento de generación (RN-INF-02). La generación
  repetida del mismo tipo de informe para el mismo caso sigue
  la política de idempotencia definida por el módulo de informes.
- Los formatos de exportación son PDF y DOCX. El motor de
  plantillas reside en el backend.
- El catálogo completo, precondiciones, permisos y especificación
  de cada tipo de informe se documentan en `CATALOGO_INFORMES.md`.
