# NOTA DE CIERRE UNIDAD E19-02 — 2026-04-14

## 1. Identificación
- Fase: E19
- Unidad: E19-02
- Nombre: Normalización de acceso y semántica de errores de Subjects
- Estado: CERRADA

## 2. Objetivo de la unidad
Verificar y alinear las reglas de acceso, ownership y semántica de errores del módulo Subjects respecto al resto de subrecursos case-scoped del backend.

## 3. Resultado
Unidad cumplida.

## 4. Hallazgo determinante
- El módulo Subjects estaba protegido solo por autenticación JWT.
- No evidenciaba control de acceso case-scoped equivalente al de otros subrecursos del caso.
- El contrato tampoco reflejaba explícitamente `401` y `403` para sus operaciones principales.

## 5. Medidas aplicadas
- Se pasó contexto de usuario al servicio en listado y detalle.
- Se incorporó verificación de acceso por ownership para perfil estudiante.
- Se agregó `getCaseResponsable(caseId)` al repositorio.
- Se alineó `CONTRATO_API.md` con la semántica de acceso y errores de Subjects.

## 6. Regla funcional consolidada
- Supervisor y Administrador: acceso permitido.
- Estudiante: solo sobre casos donde sea responsable.
- Caso inexistente: `404`.
- Caso existente sin acceso: `403`.

## 7. Validación
- El proyecto compiló correctamente después del ajuste.
- El módulo Subjects quedó alineado con la semántica case-scoped del backend.

## 8. Decisión de cierre
Se cierra E19-02 y se abre E19-03 para cierre formal de fase E19.
