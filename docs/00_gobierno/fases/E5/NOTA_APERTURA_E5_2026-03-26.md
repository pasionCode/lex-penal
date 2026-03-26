# NOTA DE APERTURA FASE E5 — 2026-03-26

## 1. Identificación

- **Proyecto:** LEX_PENAL
- **Fase:** E5 — Evolución controlada y preparación operativa
- **Fecha de apertura:** 2026-03-26
- **Estado:** ABIERTA
- **Prerequisito:** E4 cerrada formalmente

---

## 2. Contexto de entrada

La Fase E5 se abre una vez declarada formalmente cerrada la **Fase E4 — Consolidación post-MVP**, la cual resolvió los hallazgos de prioridad alta y media detectados tras el testing de guerrilla, y reclasificó los hallazgos de prioridad baja como backlog de evolución posterior.

En consecuencia, el sistema entra a E5 en condición de:

- backend funcional y estable en entorno local;
- contrato API alineado con el comportamiento observable del MVP vigente;
- backlog correctivo de E4 formalmente cerrado;
- backlog de evolución posterior habilitado para planificación controlada.

### Estado del proyecto al iniciar E5

| Fase | Estado |
|------|--------|
| E1 — Base ejecutable | ✅ CERRADA |
| E2 — Diseño detallado y gobierno | ✅ CERRADA |
| E3 — Construcción MVP | ✅ CERRADA |
| E3.5 — Testing de guerrilla | ✅ CERRADA |
| E4 — Consolidación post-MVP | ✅ CERRADA |
| E5 — Evolución controlada y preparación operativa | 🔄 ABIERTA |

### Evidencia heredada de cierre E4

- build exitoso del backend;
- login operativo y emisión de token JWT;
- regresión mínima verificada sobre `cases`, `timeline`, `review`, `reports` y `ai`;
- repositorio sincronizado y árbol limpio al cierre de Sprint 9;
- backlog E4 cerrado con prioridad baja diferida a Fase 2.

### Diferidos heredados desde E4

| ID | Descripción | Destino |
|----|-------------|---------|
| H-003 | Modelos `Actuacion` y `Documento` sin endpoints MVP | Fase 2 |
| H-005 | Campos extra del `HttpExceptionFilter` no documentados expresamente en contrato | Evaluación en Fase 2 |
| DT-007 | Módulo IA simplificado dentro del alcance MVP | Fase 2 |

---

## 3. Objetivo de E5

Conducir la **evolución controlada del MVP consolidado**, incorporando backlog diferido de Fase 2 y preparando, cuando corresponda, su operación en un entorno controlado y utilizable en condiciones reales.

**Fórmula ejecutiva:** E5 no existe para corregir E4 ni para forzar un deploy prematuro; existe para convertir un MVP ya estabilizado en una base funcional más madura y operativamente preparada.

---

## 4. Alcance de E5

### 4.1 Dentro de alcance

| Bloque | Descripción |
|--------|-------------|
| A | Reclasificación y aterrizaje del backlog diferido desde E4 |
| B | Definición del backlog inicial de Fase 2 |
| C | Diseño de evolución funcional controlada (`Actuacion`, `Documento`, mejoras IA) |
| D | Ajustes de contrato-código no críticos heredados (`HttpExceptionFilter`, trazabilidad de errores) |
| E | Preparación operativa para despliegue futuro |
| F | Decisiones de infraestructura, dominio, entorno y estrategia de operación |

### 4.2 Fuera de alcance inicial de E5

- despliegue inmediato a producción como obligación de arranque;
- expansión sin backlog priorizado;
- rediseño mayor de arquitectura sin evidencia previa;
- automatización avanzada (HA, clustering, CI/CD completo) salvo decisión expresa posterior;
- incorporación de nuevas verticales fuera de Fase 2.

---

## 5. Principios rectores de la fase

1. **E5 no reabre E4.** Los correctivos de consolidación ya quedaron cerrados documental y técnicamente.
2. **La evolución funcional entra con backlog, no por intuición.**
3. **Lo diferido desde E4 debe ser absorbido explícitamente.**
4. **La preparación operativa no obliga a desplegar de inmediato.**
5. **Cada nuevo bloque debe poder justificarse por valor funcional, operativo o de uso real.**

---

## 6. Objetivos específicos de arranque

### 6.1 Objetivo funcional

Definir el primer backlog operativo de Fase 2, priorizando los componentes que ya existen como modelo o necesidad, pero aún no están expresados plenamente en el backend o contrato observable.

### 6.2 Objetivo técnico

Revisar qué ajustes heredados conviene abordar primero para mejorar consistencia, claridad contractual y preparación para uso más serio del sistema.

### 6.3 Objetivo operativo

Preparar la toma de decisiones sobre infraestructura, despliegue, dominio, seguridad básica, backups y documentación de operación, sin convertir esa preparación en un mandato prematuro de salida a producción.

---

## 7. Backlog semilla de E5

### 7.1 Entrada heredada desde E4

| Prioridad inicial | ID | Descripción | Acción sugerida |
|-------------------|----|-------------|-----------------|
| Alta funcional | H-003 | `Actuacion` y `Documento` sin endpoints MVP | Analizar y convertir en historias funcionales |
| Media técnica | H-005 | Campos extra del `HttpExceptionFilter` no documentados | Decidir si se documentan, simplifican o normalizan |
| Media evolutiva | DT-007 | IA simplificada aceptable para MVP | Evaluar ruta de expansión controlada |

### 7.2 Bloques candidatos de evolución

| Bloque | Línea de trabajo | Resultado esperado |
|--------|------------------|-------------------|
| B1 | `Actuacion` | CRUD o flujo mínimo con valor procesal |
| B2 | `Documento` | Gestión mínima documental asociada al caso |
| B3 | IA fase siguiente | Definir alcance realista post-placeholder |
| B4 | Contrato de errores | Decidir profundidad real del contrato observable |
| B5 | Preparación operativa | Definir entorno destino, variables, backup, monitoreo |

---

## 8. Criterios de apertura cumplidos

- [x] E4 cerrada formalmente
- [x] Backlog correctivo E4 cerrado
- [x] Diferidos identificados y trazables
- [x] MVP consolidado sin bloqueantes críticos conocidos
- [x] Recomendación metodológica de transición a siguiente fase emitida

---

## 9. Criterios de cierre esperados para E5

La Fase E5 podrá considerarse cerrada cuando, como mínimo:

- exista backlog priorizado de Fase 2 ejecutado o claramente delimitado;
- los diferidos heredados de E4 hayan sido absorbidos, resueltos o replanificados con trazabilidad;
- exista definición suficiente del siguiente salto funcional del sistema;
- quede establecida una estrategia operativa razonable para despliegue o uso controlado;
- el proyecto salga de E5 con mayor madurez funcional y operativa que al inicio.

---

## 10. Riesgos de la fase

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Abrir E5 como “deploy puro” y dejar sin absorber Fase 2 | Media | Alto | Mantener backlog funcional explícito |
| Expandir sin priorización | Media | Alto | Definir backlog semilla antes de ejecutar |
| Tomar decisiones de infraestructura demasiado pronto | Media | Medio | Preparar primero, desplegar después |
| Reabrir discusiones ya cerradas en E4 | Baja | Medio | Respetar cierre documental de E4 |
| Inflar E5 con demasiadas líneas simultáneas | Media | Alto | Ejecutar por bloques y con criterio de valor |

---

## 11. Entregables iniciales de E5

| Entregable | Descripción |
|------------|-------------|
| Nota de apertura E5 | Apertura formal de fase |
| Backlog semilla E5 / Fase 2 | Priorización inicial de evolución |
| Decisión de línea dominante | Qué entra primero: funcional, IA o preparación operativa |
| Micronota o Sprint inicial E5 | Primer bloque ejecutable de la fase |

---

## 12. Decisión operativa inmediata

Como efecto del cierre de E4 y de la apertura de E5, la decisión operativa inmediata es:

1. **no abrir más sprints dentro de E4**;
2. **trasladar formalmente los diferidos al backlog de E5 / Fase 2**;
3. **definir el primer bloque dominante de E5** antes de hablar de despliegue a producción como objetivo único.

---

## 13. Cierre ejecutivo de apertura

**La Fase E5 queda formalmente abierta** como etapa de **evolución controlada y preparación operativa** del proyecto LEX_PENAL.

Su función no es repetir la consolidación post-MVP ya cumplida en E4, sino tomar un MVP estabilizado y conducirlo ordenadamente hacia su siguiente nivel de desarrollo funcional y madurez operativa.

---

**FASE E5 ABIERTA — 2026-03-26**
