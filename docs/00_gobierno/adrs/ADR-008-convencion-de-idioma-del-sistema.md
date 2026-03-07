# ADR-008 — Convención de idioma del sistema

| Campo | Valor |
|---|---|
| Estado | **Cerrado** |
| Fecha | 2026-03-06 |
| Decisor | Equipo técnico LexPenal |
| Documentos relacionados | `docs/04_api/CONTRATO_API.md`, `docs/03_datos/MODELO_DATOS.md`, `docs/03_datos/REGLAS_NEGOCIO.md`, `docs/00_gobierno/MAPA_REPOSITORIO.md` |

---

## Contexto

LexPenal opera en un dominio jurídico colombiano con terminología
técnica en español: radicado, expediente, tipicidad, antijuridicidad,
dosimetría, subrogados. Al mismo tiempo, su arquitectura técnica usa
convenciones internacionales donde el inglés es estándar: REST,
HTTP, ORM, patrones de diseño, ecosistema Node.js/NestJS/Next.js.

Durante la producción de los primeros documentos de arquitectura surgió
una mezcla no declarada: la API usa `cases`, `reports`, `review`,
`audit`; las tablas usan `casos`, `informes_generados`, `eventos_auditoria`;
la documentación usa términos jurídicos en español. Esa mezcla existe
en el sistema actual y es, en parte, correcta — pero nunca fue una
decisión explícita.

Este ADR la convierte en convención deliberada, define el alcance de
cada idioma y fija criterios para decisiones futuras de naming.

---

## Opciones evaluadas

### Opción A — Sistema completamente en inglés

Todo el sistema — API, tablas, documentación, UI, reglas de negocio —
adopta inglés como idioma único.

**Ventajas**
- Consistencia total de idioma en todas las capas.
- Facilita incorporación de colaboradores externos no hispanohablantes.
- Alineación con el ecosistema técnico predominante.

**Desventajas**
- El dominio jurídico colombiano no tiene traducción natural ni precisa
  al inglés: *radicado*, *subrogados*, *dosimetría*, *antijuridicidad*
  no tienen equivalentes técnicos en inglés sin pérdida de precisión.
- Traducir conceptos jurídicos introduce ambigüedad que puede tener
  consecuencias reales en la interpretación de reglas de negocio.
- La documentación interna y la UI serían incomprensibles para los
  operadores reales del sistema — estudiantes y abogados colombianos.

---

### Opción B — Sistema completamente en español

Todo el sistema — incluyendo API REST, endpoints, parámetros HTTP —
adopta español.

**Ventajas**
- Coherencia total con el dominio y los usuarios finales.

**Desventajas**
- Rompe convenciones REST internacionales — endpoints en español son
  inusuales y pueden generar fricción en integraciones futuras.
- El ecosistema técnico (librerías, ORM, frameworks) espera naming
  en inglés para sus propias convenciones — mezclar idiomas a ese nivel
  genera inconsistencias difíciles de mantener.
- Dificulta la incorporación de herramientas de generación de código,
  documentación automática y clientes de API.

---

### Opción C — Separación deliberada por capa (bilingüismo estructurado)

Cada capa del sistema adopta el idioma que mejor sirve a su función:

- **API REST pública**: inglés, siguiendo convenciones REST internacionales.
- **Modelo de datos / tablas**: español, porque los nombres reflejan
  conceptos del dominio jurídico que deben ser precisos y legibles
  por el equipo del despacho.
- **Documentación técnica interna**: español, porque los lectores son
  el equipo técnico del proyecto y los operadores del sistema.
- **Reglas de negocio y códigos de regla** (RN-EST-01, RN-IA-02...):
  español, porque corresponden al dominio.
- **Interfaz de usuario**: español, porque los usuarios son
  estudiantes y abogados colombianos.
- **Naming técnico de código** (clases, servicios, métodos internos):
  inglés, siguiendo las convenciones del ecosistema NestJS/Next.js/TypeScript.

**Ventajas**
- Cada idioma opera donde tiene ventaja real.
- La API es interoperable y convencional internacionalmente.
- El dominio jurídico conserva su precisión terminológica en español.
- La documentación y la UI son accesibles para los operadores reales.
- Convierte la situación actual del sistema en una decisión deliberada
  y documentada, no en una inconsistencia acumulada.

**Desventajas**
- Requiere criterio explícito para decisiones de naming en zonas
  limítrofes (ej. nombres de campos en responses JSON, nombres de
  columnas en tablas, nombres de DTOs).
- El equipo debe internalizar la convención para aplicarla
  consistentemente.

---

## Criterios de decisión

| Criterio | Solo inglés | Solo español | Bilingüismo estructurado |
|---|---|---|---|
| Precisión del dominio jurídico | Baja | Alta | Alta |
| Interoperabilidad API | Alta | Baja | Alta |
| Accesibilidad para operadores | Baja | Alta | Alta |
| Consistencia interna | Alta | Alta | Requiere disciplina |
| Alineación con ecosistema técnico | Alta | Baja | Alta |
| Adecuación al sistema actual | No | No | Sí |

---

## Decisión

> **[x] Opción C — Separación deliberada por capa (bilingüismo estructurado)**

**Justificación**: La API REST pública adopta inglés porque es la
capa de interoperabilidad del sistema — debe seguir convenciones
internacionales. El dominio jurídico colombiano adopta español porque
sus conceptos no tienen traducción técnica precisa y sus operadores
son hispanohablantes. Esta separación no es una anomalía: es una
decisión arquitectónica que reconoce que el sistema sirve a dos
audiencias con necesidades de idioma distintas — la comunidad técnica
internacional y el despacho jurídico colombiano.

---

## Convención por capa

### API REST — inglés

Recursos, endpoints, parámetros HTTP y campos de response JSON
siguen convención inglesa:

```
/api/v1/cases
/api/v1/cases/{id}/reports
/api/v1/cases/{id}/review
/api/v1/cases/{id}/audit
/api/v1/ai/query
/api/v1/users
/api/v1/clients
```

Los campos de los cuerpos JSON también van en inglés:
`caseId`, `reportType`, `status`, `createdAt`, `userId`.

**Excepción permitida, restringida y documentada caso a caso**:
valores de enumeraciones que representen conceptos jurídicos sin
traducción técnica precisa pueden mantenerse en español si su
traducción introduce ambigüedad demostrable. Cada excepción debe
justificarse explícitamente y registrarse en `CONTRATO_API.md`.
La acumulación silenciosa de excepciones erosiona la convención —
toda excepción no documentada se considera una inconsistencia.

---

### Modelo de datos / tablas — español

Los nombres de tablas y columnas reflejan el dominio:

```sql
casos, usuarios, clientes
eventos_auditoria, informes_generados
ai_request_log  ← excepción técnica aceptada (ver abajo)
radicado, tipicidad, antijuridicidad
```

**Excepción aceptada**: `ai_request_log` conserva nombre mixto
por ser un término técnico del módulo de IA sin equivalente
natural en español que no resulte forzado. Las excepciones
técnicas en el modelo de datos deben ser mínimas y justificadas
por uso real del ecosistema — no por preferencia de naming.

---

### Código fuente — inglés

Clases, servicios, módulos, métodos, variables y DTOs siguen
convención inglesa del ecosistema NestJS/TypeScript:

```typescript
CasesController, ReportsService, IAOrchestrator
CreateCaseDto, UpdateCaseDto
findById(), generateReport()
```

Los comentarios y documentación inline del código pueden ser
en español si el equipo lo prefiere.

---

### Documentación técnica — español

Todos los documentos del repositorio (`docs/`) se redactan en español:
ADRs, arquitectura, reglas de negocio, catálogos, guías de despliegue.

---

### Reglas de negocio y códigos — español

Los identificadores de reglas usan prefijos en español que reflejan
el subsistema: `RN-EST`, `RN-IA`, `RN-INF`, `RN-AUD`, `RN-UNI`.

---

### Interfaz de usuario — español

Todos los textos visibles al usuario final van en español.
Los nombres de estado del caso (`borrador`, `en_analisis`,
`pendiente_revision`) se muestran en español en la UI.

---

## Consecuencias

- `CONTRATO_API.md` se redacta en español como documento pero
  los recursos y campos que define usan inglés — es la excepción
  documentada donde conviven los dos idiomas en el mismo archivo.
- Toda decisión futura de naming debe aplicar esta convención.
  En caso de duda, la pregunta es: ¿es una capa de interoperabilidad
  técnica (inglés) o una capa de dominio/operación (español)?
- Las excepciones permitidas deben ser explícitas y documentadas —
  no acumuladas silenciosamente.
- `MAPA_REPOSITORIO.md` referencia este ADR para la convención
  de idioma. No duplica la decisión.
- Los nuevos miembros del equipo deben revisar este ADR antes de
  crear entidades, tablas, endpoints o documentos nuevos.
