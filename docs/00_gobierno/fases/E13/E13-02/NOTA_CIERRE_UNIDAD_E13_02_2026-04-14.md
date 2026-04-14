# NOTA DE CIERRE UNIDAD E13-02 — 2026-04-14

## 1. Identificación
- Fase: E13
- Unidad: E13-02
- Nombre: Observabilidad mínima útil
- Estado: CERRADA

## 2. Objetivo de la unidad
Mejorar la visibilidad operativa del backend con medidas de bajo riesgo que aumenten señal útil y reduzcan ruido en la observación diaria.

## 3. Resultado
Unidad cumplida.

## 4. Medidas aplicadas
- Se incorporó `infra/scripts/ops_lex_penal_status.sh` como script operativo de inspección rápida.
- Se configuró log dedicado de Nginx para el tráfico `/api/v1/`:
  - `/var/log/nginx/lex_penal_access.log`
  - `/var/log/nginx/lex_penal_error.log`

## 5. Validación
- `nginx -t` quedó exitoso tras saneamiento de `sites-enabled`.
- `GET /api/v1/health` respondió `200 OK` local y vía Nginx.
- `lex_penal_access.log` registró tráfico real de `/api/v1/health`.
- `lex_penal_error.log` no registró errores en la prueba realizada.

## 6. Hallazgo operativo relevante
Se confirmó como mala práctica guardar backups dentro de `/etc/nginx/sites-enabled`, porque Nginx interpreta esos archivos y puede producir errores por duplicidad de `default_server`.

## 7. Regla operativa derivada
Todo respaldo de sitios Nginx debe guardarse fuera de `sites-enabled`, preferiblemente bajo:
`/opt/lex_penal/shared/ops/backups/nginx-sites/`

## 8. Decisión de cierre
Se cierra E13-02 y se abre E13-03 para cierre formal de fase E13.
