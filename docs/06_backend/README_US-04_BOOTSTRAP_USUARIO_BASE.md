# Sprint 1 — US-04: Bootstrap de usuario base con rol

## Archivos a incorporar al proyecto

| Archivo | Destino | Acción |
|---------|---------|--------|
| `users.repository.ts` | `src/modules/users/` | Reemplazar |
| `users.service.ts` | `src/modules/users/` | Reemplazar |
| `users.module.ts` | `src/modules/users/` | Reemplazar |
| `bootstrap.service.ts` | `src/modules/users/` | Crear (nuevo) |

**Nota:** `users.controller.ts` no se modifica en US-04. El bootstrap es un proceso interno de arranque, sin endpoints HTTP nuevos.

## Artefacto auxiliar

| Archivo | Propósito |
|---------|-----------|
| `env-bootstrap-additions.txt` | Texto para copiar y pegar al final de `.env`. No es archivo del proyecto. |

## Instrucciones de instalación

### 1. Copiar archivos al proyecto

```bash
# Desde la raíz del proyecto
cp users.repository.ts src/modules/users/
cp users.service.ts src/modules/users/
cp users.module.ts src/modules/users/
cp bootstrap.service.ts src/modules/users/
```

### 2. Agregar variables de entorno

Agregar al final de `.env` (y de `.env.example` si existe):

```env
# -----------------------------------------------------------------------------
# Bootstrap de Administrador (US-04)
# -----------------------------------------------------------------------------
BOOTSTRAP_ADMIN_ENABLED=true
BOOTSTRAP_ADMIN_NAME="Administrador LEX_PENAL"
BOOTSTRAP_ADMIN_EMAIL="admin@lexpenal.local"
BOOTSTRAP_ADMIN_PASSWORD="CambiarEnProduccion_2026!"
```

**Seguridad:** La contraseña por defecto es para desarrollo local. No versionar credenciales reales.

### 3. Verificar compilación

```bash
npm run build
```

### 4. Ejecutar y verificar bootstrap

```bash
npm run start:dev
```

### 5. Verificar en base de datos

```bash
npx prisma studio
```

Navegar a la tabla `Usuario` y verificar que existe el registro con:
- email: `admin@lexpenal.local`
- perfil: `administrador`
- activo: `true`
- creado_por: `null`

---

## Evidencia esperada por escenario

### Caso 1: Primera ejecución (base sin administradores)

**Condición:** No existe ningún usuario con perfil `administrador`.

**Resultado esperado:** Usuario bootstrap creado.

**Log:**
```
[BootstrapService] Iniciando proceso de bootstrap de usuarios...
[BootstrapService] ✅ Usuario bootstrap administrador creado: admin@lexpenal.local
[BootstrapService] Proceso de bootstrap de usuarios completado
```

---

### Caso 2: Segunda ejecución (bootstrap ya creado)

**Condición:** El email `admin@lexpenal.local` ya existe con perfil `administrador`.

**Resultado esperado:** No se duplica; operación idempotente.

**Log:**
```
[BootstrapService] Iniciando proceso de bootstrap de usuarios...
[BootstrapService] ⏭️ Usuario bootstrap ya existe: admin@lexpenal.local
[BootstrapService] Proceso de bootstrap de usuarios completado
```

---

### Caso 3: Bootstrap deshabilitado

**Condición:** `BOOTSTRAP_ADMIN_ENABLED=false` en `.env`.

**Resultado esperado:** No se crea nada; arranque normal.

**Log:**
```
[BootstrapService] Iniciando proceso de bootstrap de usuarios...
[BootstrapService] Bootstrap de administrador deshabilitado (BOOTSTRAP_ADMIN_ENABLED != true)
```

---

### Caso 4: Faltan variables de entorno

**Condición:** `BOOTSTRAP_ADMIN_ENABLED=true` pero falta `BOOTSTRAP_ADMIN_EMAIL` u otra variable requerida.

**Resultado esperado:** Error de arranque (falla explícita por configuración incompleta).

**Log:**
```
[BootstrapService] Iniciando proceso de bootstrap de usuarios...
[BootstrapService] Bootstrap habilitado pero faltan variables de entorno: BOOTSTRAP_ADMIN_EMAIL
Error: Bootstrap habilitado pero faltan variables de entorno: BOOTSTRAP_ADMIN_EMAIL
```

---

### Caso 5: Email bootstrap existe con perfil distinto

**Condición:** El email `admin@lexpenal.local` ya existe en la base, pero con perfil `estudiante` o `supervisor`.

**Resultado esperado:** Error de arranque (inconsistencia crítica de configuración).

**Log:**
```
[BootstrapService] Iniciando proceso de bootstrap de usuarios...
[BootstrapService] ❌ Error en bootstrap: Inconsistencia crítica: email admin@lexpenal.local existe con perfil estudiante, se esperaba administrador
Error: Inconsistencia crítica: email admin@lexpenal.local existe con perfil estudiante, se esperaba administrador
```

---

### Caso 6: Ya existe otro administrador (distinto al email bootstrap)

**Condición:** No existe el email `admin@lexpenal.local`, pero sí existe otro usuario con perfil `administrador` (ej: `director@consultorio.edu.co`).

**Resultado esperado:** No se crea un segundo administrador; condición de existencia ya satisfecha.

**Log:**
```
[BootstrapService] Iniciando proceso de bootstrap de usuarios...
[BootstrapService] ⏭️ Ya existe al menos un administrador en el sistema
[BootstrapService] Proceso de bootstrap de usuarios completado
```

---

## Criterios de aceptación US-04

| Criterio | Verificación |
|----------|--------------|
| Usuario admin creado al arrancar | Log `✅ Usuario bootstrap administrador creado` |
| Idempotente (no duplica) | Reiniciar app → Log `⏭️ Usuario bootstrap ya existe` |
| Contraseña hasheada | Campo `password_hash` en BD no es texto plano |
| `creado_por` es null | Verificar en Prisma Studio |
| Sin endpoint HTTP nuevo | US-04 no modificó `users.controller.ts` |
| Variables de entorno | Configuración externa en `.env` |
| Inconsistencia detectada | Email con perfil distinto → error explícito |
| Admin previo respetado | Otro admin existe → no crea duplicado |

---

## Definition of Done US-04

- [ ] Archivos incorporados en `src/modules/users/`
- [ ] Variables de entorno en `.env` y `.env.example`
- [ ] `npm run build` sin errores
- [ ] `npm run start:dev` arranca correctamente
- [ ] Log de bootstrap visible en consola
- [ ] Existe administrador válido en BD; si el bootstrap lo creó, queda con `activo=true` y `creado_por=null`
- [ ] Reinicio de app no duplica usuario
- [ ] `users.controller.ts` no fue modificado

---

## Siguiente paso

Con US-04 completada, proceder a **US-01 — Iniciar sesión**.

Antes de codificar login, validar que:
- El usuario bootstrap realmente se crea o se reconoce
- El hash quedó persistido correctamente
- `UsersService.findByEmail()` está operativo
