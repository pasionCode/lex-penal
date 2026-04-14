# NOTA DE CIERRE UNIDAD E22-02 — 2026-04-14

## 1. Identificación
- Fase: E22
- Unidad: E22-02
- Nombre: Normalización semántica y contractual de Strategy
- Estado: CERRADA

## 2. Objetivo de la unidad
Verificar y alinear la semántica real de acceso, autocreación, escritura por estado y errores del módulo Strategy respecto al contrato.

## 3. Resultado
Unidad cumplida.

## 4. Hallazgo determinante
- El contrato de Strategy describía comportamiento de `client-briefing` dentro de la sección equivocada.
- El service de Strategy auto-creaba en `GET` y permitía `PUT` sin controlar estados del caso.
- La semántica correcta exigía restringir autocreación y escritura a estados habilitados.

## 5. Medidas aplicadas
- Se corrigió `strategy.service.ts` para:
  - permitir autocreación en `GET` solo en estados con escritura;
  - rechazar con `409` cuando el estado no lo permite;
  - restringir `PUT` a `en_analisis`, `devuelto` y `listo_para_cliente`.
- Se agregó `getCaseState(casoId)` al repositorio.
- Se corrigió `CONTRATO_API.md` para reflejar el comportamiento real de Strategy y su `409`.

## 6. Validación
- El proyecto compiló correctamente después del ajuste.
- Contrato y service quedaron alineados con la semántica funcional esperada del módulo.

## 7. Decisión de cierre
Se cierra E22-02 y se abre E22-03 para cierre formal de fase E22.
