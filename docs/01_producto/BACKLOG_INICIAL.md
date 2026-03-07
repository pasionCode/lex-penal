# Backlog inicial — LexPenal MVP

| Campo | Valor |
|---|---|
| Versión | 1.0 |
| Fecha | 2026-03-06 |
| Estado | Vigente |
| Documentos relacionados | `docs/00_gobierno/ALCANCE_PROYECTO.md`, `docs/01_producto/VISION_PRODUCTO.md`, `docs/03_datos/REGLAS_NEGOCIO.md` |

---

## Convenciones

**Prioridad**
- `P0` — Bloqueante. Sin esto el sistema no es operable.
- `P1` — Esencial. Define el valor central del MVP.
- `P2` — Importante. Completa el MVP pero no lo bloquea.
- `P3` — Deseable. Puede diferirse a una iteración posterior.

**Estado**
- `Pendiente` — No iniciado.
- `En progreso` — En desarrollo activo.
- `Completado` — Implementado y validado.

**Épicas**
- E1 — Autenticación y usuarios
- E2 — Gestión del caso
- E3 — Herramientas del expediente
- E4 — Revisión del supervisor
- E5 — Módulo de IA
- E6 — Motor de informes
- E7 — Auditoría y trazabilidad
- E8 — Infraestructura y despliegue

---

## E1 — Autenticación y usuarios

| ID | Historia | Prioridad | Estado | Reglas relacionadas |
|---|---|---|---|---|
| U-01 | Como usuario, quiero iniciar sesión con email y contraseña para acceder al sistema. | P0 | Pendiente | ADR-007 |
| U-02 | Como usuario, quiero que mi sesión se cierre automáticamente al expirar el token para proteger el caso. | P0 | Pendiente | ADR-007, RN-USR-06 |
| U-03 | Como administrador, quiero crear usuarios con perfil asignado para gestionar el acceso al sistema. | P0 | Pendiente | RN-USR-01, RN-USR-03 |
| U-04 | Como administrador, quiero activar y desactivar usuarios para controlar el acceso sin borrar registros históricos. | P1 | Pendiente | RN-USR-06 |
| U-05 | Como administrador, quiero cambiar el perfil de un usuario para ajustar sus permisos sin crear una cuenta nueva. | P1 | Pendiente | RN-USR-03 |
| U-06 | Como estudiante, quiero ver solo los casos donde soy responsable. Como supervisor, quiero ver todos los casos en `pendiente_revision`. Como administrador, quiero ver todos los casos del sistema. | P0 | Pendiente | RN-USR-02 |

---

## E2 — Gestión del caso

| ID | Historia | Prioridad | Estado | Reglas relacionadas |
|---|---|---|---|---|
| C-01 | Como estudiante, quiero crear un caso nuevo con radicado único para iniciar el expediente. | P0 | Pendiente | RN-CAS-01, RN-UNI-03 |
| C-02 | Como estudiante, quiero vincular un cliente al caso para registrar al procesado. | P0 | Pendiente | RN-HER-04 |
| C-03 | Como estudiante, quiero avanzar el caso de `borrador` a `en_analisis` para comenzar el análisis jurídico. | P0 | Pendiente | ADR-003, RN-EST-01 |
| C-04 | Como estudiante, quiero enviar el caso a revisión cuando el análisis esté completo. | P0 | Pendiente | ADR-003, RN-HER-02, RN-HER-03 |
| C-05 | Como estudiante, quiero retomar un caso devuelto en `en_analisis` para corregirlo y reenviarlo. | P0 | Pendiente | ADR-003, RN-EST-04 |
| C-06 | Como supervisor, quiero ver la lista de casos en `pendiente_revision` asignados a mi revisión. | P0 | Pendiente | RN-USR-02 |
| C-07 | Como supervisor, quiero aprobar un caso revisado para avanzarlo a `aprobado_supervisor`. | P0 | Pendiente | ADR-003 |
| C-08 | Como supervisor, quiero devolver un caso con retroalimentación para que el estudiante lo corrija. | P0 | Pendiente | ADR-003, RN-REV-03 |
| C-09 | Como supervisor, quiero marcar un caso como `listo_para_cliente` cuando esté preparado para la entrega. | P1 | Pendiente | ADR-003 |
| C-10 | Como supervisor, quiero cerrar un caso cuando el proceso haya concluido. | P1 | Pendiente | ADR-003 |
| C-11 | Como administrador, quiero ver todos los casos del sistema sin restricción de perfil. | P1 | Pendiente | RN-USR-02 |

---

## E3 — Herramientas del expediente

> **Criterio P0/P1**: son P0 las herramientas que activan guardias de
> transición (RN-HER-02, RN-HER-03) o que son obligatorias para el
> flujo del caso. Es P1 la herramienta sin guardia obligatoria
> (`Explicación al cliente`) — no bloquea ninguna transición del MVP.

| ID | Historia | Prioridad | Estado | Reglas relacionadas |
|---|---|---|---|---|
| H-01 | Como estudiante, quiero diligenciar la Ficha del caso para registrar los datos básicos del expediente. | P0 | Pendiente | RN-HER-01, TRAZABILIDAD_U008 |
| H-02 | Como estudiante, quiero registrar y editar Hechos del caso para construir la narrativa fáctica. | P0 | Pendiente | RN-HER-01, RN-HER-02 |
| H-03 | Como estudiante, quiero registrar las Pruebas del caso con su valor y relación con los hechos. | P0 | Pendiente | RN-HER-01 |
| H-04 | Como estudiante, quiero identificar y registrar Riesgos procesales con probabilidad e impacto. | P0 | Pendiente | RN-HER-01 |
| H-05 | Como estudiante, quiero desarrollar la Estrategia de defensa con línea principal y análisis dogmático. | P0 | Pendiente | RN-HER-01, RN-HER-03 |
| H-06 | Como estudiante, quiero redactar la Explicación al cliente en lenguaje comprensible para el procesado. | P1 | Pendiente | RN-HER-01 |
| H-07 | Como estudiante, quiero diligenciar el Checklist de control de calidad para verificar el análisis. | P0 | Pendiente | RN-HER-01, RN-CHK-01 |
| H-08 | Como estudiante, quiero redactar la Conclusión operativa del caso como síntesis ejecutiva final. | P0 | Pendiente | RN-HER-01 |
| H-09 | Como cualquier usuario, quiero ver las herramientas en modo lectura cuando el caso no está en estado editable. | P0 | Pendiente | RN-HER-01 |
| H-10 | Como supervisor, quiero ver todas las herramientas del caso en modo lectura durante la revisión. | P0 | Pendiente | RN-HER-01 |

---

## E4 — Revisión del supervisor

> **Criterio P0/P1**: son P0 las historias que hacen operable el ciclo
> de revisión — registrar, persistir y ver retroalimentación. El
> historial de revisiones (R-04, R-05) es P1 — útil pero no bloquea
> el flujo del MVP.

| ID | Historia | Prioridad | Estado | Reglas relacionadas |
|---|---|---|---|---|
| R-01 | Como supervisor, quiero registrar observaciones formales por herramienta del expediente. | P0 | Pendiente | RN-REV-01, RN-REV-03 |
| R-02 | Como supervisor, quiero que mis observaciones queden registradas como versión inmutable del caso. | P0 | Pendiente | RN-REV-04, RN-AUD-02 |
| R-03 | Como estudiante, quiero ver la retroalimentación del supervisor por herramienta para entender qué corregir. | P0 | Pendiente | RN-REV-01 |
| R-04 | Como supervisor, quiero ver el historial completo de revisiones anteriores de un caso. | P1 | Pendiente | RN-REV-04 |
| R-05 | Como estudiante, quiero ver el historial de revisiones de mis casos para seguir la evolución del análisis. | P1 | Pendiente | RN-REV-04 |

---

## E5 — Módulo de IA

| ID | Historia | Prioridad | Estado | Reglas relacionadas |
|---|---|---|---|---|
| I-01 | Como estudiante, quiero consultar al asistente de IA desde cada herramienta del expediente para orientar mi análisis. | P1 | Pendiente | RN-IA-01, RN-IA-03 |
| I-02 | Como sistema, debo registrar cada llamada al módulo de IA en el log de auditoría. | P0 | Pendiente | RN-IA-02 |
| I-03 | Como estudiante, quiero que el fallo del módulo de IA no interrumpa mi trabajo en el caso. | P0 | Pendiente | RN-IA-05 |
| I-04 | Como administrador, quiero poder cambiar el proveedor o modelo de IA mediante configuración sin tocar el código. | P2 | Pendiente | RN-IA-04, ADR-004 |

---

## E6 — Motor de informes

| ID | Historia | Prioridad | Estado | Reglas relacionadas |
|---|---|---|---|---|
| IN-01 | Como usuario autorizado, quiero generar el informe `resumen_ejecutivo` del caso en PDF o DOCX. | P0 | Pendiente | RN-INF-01, RN-INF-02 |
| IN-02 | Como supervisor, quiero generar el informe `conclusion_operativa` cuando el caso esté aprobado. | P0 | Pendiente | RN-INF-01, RN-INF-03 |
| IN-03 | Como supervisor, quiero generar el informe `revision_supervisor` cuando exista revisión formal registrada. | P1 | Pendiente | RN-INF-01, RN-INF-04 |
| IN-04 | Como usuario autorizado, quiero generar el informe `riesgos` con la matriz de riesgos del caso. | P1 | Pendiente | RN-INF-01, RN-INF-02 |
| IN-05 | Como usuario autorizado, quiero generar el informe `control_calidad` con el estado del checklist. | P1 | Pendiente | RN-INF-01, RN-INF-02 |
| IN-06 | Como usuario autorizado, quiero generar el informe `cronologico` con el historial de eventos del caso. | P2 | Pendiente | RN-INF-01, RN-INF-02 |
| IN-07 | Como usuario autorizado, quiero generar el informe `agenda_vencimientos` desde cualquier estado activo del caso. | P2 | Pendiente | RN-INF-01, RN-INF-02 |
| IN-08 | Como sistema, debo registrar toda generación de informe con tipo, caso, usuario, fecha y estado del caso. | P0 | Pendiente | RN-INF-02 |

---

## E7 — Auditoría y trazabilidad

| ID | Historia | Prioridad | Estado | Reglas relacionadas |
|---|---|---|---|---|
| A-01 | Como sistema, debo registrar toda transición de estado con usuario, fecha, estado origen y estado destino. | P0 | Pendiente | RN-AUD-01, RN-AUD-02 |
| A-02 | Como sistema, debo registrar login, logout, cambios de perfil y eliminación de casos como eventos de auditoría. | P0 | Pendiente | RN-AUD-03 |
| A-03 | Como administrador, quiero consultar el log de auditoría de un caso para revisar su historial completo. | P1 | Pendiente | RN-AUD-01 |
| A-04 | Como sistema, los registros de auditoría y de IA no deben poder modificarse ni eliminarse bajo ninguna circunstancia. | P0 | Pendiente | RN-AUD-02 |

---

## E8 — Infraestructura y despliegue

| ID | Historia | Prioridad | Estado | Reglas relacionadas |
|---|---|---|---|---|
| D-01 | Como equipo técnico, quiero desplegar el sistema completo en una VM con Ubuntu 24.04 LTS siguiendo el runbook. | P0 | Pendiente | ADR-001, DESPLIEGUE_VM |
| D-02 | Como equipo técnico, quiero que el backup diario de la base de datos se ejecute automáticamente. | P0 | Pendiente | ADR-001, DESPLIEGUE_VM |
| D-03 | Como equipo técnico, quiero que el sistema sirva tráfico HTTPS vía Nginx con certificado válido. | P0 | Pendiente | DESPLIEGUE_VM |
| D-04 | Como equipo técnico, quiero que los procesos de backend y frontend sean gestionados por PM2 con reinicio automático. | P0 | Pendiente | ADR-001, DESPLIEGUE_VM |

---

## Resumen por prioridad

| Prioridad | Total de historias | Épicas principales |
|---|---|---|
| P0 | 29 | E1, E2, E3, E5 (I-02, I-03), E6 (IN-01, IN-02, IN-08), E7, E8 |
| P1 | 12 | E2, E3, E4, E5, E6 |
| P2 | 4 | E4, E6 |
| P3 | 0 | — |

---

## Criterios de aceptación del MVP

El backlog del MVP se considera completado cuando:

1. Un estudiante puede recorrer el flujo completo: crear caso → analizar
   con las 8 herramientas → enviar a revisión → recibir retroalimentación
   → corregir → obtener aprobación.
2. Un supervisor puede revisar, registrar observaciones formales y
   tomar decisión de aprobación o devolución.
3. El sistema genera `resumen_ejecutivo` y `conclusion_operativa`
   en PDF y DOCX con datos reales.
4. Toda transición de estado queda registrada en auditoría.
5. El módulo de IA responde y su fallo no interrumpe el flujo.
6. El sistema opera en producción con HTTPS, PM2 y backup automático.
