# NOTA DE CIERRE UNIDAD E26-02 — 2026-04-14

## 1. Identificación
- Fase: E26
- Unidad: E26-02
- Nombre: Normalización de escritura, mutabilidad y semántica operativa de Facts
- Estado: CERRADA

## 2. Objetivo de la unidad
Verificar y alinear la semántica real de acceso, escritura, orden automático, mutabilidad y errores del módulo Facts respecto al contrato y a la política general del caso.

## 3. Resultado
Unidad cumplida.

## 4. Hallazgo determinante
- El módulo Facts ya respetaba orden automático, update parcial e aislamiento por caso.
- La brecha real estaba en escritura: `create` y `update` no validaban estado del caso.
- El contrato tampoco reflejaba `409` por estado no habilitado.

## 5. Medidas aplicadas
- Se corrigió `facts.service.ts` para:
  - exigir control de escritura por estado en `POST /facts`;
  - exigir control de escritura por estado en `PUT /facts/:factId`;
  - restringir escritura a `en_analisis` y `devuelto`.
- Se agregó `getCaseState(casoId)` a `FactsRepository`.
- Se normalizó `CONTRATO_API.md` para documentar `409` y la restricción de escritura por estado.

## 6. Validación
- El proyecto compiló correctamente después del ajuste.
- El código quedó alineado con la política general de edición del caso.
- `orden` se mantuvo automático e inmutable.

## 7. Decisión de cierre
Se cierra E26-02 y se abre E26-03 para cierre formal de fase E26.
