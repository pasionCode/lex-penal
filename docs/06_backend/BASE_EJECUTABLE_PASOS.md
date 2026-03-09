# BASE EJECUTABLE — Pasos para entorno local

## Estado actual del scaffold

| Componente | Estado |
|---|---|
| package.json | ✅ Creado |
| tsconfig.json | ✅ Creado |
| nest-cli.json | ✅ Creado |
| .env.example | ✅ Creado |
| Dependencias npm | ✅ Instaladas |
| Compilación TypeScript | ✅ Pasa sin errores |
| schema.prisma | ✅ 758 líneas, 18 modelos, 19 enums |
| CasoEstadoService | ✅ 718 líneas, implementación completa |
| prisma generate | ⚠️ Pendiente (requiere ejecutar en local) |
| prisma migrate | ⚠️ Pendiente (requiere PostgreSQL) |

---

## Pasos para ejecutar en tu entorno

### 1. Clonar/actualizar repositorio

```bash
# Si ya tienes el repo
cd lex-penal
git pull origin main

# Si es la primera vez
git clone https://github.com/pasionCode/lex-penal.git
cd lex-penal
```

### 2. Instalar dependencias

```bash
npm install
```

### 3. Configurar variables de entorno

```bash
# Copiar plantilla
cp .env.example .env

# Editar con tus valores reales
nano .env
```

Variables críticas a configurar:
- `DATABASE_URL`: conexión a tu PostgreSQL local
- `JWT_SECRET`: generar con `openssl rand -base64 64`
- `ANTHROPIC_API_KEY`: tu API key de Anthropic (para módulo IA)

### 4. Levantar PostgreSQL

**Opción A: Docker (recomendado)**

```bash
docker run -d \
  --name lexpenal-db \
  -e POSTGRES_USER=lexpenal \
  -e POSTGRES_PASSWORD=lexpenal_dev \
  -e POSTGRES_DB=lexpenal_dev \
  -p 5432:5432 \
  postgres:15
```

**Opción B: PostgreSQL local**

Asegurarse de tener una base de datos creada con los datos de `.env`.

### 5. Generar cliente Prisma

```bash
npx prisma generate
```

Este comando:
- Lee `prisma/schema.prisma`
- Genera el cliente tipado en `node_modules/@prisma/client`
- Debe ejecutarse cada vez que cambie el schema

### 6. Ejecutar migración inicial

```bash
npx prisma migrate dev --name init
```

Este comando:
- Crea las 18 tablas definidas en el schema
- Crea los 19 enums como tipos PostgreSQL
- Genera archivo de migración en `prisma/migrations/`

### 7. (Opcional) Agregar índice parcial

Después de la migración inicial, ejecutar en PostgreSQL:

```sql
CREATE UNIQUE INDEX revision_supervisor_vigente_unico
ON revision_supervisor (caso_id)
WHERE vigente = true;
```

O agregarlo al archivo de migración generado.

### 8. Verificar compilación

```bash
npm run build
```

### 9. Ejecutar en modo desarrollo

```bash
npm run start:dev
```

El servidor debería arrancar en `http://localhost:3001`.

### 10. Verificar endpoints

```bash
# Health check básico (cuando se implemente)
curl http://localhost:3001/api/v1/health

# O verificar que el servidor responda
curl http://localhost:3001
```

---

## Verificaciones post-setup

### Prisma Studio (opcional)

```bash
npx prisma studio
```

Abre interfaz web para explorar la base de datos.

### Ejecutar tests

```bash
npm test
```

---

## Problemas comunes

### Error "DATABASE_URL is not defined"

- Verificar que `.env` existe y tiene la variable configurada
- Verificar que NestJS está cargando ConfigModule

### Error "Can't reach database"

- Verificar que PostgreSQL está corriendo
- Verificar que el puerto 5432 está accesible
- Verificar credenciales en DATABASE_URL

### Error "Prisma client not generated"

```bash
npx prisma generate
```

### Error de migración

```bash
# Reset completo (borra datos)
npx prisma migrate reset --force

# O ver estado de migraciones
npx prisma migrate status
```

---

## Siguientes pasos después del setup

Una vez que el servidor arranque:

1. **Implementar primer vertical**: `auth` → `users` → `cases`
2. **Agregar endpoint de transición**: `POST /api/v1/cases/:id/transition`
3. **Conectar CasoEstadoService** a CasesController
4. **Implementar guardas de autenticación**

---

## Archivos modificados en esta sesión

| Archivo | Acción |
|---|---|
| `package.json` | Creado |
| `tsconfig.json` | Creado |
| `nest-cli.json` | Creado |
| `.env.example` | Creado |
| `prisma/schema.prisma` | Creado (758 líneas) |
| `src/modules/cases/caso-estado.service.ts` | Creado (718 líneas) |
| `src/modules/cases/caso-estado.constants.ts` | Creado (104 líneas) |
| `src/modules/cases/dto/transition-case.dto.ts` | Creado |
| `src/modules/cases/cases.module.ts` | Actualizado (agregado CasoEstadoService) |
| `src/types/enums.ts` | Actualizado (19 enums) |
| `src/common/filters/http-exception.filter.ts` | Implementado |
| `src/modules/ai/ai.service.ts` | Corregido import |
| `src/modules/conclusion/conclusion.controller.ts` | Corregido DTO |
| `src/modules/evidence/evidence.controller.ts` | Corregido DTO |
| `src/modules/risks/risks.controller.ts` | Corregido DTO |
| `src/infrastructure/database/prisma/transaction.helper.ts` | Corregido tipos |

---

## Control de cambios

**Fecha**: 2026-03-08  
**Responsable**: Claude  
**Documento**: BASE_EJECUTABLE_PASOS.md
