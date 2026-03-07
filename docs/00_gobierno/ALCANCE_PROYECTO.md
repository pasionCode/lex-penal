# Alcance del proyecto — LexPenal

| Campo | Valor |
|---|---|
| Versión | 1.0 — MVP |
| Fecha | 2026-03-06 |
| Estado | Vigente |
| Documentos relacionados | `docs/00_gobierno/adrs/`, `docs/03_datos/REGLAS_NEGOCIO.md`, `docs/14_legal_funcional/TRAZABILIDAD_U008.md` |

---

## 1. Propósito del sistema

LexPenal es un sistema de gestión y análisis de expedientes de defensa
penal diseñado para consultorios jurídicos de formación universitaria. Permite a estudiantes
de derecho desarrollar análisis jurídico-penal estructurado sobre casos
reales o simulados, bajo supervisión docente formal, con trazabilidad
completa del proceso y producción de informes exportables.

El sistema digitaliza y estructura el flujo de trabajo que actualmente
se gestiona de forma manual o dispersa: registro del caso, análisis
jurídico progresivo, revisión del supervisor, retroalimentación y
entrega al cliente.

---

## 2. Problema que resuelve

Los consultorios jurídicos universitarios enfrentan tres problemas
estructurales en la gestión de sus casos:

**Falta de estructura metodológica uniforme.** El análisis jurídico
varía según el estudiante, el docente o el semestre. No hay una
herramienta que imponga el método de análisis definido por la unidad
académica (U008) como guía vinculante.

**Ausencia de trazabilidad supervisable.** Los supervisores no tienen
visibilidad en tiempo real del estado del análisis ni un mecanismo
formal de revisión y retroalimentación. La supervisión es reactiva,
no sistemática.

**Informalidad en la entrega.** Los documentos que se entregan al
cliente o se archivan como evidencia del trabajo académico no tienen
formato estandarizado ni registro de quién los produjo, cuándo y en
qué estado del caso.

LexPenal resuelve los tres problemas mediante una máquina de estados
que estructura el flujo, un módulo de revisión formal del supervisor
y un motor de informes trazables.

---

## 3. Usuarios del MVP

| Perfil | Rol en el sistema |
|---|---|
| `estudiante` | Crea y desarrolla el análisis jurídico del caso. Opera las ocho herramientas del expediente. Envía a revisión. |
| `supervisor` | Revisa el análisis del estudiante. Aprueba, devuelve con retroalimentación o cierra el caso. No edita el análisis. |
| `administrador` | Gestiona usuarios, perfiles y configuración del sistema. No edita análisis de casos ni aprueba ni devuelve expedientes — su rol es de gobierno del sistema, no de flujo del caso. |

Los tres perfiles coexisten en una instalación del sistema. El perfil
solo lo asigna y modifica el administrador (RN-USR-03).

---

## 4. Funcionalidades incluidas en el MVP

### Gestión del caso
- Creación, edición y seguimiento de casos jurídico-penales.
- Máquina de estados con transiciones controladas por perfil y reglas
  de guardia: `borrador` → `en_analisis` → `pendiente_revision` →
  `aprobado_supervisor` / `devuelto` → `listo_para_cliente` → `cerrado`.
- Radicado único por caso (RN-UNI-03).
- Vinculación de cliente al caso.

### Herramientas operativas del expediente
Las ocho herramientas estructuran el análisis jurídico del caso.
Esta es la nomenclatura oficial del sistema — la que usa el
aplicativo, la API, la UX y la documentación de producto:

1. Ficha
2. Hechos
3. Pruebas
4. Riesgos
5. Estrategia
6. Explicación al cliente
7. Checklist
8. Conclusión

Las ocho herramientas constituyen una traducción operativa de la
metodología de la Unidad 8. La correspondencia exacta entre la
nomenclatura del sistema y la nomenclatura académica de la U008
se documenta en `docs/14_legal_funcional/TRAZABILIDAD_U008.md`.

Cada herramienta es editable solo en estados activos y queda
bloqueada durante revisión (RN-HER-01).

### Checklist de control de calidad
- Verificación estructurada por bloques conforme a la plantilla U008.
- Bloques críticos y no críticos con impacto diferenciado en el flujo.
- El checklist actúa como compuerta funcional del flujo y bloquea
  transiciones cuando existan incumplimientos en bloques críticos.

### Módulo de revisión del supervisor
- El supervisor registra retroalimentación formal por herramienta y
  a nivel general del caso.
- La revisión es versionada e inmutable — no reemplaza, sino que acumula.
- El supervisor aprueba o devuelve. Cuando el caso es devuelto, el
  responsable del caso debe retomarlo en `en_analisis` para corregirlo
  y reenviarlo a revisión. Por excepción, el administrador también puede
  ejecutar esta transición.

### Módulo de IA (asistente jurídico)
- Asistente de análisis jurídico disponible por herramienta.
- Orientativo — no escribe en el expediente (RN-IA-01).
- Toda llamada auditada en `ai_request_log` (RN-IA-02).
- Proveedor configurable sin cambiar código (RN-IA-04).
- Fallo del módulo de IA no bloquea el flujo del caso (RN-IA-05).

### Motor de informes
- 7 tipos de informe exportables en PDF y DOCX.
- Generación exclusiva en el backend con registro obligatorio.
- Cada tipo tiene precondiciones, estados habilitados y permisos por perfil.
- Catálogo completo en `CATALOGO_INFORMES.md`.

### Gestión de usuarios y clientes
- Registro, activación y desactivación de usuarios.
- Asignación de perfiles por administrador.
- Registro de clientes vinculados a casos.

### Auditoría
- Registro inmutable de transiciones de estado, revisiones, generación
  de informes y acciones críticas (RN-AUD-01, RN-AUD-02, RN-AUD-03).

---

## 5. Exclusiones explícitas del MVP

Las siguientes funcionalidades están fuera del alcance del MVP 1.0.
Su inclusión futura requiere decisión formal documentada.

| Exclusión | Motivo |
|---|---|
| Alta disponibilidad y redundancia | Complejidad innecesaria para el volumen del MVP — VM única aceptada formalmente (ADR-001) |
| Contenedores / orquestación (Docker, Kubernetes) | Contemplado para fase posterior al MVP |
| Autenticación de dos factores (2FA) | Fuera del alcance de seguridad del MVP |
| Selección de proveedor de IA por usuario | El proveedor es global a la instalación en MVP (ADR-004) |
| Reapertura de caso cerrado | Requiere ADR posterior — no forma parte del MVP 1.0 |
| Integración con sistemas externos del despacho | Sin especificación de sistemas objetivo en esta fase |
| Pipeline de CI/CD automatizado | Operación manual en MVP |
| Notificaciones automáticas (email, push) | No especificadas en U008 ni en requisitos del MVP |
| Portal del cliente (acceso externo) | Los informes se entregan por canal externo al sistema |
| Multiidioma / internacionalización | El sistema opera en español exclusivamente en MVP |
| Módulos especiales por tipo de delito (VIF, delitos sexuales, estupefacientes) | Reservados para una fase posterior del roadmap. El sistema base debe estar estable antes de incorporar módulos de análisis específico por tipo penal. |

---

## 6. Límites del MVP

**Una sola instalación**: el MVP opera como sistema de un único
consultorio. No hay arquitectura multi-tenant.

**Un solo servidor**: todos los componentes (frontend, backend, base
de datos) corren en una VM única (ADR-001).

**Un solo proveedor de IA activo**: la configuración de IA es global
a la instalación, no por usuario (ADR-004).

**Flujo lineal de caso**: la máquina de estados sigue un flujo
estructurado sin bifurcaciones complejas. La reapertura de casos
cerrados no está contemplada.

**Sin integración de pagos ni facturación**: LexPenal gestiona el
caso jurídico, no la relación económica con el cliente.

---

## 7. Relación con la Unidad 8 (U008)

Las ocho herramientas operativas del expediente corresponden
directamente a los apartados de la Unidad 8 del programa académico.
Esta correspondencia es vinculante: ninguna herramienta puede
eliminarse del sistema sin decisión formal documentada en
`TRAZABILIDAD_U008.md` (RN-HER-05).

El checklist de control de calidad sigue la plantilla de la U008.
Cualquier cambio en la plantilla académica que afecte al sistema
debe gestionarse como un cambio formal en el producto.

La trazabilidad completa entre las reglas del sistema y los
requisitos de la U008 se documenta en `docs/14_legal_funcional/TRAZABILIDAD_U008.md`.

---

## 8. Criterios de éxito del MVP

El MVP se considera exitoso cuando:

1. Un estudiante puede crear un caso, desarrollar las ocho
   herramientas del expediente y enviarlo a revisión sin
   intervención técnica.
2. Un supervisor puede revisar el análisis, registrar
   retroalimentación formal y aprobar o devolver el caso.
3. El sistema genera al menos los informes `resumen_ejecutivo`
   y `conclusion_operativa` en PDF y DOCX con datos reales.
4. Toda transición de estado queda registrada en `eventos_auditoria`
   con usuario, fecha y estado de origen.
5. El módulo de IA responde a consultas por herramienta y su
   fallo no interrumpe el flujo del caso.
6. El sistema opera de forma estable en la VM de producción
   con los tres perfiles de usuario activos simultáneamente.
