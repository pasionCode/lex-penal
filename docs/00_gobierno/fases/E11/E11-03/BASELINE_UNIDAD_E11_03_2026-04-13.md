# BASELINE UNIDAD E11-03 — 2026-04-13

## 1. Punto de partida
LEX_PENAL ya se encuentra operativo en el VPS, con servicio systemd y proxy Nginx funcionales, pero el código desplegado está atrasado frente al repositorio local y remoto.

## 2. Commit actual desplegado
- `32f838f`

## 3. Commit objetivo inicial
- `5255060` o el HEAD vigente de `origin/main` al momento de ejecutar la alineación.

## 4. Resultado esperado
Actualizar el despliegue sin romper:
- servicio `lex-penal.service`
- proxy `/api/v1/`
- comportamiento mínimo del smoke test.
