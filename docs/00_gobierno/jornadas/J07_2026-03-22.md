# Jornada 07 — Nota de Cierre
## Bloque de Autenticación Sprint 1

**Fecha:** 2026-03-22 / 2026-03-23  
**Objetivo:** Completar el bloque de autenticación del Sprint 1  
**Estado:** ✅ CUMPLIDO

---

## Historias cerradas

| Historia | Descripción | Estado |
|----------|-------------|--------|
| US-01 | Iniciar sesión | ✅ CERRADA |
| US-02 | Persistencia de sesión | ✅ CERRADA |
| US-05 | Consultar mi perfil | ✅ CERRADA |
| US-03 | Cerrar sesión | ✅ CERRADA |

---

## Endpoints funcionales

| Método | Ruta | Descripción | Protegido |
|--------|------|-------------|-----------|
| POST | `/api/v1/auth/login` | Autenticación, retorna JWT | No |
| POST | `/api/v1/auth/logout` | Cierre semántico de sesión | No |
| GET | `/api/v1/users/me` | Perfil del usuario autenticado | Sí |

---

## Infraestructura de autenticación

| Componente | Ubicación | Propósito |
|------------|-----------|-----------|
| `JwtStrategy` | `src/modules/auth/strategies/` | Valida JWT, extrae payload |
| `JwtAuthGuard` | `src/modules/auth/guards/` | Protege rutas |
| `@CurrentUser()` | `src/modules/auth/decorators/` | Extrae usuario del request |

---

## Archivos modificados/creados

### Configuración base
| Archivo | Cambio |
|---------|--------|
| `src/main.ts` | Prefijo global `api/v1` + ValidationPipe |
| `src/common/filters/http-exception.filter.ts` | Implementado (era stub) |

### Módulo auth
| Archivo | Cambio |
|---------|--------|
| `auth.module.ts` | PassportModule + JwtStrategy |
| `auth.service.ts` | Implementado login() |
| `auth.controller.ts` | POST /login, POST /logout |
| `dto/login.dto.ts` | Validaciones class-validator |
| `dto/login-response.dto.ts` | Nuevo |
| `strategies/jwt.strategy.ts` | Nuevo |
| `guards/jwt-auth.guard.ts` | Nuevo |
| `decorators/current-user.decorator.ts` | Nuevo |

### Módulo users
| Archivo | Cambio |
|---------|--------|
| `users.controller.ts` | GET /me + stubs 501 |

---

## Decisiones técnicas adoptadas

| Decisión | Justificación |
|----------|---------------|
| JWT stateless | Logout es semántico; cliente elimina token |
| Payload JWT mínimo | Solo sub, email, perfil; nombre se consulta en BD |
| Error genérico 401 | Evita enumeración de usuarios |
| Stubs 501 | Mejor que 500; comunica intención |
| Prefijo global | Evita duplicación en controllers |

---

## Validaciones ejecutadas

### US-01 — Login
| Caso | Resultado |
|------|-----------|
| Credenciales válidas | 200 + JWT + user ✅ |
| Password incorrecta | 401 genérico ✅ |
| Email inexistente | 401 genérico ✅ |
| DTO inválido | 400 con errores ✅ |

### US-02 — Infraestructura
| Verificación | Resultado |
|--------------|-----------|
| Compilación | Sin errores ✅ |
| Arranque | Sin errores de auth ✅ |

### US-05 — GET /users/me
| Caso | Resultado |
|------|-----------|
| Con token válido | 200 + datos ✅ |
| Sin token | 401 ✅ |
| Token inválido | 401 ✅ |

### US-03 — Logout
| Caso | Resultado |
|------|-----------|
| POST /logout | 204 No Content ✅ |

### Flujo integrado
| Paso | Resultado |
|------|-----------|
| Login | Token obtenido ✅ |
| GET /me | Datos correctos ✅ |
| Logout | 204 ✅ |
| Post-logout | Token válido (stateless) ✅ |

---

## Deuda técnica identificada

| Item | Severidad | Nota |
|------|-----------|------|
| Duplicación prefijo en otros controllers | Menor | AuditController tiene `/api/v1/api/v1/...` |
| Logout no invalida token | Diseño | Aceptable para MVP stateless |
| Stubs 501 en users | Menor | Documentado, no bloquea |

---

## Estado del Sprint 1 post-J07

| Historia | Estado |
|----------|--------|
| US-04 — Bootstrap de usuario | ✅ CERRADA (J06) |
| US-01 — Iniciar sesión | ✅ CERRADA |
| US-02 — Persistencia de sesión | ✅ CERRADA |
| US-05 — Consultar mi perfil | ✅ CERRADA |
| US-03 — Cerrar sesión | ✅ CERRADA |

**Sprint 1 — Bloque de autenticación: COMPLETO ✅**

---

## Flujo funcional validado

```
login → token → /users/me → logout
```

El sistema permite:
1. Autenticar usuario con email/password
2. Obtener JWT válido por 24h
3. Acceder a rutas protegidas con el token
4. Consultar perfil del usuario autenticado
5. Cerrar sesión (semántico)

---

## Siguiente fase

Con el bloque de autenticación completo, el proyecto está listo para:
- **Sprint 2:** Gestión básica de casos (US-06 a US-10)

Precondiciones para Sprint 2:
- Usuario autenticado puede crear casos ✅
- Guard disponible para proteger rutas de casos ✅
- Decorador disponible para obtener userId ✅
