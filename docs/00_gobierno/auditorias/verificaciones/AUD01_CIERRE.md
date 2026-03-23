# VERIFICACIÓN DE CIERRE — AUD-01

## Hallazgo original

**ID**: AUD-01  
**Descripción**: Schema Prisma no existe  
**Prioridad**: P1  
**Estado anterior**: FALTANTE

---

## Criterio de cierre definido

| # | Criterio | Estado |
|---|---|---|
| 1 | `schema.prisma` creado en `prisma/schema.prisma` | ✅ |
| 2 | 18 entidades modeladas según MODELO_DATOS_v3 | ✅ |
| 3 | Relaciones y constraints definidos | ✅ |
| 4 | Enums alineados con modelo de datos | ✅ |
| 5 | Naming en snake_case validado | ✅ |
| 6 | Listo para `prisma migrate dev` | ⚠️ Pendiente de ejecución |

---

## Evidencia de cumplimiento

### Criterio 1 — Archivo creado

```
prisma/schema.prisma — 758 líneas
```

### Criterio 2 — 18 entidades modeladas

| # | Entidad MODELO_DATOS_v3 | Modelo Prisma | Estado |
|---|---|---|---|
| 1 | usuarios | Usuario | ✅ |
| 2 | clientes | Cliente | ✅ |
| 3 | casos | Caso | ✅ |
| 4 | hechos | Hecho | ✅ |
| 5 | linea_tiempo | LineaTiempo | ✅ |
| 6 | pruebas | Prueba | ✅ |
| 7 | riesgos | Riesgo | ✅ |
| 8 | estrategia | Estrategia | ✅ |
| 9 | actuaciones | Actuacion | ✅ |
| 10 | explicacion_cliente | ExplicacionCliente | ✅ |
| 11 | checklist_bloques | ChecklistBloque | ✅ |
| 12 | checklist_items | ChecklistItem | ✅ |
| 13 | conclusion_operativa | ConclusionOperativa | ✅ |
| 14 | revision_supervisor | RevisionSupervisor | ✅ |
| 15 | documentos | Documento | ✅ |
| 16 | informes_generados | InformeGenerado | ✅ |
| 17 | ai_request_log | AIRequestLog | ✅ |
| 18 | eventos_auditoria | EventoAuditoria | ✅ |

### Criterio 3 — Relaciones y constraints

| Tipo | Cantidad | Ejemplos |
|---|---|---|
| Relaciones FK | 50+ | caso_id, usuario_id, cliente_id, etc. |
| Unique constraints | 7 | radicado, email, [tipo_documento, documento], [caso_id, orden], [caso_id, version_revision], etc. |
| Índices | 25+ | Por caso_id, estado, fecha, etc. |
| Relaciones 1:1 | 4 | estrategia, explicacion_cliente, conclusion_operativa (con caso) |
| Relaciones 1:N | 14 | hechos, pruebas, riesgos, actuaciones, etc. |

### Criterio 4 — Enums alineados

| Enum | Valores | Fuente |
|---|---|---|
| PerfilUsuario | estudiante, supervisor, administrador | MODELO_DATOS_v3 §1 |
| SituacionLibertad | libre, detenido | MODELO_DATOS_v3 §2 |
| EstadoCaso | 7 valores | MODELO_DATOS_v3 §3 |
| EstadoHecho | acreditado, referido, discutido | MODELO_DATOS_v3 §4 |
| IncidenciaJuridica | 4 valores | MODELO_DATOS_v3 §4 |
| TipoPrueba | 5 valores | MODELO_DATOS_v3 §6 |
| EvaluacionProbatoria | ok, cuestionable, deficiente | MODELO_DATOS_v3 §6 |
| Probabilidad | alta, media, baja | MODELO_DATOS_v3 §7 |
| Impacto | alto, medio, bajo | MODELO_DATOS_v3 §7 |
| Prioridad | critica, alta, media, baja | MODELO_DATOS_v3 §7 |
| EstadoMitigacion | 4 valores | MODELO_DATOS_v3 §7 |
| ResultadoRevision | aprobado, devuelto | MODELO_DATOS_v3 §14 |
| CategoriaDocumento | 8 valores | MODELO_DATOS_v3 §15 |
| TipoInforme | 7 valores | MODELO_DATOS_v3 §16 |
| FormatoInforme | pdf, docx | MODELO_DATOS_v3 §16 |
| EstadoLlamadaIA | exitosa, fallida, timeout | MODELO_DATOS_v3 §17 |
| ResultadoAuditoria | exitoso, rechazado | MODELO_DATOS_v3 §18 |
| TipoEvento | 7 valores | MODELO_DATOS_v3 §18, CONTRATO_API_v4 |
| HerramientaIA | 8 valores | CONTRATO_API_v4 |

**Total**: 19 enums

### Criterio 5 — Naming snake_case

- Todos los `@@map()` usan snake_case: `usuarios`, `clientes`, `casos`, etc.
- Todos los campos usan snake_case: `creado_en`, `actualizado_en`, `caso_id`, etc.
- Consistente con MODELO_DATOS_v3 Principio 4

### Criterio 6 — Listo para migración

El schema está sintácticamente completo. La ejecución de `prisma migrate dev` requiere:
- PostgreSQL corriendo
- Variable `DATABASE_URL` configurada
- Proyecto con dependencias instaladas

Esto se verificará en el siguiente paso (base ejecutable Nest + Prisma).

---

## Ajustes aplicados en revisión

| # | Campo | Antes | Después | Justificación |
|---|---|---|---|---|
| 1 | `EventoAuditoria.tipo_evento` | `String` | `TipoEvento` | Cerrar ajuste de enums |
| 2 | `Caso.estado_anterior` | `String?` | `EstadoCaso?` | Integridad: mismo ciclo de estados |
| 3 | `AIRequestLog.herramienta` | `String` | `HerramientaIA` | 8 herramientas canónicas cerradas |
| 4 | `RevisionSupervisor` | sin constraint | `@@unique([caso_id, version_revision])` | Evitar duplicados de versión |

---

## Anotaciones sobre el schema

### Entidades append-only

Según MODELO_DATOS_v3 Principio 2, las siguientes entidades no tienen `actualizado_en` ni `actualizado_por`:

- LineaTiempo
- RevisionSupervisor
- Documento
- InformeGenerado
- AIRequestLog
- EventoAuditoria

### Reglas de integridad no modelables en Prisma

Las siguientes reglas se validan en código, no en BD:

- RI-01: `estado_actual` solo modificable por CasoEstadoService
- RI-02: Caso cerrado no permite escritura
- RI-03: `ai_request_log` y `eventos_auditoria` son inmutables
- RI-04: Al crear caso, generar checklist, estrategia, explicación, conclusión
- RI-05: `checklist_bloques.completado` es calculado
- Integridad cruzada `Prueba.hecho_id` → mismo caso (validación en HerramientaService)
- Coherencia `ChecklistItem.bloque_id` / `caso_id` (validación aplicativa)

### Índice parcial pendiente

MODELO_DATOS_v3 §14 especifica:
> `UNIQUE (caso_id) WHERE vigente = true` (índice parcial PostgreSQL)

Prisma no soporta índices parciales nativamente. Este constraint se implementará:
- Opción A: Raw SQL en migración
- Opción B: Validación en CasoEstadoService

Decisión pendiente para AUD-02.

---

## Decisión de cierre

**AUD-01 se declara CERRADO** con la siguiente condición:

- El criterio 6 (migración exitosa) se verificará como parte del siguiente paso (base ejecutable).
- Si la migración falla por error en el schema, AUD-01 se reabre.

---

## Control de cambios

**Fecha**: 2026-03-08  
**Responsable ejecución**: Claude  
**Responsable aprobación**: Paul  
**Documento relacionado**: AUDITORIA_SCAFFOLD_LEX_PENAL_v1.2.md

### Historial
- **v1.0**: verificación inicial con 17 enums
- **v1.1**: ajustes de consistencia:
  - agregado enum `TipoEvento` (7 valores)
  - agregado enum `HerramientaIA` (8 valores)
  - `Caso.estado_anterior` cambiado a `EstadoCaso?`
  - `AIRequestLog.herramienta` cambiado a `HerramientaIA`
  - `EventoAuditoria.tipo_evento` cambiado a `TipoEvento`
  - agregado `@@unique([caso_id, version_revision])` en `RevisionSupervisor`
