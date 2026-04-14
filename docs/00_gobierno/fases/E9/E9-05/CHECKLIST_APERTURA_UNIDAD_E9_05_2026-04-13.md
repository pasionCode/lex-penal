# CHECKLIST APERTURA UNIDAD E9-05 — 2026-04-13
**Proyecto:** LEX_PENAL
**Fase:** E9
**Unidad:** E9-05
**Nombre:** Validación externa controlada del staging
**Fecha de apertura:** 2026-04-13
**Estado:** ABIERTA

## 1. Objetivo
Verificar desde fuera del host que el staging de LEX_PENAL responde correctamente por su punto de entrada real, sin pérdida de funcionalidad del backend ni afectación de servicios coexistentes.

## 2. Precondiciones verificadas
- E9-01.A cerrada
- E9-02 cerrada
- E9-03 cerrada
- E9-04 cerrada
- backend activo por `systemd`
- proxy `nginx` funcional hacia `/api/v1/*`
- secretos ya rotados

## 3. Alcance
Incluye:
- validación externa del endpoint staging
- comprobación de respuesta esperada del backend sin credenciales
- comprobación de la raíz del staging
- comprobación de continuidad de Nextcloud
- consolidación documental del resultado

No incluye:
- pruebas de carga
- despliegue productivo
- hardening adicional
- monitoreo continuo

## 4. Riesgos controlados
- falsa sensación de operatividad limitada solo al loopback
- regresiones invisibles desde cliente real
- ruptura no detectada de servicios coexistentes

## 5. Criterios de aceptación
- `/api/v1/cases` responde externamente con una respuesta coherente del backend
- `/` responde conforme al comportamiento previsto del staging
- Nextcloud responde de forma consistente
- la unidad queda documentada con evidencia real
