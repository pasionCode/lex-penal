# Seguridad base — LexPenal MVP

| Campo | Valor |
|---|---|
| Versión | 1.0 |
| Fecha | 2026-03-06 |
| Estado | Vigente |
| Documentos relacionados | `docs/00_gobierno/adrs/ADR-007-estrategia-autenticacion.md`, `docs/07_infraestructura/DESPLIEGUE_VM.md`, `docs/03_datos/REGLAS_NEGOCIO.md`, `docs/06_backend/ARQUITECTURA_BACKEND.md` |

---

## Alcance

Este documento define las medidas de seguridad del MVP de LexPenal.
Cubre autenticación, autorización, protección de datos en tránsito
y en reposo, seguridad de infraestructura y controles de aplicación.

LexPenal gestiona expedientes jurídicos de defensa penal — datos
sensibles con implicaciones legales y de confidencialidad para los
procesados. La seguridad no es una capa opcional: es un requisito
del dominio.

Lo que queda fuera del alcance del MVP y requiere decisión formal
para fases posteriores:
- Autenticación de dos factores (2FA).
- Gestión avanzada de sesiones (multi-dispositivo, cierre remoto).
- Auditoría de seguridad externa / pentesting formal.
- Cifrado de datos en reposo a nivel de disco o columna.
- Anonimización de contexto antes de envío al proveedor de IA.

---

## 1. Autenticación

### Esquema híbrido Cookie HttpOnly + Bearer

LexPenal usa un esquema de autenticación híbrido cerrado en ADR-007:

| Mecanismo | Uso |
|---|---|
| Cookie HttpOnly | Usada por el middleware de Next.js para proteger rutas server-side y para rehidratación del token en Client Components vía `GET /api/v1/auth/session`. No transporta el access token al cliente directamente. |
| Bearer token | Usado por Client Components en todas las llamadas directas al backend. Se mantiene en memoria de sesión del frontend — nunca en `localStorage` ni `sessionStorage`. |

**Aclaración del esquema del MVP**: la cookie se usa para sesión SSR
y rehidratación del token. El access token del cliente se mantiene
exclusivamente en memoria. No existe refresh token en el MVP — esta
decisión está cerrada en ADR-007. El logout invalida la cookie; el
JWT emitido no se revoca activamente.

**Flujo de autenticación**
```
Login → POST /api/v1/auth/login
  → backend valida credenciales
  → emite JWT (8h)
  → establece cookie HttpOnly con el token
  → retorna token al cliente

Client Component necesita token:
  → GET /api/v1/auth/session (con cookie HttpOnly)
  → backend verifica cookie y retorna token
  → cliente usa token como Bearer en llamadas al backend
```

### Reglas de seguridad del token

- El token JWT **no debe persistirse en `localStorage` ni `sessionStorage`**.
  Debe mantenerse en memoria de sesión del frontend y rehidratarse vía
  `GET /api/v1/auth/session` usando la cookie HttpOnly.
- La cookie debe configurarse con los atributos `HttpOnly`, `Secure` y
  `SameSite=Strict` en producción.
- Vida útil del token: `8h` — cubre una jornada de trabajo típica del
  consultorio sin interrupciones.
- El logout (`POST /api/v1/auth/logout`) invalida la cookie. El JWT emitido
  no se revoca activamente — el logout del MVP es logout local controlado
  por expiración, no revocación fuerte del token.

### Almacenamiento de contraseñas

Las contraseñas nunca se almacenan en claro (RN-DAT-04). El campo
`password_hash` en la tabla `usuarios` almacena exclusivamente el hash
de la contraseña usando `bcrypt` o `argon2`. El algoritmo concreto
se define al implementar `AuthService`.

### Variables de entorno de autenticación

```env
JWT_SECRET=<secreto_fuerte_generado>
JWT_EXPIRY=8h
SESSION_COOKIE_SECRET=<secreto_diferente_al_jwt>
```

Estas variables **nunca se incluyen en el repositorio**. Viven
exclusivamente en el entorno del servidor.

---

## 2. Autorización

### Modelo de control de acceso

LexPenal usa control de acceso basado en roles (RBAC) con tres perfiles:

| Perfil | Acceso |
|---|---|
| `estudiante` | Solo sus propios casos. No puede revisar ni aprobar. |
| `supervisor` | Todos los casos en `pendiente_revision`. Revisa, aprueba, devuelve. No edita análisis. |
| `administrador` | Todos los casos del sistema. Gestión de usuarios. No edita análisis ni aprueba casos. |

### Reglas de autorización

- El perfil del usuario se verifica en cada solicitud en el servidor —
  nunca en el cliente (RN-USR-01).
- El perfil solo puede modificarlo el administrador (RN-USR-03).
- Un usuario desactivado no puede iniciar sesión (`activo = false` → `401`) (RN-USR-06).
- Tener el perfil correcto no garantiza que una transición sea posible —
  el backend verifica primero el perfil y luego las reglas de guardia
  del estado del caso (RN-USR-04).

### Autorización en el backend

La autenticación y una primera validación de acceso (perfil mínimo
requerido) ocurren antes del controlador. Las reglas de autorización
de negocio y las guardias del caso se resuelven en los servicios de
dominio — principalmente en `CasoEstadoService` y en los servicios
de herramientas. Los controladores no implementan lógica de autorización
de negocio directamente.

---

## 3. Seguridad de infraestructura

### Puertos expuestos

Solo los puertos 80 y 443 son accesibles desde el exterior.
Los puertos de aplicación y base de datos son internos:

| Puerto | Servicio | Exposición |
|---|---|---|
| 80 | Nginx (redirección a HTTPS) | Público |
| 443 | Nginx (tráfico de la app) | Público |
| 22 | SSH | Solo IPs autorizadas |
| 3000 | Frontend (Next.js) | Solo localhost vía Nginx |
| 3001 | Backend (NestJS) | Solo localhost vía Nginx |
| 5432 | PostgreSQL | Solo localhost |

El firewall se gestiona con UFW:
```bash
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable
```

PostgreSQL (5432) y los puertos de aplicación (3000, 3001) **no se abren
al exterior bajo ninguna circunstancia**.

### TLS / HTTPS

Todo el tráfico externo va por HTTPS. La configuración de Nginx incluye:

```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_session_cache shared:SSL:10m;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options DENY always;
add_header X-Content-Type-Options nosniff always;
```

Los certificados SSL se gestionan con Certbot. La renovación automática
es obligatoria — un certificado vencido bloquea el acceso al sistema.

### Acceso SSH

El acceso SSH al servidor de producción debe limitarse a IPs autorizadas.
Las claves SSH deben rotarse si hay cambio en el equipo técnico. No se
permite autenticación SSH por contraseña en producción. Hardening
mínimo obligatorio en `/etc/ssh/sshd_config`:

```
PermitRootLogin no
PasswordAuthentication no
```

La operación ordinaria del sistema debe realizarse con un usuario no
root con permisos limitados. El usuario root se reserva para tareas
administrativas excepcionales.

---

## 4. Seguridad de la aplicación

### Logs de aplicación

Los logs de aplicación y de errores no deben registrar secretos,
tokens completos, contraseñas ni datos sensibles del expediente.
Las excepciones no manejadas se registran con stack trace en logs
internos del servidor — nunca se exponen al cliente. En producción,
el nivel de log debe configurarse para excluir datos de depuración
que puedan contener información sensible.

### Validación de entrada

Toda entrada del usuario se valida con `class-validator` en los DTOs
de NestJS antes de llegar a los servicios. El backend rechaza payloads
que no cumplan el esquema con `400 Bad Request`. La validación del
frontend es orientativa; la del backend es definitiva.

### Protección contra inyección SQL

Prisma genera consultas parametrizadas por defecto. No se construyen
consultas SQL concatenando strings. Las operaciones que requieran SQL
nativo deben usar placeholders parametrizados de Prisma.

### Protección CSRF

El riesgo CSRF clásico se reduce por dos mecanismos combinados:
`SameSite=Strict` en la cookie de sesión previene su envío en
solicitudes cross-site; y las operaciones cliente autenticadas
usan Bearer token en el header `Authorization`, no cookies.
Cualquier endpoint que acepte autenticación por cookie debe
mantenerse dentro de la política SSR/session definida — no debe
exponerse como endpoint de operación general.

### Headers de seguridad

Los headers de seguridad se configuran en Nginx y aplican a todas
las respuestas del sistema:

| Header | Valor | Propósito |
|---|---|---|
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` | Fuerza HTTPS |
| `X-Frame-Options` | `DENY` | Previene clickjacking |
| `X-Content-Type-Options` | `nosniff` | Previene MIME sniffing |

### Secretos y credenciales

- Ningún secreto, credencial ni clave privada se incluye en el repositorio.
- Las variables de entorno del servidor se documentan en `DESPLIEGUE_VM.md`
  con sus nombres pero sin valores.
- Las credenciales del proveedor de IA viven exclusivamente en variables
  de entorno del servidor — nunca en el cliente ni en el repositorio
  (RN-IA-03).

---

## 5. Protección de datos

### Datos sensibles en el expediente

Los expedientes jurídicos contienen datos personales sensibles del
procesado: identidad, situación judicial, estrategia de defensa.
El acceso está restringido por perfil y por asignación directa del caso.

### Datos en tránsito

Todo el tráfico entre cliente y servidor va cifrado por TLS 1.2 o 1.3.
No existe tráfico HTTP sin cifrar en producción — Nginx redirige todo
el tráfico del puerto 80 al 443.

### Datos en reposo

En el MVP, los datos en reposo no están cifrados a nivel de disco o
columna. La protección en reposo se basa en el control de acceso al
servidor (SSH + firewall) y la restricción de puertos.

El cifrado de datos en reposo queda documentado como exclusión explícita
del MVP. Su implementación en fases posteriores requiere decisión formal.

### Backup y retención

La base de datos se respalda diariamente a las 02:00 con retención de
30 días. Los backups deben almacenarse en ubicación física distinta al
servidor de producción. Un backup comprometido equivale a datos
comprometidos — el acceso a los backups debe seguir las mismas
restricciones que el servidor de producción. La restauración debe
probarse periódicamente — un backup no verificado no es un backup.

---

## 6. Auditoría y trazabilidad de seguridad

Las siguientes acciones quedan registradas de forma inmutable en
`eventos_auditoria` (RN-AUD-01, RN-AUD-03):

- Login y logout de usuarios.
- Cambios de perfil de usuario.
- Todas las transiciones de estado del caso.
- Generación de informes.

**Nota sobre eliminación de casos**: en el MVP no existe eliminación
física de casos. El ciclo de vida del caso termina en el estado
`cerrado`. Cualquier desactivación o baja de un caso debe tratarse
como una decisión administrativa excepcional documentada — no como
una operación ordinaria del sistema. Si en fases posteriores se
requiere eliminación, debe formalizarse mediante ADR y quedar
auditada.

Los registros de auditoría no pueden modificarse ni eliminarse bajo
ninguna circunstancia — solo `INSERT` (RN-AUD-02). Cualquier
intento de modificación es una señal de alerta de seguridad.

---

## 7. Seguridad del módulo de IA

- El frontend nunca llama directamente a ningún proveedor de IA
  externo (RN-IA-03). Toda llamada pasa por el backend.
- Las credenciales del proveedor de IA viven en el servidor — nunca
  en el cliente.
- Toda llamada al módulo de IA queda registrada en `ai_request_log`
  con proveedor, modelo, prompt completo, respuesta, tokens y duración.
  Este log es inmutable (RN-IA-02, RN-AUD-02).
- El contexto enviado al proveedor de IA puede contener datos del
  expediente jurídico. La política de anonimización de ese contexto
  antes de enviarlo a un tercero no está definida para el MVP y queda
  como decisión pendiente antes de operar con usuarios reales.

---

## 8. Responsabilidades

| Área | Responsable |
|---|---|
| Configuración de Nginx y TLS | Equipo técnico |
| Gestión de variables de entorno | Equipo técnico |
| Rotación de secretos | Equipo técnico |
| Gestión de backups | Equipo técnico |
| Gestión de perfiles de usuario | Administrador del sistema |
| Revisión de logs de auditoría | Supervisor / Administrador |
