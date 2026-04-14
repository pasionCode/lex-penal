# CHECKLIST APERTURA UNIDAD E11-02 — 2026-04-13

## 1. Identificación
- Fase: E11
- Unidad: E11-02
- Nombre: Verificación privilegiada y smoke de publicación
- Fecha de apertura: 2026-04-13
- Estado: ABIERTA

## 2. Objetivo de la unidad
Completar la verificación privilegiada del despliegue actual de LEX_PENAL y dejar definida una secuencia mínima de validación/publicación controlada sobre el backend ya existente.

## 3. Entradas
- Baseline E11-01 cerrado.
- Evidencia de backend activo en `*:3010`.
- Evidencia de `lex-penal.service` activo.
- Evidencia de entorno compartido con Nginx, Postgres, Docker y Nextcloud.

## 4. Tareas mínimas
- Identificar commit exacto desplegado.
- Leer configuración efectiva del servicio systemd.
- Leer configuración efectiva de Nginx aplicable a LEX_PENAL.
- Determinar ruta funcional válida para smoke test.
- Verificar si existe publicación externa o solo escucha local/proxy.
- Preparar secuencia reproducible de actualización segura.

## 5. Criterios de cierre
- Servicio atribuido completamente.
- Proxy atribuido completamente.
- Smoke test definido y ejecutable.
- Riesgos inmediatos de publicación identificados.
- Siguiente unidad técnica definida con precisión.

## 6. Restricciones
- No modificar producción sin evidencia suficiente.
- No reiniciar servicios sin necesidad expresa.
- No asumir rutas públicas o dominios sin validación.
