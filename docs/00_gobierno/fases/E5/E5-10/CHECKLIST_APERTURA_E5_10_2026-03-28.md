# CHECKLIST APERTURA E5-10 — VALIDACIÓN RUNTIME DE PROCEEDINGS

**Fecha:** 2026-03-28
**Unidad:** E5-10
**Tipo:** Validación de superficie implementada (no implementación nueva)

---

## 1. OBJETIVO

Validar que el módulo `proceedings` cumple con el contrato API documentado (sección 5.10) sin realizar cambios de código preventivos.

---

## 2. NATURALEZA DEL HITO

**Cierre por validación**, no por implementación.

- Si las pruebas pasan → cierre directo
- Si fallan → micro-ajuste puntual, no refactor

---

## 3. ALCANCE

### Incluye
- Validación runtime de 3 endpoints
- Verificación de comportamiento contractual
- Confirmación de protecciones (404, 403, fuga)
- npm run build

### NO incluye
- Agregar paginación
- Eliminar código muerto (update/remove)
- Cambios en control de acceso
- Ampliación funcional

---

## 4. ENDPOINTS A VALIDAR

| Endpoint | Método | Comportamiento esperado |
|----------|--------|------------------------|
| `/cases/:caseId/proceedings` | GET | Lista de actuaciones (array) |
| `/cases/:caseId/proceedings` | POST | Crear actuación, retorna 201 |
| `/cases/:caseId/proceedings/:proceedingId` | GET | Detalle de actuación |

---

## 5. DIFERENCIAS CON SUBJECTS

| Aspecto | subjects | proceedings |
|---------|----------|-------------|
| Paginación | Sí (objeto con data/total/page/per_page) | No (array directo) |
| Control de perfil | No (solo JwtAuthGuard) | Sí (estudiante solo ve sus casos) |
| Código muerto | No | Sí (update/remove en service/repository) |
| Filtros | Sí (tipo, nombre, etc.) | No documentados |

---

## 6. CRITERIOS DE ACEPTACIÓN

| # | Criterio | Código esperado |
|---|----------|-----------------|
| 1 | POST /proceedings crea actuación | 201 |
| 2 | GET /proceedings lista (array) | 200 |
| 3 | GET /proceedings/:id retorna detalle | 200 |
| 4 | GET /proceedings con caso inexistente | 404 |
| 5 | POST /proceedings con caso inexistente | 404 |
| 6 | GET /proceedings/:id con caso inexistente | 404 |
| 7 | GET /proceedings/:id con actuación inexistente | 404 |
| 8 | GET /proceedings/:id usando actuación de otro caso (fuga) | 404 |
| 9 | Acceso sin token | 401 |
| 10 | Estudiante accede a caso ajeno | 403 |
| 11 | npm run build | Verde |

---

## 7. RIESGOS IDENTIFICADOS

### R1: Código muerto
- **Ubicación:** `proceedings.service.ts` y `proceedings.repository.ts`
- **Descripción:** Métodos `update()` y `remove()` existen pero no están expuestos
- **Impacto:** Ninguno en runtime (política append-only correcta en controller)
- **Acción:** Documentar como deuda de limpieza, no bloquea E5-10

### R2: Sin paginación
- **Contrato:** No especifica paginación para proceedings
- **Implementación:** Retorna array completo
- **Impacto:** Consistente con contrato actual
- **Acción:** No es un bug, es el diseño documentado

### R3: Control de acceso por perfil
- **Ubicación:** `validateCaseAccess()` en service
- **Descripción:** Estudiante solo puede ver casos donde es responsable
- **Impacto:** Puede generar 403 para estudiante en caso ajeno
- **Acción:** Probar explícitamente en script

### R4: Protección de fuga
- **Código verifica:** `proceeding.caso_id !== caseId`
- **Estado:** Implementado correctamente

---

## 8. CONTRATO DE REFERENCIA

**Fuente:** `docs/04_api/CONTRATO_API.md`, sección 5.10 (líneas 500-520)

### Respuestas documentadas
| Código | Descripción |
|--------|-------------|
| 200 | Lista o detalle de actuaciones |
| 201 | Actuación creada |
| 400 | Payload inválido |
| 404 | Caso o actuación no encontrada |

### Política
- **Append-only:** PUT y DELETE no expuestos

---

## 9. SECUENCIA DE VALIDACIÓN

```bash
# 1. NO tocar código antes de ejecutar
# 2. Ejecutar script de validación
chmod +x test_e5_10.sh
./test_e5_10.sh

# 3. Evaluar resultados
# - Si PASS completo → cierre directo
# - Si FAIL → diagnosticar y micro-ajustar

# 4. Verificar build
npm run build
```

---

## 10. CRITERIO DE CIERRE

| Resultado | Acción |
|-----------|--------|
| 11+ PASS, 0 FAIL + build verde | E5-10 cierra |
| Fallo por 403 inesperado | Revisar validateCaseAccess |
| Fallo por estructura de respuesta | Verificar contrato vs implementación |

---

## 11. DECISIÓN DE APERTURA

Se abre E5-10 en modo **validación runtime**.
No se autoriza código preventivo hasta ver fallos reales.
