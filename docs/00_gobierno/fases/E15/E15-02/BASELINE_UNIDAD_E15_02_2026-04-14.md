# BASELINE UNIDAD E15-02 — 2026-04-14

## 1. Punto de partida
El backend de LEX_PENAL está funcional, pero se publica hoy desde el `default_server` con certificado snakeoil y `server_name _`.

## 2. Estrategia
Aplicar el ajuste de menor riesgo: trasladar el bloque `/api/v1/` al servidor `edu.pabloleon.com.co`, que ya cuenta con certificado válido.

## 3. Resultado esperado
Publicación más clara, con dominio explícito y certificado válido, sin afectar otros servicios coexistentes.
