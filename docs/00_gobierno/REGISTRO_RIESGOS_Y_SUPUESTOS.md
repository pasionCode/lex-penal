\# REGISTRO DE RIESGOS Y SUPUESTOS



\*\*Proyecto:\*\* LEX\_PENAL  

\*\*Estado:\*\* ABIERTO  

\*\*Fecha de apertura:\*\* 2026-03-22



\---



\## 1. Riesgos



| ID | Riesgo | Impacto | Probabilidad | Mitigación | Estado |

|----|--------|---------|--------------|------------|--------|

| R-001 | Desalineación entre conducción y repo real | Alto | Media | Actualización obligatoria al cierre de jornada | Abierto |

| R-002 | Cierre de jornadas con deuda técnica no regularizada | Alto | Media | Registro formal de desviaciones | Abierto |

| R-003 | Contrato API inconsistente con implementación | Alto | Media | ADR-009 + revisión de controllers + smoke tests | Abierto |

| R-004 | Interpretación laxa del concepto scaffold | Alto | Media | Aclaración expresa en MDS | Abierto |



\---



\## 2. Supuestos



| ID | Supuesto | Impacto si falla | Acción de validación | Estado |

|----|----------|------------------|----------------------|--------|

| S-001 | El prefijo global será la única fuente de versionado de rutas | Alto | Revisar todos los controllers | Pendiente |

| S-002 | GATE-01 y GATE-02 pueden regularizarse ex post sin afectar trazabilidad | Medio | Formalizar actas y dejar constancia | En validación |

| S-003 | La conducción será actualizada en cada cierre relevante | Alto | Incorporar checklist de cierre | Pendiente |



\---



\## 3. Regla de mantenimiento



Este registro deberá actualizarse:

\- al cierre de cada jornada;

\- al cierre de cada gate;

\- y cada vez que se registre una desviación.

