# BASELINE BACKEND — UNIDAD E5-01

**Fecha:** 2026-03-27  
**Proyecto:** LEX_PENAL  
**Fase:** E5 — Consolidación / expansión controlada  
**Unidad:** E5-01  
**Propósito:** Corte único del estado real del backend

---

## 1. Inventario real del backend

### 1.1 Módulos identificados

| # | Módulo | Ruta | Controller | Service | Repository | DTOs |
|---|--------|------|------------|---------|------------|------|
| 1 | auth | src/modules/auth/ | ✅ | ✅ | — | ✅ |
| 2 | users | src/modules/users/ | ✅ | ✅ | ✅ | ✅ |
| 3 | clients | src/modules/clients/ | ✅ | ⚠️ vacío | ⚠️ vacío | ✅ |
| 4 | cases | src/modules/cases/ | ✅ | ✅ | ✅ | ✅ |
| 5 | facts | src/modules/facts/ | ✅ | ✅ | ✅ | ✅ |
| 6 | evidence | src/modules/evidence/ | ✅ | ✅ | ✅ | ✅ |
| 7 | risks | src/modules/risks/ | ✅ | ✅ | ✅ | ✅ |
| 8 | strategy | src/modules/strategy/ | ✅ | ✅ | ✅ | ✅ |
| 9 | timeline | src/modules/timeline/ | ✅ | ✅ | ✅ | ✅ |
| 10 | subjects | src/modules/subjects/ | ✅ | ✅ | ✅ | ✅ |
| 11 | proceedings | src/modules/proceedings/ | ✅ | ✅ | ✅ | ✅ |
| 12 | documents | src/modules/documents/ | ✅ | ✅ | ✅ | ✅ |
| 13 | checklist | src/modules/checklist/ | ✅ | ✅ | ✅ | ✅ |
| 14 | client-briefing | src/modules/client-briefing/ | ✅ | ✅ | ✅ | ✅ |
| 15 | conclusion | src/modules/conclusion/ | ✅ | ✅ | ✅ | ✅ |
| 16 | review | src/modules/review/ | ✅ | ✅ | ✅ | ✅ |
| 17 | reports | src/modules/reports/ | ✅ | ✅ | ✅ | ✅ |
| 18 | ai | src/modules/ai/ | ✅ | ✅ | ✅ | ✅ |
| 19 | audit | src/modules/audit/ | ✅ | ⚠️ vacío | ⚠️ vacío | ✅ |

**Total:** 19 módulos  
**Con implementación:** 17  
**Solo scaffold:** 2 (clients, audit)

### 1.2 Subrecursos del caso

| Subrecurso | Naturaleza | Endpoints | Política |
|------------|------------|-----------|----------|
| facts | Colección | GET, POST, GET/:id, PUT/:id | CRUD completo |
| evidence | Colección | GET, POST, GET/:id, PUT/:id, PATCH link/unlink | CRUD + vinculación |
| risks | Colección | GET, POST, GET/:id, PUT/:id | CRUD completo |
| subjects | Colección | GET, POST, GET/:id | Append-only |
| proceedings | Colección | GET, POST, GET/:id | Append-only |
| documents | Colección | GET, POST, GET/:id, PUT/:id | CRUD completo |
| timeline | Colección | GET, POST | Append-only |
| strategy | Doc. único | GET, PUT | Lectura/actualización |
| client-briefing | Doc. único | GET, PUT | Lectura/actualización |
| checklist | Doc. único | GET, PUT | Lectura/actualización |
| conclusion | Doc. único | GET, PUT | Lectura/actualización |
| review | Especial | GET historial, POST, GET feedback | Supervisor |
| reports | Especial | GET, POST, GET/:id | Generación |

### 1.3 Modelos Prisma

| # | Modelo | Módulo asociado |
|---|--------|-----------------|
| 1 | Usuario | users |
| 2 | Cliente | clients |
| 3 | Caso | cases |
| 4 | Hecho | facts |
| 5 | Prueba | evidence |
| 6 | Riesgo | risks |
| 7 | Estrategia | strategy |
| 8 | LineaTiempo | timeline |
| 9 | Subject | subjects |
| 10 | Actuacion | proceedings |
| 11 | Documento | documents |
| 12 | ChecklistBloque | checklist |
| 13 | ChecklistItem | checklist |
| 14 | ExplicacionCliente | client-briefing |
| 15 | ConclusionOperativa | conclusion |
| 16 | RevisionSupervisor | review |
| 17 | InformeGenerado | reports |
| 18 | AIRequestLog | ai |
| 19 | EventoAuditoria | audit |

### 1.4 Artefactos transversales

| Artefacto | Ubicación | Estado |
|-----------|-----------|--------|
| JwtAuthGuard | src/modules/auth/guards/ | ✅ Funcional |
| @CurrentUser() | src/modules/auth/decorators/ | ✅ Funcional |
| CasoEstadoService | src/modules/cases/services/ | ✅ Funcional |
| PerfilUsuario enum | src/types/enums.ts | ✅ Funcional |
| EstadoCaso enum | src/types/enums.ts | ✅ Funcional |
| BootstrapService | src/modules/users/ | ✅ Funcional |

---

## 2. Estado por frente

### 2.1 Clasificación

| Estado | Definición |
|--------|------------|
| **Cerrado** | Funcional, probado, documentado, sin deuda sensible |
| **Parcial** | Funcional pero con gaps o sin pruebas completas |
| **Pendiente** | Scaffold presente, sin implementación de negocio |
| **Deuda sensible** | Funcional pero con problemas que afectan operación |

### 2.2 Matriz de estado

| Módulo | Estado | Observación |
|--------|--------|-------------|
| auth | ✅ Cerrado | Login, logout, guards funcionales |
| users | ✅ Cerrado | CRUD + bootstrap admin |
| clients | ⏳ Pendiente | Solo scaffold vacío |
| cases | ✅ Cerrado | CRUD + transición de estado |
| facts | ✅ Cerrado | CRUD completo |
| evidence | ✅ Cerrado | CRUD + link/unlink a hechos |
| risks | ✅ Cerrado | CRUD completo |
| strategy | ⚠️ Parcial | GET/PUT funcional, sin pruebas formales E5 |
| timeline | ⚠️ Parcial | GET/POST funcional, append-only, sin pruebas formales E5 |
| subjects | ✅ Cerrado | S15-S17 completados, paginación y filtros |
| proceedings | ✅ Cerrado | S10-S14 completados, append-only hardened |
| documents | ✅ Cerrado | S12 hardening completado |
| checklist | ⚠️ Parcial | GET/PUT funcional, sin pruebas formales E5 |
| client-briefing | ⚠️ Parcial | GET/PUT funcional, sin pruebas formales E5 |
| conclusion | ⚠️ Parcial | GET/PUT funcional, sin pruebas formales E5 |
| review | ⚠️ Parcial | Lógica implementada, sin pruebas runtime E5 |
| reports | ⚠️ Parcial | MVP placeholder, sin generación real |
| ai | ⚠️ Parcial | MVP placeholder, sin proveedor real |
| audit | ⏳ Pendiente | Solo scaffold vacío |

### 2.3 Resumen por estado

| Estado | Cantidad | Módulos |
|--------|----------|---------|
| ✅ Cerrado | 9 | auth, users, cases, facts, evidence, risks, subjects, proceedings, documents |
| ⚠️ Parcial | 8 | strategy, timeline, checklist, client-briefing, conclusion, review, reports, ai |
| ⏳ Pendiente | 2 | clients, audit |

---

## 3. Base de evidencia

### 3.1 Sprints E5 cerrados — Funcionales

| Sprint | Foco | Módulo | Resultado |
|--------|------|--------|-----------|
| S08 | Hardening proceedings | proceedings | ✅ |
| S09 | Hardening proceedings | proceedings | ✅ |
| S10 | Hardening proceedings | proceedings | ✅ |
| S11 | Hardening documents | documents | ✅ |
| S12 | Hardening documents | documents | ✅ |
| S13 | Append-only proceedings | proceedings | ✅ |
| S14 | Validación proceedings | proceedings | ✅ |
| S15 | Implementación subjects | subjects | ✅ |
| S16 | Paginación subjects | subjects | ✅ |
| S17 | Filtro tipo subjects | subjects | ✅ |
| S18 | Corrección filtro proceedings | proceedings | ✅ |
| S19 | Corrección filtro proceedings | proceedings | ✅ |
| S20 | Corrección filtro proceedings | proceedings | ✅ |
| S21 | Filtro nombre subjects | subjects | ✅ |

### 3.2 Sprints E5 cerrados — Soporte metodológico

| Sprint | Foco | Naturaleza | Resultado |
|--------|------|------------|-----------|
| S22 | Documentación MDS | Gobierno | ✅ |
| S23 | Metodología MDS v2.3 | Gobierno | ✅ |

### 3.3 Notas de cierre consultadas

- `docs/00_gobierno/fases/E5/sprints/sprint_*/NOTA_CIERRE_*.md`
- `docs/00_gobierno/historico/notas/NOTA_CIERRE_*.md`

### 3.4 Contrato API

- Ubicación: `docs/04_api/CONTRATO_API.md`
- Última revisión: 2026-03-27 (Sprint 22)
- Secciones: 10 (Auth, Users, Clients, Cases, Transición, Herramientas, Subjects, Review, Reports, AI, Audit)

---

## 4. Mapa de deuda sensible y bloqueos

### 4.1 Deuda técnica identificada

| ID | Tipo | Descripción | Módulo | Origen | Impacto |
|----|------|-------------|--------|--------|---------|
| BUG-001 | Runtime | Encoding UTF-8 corrupto en respuestas | Transversal | S07 | Medio |
| DT-001 | Código | Métodos update/delete en service/repo no expuestos | proceedings | S13 | Bajo |
| DT-002 | Código | Mensajes de error ruidosos | documents | S12 | Bajo |
| DT-003 | Código | Enums duplicados DTO vs Prisma | subjects | S15 | Bajo |
| DT-004 | Funcional | Sin paginación | timeline | Origen | Medio |
| DT-005 | Funcional | Sin filtros | risks, facts, evidence | Origen | Medio |
| DT-006 | Funcional | Generación real de PDF/DOCX | reports | MVP | Alto |
| DT-007 | Funcional | Integración proveedor IA real | ai | MVP | Alto |
| DT-008 | Funcional | Módulo clients vacío | clients | Origen | Medio |
| DT-009 | Funcional | Módulo audit vacío | audit | Origen | Medio |

### 4.2 Bloqueos identificados

| Bloqueo | Descripción | Módulos afectados | Criticidad |
|---------|-------------|-------------------|------------|
| B-001 | No hay generación real de archivos | reports | Alta para producción |
| B-002 | No hay proveedor IA configurado | ai | Media para MVP |
| B-003 | clients sin implementar | clients | Media |
| B-004 | audit sin implementar | audit | Baja para MVP |

### 4.3 Consistencia documental

| Aspecto | Estado |
|---------|--------|
| Contrato API vs Controllers | ✅ Alineado (post S08-A) |
| Contrato API vs Runtime | ✅ Verificado en sprints |
| Notas de cierre emitidas | ✅ S08-S23 |
| Gobierno MDS v2.3 | ✅ Institucionalizado |

---

## 5. Propuesta de bloques amplios

### 5.1 Bloque A — Núcleo del caso

**Objetivo:** Asegurar que el flujo principal del caso funcione de extremo a extremo.

| Módulo | Acción | Prioridad |
|--------|--------|-----------|
| clients | Implementar CRUD básico | Alta |
| strategy | Pruebas formales | Media |
| timeline | Pruebas formales + paginación | Media |
| checklist | Pruebas formales | Media |
| client-briefing | Pruebas formales | Media |
| conclusion | Pruebas formales | Media |

**Entregable:** Todos los subrecursos del caso probados y cerrados.

### 5.2 Bloque B — Análisis y revisión

**Objetivo:** Completar el ciclo de revisión supervisor y feedback.

| Módulo | Acción | Prioridad |
|--------|--------|-----------|
| review | Pruebas runtime completas | Alta |
| cases/transición | Verificar flujo pendiente_revision → aprobado/devuelto | Alta |
| Integración | Probar ciclo completo estudiante → supervisor → estudiante | Alta |

**Entregable:** Flujo de revisión probado end-to-end.

### 5.3 Bloque C — Salida y transversales

**Objetivo:** Habilitar salidas y cerrar módulos transversales.

| Módulo | Acción | Prioridad |
|--------|--------|-----------|
| reports | Generación real PDF/DOCX | Alta |
| ai | Integración proveedor (o MVP mejorado) | Media |
| audit | Implementar registro de eventos | Baja |
| BUG-001 | Resolver encoding UTF-8 | Media |

**Entregable:** Sistema capaz de generar informes reales.

---

## 6. Priorización

### 6.1 Bloque a abrir primero

**Bloque A — Núcleo del caso**

### 6.2 Justificación

1. **Dependencia estructural:** Sin el núcleo cerrado, B y C no tienen base sólida.
2. **clients es bloqueante:** El modelo `Cliente` existe en Prisma pero el módulo está vacío. Casos reales necesitan clientes.
3. **Subrecursos parciales:** strategy, timeline, checklist, client-briefing, conclusion tienen código pero no pruebas formales E5. Cerrarlos da confianza.
4. **Bajo riesgo:** No requiere integraciones externas (IA, PDF).
5. **Alta visibilidad:** Permite demostrar flujo completo del caso.

### 6.3 Fuera de alcance inmediato

| Ítem | Razón | Cuándo |
|------|-------|--------|
| Generación real de informes | Requiere libs PDF/DOCX | Bloque C |
| Integración IA real | Requiere API keys y diseño | Bloque C |
| Módulo audit | No bloquea MVP | Bloque C |
| BUG-001 encoding | Cosmético, no bloquea | Bloque C |

### 6.4 Orden sugerido dentro de Bloque A

| Paso | Módulo | Alcance |
|------|--------|---------|
| A.1 | clients | Implementar CRUD mínimo |
| A.2 | strategy | Pruebas runtime |
| A.3 | timeline | Pruebas runtime + paginación |
| A.4 | checklist | Pruebas runtime |
| A.5 | client-briefing | Pruebas runtime |
| A.6 | conclusion | Pruebas runtime |
| A.7 | Integración | Smoke test flujo caso completo |

---

## 7. Conclusión

El backend de LEX_PENAL tiene 17 de 19 módulos con implementación. Los micro-sprints E5 consolidaron `proceedings`, `documents` y `subjects`. Quedan 7 módulos en estado parcial que requieren pruebas formales y 2 módulos pendientes de implementación.

El Bloque A es el siguiente paso lógico: cerrar el núcleo del caso antes de abordar revisión (B) o salidas (C).

---

*Baseline generado: 2026-03-27*  
*Unidad E5-01 — Paso 2 completado*
