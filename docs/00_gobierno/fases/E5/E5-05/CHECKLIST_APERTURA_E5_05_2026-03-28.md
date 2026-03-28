# CHECKLIST DE APERTURA — UNIDAD E5-05

## 1. Identificación

| Campo | Valor |
|-------|-------|
| Proyecto | LEX_PENAL |
| Fase | E5 |
| Unidad | E5-05 |
| Tipo | Resolución de deuda técnica |
| Fecha apertura | 2026-03-28 |
| Deuda objetivo | D-05 |

---

## 2. Objetivo

Resolver D-05 (Bootstrap U008 inconsistente con guardas de checklist) agregando items al bootstrap de 12 bloques para que el ciclo `en_analisis → pendiente_revision` sea completable.

---

## 3. Contexto

### 3.1 Problema

El bootstrap U008 en `CasoEstadoService.generarEstructuraBase()` crea 12 bloques pero no crea items. La guarda de `en_analisis → pendiente_revision` verifica `checklistBloque.completado`, que no puede marcarse `true` sin items porque:

```typescript
// ChecklistRepository.updateBloqueCompletado()
const completado = items.length > 0 && items.every((i) => i.marcado);
```

### 3.2 Diagnóstico confirmado

| Componente | Estado |
|------------|--------|
| Productor (CasoEstadoService) | Roto — crea bloques sin items |
| Consumidor (ChecklistModule) | Funciona — recalcula bloques si hay items |

### 3.3 Decisión de arquitectura

La solución es extender el productor, no tocar el consumidor:
- Agregar `ITEMS_CHECKLIST_U008` en constantes
- Extender `generarEstructuraBase()` para crear items idempotentes

---

## 4. Alcance

### 4.1 Permitido

| Archivo | Cambio |
|---------|--------|
| `caso-estado.constants.ts` | Agregar `ITEMS_CHECKLIST_U008` |
| `caso-estado.service.ts` | Extender `generarEstructuraBase()` |
| Script de pruebas | `test_e5_05.sh` |

### 4.2 Prohibido

- ChecklistModule (ya funciona)
- Otros módulos
- Bootstrap viejo de 3 bloques

---

## 5. Diseño

### 5.1 Taxonomía mínima U008

1 item por bloque para destrabar guardas:

| Bloque | Item | Descripción |
|--------|------|-------------|
| B01 | B01_01 | Hechos y línea de tiempo verificados |
| B02 | B02_01 | Problema jurídico delimitado |
| B03 | B03_01 | Tipicidad analizada |
| B04 | B04_01 | Antijuridicidad analizada |
| B05 | B05_01 | Culpabilidad analizada |
| B06 | B06_01 | Matriz probatoria consolidada |
| B07 | B07_01 | Ruta procesal definida |
| B08 | B08_01 | Riesgos y estrategia documentados |
| B09 | B09_01 | Dosimetría y beneficios revisados |
| B10 | B10_01 | Salidas alternativas evaluadas |
| B11 | B11_01 | Explicación al cliente preparada |
| B12 | B12_01 | Conclusión operativa elaborada |

### 5.2 Idempotencia

El bootstrap debe soportar backfill:
1. Crear bloques si faltan
2. Cargar bloques existentes del caso
3. Por cada bloque, verificar si ya tiene items
4. Si no tiene, crear los items definidos

Esto permite corregir casos ya creados con el bootstrap roto.

---

## 6. Criterios de aceptación

| # | Criterio | Prueba |
|---|----------|--------|
| 1 | Bootstrap crea 12 bloques + 12 items | Prueba 05 |
| 2 | GET /checklist devuelve items | Visual en respuesta |
| 3 | PUT /checklist marca items y completa bloques | Prueba 08 |
| 4 | en_analisis → pendiente_revision pasa | Prueba 09 |
| 5 | Ciclo completo hasta aprobado_supervisor | Pruebas 10-17 |
| 6 | Persistencia de revisión operativa | Pruebas 11-12, 16 |

---

## 7. Entregables

| Artefacto | Ruta |
|-----------|------|
| Constantes | `src/modules/cases/constants/caso-estado.constants.ts` |
| Servicio | `src/modules/cases/services/caso-estado.service.ts` |
| Script pruebas | `test_e5_05.sh` |
| Nota cierre | `docs/00_gobierno/fases/E5/unidades/unidad_05/NOTA_CIERRE_E5_05_*.md` |

---

## 8. Riesgos

| Riesgo | Mitigación |
|--------|------------|
| Casos existentes con bloques sin items | Backfill idempotente por bloque |
| Duplicación de items en re-ejecución | Verificar `itemsExistentes === 0` antes de crear |

---

## 9. Secuencia de aplicación

```bash
# 1. Respaldar archivos actuales
cp src/modules/cases/constants/caso-estado.constants.ts src/modules/cases/constants/caso-estado.constants.ts.bak
cp src/modules/cases/services/caso-estado.service.ts src/modules/cases/services/caso-estado.service.ts.bak

# 2. Reemplazar con versiones E5-05

# 3. Compilar
npm run build

# 4. Reiniciar backend
npm run start:dev

# 5. Ejecutar pruebas
chmod +x test_e5_05.sh
./test_e5_05.sh
```

---

**Fecha:** 2026-03-28  
**Metodología:** MDS v2.3
