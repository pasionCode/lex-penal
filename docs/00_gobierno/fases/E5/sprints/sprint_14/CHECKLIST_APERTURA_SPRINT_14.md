# CHECKLIST DE APERTURA — SPRINT 14

## 1. Identificación

- Proyecto: LEX_PENAL
- Fase: E5 — Expansión funcional controlada
- Sprint: Sprint 14
- Fecha de apertura: 2026-03-26
- Estado: ABIERTO

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

- [ ] `git status` limpio
- [ ] rama `main` sincronizada con `origin/main`
- [ ] `npm run build` exitoso
- [ ] aplicación levanta sin errores críticos
- [ ] token JWT vigente para pruebas

### B. Delimitación del sprint

- [x] foco funcional definido: `proceedings`
- [x] política del sprint definida: hardening append-only
- [x] conducción definida: A3 condicionado por baseline
- [x] exclusiones expresas registradas
- [ ] criterio de cierre acordado

### C. Baseline previo

- [ ] ejecutar `GET /cases/{id}/proceedings`
- [ ] ejecutar `POST /cases/{id}/proceedings` válido
- [ ] ejecutar `GET /cases/{id}/proceedings/{proc_id}`
- [ ] ejecutar negativas `400` pendientes
- [ ] verificar `404` para `caseId` inexistente
- [ ] verificar que `PUT` y `DELETE` siguen no expuestos
- [ ] capturar evidencia previa del comportamiento actual
- [ ] definir mini-regresión del sprint

### D. Hardening objetivo

#### A1 — Validaciones del payload

- [ ] validar `descripcion` requerida / no vacía
- [ ] validar longitud máxima de `descripcion`, si aplica
- [ ] validar formato de `fecha`
- [ ] validar tipo de `completada`
- [ ] validar payload vacío
- [ ] validar campos extra no permitidos
- [ ] revisar mensajes de error en español y coherentes

#### A2 — Reglas de responsable

- [ ] validar consistencia entre `responsable_id` y `responsable_externo`

### E. Implementación

- [ ] DTOs ajustados si aplica
- [ ] controller ajustado solo si aplica
- [ ] service ajustado solo si aplica
- [ ] repository ajustado solo si aplica
- [ ] sin refactor amplio fuera del foco

### F. Validación

- [ ] prueba positiva principal verde
- [ ] persistencia confirmada
- [ ] negativa `400` por payload inválido
- [ ] negativa `400` por tipos incorrectos
- [ ] negativa `404` por `caseId` inexistente
- [ ] `PUT` no expuesto
- [ ] `DELETE` no expuesto
- [ ] mini-regresión verde
- [ ] build final verde

### G. Documentación y cierre

- [ ] baseline documentado
- [ ] contrato revisado contra runtime
- [ ] nota de cierre emitida
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

- [ ] el subrecurso `proceedings` mantenga política append-only
- [ ] exista evidencia positiva y negativa en runtime
- [ ] las validaciones relevantes del `POST` estén endurecidas
- [ ] `PUT` y `DELETE` permanezcan no expuestos
- [ ] el contrato no contradiga el runtime
- [ ] la nota de cierre esté emitida
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

*Documento generado: 2026-03-26*  
*Sprint 14 — Fase E5 — ABIERTO*
