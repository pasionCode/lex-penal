# CHECKLIST APERTURA UNIDAD E15-01 — 2026-04-14

## 1. Identificación
- Fase: E15
- Unidad: E15-01
- Nombre: Baseline de claridad de publicación y dominio
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la unidad
Levantar baseline exacto del esquema actual de publicación del backend, identificando el host efectivo, los dominios candidatos, los certificados disponibles y la ruta más segura para abandonar la dependencia del `default_server`.

## 3. Entradas
- Commit base `126b32e`
- Backend saludable por `health`
- Certificado válido para `cloud.pabloleon.com.co` y `edu.pabloleon.com.co`
- Publicación actual desde `00-default-ssl.conf`

## 4. Salidas esperadas
- Mapa de dominios y certificados útiles
- Evidencia de qué `Host` llega realmente al backend
- Recomendación de dominio objetivo para el backend
- Base para E15-02

## 5. Verificaciones mínimas
- Respuesta del backend con diferentes `Host`
- Certificados servidos por dominio/IP
- Bloques Nginx implicados
- Continuidad de `health`

## 6. Criterios de cierre
- Dominio objetivo recomendado con evidencia
- Baseline documental suficiente
- Siguiente bloque de saneamiento definido
