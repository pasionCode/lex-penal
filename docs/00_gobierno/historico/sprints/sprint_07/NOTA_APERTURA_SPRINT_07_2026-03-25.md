# NOTA DE APERTURA SPRINT 07 — 2026-03-25

## 1. Identificación

- **Proyecto:** LEX_PENAL
- **Fase:** E3.5 — Testing de guerrilla
- **Sprint:** Sprint 7
- **Fecha de apertura:** 2026-03-25
- **Estado:** ABIERTO

## 2. Contexto de entrada

### 2.1 Estado de fases

| Etapa | Estado | Descripción |
|-------|--------|-------------|
| E1 | ✅ CERRADA | Estructuración y línea base canónica |
| E2 | ✅ CERRADA | Gobierno, arquitectura y modelo de datos |
| E3 | ✅ CERRADA | Construcción MVP (Sprints 2-6, 15/15 módulos) |
| E3.5 | 🔄 EN CURSO | Testing de guerrilla (Sprint 7) |
| E4 | ⏳ PENDIENTE | Post-MVP / Consolidación |

### 2.2 MVP completado en E3

15 módulos operativos:

1. auth
2. users
3. clients
4. cases
5. facts
6. evidence
7. risks
8. strategy
9. timeline
10. client-briefing
11. conclusion
12. checklist
13. review
14. reports
15. ai

### 2.3 Deuda técnica arrastrada

| ID | Descripción | Origen |
|----|-------------|--------|
| DT-001 | Unificar `message` vs `mensaje` | Sprint 2 |
| DT-002 | Encoding UTF-8 en bootstrap checklist | Sprint 5 |
| DT-007 | AI module simplificado (removidos context builders) | Sprint 6 |
| DT-008 | Revisar encoding UTF-8 en respuesta placeholder AI | Sprint 6 |

## 3. Objetivo del Sprint 7

**Comprobar si el MVP resiste uso real controlado, no seguir construyéndolo.**

## 4. Regla rectora

> Primero evidencia real, luego ajustes; no nuevas verticales salvo bloqueo crítico.

### 4.1 Permitido

- Correcciones de bug
- Ajustes de validación
- Endurecimiento de reglas
- Mejoras mínimas de trazabilidad

### 4.2 Prohibido

- Nuevas verticales
- Refactors amplios sin evidencia
- Cambios de arquitectura sin incidente real

## 5. Alcance del testing

### 5.1 Flujo crítico end-to-end

Validar recorrido completo desde login hasta consulta IA:

1. Login → sesión
2. Crear cliente → crear caso
3. Cargar hechos → cargar pruebas → vincular
4. Timeline → riesgos → estrategia
5. Explicación cliente → conclusión → checklist
6. Transición a revisión → crear revisión
7. Generar informe → consulta IA

### 5.2 Pruebas negativas mínimas

- UUID inválido (400)
- Recurso inexistente (404)
- Sin autenticación (401)
- Acceso no autorizado (403)
- Enum inválido (400)
- Transición no permitida (409)
- Datos incompletos (400/422)

### 5.3 Coherencia contrato-modelo-ejecución

- Verificar endpoints vs CONTRATO_API_v4
- Verificar comportamientos vs schema.prisma
- Confirmar naturaleza de entidades append-only

## 6. Datos de prueba

| Recurso | Valor |
|---------|-------|
| Admin email | admin@lexpenal.local |
| Admin password | [REDACTED] |
| Estudiante email | estudiante@lexpenal.local |
| Estudiante password | [REDACTED] |
| CASE_ID de prueba | (ver seed de base de datos) |

> **Nota:** Las credenciales reales están en el archivo de seed y variables de entorno del entorno de desarrollo.

## 7. Entregables esperados

- [x] Matriz de pruebas de realidad
- [x] Bitácora de incidencias (consolidada en matriz y cierre)
- [x] Evidencia de ejecución real
- [x] Nota de cierre Sprint 7
- [x] Recomendación formal sobre entrada a E4

## 8. Hallazgos de entrada (revisión estática)

| ID | Tipo | Descripción | Acción |
|----|------|-------------|--------|
| H-001 | Doc | Nota Sprint 6 dice 18/18, debe ser 15/15 | Corregir |
| H-002 | Contrato-Código | `/proceedings` en contrato, NO implementado | Documentar como pendiente post-MVP |
| H-003 | Modelo-Código | Actuacion y Documento sin endpoints MVP | Documentar como pendiente post-MVP |

## 9. Criterios de cierre

- Flujo real controlado ejecutado sobre caso de prueba sin bloqueo crítico
- Bugs críticos identificados y priorizados
- Lista de ajustes para E4 consolidada
- Nota de cierre Sprint 7 redactada
- Decisión formal: pasar a E4 o abrir sprint correctivo

---

**Apertura autorizada:** 2026-03-25

