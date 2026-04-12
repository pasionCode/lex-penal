# NOTA FORMAL DE DECISIÓN — SERVIDOR STAGING E9-01 — 2026-04-01

## 1. Identificación
- Proyecto: LEX_PENAL
- Fase: E9
- Unidad: E9-01 — Preparación de entorno staging y saneamiento de configuración
- Fecha: 2026-04-01
- Tipo: Decisión operativa de infraestructura
- Estado: EMITIDA

## 2. Antecedente
La salida de E8-05 declaró el backend MVP como **APTO CON OBSERVACIONES**, autorizando el avance al siguiente bloque operativo, pero manteniendo bloqueada la salida productiva hasta resolver prerrequisitos críticos de infraestructura, secretos y configuración. Asimismo, el baseline de E9-01 dejó como decisión pendiente principal la definición concreta del servidor staging. :contentReference[oaicite:0]{index=0} :contentReference[oaicite:1]{index=1}

## 3. Decisión
Se decide que el entorno **staging formal** de LEX_PENAL vivirá en el servidor existente:

**`lexum-main` — `207.180.248.126`**

Infraestructura actualmente en estado de hibernación selectiva, que requiere reactivación controlada, verificación técnica e inventario operativo previo al despliegue del backend.

## 4. Fundamento de la decisión
La presente decisión se adopta por las siguientes razones:

1. Ya existe infraestructura disponible y utilizable.
2. El servidor cuenta con base previa de aseguramiento y servicios de red ya montados.
3. Permite validar el proyecto en un entorno profesional y no solo en un contexto local o simulado.
4. Reduce dispersión operativa y evita abrir una nueva dependencia de hosting innecesaria.
5. Desbloquea materialmente la unidad E9-01, que tenía como gate principal la definición del servidor staging. :contentReference[oaicite:2]{index=2}

## 5. Alcance de la decisión
La decisión adoptada produce los siguientes efectos:

- Se elimina la indeterminación sobre el servidor destino de staging.
- Se fija `lexum-main` como host objetivo para la preparación técnica de salida.
- Se habilita la reactivación del servidor como siguiente frente operativo.
- Se autoriza orientar el saneamiento de configuración y el hardening de repaso a un host concreto.

## 6. Límites de la decisión
La presente decisión **no** implica por sí misma:

- autorización de despliegue productivo;
- cierre automático de E9-01;
- presunción de que el servidor ya está apto sin revalidación;
- dispensa del saneamiento de secretos, variables, red y dependencias externas.

La salida productiva continúa bloqueada hasta cumplir las condiciones heredadas desde E8-05. :contentReference[oaicite:3]{index=3}

## 7. Orden operativa derivada
Se ordena ejecutar como siguiente frente de trabajo:

**E9-01.A — Reactivación, verificación técnica y hardening de repaso de `lexum-main`**

Este frente deberá producir evidencia verificable sobre:
- acceso administrativo;
- estado actual del host;
- recursos disponibles;
- servicios activos/inactivos;
- superficie expuesta;
- endurecimiento vigente;
- aptitud del host para alojar staging de LEX_PENAL.

## 8. Estado metodológico de la unidad
Emitida esta decisión, la unidad **E9-01** queda con servidor staging definido, pero su continuidad operativa se suspende de manera controlada hasta retomar la ejecución del frente E9-01.A bajo nueva sesión o nuevo bloque de trabajo.

## 9. Decisión final
**Servidor staging formal definido:** `lexum-main (207.180.248.126)`  
**Estado:** decisión emitida y vigente  
**Producción:** no autorizada  
**Siguiente frente:** reactivación y verificación técnica del host