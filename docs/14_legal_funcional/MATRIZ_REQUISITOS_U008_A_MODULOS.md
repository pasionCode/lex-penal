# Matriz de requisitos — Unidad 8 a módulos del sistema

| Campo | Valor |
|---|---|
| Versión | 1.0 |
| Fecha | 2026-03-06 |
| Estado | Vigente |
| Documentos relacionados | `docs/14_legal_funcional/TRAZABILIDAD_U008.md`, `docs/14_legal_funcional/REGLAS_FUNCIONALES_VINCULANTES.md`, `docs/03_datos/MODELO_DATOS_v2.md`, `docs/01_producto/BACKLOG_INICIAL.md` |

---

## Propósito

Este documento traduce cada herramienta de la Unidad 8 en requisitos
funcionales concretos para el diseño de backend, modelo de datos y
criterios de aceptación. Es el puente entre el marco metodológico
académico y la implementación técnica.

La correspondencia U008 → herramienta del sistema está en
`TRAZABILIDAD_U008.md`. Este documento asume esa correspondencia y
la convierte en especificación de implementación.

---

## Ficha

**Origen**: Apartado 1, U008 — identificación básica del caso.

**Requisito funcional**: El sistema debe permitir registrar y editar
los datos de identificación del expediente: radicado, datos del procesado,
delito imputado, etapa procesal, situación de libertad, juzgado y régimen
procesal aplicable.

**Módulo del sistema**: `CasesModule` — herramienta `basic-info`.

**Entidades de datos**: `casos` (campos de ficha), `clientes`.

**Restricción vinculante**: R01 — toda ficha pertenece a un caso.

**Criterio de aceptación clave**: Un estudiante puede crear un caso,
completar todos los campos de la ficha y recuperarlos sin pérdida de
información. Los campos obligatorios (radicado, procesado, delito)
no pueden quedar vacíos al activar el caso.

---

## Hechos

**Origen**: Apartados de lectura jurídica de los hechos y problema
jurídico e hipótesis de imputación, U008.

**Requisito funcional**: El sistema debe permitir registrar la narración
fáctica del caso, la calificación jurídica inicial y la hipótesis de
imputación. Debe soportar múltiples hechos con orden cronológico y
su relación con el tipo penal imputado.

**Módulo del sistema**: `CasesModule` — herramienta `facts`.

**Entidades de datos**: `hechos`, `linea_tiempo`.

**Restricción vinculante**: R01 — los hechos pertenecen al caso. R02 —
al menos un hecho registrado es requisito mínimo para enviar a revisión
(RN-HER-02).

**Criterio de aceptación clave**: Un estudiante puede registrar múltiples
hechos con descripción y fecha, ordenarlos cronológicamente y asociarlos
a la calificación jurídica. El intento de enviar a revisión sin hechos
registrados retorna `422`.

---

## Pruebas

**Origen**: Matriz probatoria, U008.

**Requisito funcional**: El sistema debe permitir registrar las pruebas
del caso con su tipo, descripción, valor probatorio, estado procesal
y relación con los hechos. Debe distinguir entre pruebas de cargo y
de descargo.

**Módulo del sistema**: `CasesModule` — herramienta `evidence`.

**Entidades de datos**: `pruebas`.

**Restricción vinculante**: R01 — las pruebas pertenecen al caso.
Mínimos de la herramienta pendientes de definición formal (ver
`CALIDAD_BASE.md` sección 1.3).

**Criterio de aceptación clave**: Un estudiante puede registrar pruebas
con todos sus atributos y marcarlas como de cargo o descargo. Las pruebas
son de solo lectura en `pendiente_revision`.

---

## Riesgos

**Origen**: Ruta procesal y riesgos, U008.

**Requisito funcional**: El sistema debe permitir identificar riesgos
del caso con probabilidad, impacto, prioridad resultante, estrategia
de mitigación, estado de mitigación y plazo de acción.

**Módulo del sistema**: `CasesModule` — herramienta `risks`.

**Entidades de datos**: `riesgos`.

**Restricción vinculante**: R01 — los riesgos pertenecen al caso.
Mínimos de la herramienta pendientes de definición formal (ver
`CALIDAD_BASE.md` sección 1.3).

**Criterio de aceptación clave**: Un estudiante puede registrar riesgos
con todos sus atributos y actualizar su estado de mitigación. El informe
de matriz de riesgos requiere al menos un riesgo registrado.

---

## Estrategia

**Origen**: Tipicidad, Antijuridicidad, Culpabilidad y Estrategia de
defensa, U008. Ver `TRAZABILIDAD_U008.md` para la justificación de
la condensación en una sola herramienta.

**Requisito funcional**: El sistema debe permitir registrar el análisis
dogmático del tipo penal (tipicidad, antijuridicidad, culpabilidad),
la línea defensiva principal y las actuaciones procesales asociadas.
El campo `linea_principal` es obligatorio para enviar a revisión.

**Módulo del sistema**: `CasesModule` — herramientas `strategy` y `proceedings`.

**Entidades de datos**: `estrategia`, `actuaciones`.

**Restricción vinculante**: R01 — la estrategia pertenece al caso.
Campo `linea_principal` no nulo ni vacío como mínimo obligatorio (RN-HER-03).

**Criterio de aceptación clave**: Un estudiante puede completar el
análisis dogmático y la línea defensiva. El intento de enviar a revisión
sin `linea_principal` retorna `422`. Las actuaciones procesales pueden
añadirse con fecha y tipo.

---

## Explicación al cliente

**Origen**: Sin equivalente directo en U008 — herramienta funcional
propia del sistema. Ver `TRAZABILIDAD_U008.md`.

**Requisito funcional**: El sistema debe permitir registrar una explicación
del caso en lenguaje comprensible para el procesado — sin tecnicismos,
orientada a comunicar la situación jurídica y la estrategia adoptada.

**Módulo del sistema**: `CasesModule` — herramienta `client-briefing`.

**Entidades de datos**: `explicacion_cliente`.

**Restricción vinculante**: R01 — la explicación pertenece al caso.
Sin guarda obligatoria para envío a revisión — herramienta de diligenciamiento
recomendado, no bloqueante.

**Criterio de aceptación clave**: Un estudiante puede redactar y guardar
la explicación al cliente. La herramienta es editable en `en_analisis`
y de solo lectura en `pendiente_revision`.

---

## Checklist

**Origen**: Control metodológico vinculante — no corresponde a un capítulo
U008 sino al mecanismo de verificación de calidad del análisis.

**Requisito funcional**: El sistema debe generar automáticamente el
checklist al activar el caso (transición `borrador → en_analisis`),
permitir marcar ítems como cumplidos, calcular
el avance por bloque y bloquear transiciones cuando hay bloques críticos
incompletos.

**Módulo del sistema**: `ChecklistModule`.

**Entidades de datos**: `checklist_bloques`, `checklist_items`.

**Restricción vinculante**: R01, R02, R08. El campo `completado` del bloque
es calculado — no escribible directamente (RN-DAT-05).

**Criterio de aceptación clave**: El checklist se genera automáticamente
al activar el caso (`borrador → en_analisis`). Marcar todos los ítems de
un bloque crítico actualiza `completado` del bloque. El intento de
transición a `pendiente_revision` con bloque crítico incompleto retorna `422`.

---

## Conclusión

**Origen**: Síntesis operativa final, vinculada a la Estrategia de defensa
y al cierre analítico de U008.

**Requisito funcional**: El sistema debe permitir registrar la síntesis
ejecutiva del caso en cinco bloques estructurados: síntesis jurídica,
posición defensiva, recomendación estratégica, próximas actuaciones y
observaciones finales. El informe de conclusión operativa se genera desde
esta herramienta.

**Módulo del sistema**: `CasesModule` — herramienta `conclusion`.

**Entidades de datos**: `conclusion_operativa`.

**Restricción vinculante**: R01, R02, R03, R04. Los cinco bloques deben
estar diligenciados para generar el informe de conclusión (RN-CON-01).

**Criterio de aceptación clave**: Un estudiante puede completar los cinco
bloques de la conclusión. El intento de generar el informe con bloques
incompletos retorna `422`. El informe generado incluye los datos del
supervisor que aprobó el caso.
