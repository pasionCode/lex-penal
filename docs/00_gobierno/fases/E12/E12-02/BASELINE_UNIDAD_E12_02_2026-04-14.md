# BASELINE UNIDAD E12-02 — 2026-04-14

## 1. Punto de partida
`lex-penal.service` ya opera correctamente, pero conserva varias directivas de aislamiento desactivadas.

## 2. Estrategia de la unidad
Aplicar solo medidas de hardening systemd de bajo riesgo y alta compatibilidad, evitando cambios que puedan romper Node.js, Prisma o acceso a archivos requeridos por la aplicación.

## 3. Resultado esperado
Unit file endurecido de forma conservadora, con continuidad operativa intacta.
