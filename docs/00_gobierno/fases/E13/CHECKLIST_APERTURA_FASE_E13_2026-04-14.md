# CHECKLIST APERTURA FASE E13 — 2026-04-14

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E13
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la fase
Elevar la visibilidad operativa mínima del backend desplegado, definiendo evidencias, comandos, señales y procedimientos que permitan diagnosticar estado, fallos y comportamiento sin depender exclusivamente del smoke técnico.

## 3. Justificación
Las fases E11 y E12 dejaron el despliegue controlado, el smoke técnico y un hardening conservador del servicio. Corresponde ahora fortalecer la observabilidad mínima operativa para facilitar soporte, validación y diagnóstico.

## 4. Alcance inicial
- Baseline de observabilidad actual.
- Identificación de fuentes de logs útiles.
- Procedimiento mínimo de inspección operativa.
- Posibles mejoras de bajo riesgo sobre journald o Nginx.
- Consolidación documental de comandos y evidencias.

## 5. Exclusiones iniciales
- No se abre stack completo de monitoreo.
- No se introduce Prometheus/Grafana ni APM en esta fase.
- No se alteran componentes funcionales de negocio.

## 6. Baseline de arranque
- Rama base: `main`
- Commit base: `a9c315e`
- Referencia inmediata anterior: cierre formal fase E12

## 7. Riesgos iniciales
- Baja visibilidad ante fallos intermitentes.
- Dependencia excesiva de `health` como único indicador.
- Logs insuficientemente operacionalizados.
- Ausencia de procedimiento formal de lectura rápida de estado.

## 8. Unidad inicial
- E13-01 — Baseline de observabilidad mínima operativa

## 9. Criterios de salida de fase
- Baseline de observabilidad documentado.
- Procedimiento operativo mínimo definido.
- Mejoras de bajo riesgo aplicadas o descartadas con evidencia.
- Cierre documental por unidad y cierre formal de fase.

## 10. Estado
- Fase abierta formalmente.
