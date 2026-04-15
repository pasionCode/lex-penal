# CHECKLIST APERTURA UNIDAD E35-01 — 2026-04-14

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E35
- Unidad: E35-01
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo específico
Delimitar, endurecer y validar la política de acceso y ejecución del módulo AI en función del estado del caso, asegurando coherencia con la lógica de negocio, la máquina de estados y el contrato API vigente.

## 3. Alcance
- Revisar restricciones de uso del módulo AI según estado del caso.
- Verificar alineación entre controlador, servicio y reglas de negocio.
- Confirmar respuesta esperada para estados no habilitados.
- Determinar si el contrato API requiere ajuste o precisión.
- Preparar validación runtime específica para este bloque.

## 4. Fuera de alcance
- Rediseño funcional amplio del módulo AI.
- Cambios de UX o frontend.
- Refactor general no requerido por el objetivo de la unidad.
- Ajustes ajenos a la política de estados del caso.

## 5. Evidencia esperada
- Baseline de unidad emitido.
- Hallazgo técnico delimitado.
- Cambios mínimos y trazables en código y/o contrato, si aplican.
- Validación runtime reproducible.
- Nota de cierre de unidad.

## 6. Criterio de cierre
La unidad se considerará cerrada cuando:
- exista regla clara y verificable para el uso del módulo AI según estado del caso;
- el comportamiento runtime sea consistente con dicha regla;
- el contrato quede alineado si hubo necesidad de ajuste;
- exista evidencia suficiente para cierre formal.

## 7. Estado de apertura
- [x] Unidad creada documentalmente
- [x] Checklist de apertura emitido
- [x] Baseline de unidad emitido
- [ ] Hallazgo técnico fijado
- [ ] Implementación ejecutada
- [ ] Validación runtime ejecutada
- [ ] Nota de cierre emitida
