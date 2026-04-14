# MATRIZ DE CRITERIOS — PASO A PREPRODUCCIÓN — E10-01 — 2026-04-13
**Proyecto:** LEX_PENAL
**Fase:** E10
**Unidad:** E10-01

## 1. Propósito
Definir qué condiciones deben considerarse mínimas antes de proponer el paso de un staging estable hacia un entorno con aspiración preproductiva.

## 2. Criterios bloqueantes
### B1. Autenticación real validada extremo a extremo
Debe probarse el flujo real de login, emisión de token y acceso autenticado a endpoints protegidos.

### B2. Validación funcional priorizada sobre casos de uso críticos
Deben probarse de forma controlada al menos los flujos nucleares del backend, no solo la disponibilidad HTTP:
- autenticación
- listado/consulta de casos
- creación/actualización sobre recursos críticos
- comportamiento de guardas y respuestas esperadas

### B3. Criterio explícito de manejo de secretos y configuración
Debe existir claridad sobre:
- dónde se guardan secretos
- cómo se rotan
- qué valores son solo de staging
- qué no puede promoverse tal cual a otro entorno

### B4. Trazabilidad mínima de operación
Debe existir evidencia suficiente para reconstruir:
- versión desplegada
- servicio activo
- punto de entrada
- decisión documental de avance

## 3. Criterios no bloqueantes inmediatos
### NB1. Limpieza cosmética adicional de nginx
Puede mejorar orden operativo, pero no bloquea por sí sola el siguiente salto.

### NB2. Optimización estética o refinamientos no críticos del placeholder raíz
No afecta el valor técnico del staging.

### NB3. Endurecimientos adicionales no críticos
Pueden planificarse, pero no deben retrasar validaciones funcionales esenciales si el entorno ya es estable.

## 4. Estado actual frente a la matriz
### Cumplidos
- servicio backend operativo por `systemd`
- proxy `nginx` funcional
- staging validado interna y externamente
- secretos rotados
- trazabilidad documental suficiente del bloque E9

### Pendientes principales
- autenticación real extremo a extremo
- batería funcional priorizada sobre endpoints críticos
- eventual criterio más formal de promoción al siguiente entorno

## 5. Recomendación operativa
El siguiente bloque técnico recomendado es:

**E10-02 — Validación funcional priorizada con autenticación real**

## 6. Conclusión
El proyecto no está en un punto de “preproducción por declaración”, pero sí en un punto técnicamente maduro para pasar de estabilización de entorno a validación funcional priorizada.
