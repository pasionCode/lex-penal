# NOTA DE CIERRE SPRINT 07 — 2026-03-25

## 1. Identificación

- **Proyecto:** LEX_PENAL
- **Fase:** E3.5 — Testing de guerrilla
- **Sprint:** Sprint 7
- **Fecha de cierre:** 2026-03-25
- **Estado:** CERRADO

## 2. Objetivo del sprint

Comprobar si el MVP de 15 módulos resiste uso real controlado mediante testing de guerrilla.

**Regla rectora aplicada:** Primero evidencia real, luego ajustes; no nuevas verticales salvo bloqueo crítico.

## 3. Resultados del testing

### 3.1 Flujo positivo — 15/15 módulos operativos

| # | Módulo | Endpoint probado | Resultado |
|---|--------|------------------|-----------|
| 1 | auth | POST /auth/login | ✅ 200 + token JWT |
| 2 | users | (validación indirecta por autenticación y contexto de sesión) | ✅ |
| 3 | clients | (validación indirecta por asociación funcional en casos) | ✅ |
| 4 | cases | GET /cases, GET /cases/:id | ✅ 200 |
| 5 | facts | GET /cases/:id/facts | ✅ 200 (2 hechos) |
| 6 | evidence | GET /cases/:id/evidence | ✅ 200 (1 prueba) |
| 7 | risks | GET /cases/:id/risks | ✅ 200 (2 riesgos) |
| 8 | strategy | GET /cases/:id/strategy | ✅ 200 |
| 9 | timeline | GET /cases/:id/timeline | ✅ 200 (append-only) |
| 10 | client-briefing | GET /cases/:id/client-briefing | ✅ 200 |
| 11 | conclusion | GET /cases/:id/conclusion | ✅ 200 |
| 12 | checklist | GET /cases/:id/checklist | ✅ 200 |
| 13 | review | GET /cases/:id/review | ✅ 200 (versionado) |
| 14 | reports | GET /cases/:id/reports | ✅ 200 (2 informes) |
| 15 | ai | POST /ai/query | ✅ 200 (placeholder) |

### 3.2 Pruebas negativas — 3/3 correctas

| Escenario | Esperado | Obtenido |
|-----------|----------|----------|
| UUID inválido | 400 | ✅ 400 |
| Caso inexistente | 404 | ✅ 404 |
| Sin token | 401 | ✅ 401 |

### 3.3 Validación de naturaleza

| Entidad | Naturaleza | Evidencia |
|---------|------------|-----------|
| timeline | append-only | Solo `creado_en`, `creado_por` — sin campos de actualización |
| review | append-only + versionado | `version_revision` incrementa, `vigente` se actualiza correctamente |
| reports | metadatos persistidos | `ruta_archivo`, `estado_caso_al_generar` presentes |
| ai | log operativo | Respuesta con `tokens_entrada`, `tokens_salida`, `modelo_usado` |

## 4. Bugs encontrados

| ID | Severidad | Descripción | Acción |
|----|-----------|-------------|--------|
| BUG-001 | 🟠 Mayor | Encoding UTF-8 corrupto: "Investigación" → "Investigaci�n" en `etapa_procesal` | Priorizar en E4 |

**Nota:** Confirma DT-002 que estaba pendiente de verificación en runtime.

## 5. Hallazgos de revisión estática

| ID | Tipo | Severidad | Descripción | Acción E4 |
|----|------|-----------|-------------|-----------|
| H-001 | Doc | 🟡 Menor | Nota Sprint 6 decía 18/18 | ✅ Corregido |
| H-002 | Contrato-Código | 🟠 Mayor | `/proceedings` en contrato, NO implementado | Documentar pendiente |
| H-003 | Modelo-Código | 🟡 Menor | Actuacion y Documento sin endpoints MVP | Documentar pendiente |
| H-004 | Código | 🟡 Menor | `RolesGuard` stub no implementado | Eliminar o implementar |
| H-005 | Contrato-Código | 🟡 Menor | Filtro HTTP agrega campos extra (statusCode, path, timestamp) | Evaluar alineación |
| H-006 | Contrato-Código | 🟠 Mayor | HerramientaIA: contrato dice `basic-info`, DTO acepta `basic_info` | Alinear snake_case |
| H-007 | Deuda técnica | 🟠 Mayor | 12 enums duplicados entre `/types/enums.ts` y DTOs | Consolidar en E4 |
| H-008 | Código muerto | 🟡 Menor | `TransitionCaseDto` no se usa | Eliminar |

## 6. Deuda técnica consolidada

| ID | Origen | Descripción | Prioridad E4 |
|----|--------|-------------|--------------|
| DT-001 | Sprint 2 | Unificar `message` vs `mensaje` | Media |
| DT-002 | Sprint 5 | Encoding UTF-8 (confirmado como BUG-001) | **Alta** |
| DT-007 | Sprint 6 | AI module simplificado | Baja (aceptable MVP) |
| DT-008 | Sprint 6 | Encoding UTF-8 respuesta AI | Media |
| H-006 | Sprint 7 | HerramientaIA snake_case vs kebab-case | **Alta** |
| H-007 | Sprint 7 | Enums duplicados | Media |

## 7. Lista de ajustes para E4

### Prioridad Alta
1. **BUG-001 / DT-002:** Resolver encoding UTF-8 en base de datos y respuestas HTTP
2. **H-006:** Alinear HerramientaIA con contrato API (decidir snake_case o kebab-case)

### Prioridad Media
3. **H-007:** Consolidar enums duplicados en ubicación canónica
4. **DT-001:** Unificar nomenclatura de mensajes de error
5. **H-002:** Documentar `/proceedings` como pendiente post-MVP

### Prioridad Baja
6. **H-004:** Eliminar `RolesGuard` stub no usado
7. **H-008:** Eliminar `TransitionCaseDto` código muerto
8. **H-005:** Evaluar alineación de formato de error con contrato

## 8. Decisión de cierre

### Criterios cumplidos

- [x] Flujo real controlado ejecutado sobre caso de prueba sin bloqueo crítico
- [x] 13/15 módulos con validación directa + 2/15 con validación indirecta
- [x] Pruebas negativas 400/401/404 funcionan
- [x] Naturaleza append-only verificada
- [x] Bugs identificados y priorizados (ninguno crítico)
- [x] Lista de ajustes para E4 consolidada

### Recomendación formal

**PASAR A FASE E4** — El MVP resiste uso real controlado.

Los hallazgos encontrados son de severidad Mayor o Menor, no hay bloqueos críticos. El bug de encoding (BUG-001) es el más urgente pero no impide la operación del sistema.

---

## 9. Anexos

### Commits del sprint

| Hash | Mensaje |
|------|---------|
| 9827327 | docs: checklist Sprint 7 (E3.5 testing de guerrilla) |
| (local) | docs: apertura Sprint 7, corrige 15/15, matriz pruebas |

### Datos de prueba utilizados

- Admin: `admin@lexpenal.local`
- CASE_ID: `c9f0c313-1042-42f7-8371-faa89fd84f42`
- Estado del caso: `pendiente_revision`

### Evidencia de ejecución

Archivo: `sprint7_results.txt` (terminal output)

> **Nota de seguridad:** El archivo de evidencia contiene tokens JWT en claro. 
> Antes de archivar en el repositorio, sanitizar reemplazando tokens por `[TOKEN_REDACTED]`.

---

**Sprint 07 CERRADO — 2026-03-25**
**Fase E3.5 COMPLETADA**
**Autorizado paso a Fase E4**
