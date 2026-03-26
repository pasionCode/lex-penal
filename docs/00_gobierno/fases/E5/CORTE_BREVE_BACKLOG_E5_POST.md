# CORTE BREVE DE BACKLOG E5 — POST SPRINT 10
**Proyecto:** LEX_PENAL  
**Fase:** E5 — Expansión funcional controlada  
**Fecha de corte:** 2026-03-26  
**Estado general:** E5 abierta, con Sprint 10 cerrado integralmente

---

## 1. Propósito del corte
Registrar el estado real de la fase E5 después del cierre del Sprint 10, consolidar la nueva línea base funcional y orientar la decisión del siguiente bloque dominante sin perder alineación con el MDS.

---

## 2. Línea base vigente al cierre del Sprint 10
Con el cierre del Sprint 10, el sistema queda expandido sobre el MVP consolidado con dos nuevos subrecursos funcionales del caso:

### 2.1. Actuación (`/proceedings`)
**Estado:** IMPLEMENTADO Y VALIDADO

**Endpoints operativos:**
- `GET /api/v1/cases/{id}/proceedings`
- `POST /api/v1/cases/{id}/proceedings`
- `GET /api/v1/cases/{id}/proceedings/{proc_id}`
- `PUT /api/v1/cases/{id}/proceedings/{proc_id}`
- `DELETE /api/v1/cases/{id}/proceedings/{proc_id}`

**Validado en runtime:**
- CRUD positivo completo
- 404 por `case_id` inexistente
- 404 por `proc_id` inexistente

### 2.2. Documento (`/documents`)
**Estado:** IMPLEMENTADO Y VALIDADO EN MODO METADATOS-ONLY

**Endpoints operativos:**
- `GET /api/v1/cases/{id}/documents`
- `POST /api/v1/cases/{id}/documents`
- `GET /api/v1/cases/{id}/documents/{doc_id}`

**Validado en runtime:**
- alta de documento de metadatos
- consulta de documentos del caso
- consulta de detalle por id
- 404 por `case_id` inexistente
- 404 por `doc_id` inexistente
- 400 por payload inválido

---

## 3. Componentes consolidados acumulados hasta este punto
La línea funcional disponible del sistema queda compuesta, como mínimo, por los siguientes módulos activos:

- auth
- users
- cases
- clients
- facts
- evidence
- risks
- strategy
- timeline
- client-briefing
- conclusion
- checklist
- review
- reports
- ai
- proceedings
- documents (metadatos-only)

---

## 4. Coherencia alcanzada
Al cierre del Sprint 10 se encuentra validada la coherencia mínima entre:

- modelo de datos
- endpoints operativos
- validaciones backend
- contrato API
- comportamiento observable en runtime
- estado del repositorio
- cierre documental de gobierno

Esto permite afirmar que el Sprint 10 no dejó una expansión “aparente”, sino una expansión real consolidada.

---

## 5. Exclusiones que siguen vigentes en E5
A la fecha de este corte **no** forman parte de la línea base implementada:

- subida real de archivos
- `multipart/form-data`
- almacenamiento físico local
- object storage
- antivirus de archivos
- firma de URLs
- versionado documental
- `PUT /documents`
- `DELETE /documents`
- rediseño del módulo IA
- endurecimiento de infraestructura

Estas exclusiones siguen siendo deliberadas y no deben asumirse como disponibles.

---

## 6. Deuda controlada posterior al Sprint 10
No se identifican bloqueos críticos abiertos al cierre.  
La deuda remanente es de carácter evolutivo, no correctivo.

### 6.1. Deuda evolutiva principal
- completar el ciclo funcional de documentos más allá de metadatos
- definir si los documentos tendrán flujo append-only permanente o ciclo de vida editable
- decidir si las actuaciones deberán vincularse formalmente con documentos, hechos o evidencia
- revisar si E5 continuará por profundidad sobre recursos ya abiertos o por incorporación de un nuevo subrecurso

### 6.2. Deuda de diseño funcional
- precisar reglas de negocio más finas para `responsable_id` vs `responsable_externo`
- precisar taxonomía documental definitiva
- definir política futura de integridad del archivo físico vs metadato registrado

---

## 7. Opciones candidatas para Sprint 11
Se identifican tres rutas plausibles para el siguiente sprint:

### Opción A — Profundización documental
Expandir `documents` desde metadatos-only hacia un flujo documental más completo.

**Podría incluir:**
- `PUT /documents/{id}`
- `DELETE /documents/{id}`
- validaciones funcionales más ricas
- preparación de interfaz para futura carga real

**Ventaja:** consolida el recurso recién abierto  
**Riesgo:** puede arrastrar decisiones de infraestructura antes de tiempo

---

### Opción B — Vinculación funcional entre recursos
Aprovechar `proceedings` y `documents` ya existentes para empezar relaciones útiles con otros módulos.

**Podría incluir:**
- vincular documento a actuación
- vincular actuación a evidencia o hecho
- consultas enriquecidas por contexto del caso

**Ventaja:** aumenta valor jurídico-operativo real  
**Riesgo:** exige más claridad de modelo funcional

---

### Opción C — Nuevo bloque funcional de E5
Abrir un nuevo subrecurso o capacidad complementaria no cubierta por el MVP.

**Ventaja:** expande superficie del sistema  
**Riesgo:** dispersa la fase E5 si se abandona demasiado pronto la consolidación de `documents`

---

## 8. Recomendación de conducción
La recomendación metodológica es:

### **abrir Sprint 11 con dominante documental**
No por infraestructura pesada, sino por **consolidación funcional**.

### Propuesta
**Sprint 11 — Consolidación funcional de Documento**

**Objetivo sugerido:**  
Extender el subrecurso `documents` desde el modo metadatos-only hacia un ciclo funcional más completo, manteniendo fuera de alcance la infraestructura pesada de almacenamiento.

### Alcance sugerido mínimo
- definir si `documents` seguirá append-only o pasará a editable
- incorporar `PUT /documents/{id}` si el negocio lo justifica
- incorporar `DELETE /documents/{id}` solo si el modelo jurídico-operativo lo tolera
- fortalecer reglas de categorías y metadatos
- evaluar preparación contractual para futura carga real, sin implementarla todavía

### Razón
Porque `proceedings` ya quedó suficientemente operativo, mientras que `documents` aún está en una primera capa funcional.

---

## 9. Regla de conducción para el siguiente sprint
La fase E5 debe seguir bajo esta regla:

> **No abrir infraestructura pesada ni nuevas superficies amplias mientras `documents` siga en estado preliminar, salvo decisión expresa de cambio de prioridad.**

---

## 10. Estado final del corte
E5 queda abierta con una nueva línea base estable.  
Sprint 10 se considera cerrado integralmente y habilita la apertura controlada del Sprint 11.

**Recomendación final:** abrir Sprint 11 con foco en consolidación documental.