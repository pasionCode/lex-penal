# CHECKLIST APERTURA UNIDAD E11-01 — 2026-04-13

## 1. Identificación
- Fase: E11
- Unidad: E11-01
- Nombre: Baseline técnico-operativo del entorno objetivo
- Fecha de apertura: 2026-04-13
- Estado: ABIERTA

## 2. Objetivo de la unidad
Levantar y consolidar el baseline real del entorno objetivo de despliegue para LEX_PENAL, incluyendo host, red, servicios, repositorio, ruta de despliegue, puertos, proxy, persistencia, runtime y elementos mínimos de control operativo.

## 3. Entradas conocidas
- Rama base: `main`
- Commit base: `38726cd`
- Ruta de despliegue previamente usada/referenciada: `/opt/lex_penal/app`
- Entorno objetivo: VPS principal del proyecto

## 4. Salidas esperadas
- Evidencia cruda de baseline del VPS.
- Documento baseline de unidad actualizado con hallazgos reales.
- Identificación de brechas operativas.
- Base para siguiente unidad de despliegue o hardening.

## 5. Verificaciones mínimas
- Acceso al VPS operativo.
- Identificación de usuario, host y fecha del levantamiento.
- Presencia o ausencia de repo desplegado.
- Estado de servicios relevantes.
- Estado de puertos escuchando.
- Estado de almacenamiento, memoria y red.
- Huella mínima de proxy/reverse proxy y artefactos de ejecución.

## 6. Criterios de cierre de la unidad
- Evidencia recolectada y archivada.
- Baseline documental completado con datos reales.
- Hallazgos resumidos.
- Siguiente paso técnico claramente definido.

## 7. Restricciones
- No modificar configuración crítica en esta unidad salvo necesidad diagnóstica mínima.
- No publicar cambios productivos en esta unidad.
- No asumir estado del servidor sin evidencia.
