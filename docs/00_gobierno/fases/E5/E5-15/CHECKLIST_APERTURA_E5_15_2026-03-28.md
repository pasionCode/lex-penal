# CHECKLIST APERTURA E5-15 — ALINEACION CONTRACTUAL Y VALIDACION DE REVIEW

**Fecha:** 2026-03-28
**Unidad:** E5-15
**Tipo:** Alineacion contractual + Validacion runtime

---

## 1. OBJETIVO

Completar el contrato API del modulo `review` y validar su comportamiento runtime.

---

## 2. NATURALEZA DEL HITO

**Fase A:** Alineacion contractual (completar tabla de codigos, enums, DTO)
**Fase B:** Validacion runtime (19 pruebas)

---

## 3. ENDPOINTS A VALIDAR

| Endpoint | Metodo | Comportamiento |
|----------|--------|----------------|
| `/cases/:caseId/review` | GET | Historial (solo supervisor/admin) |
| `/cases/:caseId/review` | POST | Crear revision (solo en `pendiente_revision`) |
| `/cases/:caseId/review/feedback` | GET | Vista filtrada para responsable |

---

## 4. PATRON COLECCION APPEND-ONLY

| Caracteristica | Valor |
|----------------|-------|
| Tipo | Coleccion append-only (historial versionado) |
| Creacion | POST (solo supervisor/admin, solo en `pendiente_revision`) |
| Edicion | No expuesta |
| Eliminacion | No expuesta |
| Versionamiento | Cada POST incrementa `version_revision` |
| Vigencia | Nueva revision = vigente, anteriores = no vigentes |

---

## 4.1 PRECONDICIONES PARA TRANSICION A `pendiente_revision`

La transicion `en_analisis → pendiente_revision` tiene guardas de negocio que deben cumplirse:

| Guarda | Endpoint | Payload minimo |
|--------|----------|----------------|
| Checklist criticos completos | `PUT /cases/:id/checklist` | `{items: [{id, marcado: true}, ...]}` |
| Estrategia con linea principal | `PUT /cases/:id/strategy` | `{linea_principal: "..."}` |
| Al menos 1 hecho registrado | `POST /cases/:id/facts` | `{descripcion: "...", estado_hecho: "referido"}` |

**Nota:** El script de validacion cumple estas guardas en pruebas 05-07 antes de transicionar en prueba 08.

---

## 4.2 ESTRATEGIA DE PRUEBA 409

La prueba de `POST /review` fuera de estado correcto (409) se ejecuta sobre un **caso secundario** que permanece en `en_analisis`, no sobre el caso principal que ya transiciono a `pendiente_revision`.

---

## 5. REGLAS DE ACCESO

| Endpoint | Estudiante | Supervisor | Admin |
|----------|------------|------------|-------|
| GET /review | 403 | 200 | 200 |
| POST /review | 403 | 201* | 201* |
| GET /feedback | 200 (si responsable) | 200 | 200 |

*Solo si caso en `pendiente_revision`, sino 409

---

## 6. CRITERIOS DE ACEPTACION (19 pruebas)

| # | Criterio | Codigo esperado |
|---|----------|-----------------|
| 01 | Login admin | 200 |
| 02 | POST /clients | 201 |
| 03 | POST /cases | 201 |
| 04 | Activar caso (borrador -> en_analisis) | 201 |
| 05 | Completar checklist | 200 |
| 06 | PUT /strategy con linea_principal | 200 |
| 07 | POST /facts (al menos 1 hecho) | 201 |
| 08 | Transicionar a pendiente_revision | 201 |
| 09 | GET /review historial vacio | 200 |
| 10 | GET /feedback sin revision vigente | 200 (null) |
| 11 | POST /review fuera de pendiente_revision | 409 |
| 12 | POST /review en pendiente_revision | 201 |
| 13 | GET /review con revision | 200 |
| 14 | GET /feedback con revision vigente | 200 |
| 15 | Segunda revision (version=2) | 201 |
| 16 | GET /review (estudiante) | 403 |
| 17 | GET /feedback (estudiante ajeno) | 403 |
| 18 | GET /review (caso inexistente) | 404 |
| 19 | GET /review sin token | 401 |

---

## 7. DIFF CONTRACTUAL

### Ubicacion
`docs/04_api/CONTRATO_API.md`, seccion 7 (lineas ~724-745)

### Bloque nuevo
```markdown
### 7. Revision del supervisor

#### `GET /api/v1/cases/{caseId}/review`
Retorna el historial completo de revisiones del caso.

**Acceso:** Solo Supervisor y Administrador.

#### `GET /api/v1/cases/{caseId}/review/feedback`
Retorna la vista filtrada de la revision vigente para el responsable del caso.
Retorna `null` si no existe revision vigente.

**Acceso:** Estudiante responsable del caso, Supervisor y Administrador.

#### `POST /api/v1/cases/{caseId}/review`
Registra una nueva revision del caso.

**Restricciones:**
- Solo Supervisor y Administrador
- Solo cuando el caso esta en estado `pendiente_revision`

**Comportamiento:**
- Incrementa `version_revision`
- Marca la nueva revision como `vigente: true`
- Marca revisiones anteriores como `vigente: false`

**Campos requeridos:**

| Campo | Tipo | Descripcion |
|-------|------|-------------|
| `resultado` | enum | `aprobado` o `devuelto` |
| `observaciones` | string | Observaciones del supervisor (max 3000) |
| `fecha_revision` | datetime | Opcional, default: ahora |

**Respuestas (todos los endpoints):**

| Codigo | Descripcion |
|--------|-------------|
| `200` | Historial, feedback o revision obtenida |
| `201` | Revision creada |
| `401` | No autenticado |
| `403` | Estudiante sin acceso o perfil insuficiente |
| `404` | Caso no encontrado |
| `409` | Caso no esta en estado `pendiente_revision` |
```

---

## 8. SECUENCIA DE EJECUCION

```bash
# Fase A: Aplicar diff y verificar contrato
sed -n '724,770p' docs/04_api/CONTRATO_API.md

# Fase B: Validacion runtime
chmod +x test_e5_15.sh
./test_e5_15.sh
npm run build
```

---

## 9. CRITERIO DE CIERRE

| Resultado | Accion |
|-----------|--------|
| Contrato alineado + 19 PASS + build verde | E5-15 cierra |
