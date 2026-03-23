\# ADR-009 — Prefijo global y rutas relativas en controllers



\*\*Estado:\*\* Cerrado  

\*\*Fecha:\*\* 2026-03-22  

\*\*Decisor:\*\* Pablo Jaramillo



\---



\## 1. Contexto



El proyecto usa `app.setGlobalPrefix('api/v1')` en `src/main.ts`.  

Durante la auditoría se detectó que varios controllers también declaran `api/v1/...` en su decorator, generando riesgo de duplicación de rutas y desalineación con el contrato API.



\---



\## 2. Opciones evaluadas



\### Opción A

Mantener prefijo global y usar rutas relativas en controllers.



\### Opción B

Eliminar prefijo global y declarar rutas completas en cada controller.



\---



\## 3. Decisión



Se adopta la \*\*Opción A\*\*:



\- `src/main.ts` mantiene `app.setGlobalPrefix('api/v1')`;

\- los controllers deberán declarar rutas relativas al recurso;

\- queda prohibido repetir `api/v1/` dentro de `@Controller(...)`.



\---



\## 4. Consecuencias



\- simplifica versionado;

\- evita duplicación;

\- obliga a sanear controllers existentes;

\- obliga a alinear contrato API y smoke tests.



\---



\## 5. Regla operativa



Convención válida:

\- `@Controller('auth')`

\- `@Controller('users')`

\- `@Controller('cases')`

\- `@Controller('cases/:caseId/facts')`



Convención inválida:

\- `@Controller('api/v1/cases')`

\- `@Controller('api/v1/clients')`



\---



\## 6. Acciones derivadas



1\. corregir decorators actuales;

2\. actualizar `CONTRATO\_API\_v4.md`;

3\. registrar esta decisión en `DECISIONES\_DE\_ARQUITECTURA.md`.

