# CHECKLIST APERTURA E5-14 — ALINEACION CONTRACTUAL Y VALIDACION DE RISKS

**Fecha:** 2026-03-28
**Unidad:** E5-14
**Tipo:** Alineacion contractual + Validacion runtime

---

## 1. OBJETIVO

Alinear el contrato API con la implementacion real del modulo `risks` y validar su comportamiento runtime.

---

## 2. NATURALEZA DEL HITO

**Fase A:** Alineacion contractual (corregir politica de edicion, documentar regla critica)
**Fase B:** Validacion runtime (20 pruebas)

---

## 3. DISCREPANCIA PRINCIPAL

| Contrato actual | Implementacion real |
|-----------------|---------------------|
| "Solo `descripcion` es editable" | PUT permite edicion completa de todos los campos |

**Tipo de discrepancia:** Documental (el contrato miente)
**Accion:** Corregir contrato, no modificar codigo

---

## 4. ENDPOINTS A VALIDAR

| Endpoint | Metodo | Comportamiento |
|----------|--------|----------------|
| `/cases/:caseId/risks` | POST | Crea riesgo (201) |
| `/cases/:caseId/risks` | GET | Lista riesgos (200, array) |
| `/cases/:caseId/risks/:riskId` | GET | Detalle riesgo (200) |
| `/cases/:caseId/risks/:riskId` | PUT | Edita riesgo completo (200) |

---

## 5. PATRON COLECCION

| Caracteristica | Valor |
|----------------|-------|
| Tipo | Coleccion editable sin DELETE expuesto |
| Cardinalidad | N riesgos por caso |
| Creacion | POST explicito |
| Edicion | PUT completo (todos los campos) |
| Eliminacion | No expuesta |
| Paginacion | No (array directo) |
| Fuga entre casos | Protegida (404) |

---

## 6. REGLA DE NEGOCIO ESPECIAL

**Si `prioridad = critica`, entonces `estrategia_mitigacion` es obligatoria.**

Aplica tanto en:
- POST (crear)
- PUT (actualizar a prioridad critica)

Codigo esperado si se viola: **400 Bad Request**

---

## 7. CRITERIOS DE ACEPTACION (20 pruebas)

| # | Criterio | Codigo esperado |
|---|----------|-----------------|
| 01 | Login admin | 200 |
| 02 | POST /clients | 201 |
| 03 | POST /cases | 201 |
| 04 | Activar caso | 201 |
| 05 | POST /risks (prioridad alta) | 201 |
| 06 | GET /risks lista | 200 (array) |
| 07 | GET /risks/:id detalle | 200 |
| 08 | PUT /risks/:id actualiza | 200 |
| 09 | POST /risks prioridad critica sin estrategia | 400 |
| 10 | PUT /risks/:id a critica sin estrategia | 400 |
| 11 | GET /risks (caso inexistente) | 404 |
| 12 | POST /risks (caso inexistente) | 404 |
| 13 | GET /risks/:id (caso inexistente) | 404 |
| 14 | PUT /risks/:id (caso inexistente) | 404 |
| 15 | GET /risks/:id (riesgo inexistente) | 404 |
| 16 | Fuga entre casos | 404 |
| 17 | GET /risks sin token | 401 |
| 18 | POST /risks sin token | 401 |
| 19 | GET /risks (estudiante caso ajeno) | 403 |
| 20 | POST /risks (estudiante caso ajeno) | 403 |

---

## 8. DIFF CONTRACTUAL

### Ubicacion
`docs/04_api/CONTRATO_API.md`, seccion 5.4 (lineas ~445-455)

### Bloque actual (incorrecto)
```markdown
#### 5.4 Riesgos del caso
POST   /api/v1/cases/{caseId}/risks
GET    /api/v1/cases/{caseId}/risks
GET    /api/v1/cases/{caseId}/risks/{riskId}
PUT    /api/v1/cases/{caseId}/risks/{riskId}

Entidad con **politica hibrida**: solo el campo `descripcion` es editable. No se permite eliminacion.
```

### Bloque nuevo (correcto)
```markdown
#### 5.4 Riesgos del caso
```
POST   /api/v1/cases/{caseId}/risks
GET    /api/v1/cases/{caseId}/risks
GET    /api/v1/cases/{caseId}/risks/{riskId}
PUT    /api/v1/cases/{caseId}/risks/{riskId}
```

Coleccion editable sin DELETE expuesto.

**Enums validos:**

| Campo | Valores |
|-------|---------|
| `probabilidad` | `alta`, `media`, `baja` |
| `impacto` | `alto`, `medio`, `bajo` |
| `prioridad` | `critica`, `alta`, `media`, `baja` |
| `estado_mitigacion` | `pendiente`, `en_curso`, `mitigado`, `aceptado` |

**Regla de negocio:** Si `prioridad = critica`, el campo `estrategia_mitigacion` es obligatorio.

**Respuestas:**

| Codigo | Descripcion |
|--------|-------------|
| `200` | Lista o detalle de riesgos, o riesgo actualizado |
| `201` | Riesgo creado |
| `400` | Payload invalido o prioridad critica sin estrategia |
| `401` | No autenticado |
| `403` | Estudiante sin acceso al caso |
| `404` | Caso o riesgo no encontrado |
```

---

## 9. SECUENCIA DE EJECUCION

```bash
# Fase A: Aplicar diff y verificar contrato
sed -n '445,480p' docs/04_api/CONTRATO_API.md

# Fase B: Validacion runtime
chmod +x test_e5_14.sh
./test_e5_14.sh
npm run build
```

---

## 10. CRITERIO DE CIERRE

| Resultado | Accion |
|-----------|--------|
| Contrato alineado + 20 PASS + build verde | E5-14 cierra |
