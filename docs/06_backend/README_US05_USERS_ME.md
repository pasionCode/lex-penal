# Sprint 1 — US-05: Consultar mi perfil

**Estado:** Aprobado para implementación  
**Alcance:** US-05 — Endpoint `GET /users/me`  
**Dependencia:** Requiere US-02 completada (JwtAuthGuard, @CurrentUser)

---

## Archivo a incorporar

| Archivo | Destino | Acción |
|---------|---------|--------|
| `users.controller.ts` | `src/modules/users/` | Actualizar con versión US-05 |

**Nota:** Solo se modifica el controller. `UsersService.getSessionData()` ya existe desde US-04 y no requiere cambios.

---

## Instrucciones de instalación

### 1. Copiar archivo

**Git Bash:**
```bash
cp users.controller.ts src/modules/users/
```

**PowerShell:**
```powershell
Copy-Item users.controller.ts -Destination src/modules/users/
```

### 2. Verificar compilación

```bash
npm run build
```

### 3. Ejecutar

```bash
npm run start:dev
```

---

## Prueba del endpoint

### 1. Obtener token (login)

```bash
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@lexpenal.local","password":"CambiarEnProduccion_2026!"}'
```

Copia el `access_token` de la respuesta.

### 2. Consultar perfil (con token)

```bash
curl -X GET http://localhost:3001/api/v1/users/me \
  -H "Authorization: Bearer <TOKEN>"
```

**Respuesta esperada (200):**
```json
{
  "id": "71e47a55-8803-4842-bf3c-...",
  "nombre": "Administrador LEX_PENAL",
  "email": "admin@lexpenal.local",
  "perfil": "administrador"
}
```

### 3. Sin token (debe fallar)

```bash
curl -X GET http://localhost:3001/api/v1/users/me
```

**Respuesta esperada (401):**
```json
{
  "statusCode": 401,
  "error": "Unauthorized",
  "mensaje": "Unauthorized",
  "path": "/api/v1/users/me",
  "timestamp": "2026-03-23T..."
}
```

### 4. Token inválido (debe fallar)

```bash
curl -X GET http://localhost:3001/api/v1/users/me \
  -H "Authorization: Bearer token_invalido"
```

**Respuesta esperada (401):**
```json
{
  "statusCode": 401,
  "error": "Unauthorized",
  "mensaje": "Unauthorized",
  "path": "/api/v1/users/me",
  "timestamp": "2026-03-23T..."
}
```

---

## Criterios de aceptación US-05

| Criterio | Verificación |
|----------|--------------|
| Ruta protegida | Requiere token válido |
| Retorna datos del usuario | id, nombre, email, perfil |
| No expone datos sensibles | Sin password_hash, creado_por |
| 401 sin token | Responde Unauthorized |
| 401 token inválido | Responde Unauthorized |

---

## Definition of Done US-05

- [ ] `users.controller.ts` actualizado
- [ ] `npm run build` sin errores
- [ ] `npm run start:dev` arranca correctamente
- [ ] `GET /users/me` con token válido retorna datos del usuario
- [ ] `GET /users/me` sin token retorna 401
- [ ] No se exponen datos sensibles

---

## Siguiente paso

Con US-05 completada, proceder a **US-03 — Cerrar sesión** (`POST /auth/logout`).
