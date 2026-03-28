# CHECKLIST APERTURA E5-13 — ALINEACION CONTRACTUAL Y VALIDACION DE REPORTS

**Fecha:** 2026-03-28
**Unidad:** E5-13
**Tipo:** Alineacion contractual + Validacion runtime

---

## 1. OBJETIVO

Alinear el contrato API con la implementacion real del modulo `reports` y validar su comportamiento runtime.

---

## 2. NATURALEZA DEL HITO

**Fase A:** Alineacion contractual (documentar 3 endpoints, idempotencia, codigos)
**Fase B:** Validacion runtime (17 pruebas)

---

## 3. ALCANCE

### Incluye
- Actualizacion de contrato (seccion 8)
- Validacion runtime de 3 endpoints
- Verificacion de idempotencia en POST
- Confirmacion de protecciones (404, 403, 401)

### NO incluye
- Cambios en codigo
- Agregar endpoints
- Modificar logica de idempotencia

---

## 4. ENDPOINTS A VALIDAR

| Endpoint | Metodo | Comportamiento esperado |
|----------|--------|------------------------|
| `/cases/:caseId/reports` | GET | Lista informes (array) |
| `/cases/:caseId/reports` | POST | Genera informe (201, idempotente <5min) |
| `/cases/:caseId/reports/:reportId` | GET | Detalle de informe |

---

## 5. PATRON COLECCION (NO singleton)

| Caracteristica | Valor |
|----------------|-------|
| Cardinalidad | N informes por caso |
| Creacion | POST explicito |
| Idempotencia | Si existe mismo tipo+formato <5min, retorna existente |
| Fuga entre casos | Validada (404) |

---

## 6. CRITERIOS DE ACEPTACION (17 pruebas)

| # | Criterio | Codigo esperado |
|---|----------|-----------------|
| 01 | Login admin | 200 |
| 02 | POST /clients | 201 |
| 03 | POST /cases | 201 |
| 04 | Activar caso | 201 |
| 05 | POST /reports genera informe | 201 |
| 06 | GET /reports lista (array) | 200 |
| 07 | GET /reports/:id detalle | 200 |
| 08 | POST /reports idempotente (mismo ID) | 201 |
| 09 | GET /reports (caso inexistente) | 404 |
| 10 | POST /reports (caso inexistente) | 404 |
| 11 | GET /reports/:id (caso inexistente) | 404 |
| 12 | GET /reports/:id (informe inexistente) | 404 |
| 13 | GET /reports/:id (fuga entre casos) | 404 |
| 14 | GET /reports sin token | 401 |
| 15 | POST /reports sin token | 401 |
| 16 | GET /reports (estudiante caso ajeno) | 403 |
| 17 | POST /reports (estudiante caso ajeno) | 403 |

---

## 7. DIFF CONTRACTUAL

### Ubicacion
`docs/04_api/CONTRATO_API.md`, seccion 8 (lineas ~725-740)

### Bloque nuevo
```markdown
### 8. Informes

#### `GET /api/v1/cases/{caseId}/reports`
Lista los informes generados para el caso.

#### `POST /api/v1/cases/{caseId}/reports`
Solicita la generacion de un informe del caso.

**Tipos disponibles:** `resumen_ejecutivo`, `conclusion_operativa`, `control_calidad`,
`riesgos`, `cronologico`, `revision_supervisor`, `agenda_vencimientos`

**Formatos disponibles:** `pdf`, `docx`

**Idempotencia:** Si existe un informe del mismo tipo y formato generado en los ultimos 5 minutos, se retorna ese informe en lugar de crear uno nuevo.

#### `GET /api/v1/cases/{caseId}/reports/{reportId}`
Retorna el detalle de un informe especifico.

**Respuestas (todos los endpoints):**

| Codigo | Descripcion |
|--------|-------------|
| `200` | Lista o detalle de informes |
| `201` | Informe generado |
| `400` | Payload invalido (tipo o formato no valido) |
| `401` | No autenticado |
| `403` | Estudiante sin acceso al caso |
| `404` | Caso o informe no encontrado |
```

---

## 8. SECUENCIA DE EJECUCION

```bash
# Fase A: Aplicar diff y verificar contrato
sed -n '725,760p' docs/04_api/CONTRATO_API.md

# Fase B: Validacion runtime
chmod +x test_e5_13.sh
./test_e5_13.sh
npm run build
```

---

## 9. CRITERIO DE CIERRE

| Resultado | Accion |
|-----------|--------|
| Contrato alineado + 17 PASS + build verde | E5-13 cierra |
