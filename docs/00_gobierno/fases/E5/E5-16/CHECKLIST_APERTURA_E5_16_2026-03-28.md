# CHECKLIST APERTURA E5-16 — VALIDACION RUNTIME Y CIERRE FUNCIONAL DE CONCLUSION

**Fecha:** 2026-03-28
**Unidad:** E5-16
**Tipo:** Validacion runtime + cierre funcional

---

## 1. OBJETIVO

Validar el comportamiento runtime del modulo `conclusion` y certificar su cierre funcional.

---

## 2. NATURALEZA DEL HITO

**Fase A:** Revision contractual minima (verificar alineacion existente)
**Fase B:** Validacion runtime (11 pruebas)

---

## 3. ENDPOINTS A VALIDAR

| Endpoint | Metodo | Comportamiento |
|----------|--------|----------------|
| `/cases/:caseId/conclusion` | GET | Retorna conclusion, auto-crea si no existe |
| `/cases/:caseId/conclusion` | PUT | Actualiza conclusion (upsert funcional) |

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

El modulo `conclusion` tiene comportamiento **upsert funcional**:

| Operacion | Estado previo | Resultado |
|-----------|---------------|-----------|
| GET | No existe | Crea registro vacio y retorna 200 |
| GET | Existe | Retorna 200 |
| PUT | No existe | Crea con datos enviados y retorna 200 |
| PUT | Existe | Actualiza y retorna 200 |

**Nota:** Nunca retorna 201; siempre 200 porque el recurso conceptualmente "existe" desde que existe el caso.

---

## 5. REGLAS DE ACCESO

| Endpoint | Estudiante responsable | Estudiante ajeno | Supervisor | Admin |
|----------|------------------------|------------------|------------|-------|
| GET | 200 | 403 | 200 | 200 |
| PUT | 200 | 403 | 200 | 200 |

---

## 6. CRITERIOS DE ACEPTACION (11 pruebas)

| # | Criterio | Codigo esperado |
|---|----------|-----------------|
| 01 | Login admin | 200 |
| 02 | POST /clients | 201 |
| 03 | POST /cases | 201 |
| 04 | Activar caso | 201 |
| 05 | GET /conclusion (auto-crea) | 200 |
| 06 | PUT /conclusion (actualiza) | 200 |
| 07 | GET /conclusion (refleja cambios) | 200 |
| 08 | GET /conclusion (caso inexistente) | 404 |
| 09 | GET /conclusion sin token | 401 |
| 10 | GET /conclusion (estudiante ajeno) | 403 |
| 11 | PUT /conclusion (estudiante ajeno) | 403 |

---

## 7. CONTRATO VIGENTE (verificacion)

Ubicacion: `docs/04_api/CONTRATO_API.md`, lineas ~523-531

Debe contener:
- [x] Singleton documentado
- [x] Auto-creacion en GET documentada
- [x] PUT actualiza documentado
- [x] Codigos 200, 400, 401, 403, 404

**Accion:** Solo verificar; no requiere diff salvo inconsistencia real.

---

## 8. SECUENCIA DE EJECUCION

```bash
# Fase A: Verificar contrato
sed -n '523,535p' docs/04_api/CONTRATO_API.md

# Fase B: Validacion runtime
chmod +x test_e5_16.sh
./test_e5_16.sh
npm run build
```

---

## 9. CRITERIO DE CIERRE

| Resultado | Accion |
|-----------|--------|
| Contrato verificado + 11 PASS + build verde | E5-16 cierra |
