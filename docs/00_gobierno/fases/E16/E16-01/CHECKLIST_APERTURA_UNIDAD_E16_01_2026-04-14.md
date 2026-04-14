# CHECKLIST APERTURA UNIDAD E16-01 — 2026-04-14

## 1. Identificación
- Fase: E16
- Unidad: E16-01
- Nombre: Baseline de coexistencia y limpieza histórica
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la unidad
Levantar un baseline preciso de configuraciones activas, históricas y ambiguas del proxy/Nginx, con énfasis en coexistencia de sitios y deuda documental/técnica del servidor.

## 3. Entradas
- Commit base `5f3cbd7`
- Backend de LEX_PENAL publicado en `edu.pabloleon.com.co`
- `sites-enabled` ya saneado parcialmente en fases previas

## 4. Salidas esperadas
- Inventario de archivos activos
- Inventario de archivos históricos relevantes
- Clasificación preliminar: vigente / histórico / ambiguo / candidato a retiro
- Base para E16-02

## 5. Verificaciones mínimas
- `sites-enabled`
- `sites-available`
- diferencias entre activos y disponibles
- referencias a dominios, upstreams y proxies
- identificación de archivos backup o legacy

## 6. Criterios de cierre
- Baseline documental suficiente
- Hallazgos clasificados
- Siguiente bloque de saneamiento definido con precisión
