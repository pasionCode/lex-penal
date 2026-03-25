# NOTA DE CIERRE SPRINT 05 — 2026-03-25

## 1. Identificación

- Proyecto: LEX_PENAL
- Fase: E3 — Construcción del MVP
- Sprint: Sprint 5 — Client-briefing, Checklist y Conclusion
- Fecha de cierre: 2026-03-25
- Estado: CERRADO

## 2. Objetivo del sprint

Implementar y validar el bloque funcional correspondiente a `client-briefing`, `checklist` y `conclusion`, respetando las reglas del Sprint 5:

- alcance limitado a `client-briefing`, `checklist`, `conclusion`
- no reabrir `facts`, `evidence`, `risks`, `strategy`, `timeline`
- validar primero contrato, modelo y DTOs antes de repository/service/controller
- tratar `client-briefing` y `conclusion` como documentos únicos por caso
- tratar `checklist` como recurso agregado único por caso
- cerrar con build limpio, pruebas reales y nota formal de cierre

## 3. Regla operativa aplicada

Durante la ejecución del sprint se mantuvieron las siguientes reglas:

- `client-briefing` fue tratado como documento único por caso
- `conclusion` fue tratada como documento único por caso
- `checklist` fue tratado como recurso agregado único por caso
- no se reabrieron verticales cerradas en Sprint 3 y Sprint 4
- la validación real se hizo sobre endpoints efectivos en ejecución

## 4. Validaciones previas realizadas

### 4.1 Revisión de modelo

Se validó en `schema.prisma`:

- `ExplicacionCliente` con `caso_id @unique`
- `ConclusionOperativa` con `caso_id @unique`
- `Checklist` modelado mediante `ChecklistBloque` + `ChecklistItem`
- `checklist` tratado como agregado lógico único del caso a nivel API

### 4.2 Revisión de contrato

Se verificó que:

- `GET /api/v1/cases/{id}/client-briefing`
- `PUT /api/v1/cases/{id}/client-briefing`
- `GET /api/v1/cases/{id}/checklist`
- `PUT /api/v1/cases/{id}/checklist`
- `GET /api/v1/cases/{id}/conclusion`
- `PUT /api/v1/cases/{id}/conclusion`

Además, el contrato establece que la estructura base del caso se genera automáticamente al activar el caso.

## 5. Resultado funcional por vertical

### 5.1 Client-briefing

Se validó en pruebas reales que `client-briefing` opera como recurso único por caso.

#### Evidencia funcional validada

- consulta inicial exitosa con lazy init
- actualización exitosa del documento
- persistencia correcta tras reconsulta
- control de acceso validado con `403 Forbidden` para usuario sin acceso al caso

#### Conclusión de la vertical

`client-briefing` quedó funcionalmente validado como singleton por caso.

### 5.2 Conclusion

Se validó en pruebas reales que `conclusion` opera como recurso único por caso.

#### Evidencia funcional validada

- consulta inicial exitosa con lazy init
- actualización exitosa de campos de conclusión
- persistencia correcta tras reconsulta
- control de acceso validado con `403 Forbidden` para usuario sin acceso al caso

#### Conclusión de la vertical

`conclusion` quedó funcionalmente validada como singleton por caso.

### 5.3 Checklist

Se validó en pruebas reales que `checklist` opera como recurso agregado único por caso.

#### Evidencia funcional validada

- consulta de checklist con bloques e ítems
- actualización de ítems mediante `PUT`
- recálculo correcto del campo `completado`
- control de acceso validado con `403 Forbidden` para usuario sin acceso al caso

#### Bootstrap de estructura base

Se validó adicionalmente que, al transicionar un caso de `borrador` a `en_analisis`, se genera automáticamente una estructura mínima provisional de checklist para el MVP.

#### Estructura provisional validada

- **B01 — Verificación de hechos**
  - `B01_01` Hechos contrastados con denuncia
  - `B01_02` Tipicidad analizada

- **B02 — Análisis probatorio**
  - `B02_01` Pruebas relevantes identificadas
  - `B02_02` Licitud y conducencia verificadas

- **B03 — Estrategia defensiva**
  - `B03_01` Línea principal documentada
  - `B03_02` Riesgos identificados

#### Conclusión de la vertical

`checklist` quedó funcionalmente validado como agregado único por caso, con bootstrap mínimo provisional para el MVP.

## 6. Criterios de cierre verificados

Se consideran cumplidos los criterios de cierre del Sprint 5:

- alcance respetado: `client-briefing`, `checklist`, `conclusion`
- no se reabrieron verticales ya cerradas
- contrato, modelo y DTOs fueron revisados antes de consolidar lógica
- `client-briefing` validado
- `conclusion` validado
- `checklist` validado
- bootstrap de checklist validado en transición `borrador → en_analisis`
- pruebas reales ejecutadas
- ownership validado
- `npm run build` limpio

## 7. Hallazgos y ajustes identificados

### 7.1 Checklist como agregado, no como singleton plano

Se confirmó que `checklist` no es un documento plano, sino un recurso agregado compuesto por bloques e ítems. A nivel de API, sin embargo, se mantiene como recurso único por caso.

### 7.2 Estructura provisional MVP

La estructura del checklist implementada en este sprint es mínima y provisional. No congela la versión definitiva alineada con la documentación funcional futura.

### 7.3 Codificación UTF-8 en textos sembrados

Se observó un problema menor de codificación de caracteres en algunos nombres y descripciones del checklist sembrado. No bloquea el funcionamiento del sprint, pero debe corregirse.

## 8. Evidencias funcionales relevantes

Se registraron, entre otras, las siguientes evidencias:

- lazy init de `client-briefing`
- actualización y persistencia de `client-briefing`
- lazy init de `conclusion`
- actualización y persistencia de `conclusion`
- consulta de `checklist` con bloques e ítems
- marcado de ítems en checklist
- recálculo de `completado`
- bootstrap automático del checklist al activar el caso
- acceso denegado con `403` en las tres verticales para usuario sin ownership

## 9. Estado final del sprint

Sprint 5 cerrado funcionalmente.

Las tres verticales comprometidas (`client-briefing`, `checklist`, `conclusion`) quedaron operativas y validadas con pruebas reales. El checklist quedó además con una estructura mínima provisional generada automáticamente durante la activación del caso.

## 10. Pendientes para continuidad

- corregir codificación UTF-8 en textos sembrados del checklist
- documentar formalmente la estructura provisional MVP del checklist si se decide mantenerla
- definir, en fase posterior, la estructura definitiva alineada con la documentación funcional completa

## 11. Declaración de cierre

Se declara formalmente cerrado el Sprint 5 del proyecto LEX_PENAL, correspondiente a la fase E3 — Construcción del MVP, al haberse cumplido el objetivo funcional comprometido y existir evidencia real suficiente de operación sobre `client-briefing`, `checklist` y `conclusion`.
