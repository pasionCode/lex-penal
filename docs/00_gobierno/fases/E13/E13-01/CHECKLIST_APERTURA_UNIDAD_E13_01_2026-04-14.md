# CHECKLIST APERTURA UNIDAD E13-01 — 2026-04-14

## 1. Identificación
- Fase: E13
- Unidad: E13-01
- Nombre: Baseline de observabilidad mínima operativa
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la unidad
Levantar baseline de observabilidad real del backend desplegado, identificando señales, logs, comandos y puntos de inspección útiles para soporte operativo inmediato.

## 3. Entradas
- Commit base `a9c315e`
- `GET /api/v1/health` operativo
- `lex-penal.service` endurecido y funcional
- Procedimiento estándar de despliegue activo

## 4. Salidas esperadas
- Evidencia de journald para el servicio
- Evidencia mínima de logs de Nginx
- Comandos operativos mínimos de inspección
- Diagnóstico de suficiencia actual
- Base para E13-02

## 5. Verificaciones mínimas
- Lectura de journal del servicio
- Estado del unit y últimas reinicializaciones
- Lectura de logs del proxy
- Verificación de health local y vía Nginx
- Estado actual de persistencia/retención de logs si es visible

## 6. Criterios de cierre
- Baseline documentado
- Fuentes de observación confirmadas
- Hallazgos priorizados
- Siguiente bloque de mejora definido
