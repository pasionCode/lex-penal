# Saneamiento documental — LexPenal

| Campo | Valor |
|---|---|
| Fecha | 2026-03-06 |
| Estado | Pendiente de ejecución |
| Objetivo | Eliminar duplicados, establecer ubicaciones canónicas y dejar `docs/` limpio antes de iniciar implementación |

---

## Política de saneamiento

Todo documento duplicado no canónico se moverá primero a histórico
(`Old/` o `archive/`) antes de su eliminación definitiva, salvo que
se confirme que es un artefacto vacío del bootstrap — en cuyo caso
puede eliminarse directamente.

El saneamiento tiene dos fases:
1. **Saneamiento físico** — mover o eliminar archivos duplicados.
2. **Saneamiento lógico** — actualizar todas las referencias cruzadas
   en documentos que apunten a rutas que cambiaron.

El saneamiento lógico es obligatorio después del físico. Un documento
que referencia una ruta eliminada es un documento roto.

---

## Duplicados identificados

### 1. ARQUITECTURA_BACKEND

| Ubicación | Estado |
|---|---|
| `docs/02_arquitectura/ARQUITECTURA_BACKEND.md` | Duplicado — archivar en `02_arquitectura/Old/` o eliminar tras validar que no tiene contenido propio |
| `docs/06_backend/ARQUITECTURA_BACKEND.md` | **Canónica** — conservar |

La arquitectura del backend vive en `06_backend/`. La carpeta
`02_arquitectura/` es de nivel superior y no debe tener documentos
que correspondan a una capa específica.

---

### 2. ARQUITECTURA_FRONTEND

| Ubicación | Estado |
|---|---|
| `docs/02_arquitectura/ARQUITECTURA_FRONTEND_v2.md` | Duplicado — archivar en `02_arquitectura/Old/` o eliminar tras validar que no tiene contenido propio |
| `docs/05_frontend/ARQUITECTURA_FRONTEND_v2.md` | **Canónica** — conservar |

Misma lógica: la arquitectura del frontend vive en `05_frontend/`.

---

### 3. CATALOGO_INFORMES

| Ubicación | Estado |
|---|---|
| `docs/01_producto/CATALOGO_INFORMES_v2.md` | Duplicado — mover a `docs/01_producto/Old/` |
| `docs/11_informes/CATALOGO_INFORMES.md` | **Canónica** — conservar |

El catálogo de informes es un documento técnico-funcional que vive
en `11_informes/`. La versión en `01_producto/` es un remanente de
una etapa anterior.

---

### 4. Carpeta `01_producto/Old/`

| Archivo | Acción |
|---|---|
| `ESTADOS_DEL_CASO.md` | Reemplazado por `ESTADOS_DEL_CASO_v3.md` — conservar en Old como histórico |
| `ROLES_Y_PERMISOS.md` | Reemplazado por `MATRIZ_ROLES_PERMISOS.md` — conservar en Old como histórico |

La carpeta `Old/` puede mantenerse como historial. No requiere acción.

---

### 5. CALIDAD_BASE vs PLAN_CALIDAD

| Ubicación | Estado |
|---|---|
| `docs/09_calidad/PLAN_CALIDAD.md` | Verificar contenido — puede ser un esqueleto vacío del bootstrap |
| `docs/09_calidad/CALIDAD_BASE.md` | **Canónica** — documento producido en esta sesión |

Si `PLAN_CALIDAD.md` es el esqueleto vacío del bootstrap, eliminar
o reemplazar con `CALIDAD_BASE.md`. Si tiene contenido propio,
revisar antes de decidir.

---

## Acciones de saneamiento — secuencia

**Fase 1 — Saneamiento físico**
```
1. Archivar docs/02_arquitectura/ARQUITECTURA_BACKEND.md → Old/
2. Archivar docs/02_arquitectura/ARQUITECTURA_FRONTEND_v2.md → Old/
3. Mover docs/01_producto/CATALOGO_INFORMES_v2.md → docs/01_producto/Old/
4. Verificar docs/09_calidad/PLAN_CALIDAD.md:
   - Si es artefacto vacío del bootstrap → eliminar directamente
   - Si tiene contenido propio → archivar en Old/
```

**Fase 2 — Saneamiento lógico** *(obligatorio después del físico)*
```
5. Actualizar MAPA_REPOSITORIO.md con ubicaciones canónicas definitivas
6. Verificar y corregir referencias cruzadas en:
   - MANUAL_OPERATIVO.md
   - ARQUITECTURA_BACKEND.md
   - ROADMAP.md
   - Cualquier otro documento que referencie rutas afectadas
7. Confirmar que ningún documento tiene enlaces a rutas eliminadas o archivadas
```

---

## Ubicaciones canónicas definitivas

| Documento | Ubicación canónica |
|---|---|
| Arquitectura backend | `docs/06_backend/ARQUITECTURA_BACKEND.md` |
| Arquitectura frontend | `docs/05_frontend/ARQUITECTURA_FRONTEND_v2.md` |
| Catálogo de informes | `docs/11_informes/CATALOGO_INFORMES.md` |
| Plan de calidad | `docs/09_calidad/CALIDAD_BASE.md` |
| Estados del caso | `docs/01_producto/ESTADOS_DEL_CASO_v3.md` |
| Roles y permisos | `docs/01_producto/MATRIZ_ROLES_PERMISOS.md` |
| Reglas de negocio | `docs/01_producto/REGLAS_NEGOCIO.md` |

---

## Referencias cruzadas a verificar tras el saneamiento

Los siguientes documentos contienen rutas que pueden apuntar a
ubicaciones que cambiarán:

| Documento | Referencia a verificar |
|---|---|
| `MANUAL_OPERATIVO.md` | `docs/09_calidad/CALIDAD_BASE.md` — confirmar nombre final |
| `ARQUITECTURA_BACKEND.md` | Referencias a `docs/03_datos/` y `docs/04_api/` — confirmar que apuntan a versiones actuales |
| `ROADMAP.md` | Referencias a entregables por hito — verificar nombres de archivo |
| `MAPA_REPOSITORIO.md` | Actualizar con estructura canónica completa |
