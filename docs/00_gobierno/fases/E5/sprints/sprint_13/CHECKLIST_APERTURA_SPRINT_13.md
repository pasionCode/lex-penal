# CHECKLIST DE APERTURA — SPRINT 13

## 1. Identificación

- Proyecto: LEX_PENAL
- Fase: E5 — Expansión funcional controlada
- Sprint: Sprint 13
- Foco: `proceedings`
- Estado: LISTO PARA CIERRE

---

## 2. Micronota metodológica de arranque

Antes de abrir Sprint 13 se preservan estas reglas:

- partir de `working tree clean`
- no abrir alcance sin política explícita
- no asumir que el contrato vigente refleja runtime sin baseline
- no documentar como operativo nada no probado en runtime
- no abrir edición o eliminación sin decisión formal
- mantener un solo foco funcional por sprint
- cerrar con evidencia mínima: build, humo, negativas, regresión, nota de cierre, commit y push

---

## 3. Checklist de apertura

### A. Higiene de arranque

- [x] `git status` limpio
- [x] rama `main` sincronizada con `origin/main`
- [x] `npm run build` exitoso
- [x] aplicación levanta sin errores críticos
- [x] token JWT vigente para pruebas

### B. Delimitación del sprint

- [x] foco funcional definido: `proceedings`
- [x] política del recurso definida: **A — Append-only**
- [x] alcance explícitamente acotado: alta y consulta
- [x] exclusiones expresas registradas: `PUT`, `DELETE`, refactor transversal, infraestructura
- [x] criterio de cierre acordado: runtime validado y contrato no contradictorio

### C. Baseline previo

- [x] validar `GET /cases/{id}/proceedings`
- [x] validar `POST /cases/{id}/proceedings`
- [x] validar `GET /cases/{id}/proceedings/{proc_id}`
- [x] verificar si `PUT` existe realmente en runtime
- [x] verificar si `DELETE` existe realmente en runtime
- [x] capturar evidencia positiva y negativa
- [x] identificar regresión mínima asociada

### D. Implementación

- [x] ajustar solo capas autorizadas por la política elegida
- [x] DTOs ajustados si aplica
- [x] controller ajustado si aplica
- [ ] service ajustado si aplica (no requerido)
- [ ] repository ajustado si aplica (no requerido)
- [x] sin refactor amplio fuera del foco

### E. Validación

- [x] prueba positiva principal
- [x] persistencia confirmada
- [ ] negativa `400` (no ejecutada en este sprint)
- [x] negativa `404`
- [x] mini-regresión verde
- [x] build final verde

### F. Documentación y cierre

- [x] baseline documentado
- [x] contrato revisado contra runtime
- [x] nota de cierre emitida
- [ ] commit realizado
- [ ] push realizado
- [ ] `git status` final limpio

---

## 4. Restricciones iniciales

Durante Sprint 13 no se debe:

- abrir infraestructura nueva
- introducir `DELETE` sin decisión formal
- mezclar `proceedings` con otros subrecursos
- hacer refactor transversal amplio
- tocar `main.ts` o validaciones globales sin política expresa
- actualizar contrato antes de validar runtime

---

## 5. Ruta operativa sugerida

1. higiene
2. decisión de política
3. baseline runtime de `proceedings`
4. contraste contrato vs runtime
5. implementación mínima
6. build
7. humo
8. negativas
9. regresión
10. ajuste contractual si aplica
11. nota de cierre
12. commit y push

---

## 6. Criterio de cierre

Sprint 13 solo podrá declararse cerrado cuando:

- [x] la política de `proceedings` quede formalmente definida
- [x] el cambio esté probado en runtime
- [x] exista evidencia positiva y negativa
- [x] la regresión mínima esté verde
- [x] el contrato no contradiga el runtime
- [x] la nota de cierre esté emitida
- [ ] el repositorio quede limpio

---

## 7. Pregunta de conducción del Sprint 13

**¿Qué política adoptamos para `proceedings`?**

### Opción A — Append-only ✅ SELECCIONADA

- Conservar `GET`, `POST`, `GET detalle`
- No habilitar `PUT`
- No habilitar `DELETE`

### Opción B — Editable controlado

- Conservar `GET`, `POST`, `GET detalle`
- Habilitar `PUT` solo para campos definidos por política
- No habilitar `DELETE`

### Opción C — CRUD amplio

- Convalidar `PUT` y `DELETE`
- Ajustar runtime para igualar contrato actual

**Recomendación de entrada:** A  
**Recomendación máxima admisible en este sprint:** B

---

## 8. Estado del módulo (evidencia)

**Estructura en backend:**
```
src/modules/proceedings/
├── dto/
├── proceedings.controller.ts
├── proceedings.module.ts
├── proceedings.repository.ts
└── proceedings.service.ts
```

**Contrato previo al ajuste:** GET, POST, GET detalle, PUT, DELETE anunciados

**Contrato actual (post Sprint 13):** GET, POST, GET detalle — política append-only

**Hallazgo crítico:** PUT y DELETE existían en runtime con lógica activa. Se removió exposición HTTP del controller.

---

*Documento actualizado: 2026-03-26*  
*Sprint 13 — Fase E5 — LISTO PARA CIERRE*
