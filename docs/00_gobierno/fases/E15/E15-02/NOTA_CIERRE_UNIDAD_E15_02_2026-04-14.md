# NOTA DE CIERRE UNIDAD E15-02 — 2026-04-14

## 1. Identificación
- Fase: E15
- Unidad: E15-02
- Nombre: Saneamiento controlado de publicación del backend
- Estado: CERRADA

## 2. Objetivo de la unidad
Mover la publicación efectiva del backend de LEX_PENAL desde el bloque `default_server` hacia el bloque explícito de `edu.pabloleon.com.co`, manteniendo continuidad operativa.

## 3. Resultado
Unidad cumplida.

## 4. Medidas aplicadas
- Se respaldó `00-default-ssl.conf` fuera de `sites-enabled`.
- Se retiró `/api/v1/` del `default_server`.
- Se incorporó `/api/v1/` al bloque `server_name edu.pabloleon.com.co`.
- Se validó la configuración con `nginx -t`.
- Se recargó Nginx sin afectar disponibilidad.

## 5. Validación
- `curl` con `Host: edu.pabloleon.com.co` respondió `200 OK`.
- La prueba con `--resolve edu.pabloleon.com.co:443:127.0.0.1` respondió `200 OK`.
- El backend quedó servido con certificado válido de Let's Encrypt para el dominio.
- `lex_penal_access.log` registró tráfico útil posterior al ajuste.
- `lex_penal_error.log` no registró errores en la prueba.

## 6. Efecto operativo
El backend deja de depender funcionalmente del `default_server` y pasa a publicarse de forma explícita bajo `edu.pabloleon.com.co`.

## 7. Decisión de cierre
Se cierra E15-02 y se abre E15-03 para cierre formal de fase E15.
