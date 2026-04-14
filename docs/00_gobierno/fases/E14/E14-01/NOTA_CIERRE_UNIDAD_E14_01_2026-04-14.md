# NOTA DE CIERRE UNIDAD E14-01 — 2026-04-14

## 1. Identificación
- Fase: E14
- Unidad: E14-01
- Nombre: Baseline de hardening de proxy/Nginx
- Estado: CERRADA

## 2. Objetivo de la unidad
Levantar baseline real del proxy/Nginx que publica LEX_PENAL, identificando bloques activos, publicaciones heredadas, logs, certificados y focos de ruido o ambigüedad.

## 3. Resultado
Unidad cumplida.

## 4. Hallazgos principales
- La publicación efectiva del backend de LEX_PENAL está en `00-default-ssl.conf`, bajo `location /api/v1/`.
- El backend sigue expuesto a través del `default_server` con certificado snakeoil para `server_name _`.
- Existe un bloque separado para `edu.pabloleon.com.co` que no publica el backend actual.
- El archivo `legaltech-api` permanece activo en `sites-enabled` y apunta a `127.0.0.1:8000`.
- El `error.log` general conserva ruido atribuible a `api.legaltech.local` y a ese upstream heredado.
- `lex_penal_access.log` ya registra correctamente tráfico útil del backend.

## 5. Decisión operativa
El primer saneamiento de bajo riesgo debe enfocarse en retirar de `sites-enabled` el bloque heredado `legaltech-api`, evitando tocar todavía bloques con posible uso vigente como `nextcloud` o `lexum_caddy_proxy.conf`.

## 6. Decisión de cierre
Se cierra E14-01 y se abre E14-02 para saneamiento de bajo riesgo del proxy.
