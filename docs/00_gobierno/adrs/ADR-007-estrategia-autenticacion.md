# ADR-007 — Estrategia de autenticación

| Campo | Valor |
|---|---|
| Estado | **Cerrado — Opción A elegida** |
| Fecha | (completar al decidir) |
| Decisor | (completar) |
| Documentos relacionados | `docs/06_backend/ARQUITECTURA_BACKEND.md`, `docs/07_frontend/ARQUITECTURA_FRONTEND.md`, `docs/04_api/CONTRATO_API.md`, `docs/09_despliegue/DESPLIEGUE_VM.md` |

---

## Contexto

LexPenal usa un esquema híbrido de autenticación ya cerrado y documentado:

- **Cookie HttpOnly**: usada por el middleware de Next.js para proteger rutas
  y por `GET /api/v1/auth/session` para rehidratar el token en el cliente.
- **Bearer token**: usado por los Client Components en todas las llamadas
  directas al backend.

Lo que está pendiente de decidir es la **estrategia del token de acceso**:
si el sistema emite solo un token de acceso (JWT simple) o si emite un par
de tokens (access token de vida corta + refresh token de vida larga).

Esta decisión afecta:
- la vida útil de la sesión del usuario;
- la complejidad del módulo de auth en el backend;
- las variables de entorno del servidor;
- la experiencia del usuario (frecuencia de cierre de sesión automático);
- el comportamiento del middleware de Next.js.

---

## Opciones evaluadas

### Opción A — JWT simple (solo access token)

El backend emite un único JWT al hacer login. El token tiene una vida útil
configurada (por defecto `8h` según `DESPLIEGUE_VM.md`). Cuando expira,
el usuario debe hacer login nuevamente.

**Flujo**
```
Login → backend emite JWT (8h) → cliente lo usa en Bearer
Al expirar → 401 → frontend redirige a login
```

**Ventajas**
- Implementación simple — un solo tipo de token, sin tabla de refresh tokens.
- Sin estado adicional en el backend — el JWT es autoverificable.
- Menor superficie de ataque — no hay refresh tokens que robar o revocar.
- Adecuado para el MVP: sesiones de trabajo típicas son de 4–8h.

**Desventajas**
- Cuando el token expira, el usuario pierde la sesión sin previo aviso.
- No hay mecanismo de cierre de sesión anticipado basado en revocación
  (solo se puede invalidar la cookie, no el token mismo).
- Si se extiende la vida del token para reducir interrupciones,
  aumenta el riesgo si el token es comprometido.

**Variables de entorno requeridas**
```env
JWT_SECRET=...
JWT_EXPIRY=8h
SESSION_COOKIE_SECRET=...
```

---

### Opción B — Access token + refresh token

El backend emite dos tokens al hacer login:
- **Access token**: vida corta (15–30 minutos). Usado en Bearer.
- **Refresh token**: vida larga (7–30 días). Almacenado en cookie HttpOnly.
  Usado exclusivamente para obtener un nuevo access token sin hacer login.

**Flujo**
```
Login → backend emite access token (15min) + refresh token (7d)
Access token expira → cliente llama POST /auth/refresh con cookie
Backend verifica refresh token → emite nuevo access token
Refresh token expira → usuario debe hacer login
```

**Ventajas**
- Experiencia de usuario fluida — la sesión se renueva automáticamente
  durante días sin que el usuario lo note.
- El access token de vida corta limita el daño si es interceptado.
- Posibilidad de revocar sesiones: invalidar el refresh token cierra la sesión
  efectivamente, incluso si el access token aún no expiró.

**Desventajas**
- Complejidad adicional: tabla de refresh tokens en base de datos,
  endpoint `POST /auth/refresh`, lógica de rotación y revocación.
- La cookie del refresh token debe ser HttpOnly, Secure y SameSite=Strict —
  configuración cuidadosa en Nginx y en el backend.
- La aplicación frontend deberá incorporar una estrategia de renovación automática del access token, coordinada con el backend y compatible con el middleware de Next.js.
- Mayor superficie a implementar en MVP con tiempo acotado.

**Variables de entorno adicionales requeridas**
```env
JWT_SECRET=...
JWT_EXPIRY=15m
JWT_REFRESH_SECRET=SECRETO_DIFERENTE_AL_ACCESS
JWT_REFRESH_EXPIRY=7d
SESSION_COOKIE_SECRET=...
```

---

## Criterios de decisión

| Criterio | JWT simple | Access + Refresh |
|---|---|---|
| Complejidad de implementación | Baja | Media-alta |
| Experiencia de sesión del usuario | Interrupciones al expirar | Transparente |
| Seguridad ante token comprometido | Exposición durante toda la vida del token | Limitada a 15–30 minutos |
| Capacidad de revocación | No (solo via cookie) | Sí (invalidar refresh token) |
| Variables de entorno | 3 | 5 |
| Endpoints adicionales | Ninguno | `POST /auth/refresh` |
| Estado en base de datos | Sin estado | Tabla `refresh_tokens` |
| Adecuación al MVP | Alta | Media |

---

## Recomendación

Para el **MVP**, la **Opción A — JWT simple** es adecuada:

- Las sesiones de trabajo en LexPenal son sesiones activas de análisis
  jurídico — no sesiones en segundo plano. Un token de 8h cubre la jornada
  típica sin interrupciones.
- Reduce el alcance de implementación del módulo de auth.
- El esquema híbrido con Cookie HttpOnly ya cubre la protección de rutas
  en el middleware sin necesidad de refresh token.

Para **producción con usuarios reales**, evaluar migrar a Opción B:

- Si los usuarios trabajan en sesiones largas o multijornada.
- Si se requiere cierre de sesión remoto (ej. dispositivo perdido).
- Si el contexto de seguridad del despacho lo exige.

La migración de A a B es posible sin cambios en el contrato de la API
de herramientas — solo afecta el módulo de auth y el middleware de Next.js.

---

## Decisión

> **[x] Opción A — JWT simple**
> **[ ] Opción B — Access token + refresh token**

**Justificación**: Las sesiones de trabajo en LexPenal son sesiones activas
de análisis jurídico — no sesiones en segundo plano. Un token de 8h cubre
la jornada típica sin interrupciones. La Opción A reduce el alcance del
módulo de auth en el MVP y no requiere tabla adicional ni endpoint de refresh.
El esquema híbrido Cookie HttpOnly + Bearer ya cubre la protección de rutas
sin necesidad de refresh token. La migración a Opción B es posible en
producción sin cambios en el contrato de herramientas.

---

## Consecuencias

### Si se elige Opción A — JWT simple
- `AuthService.login()` emite un JWT con vida de `JWT_EXPIRY`.
- `GET /api/v1/auth/session` verifica la cookie y retorna el token.
- `POST /api/v1/auth/logout` invalida la cookie — el logout del MVP es
  logout local/controlado por expiración, no revocación fuerte del JWT emitido.
- No se requiere tabla `refresh_tokens`.
- Variables de entorno: `JWT_SECRET`, `JWT_EXPIRY`, `SESSION_COOKIE_SECRET`.
- `DESPLIEGUE_VM.md` queda como está — no requiere variables adicionales.
- **Nota de seguridad**: el access token no debe persistirse en `localStorage`
  ni en `sessionStorage`. Debe mantenerse en memoria de sesión del frontend
  y rehidratarse vía `GET /api/v1/auth/session` usando la cookie HttpOnly.

### Si se elige Opción B — Access token + refresh token
- `AuthService.login()` emite access token + refresh token.
- Añadir `POST /api/v1/auth/refresh` al contrato API.
- Crear tabla `refresh_tokens` en el modelo de datos.
- El frontend deberá contar con una estrategia de reintento/renovación del
  access token al detectar expiración, usando `/auth/refresh` según la
  política definida. El punto exacto de integración (cliente API, capa de
  fetch, middleware de Next.js) se define al implementar.
- Añadir `JWT_REFRESH_SECRET` y `JWT_REFRESH_EXPIRY` a `DESPLIEGUE_VM.md`.
- `CONTRATO_API.md` debe documentar el endpoint `/auth/refresh`.

### En ambos casos
- `ARQUITECTURA_BACKEND.md` debe actualizarse con la opción elegida.
- El esquema híbrido Cookie HttpOnly + Bearer se mantiene sin cambios
  — esta decisión solo afecta la estrategia del token, no su mecanismo de transporte.
