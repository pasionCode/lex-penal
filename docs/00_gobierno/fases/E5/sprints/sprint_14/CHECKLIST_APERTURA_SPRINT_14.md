# CHECKLIST DE APERTURA — SPRINT 14

## 1. Identificación

- Proyecto: LEX_PENAL
- Fase: E5 — Expansión funcional controlada
- Sprint: Sprint 14
- Fecha de apertura: 2026-03-26
- Estado: LISTO PARA CIERRE

---

## 2. Micronota metodológica de arranque

Sprint 14 no abre un subrecurso nuevo.  
Su foco es consolidar `proceedings` después del ajuste de política realizado en Sprint 13.

Reglas de conducción:

- partir de `working tree clean`
- no abrir alcance nuevo sin decisión formal
- validar baseline antes de intervenir
- no documentar como operativo nada no probado en runtime
- no reabrir `PUT` ni `DELETE`
- no mezclar hardening con expansión funcional de otros módulos
- cerrar con evidencia mínima: build, humo, negativas, regresión, contrato y nota de cierre

---

## 3. Política del sprint

### Política confirmada

**A — Hardening de `proceedings`**

### Conducción

**A3 — Hardening integral corto**, condicionado por baseline.  
Si aparecen muchas brechas, se reduce a **A1** (solo validaciones de payload).

### Objetivo

Endurecer validaciones, respuestas negativas y consistencia contractual del subrecurso `proceedings`, manteniendo la política **append-only**.

### Alcance permitido

- DTOs de `proceedings`
- controller de `proceedings`, solo si se requiere ajuste puntual de validación o respuesta
- service de `proceedings`, solo si se requiere coherencia mínima con reglas de negocio ya existentes
- repository de `proceedings`, solo si una validación depende de acceso consistente a datos
- pruebas runtime del subrecurso
- documentación de baseline y cierre

### Exclusiones expresas

- no reintroducir `PUT`
- no reintroducir `DELETE`
- no abrir infraestructura
- no abrir otros subrecursos
- no hacer refactor transversal amplio
- no tocar `main.ts` ni `ValidationPipe` global sin decisión formal

---

## 4. Checklist de apertura

### A. Higiene de arranque

- [x] `git status` limpio
- [x] rama `main` sincronizada con `origin/main`
- [x] `npm run build` exitoso
- [x] aplicación levanta sin errores críticos
- [x] token JWT vigente para pruebas

### B. Delimitación del sprint

- [x] foco funcional definido: `proceedings`
- [x] política del sprint definida: hardening append-only
- [x] conducción definida: A3 condicionado por baseline
- [x] exclusiones expresas registradas
- [x] criterio de cierre acordado

### C. Baseline previo

- [x] ejecutar `GET /cases/{id}/proceedings`
- [x] ejecutar `POST /cases/{id}/proceedings` válido
- [x] ejecutar `GET /cases/{id}/proceedings/{proc_id}`
- [x] ejecutar negativas `400` pendientes
- [x] verificar `404` para `caseId` inexistente
- [x] verificar que `PUT` y `DELETE` siguen no expuestos
- [x] capturar evidencia previa del comportamiento actual
- [x] definir mini-regresión del sprint

### D. Hardening objetivo

#### A1 — Validaciones del payload

- [x] validar `descripcion` requerida / no vacía
- [x] validar longitud máxima de `descripcion`, si aplica
- [x] validar formato de `fecha`
- [x] validar tipo de `completada`
- [x] validar payload vacío
- [ ] validar campos extra no permitidos (no requerido)
- [x] revisar mensajes de error en español y coherentes

#### A2 — Reglas de responsable

- [x] validar consistencia entre `responsable_id` y `responsable_externo` (explorado, sin brecha)

### E. Implementación

- [x] DTOs ajustados si aplica
- [ ] controller ajustado solo si aplica (no requerido)
- [ ] service ajustado solo si aplica (no requerido)
- [ ] repository ajustado solo si aplica (no requerido)
- [x] sin refactor amplio fuera del foco

### F. Validación

- [x] prueba positiva principal verde
- [x] persistencia confirmada
- [x] negativa `400` por payload inválido
- [x] negativa `400` por tipos incorrectos
- [x] negativa `404` por `caseId` inexistente
- [x] `PUT` no expuesto
- [x] `DELETE` no expuesto
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
2. baseline actual de `proceedings`  
3. ver DTO actual  
4. matriz de negativos `400`  
5. identificación de brechas  
6. decisión: ¿A3 completo o reducir a A1?  
7. implementación mínima  
8. build  
9. humo  
10. negativas  
11. mini-regresión  
12. revisión de contrato  
13. nota de cierre  
14. commit y push  

---

## 6. Criterio de cierre

Sprint 14 solo podrá declararse cerrado cuando:

- [x] el subrecurso `proceedings` mantenga política append-only
- [x] exista evidencia positiva y negativa en runtime
- [x] las validaciones relevantes del `POST` estén endurecidas
- [x] `PUT` y `DELETE` permanezcan no expuestos
- [x] el contrato no contradiga el runtime
- [x] la nota de cierre esté emitida
- [ ] el repositorio quede limpio

---

## 7. Pregunta de conducción específica del Sprint 14

**¿Cuál será el foco exacto del hardening de `proceedings`?**

| Opción | Descripción | Cuándo aplicar |
|--------|-------------|----------------|
| **A1** | Validaciones del payload | Si baseline muestra muchas brechas |
| **A2** | Reglas de responsable | Solo si A1 está resuelto |
| **A3** | Hardening integral corto (A1 + A2) | Si baseline muestra pocas brechas |

**Decisión:** A3 condicionado por baseline. Si aparecen muchas brechas, se reduce a A1.

---

## 8. Relación con Sprint 13

| Sprint 13 | Sprint 14 |
|-----------|-----------|
| Definió política append-only | Consolida calidad |
| Removió PUT y DELETE | Mantiene sin PUT ni DELETE |
| Alineó contrato | Endurece validaciones |
| Baseline de exposición HTTP | Baseline de validaciones DTO |

---

*Documento actualizado: 2026-03-27*  
*Sprint 14 — Fase E5 — LISTO PARA CIERRE*
