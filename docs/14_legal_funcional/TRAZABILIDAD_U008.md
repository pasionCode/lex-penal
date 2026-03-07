# Trazabilidad U008 — Correspondencia metodológica

| Campo | Valor |
|---|---|
| Versión | 1.0 |
| Fecha | 2026-03-06 |
| Estado | Vigente |
| Documentos relacionados | `docs/00_gobierno/ALCANCE_PROYECTO.md`, `docs/03_datos/REGLAS_NEGOCIO.md`, `docs/01_producto/ESTADOS_DEL_CASO.md` |

---

## Propósito

Este documento establece la correspondencia formal entre las ocho
herramientas operativas del sistema LexPenal y los bloques metodológicos
de la Unidad 8 (U008) del programa académico.

Las herramientas del sistema no replican los capítulos de la U008 de
forma literal — los traducen en unidades operativas optimizadas para
el flujo de trabajo del consultorio jurídico. Algunos bloques U008
están condensados en una sola herramienta del sistema; otros están
desagregados o reconfigurados por utilidad práctica.

Esta distinción es intencional y estructural. La nomenclatura oficial
del sistema es la lista operativa. La U008 es el marco metodológico
de referencia, no la nomenclatura del aplicativo.

---

## Regla de gobierno

> Ninguna herramienta del sistema puede eliminarse sin una decisión
> formal documentada en este archivo y en el ADR correspondiente
> (RN-HER-05). Cualquier cambio en la plantilla académica de la U008
> que afecte al sistema debe gestionarse como un cambio formal de producto.

---

## Matriz de correspondencia

| # | Herramienta del sistema | Contenido U008 correspondiente | Observaciones |
|---|---|---|---|
| 1 | **Ficha** | Ficha básica del caso | Correspondencia directa. Recoge datos de identificación: radicado, procesado, delito imputado, etapa procesal, situación de libertad. |
| 2 | **Hechos** | Lectura jurídica de los hechos + parte de Problema jurídico e hipótesis de imputación | La herramienta condensa la narración fáctica y la calificación jurídica inicial. El análisis del problema jurídico en sentido estricto se desarrolla en Estrategia. |
| 3 | **Pruebas** | Matriz probatoria | Correspondencia directa. Registra las pruebas del caso con su relación con los hechos, su valor probatorio y su estado procesal. |
| 4 | **Riesgos** | Ruta procesal y riesgos | Correspondencia directa. Incluye identificación de riesgos, probabilidad, impacto y estrategia de mitigación. La ruta procesal se referencia como contexto de los riesgos. |
| 5 | **Estrategia** | Tipicidad + Antijuridicidad + Culpabilidad + Estrategia de defensa | Esta herramienta es la de mayor densidad dogmática. Absorbe el análisis del tipo penal, las causales de exclusión de responsabilidad y la línea defensiva principal. En U008 estos aparecen como capítulos separados; en el sistema se integran en una sola herramienta porque el análisis dogmático informa directamente la estrategia. |
| 6 | **Explicación al cliente** | Sin equivalente directo en U008 | Herramienta funcional propia del sistema. Traduce el análisis jurídico en lenguaje comprensible para el procesado. Es una pieza de producto sin referente académico rígido, pero con alta utilidad operativa y pedagógica en la formación de habilidades de comunicación jurídica. |
| 7 | **Checklist** | Control metodológico vinculante | No corresponde a un capítulo U008, sino a la verificación de que el análisis cumple los estándares metodológicos de la unidad. Es una compuerta funcional del sistema: bloquea transiciones cuando hay incumplimientos en bloques críticos. |
| 8 | **Conclusión** | Síntesis operativa final | Vinculada a Estrategia de defensa y cierre analítico de U008. En el sistema opera como herramienta independiente para separar el análisis (Estrategia) de la síntesis ejecutiva entregable (Conclusión). Esta separación facilita la generación del informe de conclusión operativa. |

---

## Herramientas sin equivalente directo en U008

| Herramienta | Naturaleza |
|---|---|
| **Explicación al cliente** | Herramienta funcional de producto — desarrolla habilidades de comunicación jurídica no explicitadas como capítulo en U008 |
| **Checklist** | Mecanismo de control de calidad metodológico — opera como compuerta del flujo, no como análisis |

Estas herramientas son parte integral del sistema y no pueden
eliminarse sin decisión formal, aunque no tengan equivalente
académico directo en U008.

---

## Herramientas U008 distribuidas entre varias herramientas del sistema

| Bloque U008 | Se distribuye en |
|---|---|
| Lectura jurídica de los hechos | Hechos (narrativa fáctica) + Estrategia (calificación jurídica) |
| Problema jurídico e hipótesis de imputación | Hechos (hipótesis inicial) + Estrategia (desarrollo dogmático) |
| Tipicidad | Estrategia |
| Antijuridicidad | Estrategia |
| Culpabilidad | Estrategia |
| Estrategia de defensa | Estrategia + Conclusión |

---

## Historial de cambios

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 2026-03-06 | Versión inicial — correspondencia establecida al cierre del diseño del MVP |
