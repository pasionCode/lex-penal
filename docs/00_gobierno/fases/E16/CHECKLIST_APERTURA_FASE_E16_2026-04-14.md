# CHECKLIST APERTURA FASE E16 — 2026-04-14

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E16
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la fase
Ordenar la coexistencia de sitios y configuraciones históricas del servidor, reduciendo ambigüedad operativa, deuda de publicación y ruido residual alrededor del backend de LEX_PENAL.

## 3. Justificación
Las fases E11 a E15 dejaron el backend desplegado, endurecido, observable y publicado de forma explícita en `edu.pabloleon.com.co`. Persiste, sin embargo, una capa de configuración histórica y coexistencia de sitios que conviene ordenar para evitar futuras colisiones, confusiones o reprocesos.

## 4. Alcance inicial
- Inventario de configuraciones activas e históricas de Nginx.
- Identificación de archivos redundantes, ambiguos o huérfanos.
- Clasificación entre configuraciones vigentes, históricas y candidatas a retiro.
- Saneamiento controlado de bajo riesgo.
- Consolidación documental de reglas de limpieza y convivencia de sitios.

## 5. Exclusiones iniciales
- No se migran servicios a otra máquina.
- No se desinstala Nextcloud ni otros servicios activos.
- No se reestructura toda la topología del servidor fuera del alcance de Nginx.

## 6. Baseline de arranque
- Rama base: `main`
- Commit base: `5f3cbd7`
- Referencia inmediata anterior: cierre formal fase E15

## 7. Riesgos iniciales
- Confusión entre archivos activos e históricos.
- Acumulación de configuraciones obsoletas que induzcan errores futuros.
- Cambios sobre archivos ambiguos sin evidencia suficiente.
- Saneamiento excesivo que afecte servicios coexistentes.

## 8. Unidad inicial
- E16-01 — Baseline de coexistencia y limpieza histórica

## 9. Criterios de salida de fase
- Inventario y clasificación de configuraciones suficiente.
- Saneamientos de bajo riesgo aplicados o descartados con evidencia.
- Reglas operativas de convivencia y limpieza reforzadas.
- Cierre documental por unidad y cierre formal de fase.

## 10. Estado
- Fase abierta formalmente.
