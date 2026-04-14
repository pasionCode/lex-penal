# NOTA DE CIERRE UNIDAD E11-04 — 2026-04-13

## 1. Identificación
- Fase: E11
- Unidad: E11-04
- Nombre: Saneamiento operativo post-despliegue
- Estado: CERRADA

## 2. Objetivo de la unidad
Formalizar la higiene del despliegue del VPS para evitar contaminación del árbol de trabajo, mejorar la trazabilidad operativa y dejar un procedimiento reproducible de actualización.

## 3. Resultado
Unidad cumplida.

## 4. Logros alcanzados
- Se incorporó script estándar de despliegue: `infra/scripts/deploy_lex_penal_vps.sh`.
- Se formalizó la regla de no almacenar evidencias dentro del repo desplegado.
- La corrida operativa fue exitosa.
- No se detectaron archivos no rastreados durante la ejecución (`SIN_UNTRACKED`).
- El despliegue quedó alineado al commit `1b5dffe`.
- El servicio `lex-penal.service` reinició correctamente.
- El smoke local y vía Nginx sobre `POST /api/v1/auth/login` respondió `400 Bad Request`, validando aplicación y proxy.
- Las evidencias y respaldos quedaron en `/opt/lex_penal/shared/ops/`.

## 5. Riesgo residual
El smoke operativo aún depende de una ruta funcional de negocio/validación (`auth/login`) y no de un endpoint técnico explícito de salud.

## 6. Decisión de cierre
Se cierra E11-04 y se recomienda abrir E11-05 para implementar endpoint mínimo de health/readiness.
