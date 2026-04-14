# BASELINE FASE E16 — 2026-04-14

## 1. Punto de partida
La fase E16 inicia después del cierre formal de E15, tomando como base el commit `5f3cbd7`.

## 2. Estado heredado
- Backend de LEX_PENAL publicado explícitamente por `edu.pabloleon.com.co`.
- `default_server` ya no es el punto funcional principal del backend.
- Nginx conserva coexistencia con otros bloques y archivos históricos.
- Persisten múltiples archivos en `sites-available` que no necesariamente reflejan estado vigente.

## 3. Brecha de la nueva fase
Aún existe deuda histórica de configuración en Nginx y en la convivencia de sitios, lo que puede dificultar mantenimiento, diagnóstico y futuras intervenciones controladas.

## 4. Decisión de arranque
Se abre E16-01 para clasificar con rigor qué configuraciones están activas, cuáles son históricas y cuáles son candidatas a saneamiento sin riesgo.
