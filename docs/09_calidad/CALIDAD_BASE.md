# Calidad base — LexPenal MVP

| Campo | Valor |
|---|---|
| Versión | 1.0 |
| Fecha | 2026-03-06 |
| Estado | Vigente |
| Documentos relacionados | `docs/03_datos/REGLAS_NEGOCIO.md`, `docs/06_backend/ARQUITECTURA_BACKEND.md`, `docs/01_producto/ESTADOS_DEL_CASO.md`, `docs/01_producto/CATALOGO_INFORMES.md` |

---

## Alcance

Este documento define la estrategia de calidad del MVP de LexPenal
en dos dimensiones:

1. **Calidad del producto jurídico** — cómo el sistema garantiza que
   el análisis del expediente cumple los estándares metodológicos
   de la Unidad 8 antes de avanzar en el flujo.

2. **Calidad del software** — cómo el equipo técnico verifica que el
   sistema se comporta correctamente: pruebas, manejo de errores,
   criterios de aceptación técnica.

Ambas dimensiones son parte del mismo sistema de calidad — no son
independientes. La calidad del software es condición necesaria para
garantizar la calidad del producto jurídico.

---

## Parte I — Calidad del producto jurídico

### 1.1 El checklist como compuerta funcional

El checklist de control de calidad es el mecanismo principal de
garantía de calidad metodológica del sistema. No es un elemento
opcional de seguimiento — es una compuerta funcional vinculante
que bloquea transiciones del caso cuando hay incumplimientos
críticos (RN-CHK-01).

**Comportamiento por tipo de bloque**

| Tipo de bloque | Efecto si incompleto |
|---|---|
| Bloque crítico | Bloquea la transición correspondiente. El sistema rechaza el avance con `422` — la transición existe pero falla una guarda de negocio. |
| Bloque no crítico | No bloquea la transición. Se registra como advertencia visible al estudiante. |

**Transiciones bloqueadas por checklist incompleto**

| Transición | Condición del checklist |
|---|---|
| `en_analisis → pendiente_revision` | No debe haber bloques críticos incompletos (RN-CHK-01) |
| `aprobado_supervisor → listo_para_cliente` | No debe haber bloques críticos incompletos (RN-CHK-02) |
| Generación de `conclusion_operativa` | No debe haber bloques críticos incompletos (RN-INF-03, RN-CON-04) |

### 1.2 Reglas del checklist

**RN-CHK-01** — El checklist es una compuerta funcional vinculante.
El backend verifica el estado del checklist antes de ejecutar las
transiciones que lo requieren. El frontend no puede saltarse esta
verificación.

**RN-CHK-03** — El campo `completado` del bloque checklist es calculado
por el backend a partir del estado de los ítems del bloque.
No puede escribirse directamente — cualquier escritura directa es
rechazada (RN-DAT-05).

**RN-CHK-04** — Un bloque aparentemente irrelevante debe documentarse,
no ignorarse. Si un bloque no aplica al caso concreto, el estudiante
debe marcarlo como no aplicable con justificación. No se omite en
silencio.

**RN-CHK-05** — El porcentaje de avance del checklist es visible en
el dashboard del caso en todo momento, independientemente del estado.

### 1.3 Calidad de las herramientas del expediente

Las reglas de guardia de las herramientas actúan como mínimos de
calidad del análisis jurídico:

| Herramienta | Mínimo requerido para enviar a revisión |
|---|---|
| Hechos | Al menos un hecho registrado (RN-HER-02) |
| Estrategia | Campo `linea_principal` no nulo ni vacío (RN-HER-03) |
| Conclusión | Cinco bloques de la conclusión operativa diligenciados (RN-CON-01) |
| Pruebas | Sin mínimo formal cerrado en MVP — se define al implementar |
| Riesgos | Sin mínimo formal cerrado en MVP — se define al implementar |
| Explicación al cliente | Sin mínimo formal cerrado en MVP — herramienta sin guarda obligatoria |
| Checklist | Sin bloques críticos incompletos (RN-CHK-01) — verificado por el sistema |

Los mínimos de Pruebas, Riesgos y Explicación al cliente deben
formalizarse antes de la implementación de sus respectivos servicios.

Estos mínimos no garantizan calidad jurídica — son condiciones
necesarias, no suficientes. La evaluación de la calidad del análisis
es responsabilidad del supervisor.

### 1.4 Rol del supervisor como control de calidad humano

El supervisor es la compuerta de calidad humana del sistema. Las
reglas del sistema (checklist, guardias) son controles formales
automatizados. La calidad del razonamiento jurídico la evalúa
el supervisor.

**Reglas que sostienen este rol**

- Las observaciones del supervisor son obligatorias en toda revisión —
  una revisión sin fundamento escrito no es válida (RN-REV-03).
- El supervisor no puede aprobar un caso con checklist incompleto
  en bloques críticos, aunque quiera hacerlo — el sistema lo bloquea.
- La revisión del supervisor es versionada e inmutable — no reemplaza,
  acumula (RN-REV-04).

---

## Parte II — Calidad del software

### 2.1 Principios de pruebas

**Las pruebas no son opcionales.** Cada servicio nombrado del backend
tiene pruebas unitarias. Las operaciones críticas del flujo del caso
tienen pruebas de integración.

**Los entornos de staging y pruebas usan datos ficticios o anonimizados.**
LexPenal gestiona expedientes de defensa penal con datos personales
sensibles. Ningún dato real de un procesado debe usarse en entornos
de desarrollo, staging ni pruebas automatizadas. Los fixtures y
seeds de prueba deben construirse con datos generados ficticiamente.

**Los servicios son la unidad de prueba principal.** Los controladores
se cubren principalmente por pruebas de API/contrato que verifican
códigos de respuesta, estructura del cuerpo y comportamiento ante
entradas inválidas. Los repositorios se verifican de forma indirecta
a través de pruebas de integración con base de datos real o en memoria.
Un controlador bien diseñado no tiene lógica de negocio propia que
requiera prueba unitaria directa.

**Las reglas de negocio cerradas se prueban explícitamente.** Cada
RN documentada en `REGLAS_NEGOCIO.md` debe tener al menos un caso
de prueba que la verifique.

### 2.2 Estrategia de pruebas por capa

#### Pruebas unitarias — servicios

| Servicio | Qué se prueba |
|---|---|
| `CasoEstadoService` | Todas las transiciones válidas e inválidas. Guardias de estado. Registro de auditoría por transición. |
| `ChecklistService` | Cálculo de `completado` por bloque. Bloqueo de transición por bloque crítico. No aplicable con justificación. |
| `HerramientaService` | Rechazo de escritura en estados no editables. Mínimos obligatorios por herramienta. |
| `RevisionSupervisorService` | Creación de revisión con observaciones. Inmutabilidad de revisiones anteriores. |
| `InformeService` | Precondiciones por tipo de informe. Registro obligatorio en `informes_generados`. |
| `IAService` | Registro en `ai_request_log` en toda llamada. Respuesta `503` ante fallo del proveedor sin afectar el caso. |
| `AuditoriaService` | Registro de eventos críticos. Rechazo de cualquier operación distinta a INSERT. |
| `AuthService` | Login con credenciales válidas e inválidas. Emisión y verificación de JWT. |

#### Pruebas de integración — flujos críticos

| Flujo | Qué se prueba |
|---|---|
| Flujo completo del caso | `borrador` → `en_analisis` → `pendiente_revision` → `aprobado_supervisor` → `listo_para_cliente` → `cerrado` con todos los actores. |
| Flujo de devolución | `pendiente_revision` → `devuelto` → `en_analisis` → `pendiente_revision`. |
| Checklist como compuerta | Intentar enviar a revisión con bloque crítico incompleto → `422` (guarda de negocio falla, transición existe). |
| Generación de informe con precondición | Intentar generar `conclusion_operativa` sin checklist completo → `422`. |
| Fallo del módulo de IA | Proveedor no responde → `503` solo en endpoint de IA, flujo del caso no afectado. |
| Auditoría obligatoria | Toda transición genera registro en `eventos_auditoria` — verificable después de cada operación. |

#### Pruebas de API — contrato

Las pruebas de API verifican que el contrato definido en
`CONTRATO_API.md` se cumple: códigos de respuesta, estructura
del cuerpo, headers y comportamiento ante entradas inválidas.

### 2.3 Manejo de errores

#### Códigos HTTP por tipo de excepción

| Excepción de dominio | Código HTTP | Cuándo |
|---|---|---|
| `RecursoNoEncontrado` | `404` | Caso, usuario o cliente no existe |
| `AccesoDenegado` | `403` | Perfil no autorizado para la operación |
| `TransicionInvalida` | `409` | El estado actual no permite la transición solicitada — la ruta no existe en la máquina de estados |
| `ReglaDeNegocioViolada` | `422` | La transición existe pero falla una guarda: checklist incompleto, mínimos no cumplidos, precondición de informe fallida |
| Error de validación de entrada | `400` | Payload no cumple el esquema del DTO |
| Error de autenticación | `401` | Token inválido, expirado o ausente |
| Fallo del proveedor de IA | `503` | Solo en endpoint `/ai/query` |
| Cualquier error no manejado | `500` | Con log interno — nunca expone stack trace al cliente |

#### Estructura estándar de error

Todas las respuestas de error siguen la misma estructura:

```json
{
  "statusCode": 422,
  "error": "ReglaDeNegocioViolada",
  "message": "El checklist tiene bloques críticos incompletos",
  "details": [
    { "bloque": "tipicidad", "estado": "incompleto" }
  ],
  "timestamp": "2026-03-06T14:30:00Z",
  "path": "/api/v1/cases/123/transition"
}
```

El campo `details` es opcional — se incluye cuando hay información
estructurada que ayuda al cliente a resolver el error. El stack trace
nunca se expone en producción.

#### Regla de auditoría en errores

Si una operación crítica falla y su registro de auditoría también
falla, la operación principal debe fallar (RI-BACK-05). No se
permiten operaciones críticas sin rastro de auditoría.

### 2.4 Criterios de aceptación técnica del MVP

El MVP se considera técnicamente aceptable cuando:

| Criterio | Verificación |
|---|---|
| Flujo completo del caso funciona sin errores | Prueba de integración end-to-end con datos reales |
| Todas las transiciones inexistentes retornan `409`; guardas fallidas retornan `422` | Prueba unitaria de `CasoEstadoService` y `ChecklistService` |
| El checklist bloquea las transiciones que debe bloquear | Prueba unitaria de `ChecklistService` |
| Toda transición genera registro de auditoría | Prueba de integración + consulta directa a `eventos_auditoria` |
| El fallo de IA no interrumpe el flujo del caso | Prueba con mock del proveedor que falla |
| Los informes P0 se generan correctamente en PDF y DOCX con contenido consistente con el expediente y metadatos de generación correctos | Prueba con caso real completo |
| Ningún endpoint expone datos de otro usuario | Prueba de autorización cruzada por perfil |
| Los secretos no aparecen en logs ni en respuestas | Revisión de logs en entorno de staging |

### 2.5 Lo que queda fuera del alcance del MVP

Las siguientes prácticas de calidad quedan diferidas para fases
posteriores y requieren decisión formal:

- Pruebas de carga y rendimiento bajo concurrencia.
- Cobertura de código con umbral mínimo definido.
- Pruebas de seguridad automatizadas (SAST, DAST).
- Pruebas de regresión automatizadas en CI/CD.
- Pruebas de accesibilidad (WCAG) en el frontend.
