# NOTA DE CIERRE UNIDAD E5-24 — 2026-03-28

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E5 — Consolidación
- Unidad: E5-24 — Validación runtime y alineación contractual de AI
- Fecha de cierre: 2026-03-28
- Estado: CERRADA (PARCIAL)

## 2. Objetivo de la unidad
Validar en runtime el endpoint `POST /api/v1/ai/query`, confirmar su request/response real en MVP, documentar sus códigos de respuesta efectivos y alinear la sección 9 del contrato API con la implementación vigente.

## 3. Alcance ejecutado
Durante la unidad E5-24 se ejecutaron las siguientes acciones:

1. Se levantó baseline funcional del módulo `ai`.
2. Se verificó la existencia del endpoint:
   - `POST /api/v1/ai/query`
3. Se revisó el controller, el service y el DTO `AIQueryDto`.
4. Se confirmó que el módulo opera en modo MVP con respuesta placeholder y sin proveedor IA real.
5. Se ejecutó validación runtime dedicada mediante `test_e5_24.sh`.
6. Se confirmó distinción funcional entre:
   - `400` por payload inválido
   - `404` por `caso_id` válido pero inexistente
7. Se ejecutó `npm run build` con resultado satisfactorio.
8. Se dejó definido el bloque contractual a aplicar sobre la sección 9 mediante `DIFF_AI_CONTRATO.md`.

## 4. Hallazgos de baseline
Se confirmó que la implementación real del módulo `ai` incluye:

- validación de existencia de caso
- control de acceso por ownership para estudiante
- restricción de uso en caso cerrado
- respuesta placeholder MVP
- registro de trazabilidad de la consulta

También se confirmó que el contrato vigente estaba incompleto respecto de:

- body real del endpoint
- response body real
- código `401`
- código `409`
- naturaleza MVP placeholder
- eliminación de `503` como código vigente del MVP

## 5. Superficie validada
### Endpoint
- `POST /api/v1/ai/query`

### Guard
- `JwtAuthGuard`

### Request body real (`AIQueryDto`)
| Campo | Tipo | Obligatorio | Restricción |
|---|---|---|---|
| `caso_id` | UUID v4 | Sí | Debe ser UUID válido |
| `herramienta` | enum | Sí | Herramienta IA permitida |
| `consulta` | string | Sí | No vacía, máximo 2000 caracteres |

### Enum `HerramientaIA`
- `basic_info`
- `facts`
- `evidence`
- `risks`
- `strategy`
- `client_briefing`
- `checklist`
- `conclusion`

### Response body real (`AIResponse`)
| Campo | Tipo | Descripción |
|---|---|---|
| `respuesta` | string | Respuesta textual del módulo |
| `tokens_entrada` | number | Tokens estimados de entrada |
| `tokens_salida` | number | Tokens estimados de salida |
| `modelo_usado` | string | Identificador del modelo |

**Valor MVP validado:** `modelo_usado = placeholder_v1`

## 6. Evidencia runtime

### 6.1 Script ejecutado
- Script: `test_e5_24.sh`

### 6.2 Resultado global
- Pasadas: `12`
- Fallidas: `0`
- Omitidas: `2`

### 6.3 Resultado por fases
| Fase | Pruebas | Resultado |
|---|---|---|
| Setup | 01-04 | ✅ |
| Consulta válida | 05 | ✅ `201` |
| Shape estricto | 06 | ✅ `placeholder_v1`, tokens numéricos |
| Payloads inválidos | 07-09 | ✅ `400` |
| Caso inexistente | 10 | ✅ `404` |
| Sin token | 11 | ✅ `401` |
| Estudiante ajeno | 12 | ✅ `403` |
| Caso cerrado | 13-14 | ⚠️ `SKIP` |

### 6.4 Hallazgo importante
La prueba 10 ejecutada con `caso_id` en formato UUID v4 válido e inexistente retornó `404`, confirmando que el comportamiento real distingue correctamente entre:

- `400` — payload inválido
- `404` — caso inexistente con identificador válido

### 6.5 Evidencia del último escenario ejecutado
- Caso principal: `E524-1774752111`
- ID caso principal: `037a79bf-1c00-46c9-9f5b-ab13adde3cd1`
- Caso para cierre: `E524B-1774752111`
- ID caso para cierre: `e8c4eae0-ed89-4345-92c4-ec1235a3fc75`

## 7. Pruebas omitidas
| Prueba | Razón |
|---|---|
| 13 | Estado `cerrado` no alcanzable en el flujo actual |
| 14 | Dependencia directa de la prueba 13 |

**Implicación:** el código `409` para caso cerrado está implementado en el service y se documenta contractualmente como comportamiento esperado, pero no fue verificado en runtime dentro del flujo ejecutado en esta unidad.

## 8. Semántica validada del módulo
Se validó en runtime que:

1. `POST /ai/query` procesa consultas válidas del caso.
2. La respuesta del MVP retorna `modelo_usado = placeholder_v1`.
3. La respuesta incluye tokens de entrada y salida numéricos.
4. Payload inválido produce `400`.
5. `caso_id` válido pero inexistente produce `404`.
6. Sin token produce `401`.
7. Estudiante ajeno produce `403`.

No se verificó en runtime el `409` por caso cerrado debido a la no alcanzabilidad de esa precondición dentro del flujo disponible.

## 9. Build
Se ejecutó `npm run build` con resultado satisfactorio.

Estado:
- Build: ✅ VERDE

## 10. Resultado contractual a incorporar
Para alinear contrato y runtime, la unidad deja identificado que la sección **9. Módulo de IA** debe actualizarse con el bloque contenido en:

- `DIFF_AI_CONTRATO.md`

Ese bloque debe reflejar:

- request body real (`AIQueryDto`)
- response body real (`AIResponse`)
- `201` como comportamiento runtime observado del endpoint
- `400` por payload inválido
- `401` por ausencia de token
- `403` por acceso indebido
- `404` por caso inexistente con UUID válido
- `409` por caso en estado cerrado
- retiro de `503` del contrato vigente del MVP
- nota expresa de que el módulo opera con placeholder local

## 11. Criterios de cierre verificados
La unidad E5-24 se considera cerrada parcialmente porque se verificó que:

- el módulo `ai` quedó validado en su operación principal
- el runtime del endpoint fue contrastado con cobertura suficiente
- el build del proyecto permanece estable
- la distinción entre `400` y `404` quedó demostrada
- el ajuste contractual requerido quedó definido explícitamente
- la única porción no verificada depende de una condición externa al módulo (`estado cerrado` alcanzable)

## 12. Estado actualizado de la fase E5
- E5-09 a E5-23: ✅
- E5-24 (`ai`): ✅ (parcial)

Backlog restante de E5:

| Orden | Unidad | Módulo | Tipo |
|---|---|---|---|
| 1 | E5-25 | `audit` | Decisión: implementar o documentar fuera de MVP |

## 13. Conclusión
La unidad E5-24 queda cerrada parcialmente con runtime conforme (`12 PASS / 0 FAIL / 2 SKIP`), build estable y módulo `ai` validado en su comportamiento principal de MVP.

El código `409` para caso cerrado queda documentado contractualmente como comportamiento esperado, pero no verificado en runtime dentro de esta unidad por dependencia externa de la máquina de estados del caso.

No se identificó deuda funcional crítica en el módulo `ai`. El remanente de la unidad corresponde únicamente a la no alcanzabilidad del estado `cerrado` dentro del flujo usado para la validación.

