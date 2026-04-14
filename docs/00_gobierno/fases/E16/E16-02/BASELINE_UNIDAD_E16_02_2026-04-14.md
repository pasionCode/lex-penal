# BASELINE UNIDAD E16-02 — 2026-04-14

## 1. Punto de partida
La publicación activa del servidor ya es más clara, pero `sites-available` conserva configuraciones históricas que aumentan ruido y ambigüedad de mantenimiento.

## 2. Estrategia
Aplicar una limpieza conservadora y reversible: archivar fuera del árbol operativo únicamente archivos no activos y claramente históricos o redundantes.

## 3. Resultado esperado
Menor deuda histórica en Nginx sin afectar los sitios activos ni la publicación del backend.
