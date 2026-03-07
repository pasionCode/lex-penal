# ADR-001 — Despliegue inicial en máquina virtual propia

| Campo | Valor |
|---|---|
| Estado | **Cerrado** |
| Fecha | 2026-03-06 |
| Decisor | Equipo técnico LexPenal |
| Documentos relacionados | `docs/07_infraestructura/DESPLIEGUE_VM.md`, `docs/06_backend/ARQUITECTURA_BACKEND.md` |

---

## Contexto

LexPenal es un sistema de gestión de casos para consultorios jurídicos
de formación. Requiere despliegue en producción para el MVP con un
presupuesto de infraestructura acotado, un equipo técnico pequeño y
sin necesidad inmediata de alta disponibilidad o escala horizontal.

El sistema tiene tres componentes principales: frontend (Next.js),
backend (NestJS) y base de datos (PostgreSQL). Se evalúa dónde y cómo
alojarlos para el MVP.

---

## Opciones evaluadas

### Opción A — Máquina virtual propia (VPS)

Un único servidor virtual con Ubuntu 24.04 LTS aloja todos los
componentes. Nginx actúa como proxy inverso. PM2 gestiona los
procesos de Node.js. PostgreSQL corre en el mismo servidor.

**Ventajas**
- Control total del entorno — sistema operativo, versiones, configuración.
- Costo predecible y bajo para el volumen del MVP.
- Sin dependencia de plataformas de terceros para lógica de despliegue.
- Curva de aprendizaje conocida para el equipo.
- Adecuado para el volumen de usuarios del MVP (consultorio jurídico,
  no cientos de usuarios concurrentes).

**Desventajas**
- Responsabilidad de mantenimiento del servidor (actualizaciones, backups).
- Sin escalabilidad automática.
- Punto único de fallo — no hay redundancia en MVP.
- El equipo asume operación y monitoreo.

---

### Opción B — Plataforma como servicio (PaaS)

Usar plataformas como Railway, Render, Fly.io o equivalentes para
alojar los servicios sin gestionar servidor directamente.

**Ventajas**
- Sin gestión de SO ni actualizaciones de infraestructura.
- Despliegue más simple desde repositorio.

**Desventajas**
- Costo variable y potencialmente mayor a escala.
- Menor control sobre la configuración de red y seguridad.
- Dependencia de la disponibilidad y política de precios del proveedor.
- Datos de casos jurídicos en infraestructura de tercero — requiere
  revisión jurídica y contractual previa por tratamiento de datos sensibles.

---

### Opción C — Contenedores (Docker / Kubernetes)

Desplegar los componentes en contenedores orquestados.

**Ventajas**
- Portabilidad y reproducibilidad del entorno.
- Facilita escalabilidad futura.

**Desventajas**
- Complejidad operativa innecesaria para el MVP.
- Requiere conocimiento de orquestación que el equipo no tiene en
  esta fase.
- Tiempo de configuración que no justifica el beneficio en MVP.

---

### Opción D — Serverless / funciones en la nube

Desplegar el backend como funciones serverless (AWS Lambda, Vercel
Functions, etc.).

**Ventajas**
- Escala a cero — sin costo cuando no hay tráfico.

**Desventajas**
- NestJS no está optimizado para arranques en frío.
- La máquina de estados del caso y las transacciones de base de datos
  requieren estado persistente — incompatible con el modelo serverless.
- Complejidad de adaptación sin beneficio real en el volumen del MVP.

---

## Criterios de decisión

| Criterio | VM propia | PaaS | Contenedores | Serverless |
|---|---|---|---|---|
| Costo MVP | Bajo | Variable | Bajo-medio | Bajo al inicio / variable según uso |
| Control del entorno | Alto | Bajo | Alto | Bajo |
| Confidencialidad datos | Alta | Requiere revisión | Alta | Requiere revisión |
| Complejidad operativa | Media | Baja | Alta | Alta |
| Adecuación al equipo actual | Alta | Alta | Baja | Baja |
| Escalabilidad futura | Manual | Automática | Alta | Alta |
| Adecuación al MVP | Alta | Media | Baja | Baja |

---

## Decisión

> **[x] Opción A — Máquina virtual propia (VPS)**

**Justificación**: El MVP de LexPenal opera en un consultorio jurídico
con un volumen de usuarios reducido y predecible. Una VM propia ofrece
control total del entorno, costo bajo y predecible, y elimina la
dependencia de terceros para el alojamiento de datos jurídicos sensibles.
La complejidad operativa es manejable para el equipo en esta fase.
La migración a contenedores o PaaS queda contemplada para fases
posteriores sin bloquear el MVP.

---

## Consecuencias

- El stack de producción es: Ubuntu 24.04 LTS + Nginx + PM2 + Node.js LTS
  + PostgreSQL 16. Documentado en `DESPLIEGUE_VM.md`.
- El equipo asume responsabilidad de mantenimiento del servidor:
  actualizaciones de seguridad, backups y monitoreo.
- **Riesgo aceptado formalmente**: la VM única es un punto único de falla
  para el MVP. Este riesgo se acepta de forma explícita y se mitiga con
  política de backup diario y snapshots periódicos de la VM. La
  redundancia queda fuera del alcance del MVP.
- Política de backup obligatoria: base de datos diaria (02:00),
  storage diario (02:30), retención 30 días, copia externa requerida.
- Los puertos 3000 (frontend), 3001 (backend) y 5432 (PostgreSQL)
  no se exponen externamente — solo accesibles vía Nginx (80/443) o
  SSH desde IPs autorizadas.
- La migración a contenedores (Docker) está contemplada como paso
  siguiente al MVP sin cambios en la arquitectura de aplicación.
- Alta disponibilidad y balanceo de carga quedan fuera del alcance
  del MVP.
