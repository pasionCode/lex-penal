# NOTA DE CIERRE SPRINT 04 — 2026-03-24

## 1. Identificación

- Proyecto: LEX_PENAL
- Fase: E3 — Construcción del MVP
- Sprint: Sprint 4 — Risks, Strategy y Timeline
- Fecha de cierre: 2026-03-24
- Estado: CERRADO

## 2. Objetivo del sprint

Implementar y validar el bloque funcional correspondiente a `risks`, `strategy` y `timeline`, respetando las reglas del Sprint 4:

- alcance limitado a `risks`, `strategy`, `timeline`
- no reabrir CRUD individual de `facts` y `evidence`
- validar primero contrato, modelo y DTOs antes de consolidar service/controller
- evitar confusión entre recurso único (`strategy`) y colecciones (`risks`, `timeline`)
- cerrar con build limpio, pruebas reales y nota formal de cierre

## 3. Regla operativa aplicada

Durante la ejecución del sprint se mantuvieron las siguientes reglas:

- `strategy` fue tratado como recurso único por caso
- `risks` fue tratado como colección por caso con recurso individual por ítem
- `timeline` fue tratado como colección append-only por caso
- no se reabrió el trabajo funcional de `facts` ni `evidence`
- la validación real se hizo sobre endpoints efectivos en ejecución, no solo sobre stubs o contrato documental

## 4. Validaciones previas realizadas

### 4.1 Estado base del repositorio

Se verificó:

- `git status` limpio al inicio
- historial reciente consistente con cierre de Sprint 3
- `npm run build` exitoso

### 4.2 Revisión de modelo Prisma

Se validó en `schema.prisma`:

- `Riesgo` como entidad múltiple por caso
- `Estrategia` con `caso_id @unique`, consistente con recurso único
- `LineaTiempo` como entidad append-only, sin campos de actualización
- enums de `Riesgo` definidos:
  - `Probabilidad`
  - `Impacto`
  - `Prioridad`
  - `EstadoMitigacion`

### 4.3 Revisión de contrato

Se verificó que:

- `strategy` estaba correctamente concebido como documento único
- `timeline` estaba concebido como `GET/POST`
- `risks` conservaba una definición antigua basada en `PUT` masivo, desalineada con el comportamiento real del backend

## 5. Resultado funcional por vertical

### 5.1 Risks

Se validó en pruebas reales que el backend opera `risks` como colección con recurso individual:

- `POST /api/v1/cases/{id}/risks`
- `GET /api/v1/cases/{id}/risks`
- `GET /api/v1/cases/{id}/risks/{riskId}`
- `PUT /api/v1/cases/{id}/risks/{riskId}`

#### Evidencia funcional validada

- creación exitosa de riesgo individual
- listado de riesgos del caso
- consulta de detalle de riesgo individual
- edición de riesgo individual
- persistencia correcta tras actualización

#### Regla de negocio validada

Se comprobó que:

- si `prioridad = critica`
- entonces `estrategia_mitigacion` es obligatoria

#### Seguridad validada

Se comprobó que un usuario sin acceso al caso recibe:

- `403 Forbidden`
- mensaje: `Sin acceso a este caso`

#### Conclusión de la vertical

`risks` quedó funcionalmente validado como colección por caso con edición individual por ítem.

### 5.2 Strategy

Se validó en pruebas reales que `strategy` opera como recurso único por caso:

- `GET /api/v1/cases/{id}/strategy`
- `PUT /api/v1/cases/{id}/strategy`

#### Evidencia funcional validada

- consulta inicial con lazy init exitoso
- creación/obtención automática del documento vacío al primer acceso
- actualización parcial exitosa
- persistencia correcta tras la reconsulta

#### Seguridad validada

Se comprobó que un usuario sin acceso al caso recibe:

- `403 Forbidden`
- mensaje: `Sin acceso a este caso`

#### Conclusión de la vertical

`strategy` quedó funcionalmente validado como singleton por caso, alineado con contrato, modelo y comportamiento real.

### 5.3 Timeline

Se validó en pruebas reales que `timeline` opera como colección append-only por caso:

- `POST /api/v1/cases/{id}/timeline`
- `GET /api/v1/cases/{id}/timeline`

#### Evidencia funcional validada

- creación exitosa de eventos cronológicos
- listado ordenado de eventos
- persistencia correcta de múltiples registros
- asignación automática de `orden` por backend en las pruebas ejecutadas

#### Seguridad validada

Se comprobó que un usuario sin acceso al caso recibe:

- `403 Forbidden`
- mensaje: `Sin acceso a este caso`

#### Conclusión de la vertical

`timeline` quedó funcionalmente validado como colección append-only. No se implementó edición de eventos, en coherencia con el modelo de datos.

## 6. Criterios de cierre verificados

Se consideran cumplidos los criterios de cierre del Sprint 4:

- alcance respetado: `risks`, `strategy`, `timeline`
- `facts` y `evidence` no fueron reabiertos como verticales de trabajo
- build limpio validado
- pruebas reales ejecutadas sobre backend en funcionamiento
- ownership por caso validado en las tres verticales
- `strategy` resuelto correctamente como recurso único
- `risks` resuelto correctamente como colección con recurso individual
- `timeline` resuelto correctamente como colección append-only

## 7. Hallazgos y ajustes identificados

### 7.1 Desalineación contractual en risks

El contrato todavía describía una versión antigua de `risks` basada en `PUT` masivo del conjunto completo.

Sin embargo, las pruebas reales demostraron que el backend ya opera bajo un modelo de CRUD individual por ítem.

Esto obliga a actualizar el contrato para reflejar el comportamiento real.

### 7.2 Timeline sin edición

El modelo Prisma de `LineaTiempo` no contempla actualización (`actualizado_en`, `actualizado_por`), por lo que no procede prometer edición de eventos en este sprint.

Se mantiene el criterio append-only.

### 7.3 Asignación de orden en timeline

En las pruebas realizadas, el backend asignó automáticamente el campo `orden` aunque no fuera enviado por cliente.

Este comportamiento debe quedar expresamente documentado en contrato o DTOs para evitar ambigüedad.

### 7.4 Estructura interna pendiente de ordenamiento

Se identificó que `timeline.controller.ts` estaba ubicado dentro del módulo `strategy`, lo que constituye una deuda de estructura interna.

No bloqueó la validación funcional del sprint, pero debe quedar registrado como ajuste de ordenamiento técnico.

### 7.5 Ruido en mensajes de validación de risks

Al probar la obligatoriedad de `estrategia_mitigacion` para riesgos críticos, el backend retornó mensajes acumulados de tipo/longitud además del mensaje central de obligatoriedad.

La regla funciona, pero los mensajes pueden pulirse.

## 8. Evidencias funcionales relevantes

Se registraron, entre otras, las siguientes evidencias:

- creación de riesgo individual exitosa
- edición de riesgo individual exitosa
- rechazo de riesgo crítico sin estrategia de mitigación
- acceso denegado a `risks` para usuario sin ownership
- lazy init de `strategy`
- actualización y persistencia de `strategy`
- acceso denegado a `strategy` para usuario sin ownership
- creación de eventos de `timeline`
- listado ordenado de `timeline`
- acceso denegado a `timeline` para usuario sin ownership

## 9. Estado final del sprint

Sprint 4 cerrado funcionalmente.

Las tres verticales comprometidas (`risks`, `strategy`, `timeline`) quedaron operativas y validadas con pruebas reales. Se identificaron deudas documentales y estructurales menores no bloqueantes, especialmente en alineación contractual y ordenamiento interno de módulos, pero no impiden declarar el sprint como cerrado.

## 10. Pendientes para continuidad

- actualizar `CONTRATO_API_v4.md` para reflejar el comportamiento real de `risks`
- documentar explícitamente el comportamiento append-only de `timeline`
- documentar si `orden` en `timeline` es calculado por backend
- ordenar la estructura modular interna si aún persiste mezcla entre `strategy` y `timeline`
- pulir mensajes de validación en `risks`

## 11. Declaración de cierre

Se declara formalmente cerrado el Sprint 4 del proyecto LEX_PENAL, correspondiente a la fase E3 — Construcción del MVP, al haberse cumplido el objetivo funcional comprometido y existir evidencia real suficiente de operación sobre las verticales `risks`, `strategy` y `timeline`.
