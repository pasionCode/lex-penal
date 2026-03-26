# NOTA DE CIERRE SPRINT 08 — 2026-03-26

## 1. Identificación

- **Proyecto:** LEX_PENAL
- **Fase:** E4 — Consolidación post-MVP
- **Sprint:** Sprint 8
- **Fecha de cierre:** 2026-03-26
- **Estado:** CERRADO

---

## 2. Objetivo del sprint

Corregir los hallazgos prioritarios de E4 que afectan consistencia observable del sistema, especialmente encoding, convención de entrada/salida y alineación entre runtime, DTO y contrato.

**Regla rectora aplicada:** Primero corregir inconsistencias visibles de runtime y contrato; después limpiar deuda interna menor.

---

## 3. Baseline verificado

| Verificación | Estado |
|--------------|--------|
| Repositorio limpio | ✅ `up to date with origin/main` |
| PostgreSQL operativo | ✅ Prisma conecta |
| Migraciones | ✅ `Database schema is up to date!` |
| Build | ✅ `npm run build` exitoso |
| Arranque | ✅ Servidor operativo en puerto 3001 |
| Login operativo | ✅ Token JWT obtenido |

---

## 4. Correcciones aplicadas

### 4.1 BUG-001 / DT-002 — Encoding UTF-8

**Problema:** Campo `etapa_procesal` mostraba caracteres corruptos (`Investigaci�n`).

**Diagnóstico:** El dato estaba corrupto en la base de datos, no en el transporte HTTP.

**Solución aplicada:** 
- Corregido dato corrupto vía Prisma Studio
- Homologados valores de `etapa_procesal` sin tildes para evitar recurrencia

**Verificación:**
```
Antes:  "etapa_procesal":"Investigaci�n"
Después: "etapa_procesal":"Investigacion"
```

**Estado:** ✅ Cerrado

---

### 4.2 H-006 — Convención HerramientaIA

**Problema:** Inconsistencia entre contrato API (kebab-case: `basic-info`) y DTO/runtime (snake_case: `basic_info`).

**Decisión:** Se confirma `snake_case` como convención oficial del campo `herramienta`, por estar ya implementado en DTO y runtime.

**Cambios aplicados al contrato (`CONTRATO_API_v4.md`):**
- Ejemplo corregido: `"herramienta": "matriz_probatoria"` → `"herramienta": "basic_info"`
- Valores válidos: `basic-info`, `client-briefing` → `basic_info`, `client_briefing`
- Agregada nota de consistencia explicando diferencia entre rutas HTTP (kebab-case) y campo JSON (snake_case)

**Verificación:**
```bash
# Prueba positiva (snake_case)
POST /ai/query {"herramienta":"basic_info"} → 200 OK

# Prueba negativa (kebab-case)
POST /ai/query {"herramienta":"basic-info"} → 400 Bad Request
```

**Estado:** ✅ Cerrado

---

## 5. Pruebas de regresión

| Módulo | Endpoint | Resultado |
|--------|----------|-----------|
| cases | GET /cases | ✅ 3 casos listados |
| timeline | GET /cases/{id}/timeline | ✅ 2 eventos devueltos |
| review | GET /cases/{id}/review | ✅ 2 revisiones devueltas |
| reports | GET /cases/{id}/reports | ✅ Tipos de informe correctos |

**Conclusión:** No se observaron regresiones visibles en módulos sensibles.

---

## 6. Artefactos modificados

| Artefacto | Tipo | Cambio |
|-----------|------|--------|
| `docs/04_api/CONTRATO_API_v4.md` | Archivo | Corrección H-006 + nota de consistencia |
| Tabla `Caso`, campo `etapa_procesal` | Dato BD | Registro `c9f0c313-...` corregido vía Prisma Studio |

**Política aplicada a datos:** Valores de `etapa_procesal` homologados sin tildes para evitar problemas de encoding recurrentes.

---

## 7. Commits del sprint

| Hash | Mensaje |
|------|---------|
| 379e6c1 | fix: Sprint 8 (E4) - BUG-001 encoding + H-006 convención IA |

---

## 8. Actualización del Backlog E4

### Items cerrados en Sprint 8

| ID | Descripción | Estado |
|----|-------------|--------|
| BUG-001 | Encoding UTF-8 corrupto | ✅ Cerrado |
| DT-002 | Encoding UTF-8 (mismo issue) | ✅ Cerrado |
| H-006 | HerramientaIA kebab vs snake_case | ✅ Cerrado |

### Items pendientes para Sprint 9

| ID | Descripción | Prioridad |
|----|-------------|-----------|
| H-007 | 12 enums duplicados | Media |
| H-004 | `RolesGuard` stub no implementado | Media |
| H-008 | `TransitionCaseDto` código muerto | Media |
| DT-001 | Unificar `message` vs `mensaje` | Media |
| DT-008 | Encoding UTF-8 respuesta AI | Media |
| H-002 | `/proceedings` en contrato, NO implementado | Media |

### Items fuera de alcance E4

| ID | Descripción | Destino |
|----|-------------|---------|
| H-003 | Actuacion y Documento sin endpoints | Fase 2 |
| DT-007 | AI module simplificado | Fase 2 |
| H-005 | HttpExceptionFilter campos extra | Evaluar en Sprint 9 |

---

## 9. Criterios de cierre cumplidos

- [x] Bug de encoding corregido en ejecución real
- [x] Convención oficial de IA cerrada y única (snake_case)
- [x] Contrato y runtime alineados
- [x] No se introdujo regresión visible
- [x] Backlog E4 actualizado

---

## 10. Decisión de continuidad

**Sprint 8 cerrado satisfactoriamente.**

Los hallazgos de prioridad alta quedaron resueltos. Los items de prioridad media pueden abordarse en Sprint 9 (consolidación) o reclasificarse según necesidad.

**Recomendación:** Proceder a Sprint 9 enfocado en limpieza de código (enums duplicados, código muerto) y consistencia de mensajes de error.

---

**Sprint 08 CERRADO — 2026-03-26**
