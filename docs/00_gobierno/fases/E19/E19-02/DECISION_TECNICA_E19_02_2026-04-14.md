# DECISIÓN TÉCNICA E19-02 — 2026-04-14

## Hallazgo
El módulo Subjects no evidencia, en su implementación visible, control de acceso case-scoped equivalente al de otros subrecursos del caso.

## Decisión
Aplicar control de acceso por ownership para perfil estudiante en:
- GET /api/v1/cases/{caseId}/subjects
- GET /api/v1/cases/{caseId}/subjects/{subjectId}
- POST /api/v1/cases/{caseId}/subjects

## Regla funcional
- Supervisor y Administrador: acceso permitido.
- Estudiante: solo sobre casos donde sea responsable.
- Caso inexistente: 404.
- Caso existente sin acceso: 403.

## Alcance contractual
Actualizar CONTRATO_API.md para reflejar explícitamente 401/403 y la regla de acceso por caso.
