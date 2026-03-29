# CHECKLIST APERTURA E6-02 — 2026-03-28

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E6 — Integración y hardening del MVP
- Unidad: E6-02 — Instrumentación de eventos case-scoped críticos
- Fecha de apertura: 2026-03-28
- Estado: ABIERTA

## 2. Objetivo específico
Ampliar la superficie real de auditoría del MVP, instrumentando eventos **case-scoped** adicionales sobre la infraestructura ya validada en E6-01, de forma que `GET /api/v1/cases/{caseId}/audit` deje de depender únicamente de `transicion_estado` y pase a reflejar otras operaciones críticas del caso.

## 3. Justificación
En E6-01 quedó resuelta la lectura funcional de auditoría por caso sobre `eventos_auditoria`, con control de acceso, paginación, filtro por tipo, runtime verde y build verde.

Sin embargo, la utilidad real del endpoint aún es limitada si la tabla solo recibe eventos desde transiciones de estado.

E6-02 abre para resolver esa brecha: no construir otra superficie de lectura, sino **ensanchar los puntos reales de escritura auditada** en flujos críticos ya existentes del MVP y visibles a nivel de caso.

## 4. Alcance de E6-02
Debe quedar implementado, validado y documentado, como mínimo:

- registro de evento `revision_supervisor`
- registro de evento `informe_generado`
- visibilidad real de esos eventos en:
  - `GET /api/v1/cases/{caseId}/audit`
- conservación del control de acceso ya validado en E6-01
- filtro por tipo funcionando con los nuevos eventos
- prueba runtime dedicada
- build verde

## 5. Fuera de alcance
Queda fuera de alcance de E6-02:

- endpoint global de auditoría
- auditoría de sesión (`login` / `logout`)
- auditoría de `ia_query`
- auditoría de eliminación de caso
- `AuditInterceptor` transversal
- retrocarga histórica de eventos
- cambios de frontend o UI
- rediseño del endpoint `GET /audit` ya aprobado en E6-01

## 6. Decisiones de diseño mínimas

### 6.1 Fuente de datos
Se mantiene la fuente ya aprobada en E6-01:

- tabla `eventos_auditoria`
- sin migración nueva
- sin infraestructura paralela

### 6.2 Naturaleza de los eventos
Los eventos a instrumentar en E6-02 son **case-scoped** y deben quedar asociados al `caso_id`.

Eventos mínimos obligatorios:

- `revision_supervisor`
- `informe_generado`

### 6.3 Puntos de escritura a resolver
La unidad debe identificar e instrumentar los puntos reales donde hoy ya se ejecutan estas acciones:

- creación/registro de revisión de supervisor
- generación de informes del caso

### 6.4 Criterio de escritura
La instrumentación debe ocurrir en el punto transaccional o inmediatamente posterior a la operación exitosa, evitando:

- duplicidad de eventos
- escritura fantasma
- registro de evento sin operación real consolidada

## 7. Fuente de verdad operativa
Aquí la primera decisión técnica de E6-02 no es la tabla, porque esa ya quedó resuelta en E6-01.

La primera decisión técnica real de E6-02 es esta:

**¿En qué servicios y en qué punto exacto del flujo deben escribirse `revision_supervisor` e `informe_generado` para que la auditoría refleje operaciones reales y no duplicadas?**

La secuencia correcta es:

1. baseline de puntos de escritura reales
2. identificación de método/servicio exacto
3. validación de no duplicidad
4. instrumentación
5. runtime
6. cierre

## 8. Entregables mínimos
- checklist de apertura E6-02
- baseline técnico de puntos de escritura en `review` y `reports`
- decisión de write point por cada evento
- implementación en servicios/repository donde corresponda
- script `test_e6_02.sh`
- nota de cierre E6-02

## 9. Criterios de aceptación
E6-02 cierra solo si se verifica:

- al generar una revisión de supervisor se registra evento `revision_supervisor`
- al generar un informe se registra evento `informe_generado`
- ambos eventos quedan visibles en `GET /api/v1/cases/{caseId}/audit`
- `supervisor` y/o `administrador` pueden verificar esa lectura según reglas vigentes
- `estudiante` sigue recibiendo `403` en el endpoint de auditoría
- caso inexistente sigue retornando `404`
- filtro `tipo=revision_supervisor` funciona
- filtro `tipo=informe_generado` funciona
- no hay duplicidad evidente de eventos por una misma operación
- `npm run build` queda en verde

## 10. Cobertura runtime sugerida
Pruebas mínimas sugeridas:

1. login admin
2. login supervisor
3. login estudiante
4. crear cliente y caso
5. activar caso para dejar `transicion_estado`
6. ejecutar operación real de revisión de supervisor
7. ejecutar operación real de generación de informe
8. `GET /audit` admin → `200`
9. `GET /audit` supervisor → `200`
10. `GET /audit` estudiante → `403`
11. `GET /audit?tipo=revision_supervisor` → `200`
12. `GET /audit?tipo=informe_generado` → `200`
13. verificación de shape paginado correcto
14. build verde

## 11. Riesgo principal
El riesgo principal de E6-02 no es el endpoint de lectura, que ya quedó validado, sino la **ubicación exacta del write point**.

Los errores probables aquí son:

- instrumentar demasiado arriba y registrar eventos aunque la operación falle
- instrumentar demasiado abajo y perder contexto útil
- duplicar escritura en flujos que ya tengan persistencia parcial
- contaminar auditoría con eventos no confiables

## 12. Siguiente paso inmediato
Abrir baseline técnico de E6-02 con esta pregunta operativa:

**¿Dónde se crean realmente hoy las revisiones de supervisor y los informes generados, y en qué punto exacto debe escribirse cada evento de auditoría para que quede trazabilidad real, única y consistente?**
