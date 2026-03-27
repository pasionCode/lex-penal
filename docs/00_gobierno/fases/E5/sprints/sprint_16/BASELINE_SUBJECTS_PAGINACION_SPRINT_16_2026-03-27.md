# BASELINE `subjects` paginación — Sprint 16

**Fecha:** 2026-03-27  
**Proyecto:** LEX_PENAL  
**Fase:** E5 — Expansión funcional controlada  
**Sprint:** 16  
**Foco:** Hardening de `subjects` — paginación  
**Commit base:** `b6f4db2`

---

## 1. Contexto

Sprint 15 implementó el subrecurso `subjects` con política append-only. El endpoint
`GET /cases/{caseId}/subjects` retornaba un array plano sin paginación, lo cual
no escala para casos con muchos sujetos procesales.

Sprint 16 interviene exclusivamente para agregar paginación contractual.

---

## 2. Estado pre-intervención

### 2.1 Endpoint

```
GET /api/v1/cases/{caseId}/subjects
Authorization: Bearer {token}
```

**Respuesta (S15):**
```json
[
  {
    "id": "uuid",
    "caso_id": "uuid",
    "tipo": "victima",
    "nombre": "string",
    ...
  }
]
```

**Problema identificado:** Array plano. Sin metadata de paginación. No escala.

### 2.2 Archivos baseline

| Archivo | Estado pre-S16 |
|---------|----------------|
| `subjects.controller.ts` | `findAll()` sin query params |
| `subjects.service.ts` | `findAllByCaseId(caseId)` retorna array |
| `subjects.repository.ts` | `findMany()` sin skip/take |
| `dto/index.ts` | Sin DTO de query |

### 2.3 Código baseline — Controller

```typescript
@Get()
async findAll(@Param('caseId', ParseUUIDPipe) caseId: string) {
  return this.service.findAllByCaseId(caseId);
}
```

### 2.4 Código baseline — Service

```typescript
async findAllByCaseId(caseId: string) {
  const caseExists = await this.repository.caseExists(caseId);
  if (!caseExists) {
    throw new NotFoundException('Caso no encontrado');
  }
  return this.repository.findAllByCaseId(caseId);
}
```

### 2.5 Código baseline — Repository

```typescript
async findAllByCaseId(caseId: string) {
  return this.prisma.subject.findMany({
    where: { caso_id: caseId },
    orderBy: { creado_en: 'desc' },
  });
}
```

---

## 3. Datos en base de datos

| ID | Tipo | Nombre | Creado |
|----|------|--------|--------|
| `c1834348-6f95-42fa-b2f4-a143cff789f3` | victima | Juan Pérez García | S15 |

Total de sujetos pre-S16: 1

---

## 4. Prueba de comportamiento pre-intervención

```bash
GET /api/v1/cases/c9f0c313-1042-42f7-8371-faa89fd84f42/subjects
```

**Respuesta verificada:**
```json
[{"id":"c1834348-6f95-42fa-b2f4-a143cff789f3","caso_id":"c9f0c313-1042-42f7-8371-faa89fd84f42","tipo":"victima","nombre":"Juan Pérez García",...}]
```

**Código:** 200  
**Formato:** Array plano  
**Paginación:** Ninguna

---

## 5. Convención de paginación del proyecto

Según `CONTRATO_API.md` (convenciones generales):

> **Paginación**: parámetros `page` y `per_page` en endpoints de listado.

Ejemplo de respuesta paginada estándar (sección 4, GET /cases):
```json
{
  "data": [...],
  "total": 42,
  "page": 1,
  "per_page": 20
}
```

El endpoint `subjects` no cumplía esta convención.

---

## 6. Diseño de intervención

### Cambios planificados

| Componente | Cambio |
|------------|--------|
| Controller | Recibir `@Query() query: ListSubjectsQueryDto` |
| Service | Recibir `page`, `perPage`, retornar `{ data, total, page, per_page }` |
| Repository | Agregar `skip`, `take`, ejecutar `count` en paralelo |
| DTO | Crear `ListSubjectsQueryDto` con validaciones |

### Validaciones de query params

| Parámetro | Default | Min | Max |
|-----------|---------|-----|-----|
| `page` | 1 | 1 | — |
| `per_page` | 20 | 1 | 100 |

### Breaking change

| Antes | Después |
|-------|---------|
| `[...]` | `{ data, total, page, per_page }` |

---

## 7. Fuera de alcance (confirmado)

- Filtros por `tipo` o `nombre`
- Ordenamiento configurable
- Alineación de enums DTO/Prisma
- Cambios a POST o GET detalle

---

*Baseline generado: 2026-03-27*  
*Sprint 16 — Hardening `subjects` (paginación)*
