# CHECKLIST APERTURA E5-23 — EVIDENCE: ALINEACIÓN CONTRACTUAL Y VALIDACIÓN RUNTIME

**Fecha:** 2026-03-28
**Unidad:** E5-23
**Tipo:** Alineación contractual + Validación runtime

---

## 1. OBJETIVO

Validar y documentar el subrecurso `evidence` como colección editable sin DELETE, con vínculo/desvínculo a hechos vía PATCH.

---

## 2. NATURALEZA DEL HITO

**Fase A:** Validación runtime (19 pruebas)
**Fase B:** Alineación contractual (si runtime OK)

---

## 3. TESIS OPERATIVA

`evidence` es una colección editable sin DELETE, con capacidad de vincular/desvincular pruebas a hechos del mismo caso mediante endpoints PATCH dedicados.

---

## 4. ENDPOINTS A VALIDAR

| Endpoint | Método | Comportamiento |
|----------|--------|----------------|
| `/cases/:caseId/evidence` | POST | Crea prueba |
| `/cases/:caseId/evidence` | GET | Lista pruebas |
| `/cases/:caseId/evidence/:evidenceId` | GET | Detalle prueba |
| `/cases/:caseId/evidence/:evidenceId` | PUT | Actualiza prueba |
| `/cases/:caseId/evidence/:evidenceId/link` | PATCH | Vincula a hecho |
| `/cases/:caseId/evidence/:evidenceId/unlink` | PATCH | Desvincula de hecho |

**Guard:** JwtAuthGuard

---

## 5. DTOs

### CreateEvidenceDto (9 campos)

| Campo | Tipo | MaxLength | Obligatorio |
|-------|------|-----------|-------------|
| `descripcion` | string | 2000 | Sí |
| `tipo_prueba` | enum | - | Sí |
| `hecho_id` | UUID | - | No |
| `hecho_descripcion_libre` | string | 500 | No |
| `licitud` | enum | - | Sí |
| `legalidad` | enum | - | Sí |
| `suficiencia` | enum | - | Sí |
| `credibilidad` | enum | - | Sí |
| `posicion_defensiva` | string | 1000 | No |

### UpdateEvidenceDto (8 campos, todos opcionales)

| Campo | Tipo | MaxLength |
|-------|------|-----------|
| `descripcion` | string | 2000 |
| `tipo_prueba` | enum | - |
| `hecho_descripcion_libre` | string | 500 |
| `licitud` | enum | - |
| `legalidad` | enum | - |
| `suficiencia` | enum | - |
| `credibilidad` | enum | - |
| `posicion_defensiva` | string | 1000 |

**Nota:** `hecho_id` se gestiona vía /link y /unlink, no vía PUT.

### LinkEvidenceDto (1 campo)

| Campo | Tipo | Obligatorio |
|-------|------|-------------|
| `hecho_id` | UUID | Sí |

---

## 6. ENUMS

| Enum | Valores |
|------|---------|
| `TipoPrueba` | `testimonial`, `documental`, `pericial`, `real`, `otro` |
| `EvaluacionProbatoria` | `ok`, `cuestionable`, `deficiente` |

---

## 7. REGLAS DE ACCESO

| Endpoint | Estudiante responsable | Estudiante ajeno | Supervisor | Admin |
|----------|------------------------|------------------|------------|-------|
| POST | 201 | 403 | 201 | 201 |
| GET lista | 200 | 403 | 200 | 200 |
| GET detalle | 200 | 403 | 200 | 200 |
| PUT | 200 | 403 | 200 | 200 |
| PATCH /link | 200 | 403 | 200 | 200 |
| PATCH /unlink | 200 | 403 | 200 | 200 |

*Supervisor: comportamiento esperado según código, no validado en runtime de esta unidad.

---

## 8. CRITERIOS DE ACEPTACIÓN (19 pruebas)

| # | Criterio | Código esperado |
|---|----------|-----------------|
| 01 | Login admin | 200 |
| 02 | POST /clients | 201 |
| 03 | POST /cases | 201 |
| 04 | Activar caso | 200/201 |
| 05 | POST /facts (crear hecho para vínculo) | 201 |
| 06 | GET /evidence (lista vacía) | 200 |
| 07 | POST /evidence | 201 |
| 08 | GET /evidence (lista con 1) | 200 |
| 09 | GET /evidence/:id (detalle) | 200 |
| 10 | PUT /evidence/:id (update parcial) | 200 |
| 11 | PATCH /evidence/:id/link (vincular a hecho) | 200 |
| 12 | GET /evidence/:id (confirma vínculo) | 200 |
| 13 | PATCH /evidence/:id/unlink (desvincular) | 200 |
| 14 | GET /evidence/:id (confirma desvinculado) | 200 |
| 15 | GET /evidence/:id (inexistente) | 404 |
| 16 | PATCH /link (hecho de otro caso) | 400/403/404 |
| 17 | POST /evidence (tipo_prueba inválido) | 400 |
| 18 | GET /evidence sin token | 401 |
| 19 | GET /evidence (estudiante ajeno) | 403 |

---

## 9. SEMÁNTICA A VERIFICAR

| Aspecto | Pregunta | Verificar en runtime |
|---------|----------|---------------------|
| PUT | ¿Update parcial o completo? | Prueba 10 |
| link/unlink | ¿Exige mismo caso? | Prueba 16 |
| hecho_id inválido | ¿400 o 404? | Prueba 16 |
| Aislamiento | ¿403 estudiante ajeno? | Prueba 19 |

---

## 10. FUERA DE ALCANCE

- Endpoint DELETE (no expuesto)
- Cambios estructurales a DTOs
- Migraciones de datos

---

## 11. DIFF CONTRACTUAL

### Ubicación
`docs/04_api/CONTRATO_API.md`, sección **5.2 Pruebas del caso**

Buscar por encabezado `#### 5.2 Pruebas del caso`, no por número de línea.

### Bloque nuevo
Ver archivo `DIFF_EVIDENCE_CONTRATO.md`

---

## 12. SECUENCIA DE EJECUCIÓN

```bash
# Fase A: Validación runtime
chmod +x test_e5_23.sh
./test_e5_23.sh
npm run build

# Fase B: Aplicar diff contractual (si runtime OK)
```

---

## 13. CRITERIO DE CIERRE

| Resultado | Acción |
|-----------|--------|
| Runtime conforme + contrato actualizado + build verde | E5-23 cierra |
