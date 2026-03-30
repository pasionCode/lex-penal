# REGLA DE GOBIERNO DOCUMENTAL — LEX_PENAL

**Proyecto:** LEX_PENAL  
**Fecha de emisión:** 2026-03-30  
**Vigencia:** Permanente hasta modificación explícita

---

## 1. Propósito

Establecer la jerarquía documental del proyecto y la regla de resolución de tensiones entre visión sustantiva y ejecución técnica.

---

## 2. Jerarquía documental

```
┌─────────────────────────────────────────────────────────────┐
│  MANUAL GENERAL DE RESOLUCIÓN DE CASOS PENALES 2.0         │
│  Fuente sustantiva primaria                                │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  DOCUMENTO FUNDACIONAL DE ALCANCE Y OBJETIVOS              │
│  Formalización: para qué, qué, hasta dónde                 │
└─────────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┼───────────────┐
            ▼               ▼               ▼
┌───────────────────┐ ┌───────────────┐ ┌───────────────────┐
│  MDS              │ │ CONTRATO_API  │ │ NOTAS DE FASE     │
│  Cómo construir   │ │ Superficie    │ │ Cuándo y con qué  │
│                   │ │ funcional     │ │ evidencia         │
│                   │ │ vigente       │ │                   │
└───────────────────┘ └───────────────┘ └───────────────────┘
```

---

## 3. Función de cada documento

| Documento | Función | Pregunta que responde |
|-----------|---------|----------------------|
| **Manual General 2.0** | Fuente sustantiva primaria | ¿Qué método existe? ¿Con qué fundamento? |
| **Documento Fundacional** | Formalización y gobierno | ¿Para qué? ¿Qué? ¿Hasta dónde? ¿Qué es fidelidad? ¿Qué es desalineación? |
| **MDS** | Metodología de ejecución | ¿Cómo se construye? ¿Cómo se valida? ¿Cómo se cierra? |
| **Contrato API** | Superficie funcional vigente | ¿Qué endpoints existen? ¿Qué comportamiento tienen? |
| **Notas de fase/cierre** | Trazabilidad evolutiva | ¿Qué se hizo en cada fase? ¿Con qué evidencia? |

**Nota sobre Contrato API:** El Contrato API no narra historia del proyecto; documenta la superficie funcional vigente del sistema. Su función es descriptiva del estado actual, no narrativa de la evolución.

---

## 4. Regla de resolución de tensiones

### 4.1 Tensión visión vs ejecución

Cuando exista conflicto entre lo que el proyecto **debería hacer** (visión) y lo que el proyecto **está haciendo** (ejecución):

1. **La visión sustantiva se reconstruye desde:**
   - Manual General 2.0 (fuente primaria)
   - Documento Fundacional (formalización)

2. **La metodología de ejecución se rige por:**
   - MDS (fases, unidades, evidencia, cierre)

3. **La implementación se documenta en:**
   - Contrato API (superficie funcional vigente)
   - Notas de fase (trazabilidad)

### 4.2 Tensión fidelidad vs desalineación

El Documento Fundacional define en sus §14-15:

- **Criterio de fidelidad:** condiciones para considerar que el proyecto permanece alineado con su propuesta inicial
- **Criterio de desalineación:** eventos que constituyen desvío fundacional

Ante duda sobre si una decisión técnica es fiel o desalineada, se contrasta contra esos criterios.

### 4.3 Tensión prioridad

Cuando exista conflicto sobre **qué hacer primero**:

1. Consultar los **objetivos específicos** del Documento Fundacional (§7)
2. Priorizar lo que habilita **pruebas de realidad** (§16)
3. Diferir lo que es **extensión futura** (§10.4)

### 4.4 Escalamiento por tensión persistente

Si la tensión no puede resolverse por jerarquía documental, se debe emitir **ADR o nota formal de decisión** antes de ejecutar el cambio.

No se permite resolver discrepancias interpretativas por costumbre, impulso o decisión no documentada.

---

## 5. Actualizaciones

| Documento | Puede actualizarse | Requiere |
|-----------|-------------------|----------|
| Manual General | Sí (versión nueva) | Revisión del Documento Fundacional |
| Documento Fundacional | Sí | Ver §5.1 |
| MDS | Sí (versión nueva) | Comunicación explícita |
| Contrato API | Sí (con cada cambio funcional) | Commit + nota de cierre |
| Notas de fase | No (son históricas) | Ver §5.2 |

### 5.1 Actualización del Documento Fundacional

Toda modificación al Documento Fundacional requiere:

1. Justificación del cambio
2. Evaluación de impacto sobre MDS y Contrato API
3. Nota de consistencia o declaración de no afectación
4. Nueva versión del documento

### 5.2 Excepción para documentos históricos

Las notas de fase no se actualizan por ser históricas, **salvo corrección formal por fe de erratas o regularización documental**, preservando trazabilidad del cambio.

---

## 6. Aplicación

A partir de la emisión de esta regla:

1. Toda decisión de alcance se contrasta contra el Documento Fundacional
2. Toda decisión metodológica se contrasta contra el MDS
3. Todo cambio funcional se refleja en el Contrato API
4. Toda fase deja nota de cierre con evidencia
5. La fidelidad del proyecto se evalúa contra §14-15 del Documento Fundacional
6. **Toda apertura de fase o unidad que afecte alcance debe citar expresamente el Documento Fundacional**

---

## 7. Vigencia

Esta regla entra en vigor con su emisión y permanece vigente hasta modificación explícita documentada.

**Emitida el 2026-03-30.**
