# BASELINE UNIDAD E9-02 — 2026-04-12
**Proyecto:** LEX_PENAL  
**Fase:** E9  
**Unidad:** E9-02  
**Tipo:** Línea base de entrada

## 1. Estado heredado
La unidad E9-02 inicia con el backend de LEX_PENAL ya desplegado y operativo en `lexum-main`, administrado por `systemd` mediante `lex-penal.service`.

## 2. Estado técnico de entrada
- Host: `lexum-main`
- SSH endurecido en `2222`, acceso administrativo por Tailnet
- Firewall:
  - `80/443` permitidos
  - `22/2222` públicos bloqueados
  - `2222` permitido por `tailscale0`
- `nginx` activo
- `postgresql` activo y local-only
- Backend NestJS activo en `*:3010`
- Smoke test local exitoso a nivel de transporte y aplicación
- Repo en host en `detached HEAD` sobre `32f838f`

## 3. Restricciones metodológicas
- No se hace commit en el repo del host staging
- No se modifica más de lo necesario del ecosistema nginx heredado
- Cualquier ajuste debe ser reproducible y verificable
- Toda validación deberá hacerse con evidencia real (`nginx -t`, `curl`, `ss`, `systemctl`, `journalctl`)

## 4. Problema operativo a resolver
Aunque el backend ya está vivo en `3010`, aún no existe evidencia de su exposición controlada por el punto de entrada nginx del servidor staging.

## 5. Resultado esperado
Al cierre de E9-02 deberá existir un amarre verificable entre `nginx` y `lex-penal` que permita consumir el backend desde el punto de acceso staging definido.
