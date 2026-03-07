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
