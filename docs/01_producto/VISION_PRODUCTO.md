# Visión del producto — LexPenal

| Campo | Valor |
|---|---|
| Versión | 1.0 |
| Fecha | 2026-03-06 |
| Estado | Vigente |
| Documentos relacionados | `docs/00_gobierno/ALCANCE_PROYECTO.md`, `docs/01_producto/BACKLOG_INICIAL.md` |

---

## Declaración de visión

LexPenal es el sistema de gestión y análisis de expedientes de defensa
penal para consultorios jurídicos universitarios. Estructura el trabajo
jurídico del estudiante, hace visible el proceso de supervisión docente
y materializa el análisis en documentos trazables y entregables.

El foco inicial es el consultorio jurídico universitario. El modelo
podría extenderse a otros entornos de práctica jurídica supervisada
— clínicas legales, programas de formación continua, despachos con
estructura de mentoría — por decisión formal de producto en fases
posteriores.

En tres frases:

> **Para** estudiantes de derecho en consultorio jurídico universitario
> **que** necesitan desarrollar análisis de defensa penal con método,
> supervisión formal y trazabilidad,
> **LexPenal** es un sistema de gestión de expedientes
> **que** estructura el flujo del caso desde el análisis hasta la entrega,
> **a diferencia de** carpetas físicas, correos o herramientas genéricas,
> **porque** impone el método de la Unidad 8, registra cada decisión y
> produce informes exportables con evidencia del trabajo realizado.

---

## Problema central

Los consultorios jurídicos universitarios operan con herramientas que
no fueron diseñadas para su realidad: carpetas físicas, hojas de cálculo,
correos electrónicos y documentos de texto sin estructura ni trazabilidad.

Eso produce tres problemas concretos:

**Análisis sin método uniforme.** El análisis jurídico varía según el
estudiante o el semestre. No hay una herramienta que imponga la
metodología académica como guía vinculante del trabajo.

**Supervisión sin visibilidad.** El docente no tiene acceso en tiempo
real al estado del análisis. La retroalimentación es informal y no
queda registrada como parte del expediente.

**Entrega sin evidencia.** Los documentos que se presentan al cliente
o se archivan como prueba del trabajo académico no tienen formato
estandarizado, autor registrado ni fecha de producción verificable.

---

## Usuarios

| Perfil | Necesidad principal |
|---|---|
| **Estudiante** | Desarrollar el análisis del caso con método, recibir retroalimentación estructurada del supervisor y producir documentos entregables. |
| **Supervisor / Docente** | Tener visibilidad real del estado de cada caso, registrar retroalimentación formal por herramienta y aprobar o devolver con fundamento escrito. |
| **Administrador** | Gestionar usuarios, perfiles y configuración del sistema sin involucrarse en el análisis jurídico. |

---

## Propuesta de valor

### Para el estudiante
Estructura el análisis jurídico con las ocho herramientas del sistema,
que constituyen la traducción operativa del método académico de la
Unidad 8. La correspondencia detallada se documenta en la matriz de
trazabilidad funcional. Elimina la hoja en blanco — cada herramienta
tiene campos definidos que guían el análisis. El asistente de IA
orienta sin reemplazar el criterio jurídico — no escribe en el
expediente; la autoría del análisis es siempre del estudiante.

### Para el supervisor
Reemplaza la revisión informal por un flujo estructurado: el supervisor
ve el análisis completo, registra observaciones por herramienta y
toma una decisión formal de aprobación o devolución. Todo queda
registrado con fecha y autor.

### Para el consultorio
Trazabilidad completa del trabajo: quién analizó, quién supervisó,
qué se entregó al cliente y cuándo. El sistema es la evidencia del
proceso académico y del servicio jurídico prestado.

---

## Principios del producto

**El análisis es del estudiante, siempre.** La IA orienta pero no
escribe en el expediente. El supervisor revisa pero no edita el
análisis del estudiante. La autoría es trazable e inequívoca.

**El método antes que la flexibilidad.** Las herramientas siguen la
estructura de la Unidad 8. El sistema no permite saltarse pasos ni
modificar la estructura del análisis por preferencia individual.

**La trazabilidad no es opcional.** Cada transición, cada revisión,
cada informe generado queda registrado. No hay acciones sin rastro.

**El fallo no bloquea el flujo.** Si el módulo de IA no responde,
el estudiante sigue trabajando. Si un servicio falla, el caso no se
pierde. La disponibilidad del trabajo es prioritaria.

---

## Roadmap de producto

### MVP — Fase actual

Consultorio jurídico universitario con un grupo de estudiantes,
un supervisor y un administrador. Casos de defensa penal en sistema
acusatorio colombiano.

Funcionalidades: gestión del caso, ocho herramientas de análisis,
checklist de control de calidad, revisión del supervisor, módulo
de IA como asistente, motor de informes con 7 tipos, auditoría completa.

**Criterio de salida del MVP**: el sistema opera de forma estable con
los tres perfiles activos, produce los informes `resumen_ejecutivo`
y `conclusion_operativa` con datos reales, y permite completar el
flujo íntegro desde `en_analisis` hasta `aprobado_supervisor` con
trazabilidad completa en al menos un caso real.

---

### Fase 2 — Consolidación y seguridad

- Autenticación de dos factores (2FA).
- Selección de proveedor de IA por usuario o por instalación configurable.
- Migración a contenedores (Docker) para mayor portabilidad.
- Pipeline de CI/CD para despliegue automatizado.
- Notificaciones internas de cambios de estado — mejora de experiencia,
  no núcleo metodológico; puede diferirse dentro de esta fase.

---

### Fase 3 — Módulos especiales de defensa penal

Módulos de análisis específico por tipo de delito, con herramientas
adaptadas a la dogmática particular de cada área:

- **Violencia intrafamiliar (VIF)**: herramientas adicionales para
  análisis de contexto de violencia, medidas de protección y
  enfoque de género.
- **Delitos sexuales**: protocolo específico de análisis probatorio
  y de victimología.
- **Estupefacientes**: análisis de política criminal, dosis personal
  y teoría del caso en tráfico.

Estos módulos no alteran el núcleo del sistema — se incorporan como
extensiones del análisis base.

---

### Fase 4 — Escalabilidad y multi-consultorio

- Arquitectura multi-tenant para varios consultorios en una misma
  instalación.
- Panel de estadísticas académicas por consultorio.
- Integración con sistemas de gestión académica universitaria.
- Portal de acceso limitado para el cliente del caso.

---

## Lo que LexPenal no es

LexPenal no es un sistema de gestión de despacho comercial. No gestiona
facturación, agenda de audiencias externas, comunicaciones con operadores
judiciales ni expedientes digitales del proceso. Es un sistema de
formación jurídica supervisada con salida en documentos trazables.

Esta distinción debe mantenerse en toda decisión de producto futura.
Las funcionalidades que acerquen el sistema a un ERP jurídico comercial
requieren decisión formal y revisión del alcance del producto.
