\# CHECKLIST APERTURA FASE E9-01 — 2026-04-01



\## 1. Identificación

\- Proyecto: LEX\_PENAL

\- Fase: E9

\- Unidad: E9-01 — Preparación de entorno staging y saneamiento de configuración

\- Fecha de apertura: 2026-04-01

\- Estado: ABIERTA



\## 2. Objetivo de la unidad

Preparar y dejar controladas las condiciones mínimas de infraestructura, configuración y secretos requeridas para habilitar una salida segura a entorno staging, conforme a la decisión de salida emitida al cierre de E8-05, sin autorizar todavía despliegue productivo. :contentReference\[oaicite:0]{index=0}



\## 3. Justificación de apertura

La decisión formal de salida de E8-05 declaró el backend MVP como \*\*APTO CON OBSERVACIONES\*\*, dejando expresamente identificados como prerrequisitos críticos: generación de secretos de producción, configuración de credenciales de base de datos, definición de servidor destino y aterrizaje de los ítems críticos del checklist preproducción. En consecuencia, corresponde abrir una unidad específica para resolver esos bloqueantes antes de cualquier salida operativa real. :contentReference\[oaicite:1]{index=1}



\## 4. Línea base de entrada

\### 4.1 Estado recibido desde E8

\- Regresión mínima validada: 15/15 PASS.

\- Barrido de secretos en código: sin hardcoding.

\- Estrategia de despliegue: definida.

\- Checklist de preproducción: emitido.

\- Salida productiva: no autorizada aún. :contentReference\[oaicite:2]{index=2}



\### 4.2 Observaciones críticas heredadas

\- JWT\_SECRET requiere generación.

\- COOKIE\_SECRET requiere generación.

\- DATABASE\_URL requiere credenciales reales del entorno.

\- COOKIE\_SECURE debe fijarse correctamente según el esquema de acceso del entorno.

\- Servidor destino no definido.

\- PostgreSQL del entorno no provisionado.

\- Dominio/HTTPS no definido. :contentReference\[oaicite:3]{index=3}



\## 5. Alcance de la unidad E9-01

La presente unidad comprende exclusivamente:



1\. Definir el entorno destino de staging.

2\. Definir la estrategia de hosting o servidor aplicable al backend.

3\. Definir el servicio o instancia PostgreSQL para staging.

4\. Generar secretos de aplicación requeridos para el entorno.

5\. Sane ar y consolidar variables de entorno.

6\. Asegurar que el arranque del sistema quede alineado con configuración segura.

7\. Dejar preparada la base de despliegue para PM2 y reverse proxy.

8\. Aterrizar en términos ejecutables los ítems críticos del checklist preproducción que condicionan la salida.

9\. Emitir validación de preparación para siguiente unidad de despliegue a staging.



\## 6. Fuera de alcance

Queda expresamente fuera de alcance en E9-01:



1\. Despliegue a producción.

2\. Salida pública definitiva con dominio operativo final.

3\. Ejecución de migración productiva.

4\. Cierre integral de E9.

5\. Optimización avanzada de observabilidad, backups o alta disponibilidad más allá del mínimo requerido para staging.



\## 7. Entregables esperados

Al cierre de E9-01 deberán existir, como mínimo, los siguientes entregables:



\- Definición formal del servidor o entorno de staging.

\- Definición formal de la base de datos de staging.

\- Inventario consolidado de variables de entorno requeridas.

\- Secretos generados y registrados en mecanismo seguro de custodia.

\- Configuración objetivo de runtime para staging.

\- Decisión explícita sobre dominio/subdominio y HTTPS para staging.

\- Nota técnica de saneamiento de configuración.

\- Evidencia de deshabilitación o neutralización de bootstrap administrativo impropio para salida.

\- Checklist de prerrequisitos críticos marcado contra evidencia real.

\- Nota de cierre de unidad con decisión de continuidad o bloqueo.



\## 8. Checklist operativo de apertura



\### 8.1 Gobierno y conducción

\- \[ ] Se reconoce formalmente que E8-05 habilita avance de bloque, pero no despliegue productivo.

\- \[ ] Se declara E9-01 como unidad de preparación y no de salida final.

\- \[ ] Se mantiene alineación con MDS y regla de intervención reproducible.

\- \[ ] Se trabajará con evidencia verificable y no con supuestos de infraestructura.



\### 8.2 Infraestructura

\- \[ ] Está identificado el servidor o proveedor donde vivirá staging.

\- \[ ] Está identificado el sistema operativo o base de ejecución.

\- \[ ] Está identificado el mecanismo de acceso administrativo.

\- \[ ] Está definida la ruta de despliegue del backend.

\- \[ ] Está definido el proceso administrador de ejecución previsto.



\### 8.3 Base de datos

\- \[ ] Está definido PostgreSQL para staging.

\- \[ ] Están definidas host, puerto, nombre de base y credenciales.

\- \[ ] Está definida la política inicial de migraciones.

\- \[ ] Está definida la conectividad entre backend y base de datos.



\### 8.4 Secretos y variables

\- \[ ] JWT\_SECRET generado con criterio seguro.

\- \[ ] COOKIE\_SECRET generado con criterio seguro.

\- \[ ] DATABASE\_URL consolidado con credenciales reales del entorno.

\- \[ ] ANTHROPIC\_API\_KEY validada o marcada formalmente como pendiente bloqueante/no bloqueante según uso.

\- \[ ] NODE\_ENV definido correctamente para salida.

\- \[ ] LOG\_LEVEL ajustado a criterio de salida.

\- \[ ] BOOTSTRAP\_ADMIN deshabilitado o controlado.

\- \[ ] COOKIE\_SECURE definido conforme al esquema real de acceso.

\- \[ ] CORS\_ORIGIN definido para staging.

\- \[ ] Inventario .env revisado completo.



\### 8.5 Red, acceso y exposición

\- \[ ] Se definió si staging operará con IP, dominio o subdominio.

\- \[ ] Se definió si staging contará con HTTPS desde esta unidad o en la siguiente.

\- \[ ] Se definió el reverse proxy objetivo.

\- \[ ] Se definió puerto interno de aplicación.

\- \[ ] Se definieron restricciones básicas de acceso al entorno.



\### 8.6 Evidencia y validación

\- \[ ] Existe evidencia documental de cada decisión de entorno.

\- \[ ] Existe evidencia técnica de generación de secretos sin exponer valores sensibles en repositorio.

\- \[ ] Existe evidencia de consistencia entre configuración requerida y configuración disponible.

\- \[ ] Existe criterio claro para abrir E9-02 o E9-03 sin reproceso.



\## 9. Riesgos controlados por esta unidad

\- Riesgo de despliegue con secretos inseguros.

\- Riesgo de salida con base de datos no definida.

\- Riesgo de exposición por configuración inconsistente de cookies/CORS.

\- Riesgo de despliegue sin destino real.

\- Riesgo de arrastre de configuraciones de desarrollo hacia staging.

\- Riesgo de salida apresurada sin evidencia suficiente.



\## 10. Dependencias de entrada

Para ejecutar esta unidad se requiere confirmar o conseguir:



1\. Acceso o definición del servidor staging.

2\. Definición de PostgreSQL staging.

3\. Ruta de gestión de secretos fuera del repositorio.

4\. Decisión mínima de networking para acceso al entorno.

5\. Confirmación del modo de despliegue previsto.



\## 11. Criterios de cierre de E9-01

La unidad solo podrá declararse cerrada si se verifica que:



1\. Existe un entorno staging definido de manera concreta.

2\. Existe una base de datos staging definida y conectable.

3\. Los secretos críticos fueron generados.

4\. El inventario de variables quedó saneado.

5\. La configuración insegura heredada de desarrollo quedó tratada.

6\. Existe evidencia documental suficiente para ejecutar la siguiente unidad sin ambigüedad.

7\. Se emite nota de cierre con decisión expresa:

&#x20;  - habilita despliegue a staging, o

&#x20;  - mantiene bloqueo por dependencia externa no resuelta.



\## 12. Criterios de no cierre

E9-01 no podrá cerrarse si ocurre cualquiera de estos supuestos:



\- No hay servidor staging definido.

\- No hay PostgreSQL staging definido.

\- No se han generado secretos críticos.

\- Se mantiene ambigüedad material sobre variables de entorno.

\- No existe evidencia de saneamiento de configuración.

\- Se pretende saltar directamente a producción.



\## 13. Próxima unidad esperada

Una vez cerrada E9-01, la siguiente unidad candidata será:



\*\*E9-02 — Consolidación técnica de despliegue a staging\*\*  

o, si la estructura de trabajo lo exige,  

\*\*E9-03 — Ejecución controlada de despliegue a staging\*\*



\## 14. Estado de apertura

Con fundamento en la decisión de salida E8-05, se declara formalmente abierta la unidad \*\*E9-01 — Preparación de entorno staging y saneamiento de configuración\*\*, como bloque habilitante previo a cualquier salida operativa real. :contentReference\[oaicite:4]{index=4}

