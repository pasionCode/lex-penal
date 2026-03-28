# CHECKLIST APERTURA E5-09 — VALIDACIÓN RUNTIME DE SUBJECTS

**Fecha:** 2026-03-28
**Unidad:** E5-09
**Tipo:** Validación de superficie implementada (no implementación nueva)

---

## 1. OBJETIVO

Validar que el módulo `subjects` cumple con el contrato API documentado (sección 6) sin realizar cambios de código preventivos.

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
- Confirmación de protecciones (404, fuga)
- npm run build

### NO incluye
- Refactor de enums
- Mapper nuevo
- Cambios preventivos
- Ampliación funcional
- Nuevos filtros o campos

---

## 4. ENDPOINTS A VALIDAR

| Endpoint | Método | Comportamiento esperado |
|----------|--------|------------------------|
| `/cases/:caseId/subjects` | GET | Lista paginada, filtros opcionales |
| `/cases/:caseId/subjects` | POST | Crear sujeto, retorna 201 |
| `/cases/:caseId/subjects/:subjectId` | GET | Detalle de sujeto |

---

## 5. CRITERIOS DE ACEPTACIÓN

| # | Criterio | Código esperado |
|---|----------|-----------------|
| 1 | POST /subjects crea sujeto | 201 |
| 2 | GET /subjects lista paginada | 200 |
| 3 | GET /subjects/:id retorna detalle | 200 |
| 4 | GET /subjects con caso inexistente | 404 |
| 5 | POST /subjects con caso inexistente | 404 |
| 6 | GET /subjects/:id con caso inexistente | 404 |
| 7 | GET /subjects/:id con sujeto inexistente | 404 |
| 8 | GET /subjects/:id usando sujeto de otro caso (fuga) | 404 |
| 9 | Página fuera de rango | 200 con data: [] |
| 10 | Filtro tipo o nombre funcional | 200 filtrado |
| 11 | Estructura paginada correcta | data, total, page, per_page |
| 12 | Acceso sin token | 401 |
| 13 | npm run build | Verde |

**Nota importante:** Este módulo NO tiene control de perfil (403). Solo tiene `JwtAuthGuard`, por lo tanto solo valida autenticación (401), no autorización por rol.

---

## 6. RIESGOS IDENTIFICADOS

### R1: Enum duplicado
- **Ubicación:** `CreateSubjectDto` define `TipoSujeto` y `TipoIdentificacion` localmente
- **Pero:** Service importa de `@prisma/client`
- **Riesgo:** Incompatibilidad de tipos en runtime
- **Acción:** Observar en pruebas. Si falla POST, es este el problema.

### R2: Retorno sin mapper
- **Ubicación:** `subjects.repository.ts` → `Promise<{ data: any[]; total: number }>`
- **Riesgo:** Exposición de estructura cruda de Prisma
- **Acción:** Verificar que campos coincidan con contrato.

### R3: Campos del contrato
- **Contrato espera:** id, caso_id, tipo, nombre, identificacion, tipo_identificacion, contacto, direccion, notas, creado_en, actualizado_en, creado_por, actualizado_por
- **Riesgo:** Prisma puede retornar campos diferentes o adicionales
- **Acción:** Verificar estructura en runtime.

### R4: Validación de filtros vacíos
- **Contrato dice:** Si `nombre` es vacío → 400
- **Riesgo:** El DTO podría no validar esto
- **Acción:** Observar en runtime. Si no valida, es deuda menor.

### R5: Política append-only
- **Contrato dice:** No se permite edición ni eliminación
- **Verificar:** Que PUT y DELETE no estén expuestos
- **Estado:** Controller solo tiene GET y POST (correcto)

### R6: Protección de fuga (YA MITIGADO)
- **Código actual verifica:** `subject.caso_id !== caseId`
- **Estado:** Implementado correctamente

---

## 7. CONTRATO DE REFERENCIA

**Fuente:** `docs/04_api/CONTRATO_API.md`, sección 6 (líneas 536-666)

### Respuesta esperada GET /subjects
```json
{
  "data": [...],
  "total": number,
  "page": number,
  "per_page": number
}
```

### Campos de sujeto
- id, caso_id, tipo, nombre
- identificacion, tipo_identificacion
- contacto, direccion, notas
- creado_en, actualizado_en
- creado_por, actualizado_por

---

## 8. SECUENCIA DE VALIDACIÓN

```bash
# 1. NO tocar código antes de ejecutar
# 2. Ejecutar script de validación
chmod +x test_e5_09.sh
./test_e5_09.sh

# 3. Evaluar resultados
# - Si PASS completo → cierre directo
# - Si FAIL → diagnosticar y micro-ajustar

# 4. Verificar build
npm run build
```

---

## 9. CRITERIO DE CIERRE

| Resultado | Acción |
|-----------|--------|
| 16 PASS, 0 FAIL + build verde | E5-09 cierra |
| Fallo por enum | Micro-ajuste en DTO o service |
| Fallo por estructura | Verificar mapper mínimo |
| Fallo por validación de filtros | Documentar como deuda menor |

---

## 10. DECISIÓN DE APERTURA

Se abre E5-09 en modo **validación runtime**.
No se autoriza código preventivo hasta ver fallos reales.
