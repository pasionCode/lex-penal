# Nota de gobierno — Stack canónico de implementación

| Campo | Valor |
|---|---|
| Tipo | Decisión operativa de gobierno |
| Fecha | 2026-03-06 |
| Estado | Cerrada |
| Responsable | Equipo técnico del proyecto |
| Documentos relacionados | `docs/00_gobierno/adrs/ADR-001` al `ADR-008`, `docs/10_gestion/ROADMAP.md` |

---

## Contexto

El bootstrap del proyecto (`lexpenal_bootstrap_v5.ps1`) generó una
estructura técnica inicial en `src/` con las siguientes características:

| Componente | Bootstrap generó |
|---|---|
| Backend | Express.js + JavaScript |
| Acceso a datos | Pool directo de pg (sin ORM) |
| Frontend | Vite + React JSX |
| Infraestructura | Docker Compose + Dockerfiles |

Esta estructura fue útil para validar el árbol de carpetas y los
módulos del sistema. No es la arquitectura objetivo del proyecto.

---

## Decisión

**El stack canónico de implementación es el definido por los ADRs.**

| Componente | Stack canónico | ADR |
|---|---|---|
| Backend | NestJS + TypeScript | ADR-006, ARQUITECTURA_BACKEND |
| ORM / acceso a datos | Prisma | ADR-006 |
| Base de datos | PostgreSQL 16 | ADR-002 |
| Frontend | Next.js + App Router + TypeScript | ARQUITECTURA_FRONTEND |
| Autenticación | JWT simple — cookie HttpOnly + Bearer | ADR-007 |
| Despliegue | VM Ubuntu 24.04 LTS — Nginx + PM2 | ADR-001 |

**El esqueleto técnico generado por el bootstrap no es canónico y no
debe usarse como base de implementación de producción.**

---

## Consecuencias

1. El contenido actual de `src/` se archiva o vacía antes de iniciar
   la implementación real. No se escribe código de producción sobre
   Express, JavaScript plano ni el pool de pg del bootstrap.

2. El nuevo esqueleto técnico se genera con las herramientas canónicas:
   - `nest new backend` — con TypeScript y estructura modular.
   - `npx create-next-app@latest frontend --ts --app` — Next.js con TypeScript y App Router.
   - `prisma init` — con `schema.prisma` y primera migración.

3. `infra/docker/` se conserva como referencia para fases posteriores
   pero no se usa como ruta de despliegue del MVP. Docker está
   explícitamente fuera del alcance del MVP (ADR-001, ALCANCE_PROYECTO).

4. El saneamiento de duplicados documentales y ubicaciones no canónicas
   en `docs/` forma parte del Hito 0, junto con la recreación del
   esqueleto técnico. Ver `SANEAMIENTO_DOCS.md` para el detalle de
   acciones y ubicaciones canónicas definitivas.

5. Esta decisión se registra en el ROADMAP como Hito 0 — Saneamiento
   y creación del esqueleto canónico — que debe cerrarse antes de
   iniciar el Hito 3 (backend base implementado).

---

## Lo que el bootstrap sí aporta al proyecto

La estructura generada por el bootstrap tiene valor documental
y de referencia:

- La carpeta `docs/` está bien estructurada y es la base de trabajo.
- Los catálogos en `resources/` (`risk_levels.json`, `sample_case.json`,
  `case_template.json`) son reutilizables como fixtures y seeds.
- Los scripts de `scripts/linux/` y `scripts/windows/` son referencias
  útiles para el entorno de desarrollo, ajustables al stack canónico.
- La carpeta `tests/` tiene la estructura correcta — se reutiliza.

---

## Estado de los ADRs que gobiernan esta decisión

ADR-006 (Prisma) y ADR-007 (JWT simple) están cerrados en el
repositorio vigente. Todos los ADRs relevantes al MVP están cerrados.
No hay decisiones de arquitectura pendientes que bloqueen el inicio
de la implementación, salvo las registradas en `ROADMAP.md` sección 8.
