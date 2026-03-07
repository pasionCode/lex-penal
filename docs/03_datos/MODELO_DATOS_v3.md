# Modelo de datos

Documento de referencia del modelo relacional de LexPenal.
Define entidades, campos, relaciones, restricciones y reglas de integridad.

**Documentos relacionados**
- `docs/00_gobierno/adrs/ADR-002-postgresql-como-base-relacional.md`
- `docs/00_gobierno/adrs/ADR-003-maquina-de-estados-del-caso.md`
- `docs/00_gobierno/adrs/ADR-006-orm-acceso-a-datos.md`
- `docs/04_api/CONTRATO_API_v4.md`

| Campo | Valor |
|---|---|
| Última revisión | (completar) |
| Responsable | (completar) |

---

## Principios del modelo

1. **El caso es el agregador central.** Toda entidad operativa (hechos, pruebas, riesgos,
   checklist, conclusión, informes, logs de IA) pertenece a un caso. No existe registro
   operativo sin caso asociado.

2. **Trazabilidad mínima obligatoria — dos convenciones.**

   **Entidades operativas editables** (casos, clientes, hechos, pruebas, riesgos,
   estrategia, actuaciones, explicacion_cliente, conclusion_operativa):
   incluyen `creado_en`, `actualizado_en`, `creado_por`, `actualizado_por`.

   **Entidades append-only o inmutables** (linea_tiempo, revision_supervisor,
   documentos, informes_generados, ai_request_log, eventos_auditoria):
   incluyen solo `creado_en` y `creado_por`. No tienen `actualizado_en`
   ni `actualizado_por` porque sus registros no se modifican — solo se crean.
   Intentar un `UPDATE` sobre ellas es un error de diseño.

3. **El estado del caso lo gobierna el backend.** El campo `estado_actual` de `Caso`
   solo puede modificarse a través del servicio `CasoEstadoService`.

4. **Nomenclatura snake_case** en todos los campos, tablas e índices.

5. **Identificadores UUID v4** en todas las entidades principales.

---

## Entidades

---

### 1. `usuarios`

Usuarios del sistema. Un usuario tiene exactamente un perfil.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | Identificador único. |
| `nombre` | VARCHAR(120) | NOT NULL | Nombre completo. |
| `email` | VARCHAR(255) | NOT NULL, UNIQUE | Correo electrónico. Usado para login. |
| `password_hash` | VARCHAR(255) | NOT NULL | Hash de la contraseña. Nunca en claro. |
| `perfil` | ENUM | NOT NULL | `estudiante`, `supervisor`, `administrador`. |
| `activo` | BOOLEAN | NOT NULL, DEFAULT true | Permite desactivar sin eliminar. |
| `creado_en` | TIMESTAMP | NOT NULL, DEFAULT now() | Fecha de creación. |
| `actualizado_en` | TIMESTAMP | NOT NULL | Fecha de última actualización. |
| `creado_por` | UUID | FK usuarios.id, nullable | Quién creó el usuario. |

**Índices**: `email` (único).

**Reglas**:
- El perfil solo puede ser modificado por un administrador.
- Un usuario desactivado no puede iniciar sesión pero sus registros se conservan.

---

### 2. `clientes`

Procesados vinculados a los casos. Un cliente puede tener múltiples casos.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | Identificador único. |
| `nombre` | VARCHAR(120) | NOT NULL | Nombre completo del procesado. |
| `documento` | VARCHAR(30) | NOT NULL | Número de documento de identidad. |
| `tipo_documento` | VARCHAR(20) | NOT NULL | Cédula, pasaporte, etc. |
| `contacto` | TEXT | nullable | Teléfono, dirección u otra información de contacto. |
| `situacion_libertad` | ENUM | NOT NULL | `libre`, `detenido`. |
| `lugar_detencion` | VARCHAR(200) | nullable | Obligatorio si `situacion_libertad = detenido`. |
| `creado_en` | TIMESTAMP | NOT NULL, DEFAULT now() | |
| `actualizado_en` | TIMESTAMP | NOT NULL | |
| `creado_por` | UUID | FK usuarios.id, NOT NULL | |
| `actualizado_por` | UUID | FK usuarios.id, nullable | |

**Índices**: `(tipo_documento, documento)` (único).

**Reglas**:
- La combinación `tipo_documento + documento` debe ser única en el sistema.
  Evita registrar al mismo procesado dos veces con documentos distintos en tipo pero iguales en número.
- Si `situacion_libertad = detenido`, `lugar_detencion` no puede ser nulo.

---

### 3. `casos`

Entidad central del sistema. Agrega todas las herramientas operativas.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | Identificador único. |
| `cliente_id` | UUID | FK clientes.id, NOT NULL | Procesado del caso. |
| `responsable_id` | UUID | FK usuarios.id, NOT NULL | Estudiante o abogado a cargo. |
| `radicado` | VARCHAR(80) | NOT NULL, UNIQUE | Número de radicado judicial. Único en el sistema. |
| `despacho` | VARCHAR(200) | nullable | Despacho judicial o fiscal. |
| `fecha_apertura` | DATE | nullable | Fecha de apertura del expediente. |
| `delito_imputado` | VARCHAR(300) | NOT NULL | Tipo penal y artículo. |
| `agravantes` | TEXT | nullable | Agravantes alegadas. |
| `regimen_procesal` | VARCHAR(100) | NOT NULL | Régimen procesal aplicable. |
| `etapa_procesal` | VARCHAR(100) | NOT NULL | Etapa procesal actual. |
| `proxima_actuacion` | TEXT | nullable | Descripción de la próxima actuación. |
| `fecha_proxima_actuacion` | DATE | nullable | Fecha de la próxima actuación. |
| `responsable_proxima_actuacion` | VARCHAR(120) | nullable | |
| `observaciones` | TEXT | nullable | Observaciones generales del caso. |
| `estado_actual` | ENUM | NOT NULL, DEFAULT 'borrador' | `borrador`, `en_analisis`, `pendiente_revision`, `devuelto`, `aprobado_supervisor`, `listo_para_cliente`, `cerrado`. |
| `estado_anterior` | VARCHAR(50) | nullable | Estado previo al actual. |
| `fecha_cambio_estado` | TIMESTAMP | nullable | Fecha del último cambio de estado. |
| `usuario_cambio_estado` | UUID | FK usuarios.id, nullable | Quién ejecutó la última transición. |
| `creado_en` | TIMESTAMP | NOT NULL, DEFAULT now() | |
| `actualizado_en` | TIMESTAMP | NOT NULL | |
| `creado_por` | UUID | FK usuarios.id, NOT NULL | |
| `actualizado_por` | UUID | FK usuarios.id, nullable | |

**Índices**: `cliente_id`, `responsable_id`, `estado_actual`, `radicado` (único).

**Reglas**:
- `estado_actual` solo puede modificarse a través de `CasoEstadoService`.
- Un caso en estado `cerrado` no admite ninguna modificación en ningún campo.
- Los campos `proxima_actuacion`, `fecha_proxima_actuacion` y `responsable_proxima_actuacion`
  son una desnormalización intencional: representan el resumen visible del siguiente
  vencimiento para consultas rápidas sin JOIN a `actuaciones`. El responsable de
  mantenerlos sincronizados es el backend — cuando se crea o modifica una actuación,
  `ActuacionesService` actualiza estos campos en `casos` si corresponde.

---

### 4. `hechos`

Hechos jurídicamente relevantes del caso. Corresponde a la Matriz de hechos (Apartado 2, U008).

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | |
| `caso_id` | UUID | FK casos.id, NOT NULL | |
| `orden` | INTEGER | NOT NULL | Posición en la lista. |
| `descripcion` | TEXT | NOT NULL | Descripción concreta del hecho. |
| `estado_hecho` | ENUM | NOT NULL | `acreditado`, `referido`, `discutido`. |
| `fuente` | TEXT | nullable | Prueba o fuente que respalda o cuestiona el hecho. |
| `incidencia_juridica` | ENUM | nullable | `tipicidad`, `antijuridicidad`, `culpabilidad`, `procedimiento`. |
| `creado_en` | TIMESTAMP | NOT NULL, DEFAULT now() | |
| `actualizado_en` | TIMESTAMP | NOT NULL | |
| `creado_por` | UUID | FK usuarios.id, NOT NULL | |
| `actualizado_por` | UUID | FK usuarios.id, nullable | |

**Índices**: `caso_id`. **Restricción**: `UNIQUE (caso_id, orden)`.

Eventos cronológicos del caso. Complementa la Matriz de hechos.
Incluida en el MVP — expuesta por `GET/POST /api/v1/cases/{id}/timeline`.
Usada por el informe `cronologico`.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | |
| `caso_id` | UUID | FK casos.id, NOT NULL | |
| `fecha_evento` | DATE | NOT NULL | |
| `descripcion` | TEXT | NOT NULL | Hecho ocurrido en esa fecha. |
| `orden` | INTEGER | NOT NULL | |
| `creado_en` | TIMESTAMP | NOT NULL, DEFAULT now() | |
| `creado_por` | UUID | FK usuarios.id, NOT NULL | |

**Índices**: `caso_id`. **Restricción**: `UNIQUE (caso_id, orden)`.

---

### 6. `pruebas`

Medios de prueba evaluados. Corresponde a la Matriz probatoria (Apartado 3, U008).

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | |
| `caso_id` | UUID | FK casos.id, NOT NULL | |
| `hecho_id` | UUID | FK hechos.id, nullable | Hecho de la matriz al que se vincula la prueba. Preferible a texto libre. |
| `hecho_descripcion_libre` | TEXT | nullable | Texto libre opcional si el hecho no está en la matriz o para notas adicionales. |
| `descripcion` | TEXT | NOT NULL | Descripción del medio de prueba. |
| `tipo_prueba` | ENUM | NOT NULL | `testimonial`, `documental`, `pericial`, `real`, `otro`. |
| `licitud` | ENUM | NOT NULL | `ok`, `cuestionable`, `deficiente`. |
| `legalidad` | ENUM | NOT NULL | `ok`, `cuestionable`, `deficiente`. |
| `suficiencia` | ENUM | NOT NULL | `ok`, `cuestionable`, `deficiente`. |
| `credibilidad` | ENUM | NOT NULL | `ok`, `cuestionable`, `deficiente`. |
| `posicion_defensiva` | TEXT | nullable | Posición de la defensa frente a esta prueba. |
| `creado_en` | TIMESTAMP | NOT NULL, DEFAULT now() | |
| `actualizado_en` | TIMESTAMP | NOT NULL | |
| `creado_por` | UUID | FK usuarios.id, NOT NULL | |
| `actualizado_por` | UUID | FK usuarios.id, nullable | |

**Índices**: `caso_id`, `hecho_id`.

**Reglas**:
- Al menos uno de `hecho_id` o `hecho_descripcion_libre` debe estar diligenciado.
- Si `hecho_id` está presente, tiene precedencia semántica sobre `hecho_descripcion_libre`.
- **Integridad cruzada**: si `hecho_id` está diligenciado, el hecho referenciado debe
  pertenecer al mismo `caso_id` que la prueba. Esta regla no puede garantizarse solo con
  la FK a `hechos.id` — se valida obligatoriamente en `HerramientaService` antes de
  persistir y se documenta como invariante del modelo.

---

### 7. `riesgos`

Riesgos procesales identificados. Corresponde a la Matriz de riesgos (Apartado 4, U008).

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | |
| `caso_id` | UUID | FK casos.id, NOT NULL | |
| `descripcion` | TEXT | NOT NULL | Descripción del riesgo procesal. |
| `probabilidad` | ENUM | NOT NULL | `alta`, `media`, `baja`. |
| `impacto` | ENUM | NOT NULL | `alto`, `medio`, `bajo`. |
| `prioridad` | ENUM | NOT NULL | `critica`, `alta`, `media`, `baja`. Calculada o asignada manualmente. |
| `estrategia_mitigacion` | TEXT | nullable | Medida de mitigación propuesta. |
| `estado_mitigacion` | ENUM | NOT NULL, DEFAULT 'pendiente' | `pendiente`, `en_curso`, `mitigado`, `aceptado`. |
| `plazo_accion` | DATE | nullable | Fecha límite para ejecutar la mitigación. |
| `responsable_id` | UUID | FK usuarios.id, nullable | Usuario responsable de la mitigación. |
| `creado_en` | TIMESTAMP | NOT NULL, DEFAULT now() | |
| `actualizado_en` | TIMESTAMP | NOT NULL | |
| `creado_por` | UUID | FK usuarios.id, NOT NULL | |
| `actualizado_por` | UUID | FK usuarios.id, nullable | |

**Índices**: `caso_id`, `prioridad`, `estado_mitigacion`, `responsable_id`.

**Reglas**:
- Los riesgos con `prioridad = 'critica'` deben tener `estrategia_mitigacion` diligenciada.
  El backend advierte si se intenta guardar un riesgo crítico sin estrategia.
- `prioridad` puede calcularse automáticamente como referencia a partir de
  `probabilidad` e `impacto`, pero puede ser sobreescrita manualmente.

---

### 8. `estrategia`

Estrategia de defensa del caso. Corresponde al Apartado 5, U008.
Relación uno a uno con `casos`.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | |
| `caso_id` | UUID | FK casos.id, NOT NULL, UNIQUE | |
| `linea_principal` | TEXT | nullable | Descripción de la línea defensiva principal. |
| `fundamento_juridico` | TEXT | nullable | |
| `fundamento_probatorio` | TEXT | nullable | |
| `linea_subsidiaria` | TEXT | nullable | |
| `posicion_allanamiento` | TEXT | nullable | |
| `posicion_preacuerdo` | TEXT | nullable | |
| `posicion_juicio` | TEXT | nullable | |
| `creado_en` | TIMESTAMP | NOT NULL, DEFAULT now() | |
| `actualizado_en` | TIMESTAMP | NOT NULL | |
| `creado_por` | UUID | FK usuarios.id, NOT NULL | |
| `actualizado_por` | UUID | FK usuarios.id, nullable | |

**Índices**: `caso_id` (único).

---

### 9. `actuaciones`

Actuaciones procesales pendientes. Vinculadas a la estrategia del caso.
Incluida en el MVP — expuesta por `GET/POST/PUT/DELETE /api/v1/cases/{id}/proceedings`.
Usada por el informe `agenda_vencimientos`.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | |
| `caso_id` | UUID | FK casos.id, NOT NULL | |
| `descripcion` | TEXT | NOT NULL | Descripción de la actuación. |
| `fecha` | DATE | nullable | Fecha programada. |
| `responsable_id` | UUID | FK usuarios.id, nullable | Usuario responsable si es interno al sistema. |
| `responsable_externo` | VARCHAR(120) | nullable | Nombre libre si el responsable es externo al sistema (ej. juez, fiscal). |
| `completada` | BOOLEAN | NOT NULL, DEFAULT false | |
| `creado_en` | TIMESTAMP | NOT NULL, DEFAULT now() | |
| `actualizado_en` | TIMESTAMP | NOT NULL | |
| `creado_por` | UUID | FK usuarios.id, NOT NULL | |
| `actualizado_por` | UUID | FK usuarios.id, nullable | |

**Índices**: `caso_id`, `fecha`, `responsable_id`.

**Reglas**:
- Al menos uno de `responsable_id` o `responsable_externo` debe estar diligenciado cuando la actuación tiene responsable asignado.
- Si `responsable_id` está presente, `responsable_externo` se ignora.

---

### 10. `explicacion_cliente`

Registro de la información transmitida al procesado. Apartado 6, U008.
Relación uno a uno con `casos`.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | |
| `caso_id` | UUID | FK casos.id, NOT NULL, UNIQUE | |
| `delito_explicado` | TEXT | nullable | Delito atribuido y su significado concreto. |
| `riesgos_informados` | TEXT | nullable | Riesgos reales del proceso informados. |
| `panorama_probatorio` | TEXT | nullable | Panorama probatorio comunicado. |
| `beneficios_informados` | TEXT | nullable | Beneficios disponibles y plazos. |
| `opciones_explicadas` | TEXT | nullable | Opciones y sus consecuencias. |
| `recomendacion` | TEXT | nullable | Recomendación fundada del abogado. |
| `decision_cliente` | TEXT | nullable | Decisión del cliente documentada. |
| `fecha_explicacion` | DATE | nullable | Fecha de la explicación. |
| `creado_en` | TIMESTAMP | NOT NULL, DEFAULT now() | |
| `actualizado_en` | TIMESTAMP | NOT NULL | |
| `creado_por` | UUID | FK usuarios.id, NOT NULL | |
| `actualizado_por` | UUID | FK usuarios.id, nullable | |

**Índices**: `caso_id` (único).

---

### 11. `checklist_bloques`

Bloques del checklist de control de calidad. Apartado 7, U008.
Se generan automáticamente al crear el caso.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | |
| `caso_id` | UUID | FK casos.id, NOT NULL | |
| `codigo_bloque` | VARCHAR(10) | NOT NULL | `B01`..`B09`. |
| `nombre_bloque` | VARCHAR(120) | NOT NULL | Nombre descriptivo del bloque. |
| `critico` | BOOLEAN | NOT NULL, DEFAULT true | Si es crítico, bloquea transiciones. |
| `completado` | BOOLEAN | NOT NULL, DEFAULT false | Calculado: todos sus ítems marcados. |
| `creado_en` | TIMESTAMP | NOT NULL, DEFAULT now() | |

**Índices**: `caso_id`. **Restricción**: `UNIQUE (caso_id, codigo_bloque)`.

Ítems individuales de cada bloque del checklist.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | |
| `bloque_id` | UUID | FK checklist_bloques.id, NOT NULL | |
| `caso_id` | UUID | FK casos.id, NOT NULL | Desnormalizado para consultas rápidas. |
| `codigo_item` | VARCHAR(10) | NOT NULL | Ej: `B01_01`. |
| `descripcion` | TEXT | NOT NULL | Criterio de calidad. |
| `marcado` | BOOLEAN | NOT NULL, DEFAULT false | |
| `marcado_en` | TIMESTAMP | nullable | |
| `marcado_por` | UUID | FK usuarios.id, nullable | |

**Índices**: `bloque_id`, `caso_id`. **Restricción**: `UNIQUE (bloque_id, codigo_item)`.

**Reglas**:
- Cuando todos los ítems de un bloque están marcados, `checklist_bloques.completado` se actualiza a `true`.
- El backend evalúa bloques con `critico = true` antes de permitir la transición a `pendiente_revision`.

---

### 13. `conclusion_operativa`

Conclusión operativa del caso. Apartado 8, U008.
Relación uno a uno con `casos`.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | |
| `caso_id` | UUID | FK casos.id, NOT NULL, UNIQUE | |
| `hechos_sintesis` | TEXT | nullable | Bloque 1 — hechos en una oración. |
| `cargo_imputado` | TEXT | nullable | Bloque 1 — cargo imputado. |
| `evaluacion_dogmatica` | TEXT | nullable | Bloque 1 — tipicidad, antijuridicidad, culpabilidad. |
| `fisuras_fortalezas` | TEXT | nullable | Bloque 1 — fisuras o fortalezas dogmáticas. |
| `fortalezas_acusacion` | TEXT | nullable | Bloque 2 — fortalezas de la acusación. |
| `debilidades_acusacion` | TEXT | nullable | Bloque 2 — debilidades de la acusación. |
| `prueba_defensa` | TEXT | nullable | Bloque 2 — prueba de la defensa. |
| `etapa_texto` | TEXT | nullable | Bloque 2 — etapa procesal y audiencias pendientes. |
| `oportunidades` | TEXT | nullable | Bloque 2 — oportunidades procesales. |
| `rangos_pena` | TEXT | nullable | Bloque 3 — rango de pena mínimo/medio/máximo. |
| `beneficios` | TEXT | nullable | Bloque 3 — beneficios disponibles. |
| `restricciones_subrogados` | TEXT | nullable | Bloque 3 — restricciones para subrogados. |
| `riesgos_prioritarios` | TEXT | nullable | Bloque 3 — riesgos prioritarios. |
| `opcion_a` | TEXT | nullable | Bloque 4 — opción A. |
| `consecuencias_a` | TEXT | nullable | |
| `opcion_b` | TEXT | nullable | Bloque 4 — opción B. |
| `consecuencias_b` | TEXT | nullable | |
| `opcion_c` | TEXT | nullable | Bloque 4 — opción C (si aplica). |
| `consecuencias_c` | TEXT | nullable | |
| `recomendacion` | TEXT | nullable | Bloque 5 — recomendación concreta. |
| `fundamento_recomendacion` | TEXT | nullable | Bloque 5 — fundamento. |
| `condicion_vigencia` | TEXT | nullable | Bloque 5 — condición de vigencia. |
| `observaciones` | TEXT | nullable | Observaciones adicionales. |
| `creado_en` | TIMESTAMP | NOT NULL, DEFAULT now() | |
| `actualizado_en` | TIMESTAMP | NOT NULL | |
| `creado_por` | UUID | FK usuarios.id, NOT NULL | |
| `actualizado_por` | UUID | FK usuarios.id, nullable | |

**Índices**: `caso_id` (único).

**Reglas**:
- Para la transición `aprobado_supervisor → listo_para_cliente`, los campos de los cinco bloques
  deben estar diligenciados y `recomendacion` no puede ser nulo ni vacío.

---

### 14. `revision_supervisor`

Registro de revisiones formales del supervisor sobre el caso.
Permite múltiples registros por caso para conservar el historial de devoluciones
y nuevas aprobaciones. Solo un registro puede tener `vigente = true` por caso.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | |
| `caso_id` | UUID | FK casos.id, NOT NULL | |
| `supervisor_id` | UUID | FK usuarios.id, NOT NULL | Supervisor que revisó. |
| `version_revision` | INTEGER | NOT NULL, DEFAULT 1 | Número de revisión. Se incrementa por cada ciclo. |
| `vigente` | BOOLEAN | NOT NULL, DEFAULT true | Solo un registro `vigente = true` por caso en cada momento. |
| `observaciones` | TEXT | NOT NULL | Observaciones del supervisor. No puede ser vacío. |
| `fecha_revision` | DATE | nullable | |
| `resultado` | ENUM | NOT NULL | `aprobado`, `devuelto`. |
| `creado_en` | TIMESTAMP | NOT NULL, DEFAULT now() | |
| `creado_por` | UUID | FK usuarios.id, NOT NULL | Usuario que creó el registro (coincide con supervisor_id en operación normal). |

**Naturaleza**: append-only. Los registros no se modifican — solo se crean. El campo
`vigente` se actualiza exclusivamente en el registro anterior al crear uno nuevo
(de `true` a `false`).

**Índices**: `caso_id`, `supervisor_id`.
**Restricción**: `UNIQUE (caso_id) WHERE vigente = true` (índice parcial PostgreSQL).
Esta restricción materializa la regla de unicidad — no puede existir más de un
registro vigente por caso en ningún momento.

**Reglas**:
- Para la transición `pendiente_revision → aprobado_supervisor`, debe existir
  un registro con `vigente = true`, `resultado = 'aprobado'` y `observaciones` no vacío.
- Para la transición `pendiente_revision → devuelto`, debe existir
  un registro con `vigente = true`, `resultado = 'devuelto'` y `observaciones` no vacío.
- Al crear una nueva revisión, la anterior debe marcarse con `vigente = false`
  antes de insertar el nuevo registro con `vigente = true`.
- `version_revision` se calcula como `MAX(version_revision) + 1` para el caso.

---

### 15. `documentos`

Archivos adjuntos vinculados al caso.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | |
| `caso_id` | UUID | FK casos.id, NOT NULL | |
| `categoria` | ENUM | NOT NULL | `acusacion`, `defensa`, `cliente`, `actuacion`, `informe`, `evidencia`, `anexo`, `otro`. |
| `nombre_original` | VARCHAR(255) | NOT NULL | Nombre del archivo al momento de la subida. |
| `nombre_almacenado` | VARCHAR(255) | NOT NULL | Nombre interno en el almacenamiento. |
| `ruta` | TEXT | NOT NULL | Ruta relativa en el sistema de almacenamiento. |
| `mime_type` | VARCHAR(100) | NOT NULL | Tipo MIME del archivo. |
| `tamanio_bytes` | BIGINT | NOT NULL | |
| `descripcion` | TEXT | nullable | Descripción opcional del documento. |
| `subido_en` | TIMESTAMP | NOT NULL, DEFAULT now() | |
| `subido_por` | UUID | FK usuarios.id, NOT NULL | |

**Índices**: `caso_id`, `categoria`.

---

### 16. `informes_generados`

Registro de los informes producidos por el sistema.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | |
| `caso_id` | UUID | FK casos.id, NOT NULL | |
| `tipo_informe` | ENUM | NOT NULL | `resumen_ejecutivo`, `conclusion_operativa`, `control_calidad`, `riesgos`, `cronologico`, `revision_supervisor`, `agenda_vencimientos`. |
| `formato` | ENUM | NOT NULL | `pdf`, `docx`. |
| `ruta_archivo` | TEXT | NOT NULL | Ruta al archivo generado. |
| `estado_caso_al_generar` | VARCHAR(50) | NOT NULL | Estado del caso en el momento de la generación. |
| `generado_en` | TIMESTAMP | NOT NULL, DEFAULT now() | |
| `generado_por` | UUID | FK usuarios.id, NOT NULL | |

**Índices**: `caso_id`.

---

### 17. `ai_request_log`

Registro de todas las consultas al módulo de IA. Obligatorio por R05 y R06.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | |
| `caso_id` | UUID | FK casos.id, NOT NULL | |
| `usuario_id` | UUID | FK usuarios.id, NOT NULL | |
| `herramienta` | VARCHAR(60) | NOT NULL | Herramienta sobre la que se consultó. |
| `proveedor` | VARCHAR(60) | NOT NULL | Proveedor de IA utilizado. |
| `modelo` | VARCHAR(80) | NOT NULL | Modelo específico invocado. |
| `prompt_enviado` | TEXT | NOT NULL | Prompt completo enviado al proveedor. |
| `respuesta_recibida` | TEXT | nullable | Respuesta completa del proveedor. |
| `tokens_entrada` | INTEGER | nullable | |
| `tokens_salida` | INTEGER | nullable | |
| `duracion_ms` | INTEGER | nullable | Duración de la llamada en milisegundos. |
| `estado_llamada` | ENUM | NOT NULL | `exitosa`, `fallida`, `timeout`. |
| `error_mensaje` | TEXT | nullable | Mensaje de error si `estado_llamada != exitosa`. |
| `creado_en` | TIMESTAMP | NOT NULL, DEFAULT now() | |

**Índices**: `caso_id`, `usuario_id`, `creado_en`.

**Reglas**:
- Este registro es inmutable. No se actualiza ni elimina.
- La respuesta de la IA no puede escribirse directamente en ningún campo del caso.

---

### 18. `eventos_auditoria`

Bitácora de acciones críticas del sistema. Obligatorio por R06.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK | |
| `caso_id` | UUID | FK casos.id, nullable | Nulo solo para acciones sin caso (ej: login). |
| `usuario_id` | UUID | FK usuarios.id, NOT NULL | |
| `tipo_evento` | VARCHAR(60) | NOT NULL | Ej: `transicion_estado`, `informe_generado`, `revision_supervisor`, `login`, `eliminacion_caso`. |
| `estado_origen` | VARCHAR(50) | nullable | Estado del caso antes de la acción (si aplica). |
| `estado_destino` | VARCHAR(50) | nullable | Estado del caso después de la acción (si aplica). |
| `resultado` | ENUM | NOT NULL | `exitoso`, `rechazado`. |
| `motivo_rechazo` | TEXT | nullable | Detalle del rechazo si `resultado = rechazado`. |
| `metadata` | JSONB | nullable | Información adicional contextual. |
| `fecha_evento` | TIMESTAMP | NOT NULL, DEFAULT now() | |

**Índices**: `caso_id`, `usuario_id`, `tipo_evento`, `fecha_evento`.

**Reglas**:
- Este registro es inmutable. No se actualiza ni elimina.
- Toda transición de estado genera un evento, sea exitosa o rechazada.

---

## Diagrama de relaciones (resumen)

```
usuarios ─────────────────────────────────────────────────┐
   │                                                       │
clientes ──→ casos ──→ hechos                             │
              │    ──→ linea_tiempo                        │
              │    ──→ pruebas                             │
              │    ──→ riesgos                             │
              │    ──→ estrategia ──→ actuaciones          │
              │    ──→ explicacion_cliente                 │
              │    ──→ checklist_bloques ──→ checklist_items
              │    ──→ conclusion_operativa                │
              │    ──→ revision_supervisor                 │
              │    ──→ documentos                         │
              │    ──→ informes_generados                  │
              │    ──→ ai_request_log ────────────────────┘
              └────→ eventos_auditoria
```

---

## Reglas de integridad transversal

**RI-01** — Ningún campo de `estado_actual` en `casos` puede modificarse
directamente por SQL fuera del servicio `CasoEstadoService`.

**RI-02** — Un caso en estado `cerrado` no puede tener ningún registro
de herramienta operativa actualizado. El backend rechaza toda escritura.

**RI-03** — Los registros de `ai_request_log` y `eventos_auditoria`
son inmutables: no admiten `UPDATE` ni `DELETE`.

**RI-04** — Al crear un caso, el sistema debe generar automáticamente
los registros de `checklist_bloques` e `checklist_items` correspondientes,
los registros vacíos de `estrategia`, `explicacion_cliente` y `conclusion_operativa`.

**RI-05** — `checklist_bloques.completado` es un campo calculado.
Debe actualizarse mediante trigger o lógica de servicio cada vez que
un ítem de ese bloque cambia su campo `marcado`.
