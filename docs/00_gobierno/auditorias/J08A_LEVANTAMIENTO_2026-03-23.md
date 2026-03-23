# Acta de Levantamiento de Pausa Metodológica J08-A

**Proyecto:** LEX_PENAL  
**Fecha:** 2026-03-23  
**Pausa levantada:** J08-A  
**Referencia:** MDS v2.2 §10.2.1, §10.2.2  
**Archivo:** `docs/00_gobierno/auditorias/J08A_LEVANTAMIENTO_2026-03-23.md`

---

## 1. Contexto

### 1.1 Origen de la pausa

La pausa metodológica J08-A fue declarada el 2026-03-22 tras la auditoría del repositorio LEX_PENAL que identificó:

- **Hallazgo C-01:** Documento de conducción desactualizado
- **Hallazgo C-02:** Lógica de negocio en scaffold (CasoEstadoService)
- **Hallazgo C-03:** 14 controllers con prefijo `api/v1` duplicado
- **Hallazgos M-01 a M-04:** Deficiencias documentales menores

### 1.2 Condición de levantamiento original

> "El saneamiento técnico debe completarse antes de continuar con el Sprint 2."

---

## 2. Saneamiento ejecutado

### 2.1 Técnico

| Acción | Archivos | Estado |
|--------|----------|--------|
| Remover prefijo duplicado en controllers | 14 archivos en `src/modules/` | ✓ |
| Verificar build | `npm run build` | ✓ |
| Alinear CONTRATO_API_v4 con implementación | `access_token`, `user` | ✓ |
| Corregir smoke tests | 4 archivos | ✓ |
| Validar smoke tests contra backend | `./tests/e2e/smoke.sh` | ✓ PASSED |

### 2.2 Documental

| Documento | Acción | Estado |
|-----------|--------|--------|
| DESVIACIONES.md | DESV-001 cerrada (actualizado) | ✓ |
| OBSERVACIONES_AUDITORIA.md | OBS-001 registrada y cerrada (nuevo) | ✓ |
| ADR-009 | Emitido (prefijo global y rutas relativas) | ✓ preexistente |
| CONTRATO_API_v4 | Actualizado | ✓ |

---

## 3. Hallazgos adicionales durante saneamiento

Durante la ejecución del saneamiento se descubrió **OBS-001: Desalineación contrato-implementación-pruebas**, que incluía:

| Problema | Antes | Después |
|----------|-------|---------|
| Token en respuesta | `token_acceso` (contrato) vs `access_token` (código) | Alineado a `access_token` |
| Usuario en respuesta | `usuario` (contrato) vs `user` (código) | Alineado a `user` |
| Contraseña smoke tests | `ChangeMe123!` | `CambiarEnProduccion_2026!` |
| Endpoint /health | Esperado | Eliminado (no existe) |
| POST /cases | Payload incorrecto | Eliminado (Sprint 2 pendiente) |

Esta observación fue registrada, corregida y cerrada en la misma sesión.

---

## 4. Verificación final

### 4.1 Checklist de validación

| # | Criterio | Comando | Resultado |
|---|----------|---------|-----------|
| 1 | Ningún controller con prefijo duplicado | `grep -rn "@Controller('api/v1" src/modules/` | 0 coincidencias ✓ |
| 2 | Contrato usa `access_token` | `grep "access_token" CONTRATO_API_v4.md` | Presente ✓ |
| 3 | Contrato no usa `token_acceso` | `grep "token_acceso" CONTRATO_API_v4.md` | 0 coincidencias ✓ |
| 4 | Smoke tests con contraseña correcta | `grep "CambiarEnProduccion" tests/e2e/*.sh tests/e2e/*.ps1 scripts/*/*.sh scripts/*/*.ps1` | 4/4 archivos ✓ |
| 5 | Smoke tests sin /health ni /cases | `grep -E "health\|/cases" tests/e2e/*.sh tests/e2e/*.ps1 scripts/*/*.sh scripts/*/*.ps1` | 0 coincidencias en 4 archivos ✓ |
| 6 | Build exitoso | `npm run build` | ✓ |
| 7 | Smoke test pasa | `./tests/e2e/smoke.sh` | COMPLETADO ✓ |

### 4.2 Salida del smoke test

```
[1/2] Login
[OK] Login — token obtenido
[2/2] GET /users/me
[OK] /users/me — autenticación verificada
=== SMOKE TEST COMPLETADO ===
```

---

## 5. Commits de cierre (planificados)

> Los siguientes commits serán ejecutados tras la aprobación de esta acta.

| # | Scope | Mensaje | Archivos |
|---|-------|---------|----------|
| 1 | fix(api) | Remover prefijo api/v1 duplicado en controllers | 14 controllers |
| 2 | docs(api) | Alinear contrato con implementación real | CONTRATO_API_v4.md |
| 3 | fix(tests) | Alinear smoke tests con implementación | 4 archivos smoke |
| 4 | docs(gobierno) | Cerrar pausa metodológica J08-A | Documentos de gobierno |

---

## 6. Lecciones aprendidas

### 6.1 Para el proceso de desarrollo

1. **Ejecutar smoke tests antes de declarar readiness** — No confiar en que "deberían funcionar".
2. **Verificar consistencia contrato ↔ código** — Especialmente convenciones de nombres.
3. **No usar plantillas genéricas sin adaptar** — Smoke tests deben derivarse del contrato real.

### 6.2 Para GATE-02 (propuesta)

Agregar criterio explícito:

> **Smoke tests validados:**  
> - Smoke tests ejecutados contra backend levantado  
> - Respuestas verificadas contra estructura del contrato  
> - Campos de request/response coinciden con DTOs reales

---

## 7. Estado post-levantamiento

| Aspecto | Estado |
|---------|--------|
| Pausa J08-A | **LEVANTADA** |
| DESV-001 | CERRADA |
| OBS-001 | CERRADA |
| Etapa habilitada | E3 |
| Próximo paso | Abrir Jornada 08, Sprint 2 |

---

## 8. Firmas

**Levantamiento autorizado por:**

Pablo Jaramillo  
2026-03-23

---

## Anexo: Resumen de archivos modificados

### Código (14 controllers)

```
src/modules/ai/ai.controller.ts
src/modules/audit/audit.controller.ts
src/modules/cases/cases.controller.ts
src/modules/checklist/checklist.controller.ts
src/modules/client-briefing/client-briefing.controller.ts
src/modules/clients/clients.controller.ts
src/modules/conclusion/conclusion.controller.ts
src/modules/evidence/evidence.controller.ts
src/modules/facts/facts.controller.ts
src/modules/reports/reports.controller.ts
src/modules/review/review.controller.ts
src/modules/risks/risks.controller.ts
src/modules/strategy/strategy.controller.ts
src/modules/strategy/timeline.controller.ts
```

### Documentación

```
docs/04_api/CONTRATO_API_v4.md
docs/00_gobierno/registros/DESVIACIONES.md
docs/00_gobierno/registros/OBSERVACIONES_AUDITORIA.md
docs/00_gobierno/auditorias/J08A_LEVANTAMIENTO_2026-03-23.md
```

### Pruebas

```
tests/e2e/smoke.sh
tests/e2e/smoke.ps1
scripts/linux/smoke.sh
scripts/windows/smoke.ps1
```
