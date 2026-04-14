# NOTA DE CIERRE UNIDAD E16-01 — 2026-04-14

## 1. Identificación
- Fase: E16
- Unidad: E16-01
- Nombre: Baseline de coexistencia y limpieza histórica
- Estado: CERRADA

## 2. Objetivo de la unidad
Levantar un baseline preciso de configuraciones activas, históricas y ambiguas del proxy/Nginx, con énfasis en coexistencia de sitios y deuda documental/técnica del servidor.

## 3. Resultado
Unidad cumplida.

## 4. Hallazgos principales
- `sites-enabled` quedó reducido a tres bloques activos: `00-default-ssl.conf`, `lexum_caddy_proxy.conf` y `nextcloud`.
- `sites-available` conserva múltiples archivos históricos, alternativos o de backup que no forman parte de la publicación activa.
- La publicación del backend de LEX_PENAL por `edu.pabloleon.com.co` se mantiene operativa.
- La deuda histórica ya no está en la publicación activa, sino en la acumulación documental/técnica de archivos no activos.

## 5. Decisión operativa
La siguiente unidad debe ejecutar una limpieza de bajo riesgo sobre archivos históricos de `sites-available`, archivándolos fuera del árbol operativo sin tocar `sites-enabled`.

## 6. Decisión de cierre
Se cierra E16-01 y se abre E16-02 para saneamiento controlado de configuraciones históricas no activas.
