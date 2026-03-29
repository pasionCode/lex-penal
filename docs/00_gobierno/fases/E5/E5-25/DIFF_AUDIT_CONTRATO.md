# DIFF CONTRACTUAL E5-25 — RETIRO DE AUDIT DEL MVP

## Acción 1: Eliminar sección 10. Auditoría
Eliminar del contrato la sección:

### 10. Auditoría

#### `GET /api/v1/cases/{caseId}/audit`
Lista los eventos de auditoría del caso. Solo Supervisor y Administrador.

**Parámetros opcionales**
- `tipo` — filtra por tipo de evento.
- `page`, `per_page` — paginación.

---

## Acción 2: Agregar sección de módulos diferidos
Insertar antes del historial de cambios:

---

## Módulos diferidos (fuera de MVP)

### Auditoría

El módulo `audit` (`GET /api/v1/cases/{caseId}/audit`) no está implementado en el MVP actual. El scaffolding existe, pero no tiene lógica funcional ni controles de acceso operativos. Su implementación queda diferida para una fase posterior.

---

## Acción 3: Agregar fila al historial
Agregar al inicio del historial:

| E5-25 | 2026-03-28 | Retiro de `audit` del contrato MVP. Módulo diferido por no tener implementación funcional (scaffolding sin lógica). |

## Acción 4: Actualizar metadatos
- `| Última revisión | 2026-03-28 (E5-25) |`
- `*Documento actualizado: 2026-03-28 (E5-25)*`
