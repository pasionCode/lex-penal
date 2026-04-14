# NOTA DE CIERRE — E9-05 — Validación externa controlada del staging
**Proyecto:** LEX_PENAL
**Fase:** E9
**Unidad:** E9-05
**Fecha de cierre:** 2026-04-13
**Estado:** CERRADA

## 1. Objeto de la unidad
Verificar desde cliente externo que el staging de LEX_PENAL respondiera correctamente por su punto de entrada real, sin afectar los servicios coexistentes del servidor.

## 2. Resultado general
La unidad **queda CERRADA por cumplimiento técnico verificable**.

## 3. Evidencia consolidada
1. La raíz del staging por IP pública respondió `200 OK` con el placeholder institucional del VPS.
2. El endpoint `https://207.180.248.126/api/v1/cases` respondió `401 Unauthorized`.
3. La respuesta del endpoint API incluyó cabeceras consistentes con paso por `nginx` y respuesta de la aplicación.
4. `https://cloud.pabloleon.com.co/` respondió `302` hacia `/login`, acreditando continuidad operativa de Nextcloud.

## 4. Interpretación técnica
- El staging quedó validado externamente.
- La respuesta `401 Unauthorized` en `/api/v1/cases` acredita alcance real del backend a través del punto de entrada público del staging.
- No se observó regresión funcional en Nextcloud.

## 5. Decisión de cierre
Se declara **CERRADA** la unidad **E9-05 — Validación externa controlada del staging**.
