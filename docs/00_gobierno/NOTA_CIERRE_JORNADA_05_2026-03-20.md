\# NOTA DE CIERRE DE JORNADA 05



\*\*Proyecto:\*\* LEX\_PENAL  

\*\*Jornada:\*\* 05 — Cierre de E2 y habilitación de E3  

\*\*Fecha:\*\* 2026-03-20  

\*\*Rama:\*\* main  

\*\*Responsable:\*\* Paul León  

\*\*Naturaleza del cierre:\*\* Auto-certificación metodológica en proyecto unipersonal



\---



\## 1. Objeto de la jornada



Durante la presente jornada se ejecutó la apertura formal de \*\*E2 — Diseño Detallado\*\* y se consolidaron todos los entregables necesarios para habilitar la transición controlada hacia E3.



La jornada tuvo como foco:



\- definir el flujo crítico mínimo del MVP;

\- formalizar épicas e historias de usuario;

\- construir el backlog priorizado;

\- establecer la Definition of Done;

\- validar coherencia entre artefactos existentes;

\- determinar si GATE-02 podía cerrarse y E3 habilitarse.



Durante esta jornada \*\*no se autorizó desarrollo de lógica de negocio productiva\*\*, conforme al MDS v2.1.



\---



\## 2. Resultado general de la jornada



La jornada concluye con resultado \*\*satisfactorio\*\*.



Se logró:



\- definir y aprobar el flujo crítico mínimo del MVP;

\- formalizar 5 épicas y 17 historias de usuario;

\- construir backlog priorizado en 3 sprints;

\- establecer Definition of Done en tres niveles;

\- confirmar coherencia de artefactos existentes;

\- cerrar \*\*GATE-02\*\* con todos los criterios cumplidos.



En consecuencia, \*\*E2 queda formalmente cerrada y E3 queda habilitada\*\*.



\---



\## 3. Flujo crítico mínimo del MVP — APROBADO



| # | Paso | Vertical |

|---|------|----------|

| 1 | Login y sesión | auth |

| 2 | Creación de caso | cases |

| 3 | Consulta y detalle básico del caso | cases |

| 4 | Transición de estado del caso | cases |

| 5 | Registro de hechos | facts |

| 6 | Registro de pruebas vinculadas a caso y, cuando aplique, a hecho | evidence |



\### Decisión formal



Se aprueba la Opción A como flujo crítico mínimo del MVP de LEX\_PENAL. El primer bloque funcional de construcción comprende autenticación, gestión básica de usuario, creación y consulta de caso, transición por máquina de estados, registro de hechos y registro de pruebas.



\### Exclusiones expresas del primer bloque



Quedan excluidos: risks, strategy, checklist, review, ai, reports — por depender de flujo base previamente estabilizado.



\### Punto crítico registrado



`evidence` no es repositorio suelto. Nace con relación obligatoria a caso y preferible a hecho. Esa unión es el valor jurídico del sistema.



\---



\## 4. Verticales del primer bloque



| Vertical | Prioridad | Alcance |

|----------|-----------|---------|

| \*\*auth\*\* | P1 | Login, sesión, token |

| \*\*users\*\* | P1 | Solo lo mínimo: identidad, perfil, rol, trazabilidad |

| \*\*cases\*\* | P1 | CRUD básico + máquina de estados |

| \*\*facts\*\* | P2 | Registro vinculado a caso |

| \*\*evidence\*\* | P2 | Registro vinculado a caso y, preferiblemente, a hecho |



\---



\## 5. Épicas formalizadas



| ID | Épica | Vertical | Descripción |

|----|-------|----------|-------------|

| EP-01 | Autenticación y sesión | auth | Permitir que usuarios accedan al sistema de forma segura |

| EP-02 | Gestión mínima de usuario | users | Mantener identidad, perfil y rol para trazabilidad |

| EP-03 | Gestión de casos | cases | Crear, consultar y transicionar casos por la máquina de estados |

| EP-04 | Registro de hechos | facts | Documentar los hechos jurídicamente relevantes del caso |

| EP-05 | Registro de pruebas | evidence | Vincular pruebas a casos y hechos para sustento jurídico |



\---



\## 6. Historias de usuario



\### EP-01 — Autenticación y sesión



| ID | Historia | Criterios de aceptación |

|----|----------|------------------------|

| US-01 | COMO usuario del sistema QUIERO iniciar sesión con credenciales PARA acceder a mis casos asignados | • Endpoint POST /auth/login funcional • Retorna JWT válido • Credenciales inválidas retornan 401 |

| US-02 | COMO usuario autenticado QUIERO que mi sesión persista PARA no re-autenticarme en cada petición | • Token JWT validado en rutas protegidas • Token expirado retorna 401 |

| US-03 | COMO usuario autenticado QUIERO cerrar sesión PARA invalidar mi acceso actual | • Endpoint POST /auth/logout funcional • Token invalidado no permite acceso |



\### EP-02 — Gestión mínima de usuario



| ID | Historia | Criterios de aceptación |

|----|----------|------------------------|

| US-04 | COMO administrador QUIERO provisionar un usuario base con rol PARA habilitar acceso al sistema | • Usuario creado con perfil y rol • Contraseña hasheada • No es CRUD amplio de usuarios |

| US-05 | COMO usuario autenticado QUIERO consultar mi perfil PARA verificar mi identidad y rol | • Endpoint GET /users/me retorna datos del usuario autenticado |



\### EP-03 — Gestión de casos



| ID | Historia | Criterios de aceptación |

|----|----------|------------------------|

| US-06 | COMO abogado QUIERO crear un caso con datos básicos PARA iniciar el análisis de defensa | • Endpoint POST /cases funcional • Caso creado en estado `borrador` • Cliente y datos mínimos registrados |

| US-07 | COMO abogado QUIERO consultar el listado de mis casos PARA ver mi carga de trabajo | • Endpoint GET /cases retorna casos del usuario • Filtrable por estado |

| US-08 | COMO abogado QUIERO consultar el detalle de un caso PARA revisar su información completa | • Endpoint GET /cases/:id retorna caso con relaciones básicas |

| US-09 | COMO abogado QUIERO transicionar un caso al siguiente estado PARA avanzar en el flujo procesal | • Endpoint POST /cases/:id/transition funcional • Valida transición permitida (CasoEstadoService) • Registra fecha y responsable |

| US-10 | COMO abogado QUIERO actualizar datos de un caso editable PARA corregir o completar información | • Endpoint PATCH /cases/:id funcional • Solo permitido en estados editables (`en\_analisis`, `devuelto`) |



\### EP-04 — Registro de hechos



| ID | Historia | Criterios de aceptación |

|----|----------|------------------------|

| US-11 | COMO abogado QUIERO registrar un hecho del caso PARA documentar las circunstancias relevantes | • Endpoint POST /cases/:id/facts funcional • Hecho vinculado obligatoriamente al caso • Fecha del hecho registrada |

| US-12 | COMO abogado QUIERO consultar los hechos de un caso PARA revisar la línea fáctica | • Endpoint GET /cases/:id/facts retorna hechos ordenados |

| US-13 | COMO abogado QUIERO editar un hecho registrado PARA corregir o precisar información | • Endpoint PATCH /facts/:id funcional • Solo en casos editables |



\### EP-05 — Registro de pruebas



| ID | Historia | Criterios de aceptación |

|----|----------|------------------------|

| US-14 | COMO abogado QUIERO registrar una prueba vinculada al caso PARA sustentar la defensa | • Endpoint POST /cases/:id/evidence funcional • Prueba vinculada obligatoriamente al caso |

| US-15 | COMO abogado QUIERO vincular una prueba a un hecho específico PARA establecer relación jurídica | • Prueba puede vincularse opcionalmente a un hecho • Relación caso-hecho-prueba trazable |

| US-16 | COMO abogado QUIERO consultar las pruebas de un caso PARA revisar el acervo probatorio | • Endpoint GET /cases/:id/evidence retorna pruebas con sus vínculos |

| US-17 | COMO abogado QUIERO editar una prueba registrada PARA actualizar su valoración o datos | • Endpoint PATCH /evidence/:id funcional • Solo en casos editables |



\---



\## 7. Backlog priorizado



\### Sprint 1 — Autenticación y usuario base



| Orden | ID | Historia | Vertical |

|-------|-----|----------|----------|

| 1 | US-04 | Bootstrap de usuario base con rol | users |

| 2 | US-01 | Iniciar sesión | auth |

| 3 | US-02 | Persistencia de sesión | auth |

| 4 | US-05 | Consultar mi perfil | users |

| 5 | US-03 | Cerrar sesión | auth |



\*\*Entregable:\*\* Usuario puede crearse, autenticarse, consultar su perfil y cerrar sesión.



\### Sprint 2 — Gestión básica de casos



| Orden | ID | Historia | Vertical |

|-------|-----|----------|----------|

| 6 | US-06 | Crear caso | cases |

| 7 | US-07 | Listar mis casos | cases |

| 8 | US-08 | Consultar detalle de caso | cases |

| 9 | US-09 | Transicionar estado | cases |

| 10 | US-10 | Actualizar caso editable | cases |



\*\*Entregable:\*\* Caso puede crearse, consultarse, avanzar por máquina de estados y editarse.



\### Sprint 3 — Hechos y pruebas



| Orden | ID | Historia | Vertical |

|-------|-----|----------|----------|

| 11 | US-11 | Registrar hecho | facts |

| 12 | US-12 | Consultar hechos del caso | facts |

| 13 | US-13 | Editar hecho | facts |

| 14 | US-14 | Registrar prueba vinculada a caso | evidence |

| 15 | US-15 | Vincular prueba a hecho | evidence |

| 16 | US-16 | Consultar pruebas del caso | evidence |

| 17 | US-17 | Editar prueba | evidence |



\*\*Entregable:\*\* Caso tiene hechos documentados y pruebas vinculadas con trazabilidad jurídica.



\### Resumen



| Sprint | Vertical(es) | Historias | Entregable |

|--------|--------------|-----------|------------|

| Sprint 1 | auth, users | 5 | Autenticación operativa |

| Sprint 2 | cases | 5 | Casos con máquina de estados |

| Sprint 3 | facts, evidence | 7 | Hechos y pruebas vinculados |

| \*\*Total\*\* | 5 verticales | \*\*17\*\* | \*\*MVP flujo crítico\*\* |



\### Dependencias entre sprints



```

Sprint 1 (auth/users)

&#x20;      │

&#x20;      ▼

Sprint 2 (cases)

&#x20;      │

&#x20;      ▼

Sprint 3 (facts/evidence)

```



\*\*Regla:\*\* No iniciar Sprint N+1 sin cerrar Sprint N.



\---



\## 8. Definition of Done



\### 8.1. DoD por historia de usuario



Una historia se considera \*\*TERMINADA\*\* cuando, según aplique:



1\. El código está implementado y funciona.

2\. El endpoint responde conforme al contrato API.

3\. Las validaciones de entrada están implementadas.

4\. Los errores retornan códigos HTTP correctos.

5\. Existe evidencia verificable de prueba mínima del camino feliz, manual o automatizada.

6\. Existe prueba de error de alto impacto en flujos críticos.

7\. La persistencia está verificada en base de datos.

8\. El modelo de datos y la persistencia son coherentes con `schema.prisma` y migraciones vigentes.

9\. La autorización está validada en rutas protegidas.

10\. No existen errores de compilación.

11\. El código está commiteado y versionado en la rama correspondiente.



\### 8.2. DoD por sprint



Un sprint se considera \*\*CERRADO\*\* cuando:



1\. Todas las historias del sprint cumplen DoD individual.

2\. El entregable del sprint es demostrable end-to-end.

3\. No existen errores bloqueantes pendientes.

4\. El código queda versionado e integrado conforme a la regla de integración vigente.

5\. La evidencia de cumplimiento queda registrada.



\### 8.3. DoD del primer bloque funcional



El bloque se considera \*\*COMPLETO\*\* cuando:



1\. Los tres sprints están cerrados.

2\. El flujo crítico opera end-to-end: login → crear caso → transicionar → registrar hechos → registrar pruebas.

3\. La máquina de estados opera correctamente.

4\. Las relaciones caso–hecho–prueba son trazables y consultables.

5\. No existe deuda técnica bloqueante registrada como abierta.

6\. El sistema compila, arranca y es desplegable en ambiente de pruebas.



\### 8.4. Exclusiones de la DoD en este bloque



\- Cobertura de tests ≥80%

\- Documentación de API completa

\- UI/UX pulido

\- Seguridad endurecida

\- Integración con IA



\---



\## 9. Validación de coherencia de artefactos



\### Artefactos base confirmados



| Artefacto | Estado | Observación |

|-----------|--------|-------------|

| MODELO\_DATOS\_v3 | ✅ Vigente | Coherente con schema.prisma |

| CONTRATO\_API\_v4 | ✅ Vigente | Base para endpoints del backlog |

| ADRs (8) | ✅ Aprobados | ADR-003 crítico para máquina de estados |

| schema.prisma | ✅ Migrado | 18 modelos, 19 enums |

| Base ejecutable | ✅ Validada J04 | Arranque local verificado |



\### Coherencia verificada



No se detectaron inconsistencias bloqueantes entre los artefactos existentes y el backlog definido.



\---



\## 10. Cierre de GATE-02



\### Criterios verificados



| Criterio | Estado | Evidencia |

|----------|--------|-----------|

| Épicas definidas | ✅ | 5 épicas formalizadas |

| Historias de usuario | ✅ | 17 historias con criterios de aceptación |

| Backlog priorizado | ✅ | 3 sprints secuenciados |

| Modelo de datos validado | ✅ | schema.prisma coherente |

| Contrato API validado | ✅ | CONTRATO\_API\_v4 vigente |

| Definition of Done | ✅ | DoD en 3 niveles |

| Infraestructura lista | ✅ | Base ejecutable validada en J04 |



\### Declaración



Se declara formalmente cerrado \*\*GATE-02\*\* del proyecto LEX\_PENAL, al haberse completado todos los entregables requeridos para la etapa de Diseño Detallado.



\---



\## 11. Estado resultante del proyecto



| Elemento | Estado |

|----------|--------|

| E0 — Preconstrucción | CERRADA |

| GATE-00 | CERRADO |

| E1 — Validación técnica | CUMPLIDA |

| GATE-01 | CERRADO |

| E2 — Diseño Detallado | \*\*CERRADA\*\* |

| GATE-02 | \*\*CERRADO\*\* |

| E3 — Construcción del MVP | \*\*HABILITADA\*\* |

| Desarrollo funcional productivo | \*\*AUTORIZADO\*\* |



\---



\## 12. Alcance de lo validado y límites del cierre



El cierre de la presente jornada certifica:



\- existencia de flujo crítico mínimo definido y aprobado;

\- backlog priorizado y secuenciado;

\- Definition of Done establecida;

\- coherencia entre artefactos de diseño;

\- habilitación formal de E3.



No se certifica todavía:



\- implementación funcional del flujo crítico;

\- cierre de sprints;

\- validación operativa con usuarios;

\- criterios de valor de negocio del MVP.



Dichos aspectos quedan reservados para \*\*E3\*\* y etapas posteriores.



\---



\## 13. Próximos pasos



\### Jornada 06 — Inicio de E3



| Acción | Descripción |

|--------|-------------|

| Abrir Sprint 1 | auth + users |

| Implementar US-04 | Bootstrap de usuario base |

| Implementar US-01 | Login |

| Implementar US-02 | Persistencia de sesión |

| Implementar US-05 | Consulta de perfil |

| Implementar US-03 | Logout |

| Cerrar Sprint 1 | Entregable: autenticación operativa |



\### Código autorizado desde J06



A partir de la siguiente jornada queda \*\*autorizado el desarrollo de lógica de negocio productiva\*\*, con estricta sujeción al backlog priorizado del primer bloque funcional y sin expansión paralela de verticales no habilitados.



\---



\## 14. Conclusión ejecutiva



La \*\*Jornada 05\*\* deja al proyecto \*\*LEX\_PENAL\*\* con diseño detallado completamente formalizado y listo para iniciar construcción controlada.



El sistema cuenta ahora con:



\- flujo crítico mínimo definido;

\- 5 épicas y 17 historias formalizadas;

\- backlog priorizado en 3 sprints;

\- Definition of Done en tres niveles;

\- artefactos de diseño validados y coherentes;

\- E3 habilitada para desarrollo funcional.



Se declara \*\*cerrada la etapa E2\*\* y \*\*habilitada la transición a E3\*\*.



\---



\## 15. Control documental



\*\*Estado del documento:\*\* Canónico  

\*\*Tipo documental:\*\* Nota de cierre de jornada  

\*\*Ubicación:\*\* `docs/00\_gobierno/NOTA\_CIERRE\_JORNADA\_05\_2026-03-20.md`



\---



\*\*Firmado electrónicamente por:\*\*  

\*\*Paul León\*\*  

Director del proyecto LEX\_PENAL

