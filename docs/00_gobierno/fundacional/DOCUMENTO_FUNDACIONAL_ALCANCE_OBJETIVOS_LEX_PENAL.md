# DOCUMENTO FUNDACIONAL DE ALCANCE Y OBJETIVOS — LEX_PENAL

## 1. Identificación

- Proyecto: LEX_PENAL
- Naturaleza del documento: pieza fundacional de gobierno
- Versión: 1.0
- Propósito documental: explicitar el alcance, los objetivos, la razón de ser y la arquitectura conceptual del proyecto
- Relación con otros documentos:
  - Fuente sustantiva primaria: Manual General de Resolución de Casos Penales 2.0
  - Fuente metodológica de ejecución: MDS
  - Fuente funcional-operativa: CONTRATO_API
  - Fuente de trazabilidad: ADRs, notas de fase, baselines y cierres

## 2. Origen de la presente formalización

Durante la evolución del proyecto se consolidó gobierno metodológico, contrato funcional y trazabilidad por fases, pero no quedó formalizado en pieza autónoma el núcleo fundacional de producto. La sustancia de ese núcleo sí existe y se encuentra desarrollada en el Manual General de Resolución de Casos Penales 2.0. Este documento se emite para decantar esa sustancia y convertirla en una referencia explícita de gobierno del proyecto.

## 3. Fuente material primaria

La fuente material primaria de este documento es el Manual General de Resolución de Casos Penales 2.0, del cual se extraen y formalizan la descripción del proyecto, su objetivo general, sus objetivos específicos, su justificación, su metodología estructural y su delimitación de alcance y límites.

## 4. Naturaleza del proyecto

LEX_PENAL es un proyecto jurídico-tecnológico orientado a estructurar, soportar y operativizar un método general de resolución de casos penales en Colombia, con énfasis en la perspectiva de la defensa.

Su naturaleza no es la de un simple compendio normativo, ni la de un manual procesal clásico, ni la de un repositorio de respuestas tipo. Su fundamento sustantivo es el de un sistema de resolución de casos que articula análisis dogmático, técnica procesal, valoración probatoria, estimación punitiva, estrategia de defensa y herramientas operativas de trabajo.

## 5. Problema que el proyecto viene a resolver

El proyecto surge de la constatación de una fragmentación persistente en la práctica y en la formación penal:

- la dogmática penal suele estudiarse separada del expediente real;
- el procedimiento penal suele enseñarse sin articulación suficiente con la estrategia;
- la litigación suele abordarse sin integración rigurosa con el análisis jurídico-sustancial;
- y el trabajo defensivo corre el riesgo de improvisación, omisión o mala priorización cuando no existe un método integrado.

LEX_PENAL busca cerrar esa brecha mediante una estructura que permita ordenar el análisis del caso penal real, disminuir omisiones, mejorar la calidad de la decisión defensiva y reforzar la capacidad de explicación estratégica al cliente.

## 6. Propósito general del proyecto

El propósito general de LEX_PENAL es proporcionar una base metodológica, operativa y progresivamente sistematizable para el análisis y la resolución de casos penales en Colombia, desde la perspectiva de la defensa, de forma que el usuario pueda:

- identificar con rigor los problemas jurídicos del caso;
- construir una hipótesis defensiva fundada;
- evaluar el panorama probatorio, procesal y punitivo;
- definir una estrategia razonable de actuación;
- y documentar el caso mediante herramientas que reduzcan el riesgo de omisiones.

## 7. Objetivos específicos del proyecto

LEX_PENAL adopta como objetivos específicos estructurales los siguientes:

1. Desarrollar capacidad de lectura jurídica de los hechos.
2. Permitir la formulación precisa del problema jurídico del caso.
3. Aplicar al caso concreto el método dogmático penal.
4. Evaluar el soporte probatorio del caso.
5. Identificar la ruta procesal aplicable y las oportunidades de actuación.
6. Valorar el panorama punitivo y los mecanismos de reducción de riesgo.
7. Construir y comunicar una estrategia de defensa.
8. Utilizar herramientas operativas estandarizadas para sistematizar el análisis.

## 8. Alcance sustantivo inicial del proyecto

El alcance sustantivo inicial de LEX_PENAL comprende:

- análisis general de casos penales en Colombia;
- enfoque principal en el sistema acusatorio vigente;
- aplicabilidad transversal a cualquier tipo de delito dentro de un tronco metodológico común;
- cobertura metodológica de hechos, problema jurídico, dogmática, prueba, procedimiento, riesgo, pena, beneficios, estrategia y conclusión operativa;
- utilidad tanto para formación práctica como para ejercicio profesional inicial o estructuración temprana del caso.

## 9. Límites y exclusiones fundacionales

LEX_PENAL no pretende:

- sustituir la ley vigente;
- sustituir la jurisprudencia actualizada;
- sustituir el juicio profesional sobre el caso concreto;
- cubrir exhaustivamente todos los regímenes penales especiales en su detalle técnico;
- convertir el análisis penal en un formulario automático;
- ni reemplazar la responsabilidad profesional del abogado o del operador jurídico.

En consecuencia, todo uso del sistema debe respetar estas exclusiones estructurales y reconocer que la herramienta ordena el análisis, pero no reemplaza la deliberación jurídica.

## 10. Arquitectura conceptual del proyecto

La arquitectura conceptual fundacional de LEX_PENAL se organiza así:

### 10.1. Bloque de apertura

Contiene identidad, objetivos, justificación, metodología, alcance y límites.

### 10.2. Tronco común metodológico

Desarrolla el método general de resolución de casos penales aplicable de manera transversal.

### 10.3. Herramientas operativas

Convierte el método en instrumentos de uso concreto:

- fichas
- matrices
- checklists
- formatos de estrategia
- formatos de conclusión operativa

### 10.4. Módulos especiales o extensiones futuras

Permiten adaptar el tronco común a categorías delictivas o escenarios específicos sin romper la unidad metodológica del sistema.

## 11. Traducción del alcance fundacional al proyecto tecnológico

En su dimensión tecnológica, LEX_PENAL debe entenderse como una implementación progresiva y controlada del sistema descrito en el apartado anterior.

La plataforma, backend, flujos, CONTRATO_API y recursos operativos del sistema no constituyen un proyecto separado del manual, sino una traducción funcional y escalable de su lógica fundacional.

Por tanto:

- el backend debe expresar el ciclo metodológico del caso;
- los recursos funcionales deben responder a operaciones reales del método;
- y el crecimiento del sistema debe mantenerse fiel al tronco común definido en este documento.

## 12. Relación con el MDS

El MDS gobierna la forma en que el proyecto se construye, valida, documenta, endurece y cierra sus iteraciones.

Este documento no regula el método de ejecución técnica ni el régimen de fases; regula el marco fundacional del proyecto.

Relación entre ambos:

- este documento responde al para qué, qué y hasta dónde del proyecto;
- el MDS responde al cómo se gobierna su construcción, validación, cierre y evolución.

En caso de duda:

- la identidad, alcance y razón de ser del proyecto se reconstruyen desde este documento y desde el manual;
- la disciplina operativa de implementación se rige por el MDS.

## 13. Relación con el alcance MVP ya construido

El MVP backend desarrollado hasta la fecha debe interpretarse como una primera materialización técnica del núcleo metodológico del proyecto.

Su valor no radica solo en exponer endpoints, sino en comenzar a representar operativamente componentes tales como:

- ciclo del caso;
- hechos;
- evidencia;
- riesgos;
- estrategia;
- briefing;
- checklist;
- conclusión;
- revisión;
- y soporte inicial de consulta asistida, en el alcance efectivamente implementado.

La fidelidad del MVP no debe medirse únicamente por completitud técnica, sino por su correspondencia con la lógica fundacional aquí definida.

## 14. Criterio de fidelidad del proyecto

Se entenderá que LEX_PENAL permanece fiel a su propuesta inicial cuando:

- conserve el enfoque de defensa penal;
- mantenga un tronco metodológico general y no se degrade a repositorio caótico de funciones;
- preserve la articulación entre hechos, dogmática, prueba, procedimiento, pena y estrategia;
- integre herramientas de control de calidad y reducción de omisiones;
- y haga evolucionar su capa tecnológica sin desprenderse de la arquitectura conceptual originaria.

## 15. Criterio de desalineación

Se entenderá que existe desalineación fundacional cuando ocurra cualquiera de estos eventos:

- el sistema técnico crece sin relación clara con el método del caso penal;
- aparecen flujos funcionales sin sustento en el tronco común;
- se privilegia acumulación de endpoints sobre coherencia metodológica;
- se sustituyen decisiones jurídicas por automatismos no gobernados;
- o se pierde el enfoque de defensa como eje de lectura del proyecto.

## 16. Puerta mínima hacia pruebas de realidad

Antes de pruebas de realidad, el proyecto deberá verificar, como mínimo:

- correspondencia entre alcance fundacional y alcance efectivamente implementado;
- consistencia entre contrato, runtime y gobierno documental;
- definición explícita de qué parte del método ya está representada técnicamente y cuál no;
- cierre de ambigüedades funcionales críticas;
- endurecimiento operativo mínimo del entorno;
- y criterio formal de aceptación para exposición a uso real controlado.

Regla de deuda para pruebas de realidad: deuda crítica abierta no permitida; deuda media solo si está explícitamente aceptada y trazada.

## 17. Efecto de este documento

Desde su emisión, este documento se adopta como referencia fundacional explícita del proyecto LEX_PENAL y como pieza de lectura obligatoria para:

- apertura de nuevas fases de producto;
- evaluación de fidelidad del backlog;
- diagnóstico de desviaciones;
- y preparación de pruebas de realidad.

## 18. Observación final

Este documento no crea ex nihilo la identidad del proyecto. La formaliza. Su función es cerrar un vacío documental de gobierno mediante la extracción y decantación de la sustancia fundacional ya contenida en el Manual General de Resolución de Casos Penales 2.0.

Su lectura debe hacerse en articulación con el Manual General y con la Regla de Gobierno Documental vigente.
