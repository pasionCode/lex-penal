# CHECKLIST APERTURA UNIDAD E7-04 — 2026-03-30

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E7
- Unidad: E7-04 — Baseline y hardening semántico de `client-briefing`
- Fecha de apertura: 2026-03-30
- Estado: ABIERTA

## 2. Objetivo de la unidad
Levantar baseline técnico-documental y resolver, si aplica, la deuda semántica observable del endpoint `GET /client-briefing`, verificando si su comportamiento de auto-creación es compatible con la máquina de estados del caso, el contrato observable y la finalidad funcional del recurso.

## 3. Justificación
E7-03 cerró el frente de integridad estructural asociado al versionado de revisión. Corresponde ahora abordar una deuda de semántica observable reportada previamente: el recurso `client-briefing` podría auto-crearse mediante `GET` sin validación suficiente del estado del caso.

La unidad E7-04 se abre para determinar con evidencia si dicha conducta:
1. constituye una deuda real;
2. responde a una decisión funcional válida;
3. requiere corrección semántica, documental o ambas.

## 4. Alcance de apertura
Esta apertura autoriza exclusivamente:

1. Levantar baseline técnico-documental de:
   - `client-briefing.service.ts`
   - `client-briefing.repository.ts`
   - controller del recurso
   - DTOs aplicables
   - contrato observable
   - comportamiento runtime actual
2. Revisar la fuente interna que rige compatibilidad por estado:
   - constantes o máquina de estados del caso
   - guardas relacionadas
   - ADR o documento rector aplicable
3. Determinar en qué estados del caso resulta funcionalmente compatible:
   - auto-crear el recurso;
   - no auto-crearlo;
   - retornar 404;
   - retornar estructura vacía;
   - o conservar el comportamiento actual documentándolo formalmente.
4. Definir la corrección mínima solo después del baseline.
5. Preparar evidencia runtime suficiente para validar el comportamiento final.

## 5. Fuera de alcance
- Rediseño completo del módulo `client-briefing`
- Replanteamiento integral de la máquina de estados
- Modificaciones colaterales en otros módulos sin evidencia de necesidad
- Implementación correctiva sin baseline previo
- Cambios contractuales no soportados por comportamiento real o decisión explícita

## 6. Pregunta rectora
¿Es semánticamente válido que `GET /client-briefing` auto-cree el recurso en cualquier estado del caso, o dicho comportamiento debe restringirse, documentarse o corregirse conforme a la lógica del flujo del caso?

## 7. Hipótesis de trabajo
La auto-creación de `client-briefing` no debería operar de forma indiferenciada en todos los estados del caso. La compatibilidad exacta deberá determinarse en baseline contra la máquina de estados, el contrato observable y el uso real del recurso.

## 8. Criterios de entrada
- E7-03 cerrada formalmente
- Repositorio limpio
- Apertura documental de E7-04 emitida
- Baseline técnico autorizado
- Fuentes de estado y contrato identificadas

## 9. Criterios de salida
E7-04 solo podrá cerrarse cuando exista:

1. baseline técnico-documental emitido;
2. decisión expresa sobre la semántica correcta de `GET /client-briefing`;
3. corrección implementada o validación/documentación formal del comportamiento vigente, según resultado del baseline;
4. validación runtime suficiente, incluyendo como mínimo:
   - comportamiento en estado no compatible, si aplica;
   - comportamiento en estado compatible, si aplica;
   - coherencia con la máquina de estados y el contrato observable;
5. build verde;
6. nota de cierre formal.

## 10. Riesgos controlados
- Mantener una auto-creación semánticamente impropia
- Romper un comportamiento vigente sin validar dependencia funcional
- Desalinear contrato, runtime y máquina de estados
- Corregir en una capa incorrecta antes de ubicar la causa real
- Cerrar la unidad sin evidencia observable suficiente

## 11. Entregables mínimos
- Checklist de apertura E7-04
- Baseline técnico E7-04
- Evidencia de análisis de compatibilidad por estado
- Corrección mínima en la capa competente, si aplica
- Script o evidencia runtime canónica de validación
- Nota de cierre E7-04

## 12. Decisión de gobierno
Se declara formalmente abierta la unidad **E7-04**, quedando habilitado únicamente el trabajo de baseline, determinación semántica y eventual corrección controlada del comportamiento observable de `client-briefing`.

## 13. Estado
- **Estado:** ABIERTA