# Roles y permisos

Este documento define los tres perfiles del sistema, sus capacidades generales
y su matriz de permisos sobre módulos, herramientas y transiciones de estado del caso.

**ADR de referencia para transiciones**: `docs/00_gobierno/adrs/ADR-003-maquina-de-estados-del-caso.md`

| Campo | Valor |
|---|---|
| Última revisión | (completar) |
| Responsable | (completar) |

---

## Perfiles

### Estudiante
Perfil de trabajo directo sobre el expediente. Crea y diligencia los casos que le son
asignados, completa las herramientas operativas y envía el análisis a revisión.
No puede aprobar, devolver ni cerrar casos.

### Supervisor
Perfil de revisión y gobierno metodológico. Accede a todos los casos del sistema,
revisa el análisis del estudiante, aprueba o devuelve con observaciones, y autoriza
el cierre. Es el responsable de la calidad del producto antes de que llegue al cliente.

### Administrador
Perfil de gestión del sistema. Gestiona usuarios, perfiles y configuraciones generales.
Tiene los mismos permisos que el supervisor sobre los casos, más acceso a estadísticas,
reportes globales y configuración del módulo de IA.

---

## Matriz de permisos — Módulos y acciones generales

| Acción                                      | Estudiante | Supervisor | Administrador |
|---------------------------------------------|-----------|-----------|---------------|
| Crear caso                                  | ✅         | ✅         | ✅             |
| Ver casos propios                           | ✅         | ✅         | ✅             |
| Ver todos los casos del sistema             | ❌         | ✅         | ✅             |
| Editar herramientas del caso (en_analisis)  | ✅         | ✅         | ✅             |
| Editar herramientas fuera de en_analisis    | ❌         | ❌         | ❌             |
| Ver checklist de cualquier caso             | ❌         | ✅         | ✅             |
| Diligenciar bloque de revisión supervisor   | ❌         | ✅         | ✅             |
| Generar informes del caso propio            | ✅         | ✅         | ✅             |
| Generar informes de cualquier caso          | ❌         | ✅         | ✅             |
| Eliminar caso                               | ❌         | ❌         | ✅             |
| Gestionar usuarios                          | ❌         | ❌         | ✅             |
| Configurar proveedor de IA                  | ❌         | ❌         | ✅             |
| Ver estadísticas globales                   | ❌         | ✅         | ✅             |
| Acceder al módulo de IA (asistente)         | ✅         | ✅         | ✅             |

---

## Matriz de permisos — Herramientas operativas (Unidad 8)

Aplica únicamente cuando el caso está en estado `en_analisis` o `devuelto`.
En cualquier otro estado, las herramientas son de solo lectura para todos los perfiles.

| Herramienta                    | Estudiante | Supervisor | Administrador |
|--------------------------------|-----------|-----------|---------------|
| Ficha básica                   | ✅         | ✅         | ✅             |
| Matriz de hechos               | ✅         | ✅         | ✅             |
| Matriz probatoria              | ✅         | ✅         | ✅             |
| Matriz de riesgos              | ✅         | ✅         | ✅             |
| Estrategia de defensa          | ✅         | ✅         | ✅             |
| Explicación al cliente         | ✅         | ✅         | ✅             |
| Checklist de control de calidad| ✅         | ✅         | ✅             |
| Conclusión operativa           | ✅         | ✅         | ✅             |
| Bloque de revisión supervisor  | ❌         | ✅         | ✅             |

---

## Matriz de permisos — Transiciones de estado del caso

| Transición                                   | Estudiante | Supervisor | Administrador |
|----------------------------------------------|-----------|-----------|---------------|
| `borrador` → `en_analisis`                   | ✅         | ✅         | ✅             |
| `en_analisis` → `pendiente_revision`         | ✅         | ✅         | ✅             |
| `pendiente_revision` → `devuelto`            | ❌         | ✅         | ✅             |
| `pendiente_revision` → `aprobado_supervisor` | ❌         | ✅         | ✅             |
| `devuelto` → `en_analisis`                   | ✅         | ✅         | ✅             |
| `aprobado_supervisor` → `listo_para_cliente` | ❌         | ✅         | ✅             |
| `listo_para_cliente` → `cerrado`             | ❌         | ✅         | ✅             |

---

## Reglas generales de autorización

**R-PERM-01** — El backend verifica el perfil del usuario en cada solicitud.
La autorización no se delega al frontend.

**R-PERM-02** — Un estudiante solo puede ver y editar los casos que le han sido
asignados o que él mismo creó. No tiene visibilidad sobre expedientes de otros usuarios.

**R-PERM-03** — El perfil no puede modificarse por el usuario mismo.
Solo el administrador puede cambiar el perfil de un usuario.

**R-PERM-04** — Los permisos sobre transiciones de estado se aplican después
de verificar las reglas de guardia. El perfil es condición necesaria pero no suficiente.

**R-PERM-05** — El administrador no puede saltarse las reglas de guardia
de las transiciones. Tiene los mismos permisos que el supervisor sobre flujos,
pero las compuertas metodológicas aplican para todos los perfiles.
