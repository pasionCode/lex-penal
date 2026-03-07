param([Parameter(Mandatory = $true)][string]$BasePath,[switch]$Force)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
function Ensure-Directory { param([string]$Path) if (-not (Test-Path -LiteralPath $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null } }
function Write-Utf8File { param([string]$Path,[string]$Content,[switch]$Overwrite) $parent = Split-Path -Parent $Path; if ($parent) { Ensure-Directory -Path $parent }; if ((Test-Path -LiteralPath $Path) -and (-not $Overwrite)) { Write-Host "[SKIP] $Path"; return }; $utf8Bom = New-Object System.Text.UTF8Encoding($true); [System.IO.File]::WriteAllText($Path, $Content, $utf8Bom); Write-Host "[OK]   $Path" }
$BasePath = [System.IO.Path]::GetFullPath([Environment]::ExpandEnvironmentVariables($BasePath))
Ensure-Directory -Path $BasePath
$dirs = @(
  'docs'
  'docs/00_gobierno'
  'docs/00_gobierno/adrs'
  'docs/01_producto'
  'docs/02_arquitectura'
  'docs/03_datos'
  'docs/04_api'
  'docs/05_frontend'
  'docs/06_backend'
  'docs/07_infraestructura'
  'docs/08_seguridad'
  'docs/09_calidad'
  'docs/10_gestion'
  'docs/11_informes'
  'docs/12_ia'
  'docs/13_operacion'
  'docs/14_legal_funcional'
  'infra'
  'infra/backups'
  'infra/docker'
  'infra/env'
  'infra/monitoring'
  'infra/nginx'
  'infra/postgres'
  'infra/postgres/init'
  'resources'
  'resources/catalogs'
  'resources/diagrams'
  'resources/fixtures'
  'resources/samples'
  'resources/templates'
  'scripts'
  'scripts/db'
  'scripts/deploy'
  'scripts/dev'
  'scripts/linux'
  'scripts/ops'
  'scripts/windows'
  'src'
  'src/backend'
  'src/backend/src'
  'src/backend/src/config'
  'src/backend/src/db'
  'src/backend/src/middlewares'
  'src/backend/src/modules'
  'src/backend/src/modules/ai_adapter'
  'src/backend/src/modules/audit'
  'src/backend/src/modules/auth'
  'src/backend/src/modules/cases'
  'src/backend/src/modules/checklist'
  'src/backend/src/modules/reports'
  'src/backend/src/modules/supervisor_review'
  'src/backend/src/routes'
  'src/frontend'
  'src/frontend/src'
  'src/frontend/src/app'
  'src/frontend/src/components'
  'src/frontend/src/features'
  'src/frontend/src/features/auth'
  'src/frontend/src/features/cases'
  'src/frontend/src/features/checklist'
  'src/frontend/src/features/reports'
  'src/frontend/src/guards'
  'src/frontend/src/layouts'
  'src/frontend/src/pages'
  'src/frontend/src/services'
  'src/frontend/src/services/api'
  'src/frontend/src/store'
  'src/shared'
  'src/shared/catalogs'
  'src/shared/constants'
  'src/shared/enums'
  'src/shared/rules'
  'tests'
  'tests/e2e'
  'tests/fixtures'
  'tests/integration'
  'tests/unit'
)
foreach ($dir in $dirs) { Ensure-Directory -Path (Join-Path $BasePath $dir) }
$files = @{}
$files['.editorconfig'] = @'
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 2
trim_trailing_whitespace = true

[*.ps1]
end_of_line = crlf

'@
$files['.gitignore'] = @'
node_modules/
dist/
coverage/
.env
.env.*
!.env.example
.DS_Store
Thumbs.db
npm-debug.log*
*.log
infra/backups/*.sql

'@
$files['README.md'] = @'
# LexPenal

Bootstrap ejecutable del sistema de gestion de casos de defensa penal colombiana, alineado con la Unidad 8 y con los principios de caso central, checklist vinculante, revision de supervisor e IA desacoplada.

## Stack base adoptado en este bootstrap
- Backend: Node.js 20 + Express + PostgreSQL
- Frontend: React + Vite
- Infraestructura base: Docker Compose + Nginx + PostgreSQL
- Scripts operativos: PowerShell y Bash
- Pruebas: smoke test, prueba unitaria de regla de checklist y prueba de salud

## Estructura principal
- `docs`: documentacion funcional, tecnica y operativa.
- `src`: codigo fuente.
- `infra`: despliegue e infraestructura.
- `scripts`: automatizaciones de soporte.
- `tests`: pruebas.
- `resources`: plantillas, muestras y diagramas.

## Puesta en marcha local
1. Copiar variables de entorno:
   - `Copy-Item .\src\backend\.env.example .\src\backend\.env`
   - `Copy-Item .\src\frontend\.env.example .\src\frontend\.env`

2. Instalar dependencias:
   - `cd src\backend && npm install`
   - `cd ..\frontend && npm install`

3. Inicializar base de datos:
   - Levantar PostgreSQL con Docker o una instancia local.
   - Ejecutar `npm run db:migrate` desde `src/backend`
   - Ejecutar `npm run db:seed` desde `src/backend`

4. Arrancar en desarrollo:
   - Backend: `npm run dev` desde `src/backend`
   - Frontend: `npm run dev` desde `src/frontend`

## Puesta en marcha con Docker
- `docker compose -f infra/docker/docker-compose.yml up --build`

## Credenciales demo
- correo: `admin@lexpenal.local`
- clave: `ChangeMe123!`

## Alcance de este bootstrap
Este bootstrap no pretende cerrar todo el producto. Deja una base ordenada y ejecutable para iniciar desarrollo real con estructura, rutas, servicios, scripts, configuracion y puntos de extension ya sembrados.

'@
$files['docs/01_producto/README.md'] = @'
# Producto
Carpeta reservada para vision funcional, backlog y casos de uso.

'@
$files['docs/02_arquitectura/README.md'] = @'
# Arquitectura
Carpeta reservada para arquitectura logica, tecnica y de despliegue.

'@
$files['docs/03_datos/README.md'] = @'
# Datos
Carpeta reservada para modelo de datos, diccionarios y catalogos.

'@
$files['docs/04_api/README.md'] = @'
# API
Carpeta reservada para contrato API y ejemplos de requests.

'@
$files['docs/05_frontend/README.md'] = @'
# Frontend
Carpeta reservada para pantallas, rutas y criterios de UX.

'@
$files['docs/06_backend/README.md'] = @'
# Backend
Carpeta reservada para modulos, reglas y servicios.

'@
$files['docs/07_infraestructura/README.md'] = @'
# Infraestructura
Carpeta reservada para despliegue, red y operacion.

'@
$files['docs/08_seguridad/README.md'] = @'
# Seguridad
Carpeta reservada para controles de acceso, logs y endurecimiento.

'@
$files['docs/09_calidad/README.md'] = @'
# Calidad
Carpeta reservada para estrategia de pruebas y criterios de aceptacion.

'@
$files['docs/10_gestion/README.md'] = @'
# Gestion
Carpeta reservada para roadmap, hitos y control de cambios.

'@
$files['docs/11_informes/README.md'] = @'
# Informes
Carpeta reservada para catalogo de salidas y plantillas.

'@
$files['docs/12_ia/README.md'] = @'
# IA
Carpeta reservada para proveedores, prompts y politicas del modulo desacoplado.

'@
$files['docs/13_operacion/README.md'] = @'
# Operacion
Carpeta reservada para runbooks de despliegue, backup y soporte.

'@
$files['docs/14_legal_funcional/README.md'] = @'
# Legal funcional
Carpeta reservada para alineacion normativa y metodologica con la Unidad 8.

'@
$files['docs/MAPA_REPOSITORIO.md'] = @'
# Mapa del repositorio

## Directorios
- `docs/00_gobierno`: decisiones, alcance y gobierno documental.
- `docs/01_producto`: producto, backlog y reglas funcionales.
- `docs/02_arquitectura`: arquitectura y componentes.
- `docs/03_datos`: datos y catálogos.
- `docs/04_api`: contrato API.
- `docs/05_frontend`: navegación, layout y pantallas.
- `docs/06_backend`: servicios y módulos.
- `docs/07_infraestructura`: despliegue y red.
- `docs/08_seguridad`: controles y endurecimiento.
- `docs/09_calidad`: pruebas y criterios.
- `docs/10_gestion`: roadmap y entregables.
- `docs/11_informes`: plantillas e informes.
- `docs/12_ia`: diseño del módulo IA.
- `docs/13_operacion`: runbooks y soporte.
- `docs/14_legal_funcional`: alineación con la Unidad 8.

## Regla de uso
La documentacion fija los invariantes. El codigo ejecutable implementa y prueba esa hipotesis.

'@
$files['infra/backups/README.md'] = @'
# Backups
Directorio de destino para respaldos de base de datos cuando se ejecuten los scripts de backup.

'@
$files['infra/docker/backend.Dockerfile'] = @'
FROM node:20-alpine
WORKDIR /app
COPY package.json package.json
RUN npm install
COPY . .
EXPOSE 8080
CMD ["npm", "run", "start"]

'@
$files['infra/docker/docker-compose.yml'] = @'
services:
  db:
    image: postgres:16-alpine
    container_name: lexpenal-db
    environment:
      POSTGRES_DB: lexpenal
      POSTGRES_USER: lexpenal
      POSTGRES_PASSWORD: lexpenal
    ports:
      - "5432:5432"
    volumes:
      - lexpenal_db_data:/var/lib/postgresql/data
      - ../postgres/init/001_schema.sql:/docker-entrypoint-initdb.d/001_schema.sql:ro

  api:
    build:
      context: ../../src/backend
      dockerfile: ../../infra/docker/backend.Dockerfile
    container_name: lexpenal-api
    environment:
      APP_NAME: LexPenal API
      NODE_ENV: development
      PORT: 8080
      CORS_ORIGIN: http://localhost:5173
      DB_HOST: db
      DB_PORT: 5432
      DB_NAME: lexpenal
      DB_USER: lexpenal
      DB_PASSWORD: lexpenal
      DEMO_ADMIN_EMAIL: admin@lexpenal.local
      DEMO_ADMIN_PASSWORD: ChangeMe123!
      DEMO_ADMIN_TOKEN: demo-admin-token
      AI_PROVIDER: stub
    depends_on:
      - db
    ports:
      - "8080:8080"

  web:
    build:
      context: ../../src/frontend
      dockerfile: ../../infra/docker/frontend.Dockerfile
    container_name: lexpenal-web
    environment:
      VITE_API_BASE_URL: http://localhost:8080/api/v1
    depends_on:
      - api
    ports:
      - "5173:5173"

  gateway:
    image: nginx:1.27-alpine
    container_name: lexpenal-gateway
    depends_on:
      - api
      - web
    ports:
      - "80:80"
    volumes:
      - ../nginx/default.conf:/etc/nginx/conf.d/default.conf:ro

volumes:
  lexpenal_db_data:

'@
$files['infra/docker/frontend.Dockerfile'] = @'
FROM node:20-alpine
WORKDIR /app
COPY package.json package.json
RUN npm install
COPY . .
EXPOSE 5173
CMD ["npm", "run", "dev"]

'@
$files['infra/env/README.md'] = @'
# Variables de entorno
Guardar aqui las variantes para despliegue y respaldar los ejemplos operativos.

'@
$files['infra/monitoring/README.md'] = @'
# Monitoring
Reservado para chequeos, logs y futura observabilidad.

'@
$files['infra/nginx/default.conf'] = @'
server {
  listen 80;
  server_name _;

  location /api/ {
    proxy_pass http://api:8080/api/;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }

  location / {
    proxy_pass http://web:5173/;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
  }
}

'@
$files['infra/postgres/init/001_schema.sql'] = @'
create extension if not exists pgcrypto;

create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  role text not null default 'admin',
  created_at timestamptz not null default now()
);

create table if not exists cases (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  title text not null,
  client_name text not null,
  status text not null default 'draft',
  risk_level text not null default 'medium',
  facts jsonb not null default '{}'::jsonb,
  checklist jsonb not null default '[]'::jsonb,
  supervisor_review jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists audit_logs (
  id uuid primary key default gen_random_uuid(),
  action text not null,
  entity_type text not null,
  entity_id uuid,
  actor text not null default 'system',
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_cases_status on cases(status);
create index if not exists idx_cases_risk_level on cases(risk_level);
create index if not exists idx_audit_logs_entity on audit_logs(entity_type, entity_id);

'@
$files['resources/catalogs/risk_levels.json'] = @'
[
  "low",
  "medium",
  "high",
  "critical"
]
'@
$files['resources/diagrams/README.md'] = @'
# Diagramas
Ubicar aqui:
- arquitectura general
- flujo del caso
- flujo del checklist vinculante
- flujo de informes

'@
$files['resources/fixtures/README.md'] = @'
# Fixtures
Reservado para datos semilla adicionales.

'@
$files['resources/samples/sample_case.json'] = @'
{
  "title": "Caso muestra",
  "client_name": "Cliente muestra",
  "risk_level": "medium",
  "facts": {
    "summary": "Caso de prueba para fixtures y smoke tests."
  }
}
'@
$files['resources/templates/case_template.json'] = @'
{
  "title": "",
  "client_name": "",
  "risk_level": "medium",
  "facts": {
    "summary": ""
  }
}
'@
$files['resources/templates/report_template.md'] = @'
# Informe operativo del caso {{code}}

## Identificacion
- Titulo: {{title}}
- Cliente: {{client_name}}
- Estado: {{status}}
- Riesgo: {{risk_level}}

## Hechos
{{facts.summary}}

## Checklist vinculante
{{checklist}}

## Revision de supervisor
{{supervisor_review}}

'@
$files['scripts/db/backup.ps1'] = @'
param([string]$File = ".\infra\backups\lexpenal_backup.sql")
docker exec -t lexpenal-db pg_dump -U lexpenal -d lexpenal > $File
Write-Host "Backup generado en $File"

'@
$files['scripts/db/restore.ps1'] = @'
param([Parameter(Mandatory = $true)][string]$File)
Get-Content $File | docker exec -i lexpenal-db psql -U lexpenal -d lexpenal
Write-Host "Restore ejecutado desde $File"

'@
$files['scripts/deploy/README.md'] = @'
# Deploy
Reservado para despliegues y rollback futuros.

'@
$files['scripts/dev/README.md'] = @'
# Desarrollo
Scripts auxiliares para arranque local.

'@
$files['scripts/linux/bootstrap-env.sh'] = @'
#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.}"
cp -n "$ROOT/src/backend/.env.example" "$ROOT/src/backend/.env" || true
cp -n "$ROOT/src/frontend/.env.example" "$ROOT/src/frontend/.env" || true
echo "Variables de entorno inicializadas."

'@
$files['scripts/linux/dev-up.sh'] = @'
#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.}"
"$ROOT/scripts/linux/bootstrap-env.sh" "$ROOT"
( cd "$ROOT/src/backend" && npm run dev ) &
( cd "$ROOT/src/frontend" && npm run dev ) &
wait

'@
$files['scripts/linux/docker-up.sh'] = @'
#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.}"
docker compose -f "$ROOT/infra/docker/docker-compose.yml" up --build

'@
$files['scripts/linux/install-deps.sh'] = @'
#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.}"
(cd "$ROOT/src/backend" && npm install)
(cd "$ROOT/src/frontend" && npm install)
echo "Dependencias instaladas."

'@
$files['scripts/linux/migrate.sh'] = @'
#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.}"
(cd "$ROOT/src/backend" && npm run db:migrate)

'@
$files['scripts/linux/seed.sh'] = @'
#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.}"
(cd "$ROOT/src/backend" && npm run db:seed)

'@
$files['scripts/linux/smoke.sh'] = @'
#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${1:-http://localhost:8080/api/v1}"
TOKEN=$(curl -s -X POST "$BASE_URL/auth/login" -H "Content-Type: application/json" -d '{"email":"admin@lexpenal.local","password":"ChangeMe123!"}' | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>console.log(JSON.parse(d).data.token));")
curl -s "$BASE_URL/health"
echo
curl -s -X POST "$BASE_URL/cases" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"title":"Caso smoke test","client_name":"Cliente smoke","risk_level":"medium","facts":{"summary":"Caso creado por smoke test."}}'
echo

'@
$files['scripts/ops/README.md'] = @'
# Ops
Reservado para operacion y mantenimiento.

'@
$files['scripts/windows/bootstrap-env.ps1'] = @'
param([string]$Root = ".")
$backendExample = Join-Path $Root "src\backend\.env.example"
$backendEnv = Join-Path $Root "src\backend\.env"
$frontendExample = Join-Path $Root "src\frontend\.env.example"
$frontendEnv = Join-Path $Root "src\frontend\.env"
if (-not (Test-Path $backendEnv)) { Copy-Item $backendExample $backendEnv }
if (-not (Test-Path $frontendEnv)) { Copy-Item $frontendExample $frontendEnv }
Write-Host "Variables de entorno inicializadas."

'@
$files['scripts/windows/dev-up.ps1'] = @'
param([string]$Root = ".")
& (Join-Path $Root "scripts\windows\bootstrap-env.ps1") -Root $Root
Start-Process powershell -ArgumentList "-NoExit", "-File", (Join-Path $Root "scripts\windows\start-backend.ps1"), "-Root", $Root
Start-Process powershell -ArgumentList "-NoExit", "-File", (Join-Path $Root "scripts\windows\start-frontend.ps1"), "-Root", $Root
Write-Host "Backend y frontend lanzados en ventanas separadas."

'@
$files['scripts/windows/docker-up.ps1'] = @'
param([string]$Root = ".")
docker compose -f (Join-Path $Root "infra\docker\docker-compose.yml") up --build

'@
$files['scripts/windows/install-deps.ps1'] = @'
param([string]$Root = ".")
Push-Location (Join-Path $Root "src\backend")
npm install
Pop-Location
Push-Location (Join-Path $Root "src\frontend")
npm install
Pop-Location
Write-Host "Dependencias instaladas."

'@
$files['scripts/windows/migrate.ps1'] = @'
param([string]$Root = ".")
Push-Location (Join-Path $Root "src\backend")
npm run db:migrate
Pop-Location

'@
$files['scripts/windows/seed.ps1'] = @'
param([string]$Root = ".")
Push-Location (Join-Path $Root "src\backend")
npm run db:seed
Pop-Location

'@
$files['scripts/windows/smoke.ps1'] = @'
param([string]$BaseUrl = "http://localhost:8080/api/v1")
$loginBody = @{ email = "admin@lexpenal.local"; password = "ChangeMe123!" } | ConvertTo-Json
$login = Invoke-RestMethod -Method Post -Uri "$BaseUrl/auth/login" -Body $loginBody -ContentType "application/json"
$token = $login.data.token
$health = Invoke-RestMethod -Method Get -Uri "$BaseUrl/health"
Write-Host "Health:" ($health | ConvertTo-Json -Depth 5)
$caseBody = @{ title = "Caso smoke test"; client_name = "Cliente smoke"; risk_level = "medium"; facts = @{ summary = "Caso creado por smoke test." } } | ConvertTo-Json -Depth 5
$case = Invoke-RestMethod -Method Post -Uri "$BaseUrl/cases" -Headers @{ Authorization = "Bearer $token" } -Body $caseBody -ContentType "application/json"
Write-Host "Case created:" ($case | ConvertTo-Json -Depth 5)

'@
$files['scripts/windows/start-backend.ps1'] = @'
param([string]$Root = ".")
Push-Location (Join-Path $Root "src\backend")
npm run dev
Pop-Location

'@
$files['scripts/windows/start-frontend.ps1'] = @'
param([string]$Root = ".")
Push-Location (Join-Path $Root "src\frontend")
npm run dev
Pop-Location

'@
$files['scripts/windows/tree.ps1'] = @'
param([string]$Root = ".")
Get-ChildItem -Path $Root -Recurse | Select-Object FullName

'@
$files['src/backend/.env.example'] = @'
APP_NAME=LexPenal API
NODE_ENV=development
PORT=8080
CORS_ORIGIN=http://localhost:5173
DB_HOST=localhost
DB_PORT=5432
DB_NAME=lexpenal
DB_USER=lexpenal
DB_PASSWORD=lexpenal
DEMO_ADMIN_EMAIL=admin@lexpenal.local
DEMO_ADMIN_PASSWORD=ChangeMe123!
DEMO_ADMIN_TOKEN=demo-admin-token
AI_PROVIDER=stub

'@
$files['src/backend/package.json'] = @'
{
  "name": "lexpenal-backend",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "node --watch src/index.js",
    "start": "node src/index.js",
    "db:migrate": "node src/db/migrate.js",
    "db:seed": "node src/db/seed.js"
  },
  "dependencies": {
    "cors": "^2.8.5",
    "dotenv": "^16.4.5",
    "express": "^4.19.2",
    "pg": "^8.12.0",
    "zod": "^3.23.8"
  }
}
'@
$files['src/backend/src/app.js'] = @'
import express from 'express';
import cors from 'cors';
import routes from './routes/index.js';
import { env } from './config/env.js';
import { requestIdMiddleware } from './middlewares/request-id.middleware.js';
import { notFoundMiddleware } from './middlewares/not-found.middleware.js';
import { errorMiddleware } from './middlewares/error.middleware.js';

export function createApp() {
  const app = express();
  app.use(cors({ origin: env.corsOrigin }));
  app.use(express.json());
  app.use(requestIdMiddleware);
  app.use(routes);
  app.use(notFoundMiddleware);
  app.use(errorMiddleware);
  return app;
}

'@
$files['src/backend/src/config/env.js'] = @'
import dotenv from 'dotenv';
import { resolve } from 'node:path';

dotenv.config({ path: resolve(process.cwd(), '.env') });

function parseNumber(value, fallback) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
}

export const env = {
  appName: process.env.APP_NAME || 'LexPenal API',
  nodeEnv: process.env.NODE_ENV || 'development',
  port: parseNumber(process.env.PORT, 8080),
  corsOrigin: process.env.CORS_ORIGIN || 'http://localhost:5173',
  db: {
    host: process.env.DB_HOST || 'localhost',
    port: parseNumber(process.env.DB_PORT, 5432),
    database: process.env.DB_NAME || 'lexpenal',
    user: process.env.DB_USER || 'lexpenal',
    password: process.env.DB_PASSWORD || 'lexpenal'
  },
  demoAdmin: {
    email: process.env.DEMO_ADMIN_EMAIL || 'admin@lexpenal.local',
    password: process.env.DEMO_ADMIN_PASSWORD || 'ChangeMe123!',
    token: process.env.DEMO_ADMIN_TOKEN || 'demo-admin-token'
  },
  aiProvider: process.env.AI_PROVIDER || 'stub'
};

'@
$files['src/backend/src/config/logger.js'] = @'
export const logger = {
  info(message, extra = {}) { console.log(JSON.stringify({ level: 'info', message, ...extra })); },
  warn(message, extra = {}) { console.warn(JSON.stringify({ level: 'warn', message, ...extra })); },
  error(message, extra = {}) { console.error(JSON.stringify({ level: 'error', message, ...extra })); }
};

'@
$files['src/backend/src/db/migrate.js'] = @'
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { pool } from './pool.js';
import { logger } from '../config/logger.js';

const schemaPath = resolve(process.cwd(), '../../infra/postgres/init/001_schema.sql');

try {
  const sql = await readFile(schemaPath, 'utf8');
  await pool.query(sql);
  logger.info('Migracion ejecutada', { schemaPath });
  process.exit(0);
} catch (error) {
  logger.error('Error ejecutando migracion', { message: error.message });
  process.exit(1);
} finally {
  await pool.end();
}

'@
$files['src/backend/src/db/pool.js'] = @'
import pg from 'pg';
import { env } from '../config/env.js';

const { Pool } = pg;

export const pool = new Pool({
  host: env.db.host,
  port: env.db.port,
  database: env.db.database,
  user: env.db.user,
  password: env.db.password
});

export async function healthcheckDb() {
  const result = await pool.query('select 1 as ok');
  return result.rows[0]?.ok === 1;
}

'@
$files['src/backend/src/db/seed.js'] = @'
import { pool } from './pool.js';
import { cloneDefaultChecklist } from '../../../shared/catalogs/checklist-blocks.js';
import { logger } from '../config/logger.js';

const sampleCase = {
  code: 'LP-DEMO-001',
  title: 'Caso demostracion de defensa penal',
  client_name: 'Cliente Demo',
  status: 'draft',
  risk_level: 'medium',
  facts: { summary: 'Caso semilla para validar flujo tecnico inicial.' },
  checklist: cloneDefaultChecklist(),
  supervisor_review: { required: true, approved: false, notes: 'Pendiente revision.' }
};

try {
  const existing = await pool.query('select id from cases where code = $1', [sampleCase.code]);
  if (existing.rowCount === 0) {
    await pool.query(
      `insert into cases (code, title, client_name, status, risk_level, facts, checklist, supervisor_review)
       values ($1,$2,$3,$4,$5,$6::jsonb,$7::jsonb,$8::jsonb)`,
      [
        sampleCase.code,
        sampleCase.title,
        sampleCase.client_name,
        sampleCase.status,
        sampleCase.risk_level,
        JSON.stringify(sampleCase.facts),
        JSON.stringify(sampleCase.checklist),
        JSON.stringify(sampleCase.supervisor_review)
      ]
    );
  }

  logger.info('Seed aplicada');
  process.exit(0);
} catch (error) {
  logger.error('Error aplicando seed', { message: error.message });
  process.exit(1);
} finally {
  await pool.end();
}

'@
$files['src/backend/src/index.js'] = @'
import { createApp } from './app.js';
import { env } from './config/env.js';
import { logger } from './config/logger.js';

const app = createApp();
app.listen(env.port, () => {
  logger.info('Backend iniciado', { port: env.port, environment: env.nodeEnv });
});

'@
$files['src/backend/src/middlewares/auth.middleware.js'] = @'
import { env } from '../config/env.js';

export function authMiddleware(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.replace('Bearer ', '').trim();

  if (!token || token !== env.demoAdmin.token) {
    return res.status(401).json({ ok: false, message: 'No autorizado' });
  }

  req.user = { email: env.demoAdmin.email, role: 'admin' };
  next();
}

'@
$files['src/backend/src/middlewares/error.middleware.js'] = @'
export function errorMiddleware(error, req, res, next) {
  console.error(error);
  res.status(error.statusCode || 500).json({
    ok: false,
    message: error.message || 'Error interno del servidor',
    requestId: req.requestId
  });
}

'@
$files['src/backend/src/middlewares/not-found.middleware.js'] = @'
export function notFoundMiddleware(req, res) {
  res.status(404).json({ ok: false, message: 'Ruta no encontrada' });
}

'@
$files['src/backend/src/middlewares/request-id.middleware.js'] = @'
import { randomUUID } from 'node:crypto';

export function requestIdMiddleware(req, res, next) {
  const requestId = req.headers['x-request-id'] || randomUUID();
  req.requestId = requestId;
  res.setHeader('x-request-id', requestId);
  next();
}

'@
$files['src/backend/src/modules/ai_adapter/ai.provider.js'] = @'
import { env } from '../../config/env.js';

export async function analyzeCase(caseRecord) {
  if (env.aiProvider === 'stub') {
    return {
      provider: 'stub',
      summary: 'Analisis IA no operativo. Proveedor stub activo.',
      recommendations: [
        'Completar checklist vinculante.',
        'Validar riesgos procesales.',
        'Revisar hipotesis de defensa.'
      ]
    };
  }

  return {
    provider: env.aiProvider,
    summary: 'Proveedor configurado pero no implementado en este bootstrap.',
    recommendations: []
  };
}

'@
$files['src/backend/src/modules/audit/audit.service.js'] = @'
import { pool } from '../../db/pool.js';

export async function writeAuditLog({ action, entityType, entityId, payload = {}, actor = 'system' }) {
  await pool.query(
    `insert into audit_logs (action, entity_type, entity_id, actor, payload)
     values ($1, $2, $3, $4, $5::jsonb)`,
    [action, entityType, entityId, actor, JSON.stringify(payload)]
  );
}

'@
$files['src/backend/src/modules/auth/auth.service.js'] = @'
import { z } from 'zod';
import { env } from '../../config/env.js';

const loginSchema = z.object({ email: z.string().email(), password: z.string().min(8) });

export function login(payload) {
  const data = loginSchema.parse(payload);
  if (data.email !== env.demoAdmin.email || data.password !== env.demoAdmin.password) {
    const error = new Error('Credenciales invalidas');
    error.statusCode = 401;
    throw error;
  }
  return { token: env.demoAdmin.token, user: { email: env.demoAdmin.email, role: 'admin' } };
}

'@
$files['src/backend/src/modules/cases/cases.repository.js'] = @'
import { pool } from '../../db/pool.js';

export async function listCases() {
  const result = await pool.query(
    `select id, code, title, client_name, status, risk_level, checklist, supervisor_review, created_at, updated_at
     from cases
     order by created_at desc`
  );
  return result.rows;
}

export async function getCaseById(id) {
  const result = await pool.query(
    `select id, code, title, client_name, status, risk_level, facts, checklist, supervisor_review, created_at, updated_at
     from cases
     where id = $1`,
    [id]
  );
  return result.rows[0] || null;
}

export async function createCase(caseRecord) {
  const result = await pool.query(
    `insert into cases
     (code, title, client_name, status, risk_level, facts, checklist, supervisor_review)
     values ($1,$2,$3,$4,$5,$6::jsonb,$7::jsonb,$8::jsonb)
     returning id, code, title, client_name, status, risk_level, facts, checklist, supervisor_review, created_at, updated_at`,
    [
      caseRecord.code,
      caseRecord.title,
      caseRecord.client_name,
      caseRecord.status,
      caseRecord.risk_level,
      JSON.stringify(caseRecord.facts || {}),
      JSON.stringify(caseRecord.checklist || []),
      JSON.stringify(caseRecord.supervisor_review || {})
    ]
  );
  return result.rows[0];
}

export async function updateCaseStatus(id, status) {
  const result = await pool.query(
    `update cases
     set status = $2, updated_at = now()
     where id = $1
     returning id, code, title, client_name, status, risk_level, facts, checklist, supervisor_review, created_at, updated_at`,
    [id, status]
  );
  return result.rows[0] || null;
}

export async function updateCaseChecklist(id, checklist) {
  const result = await pool.query(
    `update cases
     set checklist = $2::jsonb, updated_at = now()
     where id = $1
     returning id, code, title, client_name, status, risk_level, facts, checklist, supervisor_review, created_at, updated_at`,
    [id, JSON.stringify(checklist)]
  );
  return result.rows[0] || null;
}

'@
$files['src/backend/src/modules/cases/cases.service.js'] = @'
import { randomUUID } from 'node:crypto';
import { z } from 'zod';
import { CASE_STATUS, CASE_STATUS_VALUES } from '../../../../shared/enums/case-status.js';
import { buildDefaultChecklist, normalizeChecklist, validateChecklistForClosure } from '../checklist/checklist.service.js';
import { buildSupervisorReview } from '../supervisor_review/supervisor_review.service.js';
import { analyzeCase } from '../ai_adapter/ai.provider.js';
import { writeAuditLog } from '../audit/audit.service.js';
import * as repository from './cases.repository.js';

const createCaseSchema = z.object({
  title: z.string().min(5),
  client_name: z.string().min(3),
  risk_level: z.enum(['low', 'medium', 'high', 'critical']).default('medium'),
  facts: z.record(z.any()).optional()
});

const updateStatusSchema = z.object({ status: z.enum(CASE_STATUS_VALUES) });

const checklistSchema = z.array(
  z.object({
    key: z.string(),
    label: z.string(),
    required: z.boolean(),
    completed: z.boolean(),
    notes: z.string().optional().default('')
  })
);

function buildCaseCode() {
  const stamp = new Date().toISOString().replace(/[-:TZ.]/g, '').slice(0, 14);
  return `LP-${stamp}-${randomUUID().slice(0, 8).toUpperCase()}`;
}

export async function listAllCases() { return repository.listCases(); }

export async function getOneCase(id) {
  const found = await repository.getCaseById(id);
  if (!found) {
    const error = new Error('Caso no encontrado');
    error.statusCode = 404;
    throw error;
  }
  return found;
}

export async function createNewCase(payload, actor = 'admin@lexpenal.local') {
  const data = createCaseSchema.parse(payload);
  const checklist = buildDefaultChecklist();
  const draftCase = {
    code: buildCaseCode(),
    title: data.title,
    client_name: data.client_name,
    status: CASE_STATUS.DRAFT,
    risk_level: data.risk_level,
    facts: data.facts || {},
    checklist,
    supervisor_review: buildSupervisorReview({ risk_level: data.risk_level, status: CASE_STATUS.DRAFT })
  };

  const analysis = await analyzeCase(draftCase);
  draftCase.facts = { ...draftCase.facts, ai_bootstrap_summary: analysis.summary };

  const created = await repository.createCase(draftCase);
  await writeAuditLog({ action: 'case.created', entityType: 'case', entityId: created.id, actor, payload: { code: created.code } });
  return created;
}

export async function changeCaseStatus(id, payload, actor = 'admin@lexpenal.local') {
  const data = updateStatusSchema.parse(payload);
  const current = await getOneCase(id);

  if ([CASE_STATUS.APPROVED, CASE_STATUS.CLOSED].includes(data.status)) {
    const gate = validateChecklistForClosure(current.checklist);
    if (!gate.allowed) {
      const error = new Error(`No es posible cerrar o aprobar el caso. Faltan bloques: ${gate.missing.map((x) => x.label).join(', ')}`);
      error.statusCode = 400;
      throw error;
    }
  }

  const updated = await repository.updateCaseStatus(id, data.status);
  await writeAuditLog({ action: 'case.status.changed', entityType: 'case', entityId: id, actor, payload: { status: data.status } });
  return updated;
}

export async function updateChecklist(id, payload, actor = 'admin@lexpenal.local') {
  const current = await getOneCase(id);
  const data = checklistSchema.parse(payload);
  const normalizedChecklist = normalizeChecklist(data);
  const updated = await repository.updateCaseChecklist(current.id, normalizedChecklist);

  await writeAuditLog({
    action: 'case.checklist.updated',
    entityType: 'case',
    entityId: id,
    actor,
    payload: { completedBlocks: normalizedChecklist.filter((item) => item.completed).length }
  });

  return updated;
}

'@
$files['src/backend/src/modules/checklist/checklist.service.js'] = @'
import { cloneDefaultChecklist } from '../../../../shared/catalogs/checklist-blocks.js';
import { canAdvanceToClosure, getMissingRequiredChecklistBlocks } from '../../../../shared/rules/checklist-gate.js';

export function buildDefaultChecklist() { return cloneDefaultChecklist(); }

export function normalizeChecklist(checklist = []) {
  const defaults = cloneDefaultChecklist();
  const incomingMap = new Map((checklist || []).map((item) => [item.key, item]));
  return defaults.map((block) => ({ ...block, ...(incomingMap.get(block.key) || {}) }));
}

export function validateChecklistForClosure(checklist = []) {
  const normalized = normalizeChecklist(checklist);
  const missing = getMissingRequiredChecklistBlocks(normalized);
  return { allowed: canAdvanceToClosure(normalized), missing };
}

'@
$files['src/backend/src/modules/reports/reports.service.js'] = @'
import { getOneCase } from '../cases/cases.service.js';
import { getMissingRequiredChecklistBlocks } from '../../../../shared/rules/checklist-gate.js';

export async function buildCaseReport(id) {
  const caseRecord = await getOneCase(id);
  const missing = getMissingRequiredChecklistBlocks(caseRecord.checklist);

  const body = [
    `# Informe operativo del caso ${caseRecord.code}`,
    '',
    `## Identificacion`,
    `- Titulo: ${caseRecord.title}`,
    `- Cliente: ${caseRecord.client_name}`,
    `- Estado: ${caseRecord.status}`,
    `- Riesgo: ${caseRecord.risk_level}`,
    '',
    '## Resumen de hechos',
    `${caseRecord.facts?.summary || 'Sin resumen registrado.'}`,
    '',
    '## Checklist vinculante',
    ...caseRecord.checklist.map((block) => `- [${block.completed ? 'x' : ' '}] ${block.label}`),
    '',
    '## Control de calidad',
    missing.length === 0 ? '- Todos los bloques obligatorios aparecen completados.' : `- Pendientes: ${missing.map((block) => block.label).join(', ')}`,
    '',
    '## Revision de supervisor',
    `- Requerida: ${caseRecord.supervisor_review?.required ? 'Si' : 'No'}`,
    `- Aprobada: ${caseRecord.supervisor_review?.approved ? 'Si' : 'No'}`,
    `- Notas: ${caseRecord.supervisor_review?.notes || 'Sin notas.'}`
  ].join('\n');

  return { caseId: caseRecord.id, code: caseRecord.code, format: 'markdown', content: body };
}

'@
$files['src/backend/src/modules/supervisor_review/supervisor_review.service.js'] = @'
export function buildSupervisorReview(caseRecord) {
  const riskLevel = caseRecord.risk_level || 'medium';
  const required = ['high', 'critical'].includes(riskLevel) || caseRecord.status === 'ready_for_review';
  return {
    required,
    approved: false,
    notes: required ? 'Pendiente revision de supervisor.' : 'No requerida por riesgo actual.'
  };
}

'@
$files['src/backend/src/routes/auth.routes.js'] = @'
import { Router } from 'express';
import { login } from '../modules/auth/auth.service.js';

const router = Router();

router.post('/login', (req, res, next) => {
  try {
    const session = login(req.body);
    res.json({ ok: true, data: session });
  } catch (error) {
    next(error);
  }
});

export default router;

'@
$files['src/backend/src/routes/cases.routes.js'] = @'
import { Router } from 'express';
import { createNewCase, getOneCase, listAllCases, changeCaseStatus } from '../modules/cases/cases.service.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try { res.json({ ok: true, data: await listAllCases() }); } catch (error) { next(error); }
});

router.post('/', async (req, res, next) => {
  try { res.status(201).json({ ok: true, data: await createNewCase(req.body, req.user?.email) }); } catch (error) { next(error); }
});

router.get('/:id', async (req, res, next) => {
  try { res.json({ ok: true, data: await getOneCase(req.params.id) }); } catch (error) { next(error); }
});

router.patch('/:id/status', async (req, res, next) => {
  try { res.json({ ok: true, data: await changeCaseStatus(req.params.id, req.body, req.user?.email) }); } catch (error) { next(error); }
});

export default router;

'@
$files['src/backend/src/routes/checklist.routes.js'] = @'
import { Router } from 'express';
import { getOneCase, updateChecklist } from '../modules/cases/cases.service.js';

const router = Router();

router.get('/:id', async (req, res, next) => {
  try {
    const caseRecord = await getOneCase(req.params.id);
    res.json({ ok: true, data: caseRecord.checklist });
  } catch (error) {
    next(error);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const updated = await updateChecklist(req.params.id, req.body, req.user?.email);
    res.json({ ok: true, data: updated.checklist });
  } catch (error) {
    next(error);
  }
});

export default router;

'@
$files['src/backend/src/routes/health.routes.js'] = @'
import { Router } from 'express';
import { env } from '../config/env.js';
import { healthcheckDb } from '../db/pool.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const dbOk = await healthcheckDb();
    res.json({ ok: true, app: env.appName, environment: env.nodeEnv, database: dbOk ? 'up' : 'down' });
  } catch (error) {
    next(error);
  }
});

export default router;

'@
$files['src/backend/src/routes/index.js'] = @'
import { Router } from 'express';
import { API_PREFIX } from '../../../shared/constants/app.constants.js';
import { authMiddleware } from '../middlewares/auth.middleware.js';
import healthRoutes from './health.routes.js';
import authRoutes from './auth.routes.js';
import casesRoutes from './cases.routes.js';
import checklistRoutes from './checklist.routes.js';
import reportsRoutes from './reports.routes.js';

const router = Router();

router.use(`${API_PREFIX}/health`, healthRoutes);
router.use(`${API_PREFIX}/auth`, authRoutes);
router.use(`${API_PREFIX}/cases`, authMiddleware, casesRoutes);
router.use(`${API_PREFIX}/checklist`, authMiddleware, checklistRoutes);
router.use(`${API_PREFIX}/reports`, authMiddleware, reportsRoutes);

export default router;

'@
$files['src/backend/src/routes/reports.routes.js'] = @'
import { Router } from 'express';
import { buildCaseReport } from '../modules/reports/reports.service.js';

const router = Router();

router.get('/:id', async (req, res, next) => {
  try { res.json({ ok: true, data: await buildCaseReport(req.params.id) }); } catch (error) { next(error); }
});

export default router;

'@
$files['src/frontend/.env.example'] = @'
VITE_API_BASE_URL=http://localhost:8080/api/v1

'@
$files['src/frontend/index.html'] = @'
<!doctype html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>LexPenal</title>
    <script type="module" src="/src/main.jsx"></script>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>

'@
$files['src/frontend/package.json'] = @'
{
  "name": "lexpenal-frontend",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite --host 0.0.0.0 --port 5173",
    "build": "vite build",
    "preview": "vite preview --host 0.0.0.0 --port 4173"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.28.0"
  },
  "devDependencies": {
    "vite": "^5.4.10"
  }
}
'@
$files['src/frontend/src/app/router.jsx'] = @'
import React from 'react';
import { createBrowserRouter, Navigate } from 'react-router-dom';
import AppLayout from '../layouts/AppLayout.jsx';
import LoginPage from '../pages/LoginPage.jsx';
import DashboardPage from '../pages/DashboardPage.jsx';
import CasesPage from '../pages/CasesPage.jsx';
import ProtectedRoute from '../guards/ProtectedRoute.jsx';

export const router = createBrowserRouter([
  { path: '/login', element: <LoginPage /> },
  {
    path: '/',
    element: (<ProtectedRoute><AppLayout /></ProtectedRoute>),
    children: [
      { index: true, element: <Navigate to="/dashboard" replace /> },
      { path: 'dashboard', element: <DashboardPage /> },
      { path: 'cases', element: <CasesPage /> }
    ]
  }
]);

'@
$files['src/frontend/src/components/StatusBadge.jsx'] = @'
import React from 'react';

export default function StatusBadge({ value }) {
  return <span className={`badge badge-${value || 'draft'}`}>{value}</span>;
}

'@
$files['src/frontend/src/features/cases/CasesPanel.jsx'] = @'
import React, { useState } from 'react';
import StatusBadge from '../../components/StatusBadge.jsx';

export default function CasesPanel({ cases, selectedCaseId, onSelect, onCreate }) {
  const [form, setForm] = useState({ title: '', client_name: '', risk_level: 'medium' });

  async function handleSubmit(event) {
    event.preventDefault();
    if (!form.title || !form.client_name) return;
    await onCreate(form);
    setForm({ title: '', client_name: '', risk_level: 'medium' });
  }

  return (
    <div className="card">
      <h2>Casos</h2>
      <form onSubmit={handleSubmit} className="grid">
        <label>Titulo<input value={form.title} onChange={(e) => setForm((prev) => ({ ...prev, title: e.target.value }))} /></label>
        <label>Cliente<input value={form.client_name} onChange={(e) => setForm((prev) => ({ ...prev, client_name: e.target.value }))} /></label>
        <label>Riesgo<select value={form.risk_level} onChange={(e) => setForm((prev) => ({ ...prev, risk_level: e.target.value }))}>
          <option value="low">low</option>
          <option value="medium">medium</option>
          <option value="high">high</option>
          <option value="critical">critical</option>
        </select></label>
        <button type="submit">Crear caso</button>
      </form>
      <div className="list">
        {cases.map((item) => (
          <button key={item.id} className={`list-item ${selectedCaseId === item.id ? 'active' : ''}`} onClick={() => onSelect(item.id)}>
            <div><strong>{item.code}</strong><p>{item.title}</p><small>{item.client_name}</small></div>
            <StatusBadge value={item.status} />
          </button>
        ))}
      </div>
    </div>
  );
}

'@
$files['src/frontend/src/features/checklist/ChecklistPanel.jsx'] = @'
import React from 'react';

export default function ChecklistPanel({ checklist, onSave }) {
  function toggle(key) {
    const updated = checklist.map((block) => block.key === key ? { ...block, completed: !block.completed } : block);
    onSave(updated);
  }

  return (
    <div className="card">
      <h2>Checklist vinculante</h2>
      <div className="grid">
        {checklist.map((block) => (
          <label key={block.key} className="check-item">
            <input type="checkbox" checked={Boolean(block.completed)} onChange={() => toggle(block.key)} />
            <span>{block.label}</span>
          </label>
        ))}
      </div>
    </div>
  );
}

'@
$files['src/frontend/src/features/reports/ReportPanel.jsx'] = @'
import React from 'react';

export default function ReportPanel({ report }) {
  return (
    <div className="card">
      <h2>Informe</h2>
      <pre className="report-box">{report || 'Seleccione un caso para cargar el informe.'}</pre>
    </div>
  );
}

'@
$files['src/frontend/src/guards/ProtectedRoute.jsx'] = @'
import React from 'react';
import { Navigate } from 'react-router-dom';
import { getSession } from '../store/auth-store.js';

export default function ProtectedRoute({ children }) {
  const session = getSession();
  return session?.token ? children : <Navigate to="/login" replace />;
}

'@
$files['src/frontend/src/layouts/AppLayout.jsx'] = @'
import React from 'react';
import { Link, Outlet, useNavigate } from 'react-router-dom';
import { clearSession, getSession } from '../store/auth-store.js';

export default function AppLayout() {
  const navigate = useNavigate();
  const session = getSession();

  function handleLogout() {
    clearSession();
    navigate('/login');
  }

  return (
    <div className="shell">
      <aside className="sidebar">
        <h1>LexPenal</h1>
        <p className="muted">{session?.user?.email}</p>
        <nav>
          <Link to="/dashboard">Dashboard</Link>
          <Link to="/cases">Casos</Link>
        </nav>
        <button className="secondary" onClick={handleLogout}>Cerrar sesion</button>
      </aside>
      <main className="content"><Outlet /></main>
    </div>
  );
}

'@
$files['src/frontend/src/main.jsx'] = @'
import React from 'react';
import ReactDOM from 'react-dom/client';
import { RouterProvider } from 'react-router-dom';
import { router } from './app/router.jsx';
import './styles.css';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
);

'@
$files['src/frontend/src/pages/CasesPage.jsx'] = @'
import React, { useEffect, useMemo, useState } from 'react';
import CasesPanel from '../features/cases/CasesPanel.jsx';
import ChecklistPanel from '../features/checklist/ChecklistPanel.jsx';
import ReportPanel from '../features/reports/ReportPanel.jsx';
import { createCaseRequest, getCaseChecklistRequest, getCaseReportRequest, listCasesRequest, saveCaseChecklistRequest } from '../services/api/client.js';

export default function CasesPage() {
  const [cases, setCases] = useState([]);
  const [selectedCaseId, setSelectedCaseId] = useState('');
  const [checklist, setChecklist] = useState([]);
  const [report, setReport] = useState('');

  async function loadCases() {
    const data = await listCasesRequest();
    setCases(data);
    if (!selectedCaseId && data[0]) setSelectedCaseId(data[0].id);
  }

  useEffect(() => { loadCases().catch(console.error); }, []);

  useEffect(() => {
    async function loadCaseArtifacts() {
      if (!selectedCaseId) return;
      setChecklist(await getCaseChecklistRequest(selectedCaseId));
      const reportData = await getCaseReportRequest(selectedCaseId);
      setReport(reportData.content);
    }
    loadCaseArtifacts().catch(console.error);
  }, [selectedCaseId]);

  async function handleCreate(payload) {
    await createCaseRequest(payload);
    await loadCases();
  }

  async function handleSaveChecklist(updatedChecklist) {
    setChecklist(updatedChecklist);
    await saveCaseChecklistRequest(selectedCaseId, updatedChecklist);
    const reportData = await getCaseReportRequest(selectedCaseId);
    setReport(reportData.content);
  }

  const selectedCase = useMemo(() => cases.find((item) => item.id === selectedCaseId), [cases, selectedCaseId]);

  return (
    <section className="grid cases-grid">
      <CasesPanel cases={cases} selectedCaseId={selectedCaseId} onSelect={setSelectedCaseId} onCreate={handleCreate} />
      <div className="grid">
        <div className="card"><h2>Detalle</h2><pre>{JSON.stringify(selectedCase, null, 2)}</pre></div>
        <ChecklistPanel checklist={checklist} onSave={handleSaveChecklist} />
        <ReportPanel report={report} />
      </div>
    </section>
  );
}

'@
$files['src/frontend/src/pages/DashboardPage.jsx'] = @'
import React, { useEffect, useState } from 'react';
import { getHealth, listCasesRequest } from '../services/api/client.js';

export default function DashboardPage() {
  const [health, setHealth] = useState(null);
  const [count, setCount] = useState(0);

  useEffect(() => {
    async function load() {
      setHealth(await getHealth());
      setCount((await listCasesRequest()).length);
    }
    load().catch(console.error);
  }, []);

  return (
    <section className="grid two-columns">
      <div className="card">
        <h2>Estado del backend</h2>
        <p className="muted">Verificacion basica de servicio y base de datos.</p>
        <pre>{JSON.stringify(health, null, 2)}</pre>
      </div>
      <div className="card">
        <h2>Resumen rapido</h2>
        <p>Total de casos visibles: <strong>{count}</strong></p>
        <p>Checklist vinculante: activo por reglas del backend.</p>
        <p>Proveedor IA: stub desacoplado para futuras integraciones.</p>
      </div>
    </section>
  );
}

'@
$files['src/frontend/src/pages/LoginPage.jsx'] = @'
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { loginRequest } from '../services/api/client.js';
import { saveSession } from '../store/auth-store.js';

export default function LoginPage() {
  const navigate = useNavigate();
  const [form, setForm] = useState({ email: 'admin@lexpenal.local', password: 'ChangeMe123!' });
  const [error, setError] = useState('');

  async function handleSubmit(event) {
    event.preventDefault();
    setError('');
    try {
      const result = await loginRequest(form);
      saveSession(result);
      navigate('/dashboard');
    } catch (err) {
      setError(err.message || 'No fue posible iniciar sesion');
    }
  }

  return (
    <div className="centered-card">
      <div className="card">
        <h1>Ingreso LexPenal</h1>
        <p className="muted">Bootstrap funcional del sistema.</p>
        <form onSubmit={handleSubmit} className="grid">
          <label>Correo<input value={form.email} onChange={(e) => setForm((prev) => ({ ...prev, email: e.target.value }))} /></label>
          <label>Clave<input type="password" value={form.password} onChange={(e) => setForm((prev) => ({ ...prev, password: e.target.value }))} /></label>
          {error ? <div className="error-box">{error}</div> : null}
          <button type="submit">Ingresar</button>
        </form>
      </div>
    </div>
  );
}

'@
$files['src/frontend/src/services/api/client.js'] = @'
import { getSession } from '../../store/auth-store.js';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api/v1';

async function request(path, options = {}) {
  const session = getSession();
  const headers = { 'Content-Type': 'application/json', ...(options.headers || {}) };
  if (session?.token) headers.Authorization = `Bearer ${session.token}`;

  const response = await fetch(`${API_BASE_URL}${path}`, { ...options, headers });
  const data = await response.json();
  if (!response.ok) throw new Error(data.message || 'Error en la solicitud');
  return data.data ?? data;
}

export const loginRequest = (payload) => request('/auth/login', { method: 'POST', body: JSON.stringify(payload) });
export const getHealth = () => request('/health');
export const listCasesRequest = () => request('/cases');
export const createCaseRequest = (payload) => request('/cases', { method: 'POST', body: JSON.stringify(payload) });
export const getCaseChecklistRequest = (caseId) => request(`/checklist/${caseId}`);
export const saveCaseChecklistRequest = (caseId, payload) => request(`/checklist/${caseId}`, { method: 'PUT', body: JSON.stringify(payload) });
export const getCaseReportRequest = (caseId) => request(`/reports/${caseId}`);

'@
$files['src/frontend/src/store/auth-store.js'] = @'
const KEY = 'lexpenal_session';

export function saveSession(session) { localStorage.setItem(KEY, JSON.stringify(session)); }
export function getSession() { const raw = localStorage.getItem(KEY); return raw ? JSON.parse(raw) : null; }
export function clearSession() { localStorage.removeItem(KEY); }

'@
$files['src/frontend/src/styles.css'] = @'
* { box-sizing: border-box; }
body { margin: 0; font-family: Arial, Helvetica, sans-serif; background: #f4f6f8; color: #1d2733; }
button, input, select, textarea { font: inherit; }
button { cursor: pointer; border: 0; border-radius: 10px; padding: 0.75rem 1rem; background: #143b6f; color: white; }
button.secondary { background: #5f6d7e; }
a { color: inherit; text-decoration: none; }
pre { white-space: pre-wrap; word-break: break-word; }
.shell { display: grid; grid-template-columns: 280px 1fr; min-height: 100vh; }
.sidebar { background: #102a43; color: white; padding: 1.5rem; display: grid; gap: 1rem; align-content: start; }
.sidebar nav { display: grid; gap: 0.5rem; }
.sidebar nav a { padding: 0.75rem 1rem; border-radius: 10px; background: rgba(255, 255, 255, 0.08); }
.content { padding: 1.5rem; }
.card { background: white; border-radius: 18px; padding: 1.25rem; box-shadow: 0 6px 18px rgba(16, 42, 67, 0.08); }
.centered-card { min-height: 100vh; display: grid; place-items: center; padding: 1.5rem; }
.grid { display: grid; gap: 1rem; }
.two-columns { grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); }
.cases-grid { grid-template-columns: minmax(360px, 460px) 1fr; align-items: start; }
.list { display: grid; gap: 0.75rem; margin-top: 1rem; }
.list-item { width: 100%; display: flex; justify-content: space-between; align-items: start; text-align: left; background: #f7f9fc; color: #1d2733; }
.list-item.active { outline: 2px solid #143b6f; }
.badge { display: inline-block; border-radius: 999px; padding: 0.35rem 0.75rem; background: #d9e2ec; font-size: 0.85rem; }
.badge-closed, .badge-approved { background: #d4f4dd; }
.badge-draft { background: #f3e8ff; }
.badge-ready_for_review { background: #fff3cd; }
.muted { color: #6b7280; }
.error-box { background: #fee2e2; color: #991b1b; padding: 0.75rem; border-radius: 10px; }
.check-item { display: flex; gap: 0.75rem; align-items: center; background: #f7f9fc; padding: 0.75rem 1rem; border-radius: 12px; }
.report-box { background: #0b1020; color: #f8fafc; padding: 1rem; border-radius: 12px; }

'@
$files['src/frontend/vite.config.js'] = @'
import { defineConfig } from 'vite';

export default defineConfig({
  server: { port: 5173 }
});

'@
$files['src/shared/catalogs/checklist-blocks.js'] = @'
export const DEFAULT_CHECKLIST_BLOCKS = [
  { key: 'ficha', label: 'Ficha del caso', required: true, completed: false, notes: '' },
  { key: 'hechos', label: 'Hechos juridicamente relevantes', required: true, completed: false, notes: '' },
  { key: 'pruebas', label: 'Inventario y valoracion preliminar de pruebas', required: true, completed: false, notes: '' },
  { key: 'calificacion', label: 'Calificacion juridica provisional', required: true, completed: false, notes: '' },
  { key: 'estrategia', label: 'Hipotesis y estrategia de defensa', required: true, completed: false, notes: '' },
  { key: 'riesgos', label: 'Riesgos y contingencias', required: true, completed: false, notes: '' },
  { key: 'informe', label: 'Informe final revisado', required: true, completed: false, notes: '' }
];

export function cloneDefaultChecklist() {
  return DEFAULT_CHECKLIST_BLOCKS.map((block) => ({ ...block }));
}

'@
$files['src/shared/constants/app.constants.js'] = @'
export const APP_NAME = 'LexPenal';
export const API_PREFIX = '/api/v1';

'@
$files['src/shared/enums/case-status.js'] = @'
export const CASE_STATUS = Object.freeze({
  DRAFT: 'draft',
  IN_ANALYSIS: 'in_analysis',
  READY_FOR_REVIEW: 'ready_for_review',
  APPROVED: 'approved',
  CLOSED: 'closed'
});

export const CASE_STATUS_VALUES = Object.values(CASE_STATUS);

'@
$files['src/shared/rules/checklist-gate.js'] = @'
export function getMissingRequiredChecklistBlocks(checklist = []) {
  return checklist.filter((block) => block.required && !block.completed);
}

export function canAdvanceToClosure(checklist = []) {
  return getMissingRequiredChecklistBlocks(checklist).length === 0;
}

'@
$files['tests/e2e/README.md'] = @'
# E2E
Pruebas de humo para validar login, health y creacion de caso.

'@
$files['tests/e2e/smoke.ps1'] = @'
param([string]$BaseUrl = "http://localhost:8080/api/v1")
$loginBody = @{ email = "admin@lexpenal.local"; password = "ChangeMe123!" } | ConvertTo-Json
$login = Invoke-RestMethod -Method Post -Uri "$BaseUrl/auth/login" -Body $loginBody -ContentType "application/json"
$token = $login.data.token
$health = Invoke-RestMethod -Method Get -Uri "$BaseUrl/health"
Write-Host "Health:" ($health | ConvertTo-Json -Depth 5)
$caseBody = @{ title = "Caso smoke test"; client_name = "Cliente smoke"; risk_level = "medium"; facts = @{ summary = "Caso creado por smoke test." } } | ConvertTo-Json -Depth 5
$case = Invoke-RestMethod -Method Post -Uri "$BaseUrl/cases" -Headers @{ Authorization = "Bearer $token" } -Body $caseBody -ContentType "application/json"
Write-Host "Case created:" ($case | ConvertTo-Json -Depth 5)

'@
$files['tests/e2e/smoke.sh'] = @'
#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${1:-http://localhost:8080/api/v1}"
TOKEN=$(curl -s -X POST "$BASE_URL/auth/login" -H "Content-Type: application/json" -d '{"email":"admin@lexpenal.local","password":"ChangeMe123!"}' | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>console.log(JSON.parse(d).data.token));")
curl -s "$BASE_URL/health"
echo
curl -s -X POST "$BASE_URL/cases" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"title":"Caso smoke test","client_name":"Cliente smoke","risk_level":"medium","facts":{"summary":"Caso creado por smoke test."}}'
echo

'@
$files['tests/fixtures/sample-case.json'] = @'
{
  "title": "Caso muestra",
  "client_name": "Cliente muestra",
  "risk_level": "medium",
  "facts": {
    "summary": "Caso de prueba para fixtures y smoke tests."
  }
}
'@
$files['tests/integration/health-smoke.mjs'] = @'
const baseUrl = process.env.LEXPENAL_API_URL || 'http://localhost:8080/api/v1';
const response = await fetch(`${baseUrl}/health`);
const payload = await response.json();
if (!response.ok || payload.ok !== true) {
  console.error('Health check fallido', payload);
  process.exit(1);
}
console.log('Health check OK', payload);

'@
$files['tests/unit/checklist-gate.test.mjs'] = @'
import test from 'node:test';
import assert from 'node:assert/strict';
import { canAdvanceToClosure, getMissingRequiredChecklistBlocks } from '../../src/shared/rules/checklist-gate.js';

test('detecta bloques obligatorios pendientes', () => {
  const checklist = [
    { key: 'ficha', required: true, completed: true },
    { key: 'hechos', required: true, completed: false }
  ];
  const missing = getMissingRequiredChecklistBlocks(checklist);
  assert.equal(missing.length, 1);
  assert.equal(canAdvanceToClosure(checklist), false);
});

test('permite cierre cuando no faltan bloques requeridos', () => {
  const checklist = [
    { key: 'ficha', required: true, completed: true },
    { key: 'hechos', required: true, completed: true }
  ];
  assert.equal(canAdvanceToClosure(checklist), true);
});

'@
foreach ($entry in $files.GetEnumerator()) { Write-Utf8File -Path (Join-Path $BasePath $entry.Key) -Content $entry.Value -Overwrite:$Force }
Write-Host 'Bootstrap completado.'