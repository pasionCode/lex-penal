# NOTA DE CIERRE UNIDAD E11-02 — 2026-04-13

## 1. Identificación
- Fase: E11
- Unidad: E11-02
- Nombre: Verificación privilegiada y smoke de publicación
- Estado: CERRADA

## 2. Objetivo de la unidad
Completar la verificación privilegiada del despliegue actual de LEX_PENAL y dejar definida una secuencia mínima de validación/publicación controlada sobre el backend ya existente.

## 3. Resultado
Unidad cumplida.

## 4. Hallazgos confirmados
- `lex-penal.service` ejecuta el backend NestJS mediante `node dist/main.js`.
- El backend expone rutas reales bajo `/api/v1`.
- El proxy Nginx funcional hacia LEX_PENAL está definido en `00-default-ssl.conf` sobre `location /api/v1/`.
- El smoke fue positivo:
  - `POST /api/v1/auth/login` respondió `400 Bad Request` por validación.
  - `POST /api/v1/ai/query` respondió `401 Unauthorized`.
  - ambos comportamientos se reprodujeron también vía Nginx HTTPS.
- `nginx -t` fue exitoso.
- El código desplegado actualmente en el VPS corresponde a `32f838f`.

## 5. Conclusión operativa
No existe ya incertidumbre sobre servicio, proxy ni ruta mínima de smoke.
La brecha restante no es de diagnóstico sino de alineación del despliegue respecto del estado actual de `main`.

## 6. Riesgo trasladado
- El VPS está corriendo una revisión atrasada respecto del repositorio local.
- La actualización debe hacerse de forma controlada para no romper proxy, servicio ni variables de entorno compartidas.

## 7. Decisión de cierre
Se cierra E11-02 y se abre E11-03 para alineación controlada del despliegue.
