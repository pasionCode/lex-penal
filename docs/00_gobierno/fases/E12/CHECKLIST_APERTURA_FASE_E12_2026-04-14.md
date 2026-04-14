# CHECKLIST APERTURA FASE E12 — 2026-04-14

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E12
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la fase
Endurecer operativamente el backend y su despliegue, reduciendo riesgos evidentes en dependencias, configuración de servicio, proxy y procedimiento de actualización, sin introducir cambios funcionales de negocio no priorizados.

## 3. Justificación
La fase E11 dejó cerrado el baseline de despliegue, el procedimiento reproducible y el endpoint técnico de salud. Corresponde ahora una fase de hardening mínimo para disminuir riesgo operativo y preparar continuidad más robusta.

## 4. Alcance inicial
- Inventario de hallazgos de seguridad y endurecimiento.
- Evaluación de dependencias y vulnerabilidades reportadas.
- Revisión de endurecimiento del servicio systemd y del proxy Nginx.
- Identificación de ajustes de bajo riesgo y alto beneficio.
- Consolidación documental de medidas aplicadas y pendientes.

## 5. Exclusiones iniciales
- No se abre expansión funcional de dominio.
- No se ejecutan upgrades mayores de framework sin evaluación explícita.
- No se aplican cambios de alto impacto sin baseline y evidencia.

## 6. Baseline de arranque
- Rama base: `main`
- Commit base: `25f5df9`
- Referencia inmediata anterior: cierre formal fase E11

## 7. Riesgos iniciales
- Dependencias con vulnerabilidades reportadas por `npm audit`.
- Riesgo de aplicar fixes automáticos incompatibles.
- Falsa sensación de seguridad por smoke positivo mínimo.
- Endurecimiento parcial que deje deudas silenciosas.

## 8. Unidad inicial
- E12-01 — Baseline de hardening operativo mínimo

## 9. Criterios de salida de fase
- Hallazgos priorizados y evidenciados.
- Ajustes de bajo riesgo aplicados o formalmente descartados.
- Procedimiento operativo endurecido.
- Cierre documental por unidad y cierre formal de fase.

## 10. Estado
- Fase abierta formalmente.
