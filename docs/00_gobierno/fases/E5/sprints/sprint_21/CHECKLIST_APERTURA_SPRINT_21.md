# CHECKLIST DE APERTURA — SPRINT 21

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Consolidación / expansión controlada
- Sprint: 21
- Fecha de apertura: 2026-03-27
- Estado: ABIERTO

## 2. Foco del sprint
Consolidación contractual y funcional final del subrecurso `subjects`, alineando:
- contrato API
- comportamiento real del endpoint GET `/cases/:caseId/subjects`
- validaciones del query DTO
- evidencia mínima de pruebas por consola

## 3. Justificación
Después de S17, S19 y S20, el listado de `subjects` ya soporta filtros relevantes.
El siguiente paso correcto en E5 no es abrir más superficie funcional, sino cerrar coherencia entre:
- implementación
- validación
- contrato
- evidencia

## 4. Alcance permitido
- Documentar formalmente en `CONTRATO_API.md` los query params del listado de `subjects`
- Verificar consistencia entre DTO, controller, service y repository
- Validar por consola el comportamiento de los filtros ya existentes
- Registrar nota de cierre del sprint

## 5. Alcance prohibido
- No crear nuevos endpoints
- No agregar nuevos filtros
- No modificar política append-only
- No tocar otros módulos fuera de `subjects`
- No introducir migraciones Prisma

## 6. Artefactos objetivo
- `docs/04_api/CONTRATO_API.md`
- `src/modules/subjects/dto/list-subjects-query.dto.ts`
- `src/modules/subjects/subjects.controller.ts`
- `src/modules/subjects/subjects.service.ts`
- `src/modules/subjects/subjects.repository.ts`
- `docs/00_gobierno/fases/E5/sprints/sprint_21/NOTA_CIERRE_SPRINT_21_2026-03-27.md`

## 7. Validaciones mínimas esperadas
- [ ] GET sin filtros responde 200
- [ ] GET con `tipo` responde 200
- [ ] GET con `nombre` responde 200
- [ ] GET con `identificacion` responde 200
- [ ] GET con `tipo_identificacion` responde 200
- [ ] GET con `tipo_identificacion` inválido responde 400
- [ ] GET con `tipo_identificacion` vacío responde 400
- [ ] Paginación mantiene `total` consistente con filtros
- [ ] `npm run build` en verde

## 8. Riesgos a vigilar
- Desalineación entre contrato y runtime
- Reintroducción de tipado laxo en repository
- Divergencia entre `findMany` y `count`
- Ambigüedad documental sobre semántica de filtros
- Deuda de encoding detectada en respuestas runtime

## 9. Criterios de cierre
- [ ] Contrato actualizado con query params reales del GET `/subjects`
- [ ] Implementación validada por consola
- [ ] Build exitoso
- [ ] Nota de cierre emitida
- [ ] Sprint 21 cerrado sin ampliar alcance

## 10. Juicio metodológico
Sprint 21 se abre como sprint de consolidación, no de expansión funcional.
Su éxito depende de cerrar coherencia documental y técnica del bloque `subjects` sin salir del MDS.
