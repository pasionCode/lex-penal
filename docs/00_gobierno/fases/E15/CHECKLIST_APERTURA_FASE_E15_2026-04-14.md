# CHECKLIST APERTURA FASE E15 — 2026-04-14

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E15
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la fase
Aumentar la claridad de publicación del backend de LEX_PENAL, reduciendo dependencia del `default_server`, clarificando el dominio efectivo del servicio y preparando un esquema de proxy menos ambiguo.

## 3. Justificación
Las fases E11 a E14 dejaron el backend desplegado, endurecido, observable y con menor ruido heredado. Persiste, sin embargo, una ambigüedad relevante: el backend actual sigue sirviéndose desde el bloque `default_server` con certificado snakeoil, pese a que existen dominios y certificados válidos en el servidor.

## 4. Alcance inicial
- Baseline exacto del esquema actual de publicación del backend.
- Identificación de dominios candidatos y certificados utilizables.
- Validación de qué host responde realmente al backend.
- Preparación de un saneamiento controlado del proxy sin afectar otros servicios.

## 5. Exclusiones iniciales
- No se reestructura toda la granja de sitios del servidor.
- No se migra Nextcloud ni otros servicios ajenos a LEX_PENAL.
- No se introducen balanceadores ni componentes externos.

## 6. Baseline de arranque
- Rama base: `main`
- Commit base: `126b32e`
- Referencia inmediata anterior: cierre formal fase E14

## 7. Riesgos iniciales
- Ambigüedad entre dominio real, `default_server` y certificado servido.
- Interferencia con sitios coexistentes en el mismo Nginx.
- Cambios de publicación que puedan afectar salud del backend si no se validan con precisión.

## 8. Unidad inicial
- E15-01 — Baseline de claridad de publicación y dominio

## 9. Criterios de salida de fase
- Esquema de publicación real documentado.
- Dominio objetivo definido con evidencia.
- Ajuste de bajo riesgo aplicado o formalmente descartado.
- Cierre documental por unidad y cierre formal de fase.

## 10. Estado
- Fase abierta formalmente.
