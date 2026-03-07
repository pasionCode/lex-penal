# Estados del caso

Referencia operativa de la máquina de estados del caso LexPenal.
Este documento es la versión de consulta rápida de la ADR-003.
Toda decisión de fondo sobre estados y transiciones se gobierna desde allí.

**ADR de referencia**: `docs/00_gobierno/adrs/ADR-003-maquina-de-estados-del-caso.md`

| Campo | Valor |
|---|---|
| Última revisión | (completar) |
| Responsable | (completar) |

---

## Estados

| Estado                | Quién puede trabajar en él          | Descripción operativa |
|-----------------------|-------------------------------------|-----------------------|
| `borrador`            | Estudiante, Supervisor, Admin       | Caso recién creado. Ficha básica en diligenciamiento. Sin análisis iniciado. |
| `en_analisis`         | Estudiante, Supervisor, Admin       | Herramientas operativas en diligenciamiento activo. Estado principal de trabajo. |
| `pendiente_revision`  | Solo lectura para Estudiante        | Análisis enviado al supervisor. El estudiante no puede editar hasta que el supervisor actúe. |
| `devuelto`            | Estudiante, Supervisor, Admin       | Supervisor devolvió con observaciones. El caso regresa formalmente al responsable. No puede aprobarse ni enviarse al cliente sin transitar primero a `en_analisis`. |
| `aprobado_supervisor` | Solo lectura para Estudiante        | Supervisor aprobó. En preparación para entrega al cliente. |
| `listo_para_cliente`  | Solo lectura para Estudiante        | Conclusión operativa lista para presentar al procesado. |
| `cerrado`             | Solo lectura para todos             | Caso finalizado. No admite modificaciones. Reapertura no contemplada en MVP 1.0. |

---

## Diagrama de transiciones

```
borrador
  └─→ en_analisis
        └─→ pendiente_revision
              ├─→ devuelto
              │     └─→ en_analisis
              └─→ aprobado_supervisor
                    └─→ listo_para_cliente
                          └─→ cerrado
```

Toda transición no listada es inválida y el backend la rechaza con `409 Conflict`.

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
- Observaciones del supervisor no vacías.

### `pendiente_revision` → `aprobado_supervisor`
- Solo Supervisor o Administrador.
- Bloque de revisión del supervisor completamente diligenciado.
- Observaciones del supervisor no vacías.

### `devuelto` → `en_analisis`
- Estudiante, Supervisor o Administrador responsable del caso.
- Al menos una observación del supervisor registrada.
- Reapertura queda auditada con usuario y fecha.

### `aprobado_supervisor` → `listo_para_cliente`
- Solo Supervisor o Administrador.
- Conclusión operativa con los cinco bloques diligenciados.
- Campo de recomendación no vacío.
- Checklist sin bloques críticos incompletos al momento de la transición.

### `listo_para_cliente` → `cerrado`
- Solo Supervisor o Administrador.
- Decisión del cliente documentada en el formato de explicación al cliente.

---

## Permisos por transición y perfil

| Transición                               | Estudiante | Supervisor | Administrador |
|------------------------------------------|-----------|-----------|---------------|
| `borrador` → `en_analisis`               | ✅         | ✅         | ✅             |
| `en_analisis` → `pendiente_revision`     | ✅         | ✅         | ✅             |
| `pendiente_revision` → `devuelto`        | ❌         | ✅         | ✅             |
| `pendiente_revision` → `aprobado_supervisor` | ❌     | ✅         | ✅             |
| `devuelto` → `en_analisis`               | ✅         | ✅         | ✅             |
| `aprobado_supervisor` → `listo_para_cliente` | ❌     | ✅         | ✅             |
| `listo_para_cliente` → `cerrado`         | ❌         | ✅         | ✅             |

---

## Comportamiento del frontend por estado

| Estado                | Puede editar herramientas | Botón "Enviar a revisión" | Botón "Aprobar" | Botón "Devolver" |
|-----------------------|--------------------------|--------------------------|-----------------|-----------------|
| `borrador`            | ✅                        | ❌                        | ❌               | ❌               |
| `en_analisis`         | ✅                        | ✅ (con guardia visible)  | ❌               | ❌               |
| `pendiente_revision`  | ❌                        | ❌                        | ✅ (supervisor)  | ✅ (supervisor)  |
| `devuelto`            | ✅                        | ❌                        | ❌               | ❌               |
| `aprobado_supervisor` | ❌                        | ❌                        | ❌               | ❌               |
| `listo_para_cliente`  | ❌                        | ❌                        | ❌               | ❌               |
| `cerrado`             | ❌                        | ❌                        | ❌               | ❌               |

---

## Regla de implementación

El frontend renderiza únicamente las acciones disponibles para el estado actual
y el perfil del usuario en sesión. No deshabilita botones que no aplican:
directamente no los muestra.
