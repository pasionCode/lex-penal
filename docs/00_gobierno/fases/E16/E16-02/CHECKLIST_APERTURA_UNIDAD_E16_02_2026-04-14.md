# CHECKLIST APERTURA UNIDAD E16-02 — 2026-04-14

## 1. Identificación
- Fase: E16
- Unidad: E16-02
- Nombre: Saneamiento controlado de configuraciones históricas no activas
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la unidad
Reducir deuda histórica y ambigüedad en `sites-available` archivando fuera del árbol operativo configuraciones no activas, redundantes o claramente históricas, sin afectar los sitios vigentes.

## 3. Entradas
- E16-01 cerrada
- `sites-enabled` con solo tres bloques activos
- `edu.pabloleon.com.co` operativo para LEX_PENAL

## 4. Tareas mínimas
- Respaldar el conjunto candidato
- Crear directorio de archivo histórico operativo
- Mover archivos seleccionados desde `sites-available`
- Validar `nginx -t`
- Verificar `health` por `edu.pabloleon.com.co`
- Documentar resultado

## 5. Criterios de cierre
- Archivos históricos seleccionados fuera de `sites-available`
- `nginx -t` exitoso
- `health` en `200`
- Evidencia archivada
