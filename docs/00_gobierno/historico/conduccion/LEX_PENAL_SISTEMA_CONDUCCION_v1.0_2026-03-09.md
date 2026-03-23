# LEX_PENAL — Sistema de Conducción del Proyecto

**Versión:** 1.1  
**Fecha:** 2026-03-09  
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

- **METODOLOGIA_DESARROLLO_SOFTWARE_v2.1.md** — Manual metodológico institucional

### 2.2. Principios vinculantes

| Principio | Aplicación en LEX_PENAL |
|-----------|-------------------------|
| Secuencia obligatoria | No se ejecuta trabajo de una etapa sin cerrar la anterior |
| Código diferido | Código productivo solo desde E3; código de infraestructura en E1-E2 |
| Decisión explícita | Toda decisión arquitectónica queda en ADRs |
| Verificabilidad | Todo avance se evidencia con artefactos verificables |
| Iteración ordenada | Los ajustes siguen el protocolo de desviación |

### 2.3. Documentos canónicos del proyecto

| Documento | Ubicación | Propósito |
|-----------|-----------|-----------|
| MODELO_DATOS_v3 | docs/03_datos/ | Modelo de datos canónico |
| CONTRATO_API_v4 | docs/04_api/ | Contrato de API REST |
| ARQUITECTURA_MODULO_IA_v3 | docs/12_ia/ | Arquitectura del módulo de IA |
| REGLAS_FUNCIONALES_VINCULANTES | docs/14_legal_funcional/ | Reglas de negocio obligatorias |
| ADRs (8 documentos) | docs/00_gobierno/adrs/ | Decisiones arquitectónicas |

---

## 3. Estado del proyecto

### 3.1. Contexto

LEX_PENAL es un sistema de gestión de casos de defensa penal colombiana, orientado a consultorios jurídicos universitarios. El proyecto inició antes de la adopción formal del MDS, lo cual generó vacíos metodológicos que están siendo regularizados.

### 3.2. Situación actual

| Aspecto | Estado |
|---------|--------|
| **Fase del proyecto** | Cierre de E0 (regularización) |
| **Última jornada cerrada** | Jornada 03 (2026-03-08) |
| **Etapa MDS activa** | E0 en cierre |
| **Bloqueo principal** | GATE-00 pendiente (criterios de éxito) |
| **Próximo hito** | H-00b — Criterios de éxito definidos |

### 3.3. Regularización metodológica

El proyecto arrancó con documentación técnica significativa pero sin formalización MDS. La regularización en curso incluye:

| Vacío detectado | Estado de corrección |
|-----------------|---------------------|
| Etapa 0 no cerrada formalmente | En cierre |
| Criterios de éxito no definidos | Pendiente (bloquea GATE-00) |
| Cronograma macro no establecido | ✅ Establecido en este documento |
| Gates no formalizados | ✅ Formalizados en este documento |
| Jornadas sin cierre formal | ✅ Corregido desde Jornada 03 |

---

## 4. Ruta maestra de LEX_PENAL

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      RUTA MAESTRA — LEX_PENAL                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  E0                 E1                 E2                E3                 │
│  Preconstrucción    Base               Diseño            MVP                │
│  + Regularización   Ejecutable         Detallado         Funcional          │
│                                                                             │
│  [EN CIERRE]        [BLOQUEADA]        [BLOQUEADA]       [BLOQUEADA]        │
│                                                                             │
│  Gate: GATE-00      Gate: GATE-01      Gate: GATE-02     Gate: GATE-03      │
│  Estado: Parcial    Estado: Pendiente  Estado: Pendiente Estado: Pendiente  │
│                                                                             │
│  ───────────────────────────────────────────────────────────────────────   │
│                                                                             │
│  E3.5               E4                 E5                                   │
│  Ajuste de          Revisión           Consolidación                        │
│  Realidad           Arquitectónica     y Expansión                          │
│                                                                             │
│  [BLOQUEADA]        [BLOQUEADA]        [BLOQUEADA]                          │
│  Gate: GATE-3.5     Gate: GATE-04      Gate: GATE-05                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.1. Regla de secuencia

Conforme al principio de secuencia obligatoria del MDS v2.1:

> **E1 solo puede iniciarse tras superar GATE-00. No hay ejecución en paralelo.**

El proyecto LEX_PENAL, aunque tiene documentación técnica avanzada, debe cerrar formalmente E0 antes de iniciar E1.

---

## 5. Etapas oficiales del proyecto

### 5.1. ETAPA 0 — Preconstrucción + Regularización

| Atributo | Valor |
|----------|-------|
| **Estado** | EN CIERRE |
| **Inicio** | Anterior a adopción MDS |
| **Cierre previsto** | Al superar GATE-00 |
| **Responsable** | Paul León |
| **Código permitido** | Ninguno |

**Entregables requeridos:**

| Entregable | Estado | Ubicación |
|------------|--------|-----------|
| Documento de visión | ✅ Existente | docs/01_producto/ |
| Alcance y exclusiones | ✅ Existente | docs/01_producto/ |
| Análisis de dominio | ✅ Existente | docs/01_producto/ |
| Decisiones de arquitectura | ✅ 8 ADRs | docs/00_gobierno/adrs/ |
| Flujo crítico identificado | ✅ Documentado | REGLAS_FUNCIONALES |
| RNF mínimos | ✅ Documentado | docs/08_seguridad/ |
| Criterios de éxito | ⚠️ **Pendiente** | Por definir |
| Cronograma macro | ✅ Este documento | docs/00_gobierno/ |
| Ruta crítica | ✅ Este documento | docs/00_gobierno/ |

**Vacío bloqueante:**

Definir criterios de éxito medibles para MVP. Sin este entregable, GATE-00 no puede cerrarse.

---

### 5.2. ETAPA 1 — Base Ejecutable

| Atributo | Valor |
|----------|-------|
| **Estado** | BLOQUEADA (requiere GATE-00) |
| **Inicio previsto** | Jornada 04 (post GATE-00) |
| **Cierre previsto** | Jornada 04-05 |
| **Responsable** | Paul León |
| **Código permitido** | Exploratorio + Infraestructura |

**Objetivo:** Validar que el stack NestJS + Prisma + PostgreSQL funciona como base ejecutable real.

**Entregables requeridos:**

| Entregable | Criterio de aceptación |
|------------|------------------------|
| .env configurado | Archivo presente con variables válidas |
| prisma validate | Salida sin errores |
| prisma generate | Cliente generado en node_modules/@prisma/client |
| Migración inicial | prisma/migrations/ con migración aplicada |
| npm run build | Directorio dist/ generado sin errores |
| Arranque local | Servidor respondiendo en localhost:3001 |

**Particularidad:** Esta etapa no es PoC exploratorio porque el stack ya fue decidido (ADR-001, ADR-002, ADR-006). Es validación de base ejecutable.

---

### 5.3. ETAPA 2 — Diseño Detallado

| Atributo | Valor |
|----------|-------|
| **Estado** | BLOQUEADA (requiere GATE-01) |
| **Inicio previsto** | Post GATE-01 |
| **Responsable** | Paul León |
| **Código permitido** | Infraestructura (scaffolds, configuración) |

**Particularidad:** Gran parte del diseño ya existe (MODELO_DATOS_v3, CONTRATO_API_v4). Esta etapa se enfoca en:

- Validar coherencia entre documentos canónicos y scaffold
- Completar DTOs y validaciones
- Definir Definition of Done del proyecto
- Priorizar backlog de verticales

---

### 5.4. ETAPA 3 — MVP Funcional

| Atributo | Valor |
|----------|-------|
| **Estado** | BLOQUEADA (requiere GATE-02) |
| **Inicio previsto** | Post GATE-02 |
| **Responsable** | Paul León |
| **Código permitido** | Productivo (lógica de negocio) |

**Flujo crítico de LEX_PENAL:**

1. Autenticación (login, sesión, perfiles)
2. Crear caso con datos básicos
3. Transicionar caso por máquina de estados
4. Registrar hechos y pruebas
5. Consultar IA para análisis
6. Generar informe
7. Supervisor revisa y aprueba
8. Caso pasa a cliente y cierra

**Verticales de implementación:**

| Vertical | Prioridad | Dependencias |
|----------|-----------|--------------|
| auth | P1 | Base ejecutable |
| users | P1 | auth |
| cases | P1 | users |
| facts | P2 | cases |
| evidence | P2 | facts |
| risks | P2 | cases |
| strategy | P2 | risks |
| checklist | P2 | cases |
| review | P2 | checklist |
| ai | P3 | cases + contexto |
| reports | P3 | cases + datos |

---

### 5.5. ETAPA 3.5 — Ajuste de Realidad

| Atributo | Valor |
|----------|-------|
| **Estado** | BLOQUEADA (requiere GATE-03) |
| **Responsable** | Paul León |

**Objetivo:** Validar MVP con usuarios reales o representativos del consultorio jurídico.

---

### 5.6. ETAPA 4 — Revisión Arquitectónica

| Atributo | Valor |
|----------|-------|
| **Estado** | BLOQUEADA (requiere GATE-3.5) |
| **Responsable** | Paul León |

**Objetivo:** Evaluar si la arquitectura requiere ajustes basándose en hallazgos de uso real.

---

### 5.7. ETAPA 5 — Consolidación y Expansión

| Atributo | Valor |
|----------|-------|
| **Estado** | BLOQUEADA (requiere GATE-04) |
| **Responsable** | Paul León |

**Objetivo:** Estabilizar MVP y habilitar expansión modular.

---

## 6. Hitos de control

| ID | Hito | Etapa | Criterio de cumplimiento | Estado |
|----|------|-------|--------------------------|--------|
| H-00a | Documentación canónica completa | E0 | Todos los documentos en repositorio | ✅ Cumplido |
| H-00b | Criterios de éxito definidos | E0 | Documento con métricas medibles | ⚠️ **Pendiente** |
| H-01 | Base ejecutable funcionando | E1 | Servidor arrancando, BD conectada | 🔒 Bloqueado |
| H-02 | Diseño detallado completo | E2 | Backlog, DoD, infraestructura lista | 🔒 Bloqueado |
| H-03 | Flujo crítico end-to-end | E3 | Caso completo desde creación hasta cierre | 🔒 Bloqueado |
| H-3.5 | Validación con usuarios | E3.5 | 3-5 sesiones de testing completadas | 🔒 Bloqueado |
| H-04 | Decisión arquitectónica post-uso | E4 | ADR de consolidación documentado | 🔒 Bloqueado |
| H-05 | MVP en producción estable | E5 | Sistema operando sin intervención | 🔒 Bloqueado |

---

## 7. Gates de paso

### 7.1. GATE-00 — Cierre de Etapa 0

| Criterio | Evidencia | Estado |
|----------|-----------|--------|
| Documento de visión completo | docs/01_producto/ | ✅ |
| Alcance y exclusiones documentados | docs/01_producto/ | ✅ |
| Dominio analizado | Documentos canónicos | ✅ |
| Stack decidido con ADRs | 8 ADRs en repositorio | ✅ |
| Flujo crítico identificado | REGLAS_FUNCIONALES | ✅ |
| RNF documentados | docs/08_seguridad/ | ✅ |
| Criterios de éxito definidos | Por documentar | ⚠️ **Pendiente** |
| Cronograma macro establecido | Este documento | ✅ |
| Ruta crítica documentada | Este documento | ✅ |

**Estado del gate:** PARCIALMENTE CUMPLIDO  
**Bloqueo:** Criterios de éxito pendientes  
**Acción requerida:** Documentar criterios de éxito medibles para MVP  
**Autoridad de aprobación:** Paul León (auto-certificación, proyecto unipersonal)

---

### 7.2. GATE-01 — Cierre de Etapa 1 (Base Ejecutable)

| Criterio | Evidencia | Estado |
|----------|-----------|--------|
| .env configurado | Archivo en local (no versionado) | 🔒 Bloqueado |
| npx prisma validate | Salida sin errores | 🔒 Bloqueado |
| npx prisma generate | Cliente en node_modules | 🔒 Bloqueado |
| Migración inicial | prisma/migrations/ | 🔒 Bloqueado |
| npm run build | dist/ generado | 🔒 Bloqueado |
| Arranque local | localhost:3001 respondiendo | 🔒 Bloqueado |

**Estado del gate:** BLOQUEADO (requiere GATE-00)  
**Habilitación:** Tras superar GATE-00  
**Jornada objetivo:** Jornada 04

---

### 7.3. GATE-02 — Cierre de Etapa 2

| Criterio | Evidencia | Estado |
|----------|-----------|--------|
| Backlog priorizado | Documento de backlog | 🔒 Bloqueado |
| Modelo de datos validado | schema.prisma + migración | 🔒 Bloqueado |
| API definida | CONTRATO_API_v4 vigente | ✅ Existente |
| Definition of Done acordada | Documento DoD | 🔒 Bloqueado |
| Infraestructura lista | Proyecto compila, BD conecta | 🔒 Bloqueado |

**Estado del gate:** BLOQUEADO (requiere GATE-01)

---

### 7.4. GATE-03 — Cierre de Etapa 3

| Criterio | Evidencia | Estado |
|----------|-----------|--------|
| Flujo crítico funcionando | Demostración end-to-end | 🔒 Bloqueado |
| Despliegue accesible | URL de staging | 🔒 Bloqueado |
| Listo para testing | Checklist E3 completo | 🔒 Bloqueado |

**Estado del gate:** BLOQUEADO (requiere GATE-02)

---

### 7.5. GATE-3.5 — Cierre de Etapa 3.5

| Criterio | Evidencia | Estado |
|----------|-----------|--------|
| Sesiones de testing completadas | Registro de sesiones | 🔒 Bloqueado |
| Informe de Ajuste de Realidad | Documento de hallazgos | 🔒 Bloqueado |
| Decisiones de ajuste tomadas | Backlog actualizado | 🔒 Bloqueado |

**Estado del gate:** BLOQUEADO (requiere GATE-03)

---

### 7.6. GATE-04 — Cierre de Etapa 4

| Criterio | Evidencia | Estado |
|----------|-----------|--------|
| Decisión arquitectónica documentada | ADR o documento de decisión | 🔒 Bloqueado |
| Plan de acción definido | Documento de próximos pasos | 🔒 Bloqueado |

**Estado del gate:** BLOQUEADO (requiere GATE-3.5)

---

### 7.7. GATE-05 — Cierre de Etapa 5 (Cierre de proyecto)

| Criterio | Evidencia | Estado |
|----------|-----------|--------|
| MVP estable en producción | Sistema funcionando | 🔒 Bloqueado |
| Documentación técnica completa | Arquitectura, API documentados | 🔒 Bloqueado |
| Responsable de operación asignado | Acta de transferencia | 🔒 Bloqueado |
| Criterios de éxito alcanzados | Métricas verificadas | 🔒 Bloqueado |

**Estado del gate:** BLOQUEADO (requiere GATE-04)

---

## 8. Cronograma macro

### 8.1. Tabla de control temporal

| Etapa | Duración estimada | Inicio objetivo | Cierre objetivo | Inicio real | Cierre real | Desviación | Semáforo |
|-------|-------------------|-----------------|-----------------|-------------|-------------|------------|----------|
| E0 | (pre-MDS) | Pre-MDS | J04 | Pre-MDS | — | Regularización | 🟡 |
| E1 | 1-2 jornadas | Post GATE-00 | J05 | — | — | — | ⚪ |
| E2 | 2-3 jornadas | Post J05 | J08 | — | — | — | ⚪ |
| E3 | 8-12 jornadas | Post J08 | J20 | — | — | — | ⚪ |
| E3.5 | 2-3 jornadas | Post J20 | J23 | — | — | — | ⚪ |
| E4 | 1-2 jornadas | Post J23 | J25 | — | — | — | ⚪ |
| E5 | Variable | Post J25 | Por definir | — | — | — | ⚪ |

### 8.2. Leyenda de semáforo

| Semáforo | Significado |
|----------|-------------|
| 🟢 Verde | Etapa cerrada a tiempo o con desviación ≤10% |
| 🟡 Amarillo | Desviación entre 10% y 20%, o en regularización |
| 🔴 Rojo | Desviación >20% o bloqueada sin resolución |
| ⚪ Gris | Etapa no iniciada |

### 8.3. Jornadas completadas

| Jornada | Fecha | Etapa | Objetivo | Resultado | Cierre formal |
|---------|-------|-------|----------|-----------|---------------|
| J01 | Pre-MDS | E0 | Documentación inicial | Documentos canónicos creados | No (pre-MDS) |
| J02 | Pre-MDS | E0 | Scaffold inicial | Estructura src/ generada | No (pre-MDS) |
| J03 | 2026-03-08 | E0 | Regularización técnica | Auditoría + Prisma + CasoEstadoService | ✅ Sí |

### 8.4. Próxima jornada

| Jornada | Fecha prevista | Etapa | Objetivo | Gate objetivo |
|---------|----------------|-------|----------|---------------|
| J04 | Post GATE-00 | E1 | Base ejecutable funcionando | GATE-01 |

**Condición previa:** GATE-00 debe cerrarse antes de iniciar J04.

---

## 9. Ruta crítica y dependencias

### 9.1. Registro de ruta crítica

| ID | Actividad/Entregable | Etapa | Dependencias | Fecha objetivo | Fecha real | Estado | Impacto si retrasa |
|----|---------------------|-------|--------------|----------------|------------|--------|-------------------|
| RC-01 | Criterios de éxito definidos | E0 | — | J04 | — | ⏳ En curso | Bloquea GATE-00 y toda la cadena |
| RC-02 | GATE-00 cerrado | E0 | RC-01 | J04 | — | 🔒 Bloqueado | Bloquea inicio de E1 |
| RC-03 | Base ejecutable validada | E1 | RC-02 | J05 | — | 🔒 Bloqueado | Bloquea desarrollo funcional |
| RC-04 | GATE-01 cerrado | E1 | RC-03 | J05 | — | 🔒 Bloqueado | Bloquea diseño detallado |
| RC-05 | Infraestructura lista | E2 | RC-04 | J08 | — | 🔒 Bloqueado | Bloquea código productivo |
| RC-06 | GATE-02 cerrado | E2 | RC-05 | J08 | — | 🔒 Bloqueado | Bloquea MVP |
| RC-07 | Flujo crítico funcionando | E3 | RC-06 | J20 | — | 🔒 Bloqueado | Bloquea testing |
| RC-08 | GATE-03 cerrado | E3 | RC-07 | J20 | — | 🔒 Bloqueado | Bloquea ajuste de realidad |

### 9.2. Elemento crítico inmediato

**RC-01: Criterios de éxito definidos**

Este es el único elemento desbloqueado en la ruta crítica. Su resolución habilita toda la cadena posterior.

### 9.3. Dependencias técnicas (E1)

| Dependencia | Tipo | Impacto si falla |
|-------------|------|------------------|
| PostgreSQL disponible | Infraestructura | Bloquea migración y desarrollo |
| Prisma genera cliente | Técnica | Bloquea acceso a BD desde código |
| NestJS compila | Técnica | Bloquea ejecución del servidor |
| Variables de entorno | Configuración | Bloquea arranque |

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
| DEV-001 | Proceso | Proyecto inició sin MDS formal | Adopción tardía de MDS | Regularización necesaria | Cerrar E0 formalmente | Paul León | En corrección |
| DEV-002 | Alcance | Criterios de éxito no definidos en E0 | Omisión en arranque | Bloquea GATE-00 | Documentar en próxima jornada | Paul León | **Pendiente** |

### 10.2. Desviaciones históricas (resueltas)

| ID | Tipo | Descripción | Resolución | Fecha |
|----|------|-------------|------------|-------|
| DEV-003 | Proceso | Jornadas 01-02 sin cierre formal | Regularizado desde J03 | 2026-03-08 |

---

## 11. Estado actual y fase activa

### 11.1. Resumen ejecutivo

| Dimensión | Estado |
|-----------|--------|
| **Etapa activa** | E0 (en cierre) |
| **Gate pendiente** | GATE-00 (parcialmente cumplido) |
| **Bloqueo principal** | Criterios de éxito no definidos |
| **Última jornada** | J03 cerrada satisfactoriamente |
| **Compilación** | ✅ TypeScript compila sin errores |
| **Dependencias** | ✅ npm install exitoso |
| **Prisma** | ⚠️ Pendiente validación operativa (E1) |
| **Base de datos** | ⚠️ Pendiente conexión (E1) |
| **Servidor** | ⚠️ Pendiente arranque (E1) |

### 11.2. Artefactos listos

| Artefacto | Estado | Ubicación |
|-----------|--------|-----------|
| schema.prisma | ✅ 758 líneas, 18 modelos, 19 enums | prisma/ |
| CasoEstadoService | ✅ Implementado | src/modules/cases/services/ |
| caso-estado.constants | ✅ Implementado | src/modules/cases/constants/ |
| package.json | ✅ Configurado | raíz |
| tsconfig.json | ✅ Configurado | raíz |
| .env.example | ✅ Plantilla lista | raíz |

### 11.3. Artefactos pendientes para E1

| Artefacto | Acción requerida | Etapa |
|-----------|------------------|-------|
| .env | Crear desde .env.example con valores reales | E1 |
| Cliente Prisma | npx prisma generate | E1 |
| Migración | npx prisma migrate dev --name init | E1 |
| dist/ | npm run build | E1 |

---

## 12. Próximo hito y condiciones de habilitación

### 12.1. Próximo hito inmediato

**H-00b — Criterios de éxito definidos**

### 12.2. Condiciones para cerrar GATE-00

| Condición | Estado |
|-----------|--------|
| Todos los entregables de E0 completados | ⚠️ Falta criterios de éxito |
| Cronograma macro establecido | ✅ |
| Ruta crítica documentada | ✅ |

### 12.3. Acción requerida

Definir criterios de éxito medibles para MVP de LEX_PENAL. Formato sugerido:

| Criterio de éxito | Métrica | Meta MVP |
|-------------------|---------|----------|
| [Por definir] | [Por definir] | [Por definir] |

### 12.4. Secuencia post GATE-00

```
1. Cerrar GATE-00 (criterios de éxito)
2. Iniciar Jornada 04 (E1)
3. Crear .env desde .env.example
4. Levantar PostgreSQL (Docker o local)
5. npx prisma format
6. npx prisma validate
7. npx prisma generate
8. npx prisma migrate dev --name init
9. npm run build
10. npm run start:dev
11. Verificar localhost:3001 responde
12. Documentar evidencia
13. Cerrar GATE-01
```

---

## 13. Reglas de gobierno del avance

### 13.1. Regla de secuencia

> **Ninguna etapa puede iniciarse sin haber superado el gate de la etapa anterior.**

Esta regla es vinculante. No hay excepciones de ejecución en paralelo.

### 13.2. Prohibiciones mientras GATE-00 no cierre

| Actividad prohibida | Justificación |
|---------------------|---------------|
| Iniciar Jornada 04 | E1 no está habilitada |
| Ejecutar validación de base ejecutable | Corresponde a E1 |
| Comprometer fechas de funcionalidades | E0 no está cerrada |

### 13.3. Prohibiciones mientras GATE-01 no cierre

| Actividad prohibida | Justificación |
|---------------------|---------------|
| Implementar lógica de negocio | No hay base ejecutable validada |
| Crear endpoints funcionales | No hay servidor funcionando |
| Escribir tests de integración | No hay BD para testear |
| Definir sprints de desarrollo | No hay base sobre la cual desarrollar |

### 13.4. Actividades permitidas durante E0

| Actividad permitida | Condición |
|---------------------|-----------|
| Definir criterios de éxito | Obligatorio para cerrar GATE-00 |
| Actualizar documentación | Siempre |
| Corregir este documento | Si hay cambios de estado |

### 13.5. Regla de cierre de jornada

Toda jornada debe cerrarse con nota formal que incluya:

- Objetivo de la jornada
- Resultado alcanzado
- Pendientes
- Decisiones tomadas
- Próximo paso exacto
- Clasificación MDS del trabajo realizado

### 13.6. Regla de cierre de etapa

Una etapa solo se considera cerrada cuando:

- Todos los criterios del gate están cumplidos
- Existe evidencia verificable de cada criterio
- El cierre queda documentado formalmente
- Este documento se actualiza reflejando el nuevo estado

### 13.7. Autoridad de aprobación

Por tratarse de un proyecto unipersonal, la autoridad de aprobación de gates es el propio responsable del proyecto (Paul León), mediante auto-certificación documentada.

---

## 14. Conclusión ejecutiva

### 14.1. Situación

LEX_PENAL se encuentra en cierre de Etapa 0, con un único entregable pendiente: **criterios de éxito medibles**.

### 14.2. Logros de la fase actual

- Auditoría técnica del scaffold completada
- Schema Prisma incorporado (18 modelos, 19 enums)
- CasoEstadoService implementado como punto único de transición
- Compilación TypeScript exitosa
- Documentación de gobierno actualizada
- Sistema de conducción formalizado
- Todos los gates documentados (GATE-00 a GATE-05)

### 14.3. Bloqueo actual

GATE-00 está parcialmente cumplido. Falta definir criterios de éxito medibles.

### 14.4. Próximo objetivo

1. Definir criterios de éxito para MVP
2. Cerrar GATE-00
3. Iniciar E1 (Jornada 04)
4. Cerrar GATE-01 (base ejecutable funcionando)

### 14.5. Riesgo principal

Si la validación de base ejecutable falla en E1 (problemas de conexión, migración, o arranque), el proyecto queda bloqueado hasta resolver. No hay alternativa porque el stack ya fue decidido.

### 14.6. Recomendación

Antes de iniciar Jornada 04, cerrar formalmente GATE-00 con la definición de criterios de éxito. Esto garantiza coherencia con el principio de secuencia obligatoria del MDS.

---

## 15. Trazabilidad metodológica

### 15.1. Versión del MDS aplicada

Este documento aplica **MDS v2.1** como marco rector.

### 15.2. Coherencia con Nota de Cierre de Jornada 03

El estado reflejado en este documento es coherente con la Nota de Cierre de Jornada 03 (2026-03-08), que:

- Dejó preparada la validación de base ejecutable
- No habilitó verticales funcionales
- Clasificó el trabajo como fase de preparación y base técnica

---

## 16. Control de cambios

| Versión | Fecha | Cambios |
|---------|-------|---------|
| 1.0 | 2026-03-09 | Versión inicial del sistema de conducción |
| 1.1 | 2026-03-09 | Correcciones: (1) E1 bloqueada hasta GATE-00, sin excepción de paralelo; (2) Removido backlog del manual; (3) Gates 3.5-05 documentados; (4) Cronograma con fecha real, desviación y semáforo |

---

**Fin del documento.**
