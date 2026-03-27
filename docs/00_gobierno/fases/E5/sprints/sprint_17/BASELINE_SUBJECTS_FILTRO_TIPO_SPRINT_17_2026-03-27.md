# BASELINE `subjects` filtro por tipo — Sprint 17

**Fecha:** 2026-03-27  
**Proyecto:** LEX_PENAL  
**Fase:** E5 — Expansión funcional controlada  
**Sprint:** 17  
**Foco:** Hardening de `subjects` — filtro por tipo  
**Commit base:** `ddacc21`

---

## 1. Contexto

Sprint 16 cerró con paginación funcional en `GET /subjects`. El endpoint acepta
`page` y `per_page`, retorna estructura paginada, y no tiene filtros.

Sprint 17 extiende el endpoint para aceptar filtro por `tipo` sin alterar
la paginación ni la política append-only.

---

## 2. Estado pre-intervención

### 2.1 Endpoint

```
GET /api/v1/cases/{caseId}/subjects
Authorization: Bearer {token}
```

**Parámetros actuales:**

| Parámetro | Tipo | Default |
|-----------|------|---------|
| `page` | number | 1 |
| `per_page` | number | 20 |

**Sin filtro por `tipo`.**

---

## 3. Código baseline

### 3.1 `list-subjects-query.dto.ts`

```typescript
import { IsOptional, IsInt, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

export class ListSubjectsQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt({ message: 'page debe ser entero' })
  @Min(1, { message: 'page debe ser >= 1' })
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt({ message: 'per_page debe ser entero' })
  @Min(1, { message: 'per_page debe ser >= 1' })
  @Max(100, { message: 'per_page no puede exceder 100' })
  per_page?: number = 20;
}
```

**Observación:** No incluye campo `tipo`.

### 3.2 `subjects.controller.ts`

```typescript
import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { SubjectsService } from './subjects.service';
import { CreateSubjectDto, ListSubjectsQueryDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('cases/:caseId/subjects')
@UseGuards(JwtAuthGuard)
export class SubjectsController {
  constructor(private readonly service: SubjectsService) {}

  @Get()
  async findAll(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Query() query: ListSubjectsQueryDto,
  ) {
    const page = query.page ?? 1;
    const perPage = query.per_page ?? 20;
    return this.service.findAllByCaseId(caseId, page, perPage);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Body() dto: CreateSubjectDto,
    @Request() req: any,
  ) {
    return this.service.create(caseId, dto, req.user.sub);
  }

  @Get(':subjectId')
  async findOne(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Param('subjectId', ParseUUIDPipe) subjectId: string,
  ) {
    return this.service.findOne(caseId, subjectId);
  }
}
```

**Observación:** `findAll` no propaga `tipo` al service.

### 3.3 `subjects.service.ts`

```typescript
import { Injectable, NotFoundException } from '@nestjs/common';
import { SubjectsRepository } from './subjects.repository';
import { CreateSubjectDto } from './dto/create-subject.dto';

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  per_page: number;
}

@Injectable()
export class SubjectsService {
  constructor(private readonly repository: SubjectsRepository) {}

  async findAllByCaseId(
    caseId: string,
    page: number,
    perPage: number,
  ): Promise<PaginatedResponse<any>> {
    const caseExists = await this.repository.caseExists(caseId);
    if (!caseExists) {
      throw new NotFoundException('Caso no encontrado');
    }

    const { data, total } = await this.repository.findAllByCaseId(
      caseId,
      page,
      perPage,
    );

    return {
      data,
      total,
      page,
      per_page: perPage,
    };
  }

  async findOne(caseId: string, subjectId: string) {
    const caseExists = await this.repository.caseExists(caseId);
    if (!caseExists) {
      throw new NotFoundException('Caso no encontrado');
    }

    const subject = await this.repository.findById(subjectId);
    if (!subject || subject.caso_id !== caseId) {
      throw new NotFoundException('Sujeto no encontrado');
    }
    return subject;
  }

  async create(caseId: string, dto: CreateSubjectDto, userId: string) {
    const caseExists = await this.repository.caseExists(caseId);
    if (!caseExists) {
      throw new NotFoundException('Caso no encontrado');
    }
    return this.repository.create(caseId, dto, userId);
  }
}
```

**Observación:** `findAllByCaseId` recibe `caseId`, `page`, `perPage`. No recibe `tipo`.

### 3.4 `subjects.repository.ts`

```typescript
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { CreateSubjectDto } from './dto/create-subject.dto';

@Injectable()
export class SubjectsRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findAllByCaseId(
    caseId: string,
    page: number,
    perPage: number,
  ): Promise<{ data: any[]; total: number }> {
    const skip = (page - 1) * perPage;

    const [data, total] = await Promise.all([
      this.prisma.subject.findMany({
        where: { caso_id: caseId },
        orderBy: { creado_en: 'desc' },
        skip,
        take: perPage,
      }),
      this.prisma.subject.count({
        where: { caso_id: caseId },
      }),
    ]);

    return { data, total };
  }

  async findById(subjectId: string) {
    return this.prisma.subject.findUnique({
      where: { id: subjectId },
    });
  }

  async create(caseId: string, dto: CreateSubjectDto, userId: string) {
    return this.prisma.subject.create({
      data: {
        caso_id: caseId,
        tipo: dto.tipo,
        nombre: dto.nombre,
        identificacion: dto.identificacion,
        tipo_identificacion: dto.tipo_identificacion,
        contacto: dto.contacto,
        direccion: dto.direccion,
        notas: dto.notas,
        creado_por: userId,
      },
    });
  }

  async caseExists(caseId: string): Promise<boolean> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: caseId },
      select: { id: true },
    });
    return !!caso;
  }
}
```

**Observación:** `where` clause solo filtra por `caso_id`. No filtra por `tipo`.

---

## 4. Datos de prueba existentes

| ID | Tipo | Nombre | Sprint |
|----|------|--------|--------|
| `c1834348-6f95-42fa-b2f4-a143cff789f3` | victima | Juan Pérez García | S15 |
| `440c0ec4-5d05-4aed-90f2-2767759b3015` | testigo | María López Test S16 | S16 |

**Total:** 2 sujetos con tipos distintos (`victima`, `testigo`).  
**Suficiente para probar filtro.**

---

## 5. Tipos válidos (referencia contractual)

Según `create-subject.dto.ts` y `CONTRATO_API.md`:

```typescript
enum TipoSujeto {
  victima = 'victima',
  imputado = 'imputado',
  testigo = 'testigo',
  apoderado = 'apoderado',
  otro = 'otro',
}
```

---

## 6. Comportamiento actual verificado

```bash
GET /api/v1/cases/c9f0c313-1042-42f7-8371-faa89fd84f42/subjects
```

**Respuesta:**
```json
{
  "data": [
    { "id": "440c0ec4-...", "tipo": "testigo", "nombre": "María López Test S16" },
    { "id": "c1834348-...", "tipo": "victima", "nombre": "Juan Pérez García" }
  ],
  "total": 2,
  "page": 1,
  "per_page": 20
}
```

**Con `?tipo=victima`:** No implementado — el parámetro se ignora.

---

## 7. Cambios requeridos en S17

| Componente | Cambio |
|------------|--------|
| `ListSubjectsQueryDto` | Agregar campo `tipo` opcional con validación enum |
| `SubjectsController` | Propagar `query.tipo` al service |
| `SubjectsService` | Recibir `tipo` y propagarlo al repository |
| `SubjectsRepository` | Agregar `tipo` al `where` clause si está presente |
| `CONTRATO_API.md` | Documentar parámetro `tipo` en sección 6.1 |

---

## 8. Fuera de alcance (confirmado)

- Filtro por `nombre`
- Ordenamiento configurable
- Múltiples filtros combinados
- Cambios a POST o GET detalle

---

*Baseline generado: 2026-03-27*  
*Sprint 17 — Hardening `subjects` (filtro por tipo)*
