# CHECKLIST DE APERTURA — SPRINT 15

## 1. Identificación

- Proyecto: LEX_PENAL
- Fase: E5 — Expansión funcional controlada
- Sprint: Sprint 15
- Fecha de apertura: 2026-03-27
- Estado: LISTO PARA CIERRE

---

## 2. Micronota metodológica de arranque

Sprint 15 abre un nuevo frente después del cierre limpio de `proceedings` en Sprint 14.

Reglas de conducción:

- partir de `working tree clean`
- no reabrir `proceedings` sin brecha probada o decisión funcional formal
- no mezclar expansión funcional con refactor transversal amplio
- validar contrato, modelo y exposición HTTP antes de implementar
- no documentar como operativo nada no probado en runtime
- mantener alcance pequeño, demostrable y cerrable en un sprint
- cerrar con evidencia mínima: build, humo, positivas, negativas, contrato, baseline y nota de cierre

---

## 3. Política del sprint

### Política confirmada

**B — Expansión a otro subrecurso funcional**

### Conducción

**B1 — Expansión mínima vertical**
Contrato + módulo + runtime + cierre documental, sin abrir hardening transversal ni refactor estructural.

### Objetivo

Abrir y validar un subrecurso funcional nuevo o pendiente del caso, con alcance mínimo demostrable, consistente con el contrato y alineado con la política general del sistema.

### Alcance permitido

- contrato API del subrecurso objetivo
- DTOs del subrecurso
- controller del subrecurso
- service del subrecurso
- repository del subrecurso
- pruebas runtime del flujo mínimo
- baseline y nota de cierre del sprint

### Exclusiones expresas

- no reabrir `proceedings`
- no introducir `PUT` o `DELETE` si no están expresamente aprobados
- no abrir infraestructura
- no tocar `main.ts` ni validaciones globales
- no hacer refactor transversal amplio
- no intervenir módulos ajenos al foco del sprint

---

## 4. Checklist de apertura

### A. Higiene de arranque

- [x] `git status` limpio
- [x] rama `main` sincronizada con `origin/main`
- [x] `npm run build` exitoso
- [x] aplicación levanta sin errores críticos
- [x] token JWT vigente para pruebas

### B. Delimitación del sprint

- [x] Sprint 14 cerrado
- [x] `proceedings` no requiere reapertura técnica
- [x] política del sprint definida: expansión funcional
- [x] conducción definida: B1 expansión mínima vertical
- [x] subrecurso objetivo confirmado: `subjects`
- [x] criterio de cierre acordado

### C. Selección del foco

- [x] identificar subrecurso candidato: `subjects`
- [x] revisar si ya existe contrato parcial o deuda previa: no existía
- [x] revisar si existe módulo scaffold o implementación incompleta: no existía
- [x] confirmar alcance mínimo del sprint: GET, POST, GET by ID
- [x] registrar exclusiones expresas del subrecurso: sin PUT/DELETE

### D. Baseline previo

- [x] revisar contrato API del subrecurso: no existía
- [x] revisar modelo de datos relacionado: no existía
- [x] revisar exposición HTTP actual: 404 Cannot GET
- [x] verificar si hay endpoints ya activos: ninguno
- [x] ejecutar humo sobre endpoint existente o confirmar ausencia controlada
- [x] capturar evidencia previa
- [x] definir mini-regresión del sprint

### E. Implementación mínima

- [x] DTOs alineados con contrato
- [x] endpoint principal implementado
- [x] persistencia básica implementada
- [x] validaciones esenciales implementadas
- [x] respuesta HTTP coherente
- [x] sin refactor amplio fuera del foco

### F. Validación

- [x] prueba positiva principal verde
- [x] persistencia confirmada
- [x] negativa `400` por payload inválido
- [x] negativa `404` por `caseId` inexistente
- [x] negativa `404` o comportamiento esperado para recurso inexistente
- [x] mini-regresión verde
- [x] build final verde

### G. Documentación y cierre

- [x] baseline documentado
- [x] contrato revisado contra runtime
- [x] nota de cierre emitida
- [ ] commit realizado
- [ ] push realizado
- [ ] `git status` final limpio

---

## 5. Ruta operativa sugerida

1. higiene
2. seleccionar subrecurso objetivo
3. revisar contrato y modelo
4. baseline HTTP real
5. definir alcance mínimo demostrable
6. implementación mínima
7. build
8. humo
9. positivas
10. negativas
11. mini-regresión
12. revisión contrato vs runtime
13. nota de cierre
14. commit y push

---

## 6. Criterio de cierre

Sprint 15 solo podrá declararse cerrado cuando:

- [x] el subrecurso objetivo tenga alcance mínimo operativo
- [x] exista evidencia positiva y negativa en runtime
- [x] el contrato no contradiga el runtime
- [x] no se haya abierto refactor transversal fuera del foco
- [x] la nota de cierre esté emitida
- [ ] el repositorio quede limpio

---

## 7. Pregunta de conducción específica del Sprint 15

**¿Qué conviene más abrir ahora?**

| Opción | Descripción | Cuándo aplicar |
|--------|-------------|----------------|
| **A** | Decisión funcional sobre XOR en `proceedings` | Solo si negocio exige definición inmediata |
| **B** | Abrir un nuevo subrecurso funcional | Opción preferida tras cierre limpio de S14 |
| **C** | Hardening de otro módulo existente | Si aparece brecha crítica ya identificada |

**Decisión recomendada:** **B — Abrir un nuevo subrecurso funcional**.

---

## 8. Relación con Sprint 14

| Sprint 14 | Sprint 15 |
|-----------|-----------|
| Cerró hardening de `proceedings` | No reabre `proceedings` sin nueva decisión |
| Validó contrato vs runtime | Abre capacidad nueva con la misma disciplina |
| Exploró A2 sin brecha | Deja XOR como posible decisión futura |
| Cerró repositorio limpio | Parte desde base estable |

---

*Documento actualizado: 2026-03-27*  
*Sprint 15 — Fase E5 — LISTO PARA CIERRE*
