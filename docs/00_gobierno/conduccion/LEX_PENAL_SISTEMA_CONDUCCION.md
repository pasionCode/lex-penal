# LEX_PENAL — Sistema de Conducción del Proyecto

**Versión:** 1.3  
**Fecha:** 2026-03-23  
**Proyecto:** LEX_PENAL  
**Repositorio:** github.com/pasionCode/lex-penal  
**Rama principal:** main  
**Naturaleza:** Documento de gobierno y conducción operativa

---

## 1. Objeto del documento

El presente documento establece el sistema de conducción del proyecto LEX_PENAL, definiendo de forma explícita y verificable:

- la ruta maestra del proyecto;
- las etapas oficiales con sus criterios de cierre;
- los hitos de control;
- los gates de autorización de paso;
- el cronograma macro con control de desviaciones;
- la ruta crítica y dependencias;
- el estado actual del proyecto;
- las reglas de gobierno del avance.

Este documento no sustituye al MDS; lo aplica al proyecto concreto. Toda decisión de conducción debe ser coherente con el marco rector y quedar reflejada en actualizaciones de este documento.

---

## 2. Marco rector

### 2.1. Documento rector

El proyecto LEX_PENAL se rige por:

- **METODOLOGIA_DESARROLLO_SOFTWARE_v2.2.md** — Manual metodológico institucional

### 2.2. Principios vinculantes

| Principio | Aplicación en LEX_PENAL |
|-----------|-------------------------|
| Secuencia obligatoria | No se ejecuta trabajo de una etapa sin cerrar la anterior |
| Código diferido | Código productivo solo desde E3; infraestructura y scaffold solo en E1-E2 |
| Decisión explícita | Toda decisión arquitectónica queda en ADRs |
| Verificabilidad | Todo avance se evidencia con artefactos verificables |
| Iteración ordenada | Los ajustes siguen el protocolo de desviación |
| Consistencia documental | La conducción, las notas de cierre y el estado del repositorio deben contar la misma historia |
| Deuda técnica sensible | Si afecta rutas, contrato, pruebas o gates, obliga saneamiento formal |

### 2.3. Documentos canónicos del proyecto

| Documento | Ubicación | Propósito |
|-----------|-----------|-----------|
| MODELO_DATOS_v3 | docs/03_datos/ | Modelo de datos canónico |
| CONTRATO_API_v4 | docs/04_api/ | Contrato de API REST |
| ARQUITECTURA_MODULO_IA_v3 | docs/12_ia/ | Arquitectura del módulo de IA |
| REGLAS_FUNCIONALES_VINCULANTES | docs/14_legal_funcional/ | Reglas de negocio obligatorias |
| BACKLOG_INICIAL | docs/01_producto/ | Backlog funcional del proyecto |
| DECISIONES_DE_ARQUITECTURA (README) | docs/00_gobierno/adrs/ | Índice maestro de ADRs |
| ADRs (9 documentos) | docs/00_gobierno/adrs/ | Decisiones arquitectónicas |
| ACTA_CIERRE_GATE_00_2026-03-20 | docs/00_gobierno/gates/ | Cierre formal de E0 |
| ACTA_CIERRE_GATE_01_2026-03-22 | docs/00_gobierno/gates/ | Formalización de cierre de E1 |
| ACTA_CIERRE_GATE_02_2026-03-22 | docs/00_gobierno/gates/ | Formalización de cierre de E2 |
| DESVIACIONES | docs/00_gobierno/registros/ | Registro centralizado de desviaciones |
| OBSERVACIONES_AUDITORIA | docs/00_gobierno/registros/ | Observaciones de auditoría |
| RIESGOS_Y_SUPUESTOS | docs/00_gobierno/registros/ | Riesgos y supuestos vivos del proyecto |
| J08A_PAUSA_2026-03-22 | docs/00_gobierno/auditorias/ | Declaración de pausa (histórico) |
| J08A_LEVANTAMIENTO_2026-03-23 | docs/00_gobierno/auditorias/ | Acta de levantamiento de pausa |

---

## 3. Estado del proyecto

### 3.1. Contexto

LEX_PENAL es un sistema de gestión de casos de defensa penal colombiana, orientado a consultorios jurídicos universitarios. El proyecto inició antes de la adopción formal del MDS, lo cual generó vacíos metodológicos que fueron regularizados durante las Jornadas 03 a 07 y auditados en el corte J08-A.

### 3.2. Situación actual

| Aspecto | Estado |
|---------|--------|
| **Fase del proyecto** | E3 — MVP Funcional |
| **Última jornada cerrada** | Jornada 07 (2026-03-22 / 2026-03-23) |
| **Etapa MDS activa** | E3 habilitada, pausa J08-A **LEVANTADA** |
| **Bloqueo principal** | Ninguno — Sprint 2 habilitado |
| **Próximo hito** | Apertura de Jornada 08 — Sprint 2 (cases) |

### 3.3. Estado de gates al 2026-03-23

| Gate | Estado | Observación |
|------|--------|-------------|
| **GATE-00** | Cerrado | Acta formal existente: 2026-03-20 |
| **GATE-01** | Cerrado | Formalización documental ex post: 2026-03-22 |
| **GATE-02** | Cerrado | Observaciones históricas absorbidas mediante saneamiento J08-A |
| **GATE-03** | No habilitado | Depende del cierre efectivo de Sprint 2, pruebas integradas y flujo crítico operando |
| **GATE-3.5** | No habilitado | Depende de prueba de realidad controlada |
| **GATE-04** | No habilitado | Depende de ajuste de realidad |
| **GATE-05** | No habilitado | Depende de consolidación y expansión |

### 3.4. Saneamiento J08-A completado

La pausa metodológica J08-A fue **levantada el 2026-03-23** tras completar el saneamiento técnico y documental. Ver `docs/00_gobierno/auditorias/J08A_LEVANTAMIENTO_2026-03-23.md`.

### 3.5. Regularización metodológica consolidada

El proyecto completó la regularización correctiva que asegura consistencia plena entre:

- conducción del proyecto;
- notas de cierre;
- contrato API;
- decisiones arquitectónicas;
- código real del repositorio;
- smoke tests validados.

---

## 4. Ruta maestra de LEX_PENAL

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                       RUTA MAESTRA — LEX_PENAL                               │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  E0                  E1                  E2                 E3               │
│  Preconstrucción     Base                Diseño             MVP              │
│  + Regularización    Ejecutable          Detallado          Funcional        │
│                                                                              │
│  [CERRADA]           [CERRADA]           [CERRADA]          [ACTIVA]         │
│                                                                              │
│  Gate: GATE-00       Gate: GATE-01       Gate: GATE-02      Gate: GATE-03   │
│  Estado: Cerrado     Estado: Cerrado     Estado: Cerrado    Estado: Pend.    │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────   │
│                                                                              │
│  E3.5                E4                  E5                                   │
│  Ajuste de           Revisión            Consolidación                        │
│  Realidad            Arquitectónica      y Expansión                          │
│                                                                              │
│  [BLOQUEADA]         [BLOQUEADA]         [BLOQUEADA]                          │
│  Gate: GATE-3.5      Gate: GATE-04       Gate: GATE-05                        │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 4.1. Regla de secuencia

Conforme al MDS v2.2:

> **Ninguna etapa puede iniciar sin gate previo superado, y ninguna deuda técnica sensible puede arrastrarse a la etapa siguiente sin saneamiento formal.**

En LEX_PENAL, con la pausa J08-A levantada, E3 queda plenamente habilitada para continuar con Sprint 2.

---

## 5. Etapas oficiales del proyecto

### 5.1. ETAPA 0 — Preconstrucción + Regularización

| Atributo | Valor |
|----------|-------|
| **Estado** | CERRADA |
| **Inicio** | Anterior a adopción MDS |
| **Cierre formal** | 2026-03-20 |
| **Responsable** | Paul León |
| **Código permitido** | Ninguno |

**Cierre verificado mediante:**

| Entregable | Estado | Ubicación |
|------------|--------|-----------|
| Documento de visión | ✅ | docs/01_producto/ |
| Alcance y exclusiones | ✅ | docs/01_producto/ |
| Análisis de dominio | ✅ | docs/01_producto/ |
| Decisiones de arquitectura | ✅ | docs/00_gobierno/adrs/ |
| Flujo crítico identificado | ✅ | docs/14_legal_funcional/ |
| RNF mínimos | ✅ | docs/08_seguridad/ |
| Criterios de éxito | ✅ | ACTA_CIERRE_GATE_00_2026-03-20.md |
| Cronograma macro | ✅ | Este documento |
| Ruta crítica | ✅ | Este documento |

**Observación histórica:** E0 fue cerrada tardíamente, pero quedó regularizada mediante acta formal.

---

### 5.2. ETAPA 1 — Base Ejecutable

| Atributo | Valor |
|----------|-------|
| **Estado** | CERRADA |
| **Inicio real** | Jornada 04 |
| **Cierre material** | Jornada 04 |
| **Formalización documental** | 2026-03-22 |
| **Responsable** | Paul León |
| **Código permitido** | Exploratorio + Infraestructura |

**Objetivo cumplido:** Validar que el stack NestJS + Prisma + PostgreSQL funciona como base ejecutable real.

**Evidencia principal:**

| Evidencia | Estado | Ubicación |
|-----------|--------|-----------|
| `.env` materializado | ✅ | Evidenciado en J04 |
| PostgreSQL alcanzable | ✅ | J04 |
| `prisma validate` | ✅ | J04 |
| `prisma generate` | ✅ | J04 |
| migración inicial | ✅ | J04 |
| `npm run build` | ✅ | J04 |
| arranque local | ✅ | J04 |
| cierre metodológico | ✅ | ACTA_CIERRE_GATE_01_2026-03-22.md |

**Observación:** La formalización del gate fue ex post, para asegurar trazabilidad metodológica completa.

---

### 5.3. ETAPA 2 — Diseño Detallado

| Atributo | Valor |
|----------|-------|
| **Estado** | CERRADA |
| **Inicio real** | Jornada 05 |
| **Cierre material** | Jornada 05 |
| **Formalización documental** | 2026-03-22 |
| **Responsable** | Paul León |
| **Código permitido** | Infraestructura (scaffold, contratos, DTOs, preparación) |

**Objetivo cumplido:** Dejar listo el marco de diseño para habilitar E3.

**Entregables consolidados:**

| Entregable | Estado | Ubicación |
|------------|--------|-----------|
| Flujo crítico mínimo del MVP | ✅ | J05 |
| Backlog priorizado | ✅ | docs/01_producto/BACKLOG_INICIAL.md |
| Definition of Done | ✅ | J05 |
| Contrato API | ✅ | docs/04_api/CONTRATO_API_v4.md |
| Modelo de datos | ✅ | docs/03_datos/MODELO_DATOS_v3.md + prisma/schema.prisma |
| Coherencia canónica mínima | ✅ | J05 |

**Observación histórica:** Durante la evolución del proyecto se detectó mezcla indebida entre scaffold y lógica de dominio. Esta desviación fue absorbida mediante **DESV-001** y saneada en J08-A.

---

### 5.4. ETAPA 3 — MVP Funcional

| Atributo | Valor |
|----------|-------|
| **Estado** | ACTIVA |
| **Inicio histórico** | Sprint 1 (J06-J07) |
| **Estado actual** | Sprint 1 completado; Sprint 2 habilitado |
| **Responsable** | Paul León |
| **Código permitido** | Productivo (lógica de negocio) |

**Estado funcional del MVP al 2026-03-23:**

| Vertical | Estado | Observación |
|----------|--------|-------------|
| auth | ✅ Completada | US-01, US-02, US-03 y US-05 cerradas |
| users | ✅ Parcial | US-04 cerrada; módulo aún con stubs 501 en endpoints no cubiertos |
| cases | ⏳ Habilitada | Sprint 2 listo para iniciar |
| facts | 🔒 Bloqueada | Depende de cases |
| evidence | 🔒 Bloqueada | Depende de facts/cases |
| risks | 🔒 Bloqueada | Dependencia posterior |
| strategy | 🔒 Bloqueada | Dependencia posterior |
| checklist | 🔒 Bloqueada | Dependencia posterior |
| review | 🔒 Bloqueada | Dependencia posterior |
| ai | 🔒 Bloqueada | Dependencia posterior |
| reports | 🔒 Bloqueada | Dependencia posterior |

**Flujo crítico vigente para MVP:**

1. ✅ Autenticación (login, sesión, perfil)
2. ⏳ Crear caso con datos básicos
3. ⏳ Consultar detalle y listado de caso
4. ⏳ Transicionar caso por máquina de estados
5. 🔒 Registrar hechos
6. 🔒 Registrar pruebas
7. 🔒 Validar flujo integrado mínimo

---

### 5.5. ETAPA 3.5 — Ajuste de Realidad

| Atributo | Valor |
|----------|-------|
| **Estado** | BLOQUEADA |
| **Responsable** | Paul León |

**Objetivo:** Validar MVP con usuarios reales o representativos del consultorio jurídico.

---

### 5.6. ETAPA 4 — Revisión Arquitectónica

| Atributo | Valor |
|----------|-------|
| **Estado** | BLOQUEADA |
| **Responsable** | Paul León |

**Objetivo:** Evaluar si la arquitectura requiere ajustes basándose en hallazgos de uso real.

---

### 5.7. ETAPA 5 — Consolidación y Expansión

| Atributo | Valor |
|----------|-------|
| **Estado** | BLOQUEADA |
| **Responsable** | Paul León |

**Objetivo:** Estabilizar MVP y habilitar expansión modular.

---

## 6. Hitos de control

| ID | Hito | Etapa | Criterio de cumplimiento | Estado |
|----|------|-------|--------------------------|--------|
| H-00a | Gobierno base formalizado | E0 | Documento de conducción + ADRs + alcance + visión | ✅ |
| H-00b | Criterios de éxito definidos | E0 | Criterios aprobados en Gate-00 | ✅ |
| H-01 | Base ejecutable validada | E1 | Compila, migra, arranca y responde | ✅ |
| H-02 | Diseño detallado consolidado | E2 | Backlog + DoD + API + modelo de datos | ✅ |
| H-03a | Bootstrap administrador operativo | E3 | US-04 validada y cerrada | ✅ |
| H-03b | Bloque auth funcional | E3 | Login, persistencia, perfil y logout cerrados | ✅ |
| H-03c | Saneamiento metodológico J08-A | E3 | Desviación absorbida y rutas/contrato alineados | ✅ |
| H-03d | Sprint 2 — cases funcional | E3 | US-06 a US-10 cerradas + prueba integrada | ⏳ Habilitado |
| H-03e | Flujo crítico mínimo del MVP | E3 | Auth + cases + facts + evidence integrados | 🔒 Bloqueado |
| H-3.5 | Prueba de realidad controlada | E3.5 | Caso real o representativo ejecutado | ⚪ No iniciado |
| H-04 | Revisión arquitectónica | E4 | ADRs de ajuste si aplica | ⚪ No iniciado |
| H-05 | Consolidación | E5 | Estabilización + expansión modular | ⚪ No iniciado |

---

## 7. Gates y criterios de paso

### 7.1. GATE-00 — Cierre de E0

| Criterio | Estado |
|----------|--------|
| Visión y alcance definidos | ✅ |
| Dominio analizado | ✅ |
| Decisiones base de arquitectura | ✅ |
| Criterios de éxito definidos | ✅ |
| Cronograma macro y ruta crítica | ✅ |

**Estado:** CERRADO  
**Evidencia:** `docs/00_gobierno/gates/ACTA_CIERRE_GATE_00_2026-03-20.md`

---

### 7.2. GATE-01 — Cierre de E1

| Criterio | Estado |
|----------|--------|
| Entorno reproducible | ✅ |
| Base de datos alcanzable | ✅ |
| Prisma validado | ✅ |
| Migración inicial aplicada | ✅ |
| Compilación exitosa | ✅ |
| Arranque local exitoso | ✅ |

**Estado:** CERRADO  
**Evidencia:** `docs/00_gobierno/gates/ACTA_CIERRE_GATE_01_2026-03-22.md`

---

### 7.3. GATE-02 — Cierre de E2

| Criterio | Estado |
|----------|--------|
| Backlog priorizado | ✅ |
| Modelo de datos definido | ✅ |
| Contrato API definido | ✅ |
| Definition of Done acordada | ✅ |
| Infraestructura lista para E3 | ✅ |

**Estado:** CERRADO  
**Evidencia:** `docs/00_gobierno/gates/ACTA_CIERRE_GATE_02_2026-03-22.md`

**Nota:** Las observaciones históricas fueron absorbidas mediante el saneamiento J08-A.

---

### 7.4. GATE-03 — Cierre de E3

| Criterio | Estado requerido |
|----------|------------------|
| Flujo crítico mínimo operativo | Pendiente |
| Sprint 1 y Sprint 2 cerrados | Sprint 1 ✅, Sprint 2 pendiente |
| Pruebas integradas ejecutadas | Pendiente |
| Contrato API y código alineados | ✅ |
| Deuda técnica sensible saneada | ✅ |

**Estado:** NO HABILITADO

---

## 8. Cronograma macro

### 8.1. Semáforo

| Símbolo | Significado |
|---------|-------------|
| 🟢 Verde | Cumplido |
| 🟡 Amarillo | Cumplido con observaciones / en progreso |
| 🔴 Rojo | Bloqueado o desalineado críticamente |
| ⚪ Gris | No iniciado |

### 8.2. Etapas

| Etapa | Estado | Fecha objetivo inicial | Fecha real / corte | Desviación | Semáforo |
|-------|--------|------------------------|--------------------|------------|----------|
| E0 | Cerrada | 2026-03-09 | 2026-03-20 | +11 días | 🟢 |
| E1 | Cerrada | 2026-03-20 | 2026-03-20 | 0 días | 🟢 |
| E2 | Cerrada | 2026-03-20 | 2026-03-20 | 0 días | 🟢 |
| E3 | Activa | 2026-03-20 | En ejecución al 2026-03-23 | Controlada | 🟢 |
| E3.5 | No iniciada | Posterior a GATE-03 | — | — | ⚪ |
| E4 | No iniciada | Posterior a E3.5 | — | — | ⚪ |
| E5 | No iniciada | Posterior a E4 | — | — | ⚪ |

### 8.3. Jornadas completadas

| Jornada | Fecha | Etapa | Objetivo | Resultado | Cierre formal |
|---------|-------|-------|----------|-----------|---------------|
| J01 | Pre-MDS | E0 | Documentación inicial | Documentos canónicos creados | No (pre-MDS) |
| J02 | Pre-MDS | E0 | Scaffold inicial | Estructura `src/` generada | No (pre-MDS) |
| J03 | 2026-03-08 | E0 | Regularización técnica inicial | Auditoría + Prisma + servicio de estados | ✅ |
| J04 | 2026-03-20 | E1 | Cierre de GATE-00 + validación base ejecutable | GATE-00 y GATE-01 cerrados materialmente | ✅ |
| J05 | 2026-03-20 | E2 | Diseño detallado y habilitación de E3 | GATE-02 cerrado materialmente | ✅ |
| J06 | 2026-03-20 | E3 | Sprint 1 — US-04 bootstrap admin | Historia cerrada y validada | ✅ |
| J07 | 2026-03-22/23 | E3 | Cierre del bloque auth de Sprint 1 | US-01, US-02, US-03 y US-05 cerradas | ✅ |
| J08-A | 2026-03-22/23 | E3 | Auditoría y saneamiento | Pausa declarada y levantada | ✅ |

### 8.4. Próxima jornada

| Jornada | Fecha prevista | Etapa | Objetivo | Gate objetivo |
|---------|----------------|-------|----------|---------------|
| J08 | 2026-03-23 | E3 | Sprint 2 — Gestión básica de casos | Preparación para GATE-03 |

---

## 9. Ruta crítica y dependencias

### 9.1. Registro de ruta crítica

| ID | Actividad/Entregable | Etapa | Dependencias | Fecha objetivo | Fecha real | Estado | Impacto si retrasa |
|----|---------------------|-------|--------------|----------------|------------|--------|-------------------|
| RC-01 | Saneamiento de conducción y gates | E3 | Auditoría J08-A | 2026-03-23 | 2026-03-23 | ✅ Completado | — |
| RC-02 | Convención única de rutas (`api/v1`) saneada | E3 | RC-01 | 2026-03-23 | 2026-03-23 | ✅ Completado | — |
| RC-03 | ADR-009 emitido y aplicado | E3 | RC-02 | 2026-03-23 | 2026-03-22 | ✅ Completado | — |
| RC-04 | Contrato API alineado con implementación | E3 | RC-02, RC-03 | 2026-03-23 | 2026-03-23 | ✅ Completado | — |
| RC-05 | Apertura controlada de J08 | E3 | RC-01 a RC-04 | 2026-03-23 | — | ⏳ Habilitado | Bloquea cases |
| RC-06 | Sprint 2 — US-06 a US-10 | E3 | RC-05 | 2026-03-24 | — | ⏳ Habilitado | Bloquea flujo crítico |
| RC-07 | Prueba integrada de casos | E3 | RC-06 | 2026-03-24 | — | 🔒 Bloqueado | Bloquea GATE-03 |
| RC-08 | GATE-03 cerrado | E3 | RC-07 | 2026-03-24 | — | 🔒 Bloqueado | Habilita E3.5 |

### 9.2. Elemento crítico inmediato

**RC-05 y RC-06** conforman el bloque crítico inmediato: apertura de Jornada 08 y ejecución de Sprint 2.

### 9.3. Dependencias técnicas inmediatas

| Dependencia | Tipo | Estado |
|-------------|------|--------|
| `setGlobalPrefix('api/v1')` coherente con controllers | Técnica | ✅ Saneado |
| Smoke tests alineados con rutas reales | Técnica | ✅ Validado |
| `cases` DTOs definidos y payloads mínimos documentados | Técnica | ✅ |
| Documento de conducción actualizado | Metodológica | ✅ Este documento |
| Registro de desviación y riesgos | Metodológica | ✅ Actualizado |

### 9.4. Dependencias entre verticales (E3)

```
auth ─────► users ─────► cases ─────┬──► facts ──► evidence
                            │       │
                            │       └──► risks ──► strategy
                            │
                            └──► checklist ──► review ──► reports
                            │
                            └──► ai (transversal)
```

---

## 10. Control de desviaciones

### 10.1. Matriz de desviaciones activas

| ID | Tipo | Descripción | Estado |
|----|------|-------------|--------|
| — | — | No hay desviaciones activas | — |

### 10.2. Desviaciones históricas resueltas

| ID | Tipo | Descripción | Resolución | Fecha |
|----|------|-------------|------------|-------|
| DEV-001 | Proceso | Proyecto inició sin MDS formal | Cerrado vía GATE-00 | 2026-03-20 |
| DEV-002 | Gobierno | Documento de conducción desactualizado | Actualizado en saneamiento J08-A | 2026-03-23 |
| DEV-003 | Técnica | Duplicación de prefijos API | ADR-009 + saneamiento de 14 controllers | 2026-03-23 |
| DEV-004 | Método | Mezcla scaffold/dominio | Registro DESV-001 + refuerzo MDS | 2026-03-23 |
| DEV-005 | Proceso | Jornadas 01-02 sin cierre formal | Regularizado desde J03 | 2026-03-08 |
| DESV-001 | Técnica/Método | Prefijos duplicados y código diferido | Saneado en J08-A | 2026-03-23 |
| OBS-001 | Auditoría | Desalineación contrato-implementación-pruebas | Corregido en J08-A | 2026-03-23 |

---

## 11. Estado actual y fase activa

### 11.1. Resumen ejecutivo

| Dimensión | Estado |
|-----------|--------|
| **Etapa activa** | E3 — MVP Funcional |
| **Gate operativo pendiente** | GATE-03 |
| **Bloqueo principal** | Ninguno |
| **Última jornada** | J08-A cerrada (saneamiento completado) |
| **Compilación** | ✅ `npm run build` exitoso |
| **Base ejecutable** | ✅ Validada |
| **Autenticación** | ✅ Bloque Sprint 1 cerrado |
| **Gestión de casos** | ⏳ Habilitada para Sprint 2 |
| **Pruebas integradas** | 🔒 Pendiente tras Sprint 2 |
| **Smoke tests** | ✅ Validados contra backend real |

### 11.2. Artefactos listos

| Artefacto | Estado | Ubicación |
|-----------|--------|-----------|
| `schema.prisma` | ✅ | `prisma/` |
| `CasoEstadoService` | ✅ | `src/modules/cases/services/` |
| módulo `auth` | ✅ funcional | `src/modules/auth/` |
| módulo `users` | ✅ parcial | `src/modules/users/` |
| `JwtAuthGuard` | ✅ | `src/modules/auth/guards/` |
| `@CurrentUser()` | ✅ | `src/modules/auth/decorators/` |
| contrato API v4 | ✅ alineado | `docs/04_api/` |
| backlog inicial | ✅ | `docs/01_producto/` |
| smoke tests | ✅ validados | `tests/e2e/`, `scripts/` |

### 11.3. Artefactos pendientes inmediatos

| Artefacto | Acción requerida | Etapa |
|-----------|------------------|-------|
| Implementación US-06 a US-10 | Desarrollar en Sprint 2 | E3 |
| Pruebas integradas de casos | Ejecutar tras Sprint 2 | E3 |

---

## 12. Próximo hito y condiciones de habilitación

### 12.1. Próximo hito inmediato

**H-03d — Sprint 2 — cases funcional**

### 12.2. Estado del saneamiento J08-A

| Condición | Estado |
|-----------|--------|
| Documento de conducción actualizado | ✅ |
| GATE-01 formalizado documentalmente | ✅ |
| GATE-02 formalizado documentalmente | ✅ |
| ADR-009 emitido | ✅ |
| Contrato API alineado con implementación | ✅ |
| Desviación histórica registrada (DESV-001) | ✅ |
| Observación de auditoría registrada (OBS-001) | ✅ |
| Controllers saneados (14 archivos) | ✅ |
| Smoke tests corregidos y validados | ✅ |

**Pausa J08-A:** LEVANTADA (2026-03-23)

### 12.3. Secuencia post levantamiento

```
1. ✅ Actualizar documento de conducción
2. ✅ Formalizar GATE-01 y GATE-02
3. ✅ Registrar desviación histórica
4. ✅ Emitir ADR-009
5. ✅ Sanear decorators @Controller(...) y contrato API
6. ✅ Alinear smoke tests
7. ✅ Levantar pausa metodológica J08-A
8. ⏳ Abrir Jornada 08
9. ⏳ Ejecutar Sprint 2 — cases
10. 🔒 Realizar prueba integrada
11. 🔒 Preparar GATE-03
```

---

## 13. Reglas de gobierno del avance

### 13.1. Regla de secuencia

> **Ninguna etapa puede iniciarse sin haber superado el gate de la etapa anterior.**

### 13.2. Regla de deuda técnica sensible

Si una jornada cierra con deuda técnica que afecte rutas, contrato API, pruebas, gates, trazabilidad documental o habilitación de etapa, el cierre debe incorporar:

- identificación explícita del impacto;
- prioridad;
- responsable;
- plan de saneamiento;
- condición de levantamiento o bloqueo para la etapa siguiente.

### 13.3. Regla de consistencia documental mínima

Ninguna jornada podrá considerarse cerrada si:

- el documento de conducción no refleja el estado real del proyecto;
- los gates no coinciden con la secuencia ejecutada;
- el backlog aprobado no coincide materialmente con el estado declarado del repositorio.

### 13.4. Regla de delimitación entre scaffold e implementación de dominio

Se considera scaffold o infraestructura permitida en E2:

- wiring de módulos;
- DTOs;
- decorators;
- configuración;
- contratos;
- interfaces;
- stubs sin reglas de negocio.

No se considera scaffold, y por tanto queda prohibido en E2:

- reglas de transición;
- guardas de negocio;
- persistencia con decisiones de dominio;
- validaciones materiales del caso de uso;
- efectos de negocio asociados a cambio de estado.

### 13.5. Regla de cierre de jornada

Toda jornada debe cerrarse con nota formal que incluya:

- objetivo de la jornada;
- resultado alcanzado;
- pendientes;
- decisiones tomadas;
- próximo paso exacto;
- clasificación MDS del trabajo realizado.

### 13.6. Regla de cierre de etapa

Una etapa solo se considera cerrada cuando:

- todos los criterios del gate están cumplidos;
- existe evidencia verificable de cada criterio;
- el cierre queda documentado formalmente;
- este documento se actualiza reflejando el nuevo estado.

### 13.7. Regla de validación de smoke tests (nueva)

Antes de declarar readiness para cualquier sprint, los smoke tests deben:

- ejecutarse contra backend levantado;
- verificar respuestas contra estructura del contrato;
- confirmar que campos de request/response coinciden con DTOs reales.

### 13.8. Autoridad de aprobación

Por tratarse de un proyecto unipersonal, la autoridad de aprobación de gates es el propio responsable del proyecto (Paul León), mediante auto-certificación documentada.

---

## 14. Conclusión ejecutiva

### 14.1. Situación

LEX_PENAL se encuentra en **E3 activa**, con el saneamiento metodológico J08-A completado y Sprint 2 habilitado para iniciar.

### 14.2. Logros consolidados

- E0, E1 y E2 cerradas formalmente;
- GATE-00, GATE-01 y GATE-02 formalizados;
- Sprint 1 del bloque auth/users completado y validado;
- Saneamiento J08-A completado: 14 controllers, contrato API, smoke tests;
- DESV-001 y OBS-001 cerradas con trazabilidad completa;
- Base ejecutable comprobada;
- Smoke tests validados contra backend real.

### 14.3. Próximo objetivo

1. Abrir Jornada 08;
2. Ejecutar Sprint 2 — Gestión básica de casos (US-06 a US-10);
3. Realizar prueba integrada del flujo mínimo;
4. Preparar GATE-03.

### 14.4. Riesgo principal

El mayor riesgo actual es de alcance: asegurar que Sprint 2 se complete sin acumular nueva deuda técnica sensible.

### 14.5. Recomendación

Iniciar Sprint 2 de inmediato, manteniendo la disciplina de validación de smoke tests establecida durante el saneamiento J08-A.

---

## 15. Trazabilidad metodológica

### 15.1. Versión del MDS aplicada

Este documento aplica **MDS v2.2** como marco rector.

### 15.2. Coherencia con el estado real del proyecto

El estado reflejado en este documento es coherente con:

- `docs/00_gobierno/gates/ACTA_CIERRE_GATE_00_2026-03-20.md`
- `docs/00_gobierno/gates/ACTA_CIERRE_GATE_01_2026-03-22.md`
- `docs/00_gobierno/gates/ACTA_CIERRE_GATE_02_2026-03-22.md`
- `docs/00_gobierno/auditorias/J08A_LEVANTAMIENTO_2026-03-23.md`
- `docs/00_gobierno/registros/DESVIACIONES.md`
- `docs/00_gobierno/registros/OBSERVACIONES_AUDITORIA.md`
- el estado del repositorio al 2026-03-23.

### 15.3. Nota de consistencia

Cualquier cambio posterior de estado que no quede reflejado en este documento deberá considerarse desviación de gobierno documental.

---

## 16. Control de cambios

| Versión | Fecha | Cambios |
|---------|-------|---------|
| 1.0 | 2026-03-09 | Versión inicial del sistema de conducción |
| 1.1 | 2026-03-09 | Correcciones: secuencia E0→E1, gates 3.5-05 y cronograma con semáforo |
| 1.2 | 2026-03-23 | Actualización integral post auditoría J08-A: cierre histórico de E0-E2, estado real hasta J07, pausa metodológica J08-A, ruta crítica corregida, desviaciones activas y alineación con MDS v2.2 |
| 1.3 | 2026-03-23 | Levantamiento de pausa J08-A: saneamiento completado, DESV-001 y OBS-001 cerradas, smoke tests validados, Sprint 2 habilitado, regla 13.7 agregada |

---

**Fin del documento.**
