# CHECKLIST DE APERTURA — SPRINT 22

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Consolidación / expansión controlada
- Sprint: 22
- Fecha de apertura: 2026-03-27
- Estado: ABIERTO

## 2. Foco del sprint
Consolidación contractual y funcional final del subrecurso `subjects`, alineando:
- contrato API del `POST /cases/:caseId/subjects`
- contrato API del `GET /cases/:caseId/subjects/:subjectId`
- comportamiento real del runtime
- validaciones del `CreateSubjectDto`
- evidencia mínima de pruebas por consola
- cierre homogéneo de la política append-only del subrecurso

## 3. Justificación
Después del cierre de S21 sobre el listado de `subjects`, el siguiente paso correcto en E5 no es abrir un módulo nuevo, sino cerrar el subrecurso completo.

El bloque `subjects` ya expone en runtime:
- GET lista
- POST create
- GET detalle

Por tanto, S22 debe consolidar las operaciones remanentes y dejar cerrada la línea `subjects` con coherencia entre:
- implementación
- validación
- contrato
- evidencia
- política append-only

## 4. Alcance permitido
- Documentar formalmente en `CONTRATO_API.md` el `POST /subjects`
- Documentar formalmente en `CONTRATO_API.md` el `GET /subjects/:subjectId`
- Verificar consistencia entre `CreateSubjectDto`, controller, service y repository
- Validar por consola el comportamiento real de create y detail
- Confirmar coherencia con la política append-only
- Registrar nota de cierre del sprint

## 5. Alcance prohibido
- No crear nuevos endpoints
- No agregar nuevos campos al sujeto
- No agregar nuevos filtros
- No habilitar `PUT` ni `DELETE`
- No modificar la política append-only
- No tocar otros módulos fuera de `subjects`
- No introducir migraciones Prisma

## 6. Artefactos objetivo
- `docs/04_api/CONTRATO_API.md`
- `src/modules/subjects/dto/create-subject.dto.ts`
- `src/modules/subjects/subjects.controller.ts`
- `src/modules/subjects/subjects.service.ts`
- `src/modules/subjects/subjects.repository.ts`
- `docs/00_gobierno/fases/E5/sprints/sprint_22/NOTA_CIERRE_SPRINT_22_2026-03-27.md`

## 7. Validaciones mínimas esperadas
- [ ] `POST /subjects` con payload válido responde `201`
- [ ] `POST /subjects` persiste sujeto con campos esperados
- [ ] `POST /subjects` con `caseId` inexistente responde `404`
- [ ] `POST /subjects` con payload inválido responde `400`
- [ ] `GET /subjects/:subjectId` responde `200`
- [ ] `GET /subjects/:subjectId` con sujeto inexistente responde `404`
- [ ] `GET /subjects/:subjectId` con caso inexistente responde `404`
- [ ] `GET /subjects/:subjectId` no permite fuga entre casos
- [ ] Política append-only se mantiene sin `PUT` ni `DELETE`
- [ ] `npm run build` en verde

## 8. Riesgos a vigilar
- Desalineación entre contrato y runtime en create/detail
- Divergencia entre `CreateSubjectDto` y contrato documentado
- Campos devueltos no documentados o documentados de forma ambigua
- Validaciones incompletas en payload de creación
- Falta de cierre explícito de la política append-only
- Persistencia de tipado laxo en service/repository

## 9. Criterios de cierre
- [ ] Contrato actualizado para `POST /subjects`
- [ ] Contrato actualizado para `GET /subjects/:subjectId`
- [ ] Implementación validada por consola
- [ ] Build exitoso
- [ ] Nota de cierre emitida
- [ ] Sprint 22 cerrado sin ampliar alcance
- [ ] Línea `subjects` cerrada integralmente

## 10. Juicio metodológico
Sprint 22 se abre como sprint de cierre integral del subrecurso `subjects`, no de expansión funcional.

Su éxito depende de dejar cerradas las operaciones remanentes del subrecurso bajo una misma lógica de:
- coherencia documental
- validación real
- evidencia mínima
- respeto del MDS
- respeto de la política append-only
