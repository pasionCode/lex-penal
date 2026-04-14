# CHECKLIST APERTURA UNIDAD E13-02 — 2026-04-14

## 1. Identificación
- Fase: E13
- Unidad: E13-02
- Nombre: Observabilidad mínima útil
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la unidad
Mejorar la visibilidad operativa del backend con medidas de bajo riesgo que aumenten señal útil y reduzcan ruido en la observación diaria.

## 3. Entradas
- E13-01 cerrada
- `health` operativo
- `journald` útil
- `access.log` general contaminado con tráfico no pertinente

## 4. Tareas mínimas
- Crear script operativo de observación rápida.
- Separar logs de Nginx para `/api/v1/`.
- Validar `nginx -t`.
- Validar `health` local y vía Nginx.
- Registrar evidencia.

## 5. Criterios de cierre
- Script operativo disponible en repo.
- Log dedicado de backend activo en Nginx.
- `health` sigue respondiendo `200`.
- Evidencia archivada.
