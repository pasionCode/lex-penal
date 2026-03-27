# CHECKLIST DE APERTURA — SPRINT 23

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Consolidación / expansión controlada
- Sprint: 23
- Fecha de apertura: 2026-03-27
- Estado: ABIERTO

## 2. Foco del sprint
Implementación proyectual de la nueva metodología de ejecución técnica en LEX_PENAL, mediante incorporación documental de:

- régimen operativo ordinario
- régimen de contingencia con clave `desarrollador en licencia`
- método estándar de análisis y ejecución técnica
- regla de intervención reproducible
- restricción de edición manual
- principio de intervención humana mínima, controlada y trazable

## 3. Justificación
El proyecto ya cuenta con políticas de gobierno, fases, gates y cierres operativos, pero ahora debe absorber formalmente el nuevo bloque metodológico de ejecución técnica dentro de su propia conducción.

El objetivo de S23 no es desarrollar producto, sino dejar institucionalizado en el proyecto:

- cómo se opera en régimen ordinario
- cómo se opera en contingencia
- cómo se ejecutan intervenciones técnicas
- cómo se controlan excepciones por edición manual
- cómo se mantiene integridad entre analista, desarrollador y repositorio

## 4. Alcance permitido
- Actualizar el documento de conducción del proyecto para reflejar la nueva metodología
- Incorporar las reglas operativas específicas de LEX_PENAL
- Formalizar el uso de la clave `desarrollador en licencia`
- Documentar el método estándar de análisis y ejecución técnica aplicable al proyecto
- Documentar la política de intervención reproducible y restricción de edición manual
- Documentar la intervención humana mínima y trazable en flujos asistidos por IA
- Emitir nota de cierre del sprint

## 5. Alcance prohibido
- No tocar código productivo
- No tocar módulos backend
- No tocar frontend
- No tocar base de datos
- No tocar contratos API funcionales
- No abrir nuevos endpoints
- No introducir migraciones
- No realizar refactors técnicos fuera del plano documental
- No mezclar este sprint con cierre funcional de producto

## 6. Artefactos objetivo
- `docs/00_gobierno/LEX_PENAL_SISTEMA_CONDUCCION.md`
- `docs/13_operacion/MANUAL_OPERATIVO.md`
- `docs/00_gobierno/fases/E5/sprints/sprint_23/NOTA_CIERRE_SPRINT_23_2026-03-27.md`

## 7. Validaciones mínimas esperadas
- [ ] El documento de conducción incorpora régimen operativo ordinario
- [ ] El documento de conducción incorpora régimen de contingencia
- [ ] La clave `desarrollador en licencia` queda formalmente documentada
- [ ] El método estándar de análisis y ejecución técnica queda documentado
- [ ] La regla de intervención reproducible queda documentada
- [ ] La restricción de edición manual queda documentada como excepción metodológica
- [ ] La intervención humana mínima y trazable queda documentada
- [ ] La nueva metodología queda alineada con el MDS y con la práctica real del proyecto
- [ ] No se altera código ni alcance funcional del producto
- [ ] Nota de cierre emitida

## 8. Riesgos a vigilar
- Duplicar el MDS en lugar de aterrizarlo al proyecto
- Redactar reglas demasiado abstractas o poco operativas
- Introducir contradicciones entre régimen ordinario y contingencia
- Dejar ambigua la autorización de edición manual excepcional
- Contaminar el sprint con trabajo funcional no aprobado
- Sobredocumentar sin mejorar la ejecutabilidad real

## 9. Criterios de cierre
- [ ] Documento de conducción actualizado
- [ ] Anexo operativo del proyecto actualizado
- [ ] Régimen operativo formalizado
- [ ] Método estándar de ejecución técnica formalizado
- [ ] Regla de edición manual excepcional formalizada
- [ ] Intervención humana mínima y trazable formalizada
- [ ] Sprint 23 cerrado sin expansión funcional
- [ ] Nota de cierre emitida

## 10. Juicio metodológico
Sprint 23 se abre como sprint de consolidación metodológica proyectual.

No busca crear funcionalidad nueva, sino institucionalizar en LEX_PENAL la nueva capa de ejecución técnica ya definida a nivel metodológico, para que el proyecto opere con mayor claridad, integridad y reproducibilidad.
