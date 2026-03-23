# Registro de Observaciones de Auditoría — LEX_PENAL

**Documento:** Registro de observaciones detectadas en auditorías  
**Versión:** 1.0  
**Fecha:** 2026-03-23

---

## Índice de Observaciones

| ID | Título | Auditoría | Severidad | Estado |
|----|--------|-----------|-----------|--------|
| OBS-001 | Desalineación contrato-implementación-pruebas | J08-A | Mayor | CERRADA |

---

# OBS-001 — Desalineación contrato-implementación-pruebas

**Detectado en:** Auditoría J08-A  
**Fecha detección:** 2026-03-23  
**Severidad:** Mayor  
**Estado:** CERRADA

---

## 1. Descripción

Durante el saneamiento de la pausa J08-A se detectó desalineación sistemática entre tres capas del sistema:

| Capa | Documento/Artefacto |
|------|---------------------|
| Contrato | `docs/04_api/CONTRATO_API_v4.md` |
| Implementación | `src/modules/auth/auth.service.ts` |
| Pruebas | `tests/e2e/smoke.sh`, `smoke.ps1` |

---

## 2. Hallazgos específicos

### 2.1 Convención de nombres en respuesta de login

| Aspecto | Contrato (antes) | Implementación real |
|---------|------------------|---------------------|
| Token | `token_acceso` | `access_token` |
| Usuario | `usuario` | `user` |

**Causa:** Contrato redactado con convención español, implementación con convención inglés. Sin verificación cruzada.

### 2.2 Contraseña de pruebas

| Aspecto | Smoke tests (antes) | Configuración real (.env) |
|---------|---------------------|---------------------------|
| Password | `ChangeMe123!` | `CambiarEnProduccion_2026!` |

**Causa:** Smoke tests copiados de plantilla genérica, nunca validados contra backend real.

### 2.3 Endpoints inexistentes

| Endpoint | Estado en smoke tests | Estado real |
|----------|----------------------|-------------|
| `GET /health` | Esperado | No implementado |
| `POST /cases` | Invocado con payload incorrecto | Stub (Sprint 2 pendiente) |

**Causa:** Smoke tests asumían endpoints que no existen o no están implementados.

### 2.4 Payload de creación de casos

| Campo | Smoke tests (antes) | DTO real (`CreateCaseDto`) |
|-------|---------------------|---------------------------|
| `title` | ✓ | ✗ No existe |
| `client_name` | ✓ | ✗ No existe |
| `risk_level` | ✓ | ✗ No existe |
| `facts` | ✓ | ✗ No existe |
| `cliente_id` | ✗ | ✓ Requerido |
| `radicado` | ✗ | ✓ Requerido |
| `delito_imputado` | ✗ | ✓ Requerido |
| `regimen_procesal` | ✗ | ✓ Requerido |
| `etapa_procesal` | ✗ | ✓ Requerido |

---

## 3. Causa raíz

**Falta de verificación cruzada contrato ↔ implementación ↔ pruebas**

Factores contribuyentes:

1. **Contrato escrito antes de implementación** sin actualización posterior
2. **Smoke tests no ejecutados** contra backend real antes de merge
3. **GATE-02 sin criterio explícito** de validación de smoke tests
4. **Ausencia de CI/CD** que ejecute pruebas automáticamente

---

## 4. Implicación metodológica

Según MDS v2.2 §10.2.1:

> "No se puede cerrar jornada si conducción, gates y repositorio no coinciden."

Esta desalineación debió detectarse en J07 antes de declarar readiness para E3. El hecho de que llegara a J08-A indica falla en el proceso de verificación de cierre.

---

## 5. Corrección aplicada

| # | Acción | Resultado |
|---|--------|-----------|
| 1 | Actualizar CONTRATO_API_v4: `token_acceso` → `access_token` | ✓ |
| 2 | Actualizar CONTRATO_API_v4: `usuario` → `user` | ✓ |
| 3 | Corregir contraseña en smoke tests | ✓ |
| 4 | Eliminar `/health` de smoke tests | ✓ |
| 5 | Eliminar `POST /cases` de smoke tests (Sprint 2 pendiente) | ✓ |
| 6 | Cambiar flujo a: login → /users/me | ✓ |
| 7 | Validar smoke test contra backend real | ✓ PASSED |

---

## 6. Lección aprendida

### 6.1 Regla propuesta para GATE-02

Agregar al checklist de GATE-02:

> **Verificación de smoke tests:**  
> - [ ] Smoke tests ejecutados contra backend levantado  
> - [ ] Respuestas verificadas contra CONTRATO_API  
> - [ ] Todos los campos de request/response coinciden con DTOs reales

### 6.2 Práctica recomendada

Antes de cerrar cualquier jornada que toque endpoints:

```bash
# Levantar backend
npm run start:dev

# Ejecutar smoke tests
./tests/e2e/smoke.sh

# Verificar manualmente al menos un endpoint
curl -s http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"...","password":"..."}' | jq .
```

---

## 7. Estado de cierre

| Criterio | Estado |
|----------|--------|
| Contrato alineado con implementación | ✓ |
| Smoke tests corregidos | ✓ |
| Smoke tests validados | ✓ |
| Lección documentada | ✓ |

**Observación cerrada:** 2026-03-23  
**Responsable:** Pablo Jaramillo
