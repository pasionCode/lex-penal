# NOTA DE CIERRE UNIDAD E29-02 — 2026-04-14

## 1. Identificación
- Fase: E29
- Unidad: E29-02
- Fecha de cierre: 2026-04-14
- Estado: CERRADA

## 2. Objetivo de la unidad
Realizar hardening contractual y validación runtime del módulo `proceedings`.

## 3. Trabajo ejecutado
- Se abrió formalmente la unidad E29-02.
- Se realizó baseline del módulo `proceedings` contrastando contrato, controller, service y repository.
- Se confirmó desalineación residual: controller append-only vs residuos de `update/remove` en service/repository y persistencia de `update-proceeding.dto.ts`.
- Se corrigió la implementación para dejar el módulo alineado con política append-only.
- Se eliminó el DTO residual de update.
- Se ajustó el contrato para reflejar también respuestas `401` y `403`.
- Se recompiló exitosamente el backend.
- Se ejecutó validación runtime con fixture real propietario/no propietario.

## 4. Evidencia funcional verificada
- `GET /cases/{caseId}/proceedings` con propietario: `200`
- `POST /cases/{caseId}/proceedings` con propietario: creación exitosa
- `GET /cases/{caseId}/proceedings/{proceedingId}` con propietario: `200`
- `GET /cases/{caseId}/proceedings` con no propietario: `403`
- `GET /cases/{caseId}/proceedings/{proceedingId}` inexistente: `404`
- `POST /cases/{caseId}/proceedings` sobre caso inexistente: `404`

## 5. Resultado
La unidad E29-02 queda cerrada satisfactoriamente.

El módulo `proceedings` queda:
- alineado con política append-only;
- consistente entre contrato e implementación;
- validado runtime en respuestas principales `200/201/403/404`.

## 6. Archivos impactados
- `docs/04_api/CONTRATO_API.md`
- `src/modules/proceedings/proceedings.service.ts`
- `src/modules/proceedings/proceedings.repository.ts`
- `src/modules/proceedings/dto/update-proceeding.dto.ts` (eliminado)
- `docs/00_gobierno/fases/E29/E29-02/NOTA_CIERRE_UNIDAD_E29_02_2026-04-14.md`
- `docs/00_gobierno/fases/E29/E29-02/evidencias/BASELINE_MODULO_PROCEEDINGS_2026-04-14.txt`

## 7. Criterio de cierre
Se cierra E29-02 por cumplimiento del objetivo técnico, contractual y runtime del módulo `proceedings`.
