# BASELINE UNIDAD E13-02 — 2026-04-14

## 1. Punto de partida
LEX_PENAL ya cuenta con servicio estable y smoke técnico válido, pero la observación diaria sigue dispersa entre `journalctl`, `access.log` general y `error.log` ruidoso.

## 2. Estrategia
Aplicar mejoras mínimas de alta utilidad:
- un script operativo reproducible,
- y un log dedicado de Nginx para el tráfico `/api/v1/`.

## 3. Resultado esperado
Mayor visibilidad práctica del backend sin introducir complejidad innecesaria.
