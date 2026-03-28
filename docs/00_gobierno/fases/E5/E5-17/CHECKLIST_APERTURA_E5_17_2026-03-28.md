# CHECKLIST APERTURA E5-17 — ALINEACION CONTRACTUAL Y VALIDACION DE CHECKLIST

**Fecha:** 2026-03-28
**Unidad:** E5-17
**Tipo:** Alineacion contractual + Validacion runtime

---

## 1. OBJETIVO

Completar el contrato API del modulo `checklist` y validar su comportamiento runtime.

---

## 2. NATURALEZA DEL HITO

**Fase A:** Alineacion contractual (estructura, DTO, bootstrap, tabla de codigos)
**Fase B:** Validacion runtime (12 pruebas)

---

## 3. ENDPOINTS A VALIDAR

| Endpoint | Metodo | Comportamiento |
|----------|--------|----------------|
| `/cases/:caseId/checklist` | GET | Retorna estructura jerarquica (bloques + items) |
| `/cases/:caseId/checklist` | PUT | Actualiza items, recalcula bloques |

---

## 4. PATRON JERARQUICO

| Caracteristica | Valor |
|----------------|-------|
| Tipo | Jerarquico fijo (bloques -> items) |
| Cardinalidad | **12 bloques + 12 items** por caso (estructura base) |
| Creacion | Bootstrap automatico al **activar caso** |
| Edicion | PUT con array de `{id, marcado}` |
| Eliminacion | No expuesta |
| Recalculo | `bloque.completado` se recalcula automaticamente |

---

## 4.1 BOOTSTRAP EN ACTIVACION

El checklist **no se auto-crea en GET**. Se crea mediante `bootstrapIfNeeded()` durante la transicion `borrador -> en_analisis`.

**Implicacion para testing:** El setup debe incluir activacion del caso antes de probar `GET /checklist`.

---

## 4.2 ESTRUCTURA BASE (createBaseStructure)

| Bloque | Codigo | Items |
|--------|--------|-------|
| Verificacion de hechos | B01 | B01_01, B01_02 |
| Analisis probatorio | B02 | B02_01, B02_02 |
| Estrategia defensiva | B03 | B03_01, B03_02 |

**Total:** 3 bloques criticos + 6 items

---

## 4.3 RECALCULO AUTOMATICO

Al hacer `PUT /checklist`, el sistema:
1. Actualiza cada item con `marcado: true/false`
2. Recalcula `bloque.completado` = true solo si **todos** sus items estan marcados

---

## 5. REGLAS DE ACCESO

| Endpoint | Estudiante responsable | Estudiante ajeno | Supervisor | Admin |
|----------|------------------------|------------------|------------|-------|
| GET | 200 | 403 | 200 | 200 |
| PUT | 200 | 403 | 200 | 200 |

---

## 6. CRITERIOS DE ACEPTACION (12 pruebas)

| # | Criterio | Codigo esperado |
|---|----------|-----------------|
| 01 | Login admin | 200 |
| 02 | POST /clients | 201 |
| 03 | POST /cases | 201 |
| 04 | Activar caso (bootstrap checklist) | 201 |
| 05 | GET /checklist (estructura con bloques) | 200 |
| 06 | PUT /checklist (marcar items) | 200 |
| 07 | GET /checklist (refleja cambios + completado) | 200 |
| 08 | PUT /checklist (item inexistente) | 400 |
| 09 | GET /checklist (caso inexistente) | 404 |
| 10 | GET /checklist sin token | 401 |
| 11 | GET /checklist (estudiante ajeno) | 403 |
| 12 | PUT /checklist (estudiante ajeno) | 403 |

---

## 7. DIFF CONTRACTUAL

### Ubicacion
`docs/04_api/CONTRATO_API.md`, seccion 5.7 (lineas ~512-516)

### Bloque actual (escueto)
```markdown
#### 5.7 Checklist de calidad

GET  /api/v1/cases/{caseId}/checklist
PUT  /api/v1/cases/{caseId}/checklist
```

### Bloque nuevo (completo)
```markdown
#### 5.7 Checklist de calidad

```
GET  /api/v1/cases/{caseId}/checklist
PUT  /api/v1/cases/{caseId}/checklist
```

Recurso **jerarquico**: estructura fija de bloques con items.

**Bootstrap:** El checklist se crea automaticamente al activar el caso (transicion `borrador -> en_analisis`). No se auto-crea en `GET`.

**Estructura de respuesta:**
```json
{
  "bloques": [
    {
      "id": "uuid",
      "codigo_bloque": "B01",
      "nombre_bloque": "Verificacion de hechos",
      "critico": true,
      "completado": false,
      "items": [
        {
          "id": "uuid",
          "codigo_item": "B01_01",
          "descripcion": "Hechos contrastados con denuncia",
          "marcado": false
        }
      ]
    }
  ]
}
```

**Formato PUT:**
```json
{
  "items": [
    { "id": "uuid-item", "marcado": true },
    { "id": "uuid-item", "marcado": false }
  ]
}
```

**Recalculo automatico:** Al actualizar items, `bloque.completado` se recalcula como `true` solo si todos sus items estan marcados.

**Respuestas:**

| Codigo | Descripcion |
|--------|-------------|
| `200` | Checklist obtenido o actualizado |
| `400` | Item inexistente en payload |
| `401` | No autenticado |
| `403` | Estudiante sin acceso al caso o item de otro caso |
| `404` | Caso no encontrado |
```

---

## 8. SECUENCIA DE EJECUCION

```bash
# Fase A: Aplicar diff y verificar contrato
sed -n '512,560p' docs/04_api/CONTRATO_API.md

# Fase B: Validacion runtime
chmod +x test_e5_17.sh
./test_e5_17.sh
npm run build
```

---

## 9. CRITERIO DE CIERRE

| Resultado | Accion |
|-----------|--------|
| Contrato alineado + 12 PASS + build verde | E5-17 cierra |
