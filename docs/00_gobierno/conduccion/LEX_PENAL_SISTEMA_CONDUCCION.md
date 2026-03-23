# LEX_PENAL — Sistema de Conducción del Proyecto

**Versión:** 1.2  
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
| DECISIONES_DE_ARQUITECTURA | docs/00_gobierno/ | Índice maestro de ADRs |
| ADRs (9 documentos) | docs/00_gobierno/adrs/ | Decisiones arquitectónicas |
| ACTA_CIERRE_GATE_00_2026-03-20 | docs/00_gobierno/ | Cierre formal de E0 |
| ACTA_CIERRE_GATE_01_2026-03-22 | docs/00_gobierno/ | Formalización de cierre de E1 |
| ACTA_CIERRE_GATE_02_2026-03-22 | docs/00_gobierno/ | Formalización de cierre de E2 |
| ACTA_PAUSA_METODOLOGICA_J08A_2026-03-22 | docs/00_gobierno/ | Bloqueo de avance hasta saneamiento |
| REGISTRO_DESVIACION_001_2026-03-22_PREFIJOS_Y_CODIGO_DIFERIDO | docs/00_gobierno/ | Desviación histórica regularizada |
| REGISTRO_RIESGOS_Y_SUPUESTOS | docs/00_gobierno/ | Riesgos y supuestos vivos del proyecto |

---

## 3. Estado del proyecto

### 3.1. Contexto

LEX_PENAL es un sistema de gestión de casos de defensa penal colombiana, orientado a consultorios jurídicos universitarios. El proyecto inició antes de la adopción formal del MDS, lo cual generó vacíos metodológicos que fueron regularizados durante las Jornadas 03 a 07 y auditados en el corte J08-A.

### 3.2. Situación actual

| Aspecto | Estado |
|---------|--------|
| **Fase del proyecto** | Saneamiento metodológico post auditoría J08-A |
| **Última jornada cerrada** | Jornada 07 (2026-03-22 / 2026-03-23) |
| **Etapa MDS activa** | E3 habilitada históricamente, con pausa metodológica vigente previa a Sprint 2 |
| **Bloqueo principal** | Pausa metodológica J08-A por saneamiento de trazabilidad, rutas y consistencia documental |
| **Próximo hito** | Levantamiento de la pausa y apertura controlada de Jornada 08 — Sprint 2 (cases) |

### 3.3. Estado de gates al corte J08-A

| Gate | Estado | Observación |
|------|--------|-------------|
| **GATE-00** | Cerrado | Acta formal existente: 2026-03-20 |
| **GATE-01** | Cerrado | Formalización documental ex post: 2026-03-22 |
| **GATE-02** | Cerrado con observaciones | E3 quedó habilitada históricamente, pero requiere saneamiento de rutas, contrato API y trazabilidad |
| **GATE-03** | No habilitado | Depende del cierre efectivo de Sprint 2, pruebas integradas y flujo crítico operando |
| **GATE-3.5** | No habilitado | Depende de prueba de realidad controlada |
| **GATE-04** | No habilitado | Depende de ajuste de realidad |
| **GATE-05** | No habilitado | Depende de consolidación y expansión |

### 3.4. Bloque de saneamiento vigente

Se encuentra vigente la **ACTA_PAUSA_METODOLOGICA_J08A_2026-03-22.md**. Mientras esta acta no sea levantada, no se autoriza avance funcional del Sprint 2.

### 3.5. Regularización metodológica consolidada

El proyecto ya no se encuentra en regularización inicial de E0. La regularización actual es de tipo correctivo y se concentra en asegurar consistencia plena entre:

- conducción del proyecto;
- notas de cierre;
- contrato API;
- decisiones arquitectónicas;
- código real del repositorio.

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
│  [CERRADA]           [CERRADA]           [CERRADA]          [HABILITADA      │
│                                                            CON PAUSA J08-A] │
│                                                                              │
│  Gate: GATE-00       Gate: GATE-01       Gate: GATE-02      Gate: GATE-03   │
│  Estado: Cerrado     Estado: Cerrado     Estado: Cerrado    Estado: Pend.    │
│                                            con obs.                          │
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

En LEX_PENAL esto implica que, aunque E3 fue habilitada históricamente, el arranque efectivo de Sprint 2 queda suspendido mientras continúe vigente la pausa metodológica J08-A.

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
| Contrato API | ✅ con observación | docs/04_api/CONTRATO_API_v4.md |
| Modelo de datos | ✅ | docs/03_datos/MODELO_DATOS_v3.md + prisma/schema.prisma |
| Coherencia canónica mínima | ✅ | J05 |

**Observación crítica histórica:** durante la evolución del proyecto se detectó mezcla indebida entre scaffold y lógica de dominio en un tramo tempranamente etiquetado como base técnica. Esta desviación no invalida el cierre histórico de E2, pero sí dio lugar a la **DESV-001**.

---

### 5.4. ETAPA 3 — MVP Funcional

| Atributo | Valor |
|----------|-------|
| **Estado** | HABILITADA CON PAUSA METODOLÓGICA |
| **Inicio histórico** | Sprint 1 (J06-J07) |
| **Estado actual** | Sprint 1 parcialmente ejecutado; Sprint 2 bloqueado hasta saneamiento |
| **Responsable** | Paul León |
| **Código permitido** | Productivo (lógica de negocio) |

**Estado funcional del MVP al corte J08-A:**

| Vertical | Estado | Observación |
|----------|--------|-------------|
| auth | Parcialmente completada | US-01, US-02, US-03 y US-05 cerradas |
| users | Parcialmente completada | US-04 cerrada; módulo aún con stubs 501 en endpoints no cubiertos |
| cases | No iniciada funcionalmente | Existe módulo base y servicios parciales; Sprint 2 no arrancado |
| facts | No iniciada | Depende de cases |
| evidence | No iniciada | Depende de facts/cases |
| risks | No iniciada | Dependencia posterior |
| strategy | No iniciada | Dependencia posterior |
| checklist | No iniciada | Dependencia posterior |
| review | No iniciada | Dependencia posterior |
| ai | No iniciada | Dependencia posterior |
| reports | No iniciada | Dependencia posterior |

**Flujo crítico vigente para MVP:**

1. Autenticación (login, sesión, perfil)
2. Crear caso con datos básicos
3. Consultar detalle y listado de caso
4. Transicionar caso por máquina de estados
5. Registrar hechos
6. Registrar pruebas
7. Validar flujo integrado mínimo

**Bloqueo actual:** antes de abrir `cases`, debe sanearse la desviación de prefijos/rutas y la consistencia documental.

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
| H-03c | Saneamiento metodológico J08-A | E3 | Desviación absorbida y rutas/contrato alineados | ⏳ En curso |
| H-03d | Sprint 2 — cases funcional | E3 | US-06 a US-10 cerradas + prueba integrada | 🔒 Bloqueado |
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
**Evidencia:** `docs/00_gobierno/ACTA_CIERRE_GATE_00_2026-03-20.md`

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
**Evidencia:** `docs/00_gobierno/ACTA_CIERRE_GATE_01_2026-03-22.md`

---

### 7.3. GATE-02 — Cierre de E2

| Criterio | Estado |
|----------|--------|
| Backlog priorizado | ✅ |
| Modelo de datos definido | ✅ |
| Contrato API definido | ✅ con observación |
| Definition of Done acordada | ✅ |
| Infraestructura lista para E3 | ✅ |

**Estado:** CERRADO CON OBSERVACIONES  
**Evidencia:** `docs/00_gobierno/ACTA_CIERRE_GATE_02_2026-03-22.md`

**Observación:** La observación principal del gate es la necesidad de alinear la convención de rutas y absorber formalmente la desviación histórica detectada en auditoría.

---

### 7.4. GATE-03 — Cierre de E3

| Criterio | Estado requerido |
|----------|------------------|
| Flujo crítico mínimo operativo | Pendiente |
| Sprint 1 y Sprint 2 cerrados | Pendiente |
| Pruebas integradas ejecutadas | Pendiente |
| Contrato API y código alineados | Pendiente |
| Deuda técnica sensible saneada | Pendiente |

**Estado:** NO HABILITADO

---

## 8. Cronograma macro

### 8.1. Semáforo

| Símbolo | Significado |
|---------|-------------|
| 🟢 Verde | Cumplido |
| 🟡 Amarillo | Cumplido con observaciones / en saneamiento |
| 🔴 Rojo | Bloqueado o desalineado críticamente |
| ⚪ Gris | No iniciado |

### 8.2. Etapas

| Etapa | Estado | Fecha objetivo inicial | Fecha real / corte | Desviación | Semáforo |
|-------|--------|------------------------|--------------------|------------|----------|
| E0 | Cerrada | 2026-03-09 | 2026-03-20 | +11 días | 🟡 |
| E1 | Cerrada | 2026-03-20 | 2026-03-20 | 0 días | 🟢 |
| E2 | Cerrada | 2026-03-20 | 2026-03-20 | 0 días | 🟢 |
| E3 | Habilitada con pausa | 2026-03-20 | En ejecución parcial al 2026-03-23 | Controlada por J08-A | 🟡 |
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
| J07 | 2026-03-22 / 2026-03-23 | E3 | Cierre del bloque auth de Sprint 1 | US-01, US-02, US-03 y US-05 cerradas; deuda técnica reconocida | ✅ con saneamiento posterior |

### 8.4. Próxima jornada

| Jornada | Fecha prevista | Etapa | Objetivo | Gate objetivo |
|---------|----------------|-------|----------|---------------|
| J08 | Tras levantar pausa J08-A | E3 | Sprint 2 — Gestión básica de casos | Preparación para GATE-03 |

**Condición previa:** debe levantarse formalmente la pausa metodológica J08-A.

---

## 9. Ruta crítica y dependencias

### 9.1. Registro de ruta crítica

| ID | Actividad/Entregable | Etapa | Dependencias | Fecha objetivo | Fecha real | Estado | Impacto si retrasa |
|----|---------------------|-------|--------------|----------------|------------|--------|-------------------|
| RC-01 | Saneamiento de conducción y gates | E3 | Auditoría J08-A | 2026-03-23 | — | ⏳ En curso | Bloquea apertura de J08 |
| RC-02 | Convención única de rutas (`api/v1`) saneada | E3 | RC-01 | 2026-03-23 | — | 🔒 Bloqueado | Bloquea contrato API y smoke tests |
| RC-03 | ADR-009 emitido y aplicado | E3 | RC-02 | 2026-03-23 | — | 🔒 Bloqueado | Bloquea consistencia técnica |
| RC-04 | Contrato API alineado con implementación | E3 | RC-02, RC-03 | 2026-03-23 | — | 🔒 Bloqueado | Bloquea Sprint 2 |
| RC-05 | Apertura controlada de J08 | E3 | RC-01 a RC-04 | 2026-03-23 | — | 🔒 Bloqueado | Bloquea cases |
| RC-06 | Sprint 2 — US-06 a US-10 | E3 | RC-05 | 2026-03-24 | — | 🔒 Bloqueado | Bloquea flujo crítico |
| RC-07 | Prueba integrada de casos | E3 | RC-06 | 2026-03-24 | — | 🔒 Bloqueado | Bloquea GATE-03 |
| RC-08 | GATE-03 cerrado | E3 | RC-07 | 2026-03-24 | — | 🔒 Bloqueado | Habilita E3.5 |

### 9.2. Elemento crítico inmediato

**RC-01 a RC-04** conforman el bloque crítico inmediato. No existe otra ruta válida para abrir Jornada 08 sin incumplir el MDS.

### 9.3. Dependencias técnicas inmediatas

| Dependencia | Tipo | Impacto si falla |
|-------------|------|------------------|
| `setGlobalPrefix('api/v1')` coherente con controllers | Técnica | Duplica rutas y rompe contrato API |
| Smoke tests alineados con rutas reales | Técnica | Falsa validación del backend |
| `cases` DTOs y payloads coherentes | Técnica | Bloquea Sprint 2 |
| Documento de conducción actualizado | Metodológica | Rompe trazabilidad oficial |
| Registro de desviación y riesgos | Metodológica | Debilita control de avance |

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

| ID | Tipo | Descripción | Causa | Impacto | Acción correctiva | Responsable | Estado |
|----|------|-------------|-------|---------|-------------------|-------------|--------|
| DEV-001 | Proceso | Proyecto inició sin MDS formal | Adopción tardía del método | Requirió regularización de E0 | Cerrado vía GATE-00 | Paul León | ✅ Cerrada |
| DEV-002 | Gobierno | Documento de conducción quedó desactualizado frente al repo | Continuidad de jornadas sin actualización del rector | Rompe trazabilidad oficial | Actualizar conducción y cierres | Paul León | En corrección |
| DEV-003 | Técnica / Método | Duplicación de prefijos y tensión entre contrato API y código | Convención no saneada oportunamente | Riesgo de rutas inconsistentes | ADR-009 + saneamiento de controllers y contrato | Paul León | En corrección |
| DEV-004 | Método | Mezcla histórica entre scaffold y lógica de dominio | Interpretación laxa de código diferido | Riesgo de falsa conformidad | Registro formal de desviación + refuerzo MDS | Paul León | En corrección |

### 10.2. Desviaciones históricas resueltas

| ID | Tipo | Descripción | Resolución | Fecha |
|----|------|-------------|------------|-------|
| DEV-005 | Proceso | Jornadas 01-02 sin cierre formal | Regularizado desde J03 | 2026-03-08 |

---

## 11. Estado actual y fase activa

### 11.1. Resumen ejecutivo

| Dimensión | Estado |
|-----------|--------|
| **Etapa activa** | E3 con pausa metodológica |
| **Gate operativo pendiente** | GATE-03 |
| **Bloqueo principal** | Saneamiento de rutas, contrato API y trazabilidad |
| **Última jornada** | J07 cerrada con saneamiento posterior |
| **Compilación** | ✅ El backend compila en estático |
| **Base ejecutable** | ✅ Validada históricamente |
| **Autenticación** | ✅ Bloque Sprint 1 cerrado |
| **Gestión de casos** | 🔒 Pendiente apertura controlada |
| **Pruebas integradas** | 🔒 No iniciadas |

### 11.2. Artefactos listos

| Artefacto | Estado | Ubicación |
|-----------|--------|-----------|
| `schema.prisma` | ✅ | `prisma/` |
| `CasoEstadoService` | ✅ con observación metodológica histórica | `src/modules/cases/services/` |
| módulo `auth` | ✅ funcional básico | `src/modules/auth/` |
| módulo `users` | ✅ parcial | `src/modules/users/` |
| `JwtAuthGuard` | ✅ | `src/modules/auth/guards/` |
| `@CurrentUser()` | ✅ | `src/modules/auth/decorators/` |
| contrato API v4 | ✅ con observación | `docs/04_api/` |
| backlog inicial | ✅ | `docs/01_producto/` |

### 11.3. Artefactos pendientes inmediatos

| Artefacto | Acción requerida | Etapa |
|-----------|------------------|-------|
| `ACTA_CIERRE_GATE_01_2026-03-22.md` | Mantener como evidencia formal | Gobierno |
| `ACTA_CIERRE_GATE_02_2026-03-22.md` | Mantener como evidencia formal | Gobierno |
| `ADR-009-prefijo-global-y-rutas-relativas.md` | Emitir y aplicar | Gobierno / Técnica |
| `REGISTRO_DESVIACION_001_2026-03-22_PREFIJOS_Y_CODIGO_DIFERIDO.md` | Emitir | Gobierno |
| `REGISTRO_RIESGOS_Y_SUPUESTOS.md` | Abrir y mantener | Gobierno |
| controllers con prefijo duplicado | Sanear | Técnica |
| smoke tests / scripts de verificación | Alinear al contrato real | Técnica |

---

## 12. Próximo hito y condiciones de habilitación

### 12.1. Próximo hito inmediato

**H-03c — Saneamiento metodológico J08-A**

### 12.2. Condiciones para levantar la pausa J08-A

| Condición | Estado |
|-----------|--------|
| Documento de conducción actualizado | ⏳ |
| GATE-01 formalizado documentalmente | ⏳ |
| GATE-02 formalizado documentalmente | ⏳ |
| ADR-009 emitido | ⏳ |
| Contrato API alineado con convención oficial | ⏳ |
| Desviación histórica registrada | ⏳ |

### 12.3. Secuencia post pausa J08-A

```
1. Actualizar documento de conducción
2. Formalizar GATE-01 y GATE-02
3. Registrar desviación histórica
4. Emitir ADR-009
5. Sanear decorators @Controller(...) y contrato API
6. Alinear smoke tests
7. Levantar pausa metodológica J08-A
8. Abrir Jornada 08
9. Ejecutar Sprint 2 — cases
10. Realizar prueba integrada
11. Preparar GATE-03
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

### 13.3. Prohibiciones mientras la pausa J08-A no cierre

| Actividad prohibida | Justificación |
|---------------------|---------------|
| Iniciar US-06 a US-10 | El Sprint 2 no está liberado metodológicamente |
| Cerrar Sprint 2 por anticipado | La consistencia contractual aún no está saneada |
| Declarar listo `cases` | No existe aún prueba integrada ni rutas saneadas |

### 13.4. Regla de consistencia documental mínima

Ninguna jornada podrá considerarse cerrada si:

- el documento de conducción no refleja el estado real del proyecto;
- los gates no coinciden con la secuencia ejecutada;
- el backlog aprobado no coincide materialmente con el estado declarado del repositorio.

### 13.5. Regla de delimitación entre scaffold e implementación de dominio

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

### 13.6. Regla de cierre de jornada

Toda jornada debe cerrarse con nota formal que incluya:

- objetivo de la jornada;
- resultado alcanzado;
- pendientes;
- decisiones tomadas;
- próximo paso exacto;
- clasificación MDS del trabajo realizado.

### 13.7. Regla de cierre de etapa

Una etapa solo se considera cerrada cuando:

- todos los criterios del gate están cumplidos;
- existe evidencia verificable de cada criterio;
- el cierre queda documentado formalmente;
- este documento se actualiza reflejando el nuevo estado.

### 13.8. Autoridad de aprobación

Por tratarse de un proyecto unipersonal, la autoridad de aprobación de gates es el propio responsable del proyecto (Paul León), mediante auto-certificación documentada.

---

## 14. Conclusión ejecutiva

### 14.1. Situación

LEX_PENAL no se encuentra ya en cierre de E0, sino en un punto más avanzado: **E3 habilitada históricamente, con pausa metodológica correctiva antes de abrir Sprint 2**.

### 14.2. Logros consolidados

- E0, E1 y E2 cerradas materialmente;
- GATE-00 formalizado;
- Sprint 1 del bloque auth/users ejecutado parcialmente y validado;
- base ejecutable comprobada;
- backlog, modelo de datos y contrato API existentes;
- auditoría del repositorio ejecutada sobre evidencia primaria.

### 14.3. Bloqueo actual

El proyecto no está técnicamente detenido por falta de stack o arquitectura. Está metodológicamente bloqueado por la necesidad de absorber una desviación histórica y asegurar que la conducción oficial, el contrato API y el código real queden alineados.

### 14.4. Próximo objetivo

1. cerrar saneamiento J08-A;
2. levantar la pausa metodológica;
3. abrir Jornada 08;
4. ejecutar Sprint 2 — Gestión básica de casos;
5. preparar la prueba integrada del flujo mínimo.

### 14.5. Riesgo principal

El mayor riesgo actual no es técnico sino metodológico: permitir que una deuda técnica sensible o una inconsistencia documental se normalice como práctica tolerada.

### 14.6. Recomendación

No iniciar Sprint 2 hasta completar el bloque de saneamiento. La fiabilidad futura del MDS depende de que esta desviación quede correctamente absorbida y no se convierta en precedente.

---

## 15. Trazabilidad metodológica

### 15.1. Versión del MDS aplicada

Este documento aplica **MDS v2.2** como marco rector.

### 15.2. Coherencia con el estado real del proyecto

El estado reflejado en este documento es coherente con:

- `docs/00_gobierno/ACTA_CIERRE_GATE_00_2026-03-20.md`
- `docs/00_gobierno/NOTA_CIERRE_JORNADA_04_2026-03-20.md`
- `docs/00_gobierno/NOTA_CIERRE_JORNADA_05_2026-03-20.md`
- `docs/00_gobierno/NOTA_CIERRE_JORNADA_06_US-04__2026-03-20.md`
- `docs/00_gobierno/NOTA_CIERRE_JORNADA_07_2026-03-22.md`
- el estado del repositorio auditado al corte J08-A.

### 15.3. Nota de consistencia

Cualquier cambio posterior de estado que no quede reflejado en este documento deberá considerarse desviación de gobierno documental.

---

## 16. Control de cambios

| Versión | Fecha | Cambios |
|---------|-------|---------|
| 1.0 | 2026-03-09 | Versión inicial del sistema de conducción |
| 1.1 | 2026-03-09 | Correcciones: secuencia E0→E1, gates 3.5-05 y cronograma con semáforo |
| 1.2 | 2026-03-23 | Actualización integral post auditoría J08-A: cierre histórico de E0-E2, estado real hasta J07, pausa metodológica J08-A, ruta crítica corregida, desviaciones activas y alineación con MDS v2.2 |

---

**Fin del documento.**
