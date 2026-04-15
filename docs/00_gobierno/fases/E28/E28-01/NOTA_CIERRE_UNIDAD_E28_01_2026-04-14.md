# NOTA DE CIERRE UNIDAD E28-01 — 2026-04-14

## 1. Identificación
- Fase: E28
- Unidad: E28-01
- Fecha de cierre: 2026-04-14
- Estado: CERRADA

## 2. Objetivo de la unidad
Alinear el módulo `risks` con la semántica vigente del contrato API y con el patrón funcional del proyecto para subrecursos editables, incorporando guardia de estado de escritura y validación runtime mínima suficiente.

## 3. Trabajo ejecutado
- Se ajustó el contrato en `docs/04_api/CONTRATO_API.md` para documentar expresamente:
  - comportamiento de lectura en `GET /risks` y `GET /risks/{riskId}`;
  - restricción de escritura de `POST /risks` y `PUT /risks/{riskId}` a estados `en_analisis` y `devuelto`;
  - respuesta `409` cuando el estado actual no permite crear o modificar riesgos.
- Se corrigió `src/modules/risks/risks.repository.ts` incorporando consulta del estado real del caso mediante `estado_actual`.
- Se corrigió `src/modules/risks/risks.service.ts` incorporando:
  - `ConflictException`;
  - validación de estado escribible antes de `create` y `update`;
  - conservación de validación de negocio para `prioridad = critica` con `estrategia_mitigacion` obligatoria.
- Se recompiló el backend exitosamente tras saneamiento del repository y service.
- Se ejecutó validación runtime real contra backend levantado en puerto `3001`.

## 4. Evidencias funcionales verificadas
### 4.1 Validaciones ya comprobadas
- Login real con usuario bootstrap administrador.
- `GET /api/v1/health` operativo.
- `POST /risks` válido sobre caso real en `en_analisis`.
- `POST /risks` con `prioridad = critica` sin estrategia: `400`.
- `GET /risks` sobre caso real: lista correcta.
- `POST /risks` sobre caso bloqueado (`borrador`): `409`.

### 4.2 Validaciones finales de remate
- `GET /risks/{riskId}` sobre riesgo existente: `200`.
- `PUT /risks/{riskId}` válido: `200`.
- `PUT /risks/{riskId}` sobre caso bloqueado: `409`.
- `GET /risks/{riskId}` para riesgo inexistente: `404`.
- `POST /risks` sobre caso inexistente: `404`.

## 5. Resultado
La unidad E28-01 queda cerrada satisfactoriamente.  
El módulo `risks` quedó alineado con el contrato y con el patrón funcional esperado para subrecursos editables del proyecto.

## 6. Salvedad documentada
No se ejecutó en esta unidad la prueba `403` de aislamiento entre estudiante propietario y estudiante no propietario, por ausencia de fixture de seguridad específico listo para reutilización inmediata.

Esta ausencia **no bloquea** el cierre de E28-01, porque:
- no afecta la validación del núcleo funcional de `risks`;
- el control de acceso por perfil y propiedad ya existe a nivel de servicio;
- la deuda corresponde a provisión de fixture runtime, no a defecto confirmado del módulo.

## 7. Deuda residual
- Preparar fixture reutilizable para pruebas `403` de aislamiento entre estudiantes en módulos case-scoped.
- Ejecutar esa validación en una unidad posterior de hardening/runtime de seguridad.

## 8. Archivos impactados
- `docs/04_api/CONTRATO_API.md`
- `src/modules/risks/risks.repository.ts`
- `src/modules/risks/risks.service.ts`
- `scripts/test_e28_01_risks.sh`
- `scripts/find_blocked_case.ts`
- `scripts/diag_e28_01_fixture_inventory.ts`
- `docs/00_gobierno/fases/E28/E28-01/evidencias/*`

## 9. Criterio de cierre
Se cierra la unidad E28-01 por cumplimiento del objetivo técnico y contractual, con validación runtime suficiente del comportamiento principal y de los estados de error críticos `400`, `404` y `409`.
