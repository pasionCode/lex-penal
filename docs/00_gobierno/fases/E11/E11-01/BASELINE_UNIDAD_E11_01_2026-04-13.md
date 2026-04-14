# BASELINE UNIDAD E11-01 — 2026-04-13

## 1. Propósito
Esta unidad establece el punto de control técnico-operativo del entorno objetivo antes de cualquier acción de despliegue o ajuste con impacto.

## 2. Preguntas que debe responder la unidad
1. ¿Cuál es el estado real del VPS?
2. ¿Existe despliegue previo en `/opt/lex_penal/app`?
3. ¿Qué servicios están activos y cuáles exponen puertos?
4. ¿Qué artefactos de ejecución existen?
5. ¿Qué brechas impiden un despliegue controlado?

## 3. Fuentes de evidencia previstas
- Salida de comandos del VPS.
- Estado del repositorio desplegado.
- Estado de servicios del sistema.
- Inventario básico de red, puertos, disco y memoria.
- Archivos de entorno y despliegue detectados, sin exponer secretos.

## 4. Resultado esperado
Al cierre de E11-01 debe existir una fotografía técnica suficiente para decidir, con base y sin improvisación, la siguiente unidad de ejecución operativa.

## 5. Estado inicial
- Documento abierto.
- Pendiente de completar con evidencia real del levantamiento.
