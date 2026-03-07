# Decisiones de arquitectura — LexPenal

| Campo | Valor |
|---|---|
| Versión | 1.0 |
| Fecha | 2026-03-06 |
| Estado | Vigente |

Este documento es el índice maestro de todas las decisiones de
arquitectura (ADRs) del proyecto LexPenal. Cada decisión relevante
que afecte la estructura, tecnología, convenciones o límites del
sistema debe quedar registrada en un ADR en `docs/00_gobierno/adrs/`.

---

## Qué es un ADR

Un Architecture Decision Record (ADR) documenta una decisión de
arquitectura significativa: el contexto que la motivó, las opciones
evaluadas, la decisión tomada y sus consecuencias. Los ADRs son
inmutables una vez cerrados — si una decisión cambia, se genera un
nuevo ADR que reemplaza o complementa al anterior, sin modificar
el original.

Un ADR es necesario cuando la decisión:
- afecta a más de una capa del sistema;
- tiene consecuencias difíciles de revertir;
- implica elegir entre opciones técnicas con trade-offs reales;
- establece una convención que el equipo debe sostener en el tiempo.

---

## Registro de decisiones

| ID | Título | Estado | Fecha | Decisión adoptada |
|---|---|---|---|---|
| ADR-001 | Despliegue inicial en máquina virtual propia | Cerrado | 2026-03-06 | VM única con Ubuntu 24.04 LTS, Nginx, PM2 y PostgreSQL en el mismo servidor |
| ADR-002 | PostgreSQL como base de datos relacional | Cerrado | 2026-03-06 | PostgreSQL 16 — modelo relacional con ACID, integridad referencial y soporte JSON nativo |
| ADR-003 | Máquina de estados del caso | Cerrado | 2026-03-06 | Flujo controlado: `borrador` → `en_analisis` → `pendiente_revision` → `aprobado_supervisor` / `devuelto` → `listo_para_cliente` → `cerrado` |
| ADR-004 | Módulo de IA desacoplado del núcleo | Cerrado | 2026-03-06 | Patrón adaptador con `IAProviderAdapter`; proveedor inicial Anthropic; IA no escribe en expediente; fallos no bloquean el caso |
| ADR-005 | Los informes como salida central del sistema | Cerrado | 2026-03-06 | Generación exclusiva en el backend; 7 tipos de informe con precondiciones, permisos por perfil y registro obligatorio |
| ADR-006 | ORM y acceso a datos | Cerrado | 2026-03-06 | Prisma como ORM principal sobre PostgreSQL |
| ADR-007 | Estrategia de autenticación | Cerrado | 2026-03-06 | JWT simple (Opción A): token único de 8h, cookie HttpOnly + Bearer, sin refresh token en MVP |
| ADR-008 | Convención de idioma del sistema | Cerrado | 2026-03-06 | API REST en inglés; dominio, documentación, tablas y UI en español; bilingüismo estructurado por capa |

---

## Efectos principales por ADR

### ADR-001 — Despliegue en VM
Establece el entorno de producción del MVP. Todo lo relacionado con
infraestructura, puertos, servicios y backups se documenta en
`docs/07_infraestructura/DESPLIEGUE_VM.md`. La VM única es un punto
único de falla aceptado formalmente para el MVP.

### ADR-002 — PostgreSQL
Define el motor de base de datos. El modelo completo de datos se
documenta en `docs/03_datos/MODELO_DATOS.md`. Las tablas
`eventos_auditoria` y `ai_request_log` son inmutables por diseño
(solo `INSERT`).

### ADR-003 — Máquina de estados
Define el ciclo de vida del caso. Ninguna transición puede ocurrir
fuera de las definidas. Las reglas de guardia se documentan en
`docs/03_datos/REGLAS_NEGOCIO.md` y `docs/01_producto/ESTADOS_DEL_CASO.md`.

### ADR-004 — Módulo de IA
El módulo de IA opera como capa de asistencia independiente del
núcleo. El proveedor es intercambiable mediante configuración.
La arquitectura completa se documenta en `docs/12_ia/ARQUITECTURA_MODULO_IA.md`.

### ADR-005 — Informes
Los informes son el producto tangible del sistema. La generación
siempre ocurre en el backend vía `POST /api/v1/cases/{id}/reports`.
El catálogo completo se documenta en `docs/11_informes/CATALOGO_INFORMES.md`.

### ADR-006 — ORM
Prisma gestiona el acceso a datos. Las migraciones son obligatorias
para cualquier cambio de esquema — no se aplican cambios manuales
en producción. Actualiza `ARQUITECTURA_BACKEND.md` y `DESPLIEGUE_VM.md`.

### ADR-007 — Autenticación
El sistema usa JWT simple con cookie HttpOnly para el middleware y
Bearer para Client Components. El token no se persiste en
`localStorage` ni `sessionStorage`. Rehidratación vía
`GET /api/v1/auth/session`.

### ADR-008 — Convención de idioma
Define el bilingüismo estructurado del sistema. Toda decisión de
naming futura debe aplicar esta convención. Las excepciones son
restringidas, deben justificarse y registrarse explícitamente.

---

## Cómo agregar un nuevo ADR

1. Crear el archivo en `docs/00_gobierno/adrs/` con el nombre
   `ADR-00N-nombre-descriptivo.md`.
2. Usar la estructura estándar: contexto, opciones evaluadas,
   criterios de decisión, decisión, consecuencias.
3. El estado inicial es `Propuesta`. Al cerrarse, marcar `[x]`
   la opción elegida y completar justificación, decisor y fecha.
4. Actualizar este índice con la nueva entrada.
5. Si el ADR reemplaza uno anterior, referenciarlo explícitamente
   y marcar el ADR anterior como `Reemplazado por ADR-00N`.

---

## Decisiones pendientes

No hay ADRs en estado `Propuesta` al cierre de esta versión.
Los ADRs bloqueantes del MVP han sido resueltos.

> Si surge una nueva decisión de arquitectura, abrirla como ADR
> antes de implementar — no después.
