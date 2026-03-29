# CHECKLIST DE APERTURA E6-01 — AUDIT

**Fecha:** 2026-03-28  
**Unidad:** E6-01  
**Módulo:** audit  
**Tipo:** Implementación funcional

---

## 1. OBJETIVO

Implementar `GET /api/v1/cases/{caseId}/audit` como endpoint funcional del MVP.

---

## 2. BASELINE TÉCNICO

### 2.1 Infraestructura existente

| Componente | Estado | Ubicación |
|------------|--------|-----------|
| Tabla `eventos_auditoria` | ✅ Existe | Prisma schema |
| Enum `TipoEvento` | ✅ Existe | 7 valores |
| Inserciones activas | ✅ | `caso-estado.service.ts` |
| Controller scaffolding | ⚠️ | `throw new Error` |
| Service scaffolding | ⚠️ | Vacío |
| Repository scaffolding | ⚠️ | Vacío |
| DTO entrada | ✅ | `QueryAuditDto` |

### 2.2 Modelo de datos

```prisma
model EventoAuditoria {
  id             String             @id @default(uuid())
  caso_id        String?
  usuario_id     String
  tipo_evento    TipoEvento
  estado_origen  String?
  estado_destino String?
  resultado      ResultadoAuditoria
  motivo_rechazo String?
  metadata       Json?
  fecha_evento   DateTime           @default(now())
}

enum TipoEvento {
  transicion_estado
  informe_generado
  revision_supervisor
  login
  logout
  eliminacion_caso
  ia_query
}
```

### 2.3 Patrón de autenticación

```typescript
// JWT payload disponible en req.user
interface JwtPayload {
  sub: string;      // usuario_id
  email: string;
  perfil: string;   // estudiante | supervisor | administrador
}
```

---

## 3. DECISIÓN DE FUENTE DE DATOS

**Opción A confirmada:** Leer de tabla `eventos_auditoria` existente.

---

## 4. PLAN DE IMPLEMENTACIÓN

### 4.1 Repository (`audit.repository.ts`)

```typescript
async findByCaso(
  casoId: string,
  filtros: { tipo?: string; page?: number; per_page?: number }
): Promise<{ data: EventoAuditoria[]; total: number }>
```

### 4.2 Service (`audit.service.ts`)

```typescript
async findAll(
  casoId: string,
  userId: string,
  perfil: PerfilUsuario,
  query: QueryAuditDto
): Promise<PaginatedAuditResponse>
```

Lógica:
1. Verificar perfil ≠ estudiante → 403
2. Verificar caso existe → 404
3. Consultar repository con filtros
4. Retornar respuesta paginada

### 4.3 Controller (`audit.controller.ts`)

```typescript
@UseGuards(JwtAuthGuard)
@Get()
findAll(
  @Param('caseId') caseId: string,
  @Query() query: QueryAuditDto,
  @CurrentUser() user: JwtPayload
): Promise<PaginatedAuditResponse>
```

### 4.4 DTOs

**QueryAuditDto** (ya existe, ajustar validación):
- `tipo`: opcional, enum TipoEvento
- `page`: opcional, default 1
- `per_page`: opcional, default 20

**AuditEventDto** (nuevo):
```typescript
{
  id: string;
  tipo: string;
  descripcion: string;
  fecha: string;
  usuario: { id: string; nombre: string };
  estado_origen?: string;
  estado_destino?: string;
  resultado: string;
}
```

**PaginatedAuditResponse** (nuevo):
```typescript
{
  data: AuditEventDto[];
  total: number;
  page: number;
  per_page: number;
}
```

---

## 5. CONTROL DE ACCESO

| Perfil | Acceso | Código |
|--------|--------|--------|
| estudiante | ❌ | 403 |
| supervisor | ✅ | 200 |
| administrador | ✅ | 200 |

---

## 6. RESPUESTA ESPERADA

```json
{
  "data": [
    {
      "id": "uuid",
      "tipo": "transicion_estado",
      "descripcion": "Transición de estado",
      "fecha": "2026-03-28T20:00:00.000Z",
      "usuario": {
        "id": "uuid",
        "nombre": "Admin User"
      },
      "estado_origen": "borrador",
      "estado_destino": "en_analisis",
      "resultado": "exitoso"
    }
  ],
  "total": 1,
  "page": 1,
  "per_page": 20
}
```

---

## 7. CÓDIGOS DE RESPUESTA

| Código | Descripción |
|--------|-------------|
| 200 | Lista de eventos (puede estar vacía) |
| 400 | Filtro `tipo` inválido |
| 401 | Sin token |
| 403 | Perfil estudiante (acceso denegado) |
| 404 | Caso no encontrado |

---

## 8. CRITERIOS DE ACEPTACIÓN (13 pruebas)

| # | Criterio | Código |
|---|----------|--------|
| 01 | Login admin | 200 |
| 02 | Login supervisor | 200 |
| 03 | Login estudiante | 200 |
| 04 | Crear cliente y caso | 201 |
| 05 | GET /audit sin token | 401 |
| 06 | GET /audit admin | 200 |
| 07 | GET /audit supervisor | 200 |
| 08 | GET /audit estudiante | 403 |
| 09 | GET /audit caso inexistente | 404 |
| 10 | GET /audit?page=1&per_page=5 | 200 + shape |
| 11 | GET /audit?tipo=transicion_estado | 200 |
| 12 | GET /audit?tipo=invalido | 400 |
| 13 | Build verde | - |

---

## 9. ARCHIVOS A MODIFICAR

| Archivo | Acción |
|---------|--------|
| `src/modules/audit/audit.repository.ts` | Implementar consulta |
| `src/modules/audit/audit.service.ts` | Implementar lógica |
| `src/modules/audit/audit.controller.ts` | Implementar endpoint |
| `src/modules/audit/dto/query-audit.dto.ts` | Agregar validación |
| `src/modules/audit/dto/audit-response.dto.ts` | Crear (nuevo) |
| `docs/04_api/CONTRATO_API.md` | Restaurar sección 10 |

---

## 10. RIESGOS

| Riesgo | Mitigación |
|--------|------------|
| No hay eventos en BD | Crear caso + transición en prueba |
| Join con usuarios | Incluir relación en consulta Prisma |

---

## 11. SIGUIENTE PASO

Implementar en este orden:
1. DTOs de respuesta
2. Repository
3. Service
4. Controller
5. Script de pruebas
6. Contrato
