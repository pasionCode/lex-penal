# BASELINE `subjects` — Sprint 15

**Fecha:** 2026-03-27  
**Proyecto:** LEX_PENAL  
**Fase:** E5 — Expansión funcional controlada  
**Sprint:** 15  
**Foco:** Expansión mínima vertical — `subjects`  
**Política:** B1 — Implementación nueva desde cero

---

## 1. Contexto

Sprint 15 abrió el subrecurso `subjects` (sujetos procesales) como expansión funcional nueva. Implementación completa desde cero: modelo, enums, migración, módulo NestJS, controller, service, repository y validaciones.

---

## 2. Estado pre-implementación

| Aspecto | Estado inicial |
|---------|----------------|
| Contrato | ❌ No existía |
| Modelo Prisma | ❌ No existía |
| Módulo NestJS | ❌ No existía |
| Endpoint HTTP | ❌ 404 Cannot GET |

---

## 3. Implementación

### Modelo de datos

```prisma
enum TipoSujeto {
  victima
  imputado
  testigo
  apoderado
  otro
}

enum TipoIdentificacion {
  CC
  TI
  CE
  PAS
  NIT
  otro
}

model Subject {
  id                   String              @id @default(uuid()) @db.Uuid
  caso_id              String              @db.Uuid
  tipo                 TipoSujeto
  nombre               String              @db.VarChar(120)
  identificacion       String?             @db.VarChar(40)
  tipo_identificacion  TipoIdentificacion?
  contacto             String?             @db.VarChar(120)
  direccion            String?             @db.VarChar(255)
  notas                String?
  creado_en            DateTime            @default(now())
  actualizado_en       DateTime            @updatedAt
  creado_por           String              @db.Uuid
  actualizado_por      String?             @db.Uuid

  caso         Caso     @relation(...)
  creador      Usuario  @relation("SubjectCreador", ...)
  actualizador Usuario? @relation("SubjectActualizador", ...)

  @@index([caso_id])
  @@map("subjects")
}
```

### Migración

- Archivo: `20260327015609_add_subjects`
- Estado: Aplicada exitosamente

### Artefactos creados

| Archivo | Descripción |
|---------|-------------|
| `src/modules/subjects/subjects.module.ts` | Módulo NestJS |
| `src/modules/subjects/subjects.controller.ts` | Controller con GET, POST, GET by ID |
| `src/modules/subjects/subjects.service.ts` | Service con lógica de negocio |
| `src/modules/subjects/subjects.repository.ts` | Repository con acceso a Prisma |
| `src/modules/subjects/dto/create-subject.dto.ts` | DTO con validaciones |
| `src/modules/subjects/dto/subject-response.dto.ts` | DTO de respuesta |
| `src/modules/subjects/dto/index.ts` | Barrel export |

### Endpoints implementados

| Método | Ruta | Estado |
|--------|------|--------|
| GET | `/cases/{caseId}/subjects` | ✅ Implementado |
| POST | `/cases/{caseId}/subjects` | ✅ Implementado |
| GET | `/cases/{caseId}/subjects/{subjectId}` | ✅ Implementado |
| PUT | — | ❌ No expuesto (política) |
| DELETE | — | ❌ No expuesto (política) |

---

## 4. Validaciones implementadas

### Campos requeridos

| Campo | Validación |
|-------|------------|
| `tipo` | Enum obligatorio: victima, imputado, testigo, apoderado, otro |
| `nombre` | String requerido, max 120, trim automático |

### Campos opcionales

| Campo | Validación |
|-------|------------|
| `identificacion` | String, max 40, trim |
| `tipo_identificacion` | Enum: CC, TI, CE, PAS, NIT, otro |
| `contacto` | String, max 120, trim |
| `direccion` | String, max 255, trim |
| `notas` | String, trim |

---

## 5. Validación post-implementación

| # | Prueba | Código | Mensaje | Estado |
|---|--------|--------|---------|--------|
| 1 | GET lista vacía | 200 | `[]` | ✅ |
| 2 | POST válido | 201 | Sujeto creado | ✅ |
| 3 | GET detalle | 200 | Retorna sujeto | ✅ |
| 4 | GET caseId inexistente | 404 | "Caso no encontrado" | ✅ |
| 5 | GET subjectId inexistente | 404 | "Sujeto no encontrado" | ✅ |
| 6 | POST nombre vacío | 400 | "nombre es requerido" | ✅ |
| 7 | POST tipo inválido | 400 | "tipo debe ser..." | ✅ |
| 8 | PUT | 404 | Cannot PUT | ✅ No expuesto |
| 9 | DELETE | 404 | Cannot DELETE | ✅ No expuesto |

**Build:** Verde  
**Runtime:** Verde

---

## 6. Sujetos creados en pruebas

| ID | Tipo | Nombre |
|----|------|--------|
| `c1834348-6f95-42fa-b2f4-a143cff789f3` | victima | Juan Pérez García |

---

## 7. Deuda técnica

### Menor (no bloquea)

- Enums duplicados entre DTO y Prisma (alineación futura)
- Sin validación de existencia de `creado_por` como usuario válido

### Fuera de alcance

- PUT y DELETE no implementados (decisión de política)
- Sin paginación en GET lista
- Sin filtros por tipo de sujeto

---

*Documento generado: 2026-03-27*  
*Sprint 15 — Expansión `subjects`*
