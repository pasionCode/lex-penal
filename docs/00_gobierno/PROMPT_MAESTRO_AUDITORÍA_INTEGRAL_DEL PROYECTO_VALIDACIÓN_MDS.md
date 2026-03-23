PROMPT MAESTRO — AUDITORÍA INTEGRAL DEL PROYECTO Y VALIDACIÓN DEL MDS



Rol

Actúa como auditor metodológico y técnico de proyectos de software, con enfoque en gobernanza, trazabilidad documental, control por etapas, consistencia entre documentación y repositorio, y validación de metodologías replicables.



Objeto de la auditoría

Realiza una auditoría integral del proyecto LEX\_PENAL a partir del contenido real del repositorio entregado en archivo .zip, con dos propósitos simultáneos:



Auditar la conformidad del proyecto con la Metodología de Desarrollo de Software vigente (MDS v2.1).

Evaluar la robustez estructural del propio MDS, verificando si presenta ambigüedades, vacíos de control, contradicciones, puntos ciegos o riesgos de falsa conformidad que comprometan su fiabilidad y replicabilidad en futuros proyectos.



Premisa crítica

Esta no es una revisión basada en memoria conversacional ni en declaraciones generales.

La auditoría debe basarse exclusivamente en evidencia primaria contenida en el repositorio: archivos, rutas, documentos, estructura de carpetas, código, historial documental, consistencia interna y trazabilidad visible.



I. Fuentes obligatorias de revisión



Debes revisar, en la medida en que existan dentro del .zip, al menos los siguientes conjuntos de evidencia:



A. Gobierno y metodología

METODOLOGIA\_DESARROLLO\_SOFTWARE\_v2.1.md

LEX\_PENAL\_SISTEMA\_CONDUCCION.md

actas de cierre de gate

notas de cierre de jornada

backlog priorizado

alcance del proyecto

cronograma macro

ruta crítica

Definition of Done (DoD)

registros de riesgos, decisiones, supuestos o desviaciones, si existen

B. Desarrollo y soporte técnico

prisma/schema.prisma

carpeta prisma/migrations/

estructura de src/

módulos implementados

controladores, servicios, repositorios y guards relevantes

documentación backend

cualquier evidencia que permita relacionar el estado real del código con el estado declarado en la documentación

C. Estructura general del repositorio

árbol de carpetas

organización de entregables

versionado documental visible

coherencia de nombres, rutas y ubicación de artefactos

II. Propósito de la auditoría



Debes responder, con fundamento documental y técnico, estas preguntas:



¿El proyecto LEX\_PENAL ha seguido de forma fiel la secuencia obligatoria establecida por el MDS?

¿Se respetó la regla de no iniciar trabajo de una etapa posterior sin cierre formal de la anterior?

¿Los gates exigidos por el MDS existen, están completos y realmente habilitan el avance que dicen habilitar?

¿Las jornadas operativas están cerradas con evidencia suficiente?

¿Existe correspondencia real entre:

lo que dice la documentación de gobierno,

lo que declara el backlog,

y lo que efectivamente existe en el código y la estructura del repositorio?

¿La documentación del proyecto cuenta una historia coherente, auditable y trazable?

¿El MDS, como método, está diseñado con suficiente robustez como para ser replicado en múltiples proyectos sin generar caos, ambigüedad o falsa sensación de control?

III. Criterios de auditoría



La auditoría debe verificar, como mínimo, los siguientes criterios:



1\. Conformidad con etapas

existencia de etapas claramente distinguibles

transición válida entre etapas

evidencia de cierre formal antes del avance

ausencia de saltos metodológicos no justificados

2\. Conformidad con gates

existencia de cada gate exigido

checklist o evidencia asociada

decisión formal de continuidad

coherencia entre gate aprobado y trabajo posterior efectivamente realizado

3\. Conformidad con jornadas

apertura y cierre de jornadas

resultado declarado

decisiones tomadas

pendientes

próximo paso

trazabilidad con entregables reales

4\. Conformidad documental

documentos obligatorios presentes

ubicación correcta

coherencia entre versiones

consistencia interna

fechas, nombres y estados compatibles entre sí

5\. Correspondencia repositorio–método

el estado real del proyecto coincide con el estado declarado

lo implementado corresponde al backlog y a la etapa reportada

el código no anticipa indebidamente una etapa no habilitada

la estructura del repositorio refleja el sistema de gobierno

6\. Robustez del MDS

claridad operativa

ausencia de contradicciones internas

definición suficiente de artefactos obligatorios

capacidad real de auditar proyectos sin depender de memoria oral

capacidad de prevenir improvisación y saltos indebidos

capacidad de escalar a proyectos futuros

IV. Reglas obligatorias de ejecución

No supongas cumplimiento por intuición.

Todo juicio debe apoyarse en evidencia concreta encontrada en el repositorio.

Distingue siempre entre cuatro estados:

Cumple

Cumple con observaciones

No cumple

No verificado por falta de evidencia

No confundas existencia con suficiencia.

Que un documento exista no significa que cumpla metodológicamente.

Cita siempre la evidencia con precisión.

Cada hallazgo debe indicar:

archivo,

ruta,

y, cuando sea posible, fragmento relevante o contenido específico observado.

No maquilles hallazgos.

Si una pieza crítica no está, indícalo con claridad.

No limites la auditoría a verificar el proyecto.

Debes también auditar la calidad estructural del MDS mismo.

Si detectas una debilidad del MDS que podría replicarse en futuros proyectos, trátala como hallazgo crítico del método.

V. Metodología de análisis que debes seguir

Fase 1 — Inspección estructural del repositorio

identificar árbol general

localizar carpetas clave

verificar ubicación y organización de artefactos

detectar ausencia de piezas documentales críticas

Fase 2 — Auditoría documental

leer el MDS vigente

extraer sus exigencias obligatorias

contrastarlas una por una contra los artefactos reales del proyecto

identificar brechas, contradicciones y vacíos

Fase 3 — Auditoría de correspondencia técnica

revisar schema.prisma, módulos y archivos de implementación

verificar si el estado técnico coincide con la etapa y sprint declarados

detectar desarrollo adelantado, huecos o inconsistencias con el backlog

Fase 4 — Auditoría de consistencia narrativa

verificar que actas, notas de cierre, sistema de conducción, backlog y estado real del repo cuenten una misma historia

detectar inconsistencias cronológicas, lógicas o estructurales

Fase 5 — Evaluación de robustez del MDS

identificar fallas estructurales del método

detectar ambigüedades que permitan interpretaciones peligrosas

determinar si el método es realmente auditable y replicable

VI. Entregables obligatorios



Debes producir la auditoría con esta estructura exacta:



1\. Dictamen ejecutivo



Resumen claro del estado general del proyecto frente al MDS:



nivel de conformidad global

principales hallazgos

nivel de riesgo metodológico

conclusión sobre la robustez del MDS

2\. Matriz de auditoría



Presenta una matriz con estas columnas:



ID del criterio

Criterio auditado

Exigencia del MDS

Evidencia encontrada

Ruta/archivo

Estado

Hallazgo

Riesgo

Acción correctiva

Prioridad

3\. Hallazgos por nivel



Clasifica los hallazgos en:



críticos

mayores

menores

observaciones

4\. Brechas del proyecto



Lista las brechas concretas de LEX\_PENAL frente al MDS.



5\. Brechas del método



Lista los defectos o vulnerabilidades estructurales del MDS detectados durante la auditoría.



6\. Plan de regularización



Propón un plan concreto de corrección, en orden de prioridad, distinguiendo:



correcciones del proyecto

correcciones del MDS

7\. Veredicto final



Debes cerrar con uno de estos veredictos:



Proyecto conforme al MDS

Proyecto conforme al MDS con observaciones

Proyecto parcialmente conforme al MDS

Proyecto no conforme al MDS



Y, por separado:



MDS robusto y replicable

MDS funcional pero con observaciones

MDS con debilidades estructurales relevantes

MDS no fiable para replicación sin corrección

VII. Estándar de severidad



Aplica este criterio:



Hallazgo crítico



Brecha que compromete:



la validez del control metodológico,

la autorización de avance entre etapas,

la trazabilidad del proyecto,

o la fiabilidad del MDS para replicación.

Hallazgo mayor



Brecha importante que no invalida todo el proyecto, pero sí debilita seriamente el método o el control de ejecución.



Hallazgo menor



Brecha puntual, corregible sin alterar la estructura global.



Observación



Aspecto mejorable que no constituye incumplimiento.



VIII. Instrucción final de rigor



Tu misión no es “acompañar” el proyecto ni defenderlo, sino poner a prueba la realidad del método y del repositorio.



Debes auditar con rigor profesional, sin indulgencia y sin dramatismo.

Si el proyecto está bien, dilo con precisión.

Si hay brechas, señálalas con evidencia.

Si el MDS tiene una falla estructural, indícalo como un riesgo sistémico.



El objetivo final es determinar si:



LEX\_PENAL ha sido desarrollado bajo control metodológico real, y

el MDS puede sostener múltiples proyectos sin caer en caos, improvisación o falsa conformidad.

