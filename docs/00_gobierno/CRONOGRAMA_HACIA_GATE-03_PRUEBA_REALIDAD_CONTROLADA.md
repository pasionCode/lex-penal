# Cronograma proyectado hacia prueba de realidad controlada  
## LEX_PENAL — Sesiones de 3 horas

**Punto de partida:**  
- Paso 1 — Estado base del proyecto: **cerrado**  
- US-04 — Bootstrap de usuario base con rol: **cerrada**  
- Estado actual: habilitado **US-01 — Iniciar sesión**

**Objetivo general:**  
Llegar a una **prueba de realidad controlada** con un flujo mínimo utilizable del MVP.

**Flujo objetivo a validar al final:**  
**login → crear caso → consultar caso → actualizar caso → registrar hecho → registrar prueba → revisar detalle → logout**

---

## 1. Cronograma maestro

| Sesión | Duración | Tramo | Historia(s) / Objetivo | Entregable principal | Criterio de cierre |
|---|---:|---|---|---|---|
| 1 | 3 h | Sprint 1 | **US-01** — Iniciar sesión | Login funcional con usuario bootstrap | Usuario puede autenticarse correctamente |
| 2 | 3 h | Sprint 1 | **US-02** — Persistencia de sesión | Token/sesión funcional entre solicitudes | Ruta protegida accesible con sesión válida |
| 3 | 3 h | Sprint 1 | **US-05** — Consultar mi perfil | Endpoint de perfil autenticado | Sistema devuelve perfil correcto del usuario autenticado |
| 4 | 3 h | Sprint 1 | **US-03** — Cerrar sesión + cierre de Sprint 1 | Flujo auth completo | **bootstrap → login → persistencia → perfil → logout** demostrable |
| 5 | 3 h | Sprint 2 | **US-06** — Crear caso | Creación funcional de caso | Caso persiste correctamente en BD |
| 6 | 3 h | Sprint 2 | **US-07 + US-08** — Listar y consultar detalle de caso | Navegación mínima del caso | Caso creado aparece en listado y detalle |
| 7 | 3 h | Sprint 2 | **US-10** — Actualizar caso editable | Edición funcional del caso | Cambios persisten sin romper integridad |
| 8 | 3 h | Sprint 2 | **US-09** — Transicionar estado + cierre de Sprint 2 | Flujo mínimo de caso | **login → crear caso → listar → detalle → actualizar → cambiar estado** demostrable |
| 9 | 3 h | Sprint 3 | **US-11 + US-12** — Registrar y consultar hechos | Hechos funcionales por caso | Caso puede contener hechos consultables |
| 10 | 3 h | Sprint 3 | **US-13** — Editar hecho | Hecho editable | Cambios persisten sin inconsistencias |
| 11 | 3 h | Sprint 3 | **US-14** — Registrar prueba vinculada | Caso con hecho y prueba vinculada | Primera unidad mínima caso-hecho-prueba operativa |
| 12 | 3 h | Pre-realidad | Validación integral del MVP | Versión candidata para prueba de realidad | Flujo completo sin errores bloqueantes |

---

## 2. Sesiones de reserva recomendadas

| Sesión | Duración | Finalidad | Entregable |
|---|---:|---|---|
| Buffer A | 3 h | Corrección de defectos de integración | Ajustes críticos previos al gate |
| Buffer B | 3 h | Prueba de realidad controlada | Ejecución de caso semirreal o real anonimizado |

---

## 3. Resumen por tramo

### Tramo I — Cierre de Sprint 1 (Auth + Users)
**Sesiones:** 1 a 4  
**Duración total:** 12 horas

**Objetivo:**  
Dejar operativa la autenticación base del sistema.

**Salida esperada:**  
Usuario puede autenticarse, mantener sesión, consultar perfil y cerrar sesión.

---

### Tramo II — Cierre de Sprint 2 (Gestión básica de casos)
**Sesiones:** 5 a 8  
**Duración total:** 12 horas

**Objetivo:**  
Dejar operativa la unidad básica de trabajo “caso”.

**Salida esperada:**  
Usuario autenticado puede crear, listar, consultar, actualizar y transicionar un caso.

---

### Tramo III — Cierre de Sprint 3 (Hechos y pruebas)
**Sesiones:** 9 a 11  
**Duración total:** 9 horas

**Objetivo:**  
Dejar operativa la estructura mínima narrativa-probatoria del caso.

**Salida esperada:**  
Usuario puede registrar hechos y vincular pruebas dentro de un caso.

---

### Tramo IV — Validación integral previa a realidad
**Sesión:** 12  
**Duración total:** 3 horas

**Objetivo:**  
Recorrer el flujo completo del MVP, corregir errores críticos y congelar una versión utilizable.

**Salida esperada:**  
Versión candidata a **prueba de realidad controlada**.

---

## 4. Estimación total

| Escenario | Sesiones | Horas |
|---|---:|---:|
| Base | 12 | 36 |
| Prudente con 1 buffer | 13 | 39 |
| Prudente con 2 buffers | 14 | 42 |

---

## 5. Ritmo sugerido

| Ritmo | Duración aproximada |
|---|---|
| 3 sesiones por semana | 4 semanas |
| 2 sesiones por semana | 6 semanas |

---

## 6. Hito de autorización previo a prueba de realidad

### **GATE-03 — MVP utilizable en flujo mínimo**

El proyecto quedará habilitado para una primera **prueba de realidad controlada** cuando se verifique:

- autenticación operativa;
- caso operativo;
- hechos operativos;
- pruebas operativas;
- flujo completo sin errores bloqueantes;
- documentación mínima de validación.

---

## 7. Regla de conducción hasta GATE-03

Hasta cerrar el GATE-03:

- no abrir verticales ajenas al flujo mínimo;
- no dispersar esfuerzo en módulos secundarios;
- no priorizar mejoras cosméticas sobre funcionalidad crítica;
- mantener criterio de mínima expansión;
- documentar cierre por historia y por sprint.

---

## 8. Fórmula ejecutiva

**4 sesiones para auth → 4 sesiones para caso → 3 sesiones para hechos/pruebas → 1 sesión de validación integral → 1 o 2 buffers → prueba de realidad controlada.**
