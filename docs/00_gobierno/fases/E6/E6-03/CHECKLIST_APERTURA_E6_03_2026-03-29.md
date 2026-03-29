# CHECKLIST APERTURA E6-03 — 2026-03-29

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E6 — Integración y hardening del MVP
- Unidad: E6-03 — Flujo de cierre de caso, validación AI 409 e inmutabilidad downstream de client-briefing
- Fecha de apertura: 2026-03-29
- Estado: ABIERTA

## 2. Objetivo específico
Validar el flujo real hasta `cerrado`, comprobar que `POST /api/v1/ai/query` responde `409` en casos cerrados, y endurecer el comportamiento downstream de `client-briefing` para que el recurso:

- permita documentar `decision_cliente` cuando el caso esté listo para cliente
- quede inmutable una vez el caso alcance estado `cerrado`
- conserve coherencia con la máquina de estados real del sistema

## 3. Justificación
La evidencia vigente confirma que:

- la máquina de estados sí permite llegar a `cerrado`
- la guarda final exige `decision_cliente`
- AI ya bloquea consultas en casos cerrados con `409`
- `client-briefing` sí persiste `decision_cliente`, pero hoy no valida estado del caso

E6-03 se abre para cerrar esa brecha y validar end-to-end el comportamiento del MVP en estado terminal.

## 4. Alcance de E6-03
Debe quedar implementado, validado y documentado, como mínimo:

- baseline técnico del flujo hasta `cerrado`
- confirmación de la guarda `decision_cliente`
- confirmación runtime de `AI 409` en caso cerrado
- hardening de `client-briefing` por estado
- excepción funcional explícita para permitir edición en `listo_para_cliente`
- bloqueo de edición en `cerrado`
- script runtime dedicado
- build verde
- nota de cierre E6-03

## 5. Fuera de alcance
Queda fuera de alcance de E6-03:

- hardening concurrente de `version_revision`
- restricciones únicas nuevas en base de datos
- refactor transversal de todos los recursos operativos
- regresión exhaustiva de toda la fase E6
- cambios de frontend o UI
- rediseño del módulo IA

## 6. Baseline técnico mínimo

### 6.1 Flujo válido hasta cerrado
Ruta funcional objetivo:

`BORRADOR → EN_ANALISIS → PENDIENTE_REVISION → APROBADO_SUPERVISOR → LISTO_PARA_CLIENTE → CERRADO`

### 6.2 Guarda de cierre
La transición `listo_para_cliente → cerrado` exige que exista `decision_cliente` documentada en `explicacionCliente`.

### 6.3 Guarda AI
`AIService.query()` debe retornar `409` si el caso está en `EstadoCaso.CERRADO`.

### 6.4 Brecha detectada
`ClientBriefingService.update()` hoy valida acceso, pero no valida estado del caso.

## 7. Decisión de diseño

### 7.1 Regla específica para client-briefing
`client-briefing` tendrá política propia de escritura:

**Permitido en:**
- `en_analisis`
- `devuelto`
- `listo_para_cliente`

**Bloqueado en:**
- `borrador`
- `pendiente_revision`
- `aprobado_supervisor`
- `cerrado`

### 7.2 Justificación de la excepción
Aunque la política general de escritura bloquea `listo_para_cliente`, este recurso requiere excepción controlada porque el cierre depende de documentar `decision_cliente` precisamente en el tramo final.

### 7.3 Lugar de intervención
La validación debe implementarse en `ClientBriefingService.update()`, consultando el estado real del caso desde el repository.

## 8. Archivos comprometidos
- `src/modules/client-briefing/client-briefing.service.ts`
- `src/modules/client-briefing/client-briefing.repository.ts`
- `test_e6_03.sh`
- `docs/00_gobierno/fases/E6/E6-03/...`

## 9. Entregables mínimos
- checklist de apertura E6-03
- baseline técnico E6-03
- ajuste de guardas de `client-briefing`
- script `test_e6_03.sh`
- evidencia runtime
- build verde
- nota de cierre E6-03

## 10. Criterios de aceptación
E6-03 cierra solo si se verifica:

1. el caso puede llegar a `cerrado` por flujo real
2. `decision_cliente` permite destrabar la transición final
3. `POST /api/v1/ai/query` sobre caso cerrado retorna `409`
4. `PUT /client-briefing` en `listo_para_cliente` funciona
5. `PUT /client-briefing` en `cerrado` retorna `409`
6. no se rompe el control de acceso existente
7. build verde
8. runtime dedicado en verde

## 11. Cobertura runtime sugerida
Pruebas mínimas:

1. login admin / supervisor / estudiante
2. crear cliente y caso
3. transicionar `borrador → en_analisis`
4. `PUT /client-briefing` en `en_analisis` → 200
5. transicionar `en_analisis → pendiente_revision`
6. crear revisión aprobada
7. transicionar `pendiente_revision → aprobado_supervisor`
8. transicionar `aprobado_supervisor → listo_para_cliente`
9. `PUT /client-briefing` con `decision_cliente` en `listo_para_cliente` → 200
10. transicionar `listo_para_cliente → cerrado` → 201
11. `POST /api/v1/ai/query` en caso cerrado → 409
12. `PUT /client-briefing` en caso cerrado → 409
13. caso inexistente en AI → 404
14. build verde

## 12. Riesgo principal
El principal riesgo de E6-03 es endurecer `client-briefing` sin conservar la excepción funcional necesaria en `listo_para_cliente`, bloqueando de forma artificial el cierre del caso.

## 13. Siguiente paso inmediato
Implementar baseline puntual y hardening de `client-briefing` con esta pregunta operativa:

**¿Cómo bloquear escritura en estados terminales sin impedir la documentación de `decision_cliente` en `listo_para_cliente`?**
