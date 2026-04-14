# NOTA DE CIERRE UNIDAD E15-01 — 2026-04-14

## 1. Identificación
- Fase: E15
- Unidad: E15-01
- Nombre: Baseline de claridad de publicación y dominio
- Estado: CERRADA

## 2. Objetivo de la unidad
Levantar baseline exacto del esquema actual de publicación del backend, identificando el host efectivo, los dominios candidatos, los certificados disponibles y la ruta más segura para abandonar la dependencia del `default_server`.

## 3. Resultado
Unidad cumplida.

## 4. Hallazgos principales
- El backend de LEX_PENAL sigue publicado efectivamente desde el `default_server` en `00-default-ssl.conf`.
- El bloque efectivo del backend usa certificado snakeoil para `server_name _`.
- `edu.pabloleon.com.co` dispone de certificado válido, pero actualmente no publica el backend.
- `api.legaltech.local` alcanza el backend, pero su publicación es ambigua y sirve certificado autofirmado.
- `cloud.pabloleon.com.co` está asociado a Nextcloud y no debe reutilizarse para el backend.

## 5. Dominio objetivo recomendado
Se recomienda usar `edu.pabloleon.com.co` como dominio explícito del backend de LEX_PENAL, por ser el candidato de menor riesgo con certificado válido ya disponible y sin conflicto con la función actual de Nextcloud.

## 6. Decisión de cierre
Se cierra E15-01 y se abre E15-02 para saneamiento controlado de la publicación del backend hacia `edu.pabloleon.com.co`.
