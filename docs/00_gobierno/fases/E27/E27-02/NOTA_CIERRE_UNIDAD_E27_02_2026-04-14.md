# NOTA DE CIERRE UNIDAD E27-02 — 2026-04-14

## 1. Identificación
- Fase: E27
- Unidad: E27-02
- Nombre: Normalización de escritura, vínculo y semántica operativa de Evidence
- Estado: CERRADA

## 2. Objetivo de la unidad
Verificar y alinear la semántica real de acceso, escritura, actualización, `link/unlink`, control por estado y errores del módulo Evidence respecto al contrato y a la política general del caso.

## 3. Resultado
Unidad cumplida.

## 4. Hallazgo determinante
- El módulo Evidence ya validaba correctamente la pertenencia del hecho al mismo caso en `create` y `link`.
- La brecha real estaba en escritura: `create`, `update`, `link` y `unlink` no validaban estado del caso.
- El contrato tampoco reflejaba restricción por estado para esas operaciones.

## 5. Medidas aplicadas
- Se corrigió `evidence.service.ts` para exigir control de escritura por estado en:
  - `POST /evidence`
  - `PUT /evidence/:id`
  - `PATCH /evidence/:id/link`
  - `PATCH /evidence/:id/unlink`
- Se agregó `getCaseState(casoId)` a `EvidenceRepository`.
- Se normalizó `CONTRATO_API.md` para reflejar `409` tanto por hecho de otro caso como por estado no habilitado.

## 6. Validación
- El proyecto compiló correctamente después del ajuste técnico.
- La verificación muestra `ConflictException`, `checkWritePermission` y `getCaseState` presentes en el módulo.
- Se preservó la protección de `hecho_id` fuera de PUT.

## 7. Decisión de cierre
Se cierra E27-02 y se abre E27-03 para cierre formal de fase E27.
