# AUDITORÍA TÉCNICA DEL SCAFFOLD — LEX_PENAL

## 1. Objeto

Verificar que el scaffold técnico generado en `src/` se encuentre alineado con los documentos canónicos vigentes del proyecto LEX_PENAL, antes de escribir lógica de negocio o continuar con implementación productiva.

La auditoría busca determinar si la base técnica actual es:

- aprovechable sin cambios estructurales mayores;
- aprovechable con correcciones previas puntuales;
- o desalineada en aspectos que exigen saneamiento previo.

---

## 2. Alcance

La presente auditoría comprende exclusivamente la revisión técnica y estructural del scaffold generado, con énfasis en:

- módulos existentes en `src/`;
- organización de controladores, servicios, DTOs y estructura modular;
- correspondencia entre rutas declaradas y contrato API;
- correspondencia entre entidades esperadas y estructura técnica visible;
- correspondencia entre reglas funcionales vinculantes y puntos de implementación esperados;
- correspondencia entre la arquitectura del módulo IA y la estructura realmente generada;
- correspondencia entre ADRs vigentes y stack técnico observado.

---

## 3. Exclusiones

La presente auditoría **no** comprende:

- modificación de archivos;
- ejecución del proyecto;
- compilación;
- pruebas automáticas o manuales de runtime;
- refactorización;
- implementación de lógica de negocio;
- validación del manual editorial o contenido jurídico.

---

## 4. Limitaciones de la auditoría

Esta auditoría fue de naturaleza **estática y estructural**. En consecuencia:

- no verifica compilación exitosa;
- no verifica resolución real de imports;
- no verifica inyección de dependencias en runtime;
- no verifica conexión a base de datos;
- no verifica funcionamiento efectivo de endpoints;
- no verifica cobertura de tests;
- no verifica lógica de negocio implementada.

Los hallazgos se basan en inspección de archivos, no en ejecución.

---

## 5. Fuentes canónicas contrastadas

| Fuente canónica | Ruta | Objeto del contraste |
|---|---|---|
| MODELO_DATOS_v3 | `docs/03_datos/MODELO_DATOS_v3.md` | 18 entidades, campos, tipos, relaciones, reglas de integridad |
| CONTRATO_API_v4 | `docs/04_api/CONTRATO_API_v4.md` | Endpoints, convenciones, códigos de respuesta |
| ARQUITECTURA_MODULO_IA_v3 | `docs/12_ia/ARQUITECTURA_MODULO_IA_v3.md` | Componentes del módulo IA, flujo, políticas |
| REGLAS_FUNCIONALES_VINCULANTES | `docs/14_legal_funcional/REGLAS_FUNCIONALES_VINCULANTES.md` | R01-R09, reglas no negociables |
| ADRs (8 documentos) | `docs/00_gobierno/adrs/` | Decisiones arquitectónicas aprobadas |

---

## 6. Resumen ejecutivo

| Dimensión | Estado |
|---|---|
| Estructura de módulos | ✅ Alineada |
| Endpoints declarados en controllers | ✅ Alineados con contrato (verificación estructural) |
| DTOs muestreados | ✅ Alineados (3 DTOs verificados) |
| Enums | ⚠️ Parcialmente completos |
| Módulo IA (context-builders, prompts) | ✅ Alineado |
| Stack técnico vs ADRs | ⚠️ Parcialmente implementado |
| Schema Prisma | ❌ No existe |
| Módulo de documentos | ⚠️ Decisión pendiente |
| Adaptadores de proveedor IA | ❌ No estructurados |
| Servicios de negocio | ⚠️ Stubs vacíos (esperado en scaffold) |

**Veredicto preliminar**: El scaffold tiene estructura correcta pero requiere completar vacíos críticos antes de implementar lógica de negocio.

---

## 7. Contraste por fuente canónica

### 7.1. MODELO_DATOS_v3

**Pregunta**: ¿El scaffold refleja las 18 entidades del modelo de datos?

| Entidad | Módulo esperado | Módulo encontrado | Estado |
|---|---|---|---|
| `usuarios` | users | ✅ `src/modules/users/` | ALINEADO |
| `clientes` | clients | ✅ `src/modules/clients/` | ALINEADO |
| `casos` | cases | ✅ `src/modules/cases/` | ALINEADO |
| `hechos` | facts | ✅ `src/modules/facts/` | ALINEADO |
| `linea_tiempo` | strategy (timeline) | ✅ `src/modules/strategy/timeline.controller.ts` | ALINEADO |
| `pruebas` | evidence | ✅ `src/modules/evidence/` | ALINEADO |
| `riesgos` | risks | ✅ `src/modules/risks/` | ALINEADO |
| `estrategia` | strategy | ✅ `src/modules/strategy/` | ALINEADO |
| `actuaciones` | strategy (proceedings) | ✅ `src/modules/strategy/strategy.controller.ts` | ALINEADO |
| `explicacion_cliente` | client-briefing | ✅ `src/modules/client-briefing/` | ALINEADO |
| `checklist_bloques` | checklist | ✅ `src/modules/checklist/` | ALINEADO |
| `checklist_items` | checklist | ✅ `src/modules/checklist/` | ALINEADO |
| `conclusion_operativa` | conclusion | ✅ `src/modules/conclusion/` | ALINEADO |
| `revision_supervisor` | review | ✅ `src/modules/review/` | ALINEADO |
| `documentos` | (sin módulo) | ❌ No existe | DECISIÓN PENDIENTE |
| `informes_generados` | reports | ✅ `src/modules/reports/` | ALINEADO |
| `ai_request_log` | ai | ✅ `src/modules/ai/logging/` | ALINEADO |
| `eventos_auditoria` | audit | ✅ `src/modules/audit/` | ALINEADO |

**Lectura**: 17 de 18 entidades tienen correspondencia modular. La entidad `documentos` no tiene módulo asociado, pero esto puede ser una exclusión válida del MVP pendiente de documentar.

---

### 7.2. CONTRATO_API_v4

**Pregunta**: ¿Los endpoints declarados en controllers corresponden al contrato API?

| Recurso | Endpoints esperados | Controller | Estado |
|---|---|---|---|
| Auth | login, logout, session | `src/modules/auth/auth.controller.ts` | ALINEADO |
| Users | CRUD | `src/modules/users/users.controller.ts` | ALINEADO |
| Clients | CRUD | `src/modules/clients/clients.controller.ts` | ALINEADO |
| Cases | CRUD + transition | `src/modules/cases/cases.controller.ts` | ALINEADO |
| Facts | GET, PUT | `src/modules/facts/facts.controller.ts` | ALINEADO |
| Evidence | GET, PUT | `src/modules/evidence/evidence.controller.ts` | ALINEADO |
| Risks | GET, PUT | `src/modules/risks/risks.controller.ts` | ALINEADO |
| Strategy | GET, PUT | `src/modules/strategy/strategy.controller.ts` | ALINEADO |
| Proceedings | CRUD | `src/modules/strategy/strategy.controller.ts` | ALINEADO |
| Timeline | GET, POST | `src/modules/strategy/timeline.controller.ts` | ALINEADO |
| Client-briefing | GET, PUT | `src/modules/client-briefing/client-briefing.controller.ts` | ALINEADO |
| Checklist | GET, PUT | `src/modules/checklist/checklist.controller.ts` | ALINEADO |
| Conclusion | GET, PUT | `src/modules/conclusion/conclusion.controller.ts` | ALINEADO |
| Review | GET, POST, feedback | `src/modules/review/review.controller.ts` | ALINEADO |
| Reports | list, generate, download | `src/modules/reports/reports.controller.ts` | ALINEADO |
| AI | query | `src/modules/ai/ai.controller.ts` | ALINEADO |
| Audit | list por caso | `src/modules/audit/audit.controller.ts` | ALINEADO |

**Nota metodológica**: Esta verificación es estructural. Confirma que los decoradores `@Get`, `@Post`, `@Put`, `@Delete` están declarados con las rutas esperadas. No verifica que los endpoints funcionen en runtime.

---

### 7.3. ARQUITECTURA_MODULO_IA_v3

**Pregunta**: ¿La estructura del módulo `ai/` corresponde a la arquitectura definida?

| Componente esperado | Ubicación esperada | Encontrado | Estado |
|---|---|---|---|
| IAController | `ai.controller.ts` | ✅ `src/modules/ai/ai.controller.ts` | ALINEADO |
| IAService | `ai.service.ts` | ✅ `src/modules/ai/ai.service.ts` | ALINEADO |
| IAContextBuilder (orquestador) | `context-builders/` | ✅ `src/modules/ai/context-builders/ai-context-builder.ts` | ALINEADO |
| 8 context-builders por herramienta | `context-builders/` | ✅ 8 archivos encontrados | ALINEADO |
| 8 prompt-templates | `prompt-templates/` | ✅ 8 archivos .txt encontrados | ALINEADO |
| AIRequestLogRepository | `logging/` | ✅ directorio presente | ALINEADO |
| IAProviderAdapter (interfaz) | `adapters/` | ❌ No existe | FALTANTE |
| AnthropicAdapter | `adapters/` | ❌ No existe | FALTANTE |

**Evidencia de archivos verificados**:
- `src/modules/ai/context-builders/ai-context-builder.ts`
- `src/modules/ai/context-builders/basic-info.context-builder.ts`
- `src/modules/ai/context-builders/facts.context-builder.ts`
- `src/modules/ai/context-builders/evidence.context-builder.ts`
- `src/modules/ai/context-builders/risks.context-builder.ts`
- `src/modules/ai/context-builders/strategy.context-builder.ts`
- `src/modules/ai/context-builders/client-briefing.context-builder.ts`
- `src/modules/ai/context-builders/checklist.context-builder.ts`
- `src/modules/ai/context-builders/conclusion.context-builder.ts`
- `src/modules/ai/prompt-templates/*.txt` (8 archivos)

**Lectura**: La estructura base del módulo IA está correcta. Falta la capa de adaptadores de proveedor exigida por R07.

---

### 7.4. REGLAS_FUNCIONALES_VINCULANTES

**Pregunta**: ¿El scaffold tiene puntos de implementación para las reglas R01-R09?

| Regla | Descripción | Punto de implementación esperado | Estado en scaffold |
|---|---|---|---|
| R01 | Caso es unidad central | FK a `casos` en todas las entidades operativas | Schema Prisma no existe — no verificable |
| R02 | Checklist es compuerta funcional | ChecklistService + validación en transiciones | Stub vacío — pendiente |
| R03 | Conclusión tiene estructura obligatoria | 5 bloques en DTO | ✅ `UpdateConclusionDto` tiene 5 bloques |
| R04 | Revisión del supervisor es paso formal | ReviewService + observaciones obligatorias | Stub vacío — pendiente |
| R05 | IA es asistente, no decisor | Respuesta no escribe en campos del caso | Diseño respetado en arquitectura |
| R06 | Toda acción crítica es auditable | AuditService + registro inmutable | Stub vacío — pendiente |
| R07 | Módulo IA desacoplado por proveedor | Patrón adaptador | ❌ Adaptadores no estructurados |
| R08 | Activar caso genera estructura base | CasoEstadoService | ❌ No definido explícitamente |
| R09 | Caso cerrado es inmutable | Verificación en CasoEstadoService | ❌ No definido explícitamente |

**Lectura**: Las reglas R05 y R03 tienen correspondencia estructural visible. Las reglas R02, R04, R06 dependen de implementación pendiente en servicios. Las reglas R07, R08, R09 tienen vacíos estructurales que deben resolverse antes de implementar.

---

### 7.5. ADRs

**Pregunta**: ¿El stack técnico observado corresponde a las decisiones arquitectónicas aprobadas?

| ADR | Decisión | Observación en scaffold | Estado |
|---|---|---|---|
| ADR-001 | Despliegue inicial en VM | No aplica a scaffold | N/A |
| ADR-002 | PostgreSQL como base relacional | Esperado en schema.prisma | ❌ Schema no existe |
| ADR-003 | Máquina de estados del caso | Esperado en CasoEstadoService | ❌ No estructurado |
| ADR-004 | Módulo IA desacoplado | Esperado patrón adaptador | ❌ Adaptadores no existen |
| ADR-005 | Informes como salida central | Módulo reports existe | ✅ |
| ADR-006 | ORM Prisma para acceso a datos | PrismaModule existe, schema no | ⚠️ Parcial |
| ADR-007 | Estrategia de autenticación | AuthModule existe | ✅ |
| ADR-008 | Convención de idioma (español) | Observado en enums y DTOs | ✅ |

**Lectura**: El scaffold respeta las ADRs en estructura modular, pero ADR-002 (PostgreSQL), ADR-003 (máquina de estados) y ADR-004 (IA desacoplada) requieren completarse antes de implementar.

---

## 8. Matriz de hallazgos

| ID | Módulo / Área | Fuente canónica | Hallazgo | Estado | Clasificación | Prioridad | Evidencia | Acción requerida |
|---|---|---|---|---|---|---|---|---|
| AUD-01 | infrastructure/prisma | MODELO_DATOS_v3, ADR-002, ADR-006 | Schema Prisma no existe | FALTANTE | DEUDA_TECNICA | P1 | `src/infrastructure/database/prisma/` — solo tiene module, service y helper | Generar schema.prisma |
| AUD-02 | cases | ADR-003, R08, R09 | CasoEstadoService no estructurado | FALTANTE | VACIO_DE_DISENO | P1 | `src/modules/cases/cases.service.ts` — stub vacío, sin separación de responsabilidades | Definir estructura y responsabilidades |
| AUD-03 | (sin módulo) | MODELO_DATOS_v3 | Módulo documentos no existe | DECISIÓN PENDIENTE | VACIO_DE_DISENO | P2 | No hay directorio `src/modules/documents/` | Decidir alcance MVP |
| AUD-04 | types | MODELO_DATOS_v3 | Enums faltantes | PARCIALMENTE_ALINEADO | DEUDA_TECNICA | P2 | `src/types/enums.ts` — faltan CategoriaDocumento, TipoEvento | Agregar enums |
| AUD-05 | ai | ARQUITECTURA_MODULO_IA_v3, R07, ADR-004 | Adaptadores de proveedor no estructurados | FALTANTE | VACIO_DE_DISENO | P2 | `src/modules/ai/` — no existe directorio `adapters/` | Crear estructura de adaptadores |
| AUD-06 | legacy_src | N/A | Código legacy no integrado | N/A | CORRECCION_MENOR | P3 | `legacy_src/` — backend, frontend, shared | Evaluar y decidir destino |

---

## 9. Hallazgos consolidados por prioridad

### 9.1. Hallazgos P1 — Bloquean primer vertical

#### AUD-01: Schema Prisma no existe

**Descripción**: No existe archivo `schema.prisma` en el repositorio. Sin este archivo no hay acceso tipado a datos, no se pueden crear migraciones, no se puede conectar a PostgreSQL.

**Evidencia**: 
- `src/infrastructure/database/prisma/prisma.module.ts` — existe
- `src/infrastructure/database/prisma/prisma.service.ts` — existe
- `schema.prisma` — no existe en ninguna ubicación

**Fuentes canónicas afectadas**: MODELO_DATOS_v3, ADR-002, ADR-006

**Criterio de cierre**:
- [ ] `schema.prisma` creado en `prisma/schema.prisma`
- [ ] 18 entidades modeladas según MODELO_DATOS_v3
- [ ] Relaciones y constraints definidos
- [ ] Enums alineados con `src/types/enums.ts`
- [ ] Naming en snake_case validado
- [ ] Listo para `prisma migrate dev`

---

#### AUD-02: CasoEstadoService no estructurado

**Descripción**: Según MODELO_DATOS_v3, REGLAS_FUNCIONALES_VINCULANTES (R08, R09) y ADR-003, debe existir un punto único de control para transiciones de estado del caso. El scaffold tiene `cases.service.ts` como stub vacío sin separación de responsabilidades.

**Evidencia**:
- `src/modules/cases/cases.service.ts` — stub de 512 bytes
- `src/modules/cases/cases.controller.ts` — tiene endpoint `transition` pero delega a `CasesService`

**Fuentes canónicas afectadas**: MODELO_DATOS_v3 (Principio 3), R08, R09, ADR-003

**Criterio de cierre**:
- [ ] Decisión emitida: servicio separado (`CasoEstadoService`) o integrado en `CasesService`
- [ ] Responsabilidades documentadas explícitamente
- [ ] Reglas R08 (generar estructura al activar) y R09 (inmutabilidad en cerrado) mapeadas a métodos
- [ ] Punto único de transición de estado definido
- [ ] Transiciones válidas documentadas según ADR-003

---

### 9.2. Hallazgos P2 — Importantes, no bloquean inmediatamente

#### AUD-03: Módulo documentos no existe

**Descripción**: La entidad `documentos` está definida en MODELO_DATOS_v3 pero no tiene módulo correspondiente. CONTRATO_API_v4 tampoco define endpoints para documentos.

**Naturaleza del hallazgo**: No es necesariamente un error. Puede ser una exclusión válida del MVP que no se documentó formalmente.

**Acción requerida**: Emitir decisión formal:
- Si entra en MVP: crear módulo y definir endpoints
- Si no entra: documentar exclusión en alcance del proyecto

---

#### AUD-04: Enums faltantes

**Descripción**: Faltan enums para campos de entidades existentes en MODELO_DATOS_v3.

**Evidencia**: `src/types/enums.ts` — 17 enums definidos, faltan:
- `CategoriaDocumento`: acusacion, defensa, cliente, actuacion, informe, evidencia, anexo, otro
- `TipoEvento`: transicion_estado, informe_generado, revision_supervisor, login, eliminacion_caso

**Acción requerida**: Agregar enums faltantes.

---

#### AUD-05: Adaptadores de proveedor IA no estructurados

**Descripción**: Según ARQUITECTURA_MODULO_IA_v3 y R07, el módulo IA debe implementar el patrón adaptador. El scaffold no tiene la estructura de adaptadores.

**Evidencia**: 
- `src/modules/ai/` — no existe directorio `adapters/`
- No existe interfaz `IAProviderAdapter`
- No existe `AnthropicAdapter`

**Acción requerida**: Crear `src/modules/ai/adapters/` con interfaz y al menos un adaptador.

---

### 9.3. Hallazgos P3 — Diferibles

#### AUD-06: Código legacy no integrado

**Descripción**: Existe directorio `legacy_src/` con código anterior que no está integrado con el nuevo scaffold.

**Evidencia**: `legacy_src/backend/`, `legacy_src/frontend/`, `legacy_src/shared/`

**Acción requerida**: Evaluar si hay código recuperable o si debe archivarse/eliminarse.

---

## 10. DTOs muestreados

Se verificaron 3 DTOs como muestra representativa:

| DTO | Ruta | Campos verificados | Estado |
|---|---|---|---|
| UpdateFactsDto | `src/modules/facts/dto/update-facts.dto.ts` | orden, descripcion, estado_hecho, fuente, incidencia_juridica | ✅ Alineado |
| UpdateEvidenceDto | `src/modules/evidence/dto/update-evidence.dto.ts` | descripcion, tipo_prueba, hecho_id, hecho_descripcion_libre, licitud, legalidad, suficiencia, credibilidad, posicion_defensiva | ✅ Alineado |
| UpdateConclusionDto | `src/modules/conclusion/dto/update-conclusion.dto.ts` | 5 bloques completos (síntesis jurídica, panorama procesal, dosimetría, opciones, recomendación) | ✅ Alineado |

**Nota metodológica**: No se verificó la totalidad del universo de DTOs. Los 3 DTOs muestreados están alineados con MODELO_DATOS_v3.

---

## 11. Decisión de auditoría

### Decisión

**El scaffold de LEX_PENAL se declara aprovechable con correcciones previas obligatorias.**

No se autoriza implementar lógica de negocio hasta resolver AUD-01 y AUD-02.

### Justificación

El scaffold tiene estructura modular correcta, endpoints declarados alineados con el contrato, DTOs muestreados consistentes con el modelo de datos, y módulo IA con la organización esperada.

Sin embargo, presenta dos vacíos críticos que impiden avanzar:
1. Sin schema.prisma no hay acceso a datos.
2. Sin definición de CasoEstadoService no hay control de la máquina de estados, que es el núcleo funcional del sistema.

### Efecto inmediato

El próximo paso no es implementar el primer vertical, sino:
1. Generar `schema.prisma` desde MODELO_DATOS_v3
2. Definir estructura y responsabilidades de CasoEstadoService

Una vez resueltos, el scaffold queda habilitado para implementación.

---

## 12. Acciones previas obligatorias

Antes de implementar el primer vertical (`auth → users → cases`):

| Orden | Acción | Criterio de cierre | Responsable |
|---|---|---|---|
| 1 | Generar schema.prisma | Ver criterio de cierre AUD-01 | Claude (ejecución) · Paul (aprobación) |
| 2 | Definir CasoEstadoService | Ver criterio de cierre AUD-02 | Claude (propuesta) · Paul (decisión) |

Antes del MVP completo (pueden resolverse en paralelo o después del primer vertical):

| Orden | Acción | Prioridad |
|---|---|---|
| 3 | Decidir alcance de módulo documentos | P2 |
| 4 | Agregar enums faltantes | P2 |
| 5 | Crear estructura de adaptadores IA | P2 |
| 6 | Evaluar legacy_src | P3 |

---

## 13. Control de cambios

**Versión**: 1.2  
**Fecha**: 2026-03-08  
**Estado**: Vigente  
**Naturaleza**: Auditoría técnica de alineación del scaffold  
**Auditor**: Claude (sesión de regularización metodológica)  
**Proyecto**: LEX_PENAL  
**Repositorio auditado**: `github.com/pasionCode/lex-penal` @ commit `c3a3d3e`

### Historial
- **v1.0**: auditoría inicial
- **v1.1**: ajustes metodológicos:
  - precisión en afirmaciones sobre endpoints y DTOs (verificación estructural, no funcional)
  - sección de limitaciones de la auditoría agregada
  - evidencia de archivos en hallazgos
  - hallazgo AUD-03 reformulado como "decisión pendiente" no "error"
  - sección de contraste contra ADRs agregada
  - criterios de cierre exactos para AUD-01 y AUD-02
  - decisión de auditoría explícita con efectos inmediatos
- **v1.2**: ajustes de trazabilidad:
  - referencia a commit específico (`c3a3d3e`) en lugar de rama
  - responsables asignados a acciones 1 y 2 de sección 12
