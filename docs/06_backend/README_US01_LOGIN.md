# Sprint 1 — US-01: Iniciar sesión

**Estado:** Aprobado para implementación  
**Alcance:** US-01 — Iniciar sesión  
**Nota operativa:** Verificar que la contraseña de prueba coincida con la del usuario bootstrap real. Confirmar que `main.ts` tenga prefijo global y ValidationPipe antes de instalar.

---

## Configuración base requerida (una sola vez)

Antes de instalar los archivos de auth, verificar que `main.ts` tenga:
- Prefijo global `api/v1`
- `ValidationPipe` habilitado

Si tu `main.ts` no tiene estas configuraciones, actualízalo con el archivo `main.ts` incluido en este paquete, o agrega manualmente:

```typescript
app.setGlobalPrefix('api/v1');
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,
  forbidNonWhitelisted: true,
  transform: true,
}));
```

---

## Archivos de US-01 a incorporar

| Archivo | Destino | Acción |
|---------|---------|--------|
| `auth.service.ts` | `src/modules/auth/` | Actualizar con versión US-01 |
| `auth.controller.ts` | `src/modules/auth/` | Actualizar con versión US-01 |
| `auth.module.ts` | `src/modules/auth/` | Actualizar con versión US-01 |
| `dto/login.dto.ts` | `src/modules/auth/dto/` | Actualizar con versión US-01 |
| `dto/login-response.dto.ts` | `src/modules/auth/dto/` | Crear (nuevo) |

## Dependencias requeridas

Verificar que estén instaladas:

```bash
npm list class-validator class-transformer
```

Si no están instaladas:

```bash
npm install class-validator class-transformer
```

## Instrucciones de instalación

### 1. Copiar archivos al proyecto

**Git Bash:**
```bash
# Desde la raíz del proyecto
cp auth.service.ts src/modules/auth/
cp auth.controller.ts src/modules/auth/
cp auth.module.ts src/modules/auth/
cp dto/login.dto.ts src/modules/auth/dto/
cp dto/login-response.dto.ts src/modules/auth/dto/
```

**PowerShell:**
```powershell
# Desde la raíz del proyecto
Copy-Item auth.service.ts -Destination src/modules/auth/
Copy-Item auth.controller.ts -Destination src/modules/auth/
Copy-Item auth.module.ts -Destination src/modules/auth/
Copy-Item dto/login.dto.ts -Destination src/modules/auth/dto/
Copy-Item dto/login-response.dto.ts -Destination src/modules/auth/dto/
```

### 2. Verificar compilación

```bash
npm run build
```

### 3. Ejecutar y probar

```bash
npm run start:dev
```

## Prueba del endpoint

**Importante:** La contraseña en estos ejemplos (`CambiarEnProduccion_2026!`) debe coincidir exactamente con la configurada en `BOOTSTRAP_ADMIN_PASSWORD` de tu `.env`. Si usaste otra contraseña, ajusta los comandos de prueba.

### Login exitoso

```bash
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@lexpenal.local","password":"CambiarEnProduccion_2026!"}'
```

**Respuesta esperada (200):**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "71e47a55-8803-4842-bf3c-...",
    "nombre": "Administrador LEX_PENAL",
    "email": "admin@lexpenal.local",
    "perfil": "administrador"
  }
}
```

### Login fallido (credenciales inválidas)

```bash
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@lexpenal.local","password":"incorrecta"}'
```

**Respuesta esperada (401):**

```json
{
  "statusCode": 401,
  "message": "Credenciales inválidas",
  "error": "Unauthorized"
}
```

### Login fallido (email no existe)

```bash
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"noexiste@test.com","password":"cualquiera"}'
```

**Respuesta esperada (401):**

```json
{
  "statusCode": 401,
  "message": "Credenciales inválidas",
  "error": "Unauthorized"
}
```

### Login fallido (validación de DTO)

```bash
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"","password":""}'
```

**Respuesta esperada (400):**

```json
{
  "statusCode": 400,
  "message": ["Email es obligatorio", "Password es obligatorio"],
  "error": "Bad Request"
}
```

---

## Criterios de aceptación US-01

| Criterio | Verificación |
|----------|--------------|
| Endpoint responde en `/api/v1/auth/login` | curl retorna 200 con credenciales válidas |
| Retorna JWT válido | `access_token` presente en respuesta |
| Retorna datos del usuario | `user` con id, nombre, email, perfil |
| No expone datos sensibles | Sin password_hash ni creado_por |
| Error genérico 401 | Mismo mensaje para usuario inexistente, inactivo o password incorrecta |
| Validación de DTO | 400 si email o password vacíos/inválidos |

---

## Definition of Done US-01

- [ ] Configuración base verificada (`main.ts` con prefijo global y ValidationPipe)
- [ ] Archivos incorporados en `src/modules/auth/`
- [ ] `npm run build` sin errores
- [ ] `npm run start:dev` arranca correctamente
- [ ] Login exitoso retorna JWT y datos de usuario
- [ ] Login fallido retorna 401 con mensaje genérico
- [ ] Validación de DTO retorna 400 con errores específicos
- [ ] No se exponen datos sensibles

---

## Siguiente paso

Con US-01 completada, proceder a **US-02 — Persistencia de sesión**.

Entregables de US-02:
- `JwtStrategy`
- `JwtAuthGuard`
- Decorador `@CurrentUser()`
