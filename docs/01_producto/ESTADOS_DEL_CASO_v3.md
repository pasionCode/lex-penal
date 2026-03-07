# Estados del caso

Referencia operativa de la máquina de estados del caso LexPenal.
Este documento baja las decisiones de ADR-003 al lenguaje funcional del producto
y refleja todas las reglas de negocio cerradas sobre estados, herramientas y revisión.

**ADR de referencia**: `docs/00_gobierno/adrs/ADR-003-maquina-de-estados-del-caso.md`
**Reglas de negocio**: `docs/03_datos/REGLAS_NEGOCIO.md` — RN-HER-01, RN-REV-01

| Campo | Valor |
|---|---|
| Última revisión | (completar) |
| Responsable | (completar) |

---

## Estados

| Estado | Descripción operativa |
|---|---|
| `borrador` | Caso recién creado. Ficha básica en diligenciamiento. Sin análisis iniciado. |
| `en_analisis` | Herramientas operativas en diligenciamiento activo. Estado principal de trabajo del responsable. |
| `pendiente_revision` | Análisis enviado al supervisor. Herramientas de análisis en solo lectura para **todos** los perfiles. El supervisor diligencia exclusivamente el bloque de revisión (`/review`). |
| `devuelto` | Supervisor devolvió con observaciones. El caso regresa formalmente al responsable. No puede aprobarse ni enviarse al cliente sin transitar primero a `en_analisis`. |
| `aprobado_supervisor` | Supervisor aprobó el análisis. En preparación para entrega al cliente. Solo lectura para todos. |
| `listo_para_cliente` | Conclusión operativa lista para presentar al procesado. Solo lectura para todos. |
| `cerrado` | Caso finalizado. No admite modificaciones de ningún tipo. Reapertura no contemplada en MVP. |

---

## Diagrama de transiciones

```
borrador
  └─→ en_analisis
        └─→ pendiente_revision
              ├─→ devuelto
              │     └─→ en_analisis   ← único camino de corrección
              └─→ aprobado_supervisor
                    └─→ listo_para_cliente
                          └─→ cerrado
```

Toda transición no listada es inválida. El backend la rechaza con `409`.

- `409 Conflict` — la transición solicitada no existe desde el estado actual del caso.
- `422 Unprocessable Entity` — la transición existe pero falla una regla de guardia.

**Regla de corrección**: desde `devuelto`, el único camino de retorno al flujo
activo es `devuelto` → `en_analisis`. No existe transición directa de `devuelto`
a `aprobado_supervisor` ni a ningún otro estado. El responsable debe reabrir
el caso, corregir el análisis y enviarlo nuevamente a revisión.

---

## Separación entre autoría y revisión

Esta es una regla de diseño con consecuencias en todos los estados del caso.

**El análisis pertenece al responsable del caso. La revisión pertenece al supervisor.**

En el estado `pendiente_revision`:
- Las ocho herramientas de análisis (ficha, hechos, pruebas, riesgos, estrategia,
  explicación al cliente, checklist, conclusión) son de **solo lectura para todos
  los perfiles** — incluyendo supervisor y administrador.
- El supervisor tiene acceso exclusivo de escritura al bloque de revisión (`/review`).
- Esta separación garantiza que la autoría del análisis queda trazada al responsable
  y la revisión queda trazada al supervisor, sin mezcla de autoría.
- Un supervisor que quisiera corregir el análisis directamente en lugar de devolver
  el caso estaría violando esta separación. El sistema no lo permite.

**Por qué esta regla existe**:
Preserva trazabilidad, responsabilidad pedagógica y auditoría limpia.
Si el supervisor pudiera editar herramientas durante la revisión, no habría forma
de distinguir qué parte del análisis produjo el estudiante y qué parte el supervisor.

---

## Reglas de guardia por transición

### `borrador` → `en_analisis`
- Radicado, procesado, delito imputado y etapa procesal diligenciados en la ficha básica.

### `en_analisis` → `pendiente_revision`
- Checklist sin bloques críticos incompletos.
- Al menos una línea defensiva registrada en la estrategia.
- Matriz de hechos con al menos un hecho registrado.

### `pendiente_revision` → `devuelto`
- Solo Supervisor o Administrador.
- Observaciones del supervisor presentes y no vacías.
  Las observaciones son obligatorias — una devolución sin fundamento escrito
  no produce registro válido de revisión.

### `pendiente_revision` → `aprobado_supervisor`
- Solo Supervisor o Administrador.
- Bloque de revisión del supervisor diligenciado.
- Observaciones del supervisor presentes y no vacías.
  Las observaciones son obligatorias también en aprobación.
  Un supervisor que aprueba sin dejar constancia escrita de su criterio
  no genera una revisión válida.

### `devuelto` → `en_analisis`
- Estudiante responsable del caso o Administrador.
- Supervisor no puede ejecutar esta transición — la reapertura del análisis
  pertenece al responsable, en coherencia con la separación autoría/revisión.
- Al menos una revisión registrada con observaciones.
- Reapertura queda auditada con usuario y fecha.

### `aprobado_supervisor` → `listo_para_cliente`
- Solo Supervisor o Administrador.
- Conclusión operativa con los cinco bloques diligenciados.
- Campo de recomendación no vacío.
- Checklist sin bloques críticos incompletos al momento de la transición.

### `listo_para_cliente` → `cerrado`
- Solo Supervisor o Administrador.
- Decisión del cliente documentada en el bloque de explicación al cliente.

---

## Permisos por transición y perfil

| Transición | Estudiante | Supervisor | Administrador |
|---|---|---|---|
| `borrador` → `en_analisis` | ✅ | ✅ | ✅ |
| `en_analisis` → `pendiente_revision` | ✅ | ✅ | ✅ |
| `pendiente_revision` → `devuelto` | ❌ | ✅ | ✅ |
| `pendiente_revision` → `aprobado_supervisor` | ❌ | ✅ | ✅ |
| `devuelto` → `en_analisis` | ✅ | ❌ | ✅ |
| `aprobado_supervisor` → `listo_para_cliente` | ❌ | ✅ | ✅ |
| `listo_para_cliente` → `cerrado` | ❌ | ✅ | ✅ |

---

## Comportamiento del frontend por estado

La tabla distingue dos tipos de acceso:
- **Herramientas**: las ocho herramientas de análisis del caso (ficha, hechos, pruebas, etc.).
- **Revisión**: el bloque de revisión del supervisor (`/review`).

| Estado | Herramientas (edición) | Revisión (edición) | Acciones disponibles |
|---|---|---|---|
| `borrador` | ✅ Todos los perfiles | ❌ | Continuar análisis |
| `en_analisis` | ✅ Todos los perfiles | ❌ | Continuar análisis, Enviar a revisión |
| `pendiente_revision` | ❌ Todos los perfiles | ✅ Solo Supervisor / Admin | Aprobar, Devolver (supervisor) |
| `devuelto` | ✅ Todos los perfiles | ❌ | Reabrir análisis |
| `aprobado_supervisor` | ❌ Todos los perfiles | ❌ | Preparar para cliente (supervisor) |
| `listo_para_cliente` | ❌ Todos los perfiles | ❌ | Cerrar caso (supervisor) |
| `cerrado` | ❌ Todos los perfiles | ❌ | Sin acciones disponibles |

**Regla de renderizado**: el frontend no deshabilita acciones no disponibles —
directamente no las muestra. Un botón ausente comunica que esa acción no forma
parte del flujo actual. Un botón deshabilitado sugeriría que la acción existe
pero no es posible ahora, lo que no es el mensaje correcto.

**Nota sobre `pendiente_revision`**: el supervisor ve las herramientas en modo
lectura y tiene acceso al panel de revisión completo en modo edición.
El estudiante/responsable ve las herramientas en modo lectura y no tiene acceso
al panel de revisión formal — sí accede a la vista filtrada de observaciones
(`GET /cases/{id}/review/feedback`) para saber qué corregir si el caso
es devuelto. La revisión formal completa es un subrecurso del caso accesible
solo para Supervisor y Administrador.

---

## Regla de implementación

`CasoEstadoService` es el único componente del backend autorizado para escribir
`casos.estado_actual`. Ningún otro servicio, controlador ni repositorio puede
modificar ese campo directamente. Toda transición pasa por ese servicio,
que evalúa perfil, reglas de guardia y registra el evento de auditoría.
