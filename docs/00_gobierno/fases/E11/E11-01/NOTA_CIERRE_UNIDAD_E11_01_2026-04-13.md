# NOTA DE CIERRE UNIDAD E11-01 — 2026-04-13

## 1. Identificación
- Fase: E11
- Unidad: E11-01
- Nombre: Baseline técnico-operativo del entorno objetivo
- Estado: CERRADA

## 2. Objetivo de la unidad
Levantar y consolidar el baseline real del entorno objetivo de despliegue para LEX_PENAL, incluyendo host, red, servicios, repositorio, puertos, proxy, persistencia, runtime y elementos mínimos de control operativo.

## 3. Resultado
Unidad cumplida en nivel suficiente para continuidad operativa.

## 4. Logros concretos
- Se confirmó acceso al VPS objetivo.
- Se levantó baseline crudo del host.
- Se confirmó presencia del repo en `/opt/lex_penal/app`.
- Se identificó el backend de LEX_PENAL ejecutándose en `*:3010`.
- Se atribuyó el puerto `3010` al servicio `lex-penal.service`.
- Se comprobó que `/` y `/health` no funcionan hoy como endpoints de verificación.
- Se confirmó coexistencia con otros servicios del servidor, especialmente Nextcloud.

## 5. Hallazgos críticos
1. El backend ya está desplegado y ejecutándose.
2. El smoke check no puede depender de `/health`, porque devuelve 404.
3. El entorno es compartido y tiene riesgo de interferencia si se modifica sin control.
4. Persisten vacíos de verificación privilegiada por falta de `sudo` no interactivo.

## 6. Deuda trasladada a la siguiente unidad
- Confirmar commit exacto desplegado.
- Confirmar bloque Nginx que publica o enruta LEX_PENAL.
- Verificar configuración con privilegios.
- Definir ruta de smoke test funcional real.
- Preparar actualización controlada del servicio.

## 7. Decisión de cierre
Se cierra E11-01 por cumplimiento de baseline mínimo y se traslada la profundización privilegiada a E11-02.
