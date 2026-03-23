# MATRIZ_VERIFICACION_MDS_LEX_PENAL

## 1. Objeto

La presente matriz tiene por objeto verificar el grado de cumplimiento de LEX_PENAL frente a la Metodología de Desarrollo de Software (MDS), distinguiendo entre:

- **avance material**: existencia real de artefactos, código, scaffold, manuales, auditorías o decisiones;
- **cierre formal**: evidencia trazable de que el entregable cumple el gate metodológico correspondiente.

La matriz no presume que ausencia de cierre formal equivalga a ausencia de trabajo.  
Su función es reconstruir con precisión la correspondencia entre el avance real del proyecto y las etapas de la MDS.

---

## 2. Convenciones de estado

### Estado material
- **CONFIRMADO**: existe evidencia ya reportada o validada.
- **PROBABLE**: hay indicios fuertes, pero falta contraste directo con el repositorio.
- **NO VERIFICADO**: no hay evidencia suficiente aún.
- **POR DEFINIR**: el artefacto no existe y debe crearse, no buscarse.
- **NO APLICA**: el artefacto no corresponde en esta fase o no es exigible todavía.

### Estado formal
- **CERRADO**: existe evidencia suficiente de cumplimiento metodológico y trazabilidad.
- **PARCIAL**: existe trabajo sustancial, pero no está formalizado como gate.
- **ABIERTO**: pendiente de cierre formal.
- **NO APLICA**: no corresponde todavía.

### Prioridad de acción
- **ALTA**: bloquea lectura correcta del estado del proyecto.
- **MEDIA**: importante para consolidación, pero no bloquea diagnóstico inicial.
- **BAJA**: puede diferirse.

---

## 3. Distinción conceptual: producto vs. artefacto MDS

Para evitar confusiones en la lectura de esta matriz, se establece la siguiente distinción:

| Concepto | Definición | Ejemplo en LEX_PENAL |
|---|---|---|
| **Producto** | Entregable final del proyecto destinado al usuario o al dominio sustantivo | Manual de ~62,000 palabras, módulos especiales, herramientas operativas |
| **Artefacto MDS** | Documento o evidencia que satisface un gate metodológico del desarrollo | Documento de visión, modelo de datos, contrato de API, backlog priorizado |

Un producto puede cumplir funciones de artefacto MDS (por ejemplo, el manual satisface E0-03 Análisis de dominio), pero no todo producto sustituye artefactos metodológicos (el manual no reemplaza E2-02 Historias de usuario ni E0-09 Criterios de éxito medibles).

La matriz evalúa artefactos MDS, no productos. Los productos se mencionan como evidencia de avance material cuando corresponde.

---

## 4. Resumen ejecutivo preliminar

**Lectura inicial de LEX_PENAL:**

- proyecto materialmente avanzado;
- documentación canónica consolidada;
- scaffold técnico ya generado;
- manual integrado de gran volumen ya construido;
- auditoría final ejecutada;
- existencia de ajustes pendientes que deben convertirse en backlog gobernado.

**Hipótesis rectora de la matriz:**

El problema principal no es falta de avance, sino falta de **correspondencia explícita** entre:
1. lo ya construido; y  
2. el cierre formal de los gates MDS.

**Activo concreto identificado:**

Los 11 ajustes pendientes de la auditoría final constituyen un insumo tangible y de alto valor para la regularización. Su conversión en backlog único priorizado es probablemente la acción de mayor rendimiento práctico inmediato.

---

## 5. Matriz de verificación

### Artefactos transversales

| ID | Artefacto / Gate MDS | Exigencia MDS | Evidencia actual en LEX_PENAL | Estado material | Estado formal | Acción requerida | Prioridad | Observaciones |
|---|---|---|---|---|---|---|---|---|
| TR-01 | Registro de decisiones | Toda decisión relevante debe quedar documentada | ADRs y decisiones arquitectónicas reportadas; documentación canónica consolidada | CONFIRMADO | PARCIAL | consolidar referencia única al registro vigente | ALTA | parece existir material suficiente, pero falta lectura unificada |
| TR-02 | Registro de riesgos y supuestos | Debe mantenerse vivo durante todo el proyecto | no confirmado con nombre exacto de archivo | NO VERIFICADO | ABIERTO | validar existencia; crear o completar si no existe | ALTA | clave para auditar supuestos ya materializados |

### Etapa 0: Definición

| ID | Artefacto / Gate MDS | Exigencia MDS | Evidencia actual en LEX_PENAL | Estado material | Estado formal | Acción requerida | Prioridad | Observaciones |
|---|---|---|---|---|---|---|---|---|
| E0-01 | Documento de visión | visión del problema, usuario, valor, MVP | visión penal y manual troncal reportados | CONFIRMADO | PARCIAL | vincular el documento exacto que cumple esta función | ALTA | no parece faltar contenido; falta trazabilidad |
| E0-02 | Alcance y exclusiones | incluido, excluido, fuera de alcance, supuestos, dependencias | probable dentro de documentos canónicos consolidados | PROBABLE | PARCIAL | identificar archivo exacto y verificar exclusiones explícitas | ALTA | suele existir alcance implícito, no siempre exclusión explícita |
| E0-03 | Análisis de dominio | entidades, flujo, decisiones, variantes, sistema más amplio | manual de ~62,000 palabras + tronco común + módulos especiales | CONFIRMADO | PARCIAL | extraer referencia puntual al análisis de dominio canónico | ALTA | el manual es producto, pero cumple función de análisis de dominio |
| E0-04 | Matriz de variabilidad | obligatoria si aplica; evaluar variantes y modularización | módulos especiales y reflexión sobre dominio amplio reportados | CONFIRMADO | PARCIAL | formalizar la matriz como artefacto autónomo o identificar dónde vive | ALTA | punto crítico de la lección retroactiva de LEX_PENAL |
| E0-05 | Decisión monolito vs núcleo+módulos | debe quedar explícita | existe debate y maduración estratégica sobre modularización | CONFIRMADO | PARCIAL | documentar decisión vigente y estado de la decisión | ALTA | no basta con que la decisión haya sido conversada |
| E0-06 | Decisiones de arquitectura base | backend, frontend, BD, despliegue, auth | documentos canónicos como MODELO_DATOS_v3, CONTRATO_API_v4 y otros reportados | CONFIRMADO | PARCIAL | consolidar mapa de decisiones base en un solo punto de control | ALTA | materialmente fuerte |
| E0-07 | Flujo crítico identificado | secuencia mínima de valor | existe flujo sustancial del sistema y manual integrado | PROBABLE | PARCIAL | explicitar flujo crítico canónico en un documento rector | ALTA | probablemente existe de hecho, no necesariamente en forma canónica |
| E0-08 | Requisitos no funcionales | seguridad, privacidad, rendimiento, auditoría, backup, legal | auditoría final y enfoque jurídico sugieren tratamiento parcial | PROBABLE | ABIERTO | verificar si están explicitados; completar donde falte | ALTA | aquí suele haber dispersión |
| E0-09 | Criterios de éxito medibles | métricas de éxito del MVP | no existen; deben definirse | POR DEFINIR | ABIERTO | **crear métricas explícitas** (no buscar) | ALTA | vacío real, no problema de trazabilidad |
| E0-10 | Checklist de cierre Etapa 0 | no avanzar sin checklist completo | no se ha reportado acta formal de cierre | NO VERIFICADO | ABIERTO | emitir decisión formal de cierre / complemento / reapertura parcial | ALTA | núcleo de la regularización |

### Etapa 1: Validación técnica

| ID | Artefacto / Gate MDS | Exigencia MDS | Evidencia actual en LEX_PENAL | Estado material | Estado formal | Acción requerida | Prioridad | Observaciones |
|---|---|---|---|---|---|---|---|---|
| E1-01 | PoC del componente más riesgoso | validar el riesgo técnico mayor | scaffold técnico generado; 131 archivos; auditoría de ajustes | CONFIRMADO | PARCIAL | identificar cuál PoC o validación equivalente cumplió esta función | ALTA | el trabajo pudo haber absorbido la Etapa 1 sin nombrarla así |
| E1-02 | Validación de integraciones externas | APIs, servicios, BD | CONTRATO_API_v4 y scaffold sugieren validación material parcial | PROBABLE | PARCIAL | verificar pruebas o notas técnicas de integración | MEDIA | puede vivir en backend/informes |
| E1-03 | Restricciones del entorno real | despliegue, costos, seguridad, red | auditoría final sugiere entorno de prueba o revisión | PROBABLE | PARCIAL | ubicar documento que consolidó restricciones reales | ALTA | importante para saber si Etapa 1 está absorbida o incompleta |
| E1-04 | Stack confirmado como viable | decisión continuar / pivotar / cancelar | avance material del proyecto indica continuidad de hecho | CONFIRMADO | ABIERTO | formalizar decisión retrospectiva de continuidad | MEDIA | hay continuidad material sin cierre expreso |

### Etapa 2: Diseño y planificación

| ID | Artefacto / Gate MDS | Exigencia MDS | Evidencia actual en LEX_PENAL | Estado material | Estado formal | Acción requerida | Prioridad | Observaciones |
|---|---|---|---|---|---|---|---|---|
| E2-01 | Épicas definidas | agrupación de funcionalidad | manual troncal + módulos especiales + docs canónicos | CONFIRMADO | PARCIAL | identificar documento exacto de épicas o mapa funcional | MEDIA | muy probablemente satisfecho materialmente |
| E2-02 | Historias de usuario con criterios | historias concretas del backlog | no reportadas expresamente | NO VERIFICADO | ABIERTO | verificar si existen en backlog o informes | MEDIA | el manual (producto) no sustituye este artefacto |
| E2-03 | Backlog priorizado | prioridades P1/P2/P3 y sprint | auditoría con 11 ajustes pendientes indica backlog parcial | CONFIRMADO | PARCIAL | **convertir los 11 ajustes en backlog único priorizado** | ALTA | acción de alto valor práctico inmediato |
| E2-04 | Modelo de datos documentado | diseño de entidades y relaciones | MODELO_DATOS_v3 reportado | CONFIRMADO | PARCIAL | enlazar documento canónico y verificar si cumple versión vigente | ALTA | artefacto fuerte del proyecto |
| E2-05 | Contrato de API documentado | endpoints y respuestas | CONTRATO_API_v4 reportado | CONFIRMADO | PARCIAL | enlazar documento canónico y validar vigencia | ALTA | artefacto fuerte del proyecto |
| E2-06 | Definition of Done | criterio compartido de "terminado" | no reportada expresamente | NO VERIFICADO | ABIERTO | definirla o localizarla | MEDIA | puede estar implícita, pero debe quedar explícita |
| E2-07 | Sprint 1 solo flujo crítico | planificación inicial del MVP | no reportado con ese nombre | NO VERIFICADO | ABIERTO | reconstruir si existió de hecho | BAJA | menos crítico que backlog y modelo |

### Etapa 3: Implementación

| ID | Artefacto / Gate MDS | Exigencia MDS | Evidencia actual en LEX_PENAL | Estado material | Estado formal | Acción requerida | Prioridad | Observaciones |
|---|---|---|---|---|---|---|---|---|
| E3-01 | Flujo crítico end-to-end funcionando | MVP del flujo mínimo | 131 archivos de scaffold generados sugieren construcción relevante, pero no prueban E2E | PROBABLE | ABIERTO | validar demo, staging o recorrido funcional real | ALTA | clave para determinar si ya se tocó Etapa 3 o no |
| E3-02 | Despliegue en ambiente accesible | staging o dev accesible | auditoría final sugiere entorno de prueba o revisión | PROBABLE | ABIERTO | confirmar entorno real y evidencia | MEDIA | puede estar en informes |
| E3-03 | Usuario interno puede probarlo | al menos un probador interno | auditoría final y revisión sugieren prueba interna | PROBABLE | ABIERTO | dejar constancia explícita | MEDIA | evidencia posiblemente dispersa |
| E3-04 | Bugs bloqueantes resueltos | gate mínimo de calidad | auditoría final con 11 ajustes pendientes indica no cierre pleno | CONFIRMADO | ABIERTO | clasificar los 11 ajustes por severidad | ALTA | muy útil para decisión de etapa |
| E3-05 | DoD cumplida para flujo crítico | historias terminadas conforme a DoD | no verificable sin DoD explícita | NO VERIFICADO | ABIERTO | depende de E2-06 | MEDIA | arrastra vacío formal anterior |

### Etapa 3.5: Ajuste de realidad (CRÍTICA)

> **Nota importante:** Esta etapa no debe confundirse con la auditoría técnica. La auditoría final ejecutada en LEX_PENAL fue una revisión técnica interna. La Etapa 3.5 exige testing con usuario real o semirreal y feedback sobre comprensión, flujo y lenguaje. Son ejercicios distintos.

| ID | Artefacto / Gate MDS | Exigencia MDS | Evidencia actual en LEX_PENAL | Estado material | Estado formal | Acción requerida | Prioridad | Observaciones |
|---|---|---|---|---|---|---|---|---|
| E3.5-01 | Sesiones de testing / feedback semirreal | identificar patrones de fricción | auditoría final ejecutada ≠ testing de usuario | NO VERIFICADO | ABIERTO | **distinguir auditoría técnica de ajuste de realidad con usuario** | ALTA | posible faltante real |
| E3.5-02 | Informe de Ajuste de Realidad | hallazgos de comprensión, flujo, lenguaje | no reportado expresamente | NO VERIFICADO | ABIERTO | crear o identificar si existe con otro nombre | ALTA | posible faltante real |
| E3.5-03 | Backlog actualizado con hallazgos | cambios tras feedback | 11 ajustes pendientes = insumo parcial | CONFIRMADO | PARCIAL | **convertir ajustes en backlog metodológico** | ALTA | conexión inmediata con la auditoría |

### Etapa 4: Revisión arquitectónica

| ID | Artefacto / Gate MDS | Exigencia MDS | Evidencia actual en LEX_PENAL | Estado material | Estado formal | Acción requerida | Prioridad | Observaciones |
|---|---|---|---|---|---|---|---|---|
| E4-01 | Decisión arquitectónica con evidencia real | incluso "sin cambios" | auditoría final ejecutada y decisiones previas reportadas | PROBABLE | ABIERTO | formalizar decisión post-auditoría | ALTA | puede cerrar mucho del estado actual |
| E4-02 | ADRs actualizados o confirmados | mantener arquitectura trazable | ADRs reportados | CONFIRMADO | PARCIAL | verificar actualización post-auditoría | MEDIA | probablemente casi resuelto |
| E4-03 | Deuda técnica priorizada | lista con prioridad | auditoría final con 11 ajustes pendientes | CONFIRMADO | PARCIAL | **clasificar los 11 ajustes por severidad, impacto y etapa** | ALTA | pieza operativa inmediata |
| E4-04 | Plan claro: consolidar / refactorizar / expandir | decisión de rumbo | aún no consolidado formalmente | NO VERIFICADO | ABIERTO | emitir decisión de gobernanza | ALTA | este documento debe salir de la matriz |

### Etapa 5: Consolidación

| ID | Artefacto / Gate MDS | Exigencia MDS | Evidencia actual en LEX_PENAL | Estado material | Estado formal | Acción requerida | Prioridad | Observaciones |
|---|---|---|---|---|---|---|---|---|
| E5-01 | MVP estable en producción | estabilidad operativa | no reportado | NO VERIFICADO | NO APLICA | no afirmar aún | MEDIA | no conviene presumir producción |
| E5-02 | Cobertura suficiente del flujo crítico | tests confiables | no reportado | NO VERIFICADO | NO APLICA | levantar evidencia real | MEDIA | pendiente total por ahora |
| E5-03 | Documentación técnica completa | arquitectura, API, modelo, config | documentos canónicos consolidados + manual + auditoría | CONFIRMADO | PARCIAL | verificar completitud frente al checklist | MEDIA | muy avanzado materialmente |
| E5-04 | Deuda técnica bajo control | no necesariamente cero | 11 ajustes pendientes indican control no consolidado | CONFIRMADO | ABIERTO | ordenar backlog técnico | ALTA | aún no controlado formalmente |
| E5-05 | Proceso de expansión definido | crecimiento sin romper núcleo | discusión metodológica sobre modularización ya iniciada | PROBABLE | ABIERTO | documentar estrategia de expansión | MEDIA | conecta con visión de familia de productos |
| E5-06 | Registro de decisiones completo | decisiones actualizadas | parece avanzado, no validado integralmente | PROBABLE | PARCIAL | cierre por barrido final | MEDIA | depende de TR-01 |

---

## 6. Lectura preliminar por etapa

| Etapa | Estado preliminar |
|---|---|
| Transversal | existe base relevante, pero falta consolidación formal |
| Etapa 0 | materialmente muy avanzada; cierre formal pendiente; E0-09 es vacío real |
| Etapa 1 | probablemente absorbida en la práctica; falta reconstrucción canónica |
| Etapa 2 | fuerte evidencia material de cumplimiento parcial o sustancial |
| Etapa 3 | hay indicios de construcción relevante, pero falta probar E2E y ambiente accesible |
| Etapa 3.5 | **no debe confundirse auditoría técnica con ajuste de realidad; posibles faltantes reales** |
| Etapa 4 | hay insumos claros para abrirla o formalizarla |
| Etapa 5 | aún no debe presumirse cerrada |

---

## 7. Nudos críticos inmediatos

1. **Confirmar artefactos exactos que cumplen Etapa 0.**
2. **Crear E0-09 (criterios de éxito medibles)** — es vacío real, no dispersión.
3. **Ubicar evidencia canónica de validación técnica equivalente a Etapa 1.**
4. **Convertir los 11 ajustes pendientes en backlog único priorizado** — acción de mayor rendimiento inmediato.
5. **Separar claramente auditoría técnica de testing de usuario / ajuste de realidad.**
6. **Emitir una decisión formal sobre el estado real alcanzado:**
   - consolidar Etapa 0 y 1;
   - declarar Etapa 2 sustancialmente satisfecha;
   - o reconocer que ciertas piezas siguen abiertas.

---

## 8. Decisión operativa sugerida

Con la información disponible, la decisión prudente no es "reabrir todo", sino:

**Hacer barrido de verificación documental sobre artefactos exactos del repositorio y luego emitir un acta de estado metodológico real de LEX_PENAL.**

### Responsable del barrido

El barrido documental requiere acceso al repositorio real del proyecto. Opciones:

1. Si el repositorio es accesible para revisión automatizada o guiada, puede ejecutarse con asistencia técnica.
2. Si el repositorio no es accesible directamente, el responsable del proyecto deberá proveer el inventario de artefactos o facilitar acceso.

El barrido debe producir como salida una **actualización de esta matriz** con estado material verificado (no probable) y enlaces a los documentos exactos que cumplen cada gate.

---

## 9. Control de cambios

**Versión:** 0.2  
**Estado:** Borrador operativo  
**Naturaleza:** Matriz de verificación metodológica  
**Proyecto aplicable:** LEX_PENAL

### Historial
- **v0.1**: creación del borrador inicial de la matriz.
- **v0.2**: incorporación de correcciones:
  - añadida sección 3 (distinción producto vs. artefacto MDS);
  - añadido estado material "POR DEFINIR" para artefactos inexistentes que deben crearse;
  - reclasificado E0-09 como "POR DEFINIR" (vacío real, no problema de trazabilidad);
  - añadida nota crítica en Etapa 3.5 distinguiendo auditoría técnica de ajuste de realidad;
  - destacado los 11 ajustes pendientes como activo concreto de alto valor;
  - añadida sección sobre responsable del barrido;
  - reorganizada la matriz en subsecciones por etapa para mejor legibilidad.
