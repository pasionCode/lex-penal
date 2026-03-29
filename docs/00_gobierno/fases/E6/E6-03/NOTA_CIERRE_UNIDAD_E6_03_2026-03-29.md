# NOTA DE CIERRE UNIDAD E6-03 — FLUJO CIERRE + AI 409 + CLIENT-BRIEFING

**Fecha:** 2026-03-29  
**Unidad:** E6-03 — Flujo de cierre de caso, validación AI 409 e inmutabilidad downstream de client-briefing  
**Resultado:** ✅ CERRADA

---

## 1. OBJETIVO CUMPLIDO

Validar el flujo real hasta `cerrado`, comprobar que `POST /api/v1/ai/query` responde `409` en casos cerrados, y endurecer `client-briefing` para que quede inmutable en estado terminal.

---

## 2. EVIDENCIA RUNTIME

**Script ejecutado:** `test_e6_03.sh`

| # | Criterio | Resultado |
|---|----------|-----------|
| 01 | Login admin | ✅ 200 |
| 02 | Login supervisor | ✅ 200 |
| 03 | Crear cliente y caso | ✅ 201 |
| 04 | Transición borrador → en_analisis | ✅ 201 |
| 05 | PUT /client-briefing en en_analisis | ✅ 200 |
| 06 | Setup + transición → pendiente_revision | ✅ 201 |
| 07 | Crear revisión aprobada | ✅ 201 |
| 08 | Transición → aprobado_supervisor | ✅ 201 |
| 09 | Conclusión + transición → listo_para_cliente | ✅ 201 |
| 10 | PUT /client-briefing con decision_cliente | ✅ 200 |
| 11 | Transición → cerrado | ✅ 201 |
| 12 | AI query caso cerrado | ✅ 409 |
| 13 | PUT /client-briefing caso cerrado | ✅ 409 |
| 14 | AI query caso inexistente | ✅ 404 |

**Caso de prueba:** E603-1774763046  
**ID:** 40a3bcd9-2268-4727-9d90-0a246b44f61c

---

## 3. FLUJO VALIDADO

```
BORRADOR → EN_ANALISIS → PENDIENTE_REVISION → APROBADO_SUPERVISOR → LISTO_PARA_CLIENTE → CERRADO
```

### Precondiciones por transición

| Transición | Precondiciones |
|------------|----------------|
| borrador → en_analisis | Activación válida del caso; genera checklist U008 |
| en_analisis → pendiente_revision | Estrategia + hechos + checklist crítico |
| pendiente_revision → aprobado_supervisor | Revisión vigente "aprobado" + observaciones en payload |
| aprobado_supervisor → listo_para_cliente | Conclusión operativa (5 bloques) |
| listo_para_cliente → cerrado | decision_cliente documentado |

---

## 4. SUPERFICIE IMPLEMENTADA

### 4.1 Client-briefing hardening

**Política de escritura específica:**

| Estado | Escritura |
|--------|-----------|
| en_analisis | ✅ Permitida |
| devuelto | ✅ Permitida |
| listo_para_cliente | ✅ Permitida (excepción para decision_cliente) |
| borrador | ❌ 409 |
| pendiente_revision | ❌ 409 |
| aprobado_supervisor | ❌ 409 |
| cerrado | ❌ 409 |

### 4.2 AI 409 (confirmado)

```typescript
if (estado === EstadoCaso.CERRADO) {
  throw new ConflictException('No se permite consulta IA en casos cerrados');
}
```

---

## 5. ARCHIVOS MODIFICADOS

| Archivo | Cambio |
|---------|--------|
| `src/modules/client-briefing/client-briefing.repository.ts` | +`getCaseState()` |
| `src/modules/client-briefing/client-briefing.service.ts` | +`checkWritePermission()` con política específica |

**Script de prueba:** `test_e6_03.sh`

---

## 6. DECISIONES DE DISEÑO

| Aspecto | Decisión |
|---------|----------|
| Excepción listo_para_cliente | Necesaria porque decision_cliente se documenta en ese estado |
| Política específica | client-briefing tiene regla propia, distinta a constantes generales |
| Bloqueo en cerrado | Alineado con inmutabilidad de estado terminal (R09) |

---

## 7. DEUDAS Y SALVEDADES

### 7.1 GET /client-briefing mantiene auto-creación

`findByCaseId()` sigue auto-creando briefing si no existe, sin validar estado del caso. No intervenido en esta unidad — deuda semántica menor.

### 7.2 Deuda E5-24 cerrada

AI 409 en caso cerrado quedó validado con evidencia runtime (prueba 12). La deuda de E5-24 (SKIP por no alcanzar estado cerrado) queda formalmente cerrada.

---

## 8. CRITERIOS DE ACEPTACIÓN

| Criterio | Estado |
|----------|--------|
| Caso alcanza estado cerrado por flujo real | ✅ |
| decision_cliente permite destrabar cierre | ✅ |
| AI en caso cerrado → 409 | ✅ |
| client-briefing en listo_para_cliente → 200 | ✅ |
| client-briefing en cerrado → 409 | ✅ |
| Control de acceso conservado | ✅ |
| Build verde | ✅ |
| Runtime dedicado verde | ✅ 14/14 |

---

## 9. ESTADO FASE E6

| Unidad | Módulo | Tipo | Estado |
|--------|--------|------|--------|
| E6-01 | audit | Lectura funcional | ✅ |
| E6-02 | audit | Escritura instrumentada | ✅ |
| E6-03 | cierre + AI + client-briefing | Flujo terminal + hardening | ✅ |

---

## 10. COMMIT

```
feat(client-briefing): E6-03 hardening estado + flujo cierre + AI 409

- client-briefing bloqueado en estado cerrado (409)
- Excepción controlada en listo_para_cliente
- Flujo completo hasta cerrado validado end-to-end
- AI 409 en caso cerrado (cierra deuda E5-24)
- 14 pruebas runtime validadas (test_e6_03.sh)
```
