# NOTA DE CIERRE UNIDAD E28-02 — 2026-04-14

## 1. Identificación
- Fase: E28
- Unidad: E28-02
- Fecha de cierre: 2026-04-14
- Estado: CERRADA

## 2. Objetivo de la unidad
Construir un fixture reutilizable de seguridad para validar respuestas `403 Forbidden` entre estudiantes en recursos case-scoped.

## 3. Trabajo ejecutado
- Se abrió formalmente la unidad E28-02.
- Se realizó inventario de estudiantes activos y casos escribibles existentes.
- Se identificó que los casos escribibles estaban concentrados en el administrador, por lo que no existía fixture natural estudiante-vs-estudiante.
- Se provisionaron dos estudiantes fixture por API.
- Se reasignó un caso escribible de prueba al estudiante fixture A.
- Se obtuvo login real de A y B mediante `POST /api/v1/auth/login`.
- Se ejecutó validación runtime sobre recurso case-scoped (`GET /api/v1/cases/{caseId}/risks`).

## 4. Evidencia funcional verificada
- Login estudiante fixture A: exitoso.
- Login estudiante fixture B: exitoso.
- Acceso de A al caso propio: `200`.
- Acceso de B al caso de A: `403`.

## 5. Resultado
La unidad E28-02 queda cerrada satisfactoriamente.

Se deja instalado un harness reutilizable para validaciones futuras de aislamiento entre estudiantes en recursos case-scoped.

## 6. Impacto metodológico
Con este cierre queda resuelta la deuda menor de fixture de seguridad que había quedado documentada al cierre de E28-01.

## 7. Archivos impactados
- `docs/00_gobierno/fases/E28/E28-02/CHECKLIST_APERTURA_UNIDAD_E28_02_2026-04-14.md`
- `docs/00_gobierno/fases/E28/E28-02/BASELINE_UNIDAD_E28_02_2026-04-14.md`
- `docs/00_gobierno/fases/E28/E28-02/NOTA_CIERRE_UNIDAD_E28_02_2026-04-14.md`
- `docs/00_gobierno/fases/E28/E28-02/evidencias/DIAG_SECURITY_FIXTURE_2026-04-14.txt`
- `scripts/diag_e28_02_security_fixture.ts`
- `scripts/e28_02_assign_case_to_fixture_a.ts` 
  (si quedó persistido en repo)
- evidencia runtime de login y validación `200/403` en consola

## 8. Criterio de cierre
Se cierra E28-02 por cumplimiento del objetivo: validación runtime efectiva y reproducible del aislamiento `403` entre estudiantes.
