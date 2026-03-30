# BASELINE TÉCNICO E7-01 — 2026-03-30

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E7
- Unidad: E7-01
- Fecha: 2026-03-30
- Estado: EN ELABORACIÓN

## 2. Propósito
Establecer la ubicación exacta del proyecto post-E6 y delimitar el siguiente foco prioritario real del backlog.

## 3. Punto de partida confirmado
- E6: cerrada técnica y documentalmente
- E7: abierta formalmente
- Commit de corte breve E6: ee3b6bd
- Commit de apertura formal E7: 39a2e52
- Branch activa: main
- Build: OK
- Ruido local no gobernado detectado: `.claude/`, `CLAUDE.md`

## 4. Superficies candidatas post-E6

### 4.1 Candidata A — documents
Extender el subrecurso `documents` desde el modo metadatos-only hacia un ciclo funcional más completo, manteniendo fuera de alcance la infraestructura pesada de almacenamiento.

**Valor para MVP:** alto  
**Acotamiento:** alto  
**Verificabilidad runtime:** alta  
**Riesgo de dispersión:** medio-bajo

### 4.2 Candidata B — listados / vistas por rol en cases
Abordar backlog pendiente de visibilidad de casos por responsable, supervisor y administrador.

**Valor para MVP:** alto  
**Acotamiento:** medio  
**Verificabilidad runtime:** media  
**Riesgo de dispersión:** medio-alto

### 4.3 Candidata C — validación jurídico-funcional pendiente
Ejecutar bloque de validación sobre criterios jurídico-funcionales aún pendientes.

**Valor para MVP:** medio  
**Acotamiento:** medio  
**Verificabilidad runtime:** alta  
**Riesgo de dispersión:** medio

## 5. Criterios de priorización
- valor directo para el MVP
- superficie acotable
- verificabilidad runtime
- bajo riesgo de dispersión
- alineación con contrato y gobierno

## 6. Foco preliminar recomendado
**Candidata A — documents**

Se recomienda abrir la siguiente unidad ejecutiva sobre `documents`, por estar expresamente señalado en backlog evolutivo, tener módulo existente y permitir una expansión controlada sin reabrir frentes cerrados ni introducir infraestructura pesada fuera de alcance.

## 7. Superficie real a intervenir
- módulos: `documents`
- endpoints: revisar los expuestos actualmente en controller
- DTOs: `src/modules/documents/**/dto/*`
- servicios: `src/modules/documents/documents.service.ts`
- repositorios: `src/modules/documents/documents.repository.ts`
- controller: `src/modules/documents/documents.controller.ts`
- contrato: sección `documents` en `docs/04_api/CONTRATO_API.md`
- pruebas: script de runtime específico por definir en la siguiente unidad
- gobierno: apertura de unidad ejecutiva E7-02 o continuidad inmediata según tamaño del gap

## 8. Hallazgos iniciales
1. E7-01 aún no estaba correctamente abierta porque faltaba su checklist de apertura.
2. El repo está sano para continuar: `main` alineada y build satisfactoria.
3. Existen archivos locales no gobernados que no deben contaminar commits metodológicos.
4. `documents` aparece como backlog evolutivo explícito, no como intuición nueva.

## 9. Riesgos
- confundir “ciclo funcional más completo” con almacenamiento real de archivos
- mezclar `documents` con `proceedings`, `reports` o validaciones transversales
- abrir implementación sin definir primero el gap exacto contrato/código/runtime

## 10. Propuesta de continuidad
1. cerrar documentalmente la apertura de E7-01
2. inspeccionar a fondo la superficie `documents`
3. identificar gap exacto del modo metadatos-only
4. abrir unidad ejecutiva siguiente sobre `documents`
5. implementar bajo alcance mínimo demostrable
6. validar runtime
7. cerrar unidad con trazabilidad completa
