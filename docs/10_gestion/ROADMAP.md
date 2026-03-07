# Roadmap de ejecución — LexPenal

| Campo | Valor |
|---|---|
| Versión | 1.0 |
| Fecha | 2026-03-06 |
| Estado | Vigente |
| Documentos relacionados | `docs/01_producto/VISION_PRODUCTO.md`, `docs/01_producto/BACKLOG_INICIAL.md`, `docs/00_gobierno/ALCANCE_PROYECTO.md` |

---

## Estado actual

| Campo | Valor |
|---|---|
| Fase activa | Fase 1 — MVP |
| Último hito documental cerrado | Hito 1 — Gobierno y arquitectura |
| Hito operativo en curso | Hito 0 — Saneamiento y esqueleto canónico *(abierto tras detectar desalineación del bootstrap; se ejecuta antes del Hito 2)* |
| Próximo hito | Hito 2 — Modelo de datos, estados y roles |
| ADRs cerrados | ADR-001 al ADR-008 |
| Nota | El bootstrap generó un esqueleto técnico no canónico. Ver `NOTA_GOBIERNO_STACK_CANONICO.md` |

---

## 1. Propósito

Este documento traduce la visión del producto en una secuencia de
ejecución: fases, hitos, entregables, dependencias y criterios de
cierre. No define fechas de calendario — define el orden lógico de
construcción y los requisitos para avanzar de una etapa a la siguiente.

Las fechas y la asignación de sprints corresponden a un documento
posterior (`PLAN_SPRINTS.md`) cuando el equipo entre en planificación
de calendario real.

---

## 2. Relación con la visión del producto

Las fases de este roadmap corresponden directamente a las fases
estratégicas de `VISION_PRODUCTO.md`:

| Fase de ejecución | Fase estratégica | Descripción |
|---|---|---|
| Fase 1 | MVP | Sistema base operativo en consultorio universitario |
| Fase 2 | Consolidación y seguridad | Fortalecimiento técnico y operativo post-MVP |
| Fase 3 | Módulos especiales | Extensiones por tipo de delito penal |
| Fase 4 | Expansión | Multi-consultorio y escalabilidad |

Este documento desarrolla en detalle la Fase 1 (MVP) — las fases
posteriores se describen a nivel de alcance y dependencias, sin
desglose de hitos hasta que la Fase 1 esté cerrada.

---

## 3. Fase 1 — MVP

### Objetivo
Poner en operación un sistema funcional que permita a un consultorio
jurídico universitario gestionar casos de defensa penal con análisis
estructurado, revisión formal del supervisor e informes exportables.

### Alcance
Ver `docs/00_gobierno/ALCANCE_PROYECTO.md` — sección 4 (funcionalidades
incluidas) y sección 5 (exclusiones explícitas).

### Criterio de cierre de fase
- Un estudiante puede recorrer el flujo completo sin intervención técnica.
- Un supervisor puede revisar, aprobar o devolver con retroalimentación formal.
- El sistema genera `resumen_ejecutivo` y `conclusion_operativa` en PDF y DOCX.
- Toda transición de estado queda registrada en auditoría.
- El sistema opera en producción con HTTPS, PM2 y backup automático.
- Al menos un caso real completó el flujo desde `en_analisis` hasta
  `aprobado_supervisor` con trazabilidad íntegra.

---

## 4. Hitos del MVP

### Hito 0 — Saneamiento del bootstrap y esqueleto canónico

**Objetivo**: dejar `src/` y `docs/` en estado limpio y alineado
con los ADRs antes de escribir cualquier código de producción.

**Entregables**
- `NOTA_GOBIERNO_STACK_CANONICO.md` cerrada en `docs/00_gobierno/`.
- Duplicados documentales eliminados según `SANEAMIENTO_DOCS.md`.
- `src/` vaciado o archivado — el código del bootstrap no es canónico.
- Nuevo esqueleto generado con las herramientas correctas:
  - `nest new backend` (NestJS + TypeScript).
  - `create-next-app frontend` (Next.js + App Router + TypeScript).
  - `prisma init` en el backend con `schema.prisma` inicial.
- `MAPA_REPOSITORIO.md` actualizado con ubicaciones canónicas definitivas.

**Criterio de cierre**: `src/backend` es un proyecto NestJS TypeScript
arrancable. `src/frontend` es un proyecto Next.js TypeScript arrancable.
El `schema.prisma` existe aunque esté vacío de modelos. `docs/` no
tiene duplicados activos no canónicos — los históricos archivados en
`Old/` no cuentan como duplicados. El equipo puede abrir cualquier
documento y la ruta que referencia existe y es la correcta.

**Dependencia**: requiere Hito 1 cerrado. ✓ *Cerrado.*

---

### Hito 1 — Gobierno y arquitectura cerrados ✓

**Objetivo**: el equipo tiene todas las decisiones de arquitectura
resueltas y documentadas antes de escribir código de producción.

**Entregables**
- ADR-001 a ADR-008 cerrados.
- `ALCANCE_PROYECTO.md` cerrado.
- `DECISIONES_DE_ARQUITECTURA.md` actualizado.
- `REGLAS_NEGOCIO.md` cerrado.
- `SEGURIDAD_BASE.md` cerrado.
- `CALIDAD_BASE.md` cerrado.

**Criterio de cierre**: no quedan ADRs en estado `Propuesta` con
impacto en la implementación del MVP. El equipo puede iniciar código
sin decisiones de arquitectura pendientes.

---

### Hito 2 — Modelo de datos, estados y roles cerrados

**Objetivo**: la capa de datos está completamente especificada y
puede migrarse a la base de datos sin ambigüedad.

**Entregables**
- `MODELO_DATOS.md` cerrado con todas las tablas, campos y relaciones.
- `ESTADOS_DEL_CASO.md` cerrado con todas las transiciones y guardas.
- `MATRIZ_ROLES_PERMISOS.md` cerrada.
- `TRAZABILIDAD_U008.md` cerrada.
- Esquema Prisma inicial generado y migración aplicada en entorno de desarrollo (ADR-006 cerrado).

**Criterio de cierre**: `prisma migrate dev` sin errores. Todas las
entidades del modelo tienen sus restricciones definidas en el esquema.

**Dependencia**: requiere Hito 1 cerrado.

---

### Hito 3 — Backend base implementado

**Objetivo**: el backend tiene los módulos de autenticación, usuarios,
clientes y gestión del caso operativos con pruebas unitarias.

**Entregables**
- `AuthModule` — login, logout, sesión, JWT (ADR-007).
- `UsersModule` — CRUD de usuarios con perfiles.
- `ClientsModule` — registro de clientes.
- `CasesModule` — creación, listado, detalle y transiciones de estado.
- `CasoEstadoService` — máquina de estados completa con guardas.
- `AuditoriaService` — registro de eventos en toda transición.
- Pruebas unitarias de `CasoEstadoService` con todos los flujos válidos
  e inválidos.
- Contrato API de auth, users, clients y cases verificado contra
  `CONTRATO_API.md`.

**Criterio de cierre**: el flujo `borrador → en_analisis →
pendiente_revision` funciona via API con registro de auditoría.
Perfil `estudiante` no puede ejecutar transiciones de supervisor.

**Dependencia**: requiere Hito 2 cerrado.

---

### Hito 4 — Herramientas del expediente operativas

**Objetivo**: las ocho herramientas operativas del sistema son editables en estados
activos, bloqueadas en estados de solo lectura, y cumplen sus mínimos
de guardia.

**Entregables**
- `HerramientaService` base implementado con verificación de estado.
- Módulos de las 8 herramientas: Ficha, Hechos, Pruebas, Riesgos,
  Estrategia, Explicación al cliente, Checklist, Conclusión.
- `ChecklistService` con cálculo de `completado` por bloque y bloqueo
  de transición por bloque crítico.
- Pruebas unitarias de guardas por herramienta.
- Frontend: formularios de las 8 herramientas en modo edición y
  modo lectura según estado del caso.

**Criterio de cierre**: un estudiante puede diligenciar todas las
herramientas, el checklist bloquea el envío a revisión si hay bloques
críticos incompletos (`422`), y las herramientas quedan en modo
lectura en `pendiente_revision`.

**Dependencia**: requiere Hito 3 cerrado.

---

### Hito 5 — Flujo de revisión del supervisor operativo

**Objetivo**: el supervisor puede revisar, registrar retroalimentación
formal y aprobar o devolver el caso. El estudiante puede ver la
retroalimentación y retomar el caso devuelto.

**Entregables**
- `RevisionSupervisorService` con creación de revisión versionada.
- Endpoints de revisión verificados contra `CONTRATO_API.md`.
- Frontend: panel de revisión para el supervisor.
- Frontend: visualización de retroalimentación por herramienta para
  el estudiante.
- Pruebas de integración del flujo `en_analisis → pendiente_revision
  → aprobado_supervisor` y `pendiente_revision → devuelto → en_analisis`.

**Criterio de cierre**: el flujo completo de revisión funciona
end-to-end con los tres perfiles. Las observaciones del supervisor
quedan registradas como versión inmutable.

**Dependencia**: requiere Hito 4 cerrado.

---

### Hito 6A — Módulo de IA operativo

**Objetivo**: el asistente de IA responde consultas desde cada
herramienta del expediente con registro obligatorio de toda llamada.

**Entregables**
- `IAModule` con `IAProviderAdapter` e `AnthropicAdapter`.
- Endpoint `POST /api/v1/ai/query` con registro en `ai_request_log`.
- Frontend: panel del asistente de IA separado del formulario de herramienta.
- Prueba de fallo del proveedor: retorna `503` sin afectar el caso.

**Criterio de cierre**: fallo del proveedor de IA retorna `503` sin
afectar el flujo del caso. Toda llamada queda registrada en
`ai_request_log`. El frontend no llama al proveedor directamente.

**Dependencia**: requiere Hito 5 cerrado.

---

### Hito 6B — Motor de informes operativo

**Objetivo**: el motor de informes genera los 7 tipos de informe
con sus precondiciones, permisos y registro inmutable.

**Entregables**
- `InformeService` con los 7 tipos de informe y sus precondiciones.
- Generación de PDF y DOCX verificada para `resumen_ejecutivo` y
  `conclusion_operativa`.
- Frontend: botones de generación de informe por tipo con permisos correctos.
- Registro obligatorio de cada informe en `informes_generados`.

**Criterio de cierre**: `conclusion_operativa` no se genera con
checklist incompleto (`422`). Todos los informes quedan registrados.
PDF y DOCX generados con contenido consistente con el expediente y
metadatos de generación correctos.

**Dependencia**: requiere Hito 5 cerrado. Puede avanzarse en paralelo
con Hito 6A.

---

### Hito 7 — Despliegue en VM de producción

**Objetivo**: el sistema está desplegado en el servidor de producción
con HTTPS, PM2, backup automático y seguridad base configurada.

**Entregables**
- VM con Ubuntu 24.04 LTS provisionada.
- Nginx configurado con TLS 1.2/1.3, HSTS y headers de seguridad.
- PM2 gestionando frontend y backend con reinicio automático.
- PostgreSQL con backup diario automatizado a las 02:00.
- Variables de entorno de producción configuradas (nunca en repo).
- UFW con puertos 80, 443 y 22 — resto cerrado.
- Hardening SSH: `PermitRootLogin no`, `PasswordAuthentication no`.
- Certbot con renovación automática de certificado.

**Criterio de cierre**: el sistema responde en HTTPS sin errores.
El backup se ejecuta y puede restaurarse. PM2 reinicia los servicios
tras un reinicio del servidor.

**Dependencia**:
- Funcional: Hito 7 requiere Hitos 6A y 6B cerrados para salida a producción completa.
- Operativa: la preparación de infraestructura (VM, Nginx, UFW, Certbot) puede iniciarse en paralelo desde el Hito 5.

---

### Hito 8 — Pruebas, estabilización y aceptación

**Objetivo**: el sistema cumple todos los criterios de aceptación
técnica y jurídica del MVP con datos reales.

**Entregables**
- Pruebas de integración end-to-end con caso real completo.
- Verificación de auditoría en cada transición del caso real.
- Revisión de logs sin secretos ni tokens expuestos.
- Prueba de restauración de backup.
- Validación del flujo completo por parte del supervisor real del
  consultorio (aceptación funcional).

**Criterio de cierre**: todos los criterios de aceptación de
`CALIDAD_BASE.md` verificados. Al menos un caso real completó el
flujo íntegro. El consultorio da conformidad operativa.

**Dependencia**: requiere Hito 7 cerrado.

---

## 5. Dependencias críticas entre bloques

| Dependencia | Consecuencia si se viola |
|---|---|
| No implementar repositorios sin cerrar ADR-006 (Prisma, cerrado) | Cambio de ORM obliga a reescribir toda la capa de datos |
| No implementar auth sin cerrar ADR-007 (JWT simple, cerrado) | Cambio de estrategia obliga a modificar middleware y cliente |
| No implementar transiciones sin `ESTADOS_DEL_CASO.md` cerrado | Guardas incompletas generan flujos inconsistentes en producción |
| No implementar herramientas sin perfiles cerrados | Permisos incorrectos comprometen la separación supervisor/estudiante |
| No desplegar sin `SEGURIDAD_BASE.md` aplicada | Puertos expuestos, secretos en texto claro, SSL sin configurar |
| No validar informes sin `CATALOGO_INFORMES.md` y `CONTRATO_API.md` cerrados | Precondiciones y permisos incorrectos en generación |
| No usar datos reales sin política de datos ficticios en staging | Exposición de datos de procesados reales en entorno no seguro |

---

## 6. Fases posteriores al MVP

### Fase 2 — Consolidación y seguridad
No se inicia hasta que el Hito 8 esté cerrado y el sistema opere
establemente en producción con usuarios reales. Las decisiones de
esta fase requieren ADR propio para 2FA, contenedores y CI/CD.

### Fase 3 — Módulos especiales
No se inicia hasta que la Fase 2 esté cerrada. Cada módulo especial
(VIF, delitos sexuales, estupefacientes) requiere diseño funcional
propio antes de implementación.

### Fase 4 — Expansión multi-consultorio
Requiere revisión de arquitectura completa — multi-tenancy no está
contemplado en el MVP y su incorporación afecta modelo de datos,
autenticación y despliegue.

---

## 7. Riesgos de ejecución

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Cambio en la plantilla de la U008 durante el desarrollo | Media | Alto — afecta herramientas, checklist y trazabilidad | Congelar la versión U008 de referencia al inicio del Hito 4 |
| Cambio de proveedor de IA durante el MVP | Baja | Medio — el patrón adaptador lo contiene | ADR-004 ya cubre este caso; cambio vía configuración |
| Requisitos de seguridad más estrictos del consultorio | Media | Alto — puede requerir 2FA o cifrado en reposo | Documentar como Fase 2; no bloquea MVP |
| Deuda técnica en la capa de herramientas | Alta | Medio — 8 herramientas con estructuras distintas | `HerramientaService` base reutilizable desde el Hito 4 |
| Fallo del proveedor de IA en demos o validación | Media | Bajo — arquitectura lo aísla | Mock del proveedor para demos controladas |

---

## 8. Decisiones pendientes antes de implementación

| Decisión | Bloquea | Cierra en | Documento |
|---|---|---|---|
| Mínimos formales de Pruebas y Riesgos | Hito 4 — `HerramientaService` | Hito 4 | `CALIDAD_BASE.md` sección 1.3 |
| Política de idempotencia en generación de informes | Hito 6B — `InformeService` | Hito 6B | `ADR-005` consecuencias |
| Política de creación de revisión del supervisor (3 opciones abiertas) | Hito 5 — `RevisionSupervisorService` | Hito 5 | `ARQUITECTURA_BACKEND.md` RI-BACK-09 |
| Política de anonimización de contexto enviado a IA | Antes de usuarios reales | Antes de Hito 8 | `SEGURIDAD_BASE.md` sección 7 |
