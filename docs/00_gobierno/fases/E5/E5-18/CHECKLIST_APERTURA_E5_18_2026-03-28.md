# CHECKLIST APERTURA E5-18 — STRATEGY: ALINEACION CONTRACTUAL Y VALIDACION RUNTIME DE SUBRECURSO SINGLETON

**Fecha:** 2026-03-28
**Unidad:** E5-18
**Tipo:** Alineacion contractual + Validacion runtime

---

## 1. OBJETIVO

Validar y cerrar el subrecurso `strategy` con evidencia de comportamiento runtime y contrato alineado.

---

## 2. NATURALEZA DEL HITO

**Fase A:** Alineacion contractual (singleton, auto-creacion, campos DTO, tabla de codigos)
**Fase B:** Validacion runtime (12 pruebas)

---

## 3. ENDPOINTS A VALIDAR

| Endpoint | Metodo | Comportamiento |
|----------|--------|----------------|
| `/cases/:caseId/strategy` | GET | Retorna estrategia, auto-crea si no existe |
| `/cases/:caseId/strategy` | PUT | Actualiza o crea estrategia (upsert funcional) |

---

## 4. PATRON SINGLETON

| Caracteristica | Valor |
|----------------|-------|
| Tipo | Singleton (exactamente 1 por caso) |
| Cardinalidad | 1:1 con caso |
| Creacion | Auto-creacion en GET si no existe |
| Edicion | PUT completo (todos campos opcionales) |
| Eliminacion | No expuesta |

---

## 4.1 COMPORTAMIENTO UPSERT

| Operacion | Estado previo | Resultado |
|-----------|---------------|-----------|
| GET | No existe | Crea registro vacio y retorna 200 |
| GET | Existe | Retorna 200 |
| PUT | No existe | Crea con datos enviados y retorna 200 |
| PUT | Existe | Actualiza y retorna 200 |

---

## 4.2 DEPENDENCIA FUNCIONAL CON TRANSICION

**Regla de negocio:** El campo `linea_principal` es obligatorio para la transicion `en_analisis -> pendiente_revision`.

Esta dependencia esta implementada en:
- `caso-estado.service.ts` → `verificarGuardaEnAnalisisAPendienteRevision()`
- No en el modulo `strategy` directamente

**Trazabilidad:** Esta regla debe quedar cruzada en la nota de cierre.

---

## 5. CAMPOS DEL DTO (UpdateStrategyDto)

| Campo | Tipo | MaxLength | Obligatorio |
|-------|------|-----------|-------------|
| `linea_principal` | string | 2000 | No* |
| `fundamento_juridico` | string | 3000 | No |
| `fundamento_probatorio` | string | 3000 | No |
| `linea_subsidiaria` | string | 2000 | No |
| `posicion_allanamiento` | string | 1000 | No |
| `posicion_preacuerdo` | string | 1000 | No |
| `posicion_juicio` | string | 1000 | No |

*Obligatorio para transicion a `pendiente_revision`

---

## 6. REGLAS DE ACCESO

| Endpoint | Estudiante responsable | Estudiante ajeno | Supervisor | Admin |
|----------|------------------------|------------------|------------|-------|
| GET | 200 | 403 | 200 | 200 |
| PUT | 200 | 403 | 200 | 200 |

---

## 7. CRITERIOS DE ACEPTACION (12 pruebas)

| # | Criterio | Codigo esperado |
|---|----------|-----------------|
| 01 | Login admin | 200 |
| 02 | POST /clients | 201 |
| 03 | POST /cases | 201 |
| 04 | Activar caso | 200/201 |
| 05 | GET /strategy (auto-crea) | 200 |
| 06 | PUT /strategy (actualiza) | 200 |
| 07 | GET /strategy (refleja cambios) | 200 |
| 08 | PUT /strategy (caso sin strategy previa) | 200 |
| 09 | GET /strategy (caso inexistente) | 404 |
| 10 | GET /strategy sin token | 401 |
| 11 | GET /strategy (estudiante ajeno) | 403 |
| 12 | PUT /strategy (estudiante ajeno) | 403 |

---

## 8. FUERA DE ALCANCE

- Cambio de modelo de datos
- Endpoint DELETE
- Multiplicidad por caso
- Rediseno de transicion de estados
- Cambios de naming o refactor cosmetico

---

## 9. DIFF CONTRACTUAL

### Ubicacion
`docs/04_api/CONTRATO_API.md`, seccion 5.5 (lineas ~481-482)

### Bloque actual (escueto)
```markdown
GET  /api/v1/cases/{caseId}/strategy
PUT  /api/v1/cases/{caseId}/strategy
```

### Bloque nuevo (completo)
```markdown
#### 5.5 Estrategia de defensa

```
GET  /api/v1/cases/{caseId}/strategy
PUT  /api/v1/cases/{caseId}/strategy
```

Recurso **singleton**: existe exactamente una estrategia por caso.

**Comportamiento especial:**
- Si `GET /strategy` se invoca y no existe, el sistema la crea automaticamente.
- `PUT /strategy` actualiza la estrategia existente o la crea si no existe.

**Campos:**

| Campo | Tipo | MaxLength | Descripcion |
|-------|------|-----------|-------------|
| `linea_principal` | string | 2000 | Linea defensiva principal |
| `fundamento_juridico` | string | 3000 | Fundamento juridico |
| `fundamento_probatorio` | string | 3000 | Fundamento probatorio |
| `linea_subsidiaria` | string | 2000 | Linea defensiva subsidiaria |
| `posicion_allanamiento` | string | 1000 | Posicion frente a allanamiento |
| `posicion_preacuerdo` | string | 1000 | Posicion frente a preacuerdo |
| `posicion_juicio` | string | 1000 | Posicion frente a juicio |

**Dependencia funcional:** `linea_principal` es obligatorio para la transicion `en_analisis -> pendiente_revision`.

**Respuestas:**

| Codigo | Descripcion |
|--------|-------------|
| `200` | Estrategia obtenida, auto-creada o actualizada |
| `400` | Payload invalido en `PUT` |
| `401` | No autenticado |
| `403` | Estudiante sin acceso al caso |
| `404` | Caso no encontrado |
```

---

## 10. SECUENCIA DE EJECUCION

```bash
# Fase A: Aplicar diff y verificar contrato
sed -n '481,485p' docs/04_api/CONTRATO_API.md

# Fase B: Validacion runtime
chmod +x test_e5_18.sh
./test_e5_18.sh
npm run build
```

---

## 11. CRITERIO DE CIERRE

| Resultado | Accion |
|-----------|--------|
| Contrato alineado + 12 PASS + build verde | E5-18 cierra |
