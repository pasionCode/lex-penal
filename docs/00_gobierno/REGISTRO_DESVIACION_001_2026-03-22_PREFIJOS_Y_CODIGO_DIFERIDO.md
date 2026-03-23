\# REGISTRO DE DESVIACIÓN 001



\*\*Proyecto:\*\* LEX\_PENAL  

\*\*Fecha:\*\* 2026-03-22  

\*\*ID:\*\* DESV-001  

\*\*Estado:\*\* ABIERTA EN SANEAMIENTO



\---



\## 1. Título



Desviación metodológica por mezcla de código de dominio en etapa declarada como scaffold y duplicación de prefijos de rutas API.



\---



\## 2. Descripción del hecho



Durante la auditoría del repositorio se constató:



1\. presencia de lógica de negocio en `src/modules/cases/services/caso-estado.service.ts` dentro de un tramo históricamente descrito como scaffold o infraestructura;

2\. coexistencia de `app.setGlobalPrefix('api/v1')` en `src/main.ts` con controllers que vuelven a declarar `api/v1/...`.



\---



\## 3. Contexto



La Jornada 07 reconoció la duplicación de prefijos como deuda técnica conocida.  

Sin embargo, dicha deuda no fue absorbida completamente por el circuito formal del método mediante registro autónomo de desviación, condición de levantamiento o saneamiento previo al siguiente sprint.



\---



\## 4. Impacto



\### 4.1 Impacto técnico

\- riesgo de rutas duplicadas `/api/v1/api/v1/...`

\- desalineación entre contrato API y código

\- riesgo de pruebas inválidas



\### 4.2 Impacto metodológico

\- debilita el principio de código diferido

\- permite cierre de jornada con tensión no completamente regularizada

\- genera riesgo de falsa conformidad



\---



\## 5. Causa probable



\- racionalización de código de dominio como scaffold

\- continuidad del sprint con deuda técnica reconocida pero no formalizada como desviación

\- falta de regla explícita anti-falsa conformidad en el MDS



\---



\## 6. Corrección requerida



1\. mantener prefijo global en `src/main.ts`;

2\. remover `api/v1/` de todos los decorators `@Controller(...)` que lo repiten;

3\. emitir ADR-009 de convención de rutas;

4\. actualizar contrato API;

5\. reforzar MDS con regla expresa sobre deuda técnica que afecta gates, rutas, contrato o pruebas.



\---



\## 7. Acción preventiva



A partir de esta desviación, ninguna jornada podrá cerrarse con deuda técnica que afecte contrato, rutas, pruebas o habilitación de gate sin:

\- registro formal de desviación,

\- impacto,

\- responsable,

\- prioridad,

\- condición de saneamiento.



\---



\## 8. Estado esperado de cierre



La desviación se cerrará únicamente cuando:

\- el código use una sola convención de rutas,

\- el contrato API coincida con la implementación,

\- el MDS haya sido reforzado,

\- y la nota de cierre J07 quede regularizada.

