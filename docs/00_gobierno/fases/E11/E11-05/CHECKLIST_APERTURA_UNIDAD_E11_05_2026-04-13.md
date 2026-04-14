# CHECKLIST APERTURA UNIDAD E11-05 — 2026-04-13

## 1. Identificación
- Fase: E11
- Unidad: E11-05
- Nombre: Endpoint mínimo de health/readiness
- Fecha de apertura: 2026-04-13
- Estado: ABIERTA

## 2. Objetivo de la unidad
Incorporar un endpoint técnico mínimo y estable para verificación de salud del backend, apto para smoke operativo y validación post-despliegue.

## 3. Entradas
- E11-04 cerrada.
- Servicio y proxy operativos.
- Procedimiento estándar de despliegue ya formalizado.

## 4. Tareas mínimas
- Definir ruta mínima de health o readiness.
- Implementar controlador/endpoint.
- Verificar respuesta local.
- Verificar respuesta vía Nginx.
- Ajustar script operativo si aplica.

## 5. Criterios de cierre
- Endpoint responde de forma estable y predecible.
- Smoke post-deploy deja de depender de `auth/login`.
- Contrato y evidencia mínima actualizados si corresponde.
