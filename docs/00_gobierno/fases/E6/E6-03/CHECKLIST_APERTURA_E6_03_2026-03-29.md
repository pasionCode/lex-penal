# CHECKLIST APERTURA E6-03 — 2026-03-29

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E6 — Integración y hardening del MVP
- Unidad: E6-03 — [DEFINIR FOCO OPERATIVO]
- Fecha de apertura: 2026-03-29
- Estado: ABIERTA

## 2. Objetivo específico
Abrir la unidad E6-03 para intervenir el siguiente frente prioritario del hardening/integración del MVP, conservando coherencia con lo ya validado en E6-01 y E6-02, y asegurando que la nueva superficie quede:

- alineada con la implementación real
- validada en runtime
- documentada bajo gobierno MDS
- sin regresión sobre lo ya cerrado

> **Nota operativa:** el foco específico de E6-03 debe declararse expresamente antes de su cierre.  
> Esta apertura deja formalmente habilitada la unidad y su marco metodológico, a la espera de fijar el objetivo técnico puntual.

## 3. Justificación
Tras el cierre satisfactorio de E6-01 y E6-02 sobre el módulo de auditoría, la fase E6 entra en un punto donde ya no basta con validar endpoints aislados: se requiere continuar la integración y el hardening del MVP sobre superficies reales, priorizando trazabilidad, consistencia funcional, validación runtime y cierre de gobierno.

E6-03 se abre para abordar el siguiente bloque de trabajo de esta fase, manteniendo la disciplina ya aplicada:

- baseline técnico previo
- identificación de punto real de intervención
- implementación controlada
- prueba dedicada
- build verde
- nota formal de cierre

## 4. Alcance de E6-03
Debe quedar implementado, validado y documentado, como mínimo:

- baseline técnico de la superficie seleccionada
- identificación del punto real de escritura / lectura / validación según el foco
- decisión técnica explícita de implementación
- ajuste de código en servicio/repository/controller donde corresponda
- prueba runtime dedicada
- build verde
- nota de cierre E6-03

## 5. Fuera de alcance
Queda fuera de alcance de E6-03, salvo decisión expresa posterior:

- rediseño transversal de arquitectura no exigido por el foco
- refactor masivo de módulos no impactados
- cambios de frontend o UI
- migraciones no justificadas por el objetivo puntual
- hardening global de toda la fase E6 en una sola unidad
- cierre acumulado de fase E6

## 6. Decisiones metodológicas mínimas

### 6.1 Regla de intervención
La unidad no se abre para rediseñar por hipótesis, sino para intervenir sobre puntos reales del sistema ya existentes y verificables.

### 6.2 Fuente de verdad
La fuente de verdad de E6-03 será:

1. implementación real vigente
2. contrato/API/documentación aplicable
3. evidencia runtime
4. cierre de gobierno

### 6.3 Secuencia obligatoria
La secuencia mínima de trabajo de E6-03 será:

1. baseline técnico
2. identificación del punto exacto de intervención
3. decisión de diseño
4. implementación
5. runtime
6. build
7. cierre documental

## 7. Pregunta operativa de apertura
La pregunta rectora de E6-03 es:

**¿Cuál es el siguiente punto crítico del MVP que debe endurecerse o integrarse en esta unidad, y cuál es el lugar exacto de intervención para hacerlo sin introducir regresiones ni desalineación con el MDS?**

## 8. Entregables mínimos
- checklist de apertura E6-03
- baseline técnico E6-03
- decisión de diseño aplicada al foco
- cambios de implementación en código
- script de prueba dedicado
- nota de cierre E6-03

## 9. Criterios de aceptación
E6-03 solo podrá cerrarse si se verifica:

- foco técnico de la unidad claramente delimitado
- baseline técnico realizado
- implementación alineada con superficie real
- runtime dedicado en verde
- build verde
- documentación de cierre consistente
- ausencia de regresión evidente sobre E6-01 y E6-02

## 10. Riesgo principal
El principal riesgo de E6-03 es abrir una unidad sin delimitar con precisión el punto de intervención, generando:

- implementación sobre supuestos
- dispersión del alcance
- deuda documental
- regresiones innecesarias
- cierre ambiguo

## 11. Dependencias inmediatas
E6-03 depende funcionalmente de los cierres previos ya consolidados:

- E6-01 — lectura de auditoría por caso
- E6-02 — instrumentación de eventos case-scoped críticos

La nueva unidad no debe romper ni degradar estas superficies.

## 12. Siguiente paso inmediato
Abrir baseline técnico de E6-03 con esta pregunta:

**¿Cuál será exactamente el foco de intervención de E6-03 y qué archivos, servicios, repositories o contratos quedan comprometidos por esa decisión?**
