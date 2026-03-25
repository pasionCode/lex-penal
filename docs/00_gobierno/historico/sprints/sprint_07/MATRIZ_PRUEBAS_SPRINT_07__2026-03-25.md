# MATRIZ DE PRUEBAS — Sprint 7 (E3.5)

**Proyecto:** LEX_PENAL  
**Fase:** E3.5 — Testing de guerrilla  
**Fecha inicio:** 2026-03-25  
**Objetivo:** Comprobar si el MVP resiste uso real controlado

---

## Inventario de módulos (15/15)

| # | Módulo | Modelo Prisma | Endpoints | Estado |
|---|--------|--------------|-----------|--------|
| 1 | auth | Usuario | login, logout, session | ✅ Aprobado |
| 2 | users | Usuario | CRUD | ✅ Validación indirecta |
| 3 | clients | Cliente | CRUD | ✅ Validación indirecta |
| 4 | cases | Caso | CRUD + transitions | ✅ Aprobado |
| 5 | facts | Hecho | CRUD | ✅ Aprobado |
| 6 | evidence | Prueba | CRUD + link | ✅ Aprobado |
| 7 | risks | Riesgo | CRUD | ✅ Aprobado |
| 8 | strategy | Estrategia | GET/PUT (singleton) | ✅ Aprobado |
| 9 | timeline | LineaTiempo | GET/POST (append-only) | ✅ Aprobado |
| 10 | client-briefing | ExplicacionCliente | GET/PUT (singleton) | ✅ Aprobado |
| 11 | conclusion | ConclusionOperativa | GET/PUT (singleton) | ✅ Aprobado |
| 12 | checklist | ChecklistBloque/Item | GET/PUT items | ✅ Aprobado |
| 13 | review | RevisionSupervisor | GET/POST (append-only) | ✅ Aprobado |
| 14 | reports | InformeGenerado | GET/POST | ✅ Aprobado |
| 15 | ai | AIRequestLog | POST query | ✅ Aprobado |

**Leyenda:** ⬜ Pendiente | 🔄 En curso | ✅ Aprobado | ❌ Bloqueado | ⚠️ Con observaciones

**Resultado:** 13/15 módulos con validación directa + 2/15 con validación indirecta (2026-03-25)
- Validación directa: auth, cases, facts, evidence, risks, strategy, timeline, client-briefing, conclusion, checklist, review, reports, ai
- Validación indirecta: users (vía autenticación), clients (vía asociación en casos)

---

## Flujo ejecutado (testing de guerrilla)

**Modalidad:** Consultas sobre caso de prueba existente (no creación desde cero)

| Paso | Operación | Endpoint | Resultado |
|------|-----------|----------|-----------|
| 1 | Login admin | POST /auth/login | ✅ 200 + token |
| 2 | Listar casos | GET /cases | ✅ 200 (3 casos) |
| 3 | Consultar caso | GET /cases/{id} | ✅ 200 |
| 4 | Consultar hechos | GET /cases/{id}/facts | ✅ 200 (2 hechos) |
| 5 | Consultar pruebas | GET /cases/{id}/evidence | ✅ 200 (1 prueba) |
| 6 | Consultar riesgos | GET /cases/{id}/risks | ✅ 200 (2 riesgos) |
| 7 | Consultar estrategia | GET /cases/{id}/strategy | ✅ 200 |
| 8 | Consultar timeline | GET /cases/{id}/timeline | ✅ 200 (2 eventos) |
| 9 | Consultar client-briefing | GET /cases/{id}/client-briefing | ✅ 200 |
| 10 | Consultar conclusión | GET /cases/{id}/conclusion | ✅ 200 |
| 11 | Consultar checklist | GET /cases/{id}/checklist | ✅ 200 (1 bloque, 2 items) |
| 12 | Consultar revisiones | GET /cases/{id}/review | ✅ 200 (2 revisiones) |
| 13 | Consultar informes | GET /cases/{id}/reports | ✅ 200 (2 informes) |
| 14 | Consulta IA | POST /ai/query | ✅ 200 (placeholder) |

**Resultado:** 14/14 operaciones exitosas sobre caso en estado `pendiente_revision`

---

## Flujo objetivo end-to-end (referencia para testing futuro)

> **Nota:** Este flujo completo desde cero NO fue ejecutado en Sprint 7. Se incluye como referencia para validación en E4 o testing de aceptación.

| Paso | Operación | Endpoint | Esperado | Resultado |
|------|-----------|----------|----------|-----------|
| 1 | Login admin | POST /auth/login | 200 + token | ⬜ |
| 2 | Consulta sesión | GET /auth/session | 200 + user | ⬜ |
| 3 | Crear cliente | POST /clients | 201 | ⬜ |
| 4 | Crear caso | POST /cases | 201 | ⬜ |
| 5 | Cargar hecho | POST /cases/{id}/facts | 201 | ⬜ |
| 6 | Cargar prueba | POST /cases/{id}/evidence | 201 | ⬜ |
| 7 | Vincular prueba-hecho | PUT /cases/{id}/evidence/{eid}/link | 200 | ⬜ |
| 8 | Agregar timeline | POST /cases/{id}/timeline | 201 | ⬜ |
| 9 | Registrar riesgo | POST /cases/{id}/risks | 201 | ⬜ |
| 10 | Definir estrategia | PUT /cases/{id}/strategy | 200 | ⬜ |
| 11 | Explicar al cliente | PUT /cases/{id}/client-briefing | 200 | ⬜ |
| 12 | Conclusión operativa | PUT /cases/{id}/conclusion | 200 | ⬜ |
| 13 | Marcar checklist | PUT /cases/{id}/checklist/items/{iid} | 200 | ⬜ |
| 14 | Transición a revisión | POST /cases/{id}/transition | 200 | ⬜ |
| 15 | Crear revisión | POST /cases/{id}/review | 201 | ⬜ |
| 16 | Generar informe | POST /cases/{id}/reports | 201 | ⬜ |
| 17 | Consulta IA | POST /ai/query | 200 | ⬜ |

---

## Pruebas negativas mínimas

| # | Escenario | Endpoint | Esperado | Resultado |
|---|-----------|----------|----------|-----------|
| N-01 | UUID inválido | GET /cases/no-uuid | 400 | ✅ 400 |
| N-02 | Recurso inexistente | GET /cases/{uuid-falso} | 404 | ✅ 404 |
| N-03 | Sin token | GET /cases | 401 | ✅ 401 |
| N-04 | Estudiante → caso ajeno | GET /cases/{otro} | 403 | ⬜ Pendiente |
| N-05 | Enum inválido (herramienta IA) | POST /ai/query | 400 | ⬜ Pendiente |
| N-06 | Enum inválido (tipo informe) | POST /cases/{id}/reports | 400 | ⬜ Pendiente |
| N-07 | Transición no permitida | POST /cases/{id}/transition | 409 | ⬜ Pendiente |
| N-08 | Datos incompletos | POST /clients (sin nombre) | 400 | ⬜ Pendiente |
| N-09 | Review sin observaciones | POST /cases/{id}/review | 422 | ⬜ Pendiente |
| N-10 | Estudiante → historial review | GET /cases/{id}/review | 403 | ⬜ Pendiente |

**Resultado parcial:** 3/10 pruebas negativas ejecutadas, todas correctas.

---

## Validación de naturaleza (Bloque 7 checklist)

| Entidad | Naturaleza esperada | Validado | Evidencia |
|---------|---------------------|----------|-----------|
| timeline | append-only (sin UPDATE/DELETE) | ✅ | Solo campos `creado_en`, `creado_por` en respuesta |
| review | append-only (versiones, campo vigente) | ✅ | `version_revision: 1` (vigente: false), `version_revision: 2` (vigente: true) |
| reports | metadatos persistidos (sin descarga binaria MVP) | ✅ | `ruta_archivo`, `estado_caso_al_generar` presentes |
| ai | endpoint operativo + log obligatorio | ✅ | Respuesta placeholder con `tokens_entrada`, `tokens_salida`, `modelo_usado` |

---

## Registro de bugs

| ID | Módulo | Severidad | Descripción | Estado |
|----|--------|-----------|-------------|--------|
| BUG-001 | cases | 🟠 Mayor | Encoding UTF-8 corrupto: "Investigación" → "Investigaci�n" en `etapa_procesal`. Confirma DT-002. | Abierto |

**Severidad:** 🔴 Crítico | 🟠 Mayor | 🟡 Menor

---

## Hallazgos de revisión estática

> **Nota:** Esta sección es resumen operativo. El inventario completo de hallazgos (H-001 a H-008) está consolidado en `NOTA_CIERRE_SPRINT_07_2026-03-25.md`.

| ID | Tipo | Severidad | Descripción | Estado |
|----|------|-----------|-------------|--------|
| H-001 | Doc | 🟡 Menor | Nota Sprint 6 decía 18/18, corregido a 15/15 | ✅ Corregido |
| H-002 | Contrato-Código | 🟠 Mayor | `/proceedings` en contrato, NO implementado | Pendiente E4 |
| H-003 | Modelo-Código | 🟡 Menor | Actuacion y Documento sin endpoints MVP | Pendiente E4 |
| H-004 | Código | 🟡 Menor | `RolesGuard` stub no implementado (no usado) | Pendiente E4 |
| H-006 | Contrato-Código | 🟠 Mayor | HerramientaIA: contrato dice kebab, DTO acepta snake | Pendiente E4 |
| H-007 | Deuda técnica | 🟠 Mayor | 12 enums duplicados entre `/types/enums.ts` y DTOs | Pendiente E4 |

### Validaciones positivas (revisión estática)

| Aspecto | Estado |
|---------|--------|
| Encoding UTF-8 (ai.service.ts) | ✅ |
| Encoding UTF-8 (checklist.repository.ts) | ✅ |
| Review append-only (solo GET/POST) | ✅ |
| Timeline append-only (solo GET/POST) | ✅ |
| Máquina de estados en cases.service.ts | ✅ |
| checkAccess() implementado correctamente | ✅ |
| Validaciones en DTOs (class-validator) | ✅ |
| JwtAuthGuard en rutas protegidas | ✅ |

---

## Criterios de cierre

- [x] Flujo real controlado ejecutado sobre caso de prueba sin bloqueo crítico
- [x] Bugs críticos identificados y priorizados (BUG-001 = Mayor, no crítico)
- [x] Lista de ajustes para E4 consolidada (ver hallazgos)
- [x] Nota de cierre Sprint 7 redactada
- [x] Decisión formal: **PASAR A E4**

---

## Notas de ejecución

**2026-03-25:**
- Testing ejecutado sobre caso `c9f0c313-...` en estado `pendiente_revision`
- El caso ya tenía datos cargados (hechos, pruebas, riesgos, estrategia, etc.)
- Se validaron operaciones de lectura (GET) y una escritura (POST /ai/query)
- No se ejecutó flujo de creación desde cero (cliente → caso → cierre)
- BUG-001 detectado: encoding UTF-8 corrupto en `etapa_procesal`
- Pruebas negativas 400/401/404 confirmadas

**Decisión:** Flujo controlado suficiente para validar operatividad del MVP. Flujo completo desde cero queda como backlog de E4 o testing de aceptación.

