# NOTA DE CIERRE UNIDAD E7-04 — 2026-03-30

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E7
- Unidad: E7-04
- Fecha de cierre: 2026-03-30
- Estado: ✅ CERRADA

## 2. Objetivo
Corregir la deuda semántica del endpoint `GET /client-briefing` que auto-creaba el recurso sin validar el estado del caso.

## 3. Deuda corregida

### Antes (E6-03)
```
GET /client-briefing (si no existe)
├── checkCaseAccess() ✓
└── create() ← SIN VALIDAR ESTADO
```

### Después (E7-04)
```
GET /client-briefing (si no existe)
├── checkCaseAccess() ✓
├── checkWritePermission() ✓ ← VALIDACIÓN AGREGADA
└── create()
```

## 4. Cambios implementados

### 4.1 Service (`client-briefing.service.ts`)
```typescript
async findByCaseId(...): Promise<ExplicacionCliente> {
  await this.checkCaseAccess(casoId, userId, perfil);

  let briefing = await this.repository.findByCaseId(casoId);

  if (!briefing) {
    // E7-04: Validar estado antes de auto-crear
    await this.checkWritePermission(casoId);

    briefing = await this.repository.create({...});
  }

  return briefing;
}
```

### 4.2 Contrato (`CONTRATO_API.md`)
Actualizada sección "Comportamiento especial" de client-briefing para documentar:
- Auto-creación solo en estados permitidos (`en_analisis`, `devuelto`, `listo_para_cliente`)
- 409 Conflict si estado no permite y no existe
- 200 si ya existe (lectura permitida en cualquier estado)

## 5. Pruebas ejecutadas

| # | Prueba | Resultado |
|---|--------|-----------|
| 1 | GET estado no permitido + no existe | ✅ 409 |
| 1.1 | No auto-creó en estado no permitido | ✅ |
| 2 | GET estado no permitido + existe | ✅ 200 |
| 3 | GET estado permitido + no existe | ✅ 200 |
| 3.1 | Auto-creó en estado permitido | ✅ |
| 4 | GET estado permitido + existe | ✅ 200 |
| 5 | PUT estado permitido | ✅ 200 |
| 6 | PUT estado no permitido | ✅ 409 |

**Total: 8/8 PASS**

## 6. Matriz de comportamiento final

| Estado | GET (no existe) | GET (existe) | PUT |
|--------|-----------------|--------------|-----|
| BORRADOR | 409 | 200 | 409 |
| EN_ANALISIS | 200 (auto-crea) | 200 | 200 |
| PENDIENTE_REVISION | 409 | 200 | 409 |
| DEVUELTO | 200 (auto-crea) | 200 | 200 |
| APROBADO_SUPERVISOR | 409 | 200 | 409 |
| LISTO_PARA_CLIENTE | 200 (auto-crea) | 200 | 200 |
| CERRADO | 409 | 200 | 409 |

## 7. Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `src/modules/client-briefing/client-briefing.service.ts` | Agregar `checkWritePermission()` en `findByCaseId()` |
| `docs/04_api/CONTRATO_API.md` | Documentar comportamiento por estado |

## 8. Artefactos generados

| Archivo | Propósito |
|---------|-----------|
| `CHECKLIST_APERTURA_E7_04_2026-03-30.md` | Gobierno |
| `BASELINE_TECNICO_E7_04_2026-03-30.md` | Análisis de deuda |
| `scripts/test_e7-04.ts` | Validación runtime |

## 9. Conclusión

La asimetría GET/PUT en client-briefing queda eliminada. Ambas operaciones ahora respetan la misma política de estados definida en E6-03. El contrato observable refleja el comportamiento real.

## 10. Firma de cierre

**E7-04 cerrada formalmente el 2026-03-30.**

- 1 archivo de código modificado
- 1 archivo de contrato actualizado
- 8 pruebas runtime ejecutadas
- 0 fallos
- Deuda semántica saldada

