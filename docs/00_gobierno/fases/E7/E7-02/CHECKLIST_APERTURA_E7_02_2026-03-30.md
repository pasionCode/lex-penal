# CHECKLIST APERTURA E7-02 — 2026-03-30

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E7
- Unidad: E7-02 — Hardening semántico y runtime de documents
- Fecha de apertura: 2026-03-30
- Estado: ABIERTA

## 2. Objetivo
Alinear la semántica, documentación interna, contrato observable y validación runtime del módulo `documents`, tratándolo como un registro referenciado de documentos sin infraestructura real de almacenamiento.

## 3. Justificación
E7-01 confirmó que `documents` es la mejor superficie priorizada post-E6. La inspección mostró una divergencia semántica menor pero real: el controller conserva comentario de append-only sin PUT, mientras la implementación y el contrato exponen `PUT` para actualizar `descripcion`.

## 4. Alcance
- revisar DTOs reales de create/update
- corregir comentarios y semántica interna del módulo
- confirmar política funcional de `PUT` solo sobre `descripcion`
- validar runtime de `POST/GET lista/GET detalle/PUT descripcion`
- validar negativas mínimas
- emitir cierre trazable

## 5. Fuera de alcance
- upload real de archivos
- almacenamiento binario
- integración con proveedor externo
- delete
- versionado documental

## 6. Criterios de aceptación
- comentario del controller alineado con la superficie real
- contrato y código sin contradicción semántica visible
- script runtime con ciclo base validado
- negativas mínimas ejecutadas
- nota de cierre emitida
