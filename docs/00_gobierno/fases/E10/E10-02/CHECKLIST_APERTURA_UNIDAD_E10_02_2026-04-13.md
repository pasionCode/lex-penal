# CHECKLIST APERTURA UNIDAD E10-02 — 2026-04-13
**Proyecto:** LEX_PENAL
**Fase:** E10
**Unidad:** E10-02
**Nombre:** Validación funcional priorizada con autenticación real
**Fecha de apertura:** 2026-04-13
**Estado:** ABIERTA

## 1. Objetivo
Verificar la viabilidad real de autenticación en staging y ejecutar una validación funcional priorizada sobre endpoints protegidos, partiendo de credenciales reales o de un criterio documentado de ausencia de ellas.

## 2. Precondiciones verificadas
- E10 abierta
- E10-01 abierta
- staging funcional
- backend accesible externamente
- proxy `nginx` operativo
- secretos rotados

## 3. Alcance
Incluye:
- diagnóstico de disponibilidad de usuario real en staging
- validación del endpoint de login
- validación de acceso autenticado a endpoint protegido
- documentación de resultado y bloqueantes reales

No incluye:
- creación arbitraria de usuarios sin criterio
- despliegue preproductivo
- batería funcional completa de todos los módulos

## 4. Riesgos controlados
- asumir que existe usuario de prueba cuando no existe
- declarar “autenticación validada” sin login real
- perder trazabilidad del bloqueo si no hay credenciales útiles

## 5. Criterios de aceptación
- se determina si existe o no credencial real utilizable en staging
- se prueba `/api/v1/auth/login` con evidencia real
- si login exitoso, se prueba al menos un endpoint protegido con token
- si login no es viable, el bloqueo queda documentado con precisión
