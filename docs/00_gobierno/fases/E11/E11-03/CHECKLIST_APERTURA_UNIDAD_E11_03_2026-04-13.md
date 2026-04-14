# CHECKLIST APERTURA UNIDAD E11-03 — 2026-04-13

## 1. Identificación
- Fase: E11
- Unidad: E11-03
- Nombre: Alineación controlada del despliegue
- Fecha de apertura: 2026-04-13
- Estado: ABIERTA

## 2. Objetivo de la unidad
Alinear el despliegue del VPS con el estado objetivo del repositorio (`main`) de forma controlada, verificable y reversible.

## 3. Entradas
- E11-02 cerrada.
- Backend actual operativo en `3010`.
- Proxy Nginx operativo bajo `/api/v1/`.
- Commit desplegado actual: `32f838f`.
- Commit local de referencia ya publicado: `5255060`.

## 4. Tareas mínimas
- Crear respaldo lógico mínimo del estado actual del despliegue.
- Confirmar HEAD remoto de `main`.
- Actualizar repo del VPS a commit objetivo.
- Recompilar artefactos si aplica.
- Reiniciar servicio.
- Ejecutar smoke local y vía Nginx.
- Registrar evidencia y resultado.

## 5. Criterios de cierre
- Servicio reiniciado sin fallo.
- Commit desplegado alineado con objetivo.
- Smoke local y vía Nginx exitosos.
- Evidencia archivada.
- Riesgo residual documentado.

## 6. Restricciones
- No tocar Nginx salvo necesidad real.
- No modificar `.env` salvo incompatibilidad comprobada.
- No improvisar cambios funcionales fuera del objetivo de alineación.
