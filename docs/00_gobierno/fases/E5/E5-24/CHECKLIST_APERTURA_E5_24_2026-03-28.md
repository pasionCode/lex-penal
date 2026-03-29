# CHECKLIST APERTURA E5-24 — AI: ALINEACIÓN CONTRACTUAL Y VALIDACIÓN RUNTIME

**Fecha:** 2026-03-28
**Unidad:** E5-24
**Tipo:** Alineación contractual + Validación runtime

---

## 1. OBJETIVO

Validar y documentar el endpoint `POST /ai/query` con su request/response body, códigos de error reales, y depurar inconsistencia de 503.

---

## 2. NATURALEZA DEL HITO

**Fase A:** Validación runtime (13 pruebas)
**Fase B:** Alineación contractual (si runtime OK)

---

## 3. TESIS OPERATIVA

`POST /ai/query` es un endpoint transversal que recibe consultas IA sobre herramientas del caso. En MVP usa placeholder sin proveedor real. Retorna 409 para casos cerrados.

---

## 4. ENDPOINT A VALIDAR

| Endpoint | Método | Comportamiento |
|----------|--------|----------------|
| `/ai/query` | POST | Consulta IA sobre herramienta del caso |

**Guard:** JwtAuthGuard
**Nota:** Ruta transversal, no anidada bajo `/cases/:caseId`

---

## 5. REQUEST BODY (AIQueryDto)

| Campo | Tipo | MaxLength | Obligatorio |
|-------|------|-----------|-------------|
| `caso_id` | UUID | - | Sí |
| `herramienta` | enum | - | Sí |
| `consulta` | string | 2000 | Sí |

**Enum HerramientaIA:**
`basic_info`, `facts`, `evidence`, `risks`, `strategy`, `client_briefing`, `checklist`, `conclusion`

---

## 6. RESPONSE BODY (AIResponse)

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `respuesta` | string | Texto de respuesta |
| `tokens_entrada` | number | Tokens consumidos en entrada |
| `tokens_salida` | number | Tokens generados en salida |
| `modelo_usado` | string | Identificador del modelo |

**MVP:** `modelo_usado` = `placeholder_v1`

---

## 7. LÓGICA DE VALIDACIÓN

| Paso | Validación | Error |
|------|------------|-------|
| 1 | Token presente | 401 |
| 2 | Caso existe | 404 |
| 3 | Ownership (estudiante) | 403 |
| 4 | Estado ≠ cerrado | 409 |
| 5 | Payload válido | 400 |

---

## 8. REGLAS DE ACCESO

| Escenario | Código |
|-----------|--------|
| Admin con caso válido | 200 |
| Estudiante responsable | 200 |
| Estudiante ajeno | 403 |
| Caso cerrado | 409 |

*Supervisor: comportamiento esperado según código, no validado en runtime.

---

## 9. CRITERIOS DE ACEPTACIÓN (14 pruebas)

| # | Criterio | Código esperado |
|---|----------|-----------------|
| 01 | Login admin | 200 |
| 02 | POST /clients | 201 |
| 03 | POST /cases | 201 |
| 04 | Activar caso | 200/201 |
| 05 | POST /ai/query (consulta válida) | 201 |
| 06 | Validar shape estricto (modelo=placeholder_v1, tokens numéricos) | - |
| 07 | POST /ai/query (herramienta inválida) | 400 |
| 08 | POST /ai/query (consulta vacía) | 400 |
| 09 | POST /ai/query (consulta > 2000) | 400 |
| 10 | POST /ai/query (caso_id formato inválido o inexistente) | 400/404 |
| 11 | POST /ai/query sin token | 401 |
| 12 | POST /ai/query (estudiante ajeno) | 403 |
| 13 | Cerrar caso | 200/201 o SKIP |
| 14 | POST /ai/query (caso cerrado) | 409 o SKIP |

**Notas:**
- **Prueba 05:** Retorna `201` porque el endpoint registra trazabilidad además de responder.
- **Prueba 10:** Retorna `400` si `caso_id` tiene formato inválido; `404` si el formato es válido pero el caso no existe. El script acepta ambos.
- **Pruebas 13-14:** Condicionadas por alcanzabilidad del estado `cerrado`. Si no es alcanzable, se marcan como SKIP y el módulo AI se considera válido con 12 PASS.

---

## 10. DECISIÓN SOBRE 503

**Contrato actual:** Documenta `503 — Proveedor de IA no disponible`
**Implementación MVP:** No hay proveedor real, usa placeholder local

**Decisión:** Retirar 503 del contrato vigente. Se agregará cuando exista proveedor real.

---

## 11. FUERA DE ALCANCE

- Integración con proveedor IA real
- Código 503 (no aplica en MVP)
- Cambios estructurales al módulo

---

## 12. DIFF CONTRACTUAL

### Ubicación
`docs/04_api/CONTRATO_API.md`, sección **9. Módulo de IA**

Buscar por encabezado `### 9. Módulo de IA`, no por número de línea.

### Cambios
- Agregar request body (AIQueryDto)
- Agregar response body (AIResponse)
- Agregar código 401
- Agregar código 409 (caso cerrado)
- Retirar código 503 (no aplica en MVP)
- Agregar nota de naturaleza MVP

---

## 13. SECUENCIA DE EJECUCIÓN

```bash
# Fase A: Validación runtime
chmod +x test_e5_24.sh
./test_e5_24.sh
npm run build

# Fase B: Aplicar diff contractual (si runtime OK)
```

---

## 14. CRITERIO DE CIERRE

| Resultado | Acción |
|-----------|--------|
| Runtime conforme + contrato actualizado + build verde | E5-24 cierra |
