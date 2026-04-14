# BASELINE FASE E15 — 2026-04-14

## 1. Punto de partida
La fase E15 inicia después del cierre formal de E14, tomando como base el commit `126b32e`.

## 2. Estado heredado
- Backend operativo y saludable mediante `GET /api/v1/health`.
- Proxy/Nginx más limpio tras saneamiento de bloques heredados.
- Log dedicado de backend ya funcional.
- Persistencia de ambigüedad en la publicación efectiva del backend.

## 3. Brecha de la nueva fase
El backend aún depende del bloque `default_server` con certificado snakeoil para `server_name _`, mientras el servidor dispone de certificados válidos y de otros bloques por dominio. Esto reduce claridad operativa y puede dificultar una publicación más profesional y explícita.

## 4. Decisión de arranque
Se abre E15-01 para determinar con precisión qué dominio y qué bloque deben servir el backend de LEX_PENAL en el siguiente saneamiento controlado.
