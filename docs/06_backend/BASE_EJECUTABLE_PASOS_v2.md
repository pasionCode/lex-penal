clea# BASE EJECUTABLE — Pasos para entorno local

## Nota sobre entorno de ejecución

El presente documento describe el levantamiento de la base ejecutable en el entorno actual de trabajo y validación local del proyecto.

A la fecha, las pruebas operativas se realizan principalmente sobre Windows/PowerShell en el portátil de administración. No obstante, el entorno objetivo de implementación final del proyecto será previsiblemente Linux.

En consecuencia:

- las instrucciones aquí contenidas deben entenderse como guía de validación local;
- los comandos o ajustes específicos de shell podrán diferir en el despliegue final;
- antes de pasar a entorno Linux deberá elaborarse una guía específica de despliegue o adaptación operativa para dicho sistema.

---

## Estado actual del scaffold

| Componente | Estado |
|---|---|
| package.json | ✅ Creado |
| tsconfig.json | ✅ Creado |
| nest-cli.json | ✅ Creado |
| .env.example | ✅ Creado |
| Dependencias npm | ⚠️ Pendiente de validación local si aún no se han instalado en este entorno |
| Compilación TypeScript | ⚠️ Pendiente de validación local si aún no se ha ejecutado `npm run build` |
| schema.prisma | ✅ Creado |
| CasoEstadoService | ✅ Diseñado e incorporado en estructura de código |
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

#### Opción Git Bash / shell tipo Unix

```bash
# Copiar plantilla
cp .env.example .env

# Editar con tus valores reales
nano .env
```

#### Opción PowerShell (Windows)

```powershell
Copy-Item .env.example .env
notepad .env
```

Variables críticas a configurar:
- `DATABASE_URL`: conexión a tu PostgreSQL local
- `JWT_SECRET`: generar con `openssl rand -base64 64` o equivalente seguro
- `ANTHROPIC_API_KEY`: tu API key de Anthropic (para módulo IA)

### 4. Levantar PostgreSQL

**Opción A: Docker (Git Bash / shell tipo Unix)**

```bash
docker run -d \
  --name lexpenal-db \
  -e POSTGRES_USER=lexpenal \
  -e POSTGRES_PASSWORD=lexpenal_dev \
  -e POSTGRES_DB=lexpenal_dev \
  -p 5432:5432 \
  postgres:15
```

**Opción A alternativa: Docker en una sola línea (PowerShell)**

```powershell
docker run -d --name lexpenal-db -e POSTGRES_USER=lexpenal -e POSTGRES_PASSWORD=lexpenal_dev -e POSTGRES_DB=lexpenal_dev -p 5432:5432 postgres:15
```

**Opción B: PostgreSQL local**

Asegurarse de tener una base de datos creada con los datos de `.env`.

### 5. Formatear y validar schema Prisma

```bash
npx prisma format
npx prisma validate
```

### 6. Generar cliente Prisma

```bash
npx prisma generate
```

Este comando:
- lee `prisma/schema.prisma`;
- genera el cliente tipado en `node_modules/@prisma/client`;
- debe ejecutarse cada vez que cambie el schema.

### 7. Ejecutar migración inicial

```bash
npx prisma migrate dev --name init
```

Este comando:
- crea las tablas definidas en el schema;
- crea los enums como tipos PostgreSQL;
- genera archivo de migración en `prisma/migrations/`.

### 8. (Opcional) Agregar índice parcial

Después de la migración inicial, ejecutar en PostgreSQL:

```sql
CREATE UNIQUE INDEX revision_supervisor_vigente_unico
ON revision_supervisor (caso_id)
WHERE vigente = true;
```

O agregarlo al archivo de migración generado.

### 9. Verificar compilación

```bash
npm run build
```

### 10. Ejecutar en modo desarrollo

```bash
npm run start:dev
```

El servidor debería arrancar en `http://localhost:3001`.

### 11. Verificar endpoints

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
- Verificar credenciales en `DATABASE_URL`

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
3. **Conectar CasoEstadoService** a `CasesController`
4. **Implementar guardas de autenticación**

---

## Archivos preparados o modificados para esta fase

| Archivo | Acción |
|---|---|
| `package.json` | Creado |
| `tsconfig.json` | Creado |
| `nest-cli.json` | Creado |
| `.env.example` | Creado |
| `prisma/schema.prisma` | Creado |
| `src/modules/cases/services/caso-estado.service.ts` | Creado |
| `src/modules/cases/caso-estado.constants.ts` | Creado |
| `src/modules/cases/dto/transition-case.dto.ts` | Creado |
| `src/modules/cases/cases.module.ts` | Actualizado (agregado `CasoEstadoService`) |
| `src/types/enums.ts` | Actualizado |
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
**Documento**: BASE_EJECUTABLE_PASOS_v2.md
