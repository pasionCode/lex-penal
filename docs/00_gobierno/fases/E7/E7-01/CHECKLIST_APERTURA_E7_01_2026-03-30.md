# CHECKLIST APERTURA E7-01 — 2026-03-30

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E7
- Unidad: E7-01 — Baseline y delimitación operativa del frente documents post-E6
- Fecha de apertura: 2026-03-30
- Estado: ABIERTA

## 2. Objetivo
Baselinar y delimitar la superficie real del subrecurso `documents` como siguiente bloque priorizado del backlog post-E6, para preparar una intervención controlada de evolución funcional sin mezclar frentes ni abrir infraestructura pesada fuera de alcance.

## 3. Justificación
El backlog post-E5/E6 deja explícitamente como frente evolutivo la extensión de `documents` desde un modo metadatos-only hacia un ciclo funcional más completo. La superficie existe en código y contrato, y ofrece mejor relación valor/acotamiento que abrir un frente transversal más amplio.

## 4. Alcance
- verificar estado actual documental y técnico de `documents`
- identificar endpoints vigentes
- revisar DTOs, service, repository y controller
- contrastar contrato vs implementación
- identificar huecos funcionales reales del modo metadatos-only
- definir criterios de aceptación de la siguiente unidad ejecutiva

## 5. Fuera de alcance
- infraestructura pesada de almacenamiento
- integración con proveedor externo de archivos
- múltiples frentes funcionales paralelos
- rediseño del roadmap
- reapertura de E6

## 6. Entregables mínimos
- checklist de apertura de E7-01
- baseline técnico diligenciado
- decisión de foco priorizado
- superficie exacta a intervenir
- criterios de aceptación
- propuesta de continuidad

## 7. Riesgo principal
Expandir `documents` sin delimitar exactamente qué significa “ciclo funcional más completo”, abriendo alcance difuso o acoplando almacenamiento pesado fuera de alcance.

## 8. Criterio de cierre
La unidad podrá cerrarse cuando exista baseline diligenciado, foco confirmado sobre `documents`, superficie exacta descrita y siguiente paso ejecutable definido bajo MDS.
