# CHECKLIST APERTURA UNIDAD E15-02 — 2026-04-14

## 1. Identificación
- Fase: E15
- Unidad: E15-02
- Nombre: Saneamiento controlado de publicación del backend
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la unidad
Mover la publicación efectiva del backend de LEX_PENAL desde el bloque `default_server` hacia el bloque explícito de `edu.pabloleon.com.co`, manteniendo continuidad operativa.

## 3. Entradas
- E15-01 cerrada
- Dominio objetivo recomendado: `edu.pabloleon.com.co`
- `health` operativo en backend actual

## 4. Tareas mínimas
- Respaldar `00-default-ssl.conf`
- Mover `location /api/v1/` al bloque `server_name edu.pabloleon.com.co`
- Mantener el `default_server` como respuesta mínima genérica
- Validar `nginx -t`
- Recargar Nginx
- Validar `health` por `edu.pabloleon.com.co`
- Verificar que la IP sin host ya no sea el punto funcional principal del backend

## 5. Criterios de cierre
- `edu.pabloleon.com.co/api/v1/health` responde `200`
- `nginx -t` exitoso
- recarga de Nginx exitosa
- publicación del backend ya no depende del `default_server`
