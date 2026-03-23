# Sprint 1 — US-02: Persistencia de sesión

**Estado:** Aprobado para implementación  
**Alcance:** US-02 — Infraestructura de autenticación (JwtStrategy, JwtAuthGuard, @CurrentUser)  
**Nota operativa:** Esta historia crea la infraestructura. El endpoint funcional `GET /users/me` se implementa en US-05.

---

## Archivos de US-02 a incorporar

| Archivo | Destino | Acción |
|---------|---------|--------|
| `strategies/jwt.strategy.ts` | `src/modules/auth/strategies/` | Crear (nuevo) |
| `guards/jwt-auth.guard.ts` | `src/modules/auth/guards/` | Crear (nuevo) |
| `decorators/current-user.decorator.ts` | `src/modules/auth/decorators/` | Crear (nuevo) |
| `auth.module.ts` | `src/modules/auth/` | Actualizar con versión US-02 |

---

## Instrucciones de instalación

### 1. Crear carpetas

```bash
mkdir -p src/modules/auth/strategies
mkdir -p src/modules/auth/guards
mkdir -p src/modules/auth/decorators
```

### 2. Copiar archivos

**Git Bash:**
```bash
cp strategies/jwt.strategy.ts src/modules/auth/strategies/
cp guards/jwt-auth.guard.ts src/modules/auth/guards/
cp decorators/current-user.decorator.ts src/modules/auth/decorators/
cp auth.module.ts src/modules/auth/
```

**PowerShell:**
```powershell
Copy-Item strategies/jwt.strategy.ts -Destination src/modules/auth/strategies/
Copy-Item guards/jwt-auth.guard.ts -Destination src/modules/auth/guards/
Copy-Item decorators/current-user.decorator.ts -Destination src/modules/auth/decorators/
Copy-Item auth.module.ts -Destination src/modules/auth/
```

### 3. Verificar compilación

```bash
npm run build
```

### 4. Ejecutar

```bash
npm run start:dev
```

---

## Comportamiento esperado

### JwtStrategy

- Extrae token del header `Authorization: Bearer <token>`
- Valida firma con `JWT_SECRET`
- Si válido, asigna payload a `req.user`

**`req.user` contiene:**
```typescript
{
  sub: string;      // user.id
  email: string;
  perfil: string;
}
```

### JwtAuthGuard

- Protege rutas que requieren autenticación
- Token válido → permite acceso
- Token ausente/inválido/expirado → 401 Unauthorized

### @CurrentUser() decorator

```typescript
// Uso completo
@CurrentUser() user: JwtPayload

// Uso con propiedad específica
@CurrentUser('sub') userId: string
```

---

## Prueba de la infraestructura

La prueba funcional se hará en US-05 con `GET /users/me`. 

Para verificar que la infraestructura compila correctamente:

```bash
npm run build
```

Si compila sin errores, la infraestructura está lista.

---

## Criterios de aceptación US-02

| Criterio | Verificación |
|----------|--------------|
| JwtStrategy registrada | El proyecto compila y el backend arranca sin error de estrategia/auth |
| JwtAuthGuard exportable | Importable desde auth module |
| @CurrentUser funcional | Disponible para controllers |
| PassportModule integrado | auth.module.ts actualizado |

---

## Definition of Done US-02

- [ ] Carpetas creadas (strategies, guards, decorators)
- [ ] Archivos incorporados en `src/modules/auth/`
- [ ] `auth.module.ts` incluye `PassportModule` y registra `JwtStrategy`
- [ ] `npm run build` sin errores
- [ ] `npm run start:dev` arranca correctamente

---

## Siguiente paso

Con US-02 completada, proceder a **US-05 — Consultar mi perfil** (`GET /users/me`).

El endpoint usará:
- `@UseGuards(JwtAuthGuard)` para proteger la ruta
- `@CurrentUser('sub')` para obtener el userId
- `UsersService.getSessionData()` para consultar BD
