# CHECKLIST APERTURA FASE E14 — 2026-04-14

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E14
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la fase
Endurecer y sanear la capa de proxy/Nginx asociada al despliegue de LEX_PENAL, reduciendo ruido heredado, mejorando claridad de publicación y formalizando reglas operativas para intervenciones sobre el proxy.

## 3. Justificación
Las fases E11, E12 y E13 dejaron el despliegue estable, endurecido y con observabilidad mínima útil. Persisten, sin embargo, señales de ruido y herencia en Nginx que justifican una fase específica de hardening del proxy.

## 4. Alcance inicial
- Baseline del proxy real que publica LEX_PENAL.
- Identificación de bloques heredados, ruido y rutas no pertinentes.
- Revisión de `default_server`, certificados y logs.
- Aplicación de medidas de bajo riesgo.
- Consolidación documental de reglas y cambios.

## 5. Exclusiones iniciales
- No se migra a una nueva arquitectura de publicación.
- No se introducen balanceadores ni componentes externos.
- No se altera lógica funcional del backend.

## 6. Baseline de arranque
- Rama base: `main`
- Commit base: `d758a09`
- Referencia inmediata anterior: cierre formal fase E13

## 7. Riesgos iniciales
- Configuración heredada que contamine logs o errores.
- Bloques de Nginx con funciones ajenas a LEX_PENAL.
- Certificados o bloques por defecto que dificulten claridad operativa.
- Intervenciones sobre proxy que afecten disponibilidad si no se validan bien.

## 8. Unidad inicial
- E14-01 — Baseline de hardening de proxy/Nginx

## 9. Criterios de salida de fase
- Baseline de proxy documentado.
- Ajustes de bajo riesgo aplicados o descartados con evidencia.
- Publicación del backend más clara y menos ruidosa.
- Cierre documental por unidad y cierre formal de fase.

## 10. Estado
- Fase abierta formalmente.
