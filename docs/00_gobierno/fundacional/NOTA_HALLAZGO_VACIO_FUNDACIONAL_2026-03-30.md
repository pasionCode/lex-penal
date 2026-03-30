# NOTA DE HALLAZGO — VACÍO DOCUMENTAL FUNDACIONAL

**Proyecto:** LEX_PENAL  
**Fecha:** 2026-03-30  
**Contexto:** Reflexión post-cierre E8

---

## 1. Hallazgo

Durante la reflexión posterior al cierre de la fase E8, se identificó que el proyecto LEX_PENAL carecía de un documento rector que definiera el **para qué** y el **hasta dónde** del sistema.

El MDS v2.3 gobierna el **cómo** metodológico de la construcción, pero no existe un documento autónomo que ancle la visión sustantiva, el alcance funcional y los criterios de éxito del proyecto.

---

## 2. Diagnóstico

El vacío detectado **no es ausencia de sustancia, sino ausencia de formalización autónoma**.

El contenido fundacional existe y está completo en el **Manual General de Resolución de Casos Penales 2.0**, documento que:

- Define el problema que el método viene a resolver
- Establece el objetivo general y los objetivos específicos
- Describe la arquitectura conceptual (apertura, tronco común, herramientas, módulos)
- Delimita alcance y límites institucionales
- Especifica el contexto de uso (consultorio jurídico universitario)

LEX_PENAL es la **digitalización operativa** de ese manual. Sin embargo, esa relación nunca fue formalizada en un documento autónomo del proyecto.

---

## 3. Consecuencia observada

Sin documento fundacional propio:

| Área | Efecto |
|------|--------|
| Alcance MVP | Quedó implícito, no declarado |
| Criterios de éxito | No definidos formalmente |
| Priorización | Sin criterio sustantivo para decidir qué sigue |
| Tensión visión/ejecución | Sin regla de resolución |

---

## 4. Acción correctiva

Emitir el **Acta Fundacional y Marco de Alcance — LEX_PENAL**, construida mediante:

1. **Extracción** de los bloques fundacionales del Manual General 2.0
2. **Adición mínima** de tres elementos nuevos:
   - Relación con el MDS
   - Conexión con el MVP construido
   - Criterio de entrada a pruebas de realidad

---

## 5. Regla de gobierno derivada

En caso de tensión entre visión sustantiva y ejecución técnica:

- La **visión sustantiva** se reconstruye desde el Manual y su documento fundacional derivado
- La **metodología de ejecución** se rige por el MDS

---

## 6. Conclusión

El proyecto no estaba huérfano de visión; estaba huérfano de formalización. La corrección no requiere crear contenido nuevo, sino extraer y anclar el contenido ya existente en el Manual General como documento rector sustantivo de LEX_PENAL.
