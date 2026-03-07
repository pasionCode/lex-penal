# ADR-003: Máquina de estados del caso

- **Estado**: Aprobado
- **Fecha**: (completar al formalizar)
- **Ubicación**: `docs/00_gobierno/adrs/ADR-003-maquina-de-estados-del-caso.md`

---

## Contexto

El caso es la entidad central del sistema (R01). Su ciclo de vida abarca desde la apertura
hasta el cierre, pasando por etapas de análisis, control de calidad, revisión del supervisor
y entrega al cliente. Sin una máquina de estados formal, el sistema no puede garantizar que:

- el checklist sea vinculante (R02);
- la revisión del supervisor sea un paso formal obligatorio (R04);
- la conclusión operativa no se entregue sin control previo (R03);
- las acciones críticas sean auditables por estado (R06).

Una implementación sin estados formales produce un sistema donde cualquier perfil puede
realizar cualquier acción en cualquier momento, eliminando el valor metodológico del producto.

---

## Decisión

El caso tendrá una máquina de estados formal con siete estados y transiciones
controladas exclusivamente por el backend. El frontend no puede cambiar el estado
del caso directamente: solo puede solicitar una transición, y el backend la aprueba
o rechaza según las reglas de guardia definidas en este documento.

---

## Estados y descripciones

| Estado                | Descripción                                                                 |
|-----------------------|-----------------------------------------------------------------------------|
| `borrador`            | Caso creado. Ficha básica en diligenciamiento. Sin análisis iniciado.       |
| `en_analisis`         | Herramientas operativas en diligenciamiento activo.                         |
| `pendiente_revision`  | Análisis completo enviado al supervisor para revisión formal.               |
| `devuelto`            | Supervisor devolvió el caso con observaciones. El caso regresa formalmente al trabajo del responsable. Mientras esté en este estado no puede aprobarse ni enviarse al cliente sin transitar primero a `en_analisis`. |
| `aprobado_supervisor` | Supervisor aprobó el análisis. Caso listo para preparar entrega al cliente. |
| `listo_para_cliente`  | Conclusión operativa lista para ser presentada al procesado.                |
| `cerrado`             | Caso finalizado. Solo lectura. No admite modificaciones. La reapertura no hace parte del MVP 1.0; si se requiere en el futuro deberá definirse mediante un ADR posterior. |

---

## Transiciones válidas

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

Toda transición no listada aquí es inválida y debe ser rechazada por el backend
con error `422 Unprocessable Entity` y mensaje descriptivo.

---

## Reglas de guardia por transición

Cada transición tiene condiciones que el backend debe verificar antes de ejecutarla.
Si alguna condición no se cumple, la transición se rechaza y se retorna el motivo.

### `borrador` → `en_analisis`
- La ficha básica tiene al menos: radicado, procesado, delito imputado y etapa procesal.

### `en_analisis` → `pendiente_revision`
- El checklist no tiene bloques críticos incompletos. **(R02)**
- Existe al menos una línea defensiva registrada en la estrategia.
- La matriz de hechos tiene al menos un hecho registrado.

### `pendiente_revision` → `devuelto`
- Solo puede ejecutarla un usuario con perfil `supervisor` o `administrador`.
- El campo de observaciones del supervisor no puede estar vacío.

### `pendiente_revision` → `aprobado_supervisor`
- Solo puede ejecutarla un usuario con perfil `supervisor` o `administrador`.
- El bloque de revisión del supervisor está completamente diligenciado. **(R04)**
- El campo de observaciones del supervisor no puede estar vacío.

### `devuelto` → `en_analisis`
- Puede ejecutarla el estudiante o abogado responsable del caso.
- El caso debe tener al menos una observación del supervisor registrada.
- La reapertura queda auditada con usuario, fecha y estado de origen. **(R06)**

### `aprobado_supervisor` → `listo_para_cliente`
- La conclusión operativa tiene los cinco bloques diligenciados.
- El campo de recomendación no está vacío.
- El checklist no tiene bloques críticos incompletos al momento de la transición. **(R02)**

### `listo_para_cliente` → `cerrado`
- La decisión del cliente está documentada en el formato de explicación al cliente.
- Solo puede ejecutarla un usuario con perfil `supervisor` o `administrador`.

---

## Permisos por perfil y acción

| Transición                              | Estudiante | Supervisor | Administrador |
|-----------------------------------------|-----------|-----------|---------------|
| borrador → en_analisis                  | ✅         | ✅         | ✅             |
| en_analisis → pendiente_revision        | ✅         | ✅         | ✅             |
| pendiente_revision → devuelto           | ❌         | ✅         | ✅             |
| pendiente_revision → aprobado_supervisor| ❌         | ✅         | ✅             |
| devuelto → en_analisis                  | ✅         | ✅         | ✅             |
| aprobado_supervisor → listo_para_cliente| ❌         | ✅         | ✅             |
| listo_para_cliente → cerrado            | ❌         | ✅         | ✅             |

---

## Implicaciones en el modelo de datos

La entidad `Caso` debe incluir:

```
estado_actual          : enum (borrador | en_analisis | pendiente_revision |
                               devuelto | aprobado_supervisor |
                               listo_para_cliente | cerrado)
estado_anterior        : string nullable   -- estado previo al actual
fecha_cambio_estado    : timestamp         -- fecha del último cambio de estado
usuario_cambio_estado  : FK Usuario        -- quién ejecutó la transición
```

La entidad `EventoAuditoria` debe registrar cada transición con:

```
caso_id          : FK Caso
estado_origen    : string
estado_destino   : string
usuario_id       : FK Usuario
fecha_evento     : timestamp
resultado        : enum (aprobado | rechazado)
motivo_rechazo   : string nullable
```

---

## Implicaciones en el backend

- Crear un servicio `CasoEstadoService` o equivalente que centralice
  toda la lógica de transición.
- Ningún otro servicio puede modificar el campo `estado` del caso directamente.
- El endpoint de transición será:
  `POST /api/v1/cases/{id}/transition`
  con body `{ "estado_destino": "..." }`.
- El backend evalúa las reglas de guardia, ejecuta la transición si corresponde,
  registra el evento de auditoría y retorna el caso actualizado.

### Códigos de respuesta del endpoint

| Código | Significado                                                              |
|--------|--------------------------------------------------------------------------|
| `200`  | Transición aplicada. Retorna el caso con su nuevo estado.                |
| `403`  | El perfil del usuario no tiene permiso para ejecutar esta transición.    |
| `404`  | El caso no existe o no es accesible por el usuario en sesión.            |
| `409`  | El estado actual del caso es incompatible con la transición solicitada.  |
| `422`  | Las reglas de guardia no se cumplen. Se retorna detalle de los motivos.  |

### Estructura mínima del error

```json
{
  "error": "TRANSITION_REJECTED",
  "estadoActual": "en_analisis",
  "estadoSolicitado": "aprobado_supervisor",
  "motivos": [
    "El checklist tiene bloques críticos incompletos.",
    "El bloque de revisión del supervisor no está diligenciado."
  ]
}
```

---

## Implicaciones en el frontend

- El frontend consulta el estado actual del caso y renderiza solo las
  acciones de transición disponibles para el perfil del usuario en sesión.
- El botón de envío a revisión debe mostrar el resultado del checklist
  antes de habilitarse, no solo bloquearse sin explicación.
- Los estados `devuelto` y `aprobado_supervisor` deben ser visualmente
  diferenciados en el dashboard y en la vista del caso.

---

## Consecuencias

- Mayor coherencia metodológica: el flujo del sistema refleja el flujo real del análisis.
- Control de calidad efectivo: el checklist y la revisión del supervisor son compuertas reales.
- Trazabilidad completa: cada cambio de estado queda registrado con usuario y fecha.
- Complejidad adicional en backend: el servicio de transición requiere pruebas
  unitarias exhaustivas por cada combinación de estado, perfil y condición de guardia.

---

## Reglas vinculantes asociadas

- R01 — El caso es la unidad central del sistema
- R02 — El checklist es vinculante
- R03 — La conclusión operativa es un entregable formal
- R04 — La revisión del supervisor es un paso formal del flujo
- R06 — Toda acción crítica es auditable
