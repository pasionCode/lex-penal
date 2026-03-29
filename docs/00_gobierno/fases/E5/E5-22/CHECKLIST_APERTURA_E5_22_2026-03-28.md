# CHECKLIST APERTURA E5-22 — BASIC-INFO: CORRECCIÓN CONTRACTUAL

**Fecha:** 2026-03-28
**Unidad:** E5-22
**Tipo:** Corrección contractual (sin código nuevo)

---

## 1. OBJETIVO

Alinear el contrato API con la implementación real: eliminar referencias al subrecurso `/basic-info` inexistente y documentar que la ficha básica se accede vía el agregado raíz `/cases/:id`.

---

## 2. NATURALEZA DEL HITO

**Tipo:** Corrección documental
**Código nuevo:** No
**Razón:** La brecha es contractual, no funcional

---

## 3. HALLAZGO

| Aspecto | Contrato | Runtime |
|---------|----------|---------|
| `GET /cases/:caseId/basic-info` | Documentado | **404** |
| `PUT /cases/:caseId/basic-info` | Documentado | **404** |

**Causa:** El subrecurso nunca fue implementado. La funcionalidad existe en el agregado raíz.

---

## 4. DECISIÓN

**Opción seleccionada:** B — Corregir contrato

| Opción descartada | Razón |
|-------------------|-------|
| A (implementar) | Sobreconstrucción, rompe disciplina MDS |
| C (alias) | Duplica semántica, introduce deuda innecesaria |

---

## 5. SUPERFICIE REAL

La ficha básica del caso vive en el agregado raíz:

| Operación | Ruta | Comportamiento |
|-----------|------|----------------|
| Consultar ficha | `GET /api/v1/cases/:id` | Retorna caso completo |
| Editar ficha | `PUT /api/v1/cases/:id` | Actualiza campos editables |

---

## 6. CAMPOS EDITABLES (UpdateCaseDto)

| Campo | Tipo | MaxLength | Descripción |
|-------|------|-----------|-------------|
| `despacho` | string | 200 | Despacho judicial |
| `etapa_procesal` | string | 100 | Etapa procesal actual |
| `regimen_procesal` | enum | - | `Ley 600` o `Ley 906` |
| `proxima_actuacion` | string | 200 | Descripción próxima actuación |
| `fecha_proxima_actuacion` | ISO date | - | Fecha próxima actuación |
| `responsable_proxima_actuacion` | string | 120 | Responsable |
| `observaciones` | string | 2000 | Observaciones generales |
| `agravantes` | string | 500 | Circunstancias agravantes |

---

## 7. DIFF CONTRACTUAL

### Ubicación
`docs/04_api/CONTRATO_API.md`, sección **5.1 Ficha básica**

Buscar por encabezado `#### 5.1 Ficha básica`, no por número de línea.

### Bloque actual (incorrecto)
```markdown
#### 5.1 Ficha básica

GET  /api/v1/cases/{caseId}/basic-info
PUT  /api/v1/cases/{caseId}/basic-info
```

### Acción
Eliminar sección 5.1 completa y agregar nota en sección de casos indicando que la ficha básica se accede vía `GET/PUT /cases/:id`.

### Bloque nuevo
Ver archivo `DIFF_BASIC_INFO_CONTRATO.md`

---

## 8. CRITERIOS DE ACEPTACIÓN (6 pruebas)

| # | Criterio | Código esperado |
|---|----------|-----------------|
| 01 | Login admin | 200 |
| 02 | GET /cases/:id (ficha básica) | 200 |
| 03 | PUT /cases/:id (actualiza campos) | 200 |
| 04 | GET /cases/:id (refleja cambios) | 200 |
| 05 | GET /cases/:id/basic-info (NO existe) | 404 |
| 06 | PUT /cases/:id/basic-info (NO existe) | 404 |

---

## 9. FUERA DE ALCANCE

- Implementar `/basic-info` como subrecurso
- Implementar alias
- Cambios de código productivo
- Migraciones de datos

---

## 10. SECUENCIA DE EJECUCIÓN

```bash
# Fase A: Validar runtime (confirmar hallazgo)
chmod +x test_e5_22.sh
./test_e5_22.sh

# Fase B: Aplicar diff contractual
# (eliminar sección 5.1, agregar nota en sección casos)

# Fase C: Build
npm run build
```

---

## 11. CRITERIO DE CIERRE

| Resultado | Acción |
|-----------|--------|
| Runtime confirma hallazgo + contrato corregido + build verde | E5-22 cierra |

---

## 12. TRAZABILIDAD

| Aspecto | Valor |
|---------|-------|
| Hallazgo | Subrecurso `/basic-info` no existe en runtime |
| Decisión | No implementar — inconsistencia documental |
| Resultado | Contrato alineado con implementación real |
