# Matriz de roles y permisos

Este documento define los tres perfiles del sistema, sus capacidades generales
y su matriz de permisos sobre módulos, herramientas y transiciones de estado del caso.
Refleja todas las reglas de negocio y decisiones de diseño cerradas sobre
autorización, separación de roles y revisión.

**Documentos relacionados**
- `docs/00_gobierno/adrs/ADR-003-maquina-de-estados-del-caso.md`
- `docs/01_producto/ESTADOS_DEL_CASO.md`
- `docs/03_datos/REGLAS_NEGOCIO.md` — RN-HER-01, RN-REV-01, RN-USR-01..06

| Campo | Valor |
|---|---|
| Última revisión | (completar) |
| Responsable | (completar) |

---

## Perfiles

### Estudiante
Perfil de trabajo directo sobre el expediente. Crea y diligencia los casos
que le son asignados, completa las herramientas operativas de la Unidad 8
y envía el análisis a revisión. Solo ve sus propios casos.
No puede aprobar, devolver ni cerrar casos.
Cuando el caso está en `pendiente_revision`, sus herramientas quedan en
solo lectura hasta que el supervisor actúe. Puede consultar la vista filtrada
de observaciones del supervisor para saber qué corregir si el caso es devuelto.

### Supervisor
Perfil de revisión y gobierno metodológico. Accede a todos los casos del sistema.
Revisa el análisis del estudiante, diligencia el bloque de revisión del caso
y aprueba o devuelve con observaciones escritas obligatorias.
Es el responsable de la calidad del análisis antes de que llegue al cliente.
No crea casos — su rol es exclusivamente de revisión y gobierno metodológico.

**Restricción de autoría**: el supervisor no edita las herramientas de análisis
del expediente. Cuando el caso está en `pendiente_revision`, las herramientas
son de solo lectura también para el supervisor. El supervisor escribe
exclusivamente en el bloque de revisión (`/review`). Esta restricción preserva
la trazabilidad de autoría: el análisis pertenece al responsable del caso,
la revisión pertenece al supervisor.

**Restricción de reapertura**: el supervisor no puede ejecutar la transición
`devuelto → en_analisis`. La reapertura del análisis corresponde al responsable
del caso o al administrador por excepción operativa.

### Administrador
Perfil de gestión del sistema. Gestiona usuarios, perfiles y configuraciones
generales. Tiene los mismos permisos que el supervisor sobre los casos,
más acceso a estadísticas globales, reportes del sistema y configuración
del módulo de IA. Puede ejecutar la transición `devuelto → en_analisis`
por excepción operativa, pero no puede saltarse las reglas de guardia
metodológicas de ninguna transición.

---

## Separación entre autoría y revisión

Esta es la regla de diseño más importante del sistema de roles.

**El análisis pertenece al responsable del caso.**
**La revisión pertenece al supervisor.**

Las dos capas no se mezclan nunca:
- El responsable (estudiante) construye el análisis en las herramientas de la U008.
- El supervisor evalúa ese análisis en el bloque de revisión — sin tocarlo.
- Si el análisis necesita corrección, el supervisor lo devuelve con observaciones.
- El responsable corrige y reenvía. El supervisor vuelve a revisar.

Esta separación garantiza trazabilidad limpia de autoría, responsabilidad
pedagógica y auditoría sin ambigüedad. El sistema la hace cumplir
estructuralmente: no es solo una convención de trabajo.

---

## Matriz de permisos — Módulos y acciones generales

| Acción | Estudiante | Supervisor | Administrador |
|---|---|---|---|
| Crear caso | ✅ | ❌ | ✅ |
| Ver casos asignados | ✅ | — | — |
| Ver todos los casos del sistema | ❌ | ✅ | ✅ |
| Editar herramientas del caso (`en_analisis` o `devuelto`) | ✅ | ❌ | ❌ |
| Editar herramientas en cualquier otro estado | ❌ | ❌ | ❌ |
| Ver checklist del caso propio | ✅ | ✅ | ✅ |
| Ver checklist de cualquier caso del sistema | ❌ | ✅ | ✅ |
| Diligenciar bloque de revisión supervisor | ❌ | ✅ | ✅ |
| Ver observaciones de revisión (vista filtrada) | ✅ (caso propio) | ✅ | ✅ |
| Ver revisión completa con historial de versiones | ❌ | ✅ | ✅ |
| Generar informes del caso propio | ✅ | ✅ | ✅ |
| Generar informes de cualquier caso | ❌ | ✅ | ✅ |
| Eliminar caso | ❌ | ❌ | ✅ |
| Gestionar usuarios | ❌ | ❌ | ✅ |
| Configurar proveedor de IA | ❌ | ❌ | ✅ |
| Ver estadísticas globales del sistema | ❌ | ❌ | ✅ |
| Acceder al módulo de IA (asistente) | ✅ | ✅ | ✅ |

**Notas sobre la matriz:**
- **Supervisor — edición de herramientas**: el supervisor conserva acceso de lectura
  sobre todas las herramientas del expediente. No tiene acceso de escritura.
  La columna ❌ indica que no puede editar — no que no puede ver.
- **Administrador — edición de herramientas**: el administrador gestiona el sistema
  pero no analiza expedientes. La edición de herramientas pertenece exclusivamente
  al responsable del caso. Máxima separación entre gestión y análisis.
- **Supervisor — crear casos**: el supervisor no inicia expedientes. Su rol
  es exclusivamente de revisión y gobierno metodológico.
- **Ver casos asignados**: aplica solo a Estudiante. Supervisor y Administrador
  ven todos los casos del sistema — la fila no aplica para ellos (—).

---

## Matriz de permisos — Herramientas operativas (Unidad 8)

Esta matriz aplica únicamente cuando el caso está en estado `en_analisis`
o `devuelto`. En cualquier otro estado, las herramientas son de solo lectura
para **todos** los perfiles sin excepción.

El bloque de revisión del supervisor es un subrecurso separado del caso
(`/review`). No es una herramienta de la U008 y tiene su propia lógica
de acceso: solo disponible en estado `pendiente_revision`, solo para
Supervisor y Administrador.

| Herramienta | Estudiante | Supervisor | Administrador |
|---|---|---|---|
| Ficha básica | ✅ | ❌ | ❌ |
| Matriz de hechos | ✅ | ❌ | ❌ |
| Matriz probatoria | ✅ | ❌ | ❌ |
| Matriz de riesgos | ✅ | ❌ | ❌ |
| Estrategia de defensa | ✅ | ❌ | ❌ |
| Explicación al cliente | ✅ | ❌ | ❌ |
| Checklist de control de calidad | ✅ | ❌ | ❌ |
| Conclusión operativa | ✅ | ❌ | ❌ |

**Nota**: Supervisor y Administrador conservan acceso de **lectura** sobre
todas las herramientas en cualquier estado. La columna ❌ indica que no pueden
editar — no que no pueden ver. La edición del análisis pertenece exclusivamente
al responsable del caso.

---

## Matriz de permisos — Transiciones de estado del caso

| Transición | Estudiante | Supervisor | Administrador |
|---|---|---|---|
| `borrador` → `en_analisis` | ✅ | ✅ | ✅ |
| `en_analisis` → `pendiente_revision` | ✅ | ✅ | ✅ |
| `pendiente_revision` → `devuelto` | ❌ | ✅ | ✅ |
| `pendiente_revision` → `aprobado_supervisor` | ❌ | ✅ | ✅ |
| `devuelto` → `en_analisis` | ✅ | ❌ | ✅ |
| `aprobado_supervisor` → `listo_para_cliente` | ❌ | ✅ | ✅ |
| `listo_para_cliente` → `cerrado` | ❌ | ✅ | ✅ |

**Nota sobre `devuelto → en_analisis`**: el supervisor no puede ejecutar
esta transición. La reapertura del análisis corresponde al responsable del caso.
El administrador puede hacerlo por excepción operativa documentada.

---

## Reglas generales de autorización

**R-PERM-01** — El backend verifica el perfil del usuario en cada solicitud.
La autorización no se delega al frontend. El frontend refleja el estado
de permisos; no lo gobierna.

**R-PERM-02** — Un estudiante solo puede ver y editar los casos que le han
sido asignados o que él mismo creó. No tiene visibilidad sobre expedientes
de otros usuarios.

**R-PERM-03** — El perfil no puede modificarse por el usuario mismo.
Solo el administrador puede cambiar el perfil de un usuario.

**R-PERM-04** — Los permisos sobre transiciones de estado se aplican después
de verificar las reglas de guardia. El perfil es condición necesaria pero
no suficiente. Un supervisor puede tener permiso para aprobar pero el backend
rechaza con `422` si las guardas no se cumplen.

**R-PERM-05** — El administrador no puede saltarse las reglas de guardia
de las transiciones. Tiene los mismos permisos que el supervisor sobre flujos,
pero las compuertas metodológicas aplican para todos los perfiles sin excepción.

**R-PERM-06** — Ni el supervisor ni el administrador editan herramientas de análisis.
La edición de las herramientas de la U008 pertenece exclusivamente al responsable
del caso (estudiante). El supervisor conserva lectura en todo momento; el
administrador también. Ninguno de los dos puede escribir en el análisis.
Esta regla aplica en todos los estados, incluido `en_analisis` y `devuelto`.
El administrador gestiona el sistema — no analiza expedientes. (RN-HER-01)

**R-PERM-07** — Las observaciones del supervisor son obligatorias en toda revisión,
tanto en aprobación como en devolución. Una revisión sin observaciones escritas
es rechazada por el backend con `422`. Aprobar sin dejar constancia escrita
del criterio no produce una revisión válida. (RN-REV-01)

**R-PERM-08** — El estudiante/responsable accede a las observaciones del supervisor
en vista filtrada (`GET /cases/{id}/review/feedback`), no al historial completo
de revisiones. La vista filtrada incluye: resultado, observaciones vigentes,
fecha de revisión y estado del caso. El historial completo con versionado
es exclusivo de Supervisor y Administrador.
