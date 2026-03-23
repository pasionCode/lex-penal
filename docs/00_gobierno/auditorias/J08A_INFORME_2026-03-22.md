# INFORME DE AUDITORÍA J08-A — LEX_PENAL

## Alcance
Auditoría sobre snapshot del repositorio `LEX_PENAL.zip`, contrastado contra `METODOLOGIA_DESARROLLO_SOFTWARE_v2.1.md`.

## Dictamen
- **Proyecto frente al MDS:** **Proyecto parcialmente conforme al MDS**
- **MDS como método:** **MDS funcional pero con observaciones**

## Validaciones ejecutadas
- Inspección de estructura del repositorio, docs, `prisma/`, `src/`, `tests/`, `.git`.
- Revisión de `git log`.
- Compilación estática con `node node_modules/@nestjs/cli/bin/nest.js build` ✅
- `npm run build` en el snapshot falló por permisos del binario `node_modules/.bin/nest`; no se trató como hallazgo del repo versionado porque `node_modules/` no está trackeado.
- `prisma validate` no pudo cerrarse en este entorno por limitación de red al descargar engine de Prisma.

## Hallazgos críticos

### C-01 — Documento de conducción desactualizado y contradictorio
El documento canónico de conducción sigue declarando al proyecto en cierre de E0, con última jornada J03 y GATE-00 pendiente:
- `docs/00_gobierno/LEX_PENAL_SISTEMA_CONDUCCION.md:67-73`
- `docs/00_gobierno/LEX_PENAL_SISTEMA_CONDUCCION.md:330-340`
- `docs/00_gobierno/LEX_PENAL_SISTEMA_CONDUCCION.md:437-444`
- `docs/00_gobierno/LEX_PENAL_SISTEMA_CONDUCCION.md:498-505`

Pero el propio repositorio ya contiene:
- cierre de GATE-00: `docs/00_gobierno/ACTA_CIERRE_GATE_00_2026-03-20.md`
- cierre de GATE-01 y habilitación de E2: `docs/00_gobierno/NOTA_CIERRE_JORNADA_04_2026-03-20.md:381-419`
- cierre de GATE-02 y habilitación de E3: `docs/00_gobierno/NOTA_CIERRE_JORNADA_05_2026-03-20.md:557-607`
- Sprint 1 completado: `docs/00_gobierno/NOTA_CIERRE_JORNADA_07_2026-03-22.md:128-165`

**Impacto:** rompe la trazabilidad oficial del proyecto y deja el artefacto rector contando una historia distinta a la del repo.

### C-02 — Incumplimiento histórico del principio de código diferido
El MDS prohíbe código productivo antes de GATE-02:
- `METODOLOGIA_DESARROLLO_SOFTWARE_v2.1.md:50-54`

Sin embargo, en J03 se declara como “base técnica” la materialización de `CasoEstadoService`:
- `docs/00_gobierno/NOTA_CIERRE_JORNADA_03.md:18-21`
- `docs/00_gobierno/NOTA_CIERRE_JORNADA_03.md:29-40`
- `docs/00_gobierno/NOTA_CIERRE_JORNADA_03.md:85-103`

Y el archivo contiene lógica de negocio real:
- `src/modules/cases/services/caso-estado.service.ts:83-214`

Además, el histórico de commits muestra esa pieza antes del cierre de GATE-00/GATE-01/GATE-02:
- `git log --reverse`: `76142fa feat(scaffold)...` antes de `ca024d5` (J04) y `a523cde` (J05)

**Impacto:** hubo una clasificación permisiva de lógica de dominio como scaffold/infrastructura.

### C-03 — Rutas reales inconsistentes con el contrato API
`main.ts` aplica prefijo global `api/v1`:
- `src/main.ts:7-18`

Pero múltiples controllers vuelven a declarar `api/v1/...` en su decorator:
- `src/modules/cases/cases.controller.ts:20`
- `src/modules/clients/clients.controller.ts:13`
- `src/modules/facts/facts.controller.ts:11`
- `src/modules/risks/risks.controller.ts:10`
- `src/modules/review/review.controller.ts:14`
- `src/modules/reports/reports.controller.ts:16`
- etc.

El contrato API documenta rutas del tipo `/api/v1/cases`, `/api/v1/cases/{id}`, `/api/v1/cases/{id}/transition`:
- `docs/04_api/CONTRATO_API_v4.md:282-403`

Con la configuración actual, esas rutas quedarían duplicadas (`/api/v1/api/v1/...`) para los módulos que hardcodean el prefijo.

Más grave: J07 documenta como decisión que el “Prefijo global” evita duplicación en controllers:
- `docs/00_gobierno/NOTA_CIERRE_JORNADA_07_2026-03-22.md:68-77`

**Impacto:** contradicción directa entre gobierno, contrato y código.

## Hallazgos mayores

### M-01 — Registro de riesgos y supuestos no encontrado como artefacto vivo
El MDS lo exige:
- `METODOLOGIA_DESARROLLO_SOFTWARE_v2.1.md:1010-1021`

En el repo no aparece un registro operativo de riesgos/supuestos; la propia matriz de verificación lo deja “NO VERIFICADO”:
- `docs/00_gobierno/MATRIZ_VERIFICACION_MDS_LEX_PENAL_v0.2.md:82`

### M-02 — Las notas de cierre no siguen de manera uniforme la estructura MDS
El MDS exige resultado, pendientes, decisiones, próximo paso y clasificación MDS:
- `METODOLOGIA_DESARROLLO_SOFTWARE_v2.1.md:315-339`

J03 sí está cerca del formato. J04/J05/J06/J07 no mantienen de forma homogénea esa estructura ni la clasificación MDS explícita en el cuerpo del documento.

### M-03 — Artefactos de prueba desalineados con el estado real del código
Los smoke tests esperan `/health` y creación de caso:
- `tests/e2e/README.md:1-2`
- `tests/e2e/smoke.sh:3-7`

Pero no hay endpoint `health` en `src/`, y `CasesController` sigue en stub:
- `src/modules/cases/cases.controller.ts:24-40`

Además, el payload de `smoke.sh` no coincide con `CreateCaseDto`:
- `tests/e2e/smoke.sh:7`
- `src/modules/cases/dto/create-case.dto.ts:1-12`

Y la prueba unitaria referencia un archivo inexistente:
- `tests/unit/checklist-gate.test.mjs:3`

### M-04 — Sobredeclaración de readiness para Sprint 2
J07 afirma:
- “Usuario autenticado puede crear casos ✅”
- “Guard disponible para proteger rutas de casos ✅”
- “Decorador disponible para obtener userId ✅”
- `docs/00_gobierno/NOTA_CIERRE_JORNADA_07_2026-03-22.md:157-165`

Pero `CasesController`:
- no implementa endpoints (`throw new Error('not implemented')`)
- no usa `@UseGuards(JwtAuthGuard)`
- no usa `@CurrentUser()`
- `src/modules/cases/cases.controller.ts:1-40`

## Hallazgos menores

### m-01 — Metadatos incompletos en documentos canónicos
- `docs/03_datos/MODELO_DATOS_v3.md:12-15`
- `docs/04_api/CONTRATO_API_v4.md:15-18`

### m-02 — Cierre de GATE-01 y GATE-02 sin acta separada
No es incumplimiento automático en proyecto unipersonal, pero debilita auditabilidad. El cierre existe dentro de las notas J04/J05, no como actas dedicadas.

### m-03 — Persistencia de carpetas `old/Old`
No es una falta por sí sola, pero exige una política explícita de material obsoleto para no contaminar la canonicidad.

## Fortalezas reales del proyecto
- Existe taxonomía documental robusta en `docs/`.
- Hay sistema de conducción, backlog, modelo de datos, contrato API y ADRs.
- GATE-00 está formalizado con acta.
- J04 y J05 sí dejan evidencia material de cierre metodológico.
- La secuencia macro del repo es coherente: regularización → base ejecutable → diseño → Sprint 1 auth.
- El backend compila en estático.

## Evaluación del MDS
El MDS no aparece roto en su estructura base. Es un método serio y auditable. Sin embargo, la auditoría deja tres necesidades de endurecimiento:

1. **Acta de gate obligatoria para todos los gates**, incluso en proyectos unipersonales.
2. **Regla de sincronización obligatoria**: no cerrar gate/jornada sin actualizar en el mismo movimiento el documento de conducción.
3. **Regla anti-camuflaje de scaffold**: cualquier servicio con reglas de dominio, transiciones, guardas o persistencia de negocio cuenta como código productivo, aunque se llame “scaffold”.

## Plan de regularización recomendado
1. Actualizar inmediatamente `LEX_PENAL_SISTEMA_CONDUCCION.md` a estado real.
2. Emitir `ACTA_CIERRE_GATE_01` y `ACTA_CIERRE_GATE_02`, o un `ACTA_ESTADO_METODOLOGICO_J08A` que consolide ambos con referencia a J04/J05.
3. Crear `REGISTRO_RIESGOS_SUPUESTOS.md` y `REGISTRO_DESVIACIONES.md` vivos.
4. Registrar formalmente la desviación histórica por `CasoEstadoService` pre-GATE-02.
5. Normalizar estrategia de rutas: mantener prefijo global y quitar `api/v1/` de controllers.
6. Convertir stubs públicos a `NotImplementedException` o retirar módulos no habilitados del `AppModule`.
7. Corregir y realinear smoke tests, pruebas unitarias y documentación operativa.
8. Reemitir notas J06/J07 con clasificación MDS explícita y siguiente paso exacto.

## Veredicto final
- **Proyecto:** **Proyecto parcialmente conforme al MDS**
- **MDS:** **MDS funcional pero con observaciones**
