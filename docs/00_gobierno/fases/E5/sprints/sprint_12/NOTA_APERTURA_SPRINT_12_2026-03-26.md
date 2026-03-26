# APERTURA SPRINT 12 — 2026-03-26

## 1. Identificación

| Campo | Valor |
|-------|-------|
| Proyecto | LEX_PENAL |
| Fase | E5 — Expansión funcional controlada |
| Sprint | Sprint 12 |
| Fecha de apertura | 2026-03-26 |
| Estado | ABIERTO |

---

## 2. Micronota metodológica de arranque

Antes de tocar código en Sprint 12 se preservan estas reglas de conducción:

- Partir siempre de `working tree clean`
- No abrir alcance nuevo sin política explícita
- Validar baseline antes de implementar
- No documentar como operativo nada que no haya sido probado en runtime
- Cerrar con evidencia mínima: build, humo, regresión, contrato y nota de cierre
- Evitar expansión simultánea de backend + infraestructura + reglas de negocio en un mismo sprint

Sprint 12 debe ejecutarse en línea con el MDS, manteniendo expansión funcional controlada y sin contaminar la arquitectura con decisiones prematuras.

---

## 3. Pregunta de conducción

¿Cuál será el foco exacto del Sprint 12?

### Opción A — Endurecimiento de `documents`
Consolidar validaciones, payload inválido, restricciones de edición y pruebas negativas adicionales, sin abrir nuevas capacidades.

### Opción B — Expansión controlada de `proceedings`
Fortalecer o completar el subrecurso `proceedings`, manteniendo coherencia con el patrón append-only ya adoptado en módulos similares.

### Opción C — Ajuste transversal de calidad
Ejecutar sprint corto de estabilización: validaciones, errores estándar, regresión ampliada y alineación contrato/runtime en módulos E5.

**Política recomendada de entrada:** A o C.  
No se recomienda abrir infraestructura todavía.

---

## 4. Objetivo provisional del sprint

Ejecutar una expansión funcional corta, verificable y metodológicamente contenida, priorizando consolidación real sobre apertura apresurada de nuevas capacidades.

---

## 5. Restricciones iniciales

Durante Sprint 12 **no se debe:**

- Abrir infraestructura real de almacenamiento
- Introducir `DELETE` sin decisión formal
- Mezclar refactor amplio con expansión funcional
- Actualizar contrato antes de validar runtime
- Abrir múltiples subrecursos nuevos en paralelo

---

## 6. Checklist de apertura

### A. Higiene de arranque

- [ ] `git status` limpio
- [ ] Rama `main` sincronizada con `origin/main`
- [ ] `npm run build` exitoso
- [ ] Aplicación levanta sin errores críticos
- [ ] Token de autenticación válido para pruebas

### B. Delimitación del sprint

- [ ] Foco funcional definido
- [ ] Política del sprint definida
- [ ] Alcance explícitamente acotado
- [ ] Exclusiones expresas registradas
- [ ] Criterio de cierre acordado

### C. Baseline funcional

- [ ] Identificar endpoint o flujo a intervenir
- [ ] Ejecutar baseline del comportamiento actual
- [ ] Capturar evidencia del estado previo
- [ ] Identificar negativos esperados
- [ ] Identificar regresión mínima asociada

### D. Implementación

- [ ] DTOs o contratos internos ajustados
- [ ] Controller ajustado
- [ ] Service ajustado
- [ ] Repository ajustado
- [ ] Validaciones coherentes con política del sprint

### E. Validación

- [ ] Prueba positiva principal
- [ ] Persistencia confirmada
- [ ] Prueba negativa 404
- [ ] Prueba negativa 400
- [ ] Regresión mínima verde

### F. Cierre

- [ ] Contrato API actualizado
- [ ] Nota de cierre emitida
- [ ] Commit funcional realizado
- [ ] Push realizado
- [ ] `git status` final limpio

---

## 7. Ruta operativa sugerida

1. Baseline
2. Decisión de política
3. Implementación mínima
4. Build
5. Humo
6. Negativas
7. Regresión
8. Contrato
9. Nota de cierre
10. Push final

---

## 8. Criterio de cierre

Sprint 12 solo podrá declararse cerrado cuando:

- El cambio esté probado en runtime
- Exista evidencia positiva y negativa
- La regresión mínima esté verde
- El contrato refleje exactamente lo implementado
- El repositorio quede limpio

---

## 9. Observación de conducción

Sprint 11 dejó una base limpia.  
Sprint 12 debe aprovechar esa limpieza para consolidar, no para dispersar.

---

## 10. Decisiones de conducción consolidadas

| # | Decisión | Estado |
|---|----------|--------|
| 1 | Foco del sprint: Opción A — Endurecimiento de `documents` | CONFIRMADA |
| 2 | Política del sprint: hardening sin expansión funcional | CONFIRMADA |
| 3 | Verificación higiene de arranque | PENDIENTE |
| 4 | Baseline funcional capturado | PENDIENTE |

**Decisión de conducción vigente:** Sprint 12 se ejecutará sobre `documents` en modalidad de hardening, sin apertura de nuevas capacidades ni expansión transversal.

---

*Documento generado: 2026-03-26*  
*Proyecto: LEX_PENAL — Fase E5*